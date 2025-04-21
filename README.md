-- ✅ SCRIPT CODEX ULTRA OTIMIZADO COM WEBHOOK
-- 🟣 VERSÃO ATUALIZADA E REVISADA

-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

-- Configurações do script
local scriptEnabled = true
local floodIntensity = 50
local floodDelay = 0.001
local webhookEnabled = true
local webhookInterval = 10
local webhookUrl = "COLOQUE_URL_DO_WEBHOOK_AQUI"

-- Funções de persistência do Webhook
local function loadWebhookSettings()
    local success, result = pcall(function()
        local configStore = DataStoreService:GetDataStore("CodexConfig")
        return configStore:GetAsync("CodexWebhook_" .. Players.LocalPlayer.Name)
    end)
    
    if success and result and type(result) == "string" and result:sub(1, 8) == "https://" then
        webhookUrl = result
        print("✓ Webhook URL carregado do armazenamento!")
        return true
    end
    
    return false
end

local function saveWebhookSettings(url)
    if not url or type(url) ~= "string" or url:sub(1, 8) ~= "https://" then return false end
    
    pcall(function()
        local configStore = DataStoreService:GetDataStore("CodexConfig")
        configStore:SetAsync("CodexWebhook_" .. Players.LocalPlayer.Name, url)
    end)
    
    print("✓ Webhook URL salvo com sucesso!")
    return true
end

-- Carrega configurações salvas
loadWebhookSettings()

-- Pré-carregamento de eventos
local Events = ReplicatedStorage:WaitForChild("Events")
local clickEvents = {
    Events:WaitForChild("ClickMoney"),
    Events:FindFirstChild("ClickMoney"):FindFirstChild("AtomClicker"),
    Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining"),
    Events:FindFirstChild("ClickMoney"):FindFirstChild("ClickMining2"),
    Events:FindFirstChild("Prestige"):FindFirstChild("Runestone4")
}

local upgradeEvents = {
    {Events:WaitForChild("Upgrade"):WaitForChild("TranscendUpgrade"), 30},
    {Events:WaitForChild("Upgrade"):WaitForChild("TimeUpgrade"), 10},
    -- Outros eventos de upgrade...
}

local specialEvents = {
    {Events:WaitForChild("Upgrade"):WaitForChild("RuneUpgrade"), 20, false},
    {Events:WaitForChild("Upgrade"):WaitForChild("GemUpgrade"), 15, true}
}

local dungeonEvents = {
    attack = Events:WaitForChild("DungeonAttack"),
    changeEnemy = Events:WaitForChild("DungeonAttack"):WaitForChild("ChangeEnemy"),
    rebirth = Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirth"),
    upgrades = {
        Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade"),
        Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonUpgrade2"),
        Events:WaitForChild("DungeonAttack"):WaitForChild("DungeonRebirthUpgrade")
    }
}

local concreteEvent = Events:WaitForChild("Prestige"):WaitForChild("ConcretePrestige")

-- Criação da GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CodexHUDPro"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Text = "CODEX ULTRA"
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
toggleBtn.Text = "ATIVADO"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.Text = "Status: Executando"
statusLabel.Parent = frame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.9, 0, 0, 20)
fpsLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.Font = Enum.Font.SourceSans
fpsLabel.TextSize = 12
fpsLabel.Text = "FPS: --"
fpsLabel.Parent = frame

local webhookBtn = Instance.new("TextButton")
webhookBtn.Size = UDim2.new(0.45, 0, 0, 20)
webhookBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
webhookBtn.Text = "WEBHOOK: ON"
webhookBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
webhookBtn.TextColor3 = Color3.new(1, 1, 1)
webhookBtn.Font = Enum.Font.SourceSans
webhookBtn.TextSize = 12
webhookBtn.Parent = frame

local urlBtn = Instance.new("TextButton")
urlBtn.Size = UDim2.new(0.45, 0, 0, 20)
urlBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
urlBtn.Text = "DEFINIR URL"
urlBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
urlBtn.TextColor3 = Color3.new(1, 1, 1)
urlBtn.Font = Enum.Font.SourceSans
urlBtn.TextSize = 12
urlBtn.Parent = frame

