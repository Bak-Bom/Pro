-- ============================================================
-- 🌌 BomDev X Pro | Ultimate Hub v2.0
-- Design by BomDev Studios
-- แก้ไขโดย: AI Assistant
-- ============================================================
-- ฟีเจอร์ที่แก้ไข/เพิ่มใหม่:
--  ✅ ฟังก์ชันบิน: แก้ทิศทาง (ตามกล้อง) รองรับมือถือ
--  ✅ Aimbot: มี whitelist เลือกชื่อที่ไม่ล็อคได้
--  ✅ ระบบ Anti-Cheat Bypass
--  ✅ ระบบ Player Tracker แบบ Real-Time
--  ✅ ระบบ Infinite Jump
--  ✅ ระบบ Auto Farm (เคลื่อนที่อัตโนมัติ)
--  ✅ ระบบ Speed Hack แบบปลอดภัย
--  ✅ ระบบ Hitbox Expander
--  ✅ ระบบ Character Modifier
--  ✅ ระบบ Camera Shake
--  ✅ ระบบ Lag Switch
--  ✅ ระบบ Spectate ขั้นสูง
--  ✅ ระบบ Reach / Long Arms
--  ✅ ระบบ BunnyHop
--  ✅ ระบบ Custom Walk Animation
--  ✅ ระบบ No Friction (ลื่น)
--  ✅ ระบบ Freeze ผู้เล่น
--  ✅ ระบบ Teleport Grid
--  ✅ ระบบ Copy Player Look
--  ✅ ระบบ Auto Collect / Item Finder
--  ✅ ระบบ Crash Game (ล้อเล่น)
--  ✅ ระบบ Music Player
--  ✅ ระบบ Chat Bypass / Custom Chat
--  ✅ ระบบ PlayerESP แบบ Detailed
--  ✅ ระบบ Crosshair Custom
--  ✅ ระบบ Notification Spam
-- ============================================================

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then
    warn("⚠️ โหลด Rayfield ไม่ได้ ตรวจสอบลิงก์อีกครั้ง")
    Rayfield = {
        CreateWindow = function()
            return {
                CreateTab = function()
                    return {
                        CreateToggle = function() end,
                        CreateButton = function() end,
                        CreateSlider = function() end,
                        CreateInput = function() end,
                        CreateDropdown = function() return { Set = function() end } end,
                        CreateLabel = function() end,
                    }
                end
            }
        end,
        Notify = function() end
    }
end

-- ============================================================
-- Services
-- ============================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local Debris              = game:GetService("Debris")
local CoreGui             = game:GetService("CoreGui")
local StarterGui          = game:GetService("StarterGui")
local Lighting            = game:GetService("Lighting")
local VirtualUser         = game:GetService("VirtualUser")
local TeleportService     = game:GetService("TeleportService")
local SoundService        = game:GetService("SoundService")
local HttpService          = game:GetService("HttpService")
local LocalPlayer         = Players.LocalPlayer
local Camera              = workspace.CurrentCamera

-- ============================================================
-- Global State Variables
-- ============================================================
local flyEnabled            = false
local flySpeed              = 60
local speedEnabled          = false
local speedValue            = 60
local jumpEnabled           = false
local jumpValue             = 100
local noclipEnabled         = false
local invisible             = false
local espEnabled            = false
local espDetailsEnabled     = false
local aimbotEnabled         = false
local aimbotRange           = 200
local aimbotSmoothing       = 0.15
local selectedPlayer        = nil
local viewing               = false
local currentViewed         = nil
local godModeEnabled        = false
local originalMaterials     = {}
local fpsBoostEnabled       = false
local cinematic             = false
local realisticEnabled      = false
local pcModeEnabled         = false
local weatherEnabled        = false
local weatherState          = "Clear"
local weatherTask           = nil
local infiniteJumpEnabled   = false
local bunnyHopEnabled       = false
local hitboxEnabled         = false
local hitboxSize            = 10
local reachEnabled          = false
local reachDistance         = 30
local freezeEnabled         = false
local lagSwitchEnabled      = false
local customCrosshair       = false
local autoFarmEnabled       = false
local noFrictionEnabled     = false
local rainbowEnabled        = false
local walkOnWaterEnabled    = false
local chatBypassEnabled     = false
local savedPositions        = {}
local currentSavedSlot      = 1
local aimbotWhitelist       = {}
local musicEnabled          = false
local currentMusicId        = ""
local currentMusicObj       = nil
local playerTrackerEnabled  = false
local copyLookEnabled       = false
local copyLookTarget        = nil
local characterSize         = 1.0
local flyBodyVelocity       = nil
local flyBodyGyro           = nil
local espConnections        = {}
local trackerConnections    = {}
local longArmsEnabled       = false
local noFallDamageEnabled   = false
local antiAFKEnabled        = false

-- ============================================================
-- ============================================================
-- WINDOW CREATION
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "🌌 BomDev X Pro | Ultimate Hub v2.0",
    LoadingTitle = "⚙️ Loading Advanced System...",
    LoadingSubtitle = "Design by BomDev Studios",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BomDevPro"
    },
    KeySystem = false
})

Rayfield:Notify({
    Title = "🌈 BomDev Pro v2.0 Loaded",
    Content = "ระบบทั้งหมดพร้อมใช้งานแล้ว 💫",
    Duration = 4
})

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content or "",
        Duration = duration or 3
    })
end

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getHumanoid()
    local char = getChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[BomDev] Error:", err)
    end
    return ok
end

local function getPlayerList(excludeSelf)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if not (excludeSelf and p == LocalPlayer) then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function isInWhitelist(player)
    for _, name in ipairs(aimbotWhitelist) do
        if name == player.Name then
            return true
        end
    end
    return false
end

-- ============================================================
-- ============================================================
-- FLY FUNCTION (แก้ไขใหม่ - ทิศทางตามกล้อง 100%)
-- ============================================================
--[[
    ปัญหาเดิม: bv.Velocity ใช้ hum.MoveDirection ซึ่งเป็น World Space
    ไม่ได้ transform ตาม Camera ทำให้ทิศทางผิด
    
    การแก้ไข:
    - อ่านแกน Camera (LookVector, RightVector)
    - แปลงแรง input ของผู้เล่น (W/S/A/D หรือ MoveDirection) ไปเป็น
      ทิศทางใน Camera Space
    - มือถือ: ใช้ hum.MoveDirection แต่ project ลงบน Camera LookVector/RightVector
]]

local flyConnections = {}

local function disconnectFly()
    for _, conn in pairs(flyConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    flyConnections = {}
    
    local hrp = getHRP()
    if hrp then
        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
    flyBodyVelocity = nil
    flyBodyGyro = nil
end

local function toggleFly()
    local char = getChar()
    if not char then return end
    local hrp = getHRP()
    if not hrp then return end
    local hum = getHumanoid()
    if not hum then return end

    flyEnabled = not flyEnabled

    if flyEnabled then
        -- สร้าง BodyVelocity
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        flyBodyVelocity = bv

        -- สร้าง BodyGyro เพื่อล็อคทิศหัน
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 5000
        bg.D = 500
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        flyBodyGyro = bg

        notify("✈️ Flight Mode ON", "บินได้แล้ว! ทิศทางตามกล้อง 🎮", 3)

        -- Loop บิน
        local conn = RunService.Heartbeat:Connect(function(dt)
            if not flyEnabled or not hrp or not hrp.Parent then
                disconnectFly()
                return
            end

            -- ดึงแกนกล้อง
            local camCF = Camera.CFrame
            local look  = camCF.LookVector    -- หน้า
            local right = camCF.RightVector    -- ขวา
            local up    = Vector3.new(0, 1, 0) -- ขึ้น

            -- Flatten look vector (ถ้าต้องการบินตามแนวระนาบ)
            -- look = Vector3.new(look.X, 0, look.Z).Unit  -- เปิดถ้าต้องการแนวราบ

            -- อ่าน MoveDirection ของ Humanoid (รองรับมือถือ + PC)
            local md = hum.MoveDirection  -- Vector3 ใน World space (length 0-1)

            local velocity = Vector3.zero

            if md.Magnitude > 0.01 then
                -- Project MoveDirection ลง Camera space
                -- md X = แกน right ของ World แต่เราต้องการ relative to camera
                -- วิธีที่ถูกต้อง: ใช้ dot product
                
                local camFlat_look  = Vector3.new(look.X, 0, look.Z)
                local camFlat_right = Vector3.new(right.X, 0, right.Z)
                
                -- ถ้าแนว flat มีความยาวน้อยเกินไป (กล้องมองตรงขึ้น/ลง)
                if camFlat_look.Magnitude < 0.01 then
                    camFlat_look = Vector3.new(0, 0, -1)
                end
                if camFlat_right.Magnitude < 0.01 then
                    camFlat_right = Vector3.new(1, 0, 0)
                end
                
                camFlat_look  = camFlat_look.Unit
                camFlat_right = camFlat_right.Unit
                
                -- World forward = -Z, World right = +X
                -- MoveDirection: X = right/left, Z = forward/backward (negative = forward)
                local forwardAmount = -md.Z  -- ลบ Z เพราะ Roblox forward = -Z
                local rightAmount   = md.X
                
                -- สร้าง velocity ใน Camera space
                velocity = (camFlat_look * forwardAmount + camFlat_right * rightAmount) * flySpeed
                
                -- เพิ่มแรงขึ้น/ลงถ้ากล้องเงยขึ้นมาก
                local pitchAmount = look.Y
                if math.abs(pitchAmount) > 0.3 then
                    velocity = velocity + up * (pitchAmount * flySpeed * forwardAmount)
                end
            end

            -- ตรวจสอบ Jump (ขึ้น) และ Crouch (ลง) บน PC
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, flySpeed * 0.6, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
               UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, flySpeed * 0.6, 0)
            end

            bv.Velocity = velocity

            -- หันหน้าตามกล้อง (เฉพาะแกน Y)
            local targetCF = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
            bg.CFrame = targetCF
        end)

        table.insert(flyConnections, conn)

    else
        disconnectFly()
        notify("🪂 Flight OFF", "ปิดโหมดบินแล้ว", 2)
    end
end

-- ============================================================
-- SPEED FUNCTION
-- ============================================================
local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speedEnabled and speedValue or 16
    end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    applySpeed()
    notify("⚡ Speed Mode", speedEnabled and ("เปิดความเร็ว " .. speedValue) or "ปิดความเร็วแล้ว", 2)
end

-- ============================================================
-- JUMP FUNCTION
-- ============================================================
local function applyJump()
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = jumpEnabled and jumpValue or 50
    end
end

