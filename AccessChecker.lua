-- AccessChecker.lua
local HttpService = game:GetService("HttpService")

-- ลิงก์ GitHub สาธารณะ
local vipUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/refs/heads/main/NameVIP.lua"
local ownerUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/refs/heads/main/NameOwner.lua"

-- ฟังก์ชันโหลดไฟล์
local function loadScript(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        return loadstring(response)()
    else
        warn("Error loading " .. url .. ": " .. response)
        return nil
    end
end

-- โหลดไฟล์
local vipData = loadScript(vipUrl)
local ownerData = loadScript(ownerUrl)

-- ฟังก์ชันเช็คสิทธิ์
local function getPlayerLevel(playerName)
    if not playerName or playerName == "" then
        return 0, "Invalid name", {}
    end
    local levels = {}
    local maxLevel = 1
    local maxLevelName = "General"

    -- เช็คว่าเป็น Owner (ระดับ 3)
    if ownerData and ownerData.owner then
        for _, name in ipairs(ownerData.owner) do
            if name == playerName then
                table.insert(levels, "Owner (3)")
                maxLevel = 3
                maxLevelName = "Owner"
            end
        end
    end
    -- เช็คว่าเป็น VIP (ระดับ 2)
    if vipData and vipData.vip then
        for _, name in ipairs(vipData.vip) do
            if name == playerName then
                table.insert(levels, "VIP (2)")
                if maxLevel < 2 then
                    maxLevel = 2
                    maxLevelName = "VIP"
                end
            end
        end
    end
    -- ถ้าไม่มีระดับ ให้เป็น General
    if #levels == 0 then
        table.insert(levels, "General (1)")
    end

    return maxLevel, maxLevelName, levels
end

-- ฟังก์ชันหลักสำหรับเรียกใช้
local function checkAccess(playerName)
    local level, levelName, levels = getPlayerLevel(playerName)
    if level == 0 then
        print(playerName .. " has access: Invalid name (0)")
        return level, levelName
    end
    local levelText = table.concat(levels, " and ")
    if #levels > 1 then
        print(playerName .. " is in " .. levelText .. ", using " .. levelName .. " (" .. level .. ")")
    else
        print(playerName .. " has access: " .. levelName .. " (" .. level .. ")")
    end
    return level, levelName
end

return checkAccess
