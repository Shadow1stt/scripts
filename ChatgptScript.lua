-- ShadowHub GUI with Skeleton ESP and working Chams
-- Works on most executors (like Xeno)

-- === Setup UI ===
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "ShadowHub"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Tabs
local mainTab = Instance.new("Frame", frame)
mainTab.Size = UDim2.new(1, 0, 1, -30)
mainTab.Position = UDim2.new(0, 0, 0, 30)
mainTab.BackgroundTransparency = 1
mainTab.Name = "MainTab"

local visualsTab = mainTab:Clone()
visualsTab.Name = "VisualsTab"
visualsTab.Visible = false
visualsTab.Parent = frame

local mainTabBtn = Instance.new("TextButton", frame)
mainTabBtn.Size = UDim2.new(0.5, 0, 0, 30)
mainTabBtn.Text = "Main"
mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mainTabBtn.TextColor3 = Color3.new(1, 1, 1)
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.TextSize = 16

local visualTabBtn = mainTabBtn:Clone()
visualTabBtn.Text = "Visuals"
visualTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
visualTabBtn.Parent = frame

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

-- === MainTab Features ===
local ws = 16
local jp = 50
local infJumpEnabled = false

local function createSlider(tab, label, y, default, max, callback)
    local lbl = Instance.new("TextLabel", tab)
    lbl.Position = UDim2.new(0, 20, 0, y)
    lbl.Size = UDim2.new(1, -40, 0, 20)
    lbl.Text = label .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1

    local slider = Instance.new("Frame", tab)
    slider.Position = UDim2.new(0, 20, 0, y + 25)
    slider.Size = UDim2.new(1, -40, 0, 15)
    slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new(default / max, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    local knob = Instance.new("TextButton", slider)
    knob.Size = UDim2.new(0, 15, 1, 0)
    knob.Position = UDim2.new(default / max, -7, 0, 0)
    knob.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    knob.Text = ""

    local dragging = false

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            local pct = rel / slider.AbsoluteSize.X
            local val = math.floor(pct * max)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -7, 0, 0)
            lbl.Text = label .. ": " .. val
            callback(val)
        end
    end)
end

createSlider(mainTab, "WalkSpeed", 10, ws, 300, function(v) ws = v end)
createSlider(mainTab, "JumpPower", 80, jp, 300, function(v) jp = v end)

local function createToggle(tab, label, y, callback)
    local btn = Instance.new("TextButton", tab)
    btn.Size = UDim2.new(1, -40, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = label .. ": OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

createToggle(mainTab, "Infinite Jump", 150, function(state)
    infJumpEnabled = state
end)

-- Keep WalkSpeed/JumpPower applied
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = ws
            hum.JumpPower = jp
        end
    end
end)

-- Infinite Jump handler
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, gpe)
    if gpe or not infJumpEnabled then return end
    if input.KeyCode == Enum.KeyCode.Space then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- === Skeleton ESP ===
local function createSkeleton(plr)
    local char = plr.Character
    if not char then return end

    for _, limb in pairs({"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
        local part = char:FindFirstChild(limb)
        if part then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Adornee = part
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Size = part.Size + Vector3.new(0.1,0.1,0.1)
            adorn.Transparency = 0.3
            adorn.Color3 = Color3.new(1, 0, 0)
            adorn.Parent = screenGui
        end
    end
end

-- === Chams ===
local function applyChams(plr)
    local char = plr.Character
    if not char then return end

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.ForceField
            part.Color = Color3.fromRGB(0, 255, 255)
            part.Transparency = 0.3
        end
    end
end

-- === Visual Toggles ===
local skeletonOn = false
local chamsOn = false

local function makeToggle(parent, text, y, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -40, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = text .. ": OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

makeToggle(visualsTab, "Skeleton ESP", 10, function(state)
    skeletonOn = state
end)

makeToggle(visualsTab, "Chams", 55, function(state)
    chamsOn = state
end)

-- Update visuals every frame
game:GetService("RunService").RenderStepped:Connect(function()
    if not (skeletonOn or chamsOn) then return end

    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            if skeletonOn then
                createSkeleton(plr)
            end
            if chamsOn then
                applyChams(plr)
            end
        end
    end
end)
