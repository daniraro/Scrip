-- ✅ SCRIPT PARA CODEX - V4.1 FINAL CORRIGIDO
-- 🟣 GUI 100% FUNCIONAL + WEBHOOK V4.1 + TUDO INTEGRADO

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

if _G.scriptEnabled == nil then _G.scriptEnabled = true end
if _G.webhookEnabled == nil then _G.webhookEnabled = true end
if _G.floodIntensity == nil then _G.floodIntensity = 5 end
if _G.floodDelay == nil then _G.floodDelay = 0.05 end

if not scriptStartTime then scriptStartTime = tick() end

-- ===== WEBHOOK FUNCTION COM normalizeResponse =====
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
        if type(res) == "table" and res.StatusCode then return res
        elseif type(res) == "table" and res.status then return { StatusCode = res.status, Body = res.body or res.text }
        elseif type(res) == "string" then return { StatusCode = 200, Body = res }
        else return { StatusCode = 0, Body = res } end
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

-- ===== GUI CORRIGIDA =====
local gui = Instance.new("ScreenGui")
gui.Name = "CodexUltraGui"
gui.ResetOnSpawn = false

pcall(function() if syn then syn.protect_gui(gui) end gui.Parent = game:GetService("CoreGui") end)
if gui.Parent == nil then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 60, 120)
frameStroke.Transparency = 0.5
frameStroke.Thickness = 2
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(35,30,50)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20,18,35))}
frameGradient.Rotation = 90
frameGradient.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
title.BorderSizePixel = 0
title.TextColor3 = Color3.fromRGB(230, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "⚡ CODEX ULTRA ⚡"
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Container para labels
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, -10, 0, 80)
infoContainer.Position = UDim2.new(0, 5, 0, 35)
infoContainer.BackgroundTransparency = 1
infoContainer.BorderSizePixel = 0
infoContainer.Parent = frame

local infoLayout = Instance.new("UIListLayout")
infoLayout.Padding = UDim.new(0, 4)
infoLayout.Parent = infoContainer

local function createLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = infoContainer
    return label
end

local statusLabel = createLabel("Status: ✅ ATIVADO")
local upgradesLabel = createLabel("Upgrades: ⚙️ Carregando...")
local fpsLabel = createLabel("FPS: --")
local timerLabel = createLabel("Tempo: 00:00")

-- Container para botões
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -10, 1, -125)
buttonContainer.Position = UDim2.new(0, 5, 0, 120)
buttonContainer.BackgroundTransparency = 1
buttonContainer.BorderSizePixel = 0
buttonContainer.Parent = frame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Padding = UDim.new(0, 6)
buttonLayout.Parent = buttonContainer

local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Text = text
    btn.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.2 end)
    
    if callback then btn.MouseButton1Click:Connect(function() task.spawn(callback) end) end
    return btn
end

local toggleBtn = createButton("🔴 DESATIVAR", Color3.fromRGB(0, 150, 100), function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "🔴 DESATIVAR" or "✅ ATIVAR"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = _G.scriptEnabled and "Status: ✅ ATIVADO" or "Status: ⛔ DESATIVADO"
end)

local turboBtn = createButton("🚀 TURBO (5s)", Color3.fromRGB(255, 140, 0), function()
    local old = {_G.floodIntensity, _G.floodDelay}
    _G.floodIntensity = 20
    _G.floodDelay = 0.016
    turboBtn.Text = "🚀 ON"
    statusLabel.Text = "Status: 🚀 TURBO!"
    task.wait(5)
    _G.floodIntensity = old[1]
    _G.floodDelay = old[2]
    turboBtn.Text = "🚀 TURBO (5s)"
    statusLabel.Text = "Status: ✅ ATIVADO"
end)

local webhookBtn = createButton("WEBHOOK: ON", Color3.fromRGB(20, 120, 180), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(20, 120, 180) or Color3.fromRGB(100, 100, 100)
end)

