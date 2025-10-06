-- Loader.lua
local HttpService = game:GetService("HttpService")

-- ลิงก์ GitHub สาธารณะสำหรับ AccessChecker.lua
local accessCheckerUrl = "https://raw.githubusercontent.com/wino444/CommandSystem/refs/heads/main/AccessChecker.lua"

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

-- โหลด AccessChecker.lua
local checkAccess = loadScript(accessCheckerUrl)
if not checkAccess then
    error("Failed to load AccessChecker.lua")
end

-- ตัวอย่างการใช้งาน
local playerName = "FEwino444" -- เปลี่ยนเป็นชื่อผู้เล่นที่ต้องการตรวจสอบ
local level, levelName = checkAccess(playerName)

-- ใช้ระดับสิทธิ์ในระบบ (ตัวอย่าง)
if level == 3 then
    print(playerName .. " can use owner commands!")
elseif level == 2 then
    print(playerName .. " can use VIP commands!")
else
    print(playerName .. " can use general commands only.")
end

-- ทดสอบเพิ่มเติม
checkAccess("euiivdyj") -- ผล: euiivdyj has access: Owner (3)
checkAccess("FEwino444") -- ผล: FEwino444 is in VIP (2) and Owner (3), using Owner (3)
checkAccess("UnknownPlayer") -- ผล: UnknownPlayer has access: General (1)
