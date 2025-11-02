-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO ULTRA V2.8 (WEBHOOK COM PROXY + BOTÕES CORRIGIDOS)

-- Script inicia ATIVADO
if _G.scriptEnabled == nil then _G.scriptEnabled = true end

-- Configuração de delays
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.05 end
if _G.upgradeDelay == nil then _G.upgradeDelay = 0.15 end
if _G.dungeonDelay == nil then _G.dungeonDelay = 0.1 end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

-- Proxies para Discord (já que Discord bloqueia Roblox)
local PROXIES = {
    "https://hooks.hyra.io",     -- Proxy 1 (mais confiável)
    "https://osyr.is",           -- Proxy 2
    "https://webhook.cool",      -- Proxy 3
}

local currentProxyIndex = 1

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
frame.Size = UDim2.new(0, 280, 0, 440)
frame.Position = UDim2.new(0.5, -140, 0.5, -220)
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
    btn.Name = text:gsub(" ", ""):gsub(":", ""):gsub("-", ""):gsub("!", "")
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
    btn.ZIndex = 10
    
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
    
    -- Conexão de clique com verificação adicional
    if callback then
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end
    
    return btn
end

-- Função para criar labels
local function createInfoLabel(text, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Name = text:gsub(" ", ""):gsub(":", ""):gsub("-", "")
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
    label.ZIndex = 5
    
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
local webhookStatusLabel = createInfoLabel("Webhook: ⏳ Aguardando", 4)

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

-- Botão turbo
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

-- Botão webhook
local webhookBtn = createButton("WEBHOOK: ON", 7, Color3.fromRGB(20, 100, 180), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 100, 180) or Color3.fromRGB(100, 100, 100)
    webhookStatusLabel.Text = "Webhook: " .. (_G.webhookEnabled and "✅ Ativo" or "❌ Inativo")
end)

local urlBtn = createButton("⚙️ CONFIGURAR", 8, Color3.fromRGB(80, 50, 130), nil)
local sendInfoBtn = createButton("📨 ENVIAR INFO", 9, Color3.fromRGB(100, 60, 140), nil)
local compactBtn = createButton("Modo Compacto: OFF", 10, Color3.fromRGB(70, 40, 110), nil)

-- ⭐ SISTEMA DE WEBHOOK COM PROXY ⭐
local function validateWebhookUrl(url)
    if not url then return false end
    return url:match("^https://discord.com/api/webhooks/") ~= nil
end

local function getProxyUrl(webhookUrl)
    if not webhookUrl then return nil end
    
    -- Extrair ID e token do webhook
    local id, token = webhookUrl:match("https://discord.com/api/webhooks/(%d+)/(.+)")
    if not id or not token then return nil end
    
    -- Retornar URL com proxy
    return PROXIES[currentProxyIndex] .. "/api/webhooks/" .. id .. "/" .. token
end

local function switchProxy()
    currentProxyIndex = currentProxyIndex + 1
    if currentProxyIndex > #PROXIES then
        currentProxyIndex = 1
    end
    print("🔄 Trocando proxy para: " .. PROXIES[currentProxyIndex])
end