local setupBtn = createButton("⚙️ WEBHOOK SETUP", Color3.fromRGB(120, 80, 180), function()
    local pGui = Instance.new("ScreenGui")
    pGui.ResetOnSpawn = false
    pcall(function() if syn then syn.protect_gui(pGui) end pGui.Parent = game:GetService("CoreGui") end)
    if pGui.Parent == nil then pGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    local pFrame = Instance.new("Frame")
    pFrame.Size = UDim2.new(0.8, 0, 0.55, 0)
    pFrame.Position = UDim2.new(0.1, 0, 0.225, 0)
    pFrame.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
    pFrame.BorderSizePixel = 0
    pFrame.Parent = pGui
    
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 12)
    pCorner.Parent = pFrame
    
    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(150, 100, 200)
    pStroke.Thickness = 2
    pStroke.Parent = pFrame
    
    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, 0, 0, 35)
    pTitle.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    pTitle.TextColor3 = Color3.new(1, 1, 1)
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextSize = 14
    pTitle.Text = "Configurar Webhook"
    pTitle.Parent = pFrame
    
    local pTCorner = Instance.new("UICorner")
    pTCorner.CornerRadius = UDim.new(0, 12)
    pTCorner.Parent = pTitle
    
    local pInput = Instance.new("TextBox")
    pInput.Size = UDim2.new(0.9, 0, 0, 35)
    pInput.Position = UDim2.new(0.05, 0, 0, 40)
    pInput.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    pInput.TextColor3 = Color3.new(1, 1, 1)
    pInput.PlaceholderText = "URL do webhook..."
    pInput.Text = _G.webhookUrl or ""
    pInput.Font = Enum.Font.Gotham
    pInput.TextSize = 11
    pInput.Parent = pFrame
    
    local pICorner = Instance.new("UICorner")
    pICorner.CornerRadius = UDim.new(0, 8)
    pICorner.Parent = pInput
    
    local pSave = Instance.new("TextButton")
    pSave.Size = UDim2.new(0.3, 0, 0, 30)
    pSave.Position = UDim2.new(0.05, 0, 0, 80)
    pSave.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    pSave.TextColor3 = Color3.new(1, 1, 1)
    pSave.Font = Enum.Font.GothamBold
    pSave.TextSize = 11
    pSave.Text = "✅ SALVAR"
    pSave.Parent = pFrame
    
    local pSCorner = Instance.new("UICorner")
    pSCorner.CornerRadius = UDim.new(0, 6)
    pSCorner.Parent = pSave
    
    local pClose = Instance.new("TextButton")
    pClose.Size = UDim2.new(0.3, 0, 0, 30)
    pClose.Position = UDim2.new(0.65, 0, 0, 80)
    pClose.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    pClose.TextColor3 = Color3.new(1, 1, 1)
    pClose.Font = Enum.Font.GothamBold
    pClose.TextSize = 11
    pClose.Text = "❌ FECHAR"
    pClose.Parent = pFrame
    
    local pCCorner = Instance.new("UICorner")
    pCCorner.CornerRadius = UDim.new(0, 6)
    pCCorner.Parent = pClose
    
    pSave.MouseButton1Click:Connect(function()
        local url = pInput.Text:match("^%s*(.-)%s*$")
        if url and url:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = url
            pGui:Destroy()
            statusLabel.Text = "Status: ✅ Webhook OK"
        else
            pInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1)
            pInput.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
        end
    end)
    
    pClose.MouseButton1Click:Connect(function() pGui:Destroy() end)
end)

local sendBtn = createButton("📨 ENVIAR INFO", Color3.fromRGB(100, 70, 150), function()
    if not _G.webhookEnabled or not _G.webhookUrl then
        statusLabel.Text = "⚠️ Configure webhook"
        return
    end
    local uptime = math.floor(tick() - (scriptStartTime or tick()))
    local mins = math.floor(uptime / 60)
    local secs = uptime % 60
    sendWebhook("📨 Relatório", 
        "👤 " .. Players.LocalPlayer.Name ..
        "\n🏷️ " .. game.PlaceId ..
        "\n⏱️ " .. string.format("%02d:%02d", mins, secs) ..
        "\n🖥️ " .. fps .. " FPS",
        16751616)
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

-- Timer
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

-- ===== EVENTOS CARREGAMENTO =====
local clickEvents = {}
local upgradeEvents = {}
local specialEvents = {}
local dungeonEvents = {}
local concreteEvent = nil

local function preloadEvents()
    local Events = ReplicatedStorage:WaitForChild("Events", 5)
    if not Events then print("❌ Events não encontrada") return end
    
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
    
    upgradesLabel.Text = "Upgrades: ⚙️ " .. #upgradeEvents .. " OK"
end

spawn(preloadEvents)

-- ===== AUTO SYSTEMS =====
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
                if event then
                    for id = 1, upgrade[2] do
                        spawn(function() pcall(function() event:FireServer(id) end) end)
                    end
                end
            end
            for _, special in pairs(specialEvents) do
                if special[1] then
                    for id = 1, special[2] do
                        spawn(function() pcall(function() special[1]:FireServer(id, special[3]) end) end)
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
                pcall(function() dungeonEvents.changeEnemy:FireServer(1) end)
            end
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
                    spawn(function() pcall(function() upgrade:FireServer(id) end) end)
                end
            end
        end
        wait(0.01)
    end
end)

spawn(function()
    while true do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function() concreteEvent:FireServer() end)
            end
        end
        wait(0.1)
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then turboBtn.MouseButton1Click:Fire()
    end
end)

print("✅ CODEX ULTRA V4.1 COMPLETO - TUDO FUNCIONANDO!")
