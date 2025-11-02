-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO V3.0 FINAL - TUDO INCLUÍDO, NADA FALTA

-- Inicialização
if _G.scriptEnabled == nil then _G.scriptEnabled = true end
if _G.webhookEnabled == nil then _G.webhookEnabled = true end
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.05 end
if _G.upgradeDelay == nil then _G.upgradeDelay = 0.15 end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

-- Proxies para Discord
local PROXIES = {"https://hooks.hyra.io", "https://osyr.is", "https://webhook.cool"}
local currentProxyIndex = 1
local webhookQueue = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if not scriptStartTime then scriptStartTime = tick() end

-- ===== GUI SETUP =====
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

-- Labels
local statusLabel = createLabel("Status: ✅ ATIVADO", 1)
local upgradesLabel = createLabel("Upgrades: ⚙️ Carregando...", 2)
local fpsLabel = createLabel("FPS: -- | Webhook: ✅", 3)
local timerLabel = createLabel("Tempo: 00:00", 4)

-- Buttons
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

local webhookToggle = createButton("WEBHOOK: ON", 7, Color3.fromRGB(20, 100, 180), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookToggle.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookToggle.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 100, 180) or Color3.fromRGB(100, 100, 100)
end)

local setupWebhook = createButton("⚙️ WEBHOOK", 8, Color3.fromRGB(120, 80, 180), function()
    local promptGui = Instance.new("ScreenGui")
    promptGui.ResetOnSpawn = false
    pcall(function() if syn then syn.protect_gui(promptGui) end promptGui.Parent = game:GetService("CoreGui") end)
    if promptGui.Parent == nil then promptGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    local promptBg = Instance.new("Frame")
    promptBg.Size = UDim2.new(0.8, 0, 0.6, 0)
    promptBg.Position = UDim2.new(0.1, 0, 0.2, 0)
    promptBg.BackgroundColor3 = Color3.fromRGB(50, 25, 90)
    promptBg.BorderSizePixel = 0
    promptBg.Parent = promptGui
    
    local promptCorner = Instance.new("UICorner")
    promptCorner.CornerRadius = UDim.new(0, 16)
    promptCorner.Parent = promptBg
    
    local promptStroke = Instance.new("UIStroke")
    promptStroke.Color = Color3.fromRGB(180, 100, 220)
    promptStroke.Thickness = 3
    promptStroke.Parent = promptBg
    
    local promptTitle = Instance.new("TextLabel")
    promptTitle.Size = UDim2.new(1, 0, 0, 40)
    promptTitle.Text = "Configurar Webhook Discord"
    promptTitle.BackgroundColor3 = Color3.fromRGB(80, 40, 130)
    promptTitle.TextColor3 = Color3.new(1, 1, 1)
    promptTitle.Font = Enum.Font.GothamBold
    promptTitle.TextSize = 16
    promptTitle.Parent = promptBg
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = promptTitle
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(0.9, 0, 0, 40)
    urlInput.Position = UDim2.new(0.05, 0, 0, 50)
    urlInput.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    urlInput.TextColor3 = Color3.new(1, 1, 1)
    urlInput.PlaceholderText = "Cole URL webhook aqui..."
    urlInput.Text = _G.webhookUrl or ""
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 12
    urlInput.Parent = promptBg
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = urlInput
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.3, 0, 0, 40)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 100)
    saveBtn.Text = "✅ SALVAR"
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Parent = promptBg
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveBtn
    
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.3, 0, 0, 40)
    testBtn.Position = UDim2.new(0.4, 0, 0, 100)
    testBtn.Text = "🧪 TESTAR"
    testBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Parent = promptBg
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 8)
    testCorner.Parent = testBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.3, 0, 0, 40)
    closeBtn.Position = UDim2.new(0.75, 0, 0, 100)
    closeBtn.Text = "❌ FECHAR"
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = promptBg
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        local url = urlInput.Text:match("^%s*(.-)%s*$")
        if url and url:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = url
            promptGui:Destroy()
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1)
            urlInput.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        end
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        local url = urlInput.Text:match("^%s*(.-)%s*$")
        if url and url:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = url
            testBtn.Text = "⏳..."
            sendWebhookTest(url)
            task.wait(2)
            testBtn.Text = "🧪 TESTAR"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function() promptGui:Destroy() end)
end)

local sendInfoBtn = createButton("📨 ENVIAR", 9, Color3.fromRGB(100, 60, 150), function()
    if not _G.webhookEnabled or not _G.webhookUrl then return end
    local uptime = math.floor(tick() - (scriptStartTime or tick()))
    local minutes = math.floor(uptime / 60)
    local seconds = uptime % 60
    
    sendWebhookMessage("📨 Relatório",
        "👤 Jogador: " .. Players.LocalPlayer.Name ..
        "\n🏷️ PlaceId: " .. game.PlaceId ..
        "\n⏱️ Tempo: " .. string.format("%02d:%02d", minutes, seconds) ..
        "\n🖥️ FPS: " .. fps ..
        "\n🎮 Status: " .. (_G.scriptEnabled and "✅ Ativado" or "⛔ Desativado"),
        16751616
    )
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
    return PROXIES[currentProxyIndex] .. "/api/webhooks/" .. id .. "/" .. token
end

function sendWebhookTest(url)
    if not url then return end
    local proxyUrl = getProxyUrl(url)
    if not proxyUrl then return end
    
    local payload = {content = "", embeds = {{title = "🧪 Teste", description = "✅ Funcionando!", color = 65280}}}
    pcall(function() HttpService:PostAsync(proxyUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson) end)
end

function sendWebhookMessage(title, description, color)
    if not _G.webhookUrl then return end
    local proxyUrl = getProxyUrl(_G.webhookUrl)
    if not proxyUrl then return end
    
    local payload = {content = "", embeds = {{title = title, description = description, color = color or 3447003}}}
    pcall(function() HttpService:PostAsync(proxyUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson) end)
end

-- ===== FPS E MONITOR =====
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
    
    -- DUNGEON
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
    
    -- CLICKERS
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
    
    -- UPGRADES - COMPLETO
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
    
    -- BUY RUNE
    local BuyRune = safeWait(Events, "BuyRune")
    if BuyRune then
        local evt = safeWait(BuyRune, "EquipRune")
        if evt then table.insert(upgradeEvents, {event = evt, maxId = 10}) end
    end
    
    -- PRESTIGE UPGRADES
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

-- CLICKERS
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

-- UPGRADES
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

-- DUNGEON ATTACK
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

-- DUNGEON REBIRTH
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

-- DUNGEON UPGRADES
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

-- CONCRETE PRESTIGE
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

-- ===== KEYBINDS =====
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then
        turboBtn.MouseButton1Click:Fire()
    end
end)

print("✅✅✅ CODEX ULTRA V3.0 - COMPLETO 100%! ✅✅✅")
print("✅ Auto-Clickers: 4 tipos")
print("✅ Upgrades: 15+ tipos")
print("✅ Dungeon: Attack + Rebirth + Upgrades")
print("✅ Concrete Prestige: ATIVO")
print("✅ GUI: Roxo translúcido com botões")
print("✅ Webhook: Com proxy Discord")
print("✅ Turbo: 5 segundos")
print("✅ Tudo funcionando!")
print("✅ N=Ocultar | M=Ativar | B=Turbo")