local function sendWebhookWithProxy(title, description, color)
    if not _G.webhookEnabled or not _G.webhookUrl or not validateWebhookUrl(_G.webhookUrl) then
        return false
    end
    
    local proxyUrl = getProxyUrl(_G.webhookUrl)
    if not proxyUrl then
        webhookStatusLabel.Text = "Webhook: ❌ URL inválida"
        return false
    end
    
    local embed = {
        title = title,
        description = description,
        color = color or 3447003,
        footer = { text = "Codex Ultra v2.8" },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    local payload = {
        content = "",
        embeds = { embed }
    }
    
    local body = ""
    pcall(function()
        body = HttpService:JSONEncode(payload)
    end)
    
    local success, response = pcall(function()
        return HttpService:PostAsync(proxyUrl, body, Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        webhookStatusLabel.Text = "Webhook: ✅ Enviado"
        task.wait(0.5)
        webhookStatusLabel.Text = "Webhook: ✅ Pronto"
        return true
    else
        print("❌ Erro ao enviar webhook:", response)
        webhookStatusLabel.Text = "Webhook: 🔄 Tentando proxy..."
        switchProxy()
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
                sendWebhookWithProxy(item.title, item.description, item.color)
            end
            isProcessingQueue = false
        end
    end
end)

-- Configurar webhook URL
urlBtn.MouseButton1Click:Connect(function()
    print("📍 Clique no botão 'Configurar' detectado")
    
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "WebhookPrompt"
    promptGui.ZIndex = 100
    
    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 420, 0, 260)
    promptFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
    promptFrame.BackgroundColor3 = Color3.fromRGB(60, 30, 110)
    promptFrame.BackgroundTransparency = 0.1
    promptFrame.BorderSizePixel = 0
    promptFrame.Parent = promptGui
    promptFrame.ZIndex = 101
    
    local promptCorner = Instance.new("UICorner")
    promptCorner.CornerRadius = UDim.new(0, 16)
    promptCorner.Parent = promptFrame
    
    local promptStroke = Instance.new("UIStroke")
    promptStroke.Color = Color3.fromRGB(150, 100, 200)
    promptStroke.Thickness = 2
    promptStroke.Parent = promptFrame
    
    local promptTitle = Instance.new("TextLabel")
    promptTitle.Size = UDim2.new(1, -20, 0, 40)
    promptTitle.Position = UDim2.new(0, 10, 0, 10)
    promptTitle.BackgroundTransparency = 1
    promptTitle.TextColor3 = Color3.new(1, 1, 1)
    promptTitle.Font = Enum.Font.GothamBold
    promptTitle.TextSize = 16
    promptTitle.Text = "⚙️ Configurar Webhook Discord"
    promptTitle.ZIndex = 102
    promptTitle.Parent = promptFrame
    
    local instructionLabel = Instance.new("TextLabel")
    instructionLabel.Size = UDim2.new(1, -30, 0, 50)
    instructionLabel.Position = UDim2.new(0, 15, 0, 55)
    instructionLabel.BackgroundTransparency = 1
    instructionLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    instructionLabel.Font = Enum.Font.Gotham
    instructionLabel.TextSize = 11
    instructionLabel.Text = "Cole a URL do webhook Discord\n(https://discord.com/api/webhooks/...)"
    instructionLabel.TextWrapped = true
    instructionLabel.ZIndex = 102
    instructionLabel.Parent = promptFrame
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(1, -40, 0, 40)
    urlInput.Position = UDim2.new(0, 20, 0, 110)
    urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
    urlInput.BackgroundTransparency = 0.3
    urlInput.TextColor3 = Color3.new(1, 1, 1)
    urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    urlInput.Text = _G.webhookUrl and validateWebhookUrl(_G.webhookUrl) and _G.webhookUrl or ""
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 10
    urlInput.ClearTextOnFocus = false
    urlInput.ZIndex = 102
    urlInput.Parent = promptFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = urlInput
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.Parent = urlInput
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.28, -8, 0, 40)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 165)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.BackgroundTransparency = 0.2
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Text = "✅ SALVAR"
    saveBtn.ZIndex = 103
    saveBtn.Parent = promptFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 10)
    saveCorner.Parent = saveBtn
    
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.28, -8, 0, 40)
    testBtn.Position = UDim2.new(0.36, 0, 0, 165)
    testBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    testBtn.BackgroundTransparency = 0.2
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Text = "🧪 TESTAR"
    testBtn.ZIndex = 103
    testBtn.Parent = promptFrame
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 10)
    testCorner.Parent = testBtn
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.28, -8, 0, 40)
    cancelBtn.Position = UDim2.new(0.67, 0, 0, 165)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    cancelBtn.BackgroundTransparency = 0.2
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 12
    cancelBtn.Text = "❌ SAIR"
    cancelBtn.ZIndex = 103
    cancelBtn.Parent = promptFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 10)
    cancelCorner.Parent = cancelBtn
    
    saveBtn.MouseButton1Click:Connect(function()
        print("💾 Botão salvar clicado")
        local newUrl = urlInput.Text:match("^%s*(.-)%s*$")
        if validateWebhookUrl(newUrl) then
            _G.webhookUrl = newUrl
            webhookStatusLabel.Text = "Webhook: ✅ Configurado"
            print("✅ Webhook configurado com sucesso")
            promptGui:Destroy()
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            instructionLabel.Text = "❌ URL INVÁLIDA!"
            print("❌ URL inválida")
            task.wait(1)
            urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
            instructionLabel.Text = "Cole a URL do webhook Discord\n(https://discord.com/api/webhooks/...)"
        end
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        print("🧪 Testando webhook...")
        local newUrl = urlInput.Text:match("^%s*(.-)%s*$")
        if validateWebhookUrl(newUrl) then
            _G.webhookUrl = newUrl
            testBtn.Text = "⏳ TESTANDO"
            testBtn.TextSize = 10
            
            local result = sendWebhookWithProxy(
                "🧪 Teste",
                "✅ Webhook funcionando!",
                65280
            )
            
            if result then
                instructionLabel.Text = "✅ Webhook funcionando perfeitamente!"
            else
                instructionLabel.Text = "⚠️ Webhook com problema - verifique URL"
            end
            
            task.wait(2)
            testBtn.Text = "🧪 TESTAR"
            testBtn.TextSize = 12
        else
            instructionLabel.Text = "❌ URL INVÁLIDA para testar!"
            task.wait(1.5)
            instructionLabel.Text = "Cole a URL do webhook Discord\n(https://discord.com/api/webhooks/...)"
        end
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        print("❌ Prompt fechado")
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
    print("📨 Botão enviar clicado")
    if not _G.webhookEnabled or not validateWebhookUrl(_G.webhookUrl) then
        webhookStatusLabel.Text = "Webhook: ⚠️ Configure URL"
        task.wait(1.5)
        webhookStatusLabel.Text = "Webhook: ✅ Pronto"
        return
    end

    local uptime = tostring(math.floor(tick() - (scriptStartTime or tick())))
    local minutes = math.floor(tonumber(uptime) / 60)
    local seconds = tonumber(uptime) % 60
    
    local description = string.format("📊 **Relatório**\n👤 %s\n🏷️ %s\n⏱️ %02d:%02d\n🖥️ %d FPS",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        minutes, seconds,
        tostring(fps or 0))

    sendWebhookWithProxy("📨 Relatório", description, 16751616)
end)

