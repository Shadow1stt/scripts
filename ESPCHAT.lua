local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Default settings
local ESPEnabled = true
local toggleKey = Enum.KeyCode.K
local highlightColor = Color3.fromRGB(255, 0, 0)  -- Default to red
local showNameTags = true
local showHealthBars = true

local espObjects = {}

-- Create GUI for settings
local function createSettingsGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPSettingsGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 300)
    frame.Position = UDim2.new(0.5, -150, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = screenGui

    -- Toggle ESP Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 280, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.Text = "Toggle ESP: ON"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextSize = 18
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Parent = frame

    -- Color Picker Button for Highlight Color
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 280, 0, 40)
    colorButton.Position = UDim2.new(0, 10, 0, 60)
    colorButton.BackgroundColor3 = highlightColor
    colorButton.Text = "Highlight Color"
    colorButton.TextColor3 = Color3.new(1, 1, 1)
    colorButton.TextSize = 18
    colorButton.Font = Enum.Font.SourceSans
    colorButton.Parent = frame

    -- Keybind Button for Toggle Key
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0, 280, 0, 40)
    keyButton.Position = UDim2.new(0, 10, 0, 110)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyButton.Text = "Set Toggle Key: K"
    keyButton.TextColor3 = Color3.new(1, 1, 1)
    keyButton.TextSize = 18
    keyButton.Font = Enum.Font.SourceSans
    keyButton.Parent = frame

    -- Enable/Disable Name Tags Checkbox
    local nameTagCheckbox = Instance.new("TextButton")
    nameTagCheckbox.Size = UDim2.new(0, 280, 0, 40)
    nameTagCheckbox.Position = UDim2.new(0, 10, 0, 160)
    nameTagCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    nameTagCheckbox.Text = "Show Name Tags: ON"
    nameTagCheckbox.TextColor3 = Color3.new(1, 1, 1)
    nameTagCheckbox.TextSize = 18
    nameTagCheckbox.Font = Enum.Font.SourceSans
    nameTagCheckbox.Parent = frame

    -- Enable/Disable Health Bars Checkbox
    local healthBarCheckbox = Instance.new("TextButton")
    healthBarCheckbox.Size = UDim2.new(0, 280, 0, 40)
    healthBarCheckbox.Position = UDim2.new(0, 10, 0, 210)
    healthBarCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarCheckbox.Text = "Show Health Bars: ON"
    healthBarCheckbox.TextColor3 = Color3.new(1, 1, 1)
    healthBarCheckbox.TextSize = 18
    healthBarCheckbox.Font = Enum.Font.SourceSans
    healthBarCheckbox.Parent = frame

    -- Event Handlers for GUI Buttons
    toggleButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        toggleButton.Text = ESPEnabled and "Toggle ESP: ON" or "Toggle ESP: OFF"
    end)

    colorButton.MouseButton1Click:Connect(function()
        -- Open color picker or use a preset for simplicity
        highlightColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        colorButton.BackgroundColor3 = highlightColor
    end)

    keyButton.MouseButton1Click:Connect(function()
        keyButton.Text = "Press a key..."
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            keyButton.Text = "Set Toggle Key: " .. input.KeyCode.Name
            toggleKey = input.KeyCode
        end)
    end)

    nameTagCheckbox.MouseButton1Click:Connect(function()
        showNameTags = not showNameTags
        nameTagCheckbox.Text = "Show Name Tags: " .. (showNameTags and "ON" or "OFF")
    end)

    healthBarCheckbox.MouseButton1Click:Connect(function()
        showHealthBars = not showHealthBars
        healthBarCheckbox.Text = "Show Health Bars: " .. (showHealthBars and "ON" or "OFF")
    end)
end

-- Create the settings GUI
createSettingsGUI()

-- Create ESP for a player
local function createESP(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not head or not humanoid then return end

    -- Remove existing ESP
    if espObjects[player] then
        espObjects[player].gui:Destroy()
    end

    -- Billboard GUI
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESPBillboard"
    gui.Adornee = head
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.Parent = head

    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = gui

    -- Health bar background
    local healthBG = Instance.new("Frame")
    healthBG.Size = UDim2.new(1, 0, 0.2, 0)
    healthBG.Position = UDim2.new(0, 0, 0.8, 0)
    healthBG.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    healthBG.BorderSizePixel = 0
    healthBG.ZIndex = 0
    healthBG.Parent = gui

    -- Health bar foreground
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0, 0, 0.8, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
    healthBar.BorderSizePixel = 0
    healthBar.ZIndex = 1
    healthBar.Parent = gui

    -- Highlight
    local highlight = player.Character:FindFirstChild("PlayerHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = highlightColor
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character
    end

    -- Store
    espObjects[player] = {
        gui = gui,
        healthBar = healthBar,
        highlight = highlight,
        humanoid = humanoid,
    }
end

-- Update ESP visuals
RunService.RenderStepped:Connect(function()
    for player, data in pairs(espObjects) do
        if player and player.Character and data.humanoid then
            local hp = data.humanoid.Health / data.humanoid.MaxHealth
            data.healthBar.Size = UDim2.new(hp, 0, 0.2, 0)
            data.healthBar.BackgroundColor3 = Color3.fromHSV(hp / 3, 1, 1)
        end
    end
end)

-- Toggle ESP with key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        ESPEnabled = not ESPEnabled
    end
end)

-- Create ESP for all players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        createESP(player)
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            createESP(player)
        end)
    end
end
