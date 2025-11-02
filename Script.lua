-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO ULTRA OTIMIZADA V2.2 (PERFORMANCE ENHANCED)

-- Configuração de delays padrão (ajustáveis) - valores otimizados 2024
if _G.autoClickDelay == nil then _G.autoClickDelay = 0.25 end     -- 250ms entre clicks (reduz carga)
if _G.upgradeDelay == nil then _G.upgradeDelay = 2.0 end          -- 2000ms entre upgrades (evita spam)
if _G.dungeonDelay == nil then _G.dungeonDelay = 0.5 end          -- 500ms entre ações dungeon
if _G.uiUpdateDelay == nil then _G.uiUpdateDelay = 1.0 end        -- 1000ms entre updates de UI
if _G.webhookInterval == nil then _G.webhookInterval = 120 end     -- 120s entre webhooks
if _G.floodIntensity == nil then _G.floodIntensity = 3 end        -- Reduzido para 3 eventos por ciclo
if _G.floodDelay == nil then _G.floodDelay = 0.25 end             -- 250ms entre floods

-- Configurações locais de throttling
local throttleConfig = {
    clickTickRate = 0.05,    -- Taxa base de verificação (50ms)
    upgradeTickRate = 0.1,   -- Taxa base de upgrades (100ms)
    dungeonTickRate = 0.25,  -- Taxa base de dungeon (250ms)
    lastClickTime = 0,       -- Último click processado
    lastUpgradeTime = 0,     -- Último upgrade processado
    lastDungeonTime = 0      -- Última ação dungeon
}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Criar ScreenGui root
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"
gui.ResetOnSpawn = false

-- Tentar parent seguro
pcall(function()
    if syn then syn.protect_gui(gui) end
    gui.Parent = game:GetService("CoreGui")
end)

if gui.Parent == nil then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Tracking de performance e UI
local lastUIUpdate = 0
local lastFPSUpdate = 0
local startTime = tick()

-- Enhanced sendWebhook: tenta múltiplos backends HTTP (executor-specific) antes de enfileirar
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return false end

    if not _G.webhookUrl or _G.webhookUrl == "" or _G.webhookUrl == "COLOQUE_URL_DO_WEBHOOK_AQUI" then
        if statusLabel then statusLabel.Text = "Configure o Webhook!" end
        return false
    end

    local embed = {
        title = title,
        description = description,
        color = color,
        footer = { text = "Codex Ultra Script v2.1" },
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

    -- syn.request (Synapse)
    if not response and syn and syn.request then
        response = tryRequestCall(function()
            return syn.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    -- http.request (some executors)
    if not response and http and http.request then
        response = tryRequestCall(function()
            return http.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    -- http_request (fluxus / old)
    if not response and http_request then
        response = tryRequestCall(function()
            return http_request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    -- request (KRNL etc)
    if not response and request then
        response = tryRequestCall(function()
            return request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end

    -- Roblox HttpService last
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
        -- fallback: enfileirar usando writefile (executor) se disponível
        pcall(function()
            if writefile and readfile and isfile then
                local queueFile = "CodexWebhookQueue.json"
                local existing = "[]"
                if isfile(queueFile) then existing = readfile(queueFile) end
                local okDecode, list = pcall(function() return HttpService:JSONDecode(existing) end)
                if not okDecode or type(list) ~= "table" then list = {} end
                table.insert(list, { title = title, description = description, color = color, ts = DateTime.now():ToIsoDate(), err = (response and response.StatusCode) or "no-method" })
                writefile(queueFile, HttpService:JSONEncode(list))
                if statusLabel then statusLabel.Text = "Webhook enfileirado" end
                task.wait(1)
                if statusLabel then statusLabel.Text = "Status: Executando" end
            else
                warn("Falha ao enviar webhook e sem writefile disponível para enfileirar.")
                if statusLabel then statusLabel.Text = "Erro no Webhook!" end
                task.wait(1)
                if statusLabel then statusLabel.Text = "Status: Executando" end
            end
        end)
        return false
    end

    if statusLabel then statusLabel.Text = "Webhook enviado" end
    task.wait(1)
    if statusLabel then statusLabel.Text = "Status: Executando" end
    return true
end

-- Janela principal com design melhorado
-- Criar ScreenGui antes do frame
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"

pcall(function()
    if syn then syn.protect_gui(gui) end
    gui.Parent = game:GetService("CoreGui")
end)

if gui.Parent == nil then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Visual improvements: rounded corners, subtle stroke and gradient
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(60, 60, 80)
frameStroke.Transparency = 0.7
frameStroke.Thickness = 1
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28,30,42)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,22,32))
}
frameGradient.Rotation = 90
frameGradient.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Text = "CODEX ULTRA"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
    title.Parent = frame

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 28, 0, 25)
titleIcon.Position = UDim2.new(0.03, 0, 0, 0)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "⚡"
titleIcon.Font = Enum.Font.SourceSansBold
titleIcon.TextSize = 16
titleIcon.TextColor3 = Color3.fromRGB(120, 200, 255)
titleIcon.Parent = frame