-- Função para enviar mensagens para o Webhook
local function sendWebhook(title, description, color)
    if not webhookEnabled or webhookUrl == "COLOQUE_URL_DO_WEBHOOK_AQUI" then
        statusLabel.Text = "Webhook: Configure a URL!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
        statusLabel.Text = "Status: Executando"
        return
    end
    
    local data = {
        embeds = {{
            title = title or "Codex Script Notification",
            description = description or "Atualização do script Codex",
            color = color or 3447003,
            footer = {
                text = "Codex Ultra Script v2.1 - Webhook Persistente"
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success then
        statusLabel.Text = "Webhook Enviado!"
        wait(1)
        statusLabel.Text = "Status: Executando"
    else
        statusLabel.Text = "Erro no Webhook!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        wait(1)
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
        statusLabel.Text = "Status: Executando"
        print("✗ Erro ao enviar webhook: " .. tostring(response))
    end
end

-- Eventos de interface
webhookBtn.MouseButton1Click:Connect(function()
    webhookEnabled = not webhookEnabled
    webhookBtn.Text = "WEBHOOK: " .. (webhookEnabled and "ON" or "OFF")
    webhookBtn.BackgroundColor3 = webhookEnabled and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(100, 100, 100)
end)

urlBtn.MouseButton1Click:Connect(function()
    -- Criar prompt para configurar a URL do Webhook
    -- código do prompt omitido por brevidade
end)

toggleBtn.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    toggleBtn.Text = scriptEnabled and "ATIVADO" or "DESATIVADO"
    toggleBtn.BackgroundColor3 = scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    statusLabel.Text = "Status: " .. (scriptEnabled and "Executando" or "Pausado")
end)

-- Anti-AFK
spawn(function()
    while wait(20) do
        if scriptEnabled then
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            VirtualUser:SetKeyDown(0x20)
            wait(0.1)
            VirtualUser:SetKeyUp(0x20)
        end
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

-- Sistemas de Eventos
local stats = {
    startTime = tick(),
    lastSentTime = 0,
    clickCount = 0,
    upgradesPerformed = 0,
    concretePrestiges = 0,
    dungeonAttacks = 0
}

-- Auto-clicker
spawn(function()
    while true do
        if scriptEnabled and #clickEvents > 0 then
            for _, event in pairs(clickEvents) do
                if event then
                    for i = 1, floodIntensity do
                        pcall(function()
                            event:FireServer()
                            stats.clickCount = stats.clickCount + 1
                        end)
                    end
                end
            end
        end
        wait(floodDelay)
    end
end)

-- Upgrades paralelos
spawn(function()
    while wait(0.1) do
        if scriptEnabled and #upgradeEvents > 0 then
            for _, upgrade in pairs(upgradeEvents) do
                local event = upgrade[1]
                local maxId = upgrade[2]
                
                if event then
                    for id = 1, maxId do
                        spawn(function()
                            pcall(function()
                                event:FireServer(id)
                                stats.upgradesPerformed = stats.upgradesPerformed + 1
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
                                stats.upgradesPerformed = stats.upgradesPerformed + 1
                            end)
                        end)
                    end
                end
            end
        end
    end
end)

-- Concrete Prestige
spawn(function()
    while wait(0.1) do
        if scriptEnabled and concreteEvent then
            for i = 1, 5 do
                pcall(function()
                    concreteEvent:FireServer()
                    stats.concretePrestiges = stats.concretePrestiges + 1
                end)
            end
        end
    end
end)

-- Dungeon Attack
spawn(function()
    while wait(floodDelay) do
        if scriptEnabled and dungeonEvents.attack then
            for i = 1, floodIntensity do
                pcall(function()
                    dungeonEvents.attack:FireServer()
                    stats.dungeonAttacks = stats.dungeonAttacks + 1
                end)
                
                pcall(function()
                    dungeonEvents.changeEnemy:FireServer(1)
                end)
            end
        end
    end
end)

-- Dungeon Rebirth
spawn(function()
    while wait(0.5) do
        if scriptEnabled and dungeonEvents.rebirth then
            for i = 1, 3 do
                pcall(function()
                    dungeonEvents.rebirth:FireServer()
                end)
            end
        end
    end
end)

-- Dungeon Upgrades
spawn(function()
    while wait(0.01) do
        if scriptEnabled and #dungeonEvents.upgrades > 0 then
            for _, upgrade in pairs(dungeonEvents.upgrades) do
                for id = 1, 10 do
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


-- Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        -- Toggle visibilidade
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Toggle ativação
        scriptEnabled = not scriptEnabled
        toggleBtn.Text = scriptEnabled and "ATIVADO" or "DESATIVADO"
        toggleBtn.BackgroundColor3 = scriptEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "Status: " .. (scriptEnabled and "Executando" or "Pausado")
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Boost temporário
        local oldIntensity = floodIntensity
        local oldDelay = floodDelay
        
        floodIntensity = 100
        floodDelay = 0.0005
        
        statusLabel.Text = "Status: BOOST ATIVADO"
        
        wait(5)
        
        floodIntensity = oldIntensity
        floodDelay = oldDelay
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
        
        if scriptEnabled then
            statusLabel.Text = string.format("Tempo: %02d:%02d", minutes, seconds)
        end
    end
end)

-- Monitor para enviar atualizações periódicas para o Webhook
spawn(function()
    sendWebhook("Codex Script Iniciado", "O script foi inicializado com sucesso!\n\nVersão: Ultra Otimizada com Webhook Persistente", 15105570)
    
    while wait(1) do
        if scriptEnabled and webhookEnabled then
            local currentTime = tick()
            
            if currentTime - stats.lastSentTime >= webhookInterval then
                local runTime = currentTime - stats.startTime
                local hours = math.floor(runTime / 3600)
                local minutes = math.floor((runTime % 3600) / 60)
                local seconds = math.floor(runTime % 60)
                
                local description = string.format([[
**Tempo de Execução:** %02d:%02d:%02d
**Clicks Realizados:** %s
**Upgrades Efetuados:** %s
**Concrete Prestiges:** %s
**Dungeon Attacks:** %s
**FPS Atual:** %s

*Script rodando no jogo %s*
**Jogador:** %s
]], hours, minutes, seconds, 
                stats.clickCount, 
                stats.upgradesPerformed,
                stats.concretePrestiges,
                stats.dungeonAttacks,
                fps,
                game.PlaceId,
                Players.LocalPlayer.Name)
                
                sendWebhook("Codex Script - Relatório Automático", description, 3066993)
                stats.lastSentTime = currentTime
            end
        end
    end
end)

print("✓ Script Codex Ultra Otimizado com Webhook Inicializado!")
print("✓ Pressione N para ocultar a interface")
print("✓ Pressione M para ativar/desativar o script")
print("✓ Pressione B para um boost temporário")
print("✓ Webhook " .. (webhookEnabled and "ativado" or "desativado") .. " - Envie relatórios para Discord")
