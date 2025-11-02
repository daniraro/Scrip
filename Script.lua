-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO V3.1 - WEBHOOK REPARADO COM PROXIES ATUALIZADOS

if _G.scriptEnabled == nil then _G.scriptEnabled = true end
if _G.webhookEnabled == nil then _G.webhookEnabled = false end  -- Desativado por padrão
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.05 end
if _G.upgradeDelay == nil then _G.upgradeDelay = 0.15 end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

-- ⭐ PROXIES ATUALIZADOS E FUNCIONANDO ⭐
local PROXIES = {
    "https://proxydiscord.com",              -- Proxy 1 (MELHOR)
    "https://github-proxy.sleepie.dev",     -- Proxy 2 (NOVO)
    "https://hooks.hyra.io",                 -- Proxy 3 (BACKUP)
    "https://webhook.cool",                  -- Proxy 4 (BACKUP)
}

local currentProxyIndex = 1

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if not scriptStartTime then scriptStartTime = tick() end

-- GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"
gui.ResetOnSpawn = false
pcall(function() if syn then syn.protect_gui(gui) end gui.Parent = game:GetService("CoreGui") end)
if gui.Parent == nil then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 500)
frame.Position = UDim2.new(0.5, -150, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(75, 40, 120)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(150, 100, 200)
frameStroke.Transparency = 0.2
frameStroke.Thickness = 2
frameStroke.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 25, 90)
titleLabel.BackgroundTransparency = 0.3
titleLabel.BorderSizePixel = 0
titleLabel.Text = "⚡ CODEX ULTRA ⚡"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleLabel

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -55)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = buttonContainer

local function createButton(text, order, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.15
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.LayoutOrder = order
    btn.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 150, 255)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.15 end)
    
    if callback then
        btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
    end
    return btn
end

local function createLabel(text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 28)
    label.Text = text
    label.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    label.BackgroundTransparency = 0.4
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 4)
    padding.Parent = label
    return label
end

local statusLabel = createLabel("Status: ✅ ATIVADO", 1)
local upgradesLabel = createLabel("Upgrades: ⚙️ Carregando...", 2)
local fpsLabel = createLabel("FPS: -- | Webhook: ❌ DESATIVADO", 3)
local timerLabel = createLabel("Tempo: 00:00", 4)

local toggleBtn = createButton("🔴 DESATIVAR", 5, Color3.fromRGB(0, 150, 100), function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "🔴 DESATIVAR" or "✅ ATIVAR"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = _G.scriptEnabled and "Status: ✅ ATIVADO" or "Status: ⛔ DESATIVADO"
end)

local turboBtn = createButton("🚀 TURBO (5s)", 6, Color3.fromRGB(255, 140, 0), function()
    local old = {_G.floodIntensity, _G.floodDelay}
    _G.floodIntensity = 20
    _G.floodDelay = 0.016
    turboBtn.Text = "🚀 TURBO: ON"
    statusLabel.Text = "Status: 🚀 TURBO!"
    task.wait(5)
    _G.floodIntensity = old[1]
    _G.floodDelay = old[2]
    turboBtn.Text = "🚀 TURBO (5s)"
    statusLabel.Text = "Status: ✅ ATIVADO"
end)

local webhookToggle = createButton("WEBHOOK: OFF", 7, Color3.fromRGB(150, 50, 50), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookToggle.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookToggle.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 100, 180) or Color3.fromRGB(150, 50, 50)
    
    if _G.webhookEnabled then
        print("⚠️ WEBHOOK ATIVADO - Necessário configurar URL no console!")
        print("_G.webhookUrl = 'https://discord.com/api/webhooks/...'")
    else
        print("✅ Webhook desativado")
    end
end)

local setupWebhook = createButton("⚙️ WEBHOOK (AVANÇADO)", 8, Color3.fromRGB(120, 80, 180), function()
    print("\n" .. string.rep("=", 50))
    print("⚙️  CONFIGURAÇÃO AVANÇADA DE WEBHOOK")
    print(string.rep("=", 50))
    print("\n📍 PASSO 1: Copie sua URL do webhook Discord:")
    print("   (https://discord.com/api/webhooks/...)\n")
    print("📍 PASSO 2: Cole no console (F9):")
    print('   _G.webhookUrl = "sua_url_aqui"\n')
    print("📍 PASSO 3: Execute:")
    print("   _G.webhookEnabled = true\n")
    print("📍 PASSO 4: Clique em 'ENVIAR' para testar\n")
    print("⚠️  NOTA: Discord bloqueia Roblox. Proxies automáticos serão usados.")
    print("Se não funcionar, tente um serviço de webhook de terceiros.")
    print(string.rep("=", 50) .. "\n")
    
    statusLabel.Text = "Status: Veja console F9"
end)