-- Botão de toggle principal
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
toggleBtn.Text = "ATIVADO"
toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 160, 120)
toggleBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(50, 50, 70)
toggleStroke.Transparency = 0.6
toggleStroke.Parent = toggleBtn

-- Indicador de status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.Text = "Status: Executando"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- Indicador de FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.9, 0, 0, 20)
fpsLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextSize = 12
fpsLabel.Text = "FPS: --"
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = frame

-- Webhook toggle button
local webhookBtn = Instance.new("TextButton")
webhookBtn.Size = UDim2.new(0.45, 0, 0, 20)
webhookBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
webhookBtn.Text = "WEBHOOK: ON"
webhookBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 170)
webhookBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
webhookBtn.Font = Enum.Font.SourceSans
webhookBtn.TextSize = 12
webhookBtn.AutoButtonColor = true
webhookBtn.Parent = frame

local webhookCorner = Instance.new("UICorner")
webhookCorner.CornerRadius = UDim.new(0, 6)
webhookCorner.Parent = webhookBtn

-- Webhook URL input button
local urlBtn = Instance.new("TextButton")
urlBtn.Size = UDim2.new(0.45, 0, 0, 20)
urlBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
urlBtn.Text = "DEFINIR URL"
urlBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
urlBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
urlBtn.Font = Enum.Font.SourceSans
urlBtn.TextSize = 12
urlBtn.AutoButtonColor = true
urlBtn.Parent = frame

local urlCorner = Instance.new("UICorner")
urlCorner.CornerRadius = UDim.new(0, 6)
urlCorner.Parent = urlBtn

-- Registrar início do script para uptime (se ainda não houver)
if not scriptStartTime then scriptStartTime = tick() end

-- Botão para enviar manualmente informações do jogo via webhook
local sendInfoBtn = Instance.new("TextButton")
sendInfoBtn.Size = UDim2.new(0.45, 0, 0, 20)
sendInfoBtn.Position = UDim2.new(0.5, 0, 0.78, 0)
sendInfoBtn.Text = "ENVIAR INFORMAÇÕES"
sendInfoBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 110)
sendInfoBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
sendInfoBtn.Font = Enum.Font.SourceSansBold
sendInfoBtn.TextSize = 12
sendInfoBtn.AutoButtonColor = true
sendInfoBtn.Parent = frame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 6)
sendCorner.Parent = sendInfoBtn

sendInfoBtn.MouseButton1Click:Connect(function()
    if not _G.webhookEnabled then
        if statusLabel then statusLabel.Text = "Webhook desativado" end
        return
    end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        if statusLabel then statusLabel.Text = "Configure o Webhook!" end
        return
    end

    local uptime = "0"
    pcall(function() uptime = tostring(math.floor(tick() - (scriptStartTime or tick()))) end)
    local description = string.format("📢 **Relatório do Jogo**\n👤 Jogador: %s\n🏷️ PlaceId: %s\n⏱ Uptime(s): %s\n🖥 FPS: %s\nStatus: %s",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        uptime,
        tostring(fps or 0),
        _G.scriptEnabled and "Executando" or "Pausado")

    sendWebhook("📨 Relatório Manual", description, 16751616)
end)

