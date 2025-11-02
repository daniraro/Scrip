-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO ULTRA V2.7 (COMPLETO - SEM REMOVER NADA + UPGRADES CORRIGIDOS)

-- Script inicia ATIVADO
if _G.scriptEnabled == nil then _G.scriptEnabled = true end

-- Configuração de delays otimizados
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.05 end
if _G.upgradeDelay == nil then _G.upgradeDelay = 0.15 end
if _G.dungeonDelay == nil then _G.dungeonDelay = 0.1 end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

-- Rate limiter para webhooks
local webhookRateLimiter = {
    lastRequest = 0,
    minDelay = 0.4
}

local webhookQueue = {}
local isProcessingQueue = false

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Criar ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"
gui.ResetOnSpawn = false

pcall(function()
    if syn then syn.protect_gui(gui) end
    gui.Parent = game:GetService("CoreGui")
end)

if gui.Parent == nil then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

if not scriptStartTime then scriptStartTime = tick() end

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 430)
frame.Position = UDim2.new(0.5, -140, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(75, 40, 120)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(130, 80, 180)
frameStroke.Transparency = 0.3
frameStroke.Thickness = 2
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 60, 140)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 30, 100))
}
frameGradient.Rotation = 45
frameGradient.Parent = frame

-- Container do título
local titleContainer = Instance.new("Frame")
titleContainer.Name = "TitleContainer"
titleContainer.Size = UDim2.new(1, 0, 0, 50)
titleContainer.Position = UDim2.new(0, 0, 0, 0)
titleContainer.BackgroundColor3 = Color3.fromRGB(50, 25, 90)
titleContainer.BackgroundTransparency = 0.3
titleContainer.BorderSizePixel = 0
titleContainer.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleContainer

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 50, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Text = "CODEX ULTRA"
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = titleContainer

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 0, 40)
titleIcon.Position = UDim2.new(0, 5, 0.5, -20)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "⚡"
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextSize = 28
titleIcon.TextColor3 = Color3.fromRGB(200, 150, 255)
titleIcon.Parent = titleContainer

-- Container de conteúdo
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 200)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = frame

-- UIListLayout
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = contentFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Função para criar botões
local function createButton(text, layoutOrder, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text:gsub(" ", "")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.LayoutOrder = layoutOrder
    btn.Parent = contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0
        stroke.Transparency = 0.4
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 0.2
        stroke.Transparency = 0.7
    end)
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    return btn
end

-- Função para criar labels
local function createInfoLabel(text, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Name = text:gsub(" ", ""):gsub(":", "")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Text = text
    label.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    label.BackgroundTransparency = 0.3
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = layoutOrder
    label.Parent = contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = label
    
    return label
end

-- Elementos da UI
local statusLabel = createInfoLabel("Status: ✅ ATIVADO", 1)
local upgradesLabel = createInfoLabel("Upgrades: ⚙️ Funcionando", 2)
local fpsLabel = createInfoLabel("FPS: --", 3)
local webhookStatusLabel = createInfoLabel("Webhook: ✅ Pronto", 4)

-- Botão toggle
local toggleBtn = createButton("🔴 DESATIVAR", 5, Color3.fromRGB(0, 150, 100), function()
    _G.scriptEnabled = not _G.scriptEnabled
    if _G.scriptEnabled then
        toggleBtn.Text = "🔴 DESATIVAR"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        statusLabel.Text = "Status: ✅ ATIVADO"
    else
        toggleBtn.Text = "✅ ATIVAR"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: ⛔ DESATIVADO"
    end
end)

-- Botão Turbo (Tecla B)
local turboBtn = createButton("🚀 TURBO: OFF", 6, Color3.fromRGB(255, 150, 0), function()
    local oldIntensity = _G.floodIntensity
    local oldDelay = _G.floodDelay
    
    _G.floodIntensity = 20
    _G.floodDelay = 0.016
    turboBtn.Text = "🚀 TURBO: ON"
    turboBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.Text = "Status: 🚀 TURBO ATIVO"
    
    task.wait(5)
    
    _G.floodIntensity = oldIntensity
    _G.floodDelay = oldDelay
    turboBtn.Text = "🚀 TURBO: OFF"
    turboBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    statusLabel.Text = "Status: ✅ ATIVADO"
end)

-- Botões webhook
local webhookBtn = createButton("WEBHOOK: ON", 7, Color3.fromRGB(20, 100, 180), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 100, 180) or Color3.fromRGB(100, 100, 100)
end)