-- Modo compacto
local compactMode = false
compactBtn.MouseButton1Click:Connect(function()
    print("📦 Modo compacto")
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

-- ⭐ CARREGAMENTO DE EVENTOS
local clickEvents = {}
local upgradeEvents = {}
local dungeonEvents = {}

local function preloadEvents()
    print("🔄 Iniciando carregamento de eventos...")
    
    local Events = ReplicatedStorage:WaitForChild("Events", 5)
    if not Events then
        warn("❌ Pasta Events não encontrada!")
        upgradesLabel.Text = "Upgrades: ❌ Erro"
        return
    end
    
    local function safeWait(parent, name, timeout)
        if not parent then return nil end
        return parent:WaitForChild(name, timeout or 5)
    end
    
    local DungeonAttack = safeWait(Events, "DungeonAttack")
    if DungeonAttack then
        dungeonEvents = {
            attack = DungeonAttack,
            changeEnemy = safeWait(DungeonAttack, "ChangeEnemy"),
            rebirth = safeWait(DungeonAttack, "DungeonRebirth"),
            upgrade1 = safeWait(DungeonAttack, "DungeonUpgrade"),
            upgrade2 = safeWait(DungeonAttack, "DungeonUpgrade2")
        }
    end
    
    local ClickMoney = safeWait(Events, "ClickMoney")
    local Prestige = safeWait(Events, "Prestige")
    
    if ClickMoney then
        clickEvents = {
            safeWait(ClickMoney, "AtomClicker"),
            safeWait(ClickMoney, "ClickMining"),
            safeWait(ClickMoney, "ClickMining2"),
        }
    end
    
    if Prestige then
        table.insert(clickEvents, safeWait(Prestige, "Runestone4"))
    end
    
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

-- ⭐ UPGRADES
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

-- ⭐ DUNGEON ATTACK
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

-- ⭐ DUNGEON REBIRTH
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

-- ⭐ DUNGEON UPGRADES
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

-- ⭐ CONCRETE PRESTIGE
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
            statusLabel.Text = "Status: ✅ ATIVADO"
        else
            toggleBtn.Text = "✅ ATIVAR"
            statusLabel.Text = "Status: ⛔ DESATIVADO"
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        turboBtn.MouseButton1Click:Fire()
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

print("✅ Codex Ultra V2.8 Inicializado!")
print("✅ Webhook com Proxy (Discord bloqueado - proxy ativado)")
print("✅ Botões funcionando")
print("✅ Proxy atual: " .. PROXIES[currentProxyIndex])