-- Botão para alternar modo compacto (esconder informações extras para UI mais leve)
local compactBtn = Instance.new("TextButton")
compactBtn.Size = UDim2.new(0.9, 0, 0, 18)
compactBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
compactBtn.Text = "Modo Compacto: OFF"
compactBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
compactBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
compactBtn.Font = Enum.Font.SourceSans
compactBtn.TextSize = 11
compactBtn.AutoButtonColor = true
compactBtn.Parent = frame

local compactCorner = Instance.new("UICorner")
compactCorner.CornerRadius = UDim.new(0, 6)
compactCorner.Parent = compactBtn

local compactMode = false
local function setCompactMode(on)
    compactMode = on
    compactBtn.Text = "Modo Compacto: " .. (on and "ON" or "OFF")
    if fpsLabel then fpsLabel.Visible = not on end
    if statusLabel then statusLabel.Visible = not on end
    if sendInfoBtn then sendInfoBtn.Visible = not on end
    -- mantemos botões essenciais visíveis (toggleBtn, webhookBtn, urlBtn)
end

compactBtn.MouseButton1Click:Connect(function()
    setCompactMode(not compactMode)
end)

webhookBtn.MouseButton1Click:Connect(function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(100, 100, 100)
end)

-- Prompt para configurar a URL do webhook
urlBtn.MouseButton1Click:Connect(function()
    -- Criar um prompt para o usuário inserir a URL
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "WebhookPrompt"
    
    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 300, 0, 150)
    promptFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    promptFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    promptFrame.BorderSizePixel = 0
    promptFrame.Parent = promptGui
    
    local promptTitle = Instance.new("TextLabel")
    promptTitle.Size = UDim2.new(1, 0, 0, 30)
    promptTitle.Position = UDim2.new(0, 0, 0, 0)
    promptTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    promptTitle.TextColor3 = Color3.new(1, 1, 1)
    promptTitle.Font = Enum.Font.SourceSansBold
    promptTitle.TextSize = 16
    promptTitle.Text = "Configurar URL do Webhook"
    promptTitle.Parent = promptFrame
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(0.9, 0, 0, 30)
    urlInput.Position = UDim2.new(0.05, 0, 0.3, 0)
    urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    urlInput.TextColor3 = Color3.new(1, 1, 1)
    urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    urlInput.Text = _G.webhookUrl ~= "COLOQUE_URL_DO_WEBHOOK_AQUI" and _G.webhookUrl or ""
    urlInput.Font = Enum.Font.SourceSans
    urlInput.TextSize = 14
    urlInput.ClearTextOnFocus = false
    urlInput.Parent = promptFrame
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 30)
    saveBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.TextSize = 16
    saveBtn.Text = "SALVAR"
    saveBtn.Parent = promptFrame
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.45, 0, 0, 30)
    cancelBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.TextSize = 16
    cancelBtn.Text = "CANCELAR"
    cancelBtn.Parent = promptFrame
    
    -- Função para fechar o prompt
    local function closePrompt()
        promptGui:Destroy()
    end
    
    -- Botão salvar
    saveBtn.MouseButton1Click:Connect(function()
        local newUrl = urlInput.Text
        if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = newUrl
            saveWebhookSettings(newUrl)
            closePrompt()
            -- Testar webhook após salvar
            testWebhook()
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
            task.wait(2)
            urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            urlInput.PlaceholderText = "Cole a URL do webhook aqui"
        end
    end)
    
    -- Botão cancelar
    cancelBtn.MouseButton1Click:Connect(closePrompt)
    
    pcall(function()
        if syn then syn.protect_gui(promptGui) end
        promptGui.Parent = game:GetService("CoreGui")
    end)
    
    if promptGui.Parent == nil then
        promptGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
end)

-- Pré-carregamento de todos os eventos para melhor desempenho
local function preloadEvents()
    -- Eventos de clique
    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    -- Eventos de upgrade
    upgradeEvents = {
        -- Upgrades principais (evento, maxId, argumentos extras)
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
        
        -- Outros Upgrades
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    -- Eventos especiais
    specialEvents = {
        -- {evento, maxId, arg1, arg2}
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    -- Eventos de Dungeon
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
        }
    }
    
    -- Concrete Event
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