local urlBtn = createButton("⚙️ CONFIGURAR", 8, Color3.fromRGB(80, 50, 130), nil)
local sendInfoBtn = createButton("📨 ENVIAR INFO", 9, Color3.fromRGB(100, 60, 140), nil)
local compactBtn = createButton("Modo Compacto: OFF", 10, Color3.fromRGB(70, 40, 110), nil)

-- Sistema de Webhook
local function validateWebhookUrl(url)
    if not url then return false end
    return url:match("^https://discord.com/api/webhooks/") ~= nil
end

local function waitForRateLimit()
    local now = tick()
    if now - webhookRateLimiter.lastRequest < webhookRateLimiter.minDelay then
        task.wait(webhookRateLimiter.minDelay - (now - webhookRateLimiter.lastRequest))
    end
end

local function sendWebhookWithRetry(title, description, color, retryCount, maxRetries)
    retryCount = retryCount or 0
    maxRetries = maxRetries or 3
    
    if not _G.webhookEnabled or not _G.webhookUrl or not validateWebhookUrl(_G.webhookUrl) then
        return false
    end
    
    waitForRateLimit()
    
    local embed = {
        title = title,
        description = description,
        color = color or 3447003,
        footer = { text = "Codex Ultra v2.7" },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    local payload = { content = "", embeds = { embed } }
    local body = HttpService:JSONEncode(payload)
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = _G.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "CodexUltra/2.7"
            },
            Body = body
        })
    end)
    
    webhookRateLimiter.lastRequest = tick()
    
    if not success then
        if retryCount < maxRetries then
            table.insert(webhookQueue, {
                title = title,
                description = description,
                color = color,
                retryCount = retryCount + 1,
                timestamp = tick()
            })
            webhookStatusLabel.Text = "Webhook: 📋 Enfileirado"
        end
        return false
    end
    
    if response.StatusCode == 204 or response.StatusCode == 200 then
        webhookStatusLabel.Text = "Webhook: ✅ Pronto"
        return true
    elseif response.StatusCode == 429 then
        if retryCount < maxRetries then
            task.wait(1)
            table.insert(webhookQueue, {
                title = title,
                description = description,
                color = color,
                retryCount = retryCount + 1,
                timestamp = tick()
            })
        end
        return false
    else
        webhookStatusLabel.Text = "Webhook: ❌ Erro " .. response.StatusCode
        return false
    end
end

-- Processar fila de webhook
spawn(function()
    while true do
        task.wait(1)
        
        if #webhookQueue > 0 and not isProcessingQueue then
            isProcessingQueue = true
            local item = table.remove(webhookQueue, 1)
            if item then
                sendWebhookWithRetry(item.title, item.description, item.color, item.retryCount or 0)
            end
            isProcessingQueue = false
        end
    end
end)

local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return false end
    if not _G.webhookUrl or not validateWebhookUrl(_G.webhookUrl) then
        return false
    end
    return sendWebhookWithRetry(title, description, color or 3447003, 0, 3)
end