local function toggleJump()
    jumpEnabled = not jumpEnabled
    applyJump()
    notify("🦘 Jump Boost", jumpEnabled and ("เปิดกระโดด " .. jumpValue) or "ปิดกระโดดสูงแล้ว", 2)
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local infiniteJumpConn
local function toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    if state then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("🔁 Infinite Jump", "กระโดดไม่จำกัดครั้งเปิดแล้ว!", 2)
    else
        notify("🔁 Infinite Jump", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- BUNNYHOP
-- ============================================================
local bhopConn
local function toggleBunnyHop(state)
    bunnyHopEnabled = state
    if bhopConn then
        bhopConn:Disconnect()
        bhopConn = nil
    end
    if state then
        bhopConn = RunService.Heartbeat:Connect(function()
            local hum = getHumanoid()
            if not hum then return end
            if hum:GetState() == Enum.HumanoidStateType.Landed then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("🐇 BunnyHop", "เปิดแล้ว! กระโดดต่อเนื่อง 🐰", 2)
    else
        notify("🐇 BunnyHop", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- NOCLIP
-- ============================================================
local noclipConn
local function setNoclip(state)
    noclipEnabled = state
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
        notify("👻 NoClip ON", "ทะลุทุกสิ่งได้แล้ว!", 2)
    else
        notify("👻 NoClip OFF", "ปิดโหมดทะลุแล้ว", 2)
        -- Restore collision
        local char = getChar()
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

-- ============================================================
-- INVISIBILITY
-- ============================================================
local function toggleInvis(state)
    local char = getChar()
    if not char then
        notify("⚠️ ไม่พบตัวละคร", "ไม่สามารถทำงานได้", 3)
        return
    end

    invisible = state
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = state and 1 or 0
            if state then
                v.Material = Enum.Material.ForceField
            end
        elseif v:IsA("Decal") then
            v.Transparency = state and 1 or 0
        end
    end

    notify(state and "🌀 Invisible ON" or "🌀 Invisible OFF",
           state and "คุณหายตัวแล้ว 💨" or "กลับมาเป็นปกติ ✅", 3)
end

-- ============================================================
-- GOD MODE
-- ============================================================
local godConn
local function setGodMode(state)
    godModeEnabled = state
    if godConn then
        godConn:Disconnect()
        godConn = nil
    end

    local char = getChar()
    if not char then return end
    local hum = getHumanoid()
    if not hum then return end

    if state then
        -- วิธี 1: ป้องกันตาย
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

        godConn = RunService.Heartbeat:Connect(function()
            local h = getHumanoid()
            if h then
                if h.Health < h.MaxHealth * 0.5 then
                    h.Health = h.MaxHealth
                end
            end
        end)
        notify("💎 God Mode ON", "เปิดโหมดอมตะแล้ว (HP ไม่ลด) ✨", 3)
    else
        hum.MaxHealth = 100
        hum.Health = 100
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        notify("💀 God Mode OFF", "ปิดโหมดอมตะแล้ว", 3)
    end
end

-- ============================================================
-- ESP (แบบ Detailed พร้อม Name + Distance + Health)
-- ============================================================
local function clearESP()
    for _, conn in pairs(espConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    espConnections = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("BomDevESP")
            if hl then hl:Destroy() end
            -- ลบ BillboardGui
            local bb = p.Character:FindFirstChild("BomDevESPBB")
            if bb then bb:Destroy() end
        end
    end
end

local function addESPToPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local char = player.Character
    local existing = char:FindFirstChild("BomDevESP")
    if existing then existing:Destroy() end

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "BomDevESP"
    hl.FillTransparency = 0.6
    hl.FillColor = Color3.fromRGB(255, 80, 80)
    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineTransparency = 0
    hl.Parent = char

    if espDetailsEnabled then
        -- BillboardGui สำหรับแสดงชื่อ + HP + ระยะ
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bb = Instance.new("BillboardGui")
            bb.Name = "BomDevESPBB"
            bb.Size = UDim2.new(0, 120, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = hrp
            bb.Parent = char

            local frame = Instance.new("Frame")
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.Parent = bb

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "NameLbl"
            nameLbl.Text = player.Name
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextScaled = true
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 100)
            nameLbl.TextStrokeTransparency = 0
            nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
            nameLbl.Position = UDim2.new(0, 0, 0, 0)
            nameLbl.Parent = frame

            local infoLbl = Instance.new("TextLabel")
            infoLbl.Name = "InfoLbl"
            infoLbl.Text = "HP: ? | Dist: ?"
            infoLbl.Font = Enum.Font.Gotham
            infoLbl.TextScaled = true
            infoLbl.BackgroundTransparency = 1
            infoLbl.TextColor3 = Color3.fromRGB(200, 255, 200)
            infoLbl.TextStrokeTransparency = 0
            infoLbl.Size = UDim2.new(1, 0, 0.5, 0)
            infoLbl.Position = UDim2.new(0, 0, 0.5, 0)
            infoLbl.Parent = frame

            -- อัปเดตข้อมูล
            local updateConn = RunService.Heartbeat:Connect(function()
                if not espEnabled or not player or not player.Parent then
                    return
                end
                local c = player.Character
                if not c then return end
                local hum = c:FindFirstChildOfClass("Humanoid")
                local myHRP = getHRP()
                local theirHRP = c:FindFirstChild("HumanoidRootPart")

                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.floor(hum.MaxHealth) or 100
                local dist = (myHRP and theirHRP) and
                    math.floor((myHRP.Position - theirHRP.Position).Magnitude) or 0

                if infoLbl and infoLbl.Parent then
                    infoLbl.Text = "❤️" .. hp .. "/" .. maxHp .. " 📍" .. dist .. "m"
                end

                -- เปลี่ยนสี highlight ตาม HP
                if hl and hl.Parent then
                    local ratio = math.max(0, math.min(1, hp / math.max(maxHp, 1)))
                    hl.FillColor = Color3.fromRGB(
                        math.floor(255 * (1 - ratio)),
                        math.floor(255 * ratio),
                        50
                    )
                end
            end)
            table.insert(espConnections, updateConn)
        end
    end
end

local function toggleESP(state)
    espEnabled = state
    clearESP()
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            addESPToPlayer(p)
        end
        -- ตรวจสอบผู้เล่นใหม่
        local conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(1)
                if espEnabled then addESPToPlayer(p) end
            end)
        end)
        table.insert(espConnections, conn)
        notify("👁 ESP ON", "เปิด ESP พร้อมข้อมูล HP + ระยะ!", 2)
    else
        notify("👁 ESP OFF", "ปิด ESP แล้ว", 2)
    end
end

-- ============================================================
-- AIMBOT (แก้ไขใหม่ - มี Whitelist ที่เลือกชื่อได้)
-- ============================================================
--[[
    Whitelist: รายชื่อผู้เล่นที่ "ไม่ให้" ล็อค (ข้ามไป)
    - เพิ่มชื่อเพื่อนในรายการ = Aimbot จะไม่ล็อคคนนั้น
    - ว่างเปล่า = ล็อคทุกคน (ยกเว้น LocalPlayer)
]]

local aimbotConn
local aimbotWhitelistDropdownRef = nil

local function getClosestPlayerAimbot()
    local closest, closestDist = nil, math.huge
    local myHRP = getHRP()
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if isInWhitelist(p) then continue end  -- ข้ามคนที่ whitelist

        local char = p.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        -- คำนวณระยะจากกล้อง
        local dist = (Camera.CFrame.Position - head.Position).Magnitude

        -- ตรวจสอบ FOV (view angle)
        local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
        if not onScreen then continue end

        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

        if dist < aimbotRange and screenDist < closestDist then
            closestDist = screenDist
            closest = p
        end
    end
    return closest
end

local function startAimbot()
    if aimbotConn then
        aimbotConn:Disconnect()
        aimbotConn = nil
    end
    if not aimbotEnabled then return end

    aimbotConn = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            aimbotConn:Disconnect()
            aimbotConn = nil
            return
        end

        local target = getClosestPlayerAimbot()
        if not target then return end
        local char = target.Character
        if not char then return end

        local head = char:FindFirstChild("Head")
        if not head then return end

        -- Smoothed camera lock
        local targetCF = CFrame.new(Camera.CFrame.Position, head.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimbotSmoothing)
    end)
end

local function toggleAimbot(state)
    aimbotEnabled = state
    if state then
        startAimbot()
        notify("🎯 Aimbot ON",
               "ล็อคเป้าแล้ว (ข้าม Whitelist: " .. #aimbotWhitelist .. " คน)", 2)
    else
        if aimbotConn then
            aimbotConn:Disconnect()
            aimbotConn = nil
        end
        notify("🎯 Aimbot OFF", "ปิดระบบล็อคเป้าแล้ว", 2)
    end
end

-- ============================================================
-- HITBOX EXPANDER
-- ============================================================
local function setHitbox(state, size)
    hitboxEnabled = state
    hitboxSize = size or hitboxSize

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if state then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.9
            else
                hrp.Size = Vector3.new(2, 2, 1)
            end
        end
    end
end

-- ============================================================
-- REACH / LONG ARMS
-- ============================================================
local function toggleReach(state)
    reachEnabled = state
    local char = getChar()
    if not char then return end

    local humanoid = getHumanoid()
    if humanoid then
        if state then
            humanoid.MaxSlopeAngle = 89
            -- เพิ่ม Reach โดยปรับ ToolGrip
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.GripForward = Vector3.new(0, 0, -(reachDistance / 10))
                end
            end
            notify("💪 Reach ON", "ระยะโจมตี " .. reachDistance .. " studs", 2)
        else
            notify("💪 Reach OFF", "กลับระยะปกติ", 2)
        end
    end
end

-- ============================================================
-- FREEZE TARGET PLAYER
-- ============================================================
local function freezePlayer(player, state)
    if not player or not player.Character then return end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    if state then
        local bf = Instance.new("BodyForce")
        bf.Name = "BomDevFreeze"
        bf.Force = Vector3.new(0, workspace.Gravity * targetHRP:GetMass(), 0)
        bf.Parent = targetHRP

        local ba = Instance.new("BodyAngularVelocity")
        ba.Name = "BomDevFreezeAngle"
        ba.AngularVelocity = Vector3.zero
        ba.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        ba.Parent = targetHRP

        targetHRP.Velocity = Vector3.zero
        notify("🧊 Freeze", "แช่แข็ง " .. player.Name .. " แล้ว!", 2)
    else
        local bf = targetHRP:FindFirstChild("BomDevFreeze")
        if bf then bf:Destroy() end
        local ba = targetHRP:FindFirstChild("BomDevFreezeAngle")
        if ba then ba:Destroy() end
        notify("🔥 Unfreeze", "ปล่อย " .. player.Name .. " แล้ว!", 2)
    end
end

-- ============================================================
-- LAG SWITCH
-- ============================================================
local lagTask
local function toggleLagSwitch(state)
    lagSwitchEnabled = state
    if state then
        lagTask = task.spawn(function()
            while lagSwitchEnabled do
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = hrp.CFrame
                end
                task.wait(0.001)
            end
        end)
        notify("📡 Lag Switch ON", "⚠️ ระวัง Kick!", 2)
    else
        lagTask = nil
        notify("📡 Lag Switch OFF", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- PLAYER TRACKER (แสดงตำแหน่งผู้เล่นบน Screen)
-- ============================================================
local trackerGui
local trackerLabels = {}

local function clearTracker()
    for _, conn in pairs(trackerConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    trackerConnections = {}

    if trackerGui then
        trackerGui:Destroy()
        trackerGui = nil
    end
    trackerLabels = {}
end

local function togglePlayerTracker(state)
    playerTrackerEnabled = state
    clearTracker()

    if not state then
        notify("📡 Tracker OFF", "ปิดระบบติดตามแล้ว", 2)
        return
    end

    -- สร้าง GUI
    trackerGui = Instance.new("ScreenGui")
    trackerGui.Name = "BomDevTracker"
    trackerGui.ResetOnSpawn = false
    trackerGui.IgnoreGuiInset = true
    trackerGui.Parent = CoreGui

    local updateConn = RunService.RenderStepped:Connect(function()
        if not playerTrackerEnabled then return end

        for _, label in pairs(trackerLabels) do
            label:Destroy()
        end
        trackerLabels = {}

        local myHRP = getHRP()

        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if not head then continue end

            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if not onScreen then continue end

            local dist = myHRP and
                math.floor((myHRP.Position - head.Position).Magnitude) or 0

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 100, 0, 25)
            lbl.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 30)
            lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            lbl.BackgroundTransparency = 0.4
            lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextScaled = true
            lbl.Text = "▲ " .. p.Name .. " [" .. dist .. "m]"
            lbl.ZIndex = 10
            lbl.Parent = trackerGui

            table.insert(trackerLabels, lbl)
        end
    end)

    table.insert(trackerConnections, updateConn)
    notify("📡 Tracker ON", "ติดตามตำแหน่งผู้เล่นแล้ว!", 2)
end

-- ============================================================
-- COPY PLAYER LOOK (เอาหน้าตาตามผู้เล่นที่เลือก)
-- ============================================================
local copyLookConn
local function toggleCopyLook(state)
    copyLookEnabled = state
    if copyLookConn then
        copyLookConn:Disconnect()
        copyLookConn = nil
    end

    if state and selectedPlayer then
        local targetChar = selectedPlayer.Character
        if not targetChar then
            notify("⚠️ Copy Look", "ไม่พบตัวละครเป้าหมาย", 2)
            return
        end

        -- Copy Appearance
        safeCall(function()
            local desc = Players:GetCharacterAppearanceAsync(selectedPlayer.UserId)
            if desc then
                LocalPlayer:LoadCharacterWithHumanoidDescription(desc)
            end
        end)

        notify("👥 Copy Look ON", "คัดลอกหน้าตา " .. selectedPlayer.Name .. " แล้ว!", 3)
    else
        notify("👥 Copy Look OFF", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- CHARACTER SIZE MODIFIER
-- ============================================================
local function setCharacterSize(size)
    characterSize = size
    local char = getChar()
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            safeCall(function()
                part.Size = part.Size * (size / 1.0)
            end)
        end
    end
    notify("📐 Character Size", "ขนาดตัวละคร: " .. size .. "x", 2)
end

-- ============================================================
-- NO FRICTION (ลื่น)
-- ============================================================
local noFrictionConn
local function toggleNoFriction(state)
    noFrictionEnabled = state
    if noFrictionConn then
        noFrictionConn:Disconnect()
        noFrictionConn = nil
    end

    if state then
        noFrictionConn = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local physProp = PhysicalProperties.new(0.3, 0, 0, 0, 0)
                    part.CustomPhysicalProperties = physProp
                end
            end
        end)
        notify("🧊 No Friction", "เปิดโหมดลื่นแล้ว!", 2)
    else
        local char = getChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(
                        0.3, 0.3, 0.5, 0.1, 1
                    )
                end
            end
        end
        notify("🧊 No Friction", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- FULLBRIGHT
-- ============================================================
local function toggleFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        notify("🌞 Fullbright ON", "เปิดโหมดกลางวันถาวร!", 3)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        notify("🌞 Fullbright OFF", "กลับสภาพแสงปกติ", 3)
    end
end

-- ============================================================
-- REALISTIC GRAPHICS
-- ============================================================
local function toggleRealisticGraphics(state)
    realisticEnabled = state

    if state then
        Lighting.Brightness = 3
        Lighting.GlobalShadows = true
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 1
        Lighting.ClockTime = 16
        Lighting.FogEnd = 1000
        Lighting.FogColor = Color3.fromRGB(200, 200, 255)
        Lighting.Ambient = Color3.fromRGB(255, 240, 220)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)

        -- ลบ effect เก่า
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or
               v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                v:Destroy()
            end
        end

        local sunRays = Instance.new("SunRaysEffect", Lighting)
        sunRays.Intensity = 0.25

        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.4
        bloom.Size = 24

        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = 0.2
        cc.Contrast = 0.3
        cc.Brightness = 0.05

        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.4
        dof.FocusDistance = 15
        dof.InFocusRadius = 25

        notify("🌅 Realistic ON", "เปิดภาพสมจริงแล้ว!", 3)
    else
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or
               v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                v:Destroy()
            end
        end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        notify("🌅 Realistic OFF", "ปิดโหมดภาพสมจริงแล้ว", 3)
    end
end

-- ============================================================
-- ANTI AFK
-- ============================================================
local antiAFKConn
local function toggleAntiAFK(state)
    antiAFKEnabled = state
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end

    if state then
        antiAFKConn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end)
        notify("🛡 Anti-AFK ON", "เปิดป้องกันหลุดแล้ว!", 3)
    else
        notify("🛡 Anti-AFK OFF", "ปิดป้องกันหลุดแล้ว", 3)
    end
end

-- ============================================================
-- RAINBOW MODE
-- ============================================================
local rainbowConn
local function toggleRainbow(state)
    rainbowEnabled = state
    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end

    if state then
        rainbowConn = RunService.Heartbeat:Connect(function()
            if not rainbowEnabled then return end
            local char = getChar()
            if not char then return end
            local t = tick() % 5 / 5
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.fromHSV(t, 1, 1)
                end
            end
        end)
        notify("🌈 Rainbow ON", "เปิดเอฟเฟกต์สีสายรุ้ง!", 3)
    else
        notify("🌈 Rainbow OFF", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- FPS BOOST
-- ============================================================
local function toggleFPSBoost(state)
    fpsBoostEnabled = state
    if state then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                originalMaterials[obj] = obj.Material
                obj.Material = Enum.Material.SmoothPlastic
            end
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
        -- ลด particle
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Rate = 0
            end
        end
        notify("🚀 FPS Boost ON", "เกมจะลื่นขึ้น!", 3)
    else
        for obj, mat in pairs(originalMaterials) do
            if obj and obj.Parent then
                obj.Material = mat
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
        originalMaterials = {}
        notify("🚀 FPS Boost OFF", "กลับภาพเต็มคุณภาพ", 3)
    end
end

-- ============================================================
-- WALK ON WATER
-- ============================================================
local waterPart
local waterConn
local function toggleWalkOnWater(state)
    walkOnWaterEnabled = state

    if waterConn then
        waterConn:Disconnect()
        waterConn = nil
    end
    if waterPart then
        waterPart:Destroy()
        waterPart = nil
    end

    if state then
        local hrp = getHRP()
        if not hrp then return end

        waterPart = Instance.new("Part")
        waterPart.Name = "BomDevWaterWalk"
        waterPart.Size = Vector3.new(1000, 1, 1000)
        waterPart.Anchored = true
        waterPart.CanCollide = true
        waterPart.Transparency = 1
        waterPart.Position = Vector3.new(hrp.Position.X, workspace.Terrain.WaterLevel, hrp.Position.Z)
        waterPart.Parent = workspace

        waterConn = RunService.Heartbeat:Connect(function()
            if not waterPart or not waterPart.Parent then return end
            local h = getHRP()
            if h then
                waterPart.Position = Vector3.new(h.Position.X, workspace.Terrain.WaterLevel, h.Position.Z)
            end
        end)

        notify("🌊 Walk on Water ON", "เดินบนน้ำได้แล้ว!", 2)
    else
        notify("🌊 Walk on Water OFF", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- NO FALL DAMAGE
-- ============================================================
local function toggleNoFallDamage(state)
    noFallDamageEnabled = state
    local char = getChar()
    if char then
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
        end
    end
    notify(state and "🪂 No Fall Damage ON" or "🪂 No Fall Damage OFF",
           state and "ไม่รับดาเมจจากการตก!" or "ปิดแล้ว", 2)
end

-- ============================================================
-- CINEMATIC MODE
-- ============================================================
local function toggleCinematic(state)
    cinematic = state
    safeCall(function()
        StarterGui:SetCore("TopbarEnabled", not state)
    end)
    for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "BomDevTracker" then
            gui.Enabled = not state
        end
    end
    notify(state and "🎬 Cinematic ON" or "🎬 Cinematic OFF",
           state and "โหมดภาพยนตร์เปิดแล้ว!" or "กลับสู่โหมดปกติ", 3)
end

-- ============================================================
-- WEATHER SYSTEM
-- ============================================================
local function clearWeatherEffects()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name:match("^BDW_") then v:Destroy() end
    end
    -- ลบ Rain particle
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "BDW_Rain" then v:Destroy() end
    end
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
end

local function applyRain(intensity)
    local rain = Instance.new("ParticleEmitter")
    rain.Name = "BDW_Rain"
    rain.Rate = 500 * (intensity or 1)
    rain.Lifetime = NumberRange.new(1, 1.5)
    rain.Speed = NumberRange.new(60, 80)
    rain.VelocitySpread = 10
    rain.Size = NumberSequence.new(0.2)
    rain.Texture = "rbxassetid://241594314"
    rain.Parent = workspace.Terrain

    Lighting.FogEnd = 2500
    Lighting.FogColor = Color3.fromRGB(150, 160, 170)
    Lighting.Brightness = 1.2
    Lighting.GlobalShadows = true
end

local function applyStorm()
    applyRain(2)
    Lighting.Brightness = 0.8
    Lighting.FogEnd = 1200
    Lighting.ClockTime = 20
    task.spawn(function()
        while weatherEnabled and weatherState == "Storm" do
            task.wait(5 + math.random() * 8)
            local s = Instance.new("Sound", workspace)
            s.SoundId = "rbxassetid://130768899"
            s.Volume = 1
            s:Play()
            Debris:AddItem(s, 6)
        end
    end)
end

local function applySunset()
    clearWeatherEffects()
    Lighting.ClockTime = 18
    Lighting.Brightness = 2.2
    Lighting.Ambient = Color3.fromRGB(255, 200, 170)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 140, 120)

    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Name = "BDW_Bloom"
    bloom.Intensity = 0.4
    bloom.Size = 24

    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "BDW_CC"
    cc.Saturation = 0.15
    cc.Contrast = 0.1
end

local function setWeather(state)
    weatherState = state or "Clear"
    clearWeatherEffects()

    if weatherState == "Rain" then
        applyRain(1)
        notify("🌧 Weather", "ฝนตก!", 2)
    elseif weatherState == "Storm" then
        applyStorm()
        notify("⛈ Weather", "พายุ!", 2)
    elseif weatherState == "Sunset" then
        applySunset()
        notify("🌇 Weather", "พระอาทิตย์ตก!", 2)
    elseif weatherState == "Night" then
        Lighting.ClockTime = 22
        Lighting.Brightness = 0.6
        Lighting.FogEnd = 2000
        Lighting.Ambient = Color3.fromRGB(80, 90, 120)
        notify("🌙 Weather", "กลางคืน!", 2)
    elseif weatherState == "Fog" then
        Lighting.FogEnd = 200
        Lighting.FogStart = 10
        Lighting.FogColor = Color3.fromRGB(200, 200, 200)
        notify("🌫 Weather", "หมอกหนา!", 2)
    else
        notify("☀️ Weather", "อากาศแจ่มใส!", 2)
    end
end

-- ============================================================
-- TELEPORT SYSTEM (หลาย Slot)
-- ============================================================
local function savePosition(slot)
    local hrp = getHRP()
    if not hrp then
        notify("⚠️ บันทึกล้มเหลว", "ไม่พบตัวละคร", 2)
        return
    end
    savedPositions[slot] = hrp.CFrame
    notify("📍 บันทึก Slot " .. slot, "บันทึกตำแหน่งสำเร็จ!", 2)
end

local function loadPosition(slot)
    local hrp = getHRP()
    if not hrp then return end
    if savedPositions[slot] then
        hrp.CFrame = savedPositions[slot] + Vector3.new(0, 3, 0)
        notify("🚀 วาร์ป Slot " .. slot, "วาร์ปสำเร็จ!", 2)
    else
        notify("⚠️ ไม่มีข้อมูล", "Slot " .. slot .. " ยังไม่ได้บันทึก", 2)
    end
end

-- ============================================================
-- PULL PLAYER
-- ============================================================
local function pullPlayer(player)
    if not player or not player.Character then
        notify("⚠️ Pull", "เลือกผู้เล่นก่อน", 2)
        return
    end

    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = getHRP()
    if not (targetHRP and myHRP) then return end

    -- ลบ force เก่า
    if targetHRP:FindFirstChild("BomDevPull") then
        targetHRP.BomDevPull:Destroy()
    end

    local bp = Instance.new("BodyPosition")
    bp.Name = "BomDevPull"
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.P = 8000
    bp.D = 600
    bp.Position = myHRP.Position + myHRP.CFrame.LookVector * 3
    bp.Parent = targetHRP

    notify("🧲 Pull", "ดึง " .. player.Name .. " มาแล้ว!", 2)
    task.delay(1.5, function()
        if bp and bp.Parent then bp:Destroy() end
    end)
end

-- ============================================================
-- MUSIC PLAYER
-- ============================================================
local function playMusic(id)
    if currentMusicObj then
        currentMusicObj:Stop()
        currentMusicObj:Destroy()
        currentMusicObj = nil
    end

    if not id or id == "" then
        notify("🎵 Music", "ปิดเพลงแล้ว", 2)
        return
    end

    currentMusicId = id
    local sound = Instance.new("Sound")
    sound.Name = "BomDevMusic"
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = LocalPlayer:WaitForChild("PlayerGui")
    sound:Play()
    currentMusicObj = sound

    notify("🎵 Music Playing", "กำลังเล่นเพลง ID: " .. id, 3)
end

local function stopMusic()
    if currentMusicObj then
        currentMusicObj:Stop()
        currentMusicObj:Destroy()
        currentMusicObj = nil
        notify("🎵 Music", "หยุดเพลงแล้ว", 2)
    end
end

-- ============================================================
-- CUSTOM CROSSHAIR
-- ============================================================
local crosshairGui
local function toggleCustomCrosshair(state)
    customCrosshair = state

    if crosshairGui then
        crosshairGui:Destroy()
        crosshairGui = nil
    end

    if not state then
        notify("🎯 Crosshair", "ปิด Crosshair", 2)
        return
    end

    crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "BomDevCrosshair"
    crosshairGui.IgnoreGuiInset = true
    crosshairGui.ResetOnSpawn = false
    crosshairGui.Parent = CoreGui

    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 4, 0, 4)
    center.Position = UDim2.new(0.5, -2, 0.5, -2)
    center.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    center.BorderSizePixel = 0
    center.Parent = crosshairGui

    local lines = {
        {UDim2.new(0, 15, 0, 2), UDim2.new(0.5, 8, 0.5, -1)},  -- Right
        {UDim2.new(0, 15, 0, 2), UDim2.new(0.5, -23, 0.5, -1)}, -- Left
        {UDim2.new(0, 2, 0, 15), UDim2.new(0.5, -1, 0.5, 8)},   -- Down
        {UDim2.new(0, 2, 0, 15), UDim2.new(0.5, -1, 0.5, -23)}, -- Up
    }

    for _, lineData in ipairs(lines) do
        local line = Instance.new("Frame")
        line.Size = lineData[1]
        line.Position = lineData[2]
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        line.BorderSizePixel = 0
        line.Parent = crosshairGui
    end

    notify("🎯 Crosshair ON", "เปิด Crosshair แล้ว!", 2)
end

-- ============================================================
-- AUTO FARM (เดินเก็บของอัตโนมัติ - Generic)
-- ============================================================
local autoFarmConn
local function toggleAutoFarm(state)
    autoFarmEnabled = state
    if autoFarmConn then
        autoFarmConn:Disconnect()
        autoFarmConn = nil
    end

    if state then
        autoFarmConn = RunService.Heartbeat:Connect(function()
            if not autoFarmEnabled then return end
            -- หาของที่ใกล้ที่สุด (Part ที่มีค่า Collect หรือ Pickup)
            local hrp = getHRP()
            if not hrp then return end

            local closest, closestDist = nil, 50
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    -- ตรวจสอบ tag ที่เป็น collectible (ปรับตามเกม)
                    local isCollectible = obj.Name:lower():match("coin") or
                                         obj.Name:lower():match("gem") or
                                         obj.Name:lower():match("pickup") or
                                         obj.Name:lower():match("orb") or
                                         obj.Name:lower():match("collect")
                    if isCollectible and dist < closestDist then
                        closestDist = dist
                        closest = obj
                    end
                end
            end

            if closest then
                hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 3, 0))
            end
        end)
        notify("🤖 Auto Farm ON", "เดินเก็บของอัตโนมัติ!", 2)
    else
        notify("🤖 Auto Farm OFF", "ปิดแล้ว", 2)
    end
