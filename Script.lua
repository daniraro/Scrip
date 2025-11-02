-- ✅ SCRIPT PARA CODEX
-- 🟣 VERSÃO ULTRA V4.1 COMPLETA

if _G.scriptEnabled == nil then _G.scriptEnabled = true end
if _G.webhookEnabled == nil then _G.webhookEnabled = true end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if not scriptStartTime then scriptStartTime = tick() end

-- ===== WEBHOOK FUNCTION - VERSÃO ORIGINAL COM CORREÇÃO =====
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
        footer = { text = "Codex Ultra Script v4.1" },
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
                warn("Falha ao enviar webhook")
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

-- GUI SETUP - ROXO TRANSLÚCIDO COM BOTÕES ARREDONDADOS
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

-- Título
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0, 50)
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

-- Container de botões
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -70)
buttonContainer.Position = UDim2.new(0, 10, 0, 60)
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
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = buttonContainer
    
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
        btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
    end
    
    return btn
end

local function createLabel(text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = text
    label.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    label.BackgroundTransparency = 0.3
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = label
    
    return label
end

local statusLabel = createLabel("Status: ✅ ATIVADO", 1)
local upgradesLabel = createLabel("Upgrades: ⚙️ Funcionando", 2)
local fpsLabel = createLabel("FPS: --", 3)
local webhookStatusLabel = createLabel("Webhook: ✅ Pronto", 4)

local toggleBtn = createButton("🔴 DESATIVAR SCRIPT", 5, Color3.fromRGB(0, 150, 100), function()
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

local turboBtn = createButton("🚀 TURBO (5s)", 6, Color3.fromRGB(255, 140, 0), function()
    local old = {_G.floodIntensity, _G.floodDelay}
    _G.floodIntensity = 20
    _G.floodDelay = 0.016
    turboBtn.Text = "🚀 TURBO: ON"
    statusLabel.Text = "Status: 🚀 TURBO ATIVO"
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
    webhookStatusLabel.Text = "Webhook: " .. (_G.webhookEnabled and "✅ Ativo" or "❌ Desativo")
end)

local urlBtn = createButton("⚙️ CONFIGURAR WEBHOOK", 8, Color3.fromRGB(80, 50, 130), function()
    local promptGui = Instance.new("ScreenGui")
    promptGui.ResetOnSpawn = false
    
    pcall(function()
        if syn then syn.protect_gui(promptGui) end
        promptGui.Parent = game:GetService("CoreGui")
    end)
    
    if promptGui.Parent == nil then
        promptGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local promptBg = Instance.new("Frame")
    promptBg.Size = UDim2.new(0.8, 0, 0.6, 0)
    promptBg.Position = UDim2.new(0.1, 0, 0.2, 0)
    promptBg.BackgroundColor3 = Color3.fromRGB(60, 30, 110)
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
    saveBtn.Position = UDim2.new(0.05, 0, 0, 105)
    saveBtn.Text = "✅ SALVAR"
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Parent = promptBg
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.3, 0, 0, 40)
    closeBtn.Position = UDim2.new(0.67, 0, 0, 105)
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
            webhookStatusLabel.Text = "Webhook: ✅ Configurado"
        else
            urlInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1)
            urlInput.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
    end)
end)

local sendInfoBtn = createButton("📨 ENVIAR INFO", 9, Color3.fromRGB(100, 60, 150), function()
    if not _G.webhookEnabled or not _G.webhookUrl then
        webhookStatusLabel.Text = "Webhook: ⚠️ Configure URL"
        return
    end

    local uptime = tostring(math.floor(tick() - (scriptStartTime or tick())))
    local minutes = math.floor(tonumber(uptime) / 60)
    local seconds = tonumber(uptime) % 60
    
    local description = string.format("📊 **Relatório**\n👤 %s\n🏷️ %s\n⏱️ %02d:%02d\n🖥️ %d FPS\n🎮 %s",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        minutes, seconds,
        tostring(fps or 0),
        _G.scriptEnabled and "✅ Ativado" or "⛔ Desativado")

    sendWebhook("📨 Relatório", description, 16751616)
end)

local compactBtn = createButton("Modo Compacto: OFF", 10, Color3.fromRGB(70, 40, 120), function()
    local isCompact = compactBtn.Text == "Modo Compacto: OFF"
    compactBtn.Text = "Modo Compacto: " .. (isCompact and "ON" or "OFF")
end)

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
    
    upgradesLabel.Text = "Upgrades: ⚙️ " .. #upgradeEvents .. " carregados"
end

spawn(preloadEvents)

spawn(function()
    while true do
        if _G.scriptEnabled and #clickEvents > 0 then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, _G.floodIntensity do
                        pcall(function() event:FireServer() end)
                    end
                end
            end
        end
        wait(_G.floodDelay)
    end
end)

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
        wait(_G.floodDelay)
    end
end)

spawn(function()
    while true do
        if dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function() dungeonEvents.rebirth:FireServer() end)
            end
        end
        wait(0.2)
    end
end)

spawn(function()
    while true do
        if #dungeonEvents.upgrades > 0 then
            for _, upgrade in ipairs(dungeonEvents.upgrades) do
                for id = 1, 10 do
                    spawn(function() pcall(function() upgrade:FireServer() end) end)
                end
            end
        end
        wait(0.01)
    end
end)

spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function() concreteEvent:FireServer() end)
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then
        turboBtn.MouseButton1Click:Fire()
    end
end)

print("✓ Script Codex Ultra Otimizado Inicializado!")
print("✓ N=Ocultar | M=Ativar | B=Boost")