local sendInfoBtn = createButton("📨 ENVIAR", 9, Color3.fromRGB(100, 60, 150), function()
    if not _G.webhookEnabled then
        print("❌ Webhook desativado! Ative primeiro.")
        statusLabel.Text = "Status: Webhook desativado"
        return
    end
    
    if not _G.webhookUrl then
        print("❌ URL do webhook não configurada!")
        print("Execute: _G.webhookUrl = 'sua_url'")
        statusLabel.Text = "Status: Configure webhook"
        return
    end
    
    print("📨 Enviando webhook...")
    statusLabel.Text = "Status: Enviando..."
    
    local uptime = math.floor(tick() - (scriptStartTime or tick()))
    local minutes = math.floor(uptime / 60)
    local seconds = uptime % 60
    
    sendWebhookMessage("📨 Relatório Codex",
        "👤 Jogador: " .. Players.LocalPlayer.Name ..
        "\n🏷️ PlaceId: " .. game.PlaceId ..
        "\n⏱️ Tempo: " .. string.format("%02d:%02d", minutes, seconds) ..
        "\n🖥️ FPS: " .. fps ..
        "\n🎮 Status: " .. (_G.scriptEnabled and "✅ Ativado" or "⛔ Desativado"),
        16751616
    )
    
    task.wait(2)
    statusLabel.Text = "Status: ✅ ATIVADO"
end)

local compactBtn = createButton("Modo Compacto: OFF", 10, Color3.fromRGB(70, 40, 120), function()
    local isCompact = compactBtn.Text == "Modo Compacto: OFF"
    compactBtn.Text = "Modo Compacto: " .. (isCompact and "ON" or "OFF")
end)

-- ===== WEBHOOK FUNCTIONS =====
local function getProxyUrl(webhookUrl)
    if not webhookUrl then return nil end
    local id, token = webhookUrl:match("https://discord.com/api/webhooks/(%d+)/(.+)")
    if not id or not token then return nil end
    
    -- Usar proxy atualizado
    return PROXIES[currentProxyIndex] .. "/api/webhooks/" .. id .. "/" .. token
end