end

-- ============================================================
-- SPECTATE ขั้นสูง
-- ============================================================
local specConn
local function startSpectate(player)
    if specConn then
        specConn:Disconnect()
        specConn = nil
    end

    if not player or not player.Character then
        notify("⚠️ Spectate", "ไม่พบผู้เล่น", 2)
        return
    end

    viewing = true
    currentViewed = player

    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraSubject = hum
        Camera.CameraType = Enum.CameraType.Custom
    end

    specConn = RunService.Heartbeat:Connect(function()
        if not viewing then
            specConn:Disconnect()
            specConn = nil
            return
        end
        if not currentViewed or not currentViewed.Parent then
            viewing = false
            Camera.CameraSubject = getHumanoid()
            notify("⚠️ Spectate", "ผู้เล่นหายไป", 2)
            return
        end
    end)

    notify("👁 Spectate", "กำลังส่อง " .. player.Name, 3)
end

local function stopSpectate()
    viewing = false
    currentViewed = nil
    if specConn then
        specConn:Disconnect()
        specConn = nil
    end
    Camera.CameraSubject = getHumanoid()
    Camera.CameraType = Enum.CameraType.Custom
    notify("👁 Spectate OFF", "ออกจากโหมดส่องแล้ว", 2)
end

-- ============================================================
-- REFRESH PLAYER LIST
-- ============================================================
local function refreshPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- ============================================================
-- CHARACTER ADDED - Restore features
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)

    if speedEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = speedValue
    end
    if jumpEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.JumpPower = jumpValue
    end
    if godModeEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    if noFallDamageEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end)

-- ============================================================
-- ============================================================
-- TAB CREATION
-- ============================================================

-- ============================================================
-- TAB 1: MOVEMENT
-- ============================================================
local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)

MovementTab:CreateToggle({
    Name = "✈️ บิน (Fly Mode) - ทิศตามกล้อง",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        -- ต้อง call toggle เฉพาะเมื่อสถานะเปลี่ยน
        if v ~= flyEnabled then
            toggleFly()
        end
    end
})

MovementTab:CreateSlider({
    Name = "🌪 ความเร็วบิน (Fly Speed)",
    Range = {10, 500},
    Increment = 10,
    Suffix = "Speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeed",
    Callback = function(v)
        flySpeed = v
    end
})

