-- Loader.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

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

local function loadScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local successLoad, compiled = pcall(loadstring, response)
        if successLoad then
            return compiled()
        else
            warn("Error compiling script from " .. url .. ": " .. compiled)
            return nil
        end
    else
        warn("Error loading " .. url .. ": " .. response)
        return nil
    end
end

local accessChecker = loadScript("https://raw.githubusercontent.com/wino444/CommandSystem/main/AccessChecker.lua")
if accessChecker then
    accessChecker(LocalPlayer.Name)
    print("AccessChecker loaded and executed for " .. LocalPlayer.Name)
else
    warn("Failed to load AccessChecker.lua")
end