-- Inicializar eventos
spawn(preloadEvents)

-- Sistema de auto-clickers otimizado usando RenderStepped para performance máxima
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
        wait(_G.floodDelay)
    end
end)

-- Sistema de upgrades paralelos (todos são executados simultaneamente)
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    -- Upgrades em paralelo (não espera entre eles)
                    for id = 1, maxId do
                        spawn(function()
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end)
                    end
                end
            end
            
            -- Upgrades especiais também em paralelo
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
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

-- Concrete Prestige otimizado
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do -- Múltiplas tentativas
                pcall(function()
                    concreteEvent:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON ATTACK otimizado (ultra-rápido)
spawn(function()
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            -- Ataques em massa
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- DUNGEON REBIRTH otimizado
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do -- Múltiplas tentativas para garantir
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON UPGRADES otimizado
spawn(function()
    while wait(0.01) do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                -- Em paralelo para máxima eficiência
                for id = 1, 10 do -- Aumentado para 10 para garantir todos os upgrades
                    spawn(function()
                        pcall(function()
                            upgrade:FireServer(id)
                        end)
                    end)
                end
            end
        end
    end
end)

-- Keybind aprimorado
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5) -- 5 segundos de boost
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        statusLabel.Text = "Status: Executando"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while wait(10) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        -- Atualizar status
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Função para enviar mensagens para o Webhook (versão corrigida)
local function sendWebhook(title, description, color)
    -- Não enviar se desativado
    if not _G.webhookEnabled then return false end

    -- Validar URL
    if not _G.webhookUrl or _G.webhookUrl == "" or _G.webhookUrl == "COLOQUE_URL_DO_WEBHOOK_AQUI" then
        if statusLabel then statusLabel.Text = "Configure o Webhook!" end
        return false
    end

    local embed = {
        title = title,
        description = description,
        color = color,
        footer = { text = "Codex Ultra Script v2.1" },
        timestamp = DateTime.now():ToIsoDate()
    }

    local payload = { content = "", embeds = { embed } }
    local body = HttpService:JSONEncode(payload)

    local ok, result = pcall(function()
        -- Prefer RequestAsync when disponível, fallback em PostAsync
        if HttpService.RequestAsync then
            return HttpService:RequestAsync({
                Url = _G.webhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        else
            -- PostAsync retorna string/body; simular uma resposta
            local resBody = HttpService:PostAsync(_G.webhookUrl, body, Enum.HttpContentType.ApplicationJson)
            return { StatusCode = 200, Body = resBody }
        end
    end)

    if not ok then
        warn("Erro ao enviar webhook:", result)
        if statusLabel then statusLabel.Text = "Erro no Webhook!" end
        task.wait(1)
        if statusLabel then statusLabel.Text = "Status: Executando" end
        -- Se existir API de arquivos no executor, enfileirar o payload para envio externo
        pcall(function()
            if writefile and readfile and isfile then
                local queueFile = "CodexWebhookQueue.json"
                local existing = "[]"
                if isfile(queueFile) then
                    existing = readfile(queueFile)
                end
                local okDecode, list = pcall(function() return HttpService:JSONDecode(existing) end)
                if not okDecode or type(list) ~= "table" then list = {} end
                table.insert(list, { title = title, description = description, color = color, ts = DateTime.now():ToIsoDate() })
                writefile(queueFile, HttpService:JSONEncode(list))
                if statusLabel then statusLabel.Text = "Webhook enfileirado" end
                task.wait(1)
                if statusLabel then statusLabel.Text = "Status: Executando" end
            end
        end)
        return false
    end

    local statusCode = (type(result) == "table" and result.StatusCode) or 200
    if statusCode == 204 or statusCode == 200 then
        if statusLabel then statusLabel.Text = "Webhook enviado" end
        task.wait(1)
        if statusLabel then statusLabel.Text = "Status: Executando" end
        return true
    else
        warn("Webhook responded with status:", statusCode)
        if statusLabel then statusLabel.Text = "Erro no Webhook!" end
        task.wait(1)
        if statusLabel then statusLabel.Text = "Status: Executando" end
        -- Enfileira também se houver suporte a arquivos
        pcall(function()
            if writefile and readfile and isfile then
                local queueFile = "CodexWebhookQueue.json"
                local existing = "[]"
                if isfile(queueFile) then
                    existing = readfile(queueFile)
                end
                local okDecode, list = pcall(function() return HttpService:JSONDecode(existing) end)
                if not okDecode or type(list) ~= "table" then list = {} end
                table.insert(list, { title = title, description = description, color = color, ts = DateTime.now():ToIsoDate(), statusCode = statusCode })
                writefile(queueFile, HttpService:JSONEncode(list))
                if statusLabel then statusLabel.Text = "Webhook enfileirado" end
                task.wait(1)
                if statusLabel then statusLabel.Text = "Status: Executando" end
            end
        end)
        return false
    end
end

-- Heartbeat: envia periodicamente um resumo simples quando o webhook estiver ativo
-- Auto-send: envia periodicamente um relatório completo quando o webhook estiver ativo
if _G.webhookAutoInfo == nil then _G.webhookAutoInfo = true end
spawn(function()
    while true do
        local interval = tonumber(_G.webhookInterval) or 30
        wait(interval)
        if _G.webhookAutoInfo and _G.webhookEnabled and _G.webhookUrl and type(_G.webhookUrl) == "string" and _G.webhookUrl:match("^https://discord.com/api/webhooks/") then
            local uptime = "0"
            pcall(function() uptime = tostring(math.floor(tick() - (scriptStartTime or tick()))) end)
            local ok, err = pcall(function()
                local description = string.format("📡 **Atualização Automática**\n👤 Jogador: %s\n🏷️ PlaceId: %s\n⏱ Uptime(s): %s\n🖥 FPS: %s\nStatus: %s",
                    Players.LocalPlayer and Players.LocalPlayer.Name or "-",
                    tostring(game.PlaceId),
                    uptime,
                    tostring(fps or 0),
                    _G.scriptEnabled and "Executando" or "Pausado")

                sendWebhook("📡 Codex Status (Auto)", description, 3066993)
            end)
            -- não bloquear se falhar
        end
    end
end)

-- Função para testar o webhook
local function testWebhook()
    local description = string.format("📊 Teste de Webhook\n🎮 Jogo: %s\n👤 Jogador: %s\n⚡ Status: Conectado\n\nEste é um teste de conexão do webhook.", tostring(game.PlaceId), tostring(Players.LocalPlayer.Name))
    sendWebhook("🔵 Conexão Estabelecida", description, 3447003)
end

-- Modificar o evento de salvar URL do webhook
saveBtn.MouseButton1Click:Connect(function()
    local newUrl = urlInput.Text
    if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
        _G.webhookUrl = newUrl
        saveWebhookSettings(newUrl)
        closePrompt()
        -- Testar webhook após salvar
        testWebhook()
    else
        urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
        task.wait(2)
        urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    end
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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
end)

-- Pré-carregamento de todos os eventos para melhor desempenho
local function preloadEvents()
    -- Eventos de clique
    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    -- Eventos de upgrade
    upgradeEvents = {
        -- Upgrades principais (evento, maxId, argumentos extras)
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
        
        -- Outros Upgrades
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    -- Eventos especiais
    specialEvents = {
        -- {evento, maxId, arg1, arg2}
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    -- Eventos de Dungeon
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
        }
    }
    
    -- Concrete Event
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

-- Inicializar eventos
spawn(preloadEvents)

-- Sistema de auto-clickers otimizado usando RenderStepped para performance máxima
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
        wait(_G.floodDelay)
    end
end)

-- Sistema de upgrades paralelos (todos são executados simultaneamente)
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    -- Upgrades em paralelo (não espera entre eles)
                    for id = 1, maxId do
                        spawn(function()
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end)
                    end
                end
            end
            
            -- Upgrades especiais também em paralelo
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
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

-- Concrete Prestige otimizado
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do -- Múltiplas tentativas
                pcall(function()
                    concreteEvent:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON ATTACK otimizado (ultra-rápido)
spawn(function()
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            -- Ataques em massa
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- DUNGEON REBIRTH otimizado
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do -- Múltiplas tentativas para garantir
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON UPGRADES otimizado
spawn(function()
    while wait(0.01) do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                -- Em paralelo para máxima eficiência
                for id = 1, 10 do -- Aumentado para 10 para garantir todos os upgrades
                    spawn(function()
                        pcall(function()
                            upgrade:FireServer(id)
                        end)
                    end)
                end
            end
        end
    end
end)

-- Keybind aprimorado
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5) -- 5 segundos de boost
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        statusLabel.Text = "Status: Executando"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while wait(10) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        -- Atualizar status
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Função para enviar mensagens para o Webhook (versão corrigida)
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        statusLabel.Text = "Configure o Webhook!"
        return
    end

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Codex Ultra Script v2.1"
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = _G.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success or (response and response.StatusCode ~= 204) then
        warn("Erro no webhook:", response and response.StatusCode or "Falha na requisição")
        statusLabel.Text = "Erro no Webhook!"
        task.wait(1)
        statusLabel.Text = "Status: Executando"
    end
end

-- Função para testar o webhook
local function testWebhook()
    sendWebhook(
        "🔵 Conexão Estabelecida",
        string.format([[
📊 **Teste de Webhook**
🎮 **Jogo:** %s
👤 **Jogador:** %s
⚡ **Status:** Conectado

*Este é um teste de conexão do webhook.*]], 
        game.PlaceId,
        Players.LocalPlayer.Name),
        3447003
    )
end

-- Modificar o evento de salvar URL do webhook
saveBtn.MouseButton1Click:Connect(function()
    local newUrl = urlInput.Text
    if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
        _G.webhookUrl = newUrl
        saveWebhookSettings(newUrl)
        closePrompt()
        -- Testar webhook após salvar
        testWebhook()
    else
        urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
        task.wait(2)
        urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    end
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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
end)

-- Pré-carregamento de todos os eventos para melhor desempenho
local function preloadEvents()
    -- Eventos de clique
    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    -- Eventos de upgrade
    upgradeEvents = {
        -- Upgrades principais (evento, maxId, argumentos extras)
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
        
        -- Outros Upgrades
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    -- Eventos especiais
    specialEvents = {
        -- {evento, maxId, arg1, arg2}
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    -- Eventos de Dungeon
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
        }
    }
    
    -- Concrete Event
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

-- Inicializar eventos
spawn(preloadEvents)

-- Sistema de auto-clickers otimizado usando RenderStepped para performance máxima
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
        wait(_G.floodDelay)
    end
end)

-- Sistema de upgrades paralelos (todos são executados simultaneamente)
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    -- Upgrades em paralelo (não espera entre eles)
                    for id = 1, maxId do
                        spawn(function()
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end)
                    end
                end
            end
            
            -- Upgrades especiais também em paralelo
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
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

-- Concrete Prestige otimizado
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do -- Múltiplas tentativas
                pcall(function()
                    concreteEvent:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON ATTACK otimizado (ultra-rápido)
spawn(function()
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            -- Ataques em massa
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- DUNGEON REBIRTH otimizado
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do -- Múltiplas tentativas para garantir
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON UPGRADES otimizado
spawn(function()
    while wait(0.01) do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                -- Em paralelo para máxima eficiência
                for id = 1, 10 do -- Aumentado para 10 para garantir todos os upgrades
                    spawn(function()
                        pcall(function()
                            upgrade:FireServer(id)
                        end)
                    end)
                end
            end
        end
    end
end)

-- Keybind aprimorado
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5) -- 5 segundos de boost
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        statusLabel.Text = "Status: Executando"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while wait(10) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        -- Atualizar status
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Função para enviar mensagens para o Webhook (versão corrigida)
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        statusLabel.Text = "Configure o Webhook!"
        return
    end

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Codex Ultra Script v2.1"
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = _G.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success or (response and response.StatusCode ~= 204) then
        warn("Erro no webhook:", response and response.StatusCode or "Falha na requisição")
        statusLabel.Text = "Erro no Webhook!"
        task.wait(1)
        statusLabel.Text = "Status: Executando"
    end
end

-- Função para testar o webhook
local function testWebhook()
    sendWebhook(
        "🔵 Conexão Estabelecida",
        string.format([[
📊 **Teste de Webhook**
🎮 **Jogo:** %s
👤 **Jogador:** %s
⚡ **Status:** Conectado

*Este é um teste de conexão do webhook.*]], 
        game.PlaceId,
        Players.LocalPlayer.Name),
        3447003
    )
end

-- Modificar o evento de salvar URL do webhook
saveBtn.MouseButton1Click:Connect(function()
    local newUrl = urlInput.Text
    if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
        _G.webhookUrl = newUrl
        saveWebhookSettings(newUrl)
        closePrompt()
        -- Testar webhook após salvar
        testWebhook()
    else
        urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
        task.wait(2)
        urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    end
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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
end)

-- Pré-carregamento de todos os eventos para melhor desempenho
local function preloadEvents()
    -- Eventos de clique
    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    -- Eventos de upgrade
    upgradeEvents = {
        -- Upgrades principais (evento, maxId, argumentos extras)
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
        
        -- Outros Upgrades
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    -- Eventos especiais
    specialEvents = {
        -- {evento, maxId, arg1, arg2}
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    -- Eventos de Dungeon
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
        }
    }
    
    -- Concrete Event
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

-- Inicializar eventos
spawn(preloadEvents)

-- Sistema de auto-clickers otimizado usando RenderStepped para performance máxima
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
        wait(_G.floodDelay)
    end
end)

-- Sistema de upgrades paralelos (todos são executados simultaneamente)
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    -- Upgrades em paralelo (não espera entre eles)
                    for id = 1, maxId do
                        spawn(function()
                            pcall(function()
                                event:FireServer(id)
                            end)
                        end)
                    end
                end
            end
            
            -- Upgrades especiais também em paralelo
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
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

-- Concrete Prestige otimizado
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do -- Múltiplas tentativas
                pcall(function()
                    concreteEvent:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON ATTACK otimizado (ultra-rápido)
spawn(function()
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            -- Ataques em massa
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- DUNGEON REBIRTH otimizado
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do -- Múltiplas tentativas para garantir
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON UPGRADES otimizado
spawn(function()
    while wait(0.01) do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                -- Em paralelo para máxima eficiência
                for id = 1, 10 do -- Aumentado para 10 para garantir todos os upgrades
                    spawn(function()
                        pcall(function()
                            upgrade:FireServer(id)
                        end)
                    end)
                end
            end
        end
    end
end)

-- Keybind aprimorado
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5) -- 5 segundos de boost
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        statusLabel.Text = "Status: Executando"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while wait(10) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        -- Atualizar status
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Função para enviar mensagens para o Webhook (versão corrigida)
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        statusLabel.Text = "Configure o Webhook!"
        return
    end

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Codex Ultra Script v2.1"
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = _G.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success or (response and response.StatusCode ~= 204) then
        warn("Erro no webhook:", response and response.StatusCode or "Falha na requisição")
        statusLabel.Text = "Erro no Webhook!"
        task.wait(1)
        statusLabel.Text = "Status: Executando"
    end
end

-- Função para testar o webhook
local function testWebhook()
    sendWebhook(
        "🔵 Conexão Estabelecida",
        string.format([[
📊 **Teste de Webhook**
🎮 **Jogo:** %s
👤 **Jogador:** %s
⚡ **Status:** Conectado

*Este é um teste de conexão do webhook.*]], 
        game.PlaceId,
        Players.LocalPlayer.Name),
        3447003
    )
end

-- Modificar o evento de salvar URL do webhook
saveBtn.MouseButton1Click:Connect(function()
    local newUrl = urlInput.Text
    if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
        _G.webhookUrl = newUrl
        saveWebhookSettings(newUrl)
        closePrompt()
        -- Testar webhook após salvar
        testWebhook()
    else
        urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
        task.wait(2)
        urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    end
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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
end)

-- Pré-carregamento de todos os eventos para melhor desempenho
local function preloadEvents()
    -- Eventos de clique
    clickEvents = {
        Events:WaitForChild("ClickMoney"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
        Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
        Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
    }
    
    -- Eventos de upgrade
    upgradeEvents = {
        -- Upgrades principais (evento, maxId, argumentos extras)
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
        
        -- Outros Upgrades
        {Events:WaitForChild("BuyRune"):WaitForChild("EquipRune"), 10},
        {Events:WaitForChild("Prestige"):WaitForChild("PrestigeUpgrade"), 30},
        {Events:WaitForChild("Prestige"):WaitForChild("ResearchUpgrade"), 80}
    }
    
    -- Eventos especiais
    specialEvents = {
        -- {evento, maxId, arg1, arg2}
        {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
        {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
    }
    
    -- Eventos de Dungeon
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
        }
    }
    
    -- Concrete Event
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

-- Inicializar eventos
spawn(preloadEvents)

-- Sistema de auto-clickers otimizado usando RenderStepped para performance máxima
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
        wait(_G.floodDelay)
    end
end)

-- Sistema de upgrades paralelos (todos são executados simultaneamente)
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
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
                        spawn(function()
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

-- Concrete Prestige otimizado
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function()
                    concreteEvent:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON ATTACK otimizado (ultra-rápido)
spawn(function()
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            for i = 1, _G.floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- DUNGEON REBIRTH otimizado
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- DUNGEON UPGRADES otimizado com throttling
local lastDungeonUpgradeTime = 0
spawn(function()
    while true do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            local now = tick()
            if now - lastDungeonUpgradeTime >= (_G.dungeonDelay or 0.25) then
                lastDungeonUpgradeTime = now
                -- Batch dungeon upgrades em uma única thread
                task.spawn(function()
                    for _, upgrade in ipairs(dungeonEvents.upgrades) do
                        for id = 1, (_G.floodIntensity / 2) do -- Reduzido para evitar spam
                            pcall(function()
                                upgrade:FireServer(id)
                            end)
                        end
                    end
                end)
            end
        end
        task.wait(0.1) -- Tick rate base de 100ms
    end
end)

-- Keybind aprimorado
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5) -- 5 segundos de boost
        
        _G.floodIntensity = oldIntensity
        _G.floodDelay = oldDelay
        statusLabel.Text = "Status: Executando"
    end
end)

-- Performance monitor
spawn(function()
    local startTime = tick()
    while wait(10) do
        local runtime = math.floor(tick() - startTime)
        local minutes = math.floor(runtime / 60)
        local seconds = runtime % 60
        
        -- Atualizar status
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Função para enviar mensagens para o Webhook (versão corrigida)
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled then return end
    if not _G.webhookUrl or _G.webhookUrl == "" then
        statusLabel.Text = "Configure o Webhook!"
        return
    end

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "Codex Ultra Script v2.1"
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = _G.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success or (response and response.StatusCode ~= 204) then
        warn("Erro no webhook:", response and response.StatusCode or "Falha na requisição")
        statusLabel.Text = "Erro no Webhook!"
        task.wait(1)
        statusLabel.Text = "Status: Executando"
    end
end

-- Função para testar o webhook
local function testWebhook()
    sendWebhook(
        "🔵 Conexão Estabelecida",
        string.format([[
📊 **Teste de Webhook**
🎮 **Jogo:** %s
👤 **Jogador:** %s
⚡ **Status:** Conectado

*Este é um teste de conexão do webhook.*]], 
        game.PlaceId,
        Players.LocalPlayer.Name),
        3447003
    )
end

-- Modificar o evento de salvar URL do webhook
saveBtn.MouseButton1Click:Connect(function()
    local newUrl = urlInput.Text
    if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
        _G.webhookUrl = newUrl
        saveWebhookSettings(newUrl)
        closePrompt()
        -- Testar webhook após salvar
        testWebhook()
    else
        urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
        task.wait(2)
        urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        urlInput.PlaceholderText = "Cole a URL do webhook aqui"
    end
end)

print("✓ Script Codex Ultra Otimizado com Webhook Inicializado!")
print("✓ Pressione N para ocultar a interface")
print("✓ Pressione M para ativar/desativar o script")
print("✓ Pressione B para um boost temporário")
print("✓ Webhook " .. (_G.webhookEnabled and "ativado" or "desativado") .. " - Envie relatórios para Discord")