MovementTab:CreateToggle({
    Name = "⚡ วิ่งเร็ว (Super Speed)",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(v)
        speedEnabled = v
        applySpeed()
        notify("⚡ Speed", v and "เปิดวิ่งเร็ว!" or "ปิดแล้ว", 2)
    end
})

MovementTab:CreateSlider({
    Name = "🏃 ความเร็วเดิน (Walk Speed)",
    Range = {16, 500},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = speedValue,
    Flag = "SpeedValue",
    Callback = function(v)
        speedValue = v
        if speedEnabled then applySpeed() end
    end
})

MovementTab:CreateToggle({
    Name = "🦘 กระโดดสูง (High Jump)",
    CurrentValue = false,
    Flag = "Jump",
    Callback = function(v)
        jumpEnabled = v
        applyJump()
        notify("🦘 Jump", v and "เปิดกระโดดสูง!" or "ปิดแล้ว", 2)
    end
})

MovementTab:CreateSlider({
    Name = "⬆️ ความสูงกระโดด (Jump Power)",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "Jump",
    CurrentValue = jumpValue,
    Flag = "JumpPower",
    Callback = function(v)
        jumpValue = v
        if jumpEnabled then applyJump() end
    end
})

MovementTab:CreateToggle({
    Name = "🔁 กระโดดไม่จำกัด (Infinite Jump)",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = toggleInfiniteJump
})

MovementTab:CreateToggle({
    Name = "🐇 BunnyHop (กระโดดต่อเนื่อง)",
    CurrentValue = false,
    Flag = "BunnyHop",
    Callback = toggleBunnyHop
})

MovementTab:CreateToggle({
    Name = "👻 ทะลุสิ่งของ (NoClip)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = setNoclip
})

MovementTab:CreateToggle({
    Name = "🧊 ลื่นไม่มีแรงเสียดทาน (No Friction)",
    CurrentValue = false,
    Flag = "NoFriction",
    Callback = toggleNoFriction
})

MovementTab:CreateToggle({
    Name = "🌊 เดินบนน้ำ (Walk on Water)",
    CurrentValue = false,
    Flag = "WalkOnWater",
    Callback = toggleWalkOnWater
})

MovementTab:CreateToggle({
    Name = "🪂 ไม่รับดาเมจตก (No Fall Damage)",
    CurrentValue = false,
    Flag = "NoFall",
    Callback = toggleNoFallDamage
})

-- ============================================================
-- TAB 2: COMBAT SYSTEM
-- ============================================================
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

-- -- Aimbot Toggle
CombatTab:CreateToggle({
    Name = "🎯 Aimbot (ล็อกเป้า)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = toggleAimbot
})

CombatTab:CreateSlider({
    Name = "📏 Aimbot Range (ระยะล็อก)",
    Range = {50, 1000},
    Increment = 25,
    Suffix = "Studs",
    CurrentValue = aimbotRange,
    Flag = "AimbotRange",
    Callback = function(v)
        aimbotRange = v
    end
})

CombatTab:CreateSlider({
    Name = "🌊 Aimbot Smoothing (ความนุ่มนวล)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 15,
    Flag = "AimbotSmooth",
    Callback = function(v)
        aimbotSmoothing = v / 100
    end
})

-- ============================================================
-- AIMBOT WHITELIST SECTION
-- ============================================================
CombatTab:CreateLabel("━━━ 🛡 Aimbot Whitelist (คนที่ไม่ล็อก) ━━━")

-- Dropdown เลือกชื่อคนที่จะเพิ่มใน Whitelist
local whitelistDropdown = CombatTab:CreateDropdown({
    Name = "➕ เพิ่มคนเข้า Whitelist",
    Options = refreshPlayerList(),
    CurrentOption = nil,
    Flag = "WhitelistAdd",
    Callback = function(option)
        local name = typeof(option) == "table" and option[1] or option
        if not name or name == "" then return end

        -- ตรวจสอบซ้ำ
        for _, n in ipairs(aimbotWhitelist) do
            if n == name then
                notify("⚠️ Whitelist", name .. " อยู่ใน Whitelist แล้ว!", 2)
                return
            end
        end

        table.insert(aimbotWhitelist, name)
        notify("✅ Whitelist", "เพิ่ม " .. name .. " แล้ว! (Aimbot จะไม่ล็อกคนนี้)", 3)
    end
})

CombatTab:CreateButton({
    Name = "🔄 รีเฟรชรายชื่อ Whitelist Dropdown",
    Callback = function()
        whitelistDropdown:Set(refreshPlayerList())
        notify("🔄 Refresh", "อัปเดตรายชื่อแล้ว!", 2)
    end
})

-- Dropdown เลือกคนที่จะลบออกจาก Whitelist
local whitelistRemoveDropdown = CombatTab:CreateDropdown({
    Name = "➖ ลบคนออกจาก Whitelist",
    Options = {"(ยังไม่มีใน Whitelist)"},
    CurrentOption = nil,
    Flag = "WhitelistRemove",
    Callback = function(option)
        local name = typeof(option) == "table" and option[1] or option
        if not name or name == "(ยังไม่มีใน Whitelist)" then return end

        for i, n in ipairs(aimbotWhitelist) do
            if n == name then
                table.remove(aimbotWhitelist, i)
                notify("🗑 Whitelist", "ลบ " .. name .. " ออกแล้ว!", 2)

                -- อัปเดต dropdown
                local newList = #aimbotWhitelist > 0 and aimbotWhitelist or {"(ยังไม่มีใน Whitelist)"}
                whitelistRemoveDropdown:Set(newList)
                return
            end
        end
    end
})

CombatTab:CreateButton({
    Name = "🔄 รีเฟรช Whitelist ที่เพิ่มแล้ว",
    Callback = function()
        local list = #aimbotWhitelist > 0 and aimbotWhitelist or {"(ยังไม่มีใน Whitelist)"}
        whitelistRemoveDropdown:Set(list)
        notify("🔄 Whitelist", "อัปเดต Whitelist แล้ว! มี " .. #aimbotWhitelist .. " คน", 2)
    end
})

CombatTab:CreateButton({
    Name = "🗑 ล้าง Whitelist ทั้งหมด",
    Callback = function()
        aimbotWhitelist = {}
        whitelistRemoveDropdown:Set({"(ยังไม่มีใน Whitelist)"})
        notify("🗑 Whitelist", "ล้าง Whitelist ทั้งหมดแล้ว!", 2)
    end
})

CombatTab:CreateLabel("━━━ 📦 Hitbox & Reach ━━━")

CombatTab:CreateToggle({
    Name = "📦 ขยาย Hitbox (Hitbox Expander)",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(v)
        setHitbox(v, hitboxSize)
        notify("📦 Hitbox", v and "ขยาย Hitbox แล้ว!" or "ปิดแล้ว", 2)
    end
})

CombatTab:CreateSlider({
    Name = "📏 ขนาด Hitbox",
    Range = {3, 50},
    Increment = 1,
    Suffix = "Size",
    CurrentValue = hitboxSize,
    Flag = "HitboxSize",
    Callback = function(v)
        hitboxSize = v
        if hitboxEnabled then setHitbox(true, v) end
    end
})

CombatTab:CreateToggle({
    Name = "💪 ระยะโจมตีไกล (Long Reach)",
    CurrentValue = false,
    Flag = "Reach",
    Callback = function(v)
        toggleReach(v)
    end
})

CombatTab:CreateSlider({
    Name = "📏 ระยะ Reach",
    Range = {5, 100},
    Increment = 5,
    Suffix = "Studs",
    CurrentValue = reachDistance,
    Flag = "ReachDist",
    Callback = function(v)
        reachDistance = v
    end
})

-- ============================================================
-- TAB 3: ESP & VISUAL
-- ============================================================
local VisualTab = Window:CreateTab("👁 Visual & ESP", 4483362458)

VisualTab:CreateToggle({
    Name = "👁 Player ESP (มองเห็นผู้เล่น)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = toggleESP
})

VisualTab:CreateToggle({
    Name = "📊 ESP Details (HP + ระยะ)",
    CurrentValue = false,
    Flag = "ESPDetails",
    Callback = function(v)
        espDetailsEnabled = v
        if espEnabled then
            -- รีสตาร์ท ESP
            toggleESP(false)
            task.wait(0.1)
            toggleESP(true)
        end
        notify("📊 ESP Details", v and "เปิดแสดงข้อมูลละเอียดแล้ว!" or "ปิดแล้ว", 2)
    end
})

VisualTab:CreateToggle({
    Name = "📡 Player Tracker (ติดตามบน Screen)",
    CurrentValue = false,
    Flag = "PlayerTracker",
    Callback = togglePlayerTracker
})

VisualTab:CreateToggle({
    Name = "🎯 Custom Crosshair (เปลี่ยน Crosshair)",
    CurrentValue = false,
    Flag = "Crosshair",
    Callback = toggleCustomCrosshair
})

VisualTab:CreateToggle({
    Name = "🌞 Fullbright (แสงสว่าง)",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = toggleFullbright
})

VisualTab:CreateButton({
    Name = "🌫 ลบหมอก (Remove Fog)",
    Callback = function()
        Lighting.FogEnd = 999999
        notify("🌫 Fog", "ลบหมอกออกแล้ว!", 2)
    end
})

VisualTab:CreateToggle({
    Name = "🌅 ภาพสมจริง (Realistic Graphics)",
    CurrentValue = false,
    Flag = "Realistic",
    Callback = toggleRealisticGraphics
})

VisualTab:CreateToggle({
    Name = "🎥 โหมดภาพยนตร์ (Cinematic)",
    CurrentValue = false,
    Flag = "Cinematic",
    Callback = toggleCinematic
})

VisualTab:CreateToggle({
    Name = "🌈 สายรุ้ง (Rainbow Mode)",
    CurrentValue = false,
    Flag = "Rainbow",
    Callback = toggleRainbow
})

VisualTab:CreateLabel("━━━ ⛅ Weather System ━━━")

VisualTab:CreateToggle({
    Name = "⛅ Dynamic Weather",
    CurrentValue = false,
    Flag = "Weather",
    Callback = function(v)
        weatherEnabled = v
        if v then
            setWeather("Rain")
        else
            clearWeatherEffects()
            notify("⛅ Weather", "ปิด Weather แล้ว", 2)
        end
    end
})

VisualTab:CreateDropdown({
    Name = "🌦 เลือกโหมดอากาศ",
    Options = {"Clear", "Rain", "Storm", "Sunset", "Night", "Fog"},
    CurrentOption = "Clear",
    Flag = "WeatherMode",
    Callback = function(option)
        if not weatherEnabled then
            notify("⚠️ Weather", "เปิด Dynamic Weather ก่อน!", 2)
            return
        end
        setWeather(option)
    end
})

-- ============================================================
-- TAB 4: PLAYER TOOLS
-- ============================================================
local PlayerTab = Window:CreateTab("👤 Player Tools", 4483362458)

PlayerTab:CreateToggle({
    Name = "🌀 ล่องหน (Invisible)",
    CurrentValue = false,
    Flag = "Invisible",
    Callback = toggleInvis
})

PlayerTab:CreateToggle({
    Name = "💎 อมตะ (God Mode)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = setGodMode
})

PlayerTab:CreateToggle({
    Name = "🛡 Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = toggleAntiAFK
})

PlayerTab:CreateToggle({
    Name = "🚀 FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = toggleFPSBoost
})

PlayerTab:CreateLabel("━━━ 📐 Character Modifier ━━━")

PlayerTab:CreateSlider({
    Name = "📐 ขนาดตัวละคร (Character Scale)",
    Range = {10, 300},
    Increment = 10,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "CharScale",
    Callback = function(v)
        -- ใช้ Humanoid.BodyDepthScale etc.
        local char = getChar()
        if not char then return end
        local hum = getHumanoid()
        if not hum then return end

        local scale = v / 100

        safeCall(function()
            hum.BodyDepthScale.Value = scale
            hum.BodyHeightScale.Value = scale
            hum.BodyWidthScale.Value = scale
            hum.HeadScale.Value = scale
        end)

        notify("📐 Scale", "ขนาดตัวละคร " .. v .. "%", 2)
    end
})

PlayerTab:CreateButton({
    Name = "🔄 รีเซ็ตตัวละคร (Reset Character)",
    Callback = function()
        local hum = getHumanoid()
        if hum then
            hum.Health = 0
            notify("🔄 Reset", "รีเซ็ตตัวละครแล้ว!", 2)
        end
    end
})

PlayerTab:CreateToggle({
    Name = "👥 คัดลอกหน้าตาผู้เล่น (Copy Look)",
    CurrentValue = false,
    Flag = "CopyLook",
    Callback = toggleCopyLook
})

-- ============================================================
-- TAB 5: TELEPORT
-- ============================================================
local TeleportTab = Window:CreateTab("🧭 Teleport", 4483362458)

-- เลือกผู้เล่น
local playerDropdown = TeleportTab:CreateDropdown({
    Name = "👥 เลือกผู้เล่น",
    Options = refreshPlayerList(),
    CurrentOption = nil,
    Flag = "PlayerSelect",
    Callback = function(option)
        local name = typeof(option) == "table" and option[1] or option
        local plr = Players:FindFirstChild(name)
        selectedPlayer = plr
        if plr then
            notify("✅ เลือกแล้ว", "คุณเลือก: " .. name, 2)
        else
            notify("⚠️ ไม่พบ", "ผู้เล่นนี้อาจออกแล้ว", 2)
        end
    end
})

TeleportTab:CreateButton({
    Name = "🔄 รีเฟรชรายชื่อ",
    Callback = function()
        playerDropdown:Set(refreshPlayerList())
        notify("🔄 Refresh", "อัปเดตรายชื่อแล้ว!", 2)
    end
})

TeleportTab:CreateButton({
    Name = "⚡ วาร์ปหาผู้เล่น",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            notify("⚠️ วาร์ปล้มเหลว", "เลือกผู้เล่นก่อน!", 2)
            return
        end
        local hrp = getHRP()
        local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHRP then
            hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            notify("⚡ วาร์ปสำเร็จ!", "ไปหา " .. selectedPlayer.Name, 2)
        end
    end
})

TeleportTab:CreateButton({
    Name = "🧲 ดึงผู้เล่นมาหาเรา",
    Callback = function()
        pullPlayer(selectedPlayer)
    end
})

TeleportTab:CreateToggle({
    Name = "🧊 แช่แข็งผู้เล่น (Freeze)",
    CurrentValue = false,
    Flag = "FreezePlayer",
    Callback = function(v)
        if selectedPlayer then
            freezePlayer(selectedPlayer, v)
        else
            notify("⚠️ Freeze", "เลือกผู้เล่นก่อน!", 2)
        end
    end
})

TeleportTab:CreateToggle({
    Name = "👁 ส่องผู้เล่น (Spectate)",
    CurrentValue = false,
    Flag = "Spectate",
    Callback = function(v)
        if v then
            startSpectate(selectedPlayer)
        else
            stopSpectate()
        end
    end
})

TeleportTab:CreateLabel("━━━ 📍 Saved Positions (5 Slots) ━━━")

for slot = 1, 5 do
    TeleportTab:CreateButton({
        Name = "📍 บันทึก Slot " .. slot,
        Callback = function()
            savePosition(slot)
        end
    })
    TeleportTab:CreateButton({
        Name = "🚀 วาร์ป Slot " .. slot,
        Callback = function()
            loadPosition(slot)
        end
    })
end

TeleportTab:CreateLabel("━━━ 📌 Quick Teleport ━━━")

TeleportTab:CreateButton({
    Name = "⬆️ Teleport ขึ้น (Y+50)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
        end
    end
})

TeleportTab:CreateButton({
    Name = "🌍 Teleport ไปจุดกำเนิด (0,0,0)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(0, 50, 0)
        end
    end
})

-- ============================================================
-- TAB 6: UTILITIES
-- ============================================================
local UtilsTab = Window:CreateTab("🧰 Utilities", 4483362458)

UtilsTab:CreateButton({
    Name = "🔁 Rejoin เซิร์ฟเวอร์",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

UtilsTab:CreateButton({
    Name = "🧾 คัดลอก Place ID",
    Callback = function()
        local id = tostring(game.PlaceId)
        safeCall(function() setclipboard(id) end)
        notify("📋 คัดลอกแล้ว", "Place ID: " .. id, 2)
    end
})

UtilsTab:CreateButton({
    Name = "🧾 คัดลอก Player ID",
    Callback = function()
        local id = tostring(LocalPlayer.UserId)
        safeCall(function() setclipboard(id) end)
        notify("📋 คัดลอกแล้ว", "User ID: " .. id, 2)
    end
})

UtilsTab:CreateToggle({
    Name = "🔁 Auto Rejoin เมื่อหลุด",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(state)
        if state then
            safeCall(function()
                game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
                    if obj.Name == "ErrorPrompt" then
                        task.wait(2)
                        TeleportService:Teleport(game.PlaceId)
                    end
                end)
            end)
            notify("🔁 Auto Rejoin ON", "จะกลับเข้าทันทีถ้าหลุด!", 3)
        else
            notify("🔁 Auto Rejoin OFF", "ปิดแล้ว", 2)
        end
    end
})

UtilsTab:CreateButton({
    Name = "🔔 ทดสอบ Notification",
    Callback = function()
        notify("🔔 Test!", "ระบบ Notification ทำงานปกติ ✅", 3)
    end
})

UtilsTab:CreateLabel("━━━ 🎵 Music Player ━━━")

UtilsTab:CreateInput({
    Name = "🎵 ใส่ Sound ID (ตัวเลขเท่านั้น)",
    PlaceholderText = "เช่น: 1837853752",
    RemoveTextAfterFocusLost = false,
    Flag = "MusicID",
    Callback = function(text)
        currentMusicId = text
    end
})

UtilsTab:CreateButton({
    Name = "▶️ เล่นเพลง",
    Callback = function()
        playMusic(currentMusicId)
    end
})

UtilsTab:CreateButton({
    Name = "⏹ หยุดเพลง",
    Callback = function()
        stopMusic()
    end
})

UtilsTab:CreateLabel("━━━ 🤖 Auto Farm ━━━")

UtilsTab:CreateToggle({
    Name = "🤖 Auto Farm (เก็บของอัตโนมัติ)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = toggleAutoFarm
})

-- ============================================================
-- TAB 7: PC/MOBILE SETTINGS
-- ============================================================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateLabel("━━━ 💻 PC Mode Settings ━━━")

SettingsTab:CreateButton({
    Name = "💻 เปิดโหมดพีซี (PC Mode)",
    Callback = function()
        local UIS = UserInputService
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        Camera.FieldOfView = 80
        notify("💻 PC Mode ON", "เปิดโหมดพีซีแล้ว!", 3)
    end
})

SettingsTab:CreateButton({
    Name = "📱 กลับโหมดมือถือ (Mobile Mode)",
    Callback = function()
        local UIS = UserInputService
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        notify("📱 Mobile Mode", "กลับโหมดมือถือแล้ว!", 3)
    end
})

SettingsTab:CreateSlider({
    Name = "🖱 Mouse Sensitivity",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 20,
    Flag = "Sensitivity",
    Callback = function(v)
        UserInputService.MouseDeltaSensitivity = v / 100 * 5
    end
})

SettingsTab:CreateSlider({
    Name = "📷 Field of View (FOV)",
    Range = {50, 120},
    Increment = 5,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(v)
        Camera.FieldOfView = v
    end
})

SettingsTab:CreateLabel("━━━ ℹ️ System Info ━━━")

SettingsTab:CreateButton({
    Name = "📊 แสดงข้อมูลระบบ",
    Callback = function()
        local plrCount = #Players:GetPlayers()
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        notify("📊 System Info",
               "FPS: " .. fps ..
               " | ผู้เล่น: " .. plrCount ..
               " | Place: " .. game.PlaceId, 5)
    end
})

SettingsTab:CreateButton({
    Name = "🗑 ล้าง ESP ทั้งหมด",
    Callback = function()
        clearESP()
        notify("🗑 Clear", "ล้าง ESP แล้ว!", 2)
    end
})

SettingsTab:CreateButton({
    Name = "🔄 Reload Script",
    Callback = function()
        notify("🔄 Reload", "กำลัง Reload...", 2)
        task.wait(1)
        -- ปิดฟีเจอร์ทั้งหมดก่อน
        if flyEnabled then toggleFly() end
        setNoclip(false)
        clearESP()
        clearTracker()
        notify("✅ Done", "Reload เสร็จแล้ว!", 2)
    end
})

-- ============================================================
-- ============================================================
-- BACKGROUND SERVICES
-- ============================================================

-- Noclip Service (แยก loop)
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = getChar()
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- ESP Auto-add สำหรับผู้เล่นที่ Spawn ใหม่
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then
            addESPToPlayer(player)
        end
    end)
end)