-- Configurar webhook URL
urlBtn.MouseButton1Click:Connect(function()
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "WebhookPrompt"
    
    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 400, 0, 220)
    promptFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
    promptFrame.BackgroundColor3 = Color3.fromRGB(60, 30, 110)
    promptFrame.BackgroundTransparency = 0.1
    promptFrame.BorderSizePixel = 0
    promptFrame.Parent = promptGui
    
    local promptCorner = Instance.new("UICorner")
    promptCorner.CornerRadius = UDim.new(0, 16)
    promptCorner.Parent = promptFrame
    
    local promptStroke = Instance.new("UIStroke")
    promptStroke.Color = Color3.fromRGB(150, 100, 200)
    promptStroke.Thickness = 2
    promptStroke.Parent = promptFrame
    
    local promptTitle = Instance.new("TextLabel")
    promptTitle.Size = UDim2.new(1, -20, 0, 35)
    promptTitle.Position = UDim2.new(0, 10, 0, 10)
    promptTitle.BackgroundTransparency = 1
    promptTitle.TextColor3 = Color3.new(1, 1, 1)
    promptTitle.Font = Enum.Font.GothamBold
    promptTitle.TextSize = 16
    promptTitle.Text = "⚙️ Configurar Webhook"
    promptTitle.Parent = promptFrame
    
    local instructionLabel = Instance.new("TextLabel")
    instructionLabel.Size = UDim2.new(1, -30, 0, 40)
    instructionLabel.Position = UDim2.new(0, 15, 0, 50)
    instructionLabel.BackgroundTransparency = 1
    instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    instructionLabel.Font = Enum.Font.Gotham
    instructionLabel.TextSize = 11
    instructionLabel.Text = "Cole a URL completa do webhook do Discord\n(https://discord.com/api/webhooks/...)"
    instructionLabel.TextWrapped = true
    instructionLabel.Parent = promptFrame
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(1, -40, 0, 45)
    urlInput.Position = UDim2.new(0, 20, 0, 95)
    urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
    urlInput.BackgroundTransparency = 0.3
    urlInput.TextColor3 = Color3.new(1, 1, 1)
    urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    urlInput.Text = _G.webhookUrl and validateWebhookUrl(_G.webhookUrl) and _G.webhookUrl or ""
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 11
    urlInput.ClearTextOnFocus = false
    urlInput.Parent = promptFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = urlInput
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.Parent = urlInput
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.3, -7, 0, 40)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 155)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.BackgroundTransparency = 0.2
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Text = "✅ SALVAR"
    saveBtn.Parent = promptFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 10)
    saveCorner.Parent = saveBtn
    
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.3, -7, 0, 40)
    testBtn.Position = UDim2.new(0.375, 0, 0, 155)
    testBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    testBtn.BackgroundTransparency = 0.2
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Text = "🧪 TESTAR"
    testBtn.Parent = promptFrame
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 10)
    testCorner.Parent = testBtn
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.3, -7, 0, 40)
    cancelBtn.Position = UDim2.new(0.7, 0, 0, 155)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    cancelBtn.BackgroundTransparency = 0.2
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 12
    cancelBtn.Text = "❌ CANCELAR"
    cancelBtn.Parent = promptFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 10)
    cancelCorner.Parent = cancelBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        local newUrl = urlInput.Text:match("^%s*(.-)%s*$")
        if validateWebhookUrl(newUrl) then
            _G.webhookUrl = newUrl
            promptGui:Destroy()
            webhookStatusLabel.Text = "Webhook: ✅ Configurado"
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            instructionLabel.Text = "❌ URL INVÁLIDA!"
            task.wait(1)
            urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
            instructionLabel.Text = "Cole a URL completa do webhook do Discord\n(https://discord.com/api/webhooks/...)"
        end
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        local newUrl = urlInput.Text:match("^%s*(.-)%s*$")
        if validateWebhookUrl(newUrl) then
            _G.webhookUrl = newUrl
            testBtn.Text = "⏳ TESTANDO"
            sendWebhookWithRetry(
                "🧪 Teste de Conexão",
                "✅ Webhook funcionando corretamente!",
                65280
            )
            task.wait(2)
            testBtn.Text = "🧪 TESTAR"
        else
            instructionLabel.Text = "❌ URL INVÁLIDA para testar!"
            task.wait(1.5)
            instructionLabel.Text = "Cole a URL completa do webhook do Discord\n(https://discord.com/api/webhooks/...)"
        end
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
    end)
    
    pcall(function()
        if syn then syn.protect_gui(promptGui) end
        promptGui.Parent = game:GetService("CoreGui")
    end)
    
    if promptGui.Parent == nil then
        promptGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Enviar informações
