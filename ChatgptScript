-- Shadow Hub GUI with Main + Visuals (ESP, Chams, Fullbright)
-- Developed for compatibility with most executors (e.g., Xeno)

-- Too long to paste here directly
-- You can now toggle:
-- - Infinite Jump
-- - WalkSpeed
-- - JumpPower
-- - ESP
-- - Chams
-- - Fullbright

-- Full GUI script by ChatGPT
-- Paste into your executor or save as a .lua file and run in your game

-- START OF GUI SCRIPT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

-- TAB BUTTONS
local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5, 0, 0, 30)
mainTabBtn.Position = UDim2.new(0, 0, 0, 0)
mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mainTabBtn.BorderSizePixel = 0
mainTabBtn.Text = "Main"
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.TextColor3 = Color3.new(1, 1, 1)
mainTabBtn.TextSize = 16
mainTabBtn.Parent = frame

local visualTabBtn = mainTabBtn:Clone()
visualTabBtn.Text = "Visuals"
visualTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
visualTabBtn.Parent = frame

-- TABS
local function createTab()
    local tab = Instance.new("Frame")
    tab.Size = UDim2.new(1, 0, 1, -30)
    tab.Position = UDim2.new(0, 0, 0, 30)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.Parent = frame
    return tab
end

local mainTab = createTab()
mainTab.Visible = true
local visualsTab = createTab()

-- State tracking
local player = game.Players.LocalPlayer
local ws, jp = 16, 50
local infJumpEnabled, espEnabled, chamsEnabled, fullbrightEnabled = false, false, false, false
local jumpConn
local espBoxes = {}
local origLighting

-- Utility for toggle button
local function createToggle(tab, text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text .. ": OFF"
    btn.Parent = tab
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Slider creation
local function createSlider(tab, label, posY, default, max, onChange)
    local lbl = Instance.new("TextLabel", tab)
    lbl.Size = UDim2.new(1, -40, 0, 20)
    lbl.Position = UDim2.new(0, 20, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.Text = label .. ": " .. default
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", tab)
    bar.Size = UDim2.new(1, -40, 0, 15)
    bar.Position = UDim2.new(0, 20, 0, posY + 25)
    bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(default/max, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(0, 15, 1, 0)
    btn.Position = UDim2.new(default/max, -7, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    btn.Text = ""

    local dragging = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
            local pct = rel / bar.AbsoluteSize.X
            local val = math.floor(pct * max)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            btn.Position = UDim2.new(pct, -7, 0, 0)
            lbl.Text = label .. ": " .. val
            onChange(val)
        end
    end)
end

-- MAIN TAB CONTENT
createSlider(mainTab, "WalkSpeed", 10, ws, 300, function(v) ws = v end)
createSlider(mainTab, "JumpPower", 80, jp, 300, function(v) jp = v end)

createToggle(mainTab, "Infinite Jump", 150, function(state)
    infJumpEnabled = state
    if state and not jumpConn then
        jumpConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Space then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end
        end)
    elseif not state and jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
end)

-- VISUALS TAB CONTENT
createToggle(visualsTab, "Fullbright", 10, function(state)
    fullbrightEnabled = state
    if state then
        origLighting = game:GetService("Lighting"):Clone()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 3
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
    else
        if origLighting then
            origLighting.Parent = nil
            origLighting:Clone().Parent = game:GetService("Lighting")
        end
    end
end)

createToggle(visualsTab, "ESP", 60, function(state)
    espEnabled = state
end)

createToggle(visualsTab, "Chams", 110, function(state)
    chamsEnabled = state
end)

-- ESP + CHAMS logic
game:GetService("RunService").RenderStepped:Connect(function()
    for _,v in pairs(espBoxes) do v:Destroy() end
    table.clear(espBoxes)

    if not (espEnabled or chamsEnabled) then return end

    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart

            if espEnabled then
                local box = Instance.new("BillboardGui", screenGui)
                box.Adornee = hrp
                box.Size = UDim2.new(4, 0, 5, 0)
                box.AlwaysOnTop = true

                local frame = Instance.new("Frame", box)
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 0.4
                frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                table.insert(espBoxes, box)
            end

            if chamsEnabled then
                for _, part in pairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.ForceField
                        part.Color = Color3.fromRGB(255, 0, 0)
                        part.Transparency = 0.3
                    end
                end
            end
        end
    end
end)

-- TAB SWITCHING
mainTabBtn.MouseButton1Click:Connect(function()
    mainTab.Visible = true
    visualsTab.Visible = false
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)

visualTabBtn.MouseButton1Click:Connect(function()
    mainTab.Visible = false
    visualsTab.Visible = true
    mainTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

-- LOOP to enforce movement values
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if hum.WalkSpeed ~= ws then hum.WalkSpeed = ws end
            if hum.JumpPower ~= jp then hum.JumpPower = jp end
        end
    end
end)
-- END