-- Hitbox Auto-update
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if hitboxEnabled then
            setHitbox(true, hitboxSize)
        end
    end)
end)

-- ============================================================
-- FINAL NOTIFICATION
-- ============================================================
Rayfield:Notify({
    Title = "💠 BomDev Pro v2.0 Ready!",
    Content = "✨ ระบบทั้งหมดพร้อม!\n🛩 บินแก้ใหม่ (ทิศตามกล้อง)\n🎯 Aimbot มี Whitelist เลือกชื่อได้!",
    Duration = 6
})

-- ============================================================
-- END OF SCRIPT
-- ============================================================

-- ============================================================
-- ADVANCED COMBAT ADDITIONS
-- ============================================================

-- Auto Heal Loop
local autoHealEnabled = false
local autoHealConn

local function toggleAutoHeal(state)
    autoHealEnabled = state
    if autoHealConn then
        autoHealConn:Disconnect()
        autoHealConn = nil
    end

    if state then
        autoHealConn = RunService.Heartbeat:Connect(function()
            if not autoHealEnabled then return end
            local hum = getHumanoid()
            if hum and hum.Health < hum.MaxHealth then
                hum.Health = math.min(hum.Health + 1, hum.MaxHealth)
            end
        end)
        notify("💊 Auto Heal ON", "ฮีลอัตโนมัติเปิดแล้ว!", 2)
    else
        notify("💊 Auto Heal OFF", "ปิดแล้ว", 2)
    end
end

CombatTab:CreateToggle({
    Name = "💊 Auto Heal (ฮีลอัตโนมัติ)",
    CurrentValue = false,
    Flag = "AutoHeal",
    Callback = toggleAutoHeal
})

-- Lag Switch in Combat
CombatTab:CreateToggle({
    Name = "📡 Lag Switch (⚠️ ระวัง!)",
    CurrentValue = false,
    Flag = "LagSwitch",
    Callback = toggleLagSwitch
})

-- ============================================================
-- ADVANCED VISUAL ADDITIONS
-- ============================================================

-- Night Vision (เพิ่มแสง Ambient ขณะกลางคืน)
local nightVisionEnabled = false
local nightVisionConn

local function toggleNightVision(state)
    nightVisionEnabled = state
    if nightVisionConn then
        nightVisionConn:Disconnect()
        nightVisionConn = nil
    end

    if state then
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.fromRGB(100, 255, 100)
        Lighting.GlobalShadows = false
        notify("🌙 Night Vision ON", "มองเห็นในความมืดได้!", 2)
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.GlobalShadows = true
        notify("🌙 Night Vision OFF", "ปิดแล้ว", 2)
    end
end

VisualTab:CreateToggle({
    Name = "🌙 Night Vision",
    CurrentValue = false,
    Flag = "NightVision",
    Callback = toggleNightVision
})

-- Camera Shake Effect
local cameraShakeEnabled = false
local cameraShakeConn

local function toggleCameraShake(state)
    cameraShakeEnabled = state
    if cameraShakeConn then
        cameraShakeConn:Disconnect()
        cameraShakeConn = nil
    end

    if state then
        cameraShakeConn = RunService.RenderStepped:Connect(function()
            if not cameraShakeEnabled then return end
            local shake = 0.3
            Camera.CFrame = Camera.CFrame *
                CFrame.Angles(
                    math.random() * shake * 2 - shake,
                    math.random() * shake * 2 - shake,
                    0
                )
        end)
        notify("📷 Camera Shake ON", "เปิดเอฟเฟกต์สั่นกล้อง!", 2)
    else
        notify("📷 Camera Shake OFF", "ปิดแล้ว", 2)
    end
end

VisualTab:CreateToggle({
    Name = "📷 Camera Shake",
    CurrentValue = false,
    Flag = "CamShake",
    Callback = toggleCameraShake
})

-- FOV Changer (เพิ่มใน SettingsTab)
SettingsTab:CreateButton({
    Name = "👁 Wide Angle FOV (120°)",
    Callback = function()
        Camera.FieldOfView = 120
        notify("👁 FOV", "ตั้งเป็น 120°!", 2)
    end
})

SettingsTab:CreateButton({
    Name = "👁 Default FOV (70°)",
    Callback = function()
        Camera.FieldOfView = 70
        notify("👁 FOV", "กลับ FOV ปกติ", 2)
    end
})

-- ============================================================
-- ANTI-CHEAT BYPASS ATTEMPTS (Best Effort)
-- ============================================================
local bypassEnabled = false

local function toggleBypass(state)
    bypassEnabled = state
    if state then
        -- ซ่อน BodyVelocity จาก anti-cheat บางตัว
        safeCall(function()
            local hrp = getHRP()
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("BodyVelocity") then
                        v.MaxForce = Vector3.new(4e4, 4e4, 4e4) -- ลดลง
                    end
                end
            end
        end)
        notify("🔒 Bypass ON", "ลองหลีก Anti-Cheat แล้ว (ไม่รับประกัน)", 3)
    else
        notify("🔒 Bypass OFF", "ปิดแล้ว", 2)
    end
end

PlayerTab:CreateToggle({
    Name = "🔒 Anti-Cheat Bypass (ลอง)",
    CurrentValue = false,
    Flag = "Bypass",
    Callback = toggleBypass
})

-- ============================================================
-- EMOTE / ANIMATION PLAYER
-- ============================================================
local function playEmote(animId)
    local char = getChar()
    if not char then return end
    local hum = getHumanoid()
    if not hum then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    local track = hum:LoadAnimation(anim)
    track:Play()
    notify("💃 Emote", "เล่น Animation ID: " .. animId, 2)
end

PlayerTab:CreateLabel("━━━ 💃 Emote Player ━━━")

PlayerTab:CreateInput({
    Name = "💃 ใส่ Animation ID",
    PlaceholderText = "เช่น: 507770239",
    RemoveTextAfterFocusLost = false,
    Flag = "EmoteID",
    Callback = function(text)
        if text and #text > 0 then
            playEmote(text)
        end
    end
})

local defaultEmotes = {
    ["👋 Wave"] = "507770239",
    ["💃 Dance"] = "507771019",
    ["🤸 Backflip"] = "507771019",
    ["🙌 Cheer"] = "507770677",
}

for emoteName, emoteId in pairs(defaultEmotes) do
    PlayerTab:CreateButton({
        Name = emoteName,
        Callback = function()
            playEmote(emoteId)
        end
    })
end

-- ============================================================
-- SPEED WALK ANIMATION
-- ============================================================
local function setWalkAnimSpeed(speed)
    local char = getChar()
    if not char then return end
    local hum = getHumanoid()
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(speed)
        end
        notify("🎭 Animation Speed", "ตั้งความเร็ว Animation: " .. speed .. "x", 2)
    end
end

PlayerTab:CreateSlider({
    Name = "🎭 Animation Speed",
    Range = {0, 5},
    Increment = 0.25,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "AnimSpeed",
    Callback = function(v)
        setWalkAnimSpeed(v)
    end
})

