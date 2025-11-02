-- ✅ SCRIPT ULTRA OTIMIZADO V5.0 - PERFORMANCE MÁXIMA + WEBHOOK + GUI PROFISSIONAL
-- 🟣 TUDO INTEGRADO, CACHE OTIMIZADO, ADAPTATIVO AO FPS, CLEAN CODE

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- ===== CONFIGURAÇÕES GLOBAIS =====
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
end

-- ===== CACHE SYSTEM OTIMIZADO =====
local remoteCache = {}
local cacheRefreshTime = 300 -- Atualizar cache a cada 5 minutos

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

-- ===== WEBHOOK SYSTEM =====
local function sendWebhook(title, description, color)
    if not _G.webhookEnabled or not _G.webhookUrl or _G.webhookUrl == "" then return end
    
    local embed = {
        title = title,
        description = description,
        color = color,
        footer = { text = "Codex Ultra V5.0" },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    local payload = { content = "", embeds = { embed } }
    local body = HttpService:JSONEncode(payload)
    
    task.spawn(function()
        local ok = pcall(function()
            if syn and syn.request then
                syn.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            elseif http and http.request then
                http.request({ Url = _G.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            end
        end)
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

-- ===== GUI SYSTEM =====
local gui = Instance.new("ScreenGui")
gui.Name = "CodexV5HUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
pcall(function() if syn then syn.protect_gui(gui) end gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
if gui.Parent == nil then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Salvar posição
local saveKey = "codex_v5_pos.txt"
local defaultPos = UDim2.new(0.05, 0, 0.05, 0)
pcall(function()
    if readfile and isfile and isfile(saveKey) then
        local data = readfile(saveKey)
        local x, y = data:match("(%-?[%d%.]+),(%-?[%d%.]+)")
        if x and y then defaultPos = UDim2.new(0, tonumber(x), 0, tonumber(y)) end
    end
end)

-- Frame Principal
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 240)
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

-- Salvar posição com throttling
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
title.Parent = frame

-- ===== FPS HUD =====
local fpsHud = Instance.new("Frame", frame)
fpsHud.Size = UDim2.new(0.45, 0, 0, 25)
fpsHud.Position = UDim2.new(0.05, 0, 0.12, 0)
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

-- CPS HUD
local cpsHud = Instance.new("Frame", frame)
cpsHud.Size = UDim2.new(0.45, 0, 0, 25)
cpsHud.Position = UDim2.new(0.5, 0, 0.12, 0)
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

-- Botões principais
local toggleBtn = createBtn("⚡ TURBO", 0.18, Color3.fromRGB(170, 0, 255), function()
    _G.modoTurbo = not _G.modoTurbo
    toggleBtn.Text = _G.modoTurbo and "⚡ TURBO" or "💤 LEVE"
    toggleBtn.BackgroundColor3 = _G.modoTurbo and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(0, 160, 255)
    _G.floodIntensity = _G.modoTurbo and 30 or 10
    _G.floodDelay = _G.modoTurbo and 0.001 or 0.01
end)

local clickBtn = createBtn("AUTO CLICKER", 0.27, Color3.fromRGB(50, 150, 50), function()
    _G.autoClickEnabled = not _G.autoClickEnabled
    clickBtn.BackgroundColor3 = _G.autoClickEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
end)

local upgradeBtn = createBtn("UPGRADES", 0.36, Color3.fromRGB(50, 100, 180), function()
    _G.upgradesEnabled = not _G.upgradesEnabled
    upgradeBtn.BackgroundColor3 = _G.upgradesEnabled and Color3.fromRGB(50, 100, 180) or Color3.fromRGB(100, 100, 100)
end)

local dungeonBtn = createBtn("DUNGEON", 0.45, Color3.fromRGB(180, 100, 50), function()
    _G.dungeonEnabled = not _G.dungeonEnabled
    dungeonBtn.BackgroundColor3 = _G.dungeonEnabled and Color3.fromRGB(180, 100, 50) or Color3.fromRGB(100, 100, 100)
end)

local concreteBtn = createBtn("CONCRETE", 0.54, Color3.fromRGB(100, 100, 50), function()
    _G.concretePrestigeEnabled = not _G.concretePrestigeEnabled
    concreteBtn.BackgroundColor3 = _G.concretePrestigeEnabled and Color3.fromRGB(100, 100, 50) or Color3.fromRGB(100, 100, 100)
end)

local webhookBtn = createBtn("WEBHOOK: ON", 0.63, Color3.fromRGB(50, 150, 150), function()
    _G.webhookEnabled = not _G.webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (_G.webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = _G.webhookEnabled and Color3.fromRGB(50, 150, 150) or Color3.fromRGB(100, 100, 100)
end)

local masterBtn = createBtn("MASTER TOGGLE", 0.72, Color3.fromRGB(170, 0, 255), function()
    local state = not _G.autoClickEnabled
    _G.autoClickEnabled = state
    _G.upgradesEnabled = state
    _G.dungeonEnabled = state
    _G.concretePrestigeEnabled = state
    
    local color = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
    clickBtn.BackgroundColor3 = color
    upgradeBtn.BackgroundColor3 = color
    dungeonBtn.BackgroundColor3 = color
    concreteBtn.BackgroundColor3 = color
end)

-- Status Label
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Text = "✅ V5.0 ATIVO"

-- ===== KEYBINDS =====
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        _G.autoClickEnabled = not _G.autoClickEnabled
        clickBtn.BackgroundColor3 = _G.autoClickEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
    end
end)

-- ===== FPS MONITOR OTIMIZADO =====
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

-- ===== CPS MONITOR =====
local cps = 0
task.spawn(function()
    while true do
        task.wait(0.5)
        cpsLabel.Text = "CPS: " .. (cps * 2)
        cps = 0
    end
end)

_G.incrementCPS = function()
    cps = cps + 1
end

-- ===== AUTO CLICKERS ULTRA RÁPIDOS =====
local clickPaths = {
    "Events.ClickMoney",
    "Events.ClickMoney.AtomClicker",
    "Events.ClickMoney.ClickMining",
    "Events.ClickMoney.ClickMining2",
    "Events.Prestige.Runestone4"
}

-- Pré-cache
for _, path in ipairs(clickPaths) do
    task.spawn(function() getRemote(path) end)
end

-- Auto-clickers
for _, path in ipairs(clickPaths) do
    task.spawn(function()
        while true do
            if _G.autoClickEnabled then
                local intensity = _G.floodIntensity
                if _G.fps < 20 then intensity = 5
                elseif _G.fps < 30 then intensity = 10
                elseif _G.fps < 40 then intensity = 15 end
                
                for i = 1, intensity do
                    if not _G.autoClickEnabled then break end
                    local remote = remoteCache[path]
                    if remote then
                        pcall(function() remote:FireServer() end)
                        _G.incrementCPS()
                    end
                end
            end
            task.wait(_G.floodDelay)
        end
    end)
end

-- ===== UPGRADES DINÂMICOS OTIMIZADOS =====
local upgradeConfigs = {
    {"Events.Upgrade.TranscendUgprade", 30},
    {"Events.Upgrade.TimeUpgrade", 10},
    {"Events.Upgrade.ExtraUpgrade", 35},
    {"Events.Upgrade.AtomUpgrade2", 15},
    {"Events.Upgrade.MiningUpgrade", 35},
    {"Events.Upgrade.MiningUpgrade2", 20},
    {"Events.Upgrade.RuneUpgrade", 30},
    {"Events.Upgrade.RuneUpgrade2", 25},
    {"Events.Upgrade.JewelUpgrade", 25},
    {"Events.Upgrade.ExtraUpgrade3", 40},
    {"Events.Upgrade.ConcreteUpgrade", 30},
    {"Events.BuyRune.EquipRune", 10},
    {"Events.Prestige.PrestigeUpgrade", 30},
    {"Events.Prestige.ResearchUpgrade", 80}
}

for _, config in ipairs(upgradeConfigs) do
    task.spawn(function()
        while true do
            if _G.upgradesEnabled then
                for id = 1, config[2] do
                    if not _G.upgradesEnabled then break end
                    local remote = getRemote(config[1])
                    if remote then
                        pcall(function() remote:FireServer(id) end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ===== DUNGEON SYSTEM =====
task.spawn(function()
    while true do
        if _G.dungeonEnabled then
            for id = 1, 10 do
                if not _G.dungeonEnabled then break end
                local remote = getRemote("Events.DungeonAttack.DungeonUpgrade")
                if remote then
                    pcall(function() remote:FireServer(id) end)
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if _G.dungeonEnabled then
            local remote = getRemote("Events.DungeonAttack")
            if remote then
                pcall(function() remote:FireServer() end)
            end
        end
        task.wait(_G.floodDelay)
    end
end)

-- ===== CONCRETE PRESTIGE =====
task.spawn(function()
    while true do
        if _G.concretePrestigeEnabled then
            local remote = getRemote("Events.Prestige.ConcretePrestige")
            if remote then
                pcall(function() remote:FireServer() end)
            end
        end
        task.wait(0.1)
    end
end)

print("✓ Codex Ultra V5.0 - Ultra Otimizado com Webhook!")
sendWebhook("✅ Script Iniciado", "Codex Ultra V5.0 rodando em máxima performance", 3066993)
