-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO ULTRA V2.4 (GUI REDESENHADA + SEMPRE ATIVO)

-- Script inicia ATIVADO por padrão
if _G.scriptEnabled == nil then _G.scriptEnabled = true end

-- Configuração de delays otimizados
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.05 end
if _G.upgradeDelay == nil then _G.upgradeDelay = 0.5 end
if _G.dungeonDelay == nil then _G.dungeonDelay = 0.1 end
if _G.uiUpdateDelay == nil then _G.uiUpdateDelay = 0.5 end
if _G.webhookInterval == nil then _G.webhookInterval = 120 end
if _G.floodIntensity == nil then _G.floodIntensity = 10 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Criar ScreenGui root
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

-- Frame principal com cor ROXA TRANSLÚCIDA
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 400)  -- Maior e mais organizado
frame.Position = UDim2.new(0.5, -140, 0.5, -200)  -- Centralizado
frame.BackgroundColor3 = Color3.fromRGB(75, 40, 120)  -- Roxo
frame.BackgroundTransparency = 0.25  -- Translúcido
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Cantos arredondados no frame principal
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)  -- Bem arredondado
frameCorner.Parent = frame

-- Borda suave
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(130, 80, 180)  -- Roxo claro
frameStroke.Transparency = 0.3
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Gradiente roxo
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

-- Ícone do título
local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 0, 40)
titleIcon.Position = UDim2.new(0, 5, 0.5, -20)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "⚡"
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextSize = 28
titleIcon.TextColor3 = Color3.fromRGB(200, 150, 255)
titleIcon.Parent = titleContainer

-- Container de conteúdo com scroll
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 200)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Será ajustado automaticamente
contentFrame.Parent = frame

-- UIListLayout para organizar os elementos automaticamente
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)  -- Espaçamento entre botões
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = contentFrame

