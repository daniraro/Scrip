## What this repo is

This repository contains a single Roblox client-side Lua script: `Script.lua` (Codex Ultra). It's a runtime script that constructs a GUI, preloads remote events from `ReplicatedStorage.Events`, and drives large-volume remote calls (clicks, upgrades, dungeon actions). It also persists a Discord webhook URL via `DataStoreService` (and optionally `writefile`/`readfile`) and reports status via `HttpService`.

## Big-picture architecture & why

- Single-file, client-focused script: all logic lives in `Script.lua`. There is no server code in this repo. The script expects a Roblox environment with a `ReplicatedStorage.Events` folder containing named RemoteEvents (e.g. `ClickMoney`, `Upgrade`, `DungeonAttack`, `Prestige`).
- Key services used: `Players`, `ReplicatedStorage`, `RunService`, `HttpService`, `DataStoreService`, `UserInputService`, and `VirtualUser` (anti-AFK).
- Design choices you should preserve:
  - Events are preloaded via `WaitForChild` / `FindFirstChild` and then cached in arrays (`clickEvents`, `upgradeEvents`, `dungeonEvents`).
  - Heavy use of `spawn`, `pcall` and parallel event firing to maximize throughput. Changing concurrency patterns can dramatically change runtime behavior.
  - GUI is created at runtime (`CodexHUDPro`) and may be protected via `syn.protect_gui` if available.

## Project-specific conventions & patterns

- Global vs local config: the code uses both `local` variables and `_G` in different versions. When editing, keep the visible public config options (like `scriptEnabled`, `floodIntensity`, `floodDelay`, `webhookEnabled`, `webhookInterval`, `webhookUrl`) accessible in the same scope as the existing code to avoid breaking callers.
- Event naming and shapes: the code expects specific event names and argument shapes. Examples from the file:
  - Click events: `Events:WaitForChild("ClickMoney")`, `AtomClicker`, `ClickMining`, `ClickMining2`.
  - Upgrade events: `Upgrade:TranscendUpgrade`, `TimeUpgrade`, etc. Many upgrades are fired by ID (1..N).
  - Dungeon events: `DungeonAttack`, `ChangeEnemy`, `DungeonRebirth`, `DungeonUpgrade`.
- Webhook persistence keys: saved under `CodexWebhook_<playerName>` in `DataStoreService` and optionally `CodexWebhook.txt` when `writefile`/`readfile` are available. Respect both mechanisms when reading/writing.

## Integration points & external dependencies

- ReplicatedStorage.Events: must exist in the running place. Code uses `:WaitForChild` with timeouts and `FindFirstChild` in places — keep these to avoid nil derefs.
- DataStoreService: used to persist webhook URL (server-side datastore). Editing datastore keys changes user-specific persistence.
- HttpService: used to POST to Discord webhooks — take care with rate limits. The script already exposes `webhookInterval` to control frequency.
- Executor-only APIs: the script optionally calls `writefile/readfile` and `syn.protect_gui` if the environment exposes them. Only use these when present.

## How to run & debug (developer workflows)

1. Run inside Roblox Studio (Play Solo) or the intended runtime. Ensure `ReplicatedStorage.Events` structure matches the expected event names.
2. Use the Output window in Studio to see the script's `print`/`warn` messages. The script prints several startup messages (e.g. "✓ Script Codex Ultra Otimizado...").
3. To test webhooks safely, use a disposable/test Discord webhook and increase `webhookInterval` to avoid rate limits. The webhook key used in DataStore is `CodexWebhook_<playerName>`.
4. Keybinds available in the UI: N = toggle UI visibility, M = enable/disable the main script loop, B = temporary boost. These are useful quick-debug controls.

## Small edit rules for AI agents

- Preserve event names and the structure of `clickEvents`, `upgradeEvents`, `dungeonEvents` unless you have evidence the target game uses different names. Example: do not change `Events:WaitForChild("ClickMoney")` to another name.
- When you modify concurrency (replace `spawn` loops with coroutines or timers), include a comment explaining the reason and run a quick smoke-check: ensure `clickEvents` entries are still fired and that `statusLabel` updates.
- Respect optional executor APIs: guard any `writefile`, `syn` or similar calls with `if writefile then ... end`.
- Avoid increasing default `floodIntensity` or decreasing `floodDelay` without profiling; those are the main knobs affecting server load and rate limits.

## Examples for common tasks

- Change default webhook interval to 30s (recommended to reduce rate-limit risk): edit the top of `Script.lua` and set `webhookInterval = 30` (or `_G.webhookInterval = 30` depending on which variant you modify).
- Add logging for a specific event before firing: insert `print("Firing TranscendUpgrade id=", id)` inside the loop that calls `event:FireServer(id)` for `TranscendUpgrade`.

## Files to inspect for context

- `Script.lua` — main and only source of truth for runtime behavior.
- There is no server code or build/test harness in this repo; runtime behavior must be validated in the Roblox runtime (Studio or the target environment).

If any of these assumptions are incorrect (e.g. there are additional files, a different runtime, or you want a stricter merging strategy), tell me which parts to change and I will iterate on this file.

---
Feedback request: Is there any other project-specific info you want added (for example, a list of exact RemoteEvent names or recommended safe defaults)? I can update this file quickly.