sendInfoBtn.MouseButton1Click:Connect(function()
    if not _G.webhookEnabled or not validateWebhookUrl(_G.webhookUrl) then
        webhookStatusLabel.Text = "Webhook: ❌ Configure URL"
        task.wait(1.5)
        webhookStatusLabel.Text = "Webhook: ✅ Pronto"
        return
    end

    local uptime = tostring(math.floor(tick() - (scriptStartTime or tick())))
    local minutes = math.floor(tonumber(uptime) / 60)
    local seconds = tonumber(uptime) % 60
    
    local description = string.format("📊 **Relatório**\n👤 %s\n🏷️ %s\n⏱️ %02d:%02d\n🖥️ %d FPS\n🎮 Status: %s",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        minutes, seconds,
        tostring(fps or 0),
        _G.scriptEnabled and "✅ Ativado" or "⛔ Desativado")

    sendWebhook("📨 Relatório", description, 16751616)
end)

-- Modo compacto
local compactMode = false
compactBtn.MouseButton1Click:Connect(function()
    compactMode = not compactMode
    compactBtn.Text = "Modo Compacto: " .. (compactMode and "ON" or "OFF")
    fpsLabel.Visible = not compactMode
    upgradesLabel.Visible = not compactMode
end)

-- FPS Counter
local fps = 0
local fpsCount = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastUpdate >= 1 then
        fps = fpsCount
        fpsLabel.Text = "FPS: " .. fps
        fpsCount = 0
        lastUpdate = tick()
    end
end)

-- ⭐ SISTEMA DE CARREGAMENTO DE EVENTOS
local clickEvents = {}
local upgradeEvents = {}
local dungeonEvents = {}