-- Atualizar tamanho do canvas automaticamente
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Função para criar botões padronizados e ARREDONDADOS
local function createButton(text, layoutOrder, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text:gsub(" ", "")
    btn.Size = UDim2.new(1, -20, 0, 45)  -- Maior e mais clicável
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.LayoutOrder = layoutOrder
    btn.Parent = contentFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    -- Borda
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = btn
    
    -- Efeito hover
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

-- Função para criar labels de informação
local function createInfoLabel(text, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Name = text:gsub(" ", ""):gsub(":", "")
    label.Size = UDim2.new(1, -20, 0, 35)
    label.Text = text
    label.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    label.BackgroundTransparency = 0.3
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = layoutOrder
    label.Parent = contentFrame
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    
    -- Padding interno
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = label
    
    return label
end

-- Criar elementos da UI de forma ORGANIZADA
local statusLabel = createInfoLabel("Status: ✅ ATIVADO", 1)
local fpsLabel = createInfoLabel("FPS: --", 2)

-- Botão principal de DESATIVAR/ATIVAR (inicia ativado)
local toggleBtn = createButton("🔴 DESATIVAR SCRIPT", 3, Color3.fromRGB(0, 150, 100), function()
    _G.scriptEnabled = not _G.scriptEnabled
    if _G.scriptEnabled then
        toggleBtn.Text = "🔴 DESATIVAR SCRIPT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        statusLabel.Text = "Status: ✅ ATIVADO"
    else
        toggleBtn.Text = "✅ ATIVAR SCRIPT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: ⛔ DESATIVADO"
    end
end)

-- Botão Webhook Toggle
local webhookBtn = createButton("WEBHOOK: ON", 4, Color3.fromRGB(20, 100, 180), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 100, 180) or Color3.fromRGB(100, 100, 100)
end)

-- Botão Configurar Webhook
local urlBtn = createButton("⚙️ CONFIGURAR WEBHOOK", 5, Color3.fromRGB(80, 50, 130), nil)

-- Botão Enviar Informações
local sendInfoBtn = createButton("📨 ENVIAR INFORMAÇÕES", 6, Color3.fromRGB(100, 60, 140), nil)

-- Botão Modo Compacto
local compactBtn = createButton("Modo Compacto: OFF", 7, Color3.fromRGB(70, 40, 110), nil)

-- Enhanced sendWebhook function
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return false end

    if not _G.webhookUrl or _G.webhookUrl == "" or _G.webhookUrl == "COLOQUE_URL_DO_WEBHOOK_AQUI" then
        statusLabel.Text = "Status: ⚠️ Configure Webhook!"
        return false
    end

    local embed = {
        title = title,
        description = description,
        color = color,
        footer = { text = "Codex Ultra Script v2.4" },
        timestamp = DateTime.now():ToIsoDate()
    }

    local payload = { content = "", embeds = { embed } }
    local body = HttpService:JSONEncode(payload)

    local function normalizeResponse(res)
        if type(res) == "table" and res.StatusCode then
            return res
        elseif type(res) == "table" and res.status then
            return { StatusCode = res.status, Body = res.body or res.text }
        elseif type(res) == "string" then
            return { StatusCode = 200, Body = res }
        else
            return { StatusCode = 0, Body = res }
        end
    end

    local function tryRequestCall(fn)
        local ok, res = pcall(fn)
        if ok and res then return normalizeResponse(res) end
        return nil
    end

    local response = nil

    if not response and syn and syn.request then
        response = tryRequestCall(function()
            return syn.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    if not response and http and http.request then
        response = tryRequestCall(function()
            return http.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    if not response and http_request then
        response = tryRequestCall(function()
            return http_request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    if not response and request then
        response = tryRequestCall(function()
            return request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    if not response then
        local ok, res = pcall(function()
            if HttpService.RequestAsync then
                return HttpService:RequestAsync({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            else
                local resBody = HttpService:PostAsync(_G.webhookUrl, body, Enum.HttpContentType.ApplicationJson)
                return { StatusCode = 200, Body = resBody }
            end
        end)
        if ok and res then response = normalizeResponse(res) end
    end

    if not response or (response.StatusCode ~= 204 and response.StatusCode ~= 200) then
        statusLabel.Text = "Status: ❌ Erro Webhook"
        task.wait(1)
        statusLabel.Text = "Status: ✅ ATIVADO"
        return false
    end

    statusLabel.Text = "Status: 📤 Webhook enviado"
    task.wait(1)
    statusLabel.Text = "Status: ✅ ATIVADO"
    return true
end

-- Configurar botão de webhook URL
urlBtn.MouseButton1Click:Connect(function()
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "WebhookPrompt"
    
    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 400, 0, 200)
    promptFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
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
    promptTitle.Size = UDim2.new(1, -20, 0, 40)
    promptTitle.Position = UDim2.new(0, 10, 0, 10)
    promptTitle.BackgroundTransparency = 1
    promptTitle.TextColor3 = Color3.new(1, 1, 1)
    promptTitle.Font = Enum.Font.GothamBold
    promptTitle.TextSize = 18
    promptTitle.Text = "⚙️ Configurar Webhook"
    promptTitle.Parent = promptFrame
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(1, -40, 0, 45)
    urlInput.Position = UDim2.new(0, 20, 0, 60)
    urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
    urlInput.BackgroundTransparency = 0.3
    urlInput.TextColor3 = Color3.new(1, 1, 1)
    urlInput.PlaceholderText = "Cole a URL do webhook Discord aqui..."
    urlInput.Text = _G.webhookUrl ~= "COLOQUE_URL_DO_WEBHOOK_AQUI" and _G.webhookUrl or ""
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 13
    urlInput.ClearTextOnFocus = false
    urlInput.Parent = promptFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = urlInput
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.Parent = urlInput
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, -10, 0, 45)
    saveBtn.Position = UDim2.new(0.05, 0, 0, 130)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.BackgroundTransparency = 0.2
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 16
    saveBtn.Text = "✅ SALVAR"
    saveBtn.Parent = promptFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 10)
    saveCorner.Parent = saveBtn
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.45, -10, 0, 45)
    cancelBtn.Position = UDim2.new(0.5, 5, 0, 130)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    cancelBtn.BackgroundTransparency = 0.2
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 16
    cancelBtn.Text = "❌ CANCELAR"
    cancelBtn.Parent = promptFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 10)
    cancelCorner.Parent = cancelBtn
    
    local function closePrompt()
        promptGui:Destroy()
    end
    
    saveBtn.MouseButton1Click:Connect(function()
        local newUrl = urlInput.Text
        if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = newUrl
            closePrompt()
            statusLabel.Text = "Status: ✅ Webhook configurado"
            task.wait(1)
            statusLabel.Text = "Status: ✅ ATIVADO"
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            urlInput.PlaceholderText = "❌ URL inválida!"
            task.wait(2)
            urlInput.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
            urlInput.PlaceholderText = "Cole a URL do webhook Discord aqui..."
        end
    end)
    
    cancelBtn.MouseButton1Click:Connect(closePrompt)
    
    pcall(function()
        if syn then syn.protect_gui(promptGui) end
        promptGui.Parent = game:GetService("CoreGui")
    end)
    
    if promptGui.Parent == nil then
        promptGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Configurar botão de enviar informações
sendInfoBtn.MouseButton1Click:Connect(function()
    if not _G.webhookEnabled then
        statusLabel.Text = "Status: ⚠️ Webhook desativado"
        task.wait(1)
        statusLabel.Text = "Status: ✅ ATIVADO"
        return
    end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        statusLabel.Text = "Status: ⚠️ Configure Webhook"
        task.wait(1)
        statusLabel.Text = "Status: ✅ ATIVADO"
        return
    end

    local uptime = "0"
    pcall(function() uptime = tostring(math.floor(tick() - (scriptStartTime or tick()))) end)
    local description = string.format("📢 **Relatório do Jogo**\n👤 Jogador: %s\n🏷️ PlaceId: %s\n⏱ Uptime(s): %s\n🖥 FPS: %s\nStatus: %s",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        uptime,
        tostring(fps or 0),
        _G.scriptEnabled and "✅ Ativado" or "⛔ Desativado")

    sendWebhook("📨 Relatório Manual", description, 16751616)
end)

-- Configurar modo compacto
local compactMode = false
compactBtn.MouseButton1Click:Connect(function()
    compactMode = not compactMode
    compactBtn.Text = "Modo Compacto: " .. (compactMode and "ON" or "OFF")
    fpsLabel.Visible = not compactMode
    statusLabel.Visible = not compactMode
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

-- Pré-carregamento de eventos
local clickEvents = {}
local upgradeEvents = {}
local specialEvents = {}
local dungeonEvents = {}

local function preloadEvents()
    local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
    
    local function verifyEvent(parent, name)
        local event = parent:WaitForChild(name, 5)
        if not event then warn("❌ Falha ao carregar: " .. name) end
        return event
    end
    
    local DungeonAttack = verifyEvent(Events, "DungeonAttack")
    
    dungeonEvents = {
        attack = DungeonAttack,
        changeEnemy = verifyEvent(DungeonAttack, "ChangeEnemy"),
        rebirth = verifyEvent(DungeonAttack, "DungeonRebirth"),
        upgrades = {
            verifyEvent(DungeonAttack, "DungeonUpgrade"),
            verifyEvent(DungeonAttack, "DungeonUpgrade2")
        }
    }

    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    upgradeEvents = {
        {Events:WaitForChild("Upgrade"):WaitForChild("TranscendUpgrade"), 30},
        {Events:WaitForChild("Upgrade"):WaitForChild("TimeUpgrade"), 10},
        {Events:WaitForChild("Upgrade"):WaitForChild("ExtraUpgrade"), 35},
        {Events:WaitForChild("Upgrade"):WaitForChild("AtomUpgrade2"), 15},
        {Events:WaitForChild("Upgrade"):WaitForChild("MiningUpgrade"), 35},
        {Events:WaitForChild("Upgrade"):WaitForChild("MiningUpgrade2"), 20},
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 30},
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade2"), 25},
        {Events:WaitForChild("Upgrade"):WaitForChild("JewelUpgrade"), 25},
        {Events:WaitForChild("Upgrade"):WaitForChild("ExtraUpgrade3"), 40},
        {Events:WaitForChild("Upgrade"):WaitForChild("ConcreteUpgrade"), 30},
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    specialEvents = {
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    print("✓ Eventos carregados - MODO ULTRA ATIVO!")
    statusLabel.Text = "Status: ✅ ATIVADO"
end

spawn(preloadEvents)

-- ⚡ SISTEMA DE AUTO-CLICKERS (SEMPRE ATIVO)
spawn(function()
    while true do
        if _G.scriptEnabled and #clickEvents > 0 then
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

-- ⚡ SISTEMA DE UPGRADES (SEMPRE ATIVO)
spawn(function()
    while task.wait(0.03) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    for id = 1, maxId do
                        task.spawn(function()
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end)
                    end
                end
            end
            
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                
                if event then
                    for id = 1, maxId do
                        task.spawn(function()
                            pcall(function()
                                event:FireServer(id, arg)
                            end)
                        end)
                    end
                end
            end
        end
    end
end)

-- ⚡ DUNGEON ATTACK (SEMPRE SPAMANDO - NÃO PARA NUNCA)
spawn(function()
    while true do  -- Loop infinito sem verificação de _G.scriptEnabled
        pcall(function()
            local DungeonAttack = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DungeonAttack")
            local ChangeEnemy = DungeonAttack:WaitForChild("ChangeEnemy")
            
            for i = 1, _G.floodIntensity do
                pcall(function()
                    DungeonAttack:FireServer()
                    local args = {[1] = 1}
                    ChangeEnemy:FireServer(unpack(args))
                end)
            end
        end)
        task.wait(_G.floodDelay)
    end
end)

-- ⚡ DUNGEON REBIRTH (SEMPRE SPAMANDO - NÃO PARA NUNCA)
spawn(function()
    while true do  -- Loop infinito sem verificação
        pcall(function()
            if dungeonEvents.rebirth then
                for i = 1, 5 do
                    dungeonEvents.rebirth:FireServer()
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- ⚡ DUNGEON UPGRADES (SEMPRE SPAMANDO - NÃO PARA NUNCA)
spawn(function()
    while true do  -- Loop infinito sem verificação
        pcall(function()
            if #dungeonEvents.upgrades > 0 then
                task.spawn(function()
                    for _, upgrade in ipairs(dungeonEvents.upgrades) do
                        for id = 1, _G.floodIntensity do
                            pcall(function()
                                upgrade:FireServer()
                            end)
                        end
                    end
                end)
            end
        end)
        task.wait(0.05)
    end
end)

-- ⚡ CONCRETE PRESTIGE (SEMPRE ATIVO)
spawn(function()
    while task.wait(0.05) do
        if _G.scriptEnabled then
            pcall(function()
                local concreteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
                if concreteEvent then
                    for i = 1, 10 do
                        concreteEvent:FireServer()
                    end
                end
            end)
        end
    end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        _G.scriptEnabled = not _G.scriptEnabled
        if _G.scriptEnabled then
            toggleBtn.Text = "🔴 DESATIVAR SCRIPT"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            statusLabel.Text = "Status: ✅ ATIVADO"
        else
            toggleBtn.Text = "✅ ATIVAR SCRIPT"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            statusLabel.Text = "Status: ⛔ DESATIVADO"
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 20
        _G.floodDelay = 0.016
        
        statusLabel.Text = "Status: 🚀 TURBO ATIVADO"
        
        task.wait(5)
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
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
            statusLabel.Text = string.format("Status: ✅ ATIVO (%02d:%02d)", minutes, seconds)
        end
    end
end)

print("✓ ✅ Script Codex Ultra V2.4 Inicializado - JÁ ATIVADO!")
print("✓ 🟣 GUI Redesenhada com Roxo Translúcido")
print("✓ ⚡ Dungeon SEMPRE SPAMANDO (não para nunca)")
print("✓ 🎮 Pressione N para ocultar | M para desativar | B para turbo")
