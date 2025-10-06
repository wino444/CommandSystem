-- SelfCommands.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ตรวจสอบว่าโหลดผ่าน AccessChecker.lua
if not getgenv().playerLevel then
    print("Error: SelfCommands.lua must be loaded through Loader.lua")
    return
end

local isNoclip = false
local noclipConnection
local isFloating = false
local floatConnection

-- ฟังก์ชันส่งข้อความ (เก็บไว้เผื่ออนาคต)
--[[
local function sendMessage(msg)
    local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel then
        channel:SendAsync(msg)
    else
        warn("❌ ไม่พบแชนเนล RBXGeneral")
    end
end
--]]

-- Function to enable noclip
local function enableNoclip()
    isNoclip = true
    noclipConnection = RunService.Stepped:Connect(function()
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    print("Noclip Enabled")
end

-- Function to disable noclip
local function disableNoclip()
    isNoclip = false
    if noclipConnection then noclipConnection:Disconnect() end
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    print("Noclip Disabled")
end

-- Function to make the player float
local function enableFloat(height)
    if not isFloating then
        isFloating = true
        local rootPart = Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.MaxForce = Vector3.new(0, 100000, 0)
            bodyPosition.D = 1000
            bodyPosition.P = 50000
            bodyPosition.Position = rootPart.Position + Vector3.new(0, height, 0)
            bodyPosition.Parent = rootPart
            floatConnection = bodyPosition
            print("Floating at height: " .. height)
        end
    end
end

-- Function to disable floating
local function disableFloat()
    if isFloating and floatConnection then
        floatConnection:Destroy()
        floatConnection = nil
        isFloating = false
        print("Floating Disabled")
    end
end

-- Function to blind the player
local function blindPlayer()
    if LocalPlayer:FindFirstChild("PlayerGui") then
        local gui = Instance.new("ScreenGui")
        gui.Name = "BlindEffect"
        gui.ResetOnSpawn = false
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        gui.Parent = LocalPlayer:FindFirstChild("PlayerGui")
        print("Blinded")
    end
end

-- Function to remove the blindness effect
local function unblindPlayer()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local blindGui = playerGui:FindFirstChild("BlindEffect")
        if blindGui then
            blindGui:Destroy()
            print("Unblinded")
        end
    end
end

-- Function to force jump
local function forceJump()
    if Humanoid then
        Humanoid.Jump = true
        print("Forced Jump")
    end
end

-- Handle self commands
local function handleSelfCommands()
    LocalPlayer.Chatted:Connect(function(message)
        local args = string.split(message, " ")
        local command = args[1] and args[1]:lower()

        if command == "/say" then
            local textToSay = message:sub(6)
            if textToSay and textToSay ~= "" then
                print("Say: " .. textToSay)
            end
        elseif command == "/noclip" then
            enableNoclip()
        elseif command == "/unnoclip" then
            disableNoclip()
        elseif command == "/speed" and args[2] then
            local speed = tonumber(args[2])
            if speed and speed >= 16 and speed <= 500 then
                Humanoid.WalkSpeed = speed
                print("Speed set to: " .. speed)
            end
        elseif command == "/jump" and args[2] then
            local jumpPower = tonumber(args[2])
            if jumpPower and jumpPower >= 50 and jumpPower <= 1000 then
                Humanoid.JumpPower = jumpPower
                print("Jump Power set to: " .. jumpPower)
            end
        elseif command == "/forcejump" then
            forceJump()
        elseif command == "/float" and args[2] then
            local height = tonumber(args[2])
            if height then
                enableFloat(height)
            end
        elseif command == "/unfloat" then
            disableFloat()
        elseif command == "/blind" then
            blindPlayer()
        elseif command == "/unblind" then
            unblindPlayer()
        end
    end)
end

return handleSelfCommands