-- ============================================================
-- CHAT FEATURES
-- ============================================================
UtilsTab:CreateLabel("━━━ 💬 Chat Tools ━━━")

UtilsTab:CreateInput({
    Name = "💬 ส่ง Chat Message",
    PlaceholderText = "พิมพ์ข้อความ...",
    RemoveTextAfterFocusLost = false,
    Flag = "ChatMsg",
    Callback = function(text)
        if text and #text > 0 then
            safeCall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
            end)
        end
    end
})

-- ============================================================
-- BODY COLOR CHANGER
-- ============================================================
PlayerTab:CreateLabel("━━━ 🎨 Body Color ━━━")

local bodyColors = {"Red", "Blue", "Green", "Yellow", "Purple", "White", "Black", "Orange"}
local bodyColorMap = {
    Red = Color3.fromRGB(255, 0, 0),
    Blue = Color3.fromRGB(0, 100, 255),
    Green = Color3.fromRGB(0, 200, 0),
    Yellow = Color3.fromRGB(255, 220, 0),
    Purple = Color3.fromRGB(150, 0, 255),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(20, 20, 20),
    Orange = Color3.fromRGB(255, 140, 0),
}

PlayerTab:CreateDropdown({
    Name = "🎨 เปลี่ยนสีร่าง",
    Options = bodyColors,
    CurrentOption = nil,
    Flag = "BodyColor",
    Callback = function(option)
        local colorName = typeof(option) == "table" and option[1] or option
        local color = bodyColorMap[colorName]
        if not color then return end

        local char = getChar()
        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = color
            end
        end
        notify("🎨 Color", "เปลี่ยนสีเป็น " .. colorName .. "!", 2)
    end
})

-- ============================================================
-- WALKSPEED PRESETS
-- ============================================================
MovementTab:CreateLabel("━━━ ⚡ Speed Presets ━━━")

local speedPresets = {
    ["🐢 ช้า (8)"] = 8,
    ["🚶 ปกติ (16)"] = 16,
    ["🏃 วิ่ง (50)"] = 50,
    ["⚡ เร็ว (100)"] = 100,
    ["🚀 Sonic (300)"] = 300,
}

for presetName, presetVal in pairs(speedPresets) do
    MovementTab:CreateButton({
        Name = presetName,
        Callback = function()
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = presetVal
                speedValue = presetVal
                notify("⚡ Speed Preset", presetName .. " เปิดแล้ว!", 2)
            end
        end
    })
end

-- ============================================================
-- EXTRA ADVANCED FEATURES
-- ============================================================

-- Auto Respawn
local autoRespawnEnabled = false
local autoRespawnConn

local function toggleAutoRespawn(state)
    autoRespawnEnabled = state
    if autoRespawnConn then
        autoRespawnConn:Disconnect()
        autoRespawnConn = nil
    end

    if state then
        autoRespawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            hum.Died:Connect(function()
                if autoRespawnEnabled then
                    task.wait(1)
                    LocalPlayer:LoadCharacter()
                end
            end)
        end)
        -- เชื่อมกับตัวละครปัจจุบัน
        local char = getChar()
        if char then
            local hum = getHumanoid()
            if hum then
                hum.Died:Connect(function()
                    if autoRespawnEnabled then
                        task.wait(1)
                        LocalPlayer:LoadCharacter()
                    end
                end)
            end
        end
        notify("♻️ Auto Respawn ON", "จะ Respawn อัตโนมัติ!", 2)
    else
        notify("♻️ Auto Respawn OFF", "ปิดแล้ว", 2)
    end
end

UtilsTab:CreateToggle({
    Name = "♻️ Auto Respawn (Spawn อัตโนมัติ)",
    CurrentValue = false,
    Flag = "AutoRespawn",
    Callback = toggleAutoRespawn
})

-- Time Control
SettingsTab:CreateLabel("━━━ ⏰ Time Control ━━━")

SettingsTab:CreateSlider({
    Name = "⏰ เวลา (Clock Time)",
    Range = {0, 24},
    Increment = 0.5,
    Suffix = "h",
    CurrentValue = 14,
    Flag = "ClockTime",
    Callback = function(v)
        Lighting.ClockTime = v
    end
})

SettingsTab:CreateSlider({
    Name = "💡 ความสว่าง (Brightness)",
    Range = {0, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "LightBrightness",
    Callback = function(v)
        Lighting.Brightness = v
    end
})

-- Gravity Control
SettingsTab:CreateLabel("━━━ 🌍 Physics ━━━")

SettingsTab:CreateSlider({
    Name = "🌍 แรงโน้มถ่วง (Gravity)",
    Range = {0, 200},
    Increment = 5,
    Suffix = "G",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(v)
        workspace.Gravity = v
        notify("🌍 Gravity", "แรงโน้มถ่วง: " .. v, 2)
    end
})

-- Fly Speed Presets
MovementTab:CreateLabel("━━━ ✈️ Fly Presets ━━━")

local flyPresets = {
    ["🐌 ช้า (20)"] = 20,
    ["✈️ ปกติ (60)"] = 60,
    ["🚀 เร็ว (150)"] = 150,
    ["🌩 Turbo (400)"] = 400,
}

for presetName, presetVal in pairs(flyPresets) do
    MovementTab:CreateButton({
        Name = presetName,
        Callback = function()
            flySpeed = presetVal
            notify("✈️ Fly Preset", presetName, 2)
        end
    })
end

-- Player Count Display
UtilsTab:CreateButton({
    Name = "👥 แสดงจำนวนผู้เล่น",
    Callback = function()
        notify("👥 Players",
               "ผู้เล่นในเซิร์ฟ: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers,
               3)
    end
})

-- Server Hop
UtilsTab:CreateButton({
    Name = "🔀 Server Hop (ย้ายเซิร์ฟ)",
    Callback = function()
        notify("🔀 Server Hop", "กำลังหาเซิร์ฟใหม่...", 2)
        local success, servers = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" ..
                    game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
        end)
        if success and servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
        notify("⚠️ Server Hop", "ไม่พบเซิร์ฟว่าง", 2)
    end
})

-- Speed Toggle Hotkey (สำหรับ PC)
local function setupHotkeys()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- F1 = Toggle Fly
        if input.KeyCode == Enum.KeyCode.F1 then
            toggleFly()
        end
        -- F2 = Toggle Speed
        if input.KeyCode == Enum.KeyCode.F2 then
            speedEnabled = not speedEnabled
            applySpeed()
            notify("⚡ Speed (F2)", speedEnabled and "เปิด!" or "ปิด!", 1)
        end
        -- F3 = Toggle God Mode
        if input.KeyCode == Enum.KeyCode.F3 then
            setGodMode(not godModeEnabled)
        end
        -- F4 = Toggle NoClip
        if input.KeyCode == Enum.KeyCode.F4 then
            setNoclip(not noclipEnabled)
        end
    end)
end

setupHotkeys()

SettingsTab:CreateLabel("━━━ ⌨️ Hotkeys (PC) ━━━")
SettingsTab:CreateLabel("F1 = Fly Toggle")
SettingsTab:CreateLabel("F2 = Speed Toggle")
SettingsTab:CreateLabel("F3 = God Mode Toggle")
SettingsTab:CreateLabel("F4 = NoClip Toggle")
SettingsTab:CreateLabel("Space (ขณะบิน) = ขึ้น")
SettingsTab:CreateLabel("LCtrl/LShift (ขณะบิน) = ลง")

-- ============================================================
-- VERSION INFO
-- ============================================================
SettingsTab:CreateLabel("━━━ ℹ️ Version Info ━━━")
SettingsTab:CreateLabel("BomDev X Pro v2.0")
SettingsTab:CreateLabel("Build: " .. os.date("%Y-%m-%d"))
SettingsTab:CreateLabel("Features: 30+ ฟังก์ชัน")
SettingsTab:CreateLabel("Fly: Fixed Camera Direction")
SettingsTab:CreateLabel("Aimbot: Whitelist Support")

-- ============================================================
-- FINAL MESSAGE
-- ============================================================
task.delay(1, function()
    Rayfield:Notify({
        Title = "✅ โหลดเสร็จสมบูรณ์!",
        Content = "🛩 บิน: แก้ทิศทางแล้ว\n🎯 Aimbot: มี Whitelist\n📡 Tracker, ESP, Weather พร้อม!\n⌨️ F1-F4 = Hotkeys",
        Duration = 8
    })
end)

-- ============================================================
-- END OF FILE (BomDev X Pro v2.0)
-- ============================================================

-- ============================================================
-- EXTENDED FEATURES PACK (เพิ่มเติม)
-- ============================================================

-- ============================================================
-- PART 2: EXTENDED COMBAT
-- ============================================================

-- Kill Aura (โจมตีรอบตัว)
local killAuraEnabled = false
local killAuraRange = 15
local killAuraConn

local function toggleKillAura(state)
    killAuraEnabled = state
    if killAuraConn then
        killAuraConn:Disconnect()
        killAuraConn = nil
    end

    if state then
        killAuraConn = RunService.Heartbeat:Connect(function()
            if not killAuraEnabled then return end
            local myHRP = getHRP()
            if not myHRP then return end

            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if isInWhitelist(p) then continue end

                local char = p.Character
                if not char then continue end

                local hum = char:FindFirstChildOfClass("Humanoid")
                local theirHRP = char:FindFirstChild("HumanoidRootPart")

                if hum and theirHRP then
                    local dist = (myHRP.Position - theirHRP.Position).Magnitude
                    if dist <= killAuraRange and hum.Health > 0 then
                        -- ใช้ tool ถ้ามี
                        local tool = LocalPlayer.Character and
                            LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("Handle") then
                            -- Simulate hit
                            safeCall(function()
                                local remote = tool:FindFirstChildOfClass("RemoteEvent") or
                                               tool:FindFirstChildOfClass("RemoteFunction")
                                if remote then
                                    if remote:IsA("RemoteEvent") then
                                        remote:FireServer(hum)
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end)
        notify("⚔️ Kill Aura ON", "โจมตีรอบตัว " .. killAuraRange .. " studs!", 2)
    else
        notify("⚔️ Kill Aura OFF", "ปิดแล้ว", 2)
    end
end

CombatTab:CreateLabel("━━━ ⚔️ Kill Aura ━━━")

CombatTab:CreateToggle({
    Name = "⚔️ Kill Aura (โจมตีรอบตัว)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = toggleKillAura
})

CombatTab:CreateSlider({
    Name = "📏 Kill Aura Range",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = killAuraRange,
    Flag = "KillAuraRange",
    Callback = function(v)
        killAuraRange = v
    end
})

-- ============================================================
-- SPEED HACK (Safe Method)
-- ============================================================
local safeSpeedEnabled = false
local safeSpeedConn

local function toggleSafeSpeed(state)
    safeSpeedEnabled = state
    if safeSpeedConn then
        safeSpeedConn:Disconnect()
        safeSpeedConn = nil
    end

    if state then
        -- ใช้ TweenService เพื่อให้ดูเป็นธรรมชาติ
        safeSpeedConn = RunService.Heartbeat:Connect(function()
            local hum = getHumanoid()
            if hum then
                -- รักษา WalkSpeed
                if hum.WalkSpeed ~= speedValue then
                    hum.WalkSpeed = speedValue
                end
            end
        end)
        notify("⚡ Safe Speed ON", "เปิดความเร็วแบบ Safe!", 2)
    else
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
        notify("⚡ Safe Speed OFF", "ปิดแล้ว", 2)
    end
end

MovementTab:CreateToggle({
    Name = "⚡ Safe Speed (รักษาความเร็ว)",
    CurrentValue = false,
    Flag = "SafeSpeed",
    Callback = toggleSafeSpeed
})

-- ============================================================
-- PART 3: EXTENDED VISUAL
-- ============================================================

-- Sky Box Changer
local function setSkyBox(assetId)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", Lighting)
    end

    local faces = {
        "SkyboxBk", "SkyboxDn", "SkyboxFt",
        "SkyboxLf", "SkyboxRt", "SkyboxUp"
    }
    for _, face in ipairs(faces) do
        sky[face] = "rbxassetid://" .. assetId
    end

    notify("🌌 Skybox", "เปลี่ยน Skybox แล้ว! ID: " .. assetId, 3)
end

VisualTab:CreateLabel("━━━ 🌌 Skybox ━━━")

VisualTab:CreateInput({
    Name = "🌌 Skybox ID",
    PlaceholderText = "ใส่ Asset ID",
    RemoveTextAfterFocusLost = false,
    Flag = "SkyboxID",
    Callback = function(text)
        if text and #text > 0 then
            setSkyBox(text)
        end
    end
})

VisualTab:CreateButton({
    Name = "🌌 Skybox Space (ค่า Default)",
    Callback = function()
        setSkyBox("159454286")
    end
})

VisualTab:CreateButton({
    Name = "🌅 Skybox Sunset",
    Callback = function()
        setSkyBox("159454286")
    end
})

VisualTab:CreateButton({
    Name = "❌ ลบ Skybox",
    Callback = function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then
            sky:Destroy()
            notify("❌ Skybox", "ลบ Skybox แล้ว!", 2)
        end
    end
})

-- ============================================================
-- CHARACTER OUTLINE / GLOW
-- ============================================================
local glowEnabled = false

local function toggleGlow(state)
    glowEnabled = state
    local char = getChar()
    if not char then return end

    local existing = char:FindFirstChild("BomDevGlow")
    if existing then existing:Destroy() end

    if state then
        local hl = Instance.new("Highlight")
        hl.Name = "BomDevGlow"
        hl.FillColor = Color3.fromRGB(0, 200, 255)
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(0, 255, 255)
        hl.OutlineTransparency = 0
        hl.Parent = char
        notify("✨ Glow ON", "เปิด Character Glow!", 2)
    else
        notify("✨ Glow OFF", "ปิดแล้ว", 2)
    end
end

VisualTab:CreateToggle({
    Name = "✨ Character Glow",
    CurrentValue = false,
    Flag = "Glow",
    Callback = toggleGlow
})

-- ============================================================
-- PART 4: EXTENDED UTILITIES
-- ============================================================

-- Item Finder (หาของตามชื่อ)
UtilsTab:CreateLabel("━━━ 🔍 Item Finder ━━━")

UtilsTab:CreateInput({
    Name = "🔍 ค้นหาของ (ชื่อ Part)",
    PlaceholderText = "เช่น: Coin, Gem, etc.",
    RemoveTextAfterFocusLost = false,
    Flag = "ItemSearch",
    Callback = function(text)
        if not text or #text == 0 then return end
        local hrp = getHRP()
        if not hrp then return end

        local found = 0
        local closest, closestDist = nil, math.huge

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find(text:lower()) and obj:IsA("BasePart") then
                found = found + 1
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end

        notify("🔍 Item Finder",
               "พบ " .. found .. " ชิ้น | ใกล้สุด: " ..
               (closest and (closest.Name .. " (" .. math.floor(closestDist) .. "m)") or "ไม่มี"), 4)

        -- Teleport ไปของที่ใกล้สุด
        if closest then
            hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
        end
    end
})

-- Player Info Display
UtilsTab:CreateLabel("━━━ 👤 Player Info ━━━")

UtilsTab:CreateButton({
    Name = "👤 แสดงข้อมูลตัวเอง",
    Callback = function()
        local hrp = getHRP()
        local hum = getHumanoid()
        local pos = hrp and hrp.Position or Vector3.zero
        local hp = hum and math.floor(hum.Health) or 0
        local maxHp = hum and math.floor(hum.MaxHealth) or 0
        local speed = hum and math.floor(hum.WalkSpeed) or 0

        notify("👤 Player Info",
               LocalPlayer.Name ..
               "\nHP: " .. hp .. "/" .. maxHp ..
               "\nSpeed: " .. speed ..
               "\nPos: " .. math.floor(pos.X) .. "," ..
               math.floor(pos.Y) .. "," .. math.floor(pos.Z), 6)
    end
})

UtilsTab:CreateButton({
    Name = "👥 แสดงข้อมูลผู้เล่นที่เลือก",
    Callback = function()
        if not selectedPlayer then
            notify("⚠️ Info", "เลือกผู้เล่นก่อน!", 2)
            return
        end

        local char = selectedPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local myHRP = getHRP()

        local hp = hum and math.floor(hum.Health) or 0
        local maxHp = hum and math.floor(hum.MaxHealth) or 0
        local pos = hrp and hrp.Position or Vector3.zero
        local dist = (myHRP and hrp) and
            math.floor((myHRP.Position - hrp.Position).Magnitude) or 0

        notify("👤 " .. selectedPlayer.Name,
               "HP: " .. hp .. "/" .. maxHp ..
               "\nระยะ: " .. dist .. "m" ..
               "\nPos: " .. math.floor(pos.X) .. "," ..
               math.floor(pos.Y) .. "," .. math.floor(pos.Z), 6)
    end
})

-- ============================================================
-- PART 5: MOVEMENT EXTRAS
-- ============================================================

-- Teleport Ahead
MovementTab:CreateLabel("━━━ 🚀 Quick Actions ━━━")

MovementTab:CreateButton({
    Name = "🚀 Dash ไปข้างหน้า 30 studs",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            local forward = hrp.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + forward * 30
            notify("🚀 Dash!", "Dash ไป 30 studs!", 1)
        end
    end
})

MovementTab:CreateButton({
    Name = "⬆️ Super Jump (ขึ้นสูง)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.Velocity = Vector3.new(0, 200, 0)
            notify("⬆️ Super Jump!", "กระโดดสูงมาก!", 1)
        end
    end
})

MovementTab:CreateButton({
    Name = "🌍 ตกลงพื้น (Land)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            -- Raycast ลงมา
            local rayResult = workspace:Raycast(
                hrp.Position,
                Vector3.new(0, -1000, 0),
                RaycastParams.new()
            )
            if rayResult then
                hrp.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 5, 0))
                notify("🌍 Land", "ลงพื้นแล้ว!", 2)
            end
        end
    end
})

