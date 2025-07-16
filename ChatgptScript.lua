local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local mainTab = Instance.new("Frame")
mainTab.Size = UDim2.new(1, 0, 1, -30)
mainTab.Position = UDim2.new(0, 0, 0, 30)
mainTab.BackgroundTransparency = 1
mainTab.Name = "MainTab"
mainTab.Parent = frame

local visualsTab = mainTab:Clone()
visualsTab.Name = "VisualsTab"
visualsTab.Visible = false
visualsTab.Parent = frame

local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5, 0, 0, 30)
mainTabBtn.Text = "Main"
mainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mainTabBtn.TextColor3 = Color3.new(1, 1, 1)
mainTabBtn.Font = Enum.Font.GothamBold
mainTabBtn.TextSize = 16
mainTabBtn.Parent = frame

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

local ws = 16
local jp = 50
local infJumpEnabled = false

local function createToggle(tab, label, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = label .. ": OFF"
    btn.Parent = tab

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

createToggle(mainTab, "Infinite Jump", 10, function(state)
    infJumpEnabled = state
end)

local function makeInput(tab, label, y, default, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Position = UDim2.new(0, 20, 0, y)
    lbl.Size = UDim2.new(0, 100, 0, 25)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = tab

    local input = Instance.new("TextBox")
    input.Text = tostring(default)
    input.Position = UDim2.new(0, 130, 0, y)
    input.Size = UDim2.new(0, 100, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = tab

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then callback(val) end
    end)
end

makeInput(mainTab, "WalkSpeed", 55, ws, function(v) ws = v end)
makeInput(mainTab, "JumpPower", 90, jp, function(v) jp = v end)

spawn(function()
    while true do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.WalkSpeed = ws
                hum.JumpPower = jp
            end
        end
        task.wait(0.1)
    end
end)

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

local adornments = {}

local function clearSkeleton()
    for _, v in pairs(adornments) do v:Destroy() end
    adornments = {}
end

local function createSkeleton(plr)
    local char = plr.Character
    if not char then return end
    for _, limb in pairs({"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local part = char:FindFirstChild(limb)
        if part then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Adornee = part
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
            adorn.Transparency = 0.3
            adorn.Color3 = Color3.new(1, 0, 0)
            adorn.Parent = screenGui
            table.insert(adornments, adorn)
        end
    end
end

local skeletonOn = false
local fullbrightOn = false

createToggle(visualsTab, "Skeleton ESP", 10, function(state)
    skeletonOn = state
    if not state then clearSkeleton() end
end)

createToggle(visualsTab, "Fullbright", 55, function(state)
    fullbrightOn = state
    local lighting = game:GetService("Lighting")
    if state then
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.Brightness = 2
        lighting.ClockTime = 12
    else
        lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        lighting.Brightness = 1
    end
end)

local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    if skeletonOn then
        clearSkeleton()
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player then
                createSkeleton(plr)
            end
        end
    end
end)
