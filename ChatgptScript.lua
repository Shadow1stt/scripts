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

-- Add more features in mainTab if needed