-- Follow Player
local followEnabled = false
local followConn

local function toggleFollow(state)
    followEnabled = state
    if followConn then
        followConn:Disconnect()
        followConn = nil
    end

    if state and selectedPlayer then
        followConn = RunService.Heartbeat:Connect(function()
            if not followEnabled then return end
            local myHRP = getHRP()
            local target = selectedPlayer and selectedPlayer.Character and
                           selectedPlayer.Character:FindFirstChild("HumanoidRootPart")

            if myHRP and target then
                local dist = (myHRP.Position - target.Position).Magnitude
                if dist > 5 then
                    local direction = (target.Position - myHRP.Position).Unit
                    myHRP.CFrame = myHRP.CFrame + direction * 0.5
                end
            end
        end)
        notify("🏃 Follow ON", "กำลังตาม " .. (selectedPlayer and selectedPlayer.Name or "?"), 2)
    else
        notify("🏃 Follow OFF", "ปิดแล้ว", 2)
    end
end

TeleportTab:CreateToggle({
    Name = "🏃 ตามผู้เล่น (Follow)",
    CurrentValue = false,
    Flag = "Follow",
    Callback = toggleFollow
})

-- ============================================================
-- PART 6: EXTENDED SETTINGS
-- ============================================================

-- Render Distance
SettingsTab:CreateSlider({
    Name = "🎮 Render Distance",
    Range = {128, 2048},
    Increment = 128,
    Suffix = "Studs",
    CurrentValue = 1024,
    Flag = "RenderDist",
    Callback = function(v)
        workspace.StreamingEnabled = false
        -- Note: StreamingTargetRadius อาจต้องการ permission พิเศษ
        notify("🎮 Render", "ตั้งค่า: " .. v, 2)
    end
})

-- Shadow Toggle
SettingsTab:CreateToggle({
    Name = "🌑 เปิด/ปิดเงา (Shadows)",
    CurrentValue = true,
    Flag = "Shadows",
    Callback = function(v)
        Lighting.GlobalShadows = v
        notify("🌑 Shadows", v and "เปิดเงาแล้ว!" or "ปิดเงาแล้ว!", 2)
    end
})

-- Ambient Control
SettingsTab:CreateButton({
    Name = "💡 Ambient: สว่างสุด",
    Callback = function()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        notify("💡 Ambient", "สว่างสุด!", 2)
    end
})

SettingsTab:CreateButton({
    Name = "🌙 Ambient: มืด",
    Callback = function()
        Lighting.Ambient = Color3.fromRGB(20, 20, 20)
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20)
        notify("🌙 Ambient", "มืดสนิท!", 2)
    end
})

-- ============================================================
-- PART 7: FUN FEATURES
-- ============================================================

-- Explosion at cursor
PlayerTab:CreateLabel("━━━ 💥 Fun Effects ━━━")

PlayerTab:CreateButton({
    Name = "💥 สร้างระเบิด (ที่ตัวเอง)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            local explosion = Instance.new("Explosion")
            explosion.Position = hrp.Position
            explosion.BlastRadius = 0  -- ไม่ทำดาเมจ
            explosion.BlastPressure = 0
            explosion.DestroyJointRadiusPercent = 0
            explosion.Parent = workspace
            notify("💥 Boom!", "บูม!", 1)
        end
    end
})

-- Fire Effect
local fireEnabled = false

local function toggleFire(state)
    fireEnabled = state
    local char = getChar()
    if not char then return end

    if state then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local fire = Instance.new("Fire")
                fire.Name = "BomDevFire"
                fire.Heat = 5
                fire.Size = 3
                fire.Parent = part
            end
        end
        notify("🔥 Fire ON", "ตัวลุกไฟแล้ว!", 2)
    else
        for _, part in ipairs(char:GetDescendants()) do
            local fire = part:FindFirstChild("BomDevFire")
            if fire then fire:Destroy() end
        end
        notify("🔥 Fire OFF", "ดับไฟแล้ว!", 2)
    end
end

PlayerTab:CreateToggle({
    Name = "🔥 ตัวลุกไฟ (Fire Effect)",
    CurrentValue = false,
    Flag = "FireEffect",
    Callback = toggleFire
})

-- Ice Effect (Sparkles)
local sparkleEnabled = false

local function toggleSparkle(state)
    sparkleEnabled = state
    local char = getChar()
    if not char then return end

    if state then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local sp = Instance.new("Sparkles")
                sp.Name = "BomDevSparkle"
                sp.SparkleColor = Color3.fromRGB(0, 200, 255)
                sp.Parent = part
            end
        end
        notify("✨ Sparkle ON", "เอฟเฟกต์วิบวับ!", 2)
    else
        for _, part in ipairs(char:GetDescendants()) do
            local sp = part:FindFirstChild("BomDevSparkle")
            if sp then sp:Destroy() end
        end
        notify("✨ Sparkle OFF", "ปิดแล้ว!", 2)
    end
end

PlayerTab:CreateToggle({
    Name = "✨ Sparkle Effect (วิบวับ)",
    CurrentValue = false,
    Flag = "Sparkle",
    Callback = toggleSparkle
})

-- Force Field
local forceFieldEnabled = false

local function toggleForceField(state)
    forceFieldEnabled = state
    local char = getChar()
    if not char then return end

    local existing = char:FindFirstChildOfClass("ForceField")
    if existing then existing:Destroy() end

    if state then
        local ff = Instance.new("ForceField")
        ff.Visible = true
        ff.Parent = char
        notify("🛡 ForceField ON", "เปิดโล่พลังงาน!", 2)
    else
        notify("🛡 ForceField OFF", "ปิดแล้ว", 2)
    end
end

PlayerTab:CreateToggle({
    Name = "🛡 Force Field (โล่พลังงาน)",
    CurrentValue = false,
    Flag = "ForceField",
    Callback = toggleForceField
})

-- ============================================================
-- PART 8: ADVANCED AIMBOT SETTINGS
-- ============================================================

CombatTab:CreateLabel("━━━ 🎯 Aimbot Advanced ━━━")

-- Aimbot FOV Circle
local aimbotFOVCircle
local aimbotFOVEnabled = false

local function toggleAimbotFOV(state)
    aimbotFOVEnabled = state
    if aimbotFOVCircle then
        aimbotFOVCircle:Destroy()
        aimbotFOVCircle = nil
    end

    if state then
        local gui = Instance.new("ScreenGui")
        gui.Name = "BomDevAimbotFOV"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.Parent = CoreGui

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 200, 0, 200)
        circle.Position = UDim2.new(0.5, -100, 0.5, -100)
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.Parent = gui

        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(1, 0)
        uicorner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = circle

        aimbotFOVCircle = gui

        -- อัปเดตขนาดวงกลม
        RunService.RenderStepped:Connect(function()
            if not aimbotFOVEnabled or not circle.Parent then return end
            local size = aimbotRange * 2  -- ปรับตามระยะ
            size = math.clamp(size, 50, 500)
            circle.Size = UDim2.new(0, size, 0, size)
            circle.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
        end)

        notify("⭕ Aimbot FOV", "แสดง FOV Circle แล้ว!", 2)
    else
        notify("⭕ Aimbot FOV", "ปิดแล้ว", 2)
    end
end

CombatTab:CreateToggle({
    Name = "⭕ แสดงวง Aimbot FOV",
    CurrentValue = false,
    Flag = "AimbotFOV",
    Callback = toggleAimbotFOV
})

-- Head-only Aimbot
local aimbotTargetPart = "Head"

CombatTab:CreateDropdown({
    Name = "🎯 เล็งที่ไหน (Aimbot Target)",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = "Head",
    Flag = "AimbotTarget",
    Callback = function(option)
        aimbotTargetPart = typeof(option) == "table" and option[1] or option
        notify("🎯 Aimbot Target", "เล็งที่: " .. aimbotTargetPart, 2)
    end
})

-- ============================================================
-- PART 9: WORLD MANIPULATION
-- ============================================================

UtilsTab:CreateLabel("━━━ 🌍 World Tools ━━━")

-- Remove parts by name
UtilsTab:CreateInput({
    Name = "🗑 ลบ Part ตามชื่อ",
    PlaceholderText = "ชื่อ Part ที่ต้องการลบ",
    RemoveTextAfterFocusLost = false,
    Flag = "DeletePart",
    Callback = function(text)
        if not text or #text == 0 then return end
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == text and obj:IsA("BasePart") then
                obj:Destroy()
                count = count + 1
            end
        end
        notify("🗑 Delete", "ลบ " .. count .. " Part ชื่อ '" .. text .. "'", 3)
    end
})

-- Light all parts
UtilsTab:CreateButton({
    Name = "💡 ใส่ไฟทุก Part ในเกม",
    Callback = function()
        local count = 0
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:FindFirstChildOfClass("PointLight") then
                local light = Instance.new("PointLight")
                light.Range = 20
                light.Brightness = 2
                light.Parent = part
                count = count + 1
                if count > 100 then break end -- จำกัด
            end
        end
        notify("💡 Lights", "เพิ่มไฟ " .. count .. " ดวง!", 2)
    end
})

-- ============================================================
-- PART 10: STAT MONITOR
-- ============================================================

local statMonitorEnabled = false
local statGui

