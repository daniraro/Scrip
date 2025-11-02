#!/usr/bin/env python3
"""
webhook_bridge.py

Monitora um arquivo JSON (CodexWebhookQueue.json) contendo um array de mensagens
{ title, description, color, ts }
Envia cada item como embed para o Discord webhook configurado no primeiro argumento
ou no próprio item (se incluir url). Após enviar com sucesso, remove o item da fila.

Uso:
    python webhook_bridge.py --webhook <WEBHOOK_URL> [--file CodexWebhookQueue.json] [--poll 2]

Dependências: requests
    pip install requests

Observação: o arquivo deve ser acessível pelo usuário que roda este script. Ajuste o
caminho com --file se necessário (ex: executors de Lua podem gravar em pastas diferentes).
"""
import argparse
import json
import time
import os
import sys
from typing import List

try:
    import requests
except ImportError:
    print("Missing dependency 'requests'. Install with: pip install requests")
    sys.exit(1)


def load_queue(path: str) -> List[dict]:
    if not os.path.exists(path):
        return []
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
            if isinstance(data, list):
                return data
            return []
    except Exception as e:
        print(f"Failed to read/parse queue file {path}:", e)
        return []


def save_queue(path: str, queue: List[dict]):
    try:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(queue, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print("Failed to write queue file:", e)


def send_webhook(webhook_url: str, title: str, description: str, color: int = None):
    embed = {"title": title, "description": description}
    if color is not None:
        embed["color"] = int(color)
    payload = {"content": "", "embeds": [embed]}
    try:
        r = requests.post(webhook_url, json=payload, timeout=10)
        if r.status_code in (200, 204):
            return True
        else:
            print(f"Discord webhook returned status {r.status_code}: {r.text}")
            return False
    except Exception as e:
        print("Error sending webhook:", e)
        return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--webhook", required=True, help="Discord webhook URL to forward messages to")
    ap.add_argument("--file", default="CodexWebhookQueue.json", help="Queue file path to monitor")
    ap.add_argument("--poll", type=float, default=2.0, help="Polling interval in seconds")
    args = ap.parse_args()

    queue_file = args.file
    webhook_url = args.webhook
    poll = max(0.5, args.poll)

    print(f"Starting webhook bridge. Queue file: {queue_file}. Forwarding to: {webhook_url}")
    print("Press Ctrl+C to stop")

    while True:
        try:
            queue = load_queue(queue_file)
            if queue:
                remaining = []
                for item in queue:
                    url = item.get("url") or webhook_url
                    title = item.get("title", "Codex Message")
                    desc = item.get("description", "")
                    color = item.get("color")
                    ok = send_webhook(url, title, desc, color)
                    if not ok:
                        # keep the item for retry
                        remaining.append(item)
                    else:
                        print(f"Sent: {title}")
                # write remaining back
                save_queue(queue_file, remaining)
            time.sleep(poll)
        except KeyboardInterrupt:
            print("Stopping")
            break
        except Exception as e:
            print("Bridge error:", e)
            time.sleep(poll)


if __name__ == "__main__":
    main()
