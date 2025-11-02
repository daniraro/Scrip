-- ✅ SCRIPT PARA CODEX - V4.0 FINAL
-- 🟣 EXATAMENTE IGUAL AO CÓDIGO QUE FUNCIONAVA + GUI MELHORADA

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ===== WEBHOOK FUNCTION - EXATAMENTE COMO FUNCIONAVA =====
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

-- GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"
gui.ResetOnSpawn = false
pcall(function() if syn then syn.protect_gui(gui) end gui.Parent = game:GetService("CoreGui") end)
if gui.Parent == nil then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

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

if not scriptStartTime then scriptStartTime = tick() end

local sendInfoBtn = Instance.new("TextButton")
sendInfoBtn.Size = UDim2.new(0.9, 0, 0, 20)
sendInfoBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
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

webhookBtn.MouseButton1Click:Connect(function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(100, 100, 100)
end)

urlBtn.MouseButton1Click:Connect(function()
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
    
    local function closePrompt()
        promptGui:Destroy()
    end
    
    saveBtn.MouseButton1Click:Connect(function()
        local newUrl = urlInput.Text
        if newUrl and newUrl:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = newUrl
            closePrompt()
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            urlInput.PlaceholderText = "URL inválida! Deve ser um webhook do Discord"
            task.wait(2)
            urlInput.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            urlInput.PlaceholderText = "Cole a URL do webhook aqui"
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

-- Pré-carregamento de eventos
local clickEvents = {}
local upgradeEvents = {}
local specialEvents = {}
local dungeonEvents = {}
local concreteEvent = nil

local function preloadEvents()
    local Events = ReplicatedStorage:WaitForChild("Events")
    
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
    
    dungeonEvents = {
        attack = Events:WaitForChild("DungeonAttack"),
        changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
        rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
        upgrades = {
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
            Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2")
        }
    }
    
    concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")
    
    print("✓ Eventos pré-carregados com sucesso!")
    statusLabel.Text = "Status: Eventos carregados"
end

spawn(preloadEvents)

-- Auto-clickers
spawn(function()
    while true do
        if _G.scriptEnabled and #clickEvents > 0 then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, (_G.floodIntensity or 5) do
                        pcall(function() event:FireServer() end)
                    end
                end
            end
        end
        wait(_G.floodDelay or 0.05)
    end
end)

-- Upgrades
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                if event then
                    for id = 1, maxId do
                        spawn(function() pcall(function() event:FireServer(id) end) end)
                    end
                end
            end
            for _, special in pairs(specialEvents) do
                local event = special[1]
                local maxId = special[2]
                local arg = special[3]
                if event then
                    for id = 1, maxId do
                        spawn(function() pcall(function() event:FireServer(id, arg) end) end)
                    end
                end
            end
        end
    end
end)

-- Dungeon Attack
spawn(function()
    while wait(_G.floodDelay or 0.05) do
        if _G.scriptEnabled and dungeonEvents.attack then
            for i = 1, (_G.floodIntensity or 5) do
                pcall(function() dungeonEvents.attack:FireServer() end)
                pcall(function() dungeonEvents.changeEnemy:FireServer(1) end)
            end
        end
    end
end)

-- Dungeon Rebirth
spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function() dungeonEvents.rebirth:FireServer() end)
            end
        end
    end
end)

-- Dungeon Upgrades
spawn(function()
    while wait(0.01) do
        if _G.scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                for id = 1, 10 do
                    spawn(function() pcall(function() upgrade:FireServer(id) end) end)
                end
            end
        end
    end
end)

-- Concrete Prestige
spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function() concreteEvent:FireServer() end)
            end
        end
    end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        _G.scriptEnabled = not _G.scriptEnabled
        toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        local oldIntensity = _G.floodIntensity
        local oldDelay = _G.floodDelay
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        statusLabel.Text = "Status: BOOST ATIVADO"
        wait(5)
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
        if _G.scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

print("✓ Script Codex Ultra Otimizado Inicializado!")
print("✓ Webhook com normalizeResponse + múltiplos métodos HTTP")
print("✓ N=Ocultar | M=Ativar | B=Boost")
