-- ✅ SCRIPT CODEX ULTRA V5.0 FINAL COMPLETO
-- 🟣 TUDO INTEGRADO: GUI + WEBHOOK + AUTO-SYSTEMS + TIMER + FPS + MONITORAMENTO

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- ===== VARIÁVEIS GLOBAIS INICIAIS =====
if _G.scriptV5 == nil then
    _G.scriptV5 = true
    _G.autoClickEnabled = true
    _G.upgradesEnabled = true
    _G.dungeonEnabled = true
    _G.concretePrestigeEnabled = true
    _G.webhookEnabled = true
    _G.modoTurbo = true
    _G.fps = 60
    _G.floodIntensity = 30
    _G.floodDelay = 0.001
    _G.webhookUrl = ""
end

if not scriptStartTime then scriptStartTime = tick() end

-- ===== CACHE SYSTEM OTIMIZADO =====
local remoteCache = {}
local cacheRefreshTime = 300

local function getRemote(path)
    if remoteCache[path] and remoteCache[path].time and (tick() - remoteCache[path].time < cacheRefreshTime) then
        return remoteCache[path].remote
    end
    
    local parts = string.split(path, ".")
    local ref = ReplicatedStorage
    for _, part in ipairs(parts) do
        ref = ref:WaitForChild(part, 5)
        if not ref then return nil end
    end
    
    remoteCache[path] = {remote = ref, time = tick()}
    return ref
end

-- ===== WEBHOOK FUNCTION V4.1 COM normalizeResponse =====
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled or not _G.webhookUrl or _G.webhookUrl == "" then return end
    
    local embed = {
        title = title,
        description = description,
        color = color,
        footer = { text = "Codex Ultra Script v5.0" },
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
    
    task.spawn(function()
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
                    return { StatusCode = 200, Body = HttpService:PostAsync(_G.webhookUrl, body, Enum.HttpContentType.ApplicationJson) }
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
                    table.insert(list, { title = title, description = description, color = color, ts = DateTime.now():ToIsoDate() })
                    writefile(queueFile, HttpService:JSONEncode(list))
                    if statusLabel then statusLabel.Text = "✅ Webhook enfileirado" end
                    task.wait(1)
                    if statusLabel then statusLabel.Text = "Status: Executando" end
                end
            end)
        else
            if statusLabel then statusLabel.Text = "✅ Webhook enviado" end
            task.wait(1)
            if statusLabel then statusLabel.Text = "Status: Executando" end
        end
    end)
end