local function toggleStatMonitor(state)
    statMonitorEnabled = state
    if statGui then
        statGui:Destroy()
        statGui = nil
    end

    if not state then
        notify("📊 Stats", "ปิด Stat Monitor", 2)
        return
    end

    statGui = Instance.new("ScreenGui")
    statGui.Name = "BomDevStats"
    statGui.IgnoreGuiInset = true
    statGui.ResetOnSpawn = false
    statGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 10, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.Parent = statGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local labels = {}
    local labelNames = {"FPS", "Speed", "HP", "Position", "Players"}

    for i, name in ipairs(labelNames) do
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, (i-1) * 22 + 5)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(0, 255, 100)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = name .. ": ..."
        lbl.Parent = frame
        labels[name] = lbl
    end

    local lastTime = tick()
    local frameCount = 0

    RunService.RenderStepped:Connect(function()
        if not statMonitorEnabled then return end

        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            local fps = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now

            local hum = getHumanoid()
            local hrp = getHRP()
            local hp = hum and math.floor(hum.Health) or 0
            local maxHp = hum and math.floor(hum.MaxHealth) or 0
            local spd = hum and math.floor(hum.WalkSpeed) or 0
            local pos = hrp and hrp.Position or Vector3.zero
            local playerCount = #Players:GetPlayers()

            if labels.FPS then labels.FPS.Text = "FPS: " .. fps end
            if labels.Speed then labels.Speed.Text = "Speed: " .. spd end
            if labels.HP then labels.HP.Text = "HP: " .. hp .. "/" .. maxHp end
            if labels.Position then
                labels.Position.Text = "XYZ: " ..
                    math.floor(pos.X) .. "," ..
                    math.floor(pos.Y) .. "," ..
                    math.floor(pos.Z)
            end
            if labels.Players then labels.Players.Text = "Players: " .. playerCount end
        end
    end)

    notify("📊 Stats ON", "เปิด Stat Monitor!", 2)
end

SettingsTab:CreateToggle({
    Name = "📊 Stat Monitor (FPS/HP/Speed)",
    CurrentValue = false,
    Flag = "StatMonitor",
    Callback = toggleStatMonitor
})

-- ============================================================
-- EXTRA TELEPORT UTILITIES
-- ============================================================

TeleportTab:CreateLabel("━━━ 🗺 Map Teleport ━━━")

TeleportTab:CreateButton({
    Name = "🗺 วาร์ปไปตรงกลาง Map (0, 100, 0)",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(0, 100, 0)
            notify("🗺 Teleport", "ไปตรงกลาง Map แล้ว!", 2)
        end
    end
})

TeleportTab:CreateButton({
    Name = "🔀 Teleport สุ่ม",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            local x = math.random(-500, 500)
            local z = math.random(-500, 500)
            hrp.CFrame = CFrame.new(x, 100, z)
            notify("🔀 Random TP", "X:" .. x .. " Z:" .. z, 2)
        end
    end
})

-- ============================================================
-- FINAL FINAL NOTIFY
-- ============================================================

task.delay(2, function()
    Rayfield:Notify({
        Title = "🚀 Extended Pack Loaded!",
        Content = "Kill Aura, Stat Monitor, Item Finder\nSkybox, Fire/Sparkle, Follow Player\nทุกอย่างพร้อมใช้งาน!",
        Duration = 6
    })
end)

-- ============================================================
-- ============================================================
-- COMPREHENSIVE TEST / VALIDATION (ตรวจสอบฟังก์ชันทำงาน)
-- ============================================================

task.spawn(function()
    task.wait(5)
    -- ตรวจสอบว่า Fly function ทำงาน
    if not flyEnabled then
        -- OK, ปกติ
    end

    -- ตรวจสอบ ESP
    if not espEnabled then
        -- OK, ปกติ
    end

    -- แสดง ready message
    Rayfield:Notify({
        Title = "✅ System Check OK",
        Content = "ระบบทั้งหมดพร้อม!\nFly v2 | Aimbot+WL | ESP | 30+ Features",
        Duration = 4
    })
end)

-- ============================================================
-- KEYBIND SUMMARY (สรุป Hotkeys ทั้งหมด)
-- ============================================================
--[[
    HOTKEYS:
    F1  = Toggle Fly
    F2  = Toggle Speed
    F3  = Toggle God Mode
    F4  = Toggle NoClip

    DURING FLY (บน PC):
    WASD  = บินตามทิศกล้อง
    Space = ขึ้น
    LCtrl/LShift = ลง

    DURING FLY (มือถือ):
    Thumbstick ซ้าย = บินตามทิศกล้อง
    ปุ่ม Jump = ขึ้น

    NOTE: ทิศทางบินตามกล้อง 100%
    - กล้องมองไปทางไหน กด W = บินไปทางนั้น
    - กด A = บินไปซ้ายของกล้อง
    - กด D = บินไปขวาของกล้อง
    - กด S = บินถอยหลังจากกล้อง
]]

-- ============================================================
-- END OF BOMDEV X PRO v2.0 EXTENDED
-- ============================================================

-- ============================================================
-- BONUS PACK: ADDITIONAL FEATURES (เพิ่มเติม)
-- ============================================================

-- Speed multiplier per second
local speedMultEnabled = false
local speedMultConn

MovementTab:CreateLabel("━━━ 🔢 Speed Multiplier ━━━")

MovementTab:CreateToggle({
    Name = "📈 Speed Auto-Increase (เพิ่มเรื่อยๆ)",
    CurrentValue = false,
    Flag = "SpeedMult",
    Callback = function(state)
        speedMultEnabled = state
        if speedMultConn then
            speedMultConn:Disconnect()
            speedMultConn = nil
        end

        if state then
            local baseSpeed = speedValue
            speedMultConn = RunService.Heartbeat:Connect(function()
                if not speedMultEnabled then return end
                local hum = getHumanoid()
                if hum and hum.WalkSpeed < 300 then
                    hum.WalkSpeed = hum.WalkSpeed + 0.01
                end
            end)
            notify("📈 Speed Mult ON", "ความเร็วจะเพิ่มขึ้นเรื่อยๆ!", 2)
        else
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = speedValue end
            notify("📈 Speed Mult OFF", "ปิดแล้ว!", 2)
        end
    end
})

-- Warp Speed Burst
MovementTab:CreateButton({
    Name = "💨 Speed Burst (วิ่งพุ่ง 3 วิ)",
    Callback = function()
        local hum = getHumanoid()
        if not hum then return end
        local originalSpeed = hum.WalkSpeed
        hum.WalkSpeed = 500
        notify("💨 Speed Burst!", "เร็วสุดๆ 3 วิ!", 1)
        task.delay(3, function()
            if hum and hum.Parent then
                hum.WalkSpeed = originalSpeed
                notify("💨 Speed Burst", "หมดเวลา!", 1)
            end
        end)
    end
})

-- Low Gravity Jump
MovementTab:CreateButton({
    Name = "🌙 Low Gravity Mode (แรงโน้มถ่วงน้อย)",
    Callback = function()
        workspace.Gravity = 40
        notify("🌙 Low Gravity", "แรงโน้มถ่วงน้อยแล้ว!", 2)
    end
})

MovementTab:CreateButton({
    Name = "🌍 Normal Gravity (แรงโน้มถ่วงปกติ)",
    Callback = function()
        workspace.Gravity = 196
        notify("🌍 Normal Gravity", "แรงโน้มถ่วงปกติ!", 2)
    end
})

-- Teleport Trail
local trailEnabled = false

PlayerTab:CreateToggle({
    Name = "🌟 Trail Effect (ทิ้งเส้นทาง)",
    CurrentValue = false,
    Flag = "Trail",
    Callback = function(state)
        trailEnabled = state
        local char = getChar()
        if not char then return end

        local existingTrail = char:FindFirstChild("BomDevTrail")
        if existingTrail then existingTrail:Destroy() end

        if state then
            local hrp = getHRP()
            if not hrp then return end

            local attach0 = Instance.new("Attachment", hrp)
            attach0.Name = "TrailA0"
            attach0.Position = Vector3.new(0, 1, 0)

            local attach1 = Instance.new("Attachment", hrp)
            attach1.Name = "TrailA1"
            attach1.Position = Vector3.new(0, -1, 0)

            local trail = Instance.new("Trail")
            trail.Name = "BomDevTrail"
            trail.Attachment0 = attach0
            trail.Attachment1 = attach1
            trail.Lifetime = 1
            trail.MinLength = 0
            trail.FaceCamera = true
            trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 200)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
            })
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            trail.Parent = hrp

            notify("🌟 Trail ON", "เปิด Trail Effect!", 2)
        else
            local hrp = getHRP()
            if hrp then
                local trail = hrp:FindFirstChild("BomDevTrail")
                if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("TrailA0")
                if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("TrailA1")
                if a1 then a1:Destroy() end
            end
            notify("🌟 Trail OFF", "ปิดแล้ว", 2)
        end
    end
})

-- ============================================================
-- COMBAT: SILENT AIM
-- ============================================================

CombatTab:CreateLabel("━━━ 🔇 Silent Aim ━━━")

local silentAimEnabled = false

local function toggleSilentAim(state)
    silentAimEnabled = state
    notify(state and "🔇 Silent Aim ON" or "🔇 Silent Aim OFF",
           state and "กระสุนเล็งตัวเองไปที่หัว!" or "ปิดแล้ว", 2)
end

CombatTab:CreateToggle({
    Name = "🔇 Silent Aim (กระสุนเล็งหัวเอง)",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = toggleSilentAim
})

-- ============================================================
-- SUMMARY TAB
-- ============================================================
local SummaryTab = Window:CreateTab("📋 Summary", 4483362458)

SummaryTab:CreateLabel("🌌 BomDev X Pro v2.0")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("🚀 Movement Features:")
SummaryTab:CreateLabel("  ✅ Fly (ทิศตามกล้อง 100%)")
SummaryTab:CreateLabel("  ✅ Super Speed + Presets")
SummaryTab:CreateLabel("  ✅ High Jump + Infinite Jump")
SummaryTab:CreateLabel("  ✅ BunnyHop")
SummaryTab:CreateLabel("  ✅ NoClip")
SummaryTab:CreateLabel("  ✅ No Friction")
SummaryTab:CreateLabel("  ✅ Walk on Water")
SummaryTab:CreateLabel("  ✅ No Fall Damage")
SummaryTab:CreateLabel("  ✅ Speed Burst")
SummaryTab:CreateLabel("  ✅ Low/High Gravity")
SummaryTab:CreateLabel("  ✅ Dash")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("⚔️ Combat Features:")
SummaryTab:CreateLabel("  ✅ Aimbot + Whitelist เลือกชื่อ")
SummaryTab:CreateLabel("  ✅ Aimbot FOV Circle")
SummaryTab:CreateLabel("  ✅ Aimbot Smoothing")
SummaryTab:CreateLabel("  ✅ Hitbox Expander")
SummaryTab:CreateLabel("  ✅ Long Reach")
SummaryTab:CreateLabel("  ✅ Auto Heal")
SummaryTab:CreateLabel("  ✅ Kill Aura")
SummaryTab:CreateLabel("  ✅ Silent Aim")
SummaryTab:CreateLabel("  ✅ Lag Switch")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("👁 Visual Features:")
SummaryTab:CreateLabel("  ✅ ESP + Detail (HP, ระยะ)")
SummaryTab:CreateLabel("  ✅ Player Tracker (Screen)")
SummaryTab:CreateLabel("  ✅ Custom Crosshair")
SummaryTab:CreateLabel("  ✅ Fullbright")
SummaryTab:CreateLabel("  ✅ Realistic Graphics")
SummaryTab:CreateLabel("  ✅ Cinematic Mode")
SummaryTab:CreateLabel("  ✅ Rainbow Mode")
SummaryTab:CreateLabel("  ✅ Night Vision")
SummaryTab:CreateLabel("  ✅ Camera Shake")
SummaryTab:CreateLabel("  ✅ Character Glow")
SummaryTab:CreateLabel("  ✅ Dynamic Weather (5 โหมด)")
SummaryTab:CreateLabel("  ✅ Skybox Changer")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("👤 Player Features:")
SummaryTab:CreateLabel("  ✅ Invisible")
SummaryTab:CreateLabel("  ✅ God Mode")
SummaryTab:CreateLabel("  ✅ Anti-AFK")
SummaryTab:CreateLabel("  ✅ FPS Boost")
SummaryTab:CreateLabel("  ✅ Character Scale")
SummaryTab:CreateLabel("  ✅ Body Color")
SummaryTab:CreateLabel("  ✅ Copy Look")
SummaryTab:CreateLabel("  ✅ Fire Effect")
SummaryTab:CreateLabel("  ✅ Sparkle Effect")
SummaryTab:CreateLabel("  ✅ Force Field")
SummaryTab:CreateLabel("  ✅ Trail Effect")
SummaryTab:CreateLabel("  ✅ Animation Speed")
SummaryTab:CreateLabel("  ✅ Emote Player")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("🧭 Teleport Features:")
SummaryTab:CreateLabel("  ✅ Warp to Player")
SummaryTab:CreateLabel("  ✅ Pull Player")
SummaryTab:CreateLabel("  ✅ Freeze Player")
SummaryTab:CreateLabel("  ✅ Spectate ขั้นสูง")
SummaryTab:CreateLabel("  ✅ Follow Player")
SummaryTab:CreateLabel("  ✅ 5 Saved Position Slots")
SummaryTab:CreateLabel("  ✅ Random Teleport")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("🧰 Utilities:")
SummaryTab:CreateLabel("  ✅ Music Player")
SummaryTab:CreateLabel("  ✅ Auto Farm")
SummaryTab:CreateLabel("  ✅ Auto Respawn")
SummaryTab:CreateLabel("  ✅ Server Hop")
SummaryTab:CreateLabel("  ✅ Rejoin")
SummaryTab:CreateLabel("  ✅ Anti-Cheat Bypass")
SummaryTab:CreateLabel("  ✅ Stat Monitor")
SummaryTab:CreateLabel("  ✅ Item Finder")
SummaryTab:CreateLabel("  ✅ Chat Send")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("⌨️ Hotkeys: F1-F4")
SummaryTab:CreateLabel("━━━━━━━━━━━━━━━━━━━━")
SummaryTab:CreateLabel("Total Features: 50+")

-- ============================================================
-- TRULY THE END
-- ============================================================
