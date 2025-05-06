local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local x = 57
local y = 3
local startZ = 30000
local endZ = -49032.99
local stepZ = -2000
local duration = 0.5
local stopTweening = false

local teleportCount = 10
local delayTime = 0.1

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
local bondPositions = {}

-- Disable Collisions
RunService.Stepped:Connect(function()
    for _, descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = false
        end
    end
end)

-- Bond Detection Function
local function checkForBonds(currentZ)
    for _, bondModel in pairs(workspace.RuntimeItems:GetChildren()) do
        if bondModel:IsA("Model") and bondModel.PrimaryPart then
            local bondZ = bondModel.PrimaryPart.Position.Z
            local bondPosition = bondModel.PrimaryPart.Position
            
            -- Expanding bounds slightly to ensure detection
            if bondZ <= currentZ and bondZ > currentZ + stepZ * 1.1 then
                bondCount += 1
                table.insert(bondPositions, bondPosition)
            end
        end
    end
    bondCounter.Text = "Bonds Found: " .. bondCount
end

-- Tween Loop
for z = startZ, endZ, stepZ do
    if stopTweening then break end
    local adjustedY = math.max(y, 3)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(Vector3.new(x, adjustedY, z))}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    
    tween:Play()
    tween.Completed:Wait()
    
    checkForBonds(z) -- Update bond count during tween
end

print("Tweening complete. Total Bonds Found: " .. bondCount)

-- Wait 3 seconds before teleporting to each bond
task.wait(3)

-- Teleport to each bond location with a 0.8-second delay, unless bonds are close together
local lastPos = nil

for _, bondPos in ipairs(bondPositions) do
    if lastPos and (bondPos - lastPos).Magnitude <= 10 then
        continue -- Skip teleport if the bond is within 10 studs of the previous one
    end
    
    humanoidRootPart.CFrame = CFrame.new(bondPos)
    lastPos = bondPos
    task.wait(0.8)
end

print("Teleportation to all bonds completed.")