-- ===== ANTI-AFK OTIMIZADO =====
task.spawn(function()
    while true do
        task.wait(60)
        if _G.scriptV5 then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- ===== GUI SYSTEM PROFISSIONAL =====
local gui = Instance.new("ScreenGui")
gui.Name = "CodexV5HUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
pcall(function() if syn then syn.protect_gui(gui) end gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
if gui.Parent == nil then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local saveKey = "codex_v5_pos.txt"
local defaultPos = UDim2.new(0.05, 0, 0.05, 0)
pcall(function()
    if readfile and isfile and isfile(saveKey) then
        local data = readfile(saveKey)
        local x, y = data:match("(%-?[%d%.]+),(%-?[%d%.]+)")
        if x and y then defaultPos = UDim2.new(0, tonumber(x), 0, tonumber(y)) end
    end
end)

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 380)
frame.Position = defaultPos
frame.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(100, 60, 180)
uiStroke.Transparency = 0.5
uiStroke.Thickness = 2

local lastSaveTime = 0
frame:GetPropertyChangedSignal("Position"):Connect(function()
    if tick() - lastSaveTime < 1 then return end
    lastSaveTime = tick()
    if writefile then
        task.spawn(function()
            writefile(saveKey, tostring(math.floor(frame.Position.X.Offset))..","..tostring(math.floor(frame.Position.Y.Offset)))
        end)
    end
end)

-- ===== TÍTULO =====
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 200, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Text = "⚡ CODEX ULTRA V5.0"

-- ===== STATUS E MONITORAMENTO =====
local fpsHud = Instance.new("Frame", frame)
fpsHud.Size = UDim2.new(0.45, 0, 0, 25)
fpsHud.Position = UDim2.new(0.05, 0, 0.08, 0)
fpsHud.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
fpsHud.BackgroundTransparency = 0.3
fpsHud.BorderSizePixel = 0
Instance.new("UICorner", fpsHud).CornerRadius = UDim.new(0, 6)

local fpsLabel = Instance.new("TextLabel", fpsHud)
fpsLabel.Size = UDim2.new(1, -10, 1, 0)
fpsLabel.Position = UDim2.new(0, 5, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 12
fpsLabel.Text = "FPS: 60"
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local timerHud = Instance.new("Frame", frame)
timerHud.Size = UDim2.new(0.45, 0, 0, 25)
timerHud.Position = UDim2.new(0.5, 0, 0.08, 0)
timerHud.BackgroundColor3 = Color3.fromRGB(70, 40, 0)
timerHud.BackgroundTransparency = 0.3
timerHud.BorderSizePixel = 0
Instance.new("UICorner", timerHud).CornerRadius = UDim.new(0, 6)

local timerLabel = Instance.new("TextLabel", timerHud)
timerLabel.Size = UDim2.new(1, -10, 1, 0)
timerLabel.Position = UDim2.new(0, 5, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 12
timerLabel.Text = "Tempo: 00:00"
timerLabel.TextXAlignment = Enum.TextXAlignment.Left

local cpsHud = Instance.new("Frame", frame)
cpsHud.Size = UDim2.new(1, -0.1, 0, 25)
cpsHud.Position = UDim2.new(0.05, 0, 0.16, 0)
cpsHud.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
cpsHud.BackgroundTransparency = 0.3
cpsHud.BorderSizePixel = 0
Instance.new("UICorner", cpsHud).CornerRadius = UDim.new(0, 6)

local cpsLabel = Instance.new("TextLabel", cpsHud)
cpsLabel.Size = UDim2.new(1, -10, 1, 0)
cpsLabel.Position = UDim2.new(0, 5, 0, 0)
cpsLabel.BackgroundTransparency = 1
cpsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
cpsLabel.Font = Enum.Font.GothamBold
cpsLabel.TextSize = 12
cpsLabel.Text = "CPS: 0"
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -0.1, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.24, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Text = "✅ V5.0 ATIVO"

-- ===== BOTÕES DE CONTROLE =====
local function createBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 22)
    btn.Position = UDim2.new(0.05, 0, pos, 0)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local toggleBtn = createBtn("⚡ TURBO", 0.30, Color3.fromRGB(170, 0, 255), function()
    _G.modoTurbo = not _G.modoTurbo
    toggleBtn.Text = _G.modoTurbo and "⚡ TURBO" or "💤 LEVE"
    toggleBtn.BackgroundColor3 = _G.modoTurbo and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(0, 160, 255)
    _G.floodIntensity = _G.modoTurbo and 30 or 10
    _G.floodDelay = _G.modoTurbo and 0.001 or 0.01
end)

local clickBtn = createBtn("AUTO CLICKER", 0.38, Color3.fromRGB(50, 150, 50), function()
    _G.autoClickEnabled = not _G.autoClickEnabled
    clickBtn.BackgroundColor3 = _G.autoClickEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
end)

local upgradeBtn = createBtn("UPGRADES", 0.46, Color3.fromRGB(50, 100, 180), function()
    _G.upgradesEnabled = not _G.upgradesEnabled
    upgradeBtn.BackgroundColor3 = _G.upgradesEnabled and Color3.fromRGB(50, 100, 180) or Color3.fromRGB(100, 100, 100)
end)

local dungeonBtn = createBtn("DUNGEON", 0.54, Color3.fromRGB(180, 100, 50), function()
    _G.dungeonEnabled = not _G.dungeonEnabled
    dungeonBtn.BackgroundColor3 = _G.dungeonEnabled and Color3.fromRGB(180, 100, 50) or Color3.fromRGB(100, 100, 100)
end)

local concreteBtn = createBtn("CONCRETE", 0.62, Color3.fromRGB(100, 100, 50), function()
    _G.concretePrestigeEnabled = not _G.concretePrestigeEnabled
    concreteBtn.BackgroundColor3 = _G.concretePrestigeEnabled and Color3.fromRGB(100, 100, 50) or Color3.fromRGB(100, 100, 100)
end)

local webhookBtn = createBtn("WEBHOOK: ON", 0.70, Color3.fromRGB(50, 150, 150), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(50, 150, 150) or Color3.fromRGB(100, 100, 100)
end)

local urlBtn = createBtn("DEFINIR URL", 0.78, Color3.fromRGB(60, 60, 90), function()
    local pGui = Instance.new("ScreenGui")
    pGui.ResetOnSpawn = false
    pcall(function() if syn then syn.protect_gui(pGui) end pGui.Parent = game:GetService("CoreGui") end)
    if pGui.Parent == nil then pGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
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
            statusLabel.Text = "✅ Webhook configurado"
        else
            pInput.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1)
            pInput.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
        end
    end)
    
    pClose.MouseButton1Click:Connect(function() pGui:Destroy() end)
end)

