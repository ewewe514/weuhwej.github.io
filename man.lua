local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local positions = {
    Vector3.new(57, 3, 30000), Vector3.new(57, 3, 28000),
    Vector3.new(57, 3, 26000), Vector3.new(57, 3, 24000),
    Vector3.new(57, 3, 22000), Vector3.new(57, 3, 20000),
    Vector3.new(57, 3, 18000), Vector3.new(57, 3, 16000),
    Vector3.new(57, 3, 14000), Vector3.new(57, 3, 12000),
    Vector3.new(57, 3, 10000), Vector3.new(57, 3, 8000),
    Vector3.new(57, 3, 6000), Vector3.new(57, 3, 4000),
    Vector3.new(57, 3, 2000), Vector3.new(57, 3, 0),
    Vector3.new(57, 3, -2000), Vector3.new(57, 3, -4000),
    Vector3.new(57, 3, -6000), Vector3.new(57, 3, -8000),
    Vector3.new(57, 3, -10000), Vector3.new(57, 3, -12000),
    Vector3.new(57, 3, -14000), Vector3.new(57, 3, -16000),
    Vector3.new(57, 3, -18000), Vector3.new(57, 3, -20000),
    Vector3.new(57, 3, -22000), Vector3.new(57, 3, -24000),
    Vector3.new(57, 3, -26000), Vector3.new(57, 3, -28000),
    Vector3.new(57, 3, -30000), Vector3.new(57, 3, -32000),
    Vector3.new(57, 3, -34000), Vector3.new(57, 3, -36000),
    Vector3.new(57, 3, -38000), Vector3.new(57, 3, -40000),
    Vector3.new(57, 3, -42000), Vector3.new(57, 3, -44000),
    Vector3.new(57, 3, -46000), Vector3.new(57, 3, -48000),
    Vector3.new(57, 3, -49032)
}

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

local bondCounter = Instance.new("TextLabel")
bondCounter.Size = UDim2.new(0, 200, 0, 50)
bondCounter.Position = UDim2.new(0.5, -100, 0, 50)
bondCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bondCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
bondCounter.TextSize = 20
bondCounter.Text = "Bonds Found: 0"
bondCounter.Parent = screenGui

local bondCount = 0

-- Bond Detection Function
local function checkForBonds(currentPos)
    for _, bondModel in pairs(workspace.RuntimeItems:GetChildren()) do
        if bondModel:IsA("Model") and bondModel.PrimaryPart then
            local bondZ = bondModel.PrimaryPart.Position.Z
            
            -- Ensuring bond is detected at or near current position
            if math.abs(bondZ - currentPos.Z) <= 500 then
                bondCount += 1
            end
        end
    end
    bondCounter.Text = "Bonds Found: " .. bondCount
end

-- Instant Teleport Loop
for _, pos in ipairs(positions) do
    humanoidRootPart.CFrame = CFrame.new(pos)
    checkForBonds(pos)
    task.wait(0.05) -- Small delay for GUI update
end

print("Teleporting complete. Total Bonds Found: " .. bondCount)
