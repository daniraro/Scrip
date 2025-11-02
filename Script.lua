-- ✅ SCRIPT PARA CODEX - V4.1 FINAL COM TUDO EM :FireServer()
-- 🟣 LINGUAGEM LUA - TUDO CORRETO

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

-- ===== WEBHOOK FUNCTION =====
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled or not _G.webhookUrl or _G.webhookUrl == "" then return end

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

    local response = nil
    if not response and syn and syn.request then
        local ok, res = pcall(function() return syn.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
        if ok and res then response = normalizeResponse(res) end
    end
    if not response and http and http.request then
        local ok, res = pcall(function() return http.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
        if ok and res then response = normalizeResponse(res) end
    end
    if not response and http_request then
        local ok, res = pcall(function() return http_request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
        if ok and res then response = normalizeResponse(res) end
    end
    if not response and request then
        local ok, res = pcall(function() return request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body }) end)
        if ok and res then response = normalizeResponse(res) end
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
end

-- ===== GUI =====
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
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Text = "CODEX ULTRA"
title.TextXAlignment = Enum.TextXAlignment.Left
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

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.9, 0, 0, 20)
timerLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
timerLabel.Font = Enum.Font.SourceSans
timerLabel.TextSize = 12
timerLabel.Text = "Tempo: 00:00"
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = frame

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

local sendInfoBtn = Instance.new("TextButton")
sendInfoBtn.Size = UDim2.new(0.45, 0, 0, 20)
sendInfoBtn.Position = UDim2.new(0.05, 0, 0.77, 0)
sendInfoBtn.Text = "ENVIAR INFO"
sendInfoBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 150)
sendInfoBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
sendInfoBtn.Font = Enum.Font.SourceSansBold
sendInfoBtn.TextSize = 12
sendInfoBtn.AutoButtonColor = true
sendInfoBtn.Parent = frame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 6)
sendCorner.Parent = sendInfoBtn

webhookBtn.MouseButton1Click:Connect(function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(100, 100, 100)
end)

sendInfoBtn.MouseButton1Click:Connect(function()
    if not _G.webhookEnabled or not _G.webhookUrl then
        statusLabel.Text = "Configure webhook!"
        return
    end
    local uptime = tostring(math.floor(tick() - (scriptStartTime or tick())))
    local description = string.format("📢 **Relatório**\n👤 %s\n🏷️ %s\n⏱ %s\n🖥 %s FPS",
        Players.LocalPlayer and Players.LocalPlayer.Name or "-",
        tostring(game.PlaceId),
        uptime,
        tostring(fps or 0))
    sendWebhook("📨 Relatório Manual", description, 16751616)
end)

urlBtn.MouseButton1Click:Connect(function()
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
    
    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, 0, 0, 35)
    pTitle.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    pTitle.TextColor3 = Color3.new(1, 1, 1)
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextSize = 14
    pTitle.Text = "Configurar Webhook"
    pTitle.Parent = pFrame
    
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
    
    local pSave = Instance.new("TextButton")
    pSave.Size = UDim2.new(0.3, 0, 0, 30)
    pSave.Position = UDim2.new(0.05, 0, 0, 80)
    pSave.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    pSave.TextColor3 = Color3.new(1, 1, 1)
    pSave.Font = Enum.Font.GothamBold
    pSave.TextSize = 11
    pSave.Text = "✅ SALVAR"
    pSave.Parent = pFrame
    
    local pClose = Instance.new("TextButton")
    pClose.Size = UDim2.new(0.3, 0, 0, 30)
    pClose.Position = UDim2.new(0.65, 0, 0, 80)
    pClose.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    pClose.TextColor3 = Color3.new(1, 1, 1)
    pClose.Font = Enum.Font.GothamBold
    pClose.TextSize = 11
    pClose.Text = "❌ FECHAR"
    pClose.Parent = pFrame
    
    pSave.MouseButton1Click:Connect(function()
        local url = pInput.Text:match("^%s*(.-)%s*$")
        if url and url:match("^https://discord.com/api/webhooks/") then
            _G.webhookUrl = url
            pGui:Destroy()
        else
            pInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1)
            pInput.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
        end
    end)
    
    pClose.MouseButton1Click:Connect(function()
        pGui:Destroy()
    end)
end)

toggleBtn.MouseButton1Click:Connect(function()
    _G.scriptEnabled = not _G.scriptEnabled
    toggleBtn.Text = _G.scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = _G.scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (_G.scriptEnabled and "Executando" or "Pausado")
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

spawn(function()
    local startTime = tick()
    while true do
        if _G.scriptEnabled then
            local runtime = math.floor(tick() - startTime)
            local minutes = math.floor(runtime / 60)
            local seconds = runtime % 60
            timerLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
        task.wait(1)
    end
end)

-- ===== EVENTOS CARREGAMENTO =====
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
    
    print("✓ Eventos carregados!")
    statusLabel.Text = "Status: Eventos carregados"
end

spawn(preloadEvents)

-- ===== AUTO SYSTEMS COM :FireServer() =====
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
                if upgrade[1] then
                    for id = 1, upgrade[2] do
                        spawn(function() pcall(function() upgrade[1]:FireServer(id) end) end)
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
    while wait(_G.floodDelay) do
        if _G.scriptEnabled and dungeonEvents.attack then
            for i = 1, _G.floodIntensity do
                pcall(function() dungeonEvents.attack:FireServer() end)
                pcall(function() dungeonEvents.changeEnemy:FireServer(1) end)
            end
        end
    end
end)

spawn(function()
    while wait(0.5) do
        if _G.scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function() dungeonEvents.rebirth:FireServer() end)
            end
        end
    end
end)

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

spawn(function()
    while wait(0.1) do
        if _G.scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function() concreteEvent:FireServer() end)
            end
        end
    end
end)

-- ===== KEYBINDS =====
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        toggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then
        local old = {_G.floodIntensity, _G.floodDelay}
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        statusLabel.Text = "BOOST!"
        wait(5)
        _G.floodIntensity = old[1]
        _G.floodDelay = old[2]
        statusLabel.Text = "Status: Executando"
    end
end)

print("✓ Codex Ultra V4.1 Completo!")