function sendWebhookMessage(title, description, color)
    if not _G.webhookUrl or not _G.webhookEnabled then return end
    
    local proxyUrl = getProxyUrl(_G.webhookUrl)
    if not proxyUrl then
        print("❌ URL inválida ou proxy não encontrado")
        return
    end
    
    print("🔗 Proxy usando: " .. PROXIES[currentProxyIndex])
    
    local payload = {
        content = "",
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(proxyUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        print("✅ Webhook enviado com sucesso!")
        statusLabel.Text = "Status: ✅ Enviado"
    else
        print("❌ Erro ao enviar webhook:")
        print("   Resposta: " .. tostring(response))
        
        -- Tentar próximo proxy
        currentProxyIndex = currentProxyIndex + 1
        if currentProxyIndex > #PROXIES then currentProxyIndex = 1 end
        print("🔄 Tentando próximo proxy: " .. PROXIES[currentProxyIndex])
        
        statusLabel.Text = "Status: ❌ Falha (trocando proxy)"
    end
end

-- FPS Counter
local fps = 0
local fpsCount = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastUpdate >= 1 then
        fps = fpsCount
        fpsLabel.Text = "FPS: " .. fps .. " | Webhook: " .. (_G.webhookEnabled and "✅" or "❌")
        fpsCount = 0
        lastUpdate = tick()
    end
end)

spawn(function()
    local startTime = tick()
    while task.wait(1) do
        if _G.scriptEnabled then
            local runtime = math.floor(tick() - startTime)
            local minutes = math.floor(runtime / 60)
            local seconds = runtime % 60
            timerLabel.Text = "Tempo: " .. string.format("%02d:%02d", minutes, seconds)
        end
    end
end)

-- ===== CARREGAMENTO DE EVENTOS =====
local clickEvents = {}
local upgradeEvents = {}
local dungeonEvents = {}

local function preloadEvents()
    print("🔄 Carregando eventos...")
    local Events = ReplicatedStorage:WaitForChild("Events", 5)
    if not Events then print("❌ Events não encontrada") return end
    
    local function safeWait(parent, name) if not parent then return nil end return parent:WaitForChild(name, 3) end
    
    local DungeonAttack = safeWait(Events, "DungeonAttack")
    if DungeonAttack then
        dungeonEvents = {
            attack = DungeonAttack,
            changeEnemy = safeWait(DungeonAttack, "ChangeEnemy"),
            rebirth = safeWait(DungeonAttack, "DungeonRebirth"),
            upgrade1 = safeWait(DungeonAttack, "DungeonUpgrade"),
            upgrade2 = safeWait(DungeonAttack, "DungeonUpgrade2")
        }
        print("✅ Dungeon eventos carregados")
    end
    
    local ClickMoney = safeWait(Events, "ClickMoney")
    if ClickMoney then
        clickEvents = {
            safeWait(ClickMoney, "AtomClicker") or ClickMoney,
            safeWait(ClickMoney, "ClickMining"),
            safeWait(ClickMoney, "ClickMining2"),
        }
        print("✅ Click eventos carregados")
    end
    
    local Prestige = safeWait(Events, "Prestige")
    if Prestige then
        table.insert(clickEvents, safeWait(Prestige, "Runestone4"))
    end
    
    local Upgrade = safeWait(Events, "Upgrade")
    if Upgrade then
        local upgradeList = {
            {"TranscendUpgrade", 30}, {"TimeUpgrade", 10}, {"ExtraUpgrade", 35}, {"AtomUpgrade2", 15},
            {"MiningUpgrade", 35}, {"MiningUpgrade2", 20}, {"RuneUpgrade", 30}, {"RuneUpgrade2", 25},
            {"JewelUpgrade", 25}, {"ExtraUpgrade3", 40}, {"ConcreteUpgrade", 30}, {"GemUpgrade", 15}
        }
        for _, data in ipairs(upgradeList) do
            local evt = safeWait(Upgrade, data[1])
            if evt then
                table.insert(upgradeEvents, {event = evt, maxId = data[2]})
            end
        end
        print("✅ " .. #upgradeEvents .. " upgrades carregados")
    end
    
    local BuyRune = safeWait(Events, "BuyRune")
    if BuyRune then
        local evt = safeWait(BuyRune, "EquipRune")
        if evt then table.insert(upgradeEvents, {event = evt, maxId = 10}) end
    end
    
    if Prestige then
        local evt1 = safeWait(Prestige, "PrestigeUpgrade")
        if evt1 then table.insert(upgradeEvents, {event = evt1, maxId = 30}) end
        
        local evt2 = safeWait(Prestige, "ResearchUpgrade")
        if evt2 then table.insert(upgradeEvents, {event = evt2, maxId = 80}) end
    end
    
    upgradesLabel.Text = "Upgrades: ⚙️ " .. #upgradeEvents .. " OK"
    print("✅ TOTAL: " .. #upgradeEvents .. " upgrades | " .. #clickEvents .. " clickers")
end

spawn(preloadEvents)

-- ===== AUTO SYSTEMS =====
spawn(function()
    while true do
        if _G.scriptEnabled then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, _G.floodIntensity do
                        pcall(function() event:FireServer() end)
                    end
                end
            end
        end
        task.wait(_G.floodDelay)
    end
end)

spawn(function()
    while task.wait(_G.upgradeDelay) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in ipairs(upgradeEvents) do
                if upgrade.event then
                    task.spawn(function()
                        for id = 1, math.min(upgrade.maxId, 5) do
                            pcall(function() upgrade.event:FireServer(id) end)
                        end
                    end)
                end
            end
        end
    end
end)

spawn(function()
    while true do
        if dungeonEvents.attack then
            for i = 1, _G.floodIntensity do
                pcall(function() dungeonEvents.attack:FireServer() end)
            end
        end
        if dungeonEvents.changeEnemy then
            pcall(function() dungeonEvents.changeEnemy:FireServer(1) end)
        end
        task.wait(_G.floodDelay)
    end
end)

spawn(function()
    while true do
        if dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function() dungeonEvents.rebirth:FireServer() end)
            end
        end
        task.wait(0.2)
    end
end)

spawn(function()
    while true do
        if dungeonEvents.upgrade1 then
            for i = 1, 3 do
                pcall(function() dungeonEvents.upgrade1:FireServer() end)
            end
        end
        if dungeonEvents.upgrade2 then
            for i = 1, 3 do
                pcall(function() dungeonEvents.upgrade2:FireServer() end)
            end
        end
        task.wait(0.2)
    end
end)

spawn(function()
    while true do
        pcall(function()
            local Prestige = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("Prestige")
            if Prestige then
                local concreteEvent = Prestige:FindFirstChild("ConcretePrestige")
                if concreteEvent then
                    for i = 1, 5 do
                        concreteEvent:FireServer()
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then
        turboBtn.MouseButton1Click:Fire()
    end
end)

print("✅✅✅ CODEX ULTRA V3.1 - WEBHOOK REPARADO ✅✅✅")
print("✅ Webhook DESATIVADO por padrão (Discord bloqueia)")
print("✅ Proxies atualizados: proxydiscord.com + github-proxy.sleepie.dev")
print("✅ Para ativar webhook:")
print('   1. _G.webhookUrl = "https://discord.com/api/webhooks/..."')
print("   2. _G.webhookEnabled = true")
print("   3. Clique em ENVIAR")