local function preloadEvents()
    print("🔄 Iniciando carregamento de eventos...")
    
    local Events = ReplicatedStorage:WaitForChild("Events", 5)
    if not Events then
        warn("❌ Pasta Events não encontrada!")
        upgradesLabel.Text = "Upgrades: ❌ Erro ao carregar"
        return
    end
    
    local function safeWait(parent, name, timeout)
        if not parent then return nil end
        return parent:WaitForChild(name, timeout or 5)
    end
    
    -- DUNGEON EVENTS
    print("📍 Carregando eventos de Dungeon...")
    local DungeonAttack = safeWait(Events, "DungeonAttack")
    if DungeonAttack then
        dungeonEvents = {
            attack = DungeonAttack,
            changeEnemy = safeWait(DungeonAttack, "ChangeEnemy"),
            rebirth = safeWait(DungeonAttack, "DungeonRebirth"),
            upgrade1 = safeWait(DungeonAttack, "DungeonUpgrade"),
            upgrade2 = safeWait(DungeonAttack, "DungeonUpgrade2")
        }
        print("✅ Eventos Dungeon carregados")
    end
    
    -- CLICK EVENTS
    print("📍 Carregando eventos de clique...")
    local ClickMoney = safeWait(Events, "ClickMoney")
    local Prestige = safeWait(Events, "Prestige")
    
    if ClickMoney then
        clickEvents = {
            safeWait(ClickMoney, "AtomClicker"),
            safeWait(ClickMoney, "ClickMining"),
            safeWait(ClickMoney, "ClickMining2"),
        }
        print("✅ Eventos Click carregados")
    end
    
    if Prestige then
        table.insert(clickEvents, safeWait(Prestige, "Runestone4"))
    end
    
    -- UPGRADE EVENTS
    print("📍 Carregando eventos de upgrades...")
    local Upgrade = safeWait(Events, "Upgrade")
    local BuyRune = safeWait(Events, "BuyRune")
    
    upgradeEvents = {}
    
    if Upgrade then
        local upgradeList = {
            "TranscendUpgrade", "TimeUpgrade", "ExtraUpgrade", "AtomUpgrade2",
            "MiningUpgrade", "MiningUpgrade2", "RuneUpgrade", "RuneUpgrade2",
            "JewelUpgrade", "ExtraUpgrade3", "ConcreteUpgrade", "GemUpgrade"
        }
        
        for _, upgradeName in ipairs(upgradeList) do
            local evt = safeWait(Upgrade, upgradeName)
            if evt then
                table.insert(upgradeEvents, {
                    name = upgradeName,
                    event = evt,
                    maxId = 30
                })
            end
        end
        print("✅ Eventos Upgrade carregados: " .. #upgradeEvents)
    end
    
    if BuyRune then
        local evt = safeWait(BuyRune, "EquipRune")
        if evt then
            table.insert(upgradeEvents, {
                name = "EquipRune",
                event = evt,
                maxId = 10
            })
        end
    end
    
    if Prestige then
        local evt1 = safeWait(Prestige, "PrestigeUpgrade")
        local evt2 = safeWait(Prestige, "ResearchUpgrade")
        
        if evt1 then
            table.insert(upgradeEvents, {
                name = "PrestigeUpgrade",
                event = evt1,
                maxId = 30
            })
        end
        
        if evt2 then
            table.insert(upgradeEvents, {
                name = "ResearchUpgrade",
                event = evt2,
                maxId = 80
            })
        end
    end
    
    print("✅ Total de upgrades carregados: " .. #upgradeEvents)
    upgradesLabel.Text = "Upgrades: ⚙️ " .. #upgradeEvents .. " OK"
end

spawn(preloadEvents)

-- ⭐ AUTO-CLICKERS
spawn(function()
    while true do
        if _G.scriptEnabled then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, _G.floodIntensity do
                        pcall(function()
                            event:FireServer()
                        end)
                    end
                end
            end
        end
        task.wait(_G.floodDelay)
    end
end)

-- ⭐ UPGRADES CORRIGIDOS
spawn(function()
    while task.wait(_G.upgradeDelay) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in ipairs(upgradeEvents) do
                local event = upgrade.event
                local maxId = upgrade.maxId
                
                if event then
                    task.spawn(function()
                        for id = 1, math.min(maxId, 5) do
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end
                    end)
                end
            end
        end
    end
end)

-- ⭐ DUNGEON ATTACK (SEMPRE ATIVO)
spawn(function()
    while true do
        if dungeonEvents.attack then
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
            end
        end
        
        if dungeonEvents.changeEnemy then
            pcall(function()
                dungeonEvents.changeEnemy:FireServer(1)
            end)
        end
        
        task.wait(_G.floodDelay)
    end
end)

-- ⭐ DUNGEON REBIRTH (SEMPRE ATIVO)
spawn(function()
    while true do
        if dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
        task.wait(0.2)
    end
end)

-- ⭐ DUNGEON UPGRADES (SEMPRE ATIVO)
spawn(function()
    while true do
        if dungeonEvents.upgrade1 then
            for i = 1, 3 do
                pcall(function()
                    dungeonEvents.upgrade1:FireServer()
                end)
            end
        end
        
        if dungeonEvents.upgrade2 then
            for i = 1, 3 do
                pcall(function()
                    dungeonEvents.upgrade2:FireServer()
                end)
            end
        end
        
        task.wait(0.2)
    end
end)

-- ⭐ CONCRETE PRESTIGE (SEMPRE ATIVO)
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
        _G.scriptEnabled = not _G.scriptEnabled
        if _G.scriptEnabled then
            toggleBtn.Text = "🔴 DESATIVAR"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            statusLabel.Text = "Status: ✅ ATIVADO"
            upgradesLabel.Text = "Upgrades: ⚙️ Funcionando"
        else
            toggleBtn.Text = "✅ ATIVAR"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            statusLabel.Text = "Status: ⛔ DESATIVADO"
            upgradesLabel.Text = "Upgrades: ⏸️ Pausado"
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 20
        _G.floodDelay = 0.016
        turboBtn.Text = "🚀 TURBO: ON"
        turboBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        statusLabel.Text = "Status: 🚀 TURBO"
        
        task.wait(5)
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        turboBtn.Text = "🚀 TURBO: OFF"
        turboBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "Status: ✅ ATIVADO"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while task.wait(5) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        if _G.scriptEnabled and not compactMode then
            statusLabel.Text = string.format("Status: ✅ (%02d:%02d)", minutes, seconds)
        end
    end
end)

print("✅ Codex Ultra V2.7 - COMPLETO INICIALIZADO!")
print("✅ Todas as funções presentes!")
print("✅ Upgrades corrigidos e funcionando!")
print("✅ Dungeon sempre ativo!")
print("✅ Concrete Prestige ativo!")
print("✅ Turbo (B) disponível!")
print("✅ Webhook com fila + retry!")
