-- AccessChecker.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

-- ลิงก์ GitHub สาธารณะ
local vipUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/main/NameVIP.lua"
local ownerUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/main/NameOwner.lua"
local selfCommandsUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/main/SelfCommands.lua"
local otherCommandsUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/main/OtherCommands.lua"

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

-- ฟังก์ชันโหลดไฟล์
local function loadScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        print("Successfully fetched script from " .. url)
        local successLoad, compiled = pcall(loadstring, response)
        if successLoad then
            if type(compiled) == "function" then
                print("Successfully compiled script from " .. url)
                return compiled()
            else
                warn("Error: Script from " .. url .. " did not return a function")
                return nil
            end
        else
            warn("Error compiling script from " .. url .. ": " .. compiled)
            return nil
        end
    else
        warn("Error loading " .. url .. ": " .. response)
        return nil
    end
end

-- โหลดไฟล์และเก็บใน getgenv()
local vipData = loadScript(vipUrl)
local ownerData = loadScript(ownerUrl)
getgenv().vipData = vipData or { vip = {}, moderator = {} } -- เก็บใน global environment
getgenv().ownerData = ownerData or {} -- เก็บใน global environment
print("VIP data loaded: ", getgenv().vipData)
print("Owner data loaded: ", getgenv().ownerData)

-- เพิ่ม timer รีโหลดทุก 2 นาที (120 วินาที)
spawn(function()
    while true do
        wait(120) -- รอ 2 นาที
        local success, newVipData = pcall(loadScript, vipUrl)
        if success then 
            getgenv().vipData = newVipData or getgenv().vipData 
            print("Reloaded VIP data: ", getgenv().vipData)
        end
        local success, newOwnerData = pcall(loadScript, ownerUrl)
        if success then 
            getgenv().ownerData = newOwnerData or getgenv().ownerData 
            print("Reloaded Owner data: ", getgenv().ownerData)
        end
        print("Reloaded VIP and Owner data")
    end
end)

-- ฟังก์ชันเช็คสิทธิ์
local function getPlayerLevel(playerName)
    if not playerName or playerName == "" then
        return 0, "Invalid name", {}, false, false
    end
    local levels = {}
    local maxLevel = 1
    local maxLevelName = "General"
    local isProtected = false
    local allowAll = false
    local vipProtected = false

    -- เช็คว่าเป็น Owner (ระดับ 4)
    if getgenv().ownerData then
        for _, entry in ipairs(getgenv().ownerData) do
            if entry.name == playerName then
                table.insert(levels, "Owner (4)")
                maxLevel = 4
                maxLevelName = "Owner"
                isProtected = entry.have_protected == "yes"
            end
        end
    end
    -- เช็คว่าเป็น Moderator (ระดับ 3) หรือ VIP (ระดับ 2)
    if getgenv().vipData then
        -- ตรวจสอบ Moderator
        if getgenv().vipData.moderator then
            for _, entry in ipairs(getgenv().vipData.moderator) do
                if entry.name == playerName then
                    table.insert(levels, "Moderator (3)")
                    if maxLevel < 3 then
                        maxLevel = 3
                        maxLevelName = "Moderator"
                        isProtected = entry.have_protected == "yes"
                        allowAll = entry.allow_all == "yes"
                    end
                    vipProtected = entry.have_protected == "yes"
                end
            end
        end
        -- ตรวจสอบ VIP
        if getgenv().vipData.vip then
            for _, entry in ipairs(getgenv().vipData.vip) do
                if entry.name == playerName then
                    table.insert(levels, "VIP (2)")
                    if maxLevel < 2 then
                        maxLevel = 2
                        maxLevelName = "VIP"
                        isProtected = entry.have_protected == "yes"
                        allowAll = entry.allow_all == "yes"
                    end
                    vipProtected = entry.have_protected == "yes"
                end
            end
        end
    end
    -- ถ้าไม่มีระดับ ให้เป็น General
    if #levels == 0 then
        table.insert(levels, "General (1)")
    end
    -- ถ้ามี protected ในทั้งสองไฟล์ ให้รับรองไม่โดนคำสั่ง
    if maxLevel == 4 and vipProtected and isProtected then
        isProtected = true
    end

    return maxLevel, maxLevelName, levels, isProtected, allowAll