local sendInfoBtn = createBtn("ENVIAR INFO", 0.86, Color3.fromRGB(100, 60, 150), function()
    if not _G.webhookEnabled or not _G.webhookUrl then
        statusLabel.Text = "Configure webhook!"
        return
    end
    local uptime = tostring(math.floor(tick() - (scriptStartTime or tick())))
    local mins = math.floor(uptime / 60)
    local secs = uptime % 60
    local description = string.format("📢 **Relatório**\n👤 %s\n🏷️ %s\n⏱ %02d:%02d\n🖥 %s FPS\n💰 CPS: %s", 
        LocalPlayer and LocalPlayer.Name or "-", 
        tostring(game.PlaceId), 
        mins, secs, 
        tostring(_G.fps or 0),
        cpsLabel.Text:match("%d+"))
    sendWebhook("📨 Relatório Manual", description, 16751616)
end)

-- ===== KEYBINDS =====
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        _G.autoClickEnabled = not _G.autoClickEnabled
        clickBtn.BackgroundColor3 = _G.autoClickEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
    elseif input.KeyCode == Enum.KeyCode.B then
        local old = {_G.floodIntensity, _G.floodDelay}
        _G.floodIntensity = 100
        _G.floodDelay = 0.0005
        statusLabel.Text = "🚀 BOOST ATIVADO!"
        task.wait(5)
        _G.floodIntensity = old[1]
        _G.floodDelay = old[2]
        statusLabel.Text = "Status: Executando"
    end
end)

-- ===== TIMER E FPS MONITOR =====
local frameCount = 0
local lastFpsUpdate = tick()
local fpsThreshold = 40

RS.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsUpdate >= 0.5 then
        _G.fps = math.floor(frameCount / (now - lastFpsUpdate))
        fpsLabel.Text = "FPS: " .. _G.fps
        fpsHud.BackgroundColor3 = _G.fps < fpsThreshold and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(0, 120, 0)
        frameCount = 0
        lastFpsUpdate = now
    end
end)

spawn(function()
    local startTime = tick()
    while true do
        if _G.scriptV5 then
            local runtime = math.floor(tick() - startTime)
            local minutes = math.floor(runtime / 60)
            local seconds = runtime % 60
            timerLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
        task.wait(1)
    end
end)

-- ===== CPS MONITOR =====
local cps = 0
spawn(function()
    while true do
        task.wait(0.5)
        cpsLabel.Text = "CPS: " .. (cps * 2)
        cps = 0
    end
end)

_G.incrementCPS = function()
    cps = cps + 1
end

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
    statusLabel.Text = "✅ Eventos carregados"
end

spawn(preloadEvents)

-- ===== AUTO CLICKERS =====
spawn(function()
    while true do
        if _G.autoClickEnabled and #clickEvents > 0 then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, _G.floodIntensity do
                        pcall(function() event:FireServer() end)
                        _G.incrementCPS()
                    end
                end
            end
        end
        wait(_G.floodDelay)
    end
end)

-- ===== UPGRADES =====
spawn(function()
    while wait(0.1) do
        if _G.upgradesEnabled and #upgradeEvents > 0 then
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

-- ===== DUNGEON ATTACK =====
spawn(function()
    while wait(_G.floodDelay) do
        if _G.dungeonEnabled and dungeonEvents.attack then
            for i = 1, _G.floodIntensity do
                pcall(function() dungeonEvents.attack:FireServer() end)
                pcall(function() dungeonEvents.changeEnemy:FireServer(1) end)
            end
        end
    end
end)

-- ===== DUNGEON REBIRTH =====
spawn(function()
    while wait(0.5) do
        if _G.dungeonEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function() dungeonEvents.rebirth:FireServer() end)
            end
        end
    end
end)

-- ===== DUNGEON UPGRADES =====
spawn(function()
    while wait(0.01) do
        if _G.dungeonEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                for id = 1, 10 do
                    spawn(function() pcall(function() upgrade:FireServer(id) end) end)
                end
            end
        end
    end
end)

-- ===== CONCRETE PRESTIGE =====
spawn(function()
    while wait(0.1) do
        if _G.concretePrestigeEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function() concreteEvent:FireServer() end)
            end
        end
    end
end)

print("✓ Codex Ultra V5.0 - COMPLETO E FUNCIONAL!")
sendWebhook("✅ Script Iniciado", "Codex Ultra V5.0 rodando em máxima performance!", 3066993)