end

-- ฟังก์ชันดำเนินการคำสั่ง
local function executeCommand(callerName, targetName, command, action)
    local callerLevel, callerLevelName, _, _, callerAllowAll = getPlayerLevel(callerName)
    local targetLevel, targetLevelName, _, targetProtected, _ = getPlayerLevel(targetName)

    if callerLevel == 0 or targetLevel == 0 then
        return false, "Invalid caller or target name"
    end

    -- ถ้า caller ไม่ใช่ VIP, Moderator หรือ Owner ไม่สามารถใช้คำสั่งได้ (กรณี 1)
    if callerLevel < 2 then
        return false, callerName .. " does not have permission to use commands on others"
    end

    -- ถ้าเป้าหมายมี protected ในทั้งสองไฟล์ (กรณี 3)
    if targetLevel == 4 and targetProtected then
        local vipData = getgenv().vipData
        local isVipProtected = false
        if vipData and (vipData.vip or vipData.moderator) then
            for _, entry in ipairs(vipData.vip or {}) do
                if entry.name == targetName and entry.have_protected == "yes" then
                    isVipProtected = true
                end
            end
            for _, entry in ipairs(vipData.moderator or {}) do
                if entry.name == targetName and entry.have_protected == "yes" then
                    isVipProtected = true
                end
            end
        end
        if isVipProtected then
            return false, targetName .. " is fully protected and cannot be affected"
        end
    end

    -- ถ้าเป้าหมายมีระดับสูงกว่า (กรณี 3)
    if targetLevel > callerLevel then
        return false, targetName .. " has higher level (" .. targetLevelName .. ") than " .. callerName .. " (" .. callerLevelName .. ")"
    end

    -- ถ้าเป้าหมายมีสถานะ protected และระดับเท่ากัน (กรณี 3)
    if targetProtected and targetLevel == callerLevel then
        return false, targetName .. " is protected and cannot be affected"
    end

    -- ดำเนินการคำสั่ง (กรณี 2)
    action()
    print(callerName .. " used command '" .. command .. "' on " .. targetName .. " successfully")
    return true, "Command executed"
end

-- ฟังก์ชันหลักสำหรับเรียกใช้
local function checkAccess(playerName)
    print("Checking access for player: " .. playerName)
    local level, levelName, levels, isProtected, allowAll = getPlayerLevel(playerName)
    if level == 0 then
        print(playerName .. " has access: Invalid name (0)")
        return level, levelName, isProtected, nil
    end
    local levelText = table.concat(levels, " and ")
    if #levels > 1 then
        print(playerName .. " is in " .. levelText .. ", using " .. levelName .. " (" .. level .. ")" .. (isProtected and " [protected]" or " [noprotected]") .. (allowAll and " [allow_all]" or ""))
    else
        print(playerName .. " has access: " .. levelName .. " (" .. level .. ")" .. (isProtected and " [protected]" or " [noprotected]") .. (allowAll and " [allow_all]" or ""))
    end

    -- เก็บระดับของผู้เล่นใน getgenv() เพื่อใช้ใน SelfCommands.lua
    getgenv().playerLevel = level
    print("Set playerLevel for " .. playerName .. ": " .. level)

    -- โหลดสคริปต์คำสั่งทั้งสองไฟล์
    local commandHandler = nil
    local selfCommands = loadScript(selfCommandsUrl)
    if selfCommands then
        print("Executing SelfCommands.lua")
        selfCommands()
        print("Loaded SelfCommands.lua")
    else
        print("Failed to load SelfCommands.lua")
    end
    local otherCommands = loadScript(otherCommandsUrl)
    if otherCommands then
        print("Executing OtherCommands.lua")
        commandHandler = function(callerName, targetName, command, action)
            return executeCommand(callerName, targetName, command, action)
        end
        otherCommands(commandHandler)
        print("Loaded OtherCommands.lua")
    else
        print("Failed to load OtherCommands.lua - VIP/Owner commands disabled")
    end

    return level, levelName, isProtected, commandHandler
end

return checkAccess
