-- ╔══════════════════════════════════════════════╗
-- ║        BomDev Hub  v7.0  |  Dev: BomDev      ║
-- ║  UI: Rayfield Interface Suite  (sirius.menu)  ║
-- ╚══════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local CoreGui       = game:GetService("CoreGui")
local Lighting      = game:GetService("Lighting")
local VirtualUser   = game:GetService("VirtualUser")
local TeleportSvc   = game:GetService("TeleportService")
local HttpService   = game:GetService("HttpService")
local GuiService    = game:GetService("GuiService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ─── State ───────────────────────────────────────
local S = {
    fly=false,      flySpeed=60,
    speed=false,    speedVal=60,
    jump=false,     jumpVal=100,
    noclip=false,
    god=false,
    infJump=false,
    bhop=false,
    hitbox=false,   hitboxSz=10,
    aimbot=false,   abRange=200, abSmooth=0.15,
    esp=false,
    rainbow=false,
    glow=false,
    fire=false,
    sparkle=false,
    trail=false,
    invis=false,
    killAura=false, kaRange=15,
    antiAfk=false,
    autoFarm=false,
    noFall=false,
    stats=false,
    crosshair=false,
}

local Conns   = {}
local WL      = {}
local Slots   = {}
local EspConns= {}

-- ─── Helpers ─────────────────────────────────────
local function safe(fn, ...) pcall(fn, ...) end
local function char()
    local c = LP.Character
    return c
end
local function hrp()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function killConn(name)
    if Conns[name] then
        pcall(function() Conns[name]:Disconnect() end)
        Conns[name] = nil
    end
end
local function notify(title, content, duration, icon)
    Rayfield:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 2,
        Image    = icon or "info",
    })
end

-- ═══════════════════════════════════════════════════════════
--  ✈  FLY SYSTEM  —  ทำงานได้ PC + มือถือ 100%
--     หลักการ:
--     • ใช้ BodyVelocity + BodyGyro (MaxForce 1e9)
--     • ไม่ใช้ PlatformStand (มันบล็อก input)
--     • Loop ใน RenderStepped อ่าน key / joystick ทุก frame
--     • มือถือ: สร้าง Virtual Joystick (วงกลม) + ปุ่มลอยขึ้น/ลง
--     • ถ้า bv/bg หาย (respawn) → auto restart
-- ═══════════════════════════════════════════════════════════

local FlyJoyGui     = nil
local joyActive     = false
local joyCenter     = Vector2.zero
local joyDelta      = Vector2.zero   -- (-1..1, -1..1)  X=strafe  Y=forward(-)
local flyBtnUp      = false
local flyBtnDown    = false
local JOY_R         = 65             -- radius joystick วงกลม (px)

local function destroyJoystick()
    if FlyJoyGui then
        FlyJoyGui:Destroy()
        FlyJoyGui = nil
    end
    joyActive   = false
    joyDelta    = Vector2.zero
    flyBtnUp    = false
    flyBtnDown  = false
end

local function createJoystick()
    destroyJoystick()

    local sg = Instance.new("ScreenGui")
    sg.Name          = "BomDevFlyJoy"
    sg.ResetOnSpawn  = false
    sg.IgnoreGuiInset= true
    sg.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder  = 200

    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    FlyJoyGui = sg

    -- ── วงกลม base ──────────────────────────────────────
    local baseFrame = Instance.new("Frame")
    baseFrame.Name               = "JoyBase"
    baseFrame.AnchorPoint        = Vector2.new(0, 1)
    baseFrame.Size               = UDim2.fromOffset(JOY_R*2, JOY_R*2)
    baseFrame.Position           = UDim2.new(0, 20, 1, -100)
    baseFrame.BackgroundColor3   = Color3.fromRGB(20, 20, 20)
    baseFrame.BackgroundTransparency = 0.45
    baseFrame.BorderSizePixel    = 0
    baseFrame.ZIndex             = 200
    baseFrame.Parent             = sg
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = baseFrame
        local st = Instance.new("UIStroke")
        st.Color       = Color3.fromRGB(80, 160, 255)
        st.Thickness   = 2
        st.Transparency= 0.2
        st.Parent = baseFrame
    end

    -- ── thumb ────────────────────────────────────────────
    local THUMB_R = JOY_R * 0.45
    local thumb = Instance.new("Frame")
    thumb.Name              = "Thumb"
    thumb.AnchorPoint       = Vector2.new(0.5, 0.5)
    thumb.Size              = UDim2.fromOffset(THUMB_R*2, THUMB_R*2)
    thumb.Position          = UDim2.new(0.5, 0, 0.5, 0)
    thumb.BackgroundColor3  = Color3.fromRGB(80, 160, 255)
    thumb.BackgroundTransparency = 0.15
    thumb.BorderSizePixel   = 0
    thumb.ZIndex            = 201
    thumb.Parent            = baseFrame
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = thumb
    end

    -- ── label ────────────────────────────────────────────
    local lbl = Instance.new("TextLabel")
    lbl.Size     = UDim2.new(1,0,0,16)
    lbl.Position = UDim2.new(0,0,-0.28,0)
    lbl.BackgroundTransparency = 1
    lbl.Text     = "✈ FLY"
    lbl.TextSize = 11
    lbl.Font     = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(80,160,255)
    lbl.ZIndex   = 201
    lbl.Parent   = baseFrame

    -- ── ปุ่ม UP / DOWN ───────────────────────────────────
    local function mkBtn(lbTxt, anchorY, posOffY, onPress)
        local btn = Instance.new("TextButton")
        btn.Name              = lbTxt
        btn.AnchorPoint       = Vector2.new(0, anchorY)
        btn.Size              = UDim2.fromOffset(58, 58)
        btn.Position          = UDim2.new(0, 20 + JOY_R*2 + 18, 1, posOffY)
        btn.BackgroundColor3  = Color3.fromRGB(20, 20, 20)
        btn.BackgroundTransparency = 0.45
        btn.Text              = lbTxt
        btn.TextColor3        = Color3.fromRGB(255, 255, 255)
        btn.TextSize          = 22
        btn.Font              = Enum.Font.GothamBold
        btn.BorderSizePixel   = 0
        btn.ZIndex            = 200
        btn.Parent            = sg
        do
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0.25, 0)
            c.Parent = btn
            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(80, 160, 255)
            st.Thickness = 2
            st.Transparency = 0.2
            st.Parent = btn
        end
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
                onPress(true)
            end
        end)
        btn.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
                onPress(false)
            end
        end)
        return btn
    end

    mkBtn("⬆", 1, -170, function(v) flyBtnUp   = v end)
    mkBtn("⬇", 1, -102, function(v) flyBtnDown = v end)

    -- ── Joystick Touch Handling ──────────────────────────
    local touchIds = {}   -- ติดตาม touch ID ที่แตะ joystick

    local ib = UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if not baseFrame or not baseFrame.Parent then return end
        local abs   = baseFrame.AbsolutePosition
        local sz    = baseFrame.AbsoluteSize
        local center= abs + sz / 2
        local tp    = Vector2.new(inp.Position.X, inp.Position.Y)
        if (tp - center).Magnitude <= JOY_R then
            touchIds[inp.UserInputState] = inp
            joyActive = true
            joyCenter = center
        end
    end)

    local ic = UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if not joyActive then return end
        local tp    = Vector2.new(inp.Position.X, inp.Position.Y)
        local delta = tp - joyCenter
        if delta.Magnitude > JOY_R then
            delta = delta.Unit * JOY_R
        end
        joyDelta = delta / JOY_R
        if thumb and thumb.Parent then
            thumb.Position = UDim2.fromOffset(
                JOY_R + delta.X - THUMB_R,
                JOY_R + delta.Y - THUMB_R
            )
        end
    end)

    local ie = UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        joyActive = false
        joyDelta  = Vector2.zero
        if thumb and thumb.Parent then
            thumb.Position = UDim2.new(0.5, -THUMB_R, 0.5, -THUMB_R)
        end
    end)

    sg.Destroying:Connect(function()
        pcall(function() ib:Disconnect() end)
        pcall(function() ic:Disconnect() end)
        pcall(function() ie:Disconnect() end)
    end)
end

-- ── startFly / stopFly ──────────────────────────────────
local function startFly()
    local c = char(); if not c then return end
    local r = hrp();  if not r then return end
    local h = hum();  if not h then return end

    -- ลบของเก่า
    for _, n in ipairs({"BDFlyBV","BDFlyBG"}) do
        local ex = r:FindFirstChild(n)
        if ex then ex:Destroy() end
    end

    -- BodyVelocity — ควบคุมความเร็ว/ทิศ
    local bv = Instance.new("BodyVelocity")
    bv.Name      = "BDFlyBV"
    bv.MaxForce  = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity  = Vector3.zero
    bv.Parent    = r

    -- BodyGyro — ล็อคหน้าให้ตาม camera
    local bg = Instance.new("BodyGyro")
    bg.Name      = "BDFlyBG"
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P         = 1e4
    bg.D         = 600
    bg.CFrame    = r.CFrame
    bg.Parent    = r

    -- ปิด state รบกวน  (อย่าใช้ PlatformStand!)
    h.PlatformStand = false
    h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)

    -- สร้าง joystick ถ้าเป็นมือถือ
    if UIS.TouchEnabled then
        createJoystick()
    end

    killConn("fly")

    Conns.fly = RunService.RenderStepped:Connect(function()
        if not S.fly then return end

        local rNow = hrp()
        if not rNow then return end

        local bvNow = rNow:FindFirstChild("BDFlyBV")
        local bgNow = rNow:FindFirstChild("BDFlyBG")

        -- ถ้า instance หาย → restart
        if not bvNow or not bgNow then
            killConn("fly")
            task.defer(function()
                if S.fly then startFly() end
            end)
            return
        end

        local cf    = Cam.CFrame
        local look  = cf.LookVector
        local right = cf.RightVector
        local up    = Vector3.new(0, 1, 0)
        local spd   = S.flySpeed

        local vel = Vector3.zero

        -- PC: WASD + Space + Ctrl/Shift
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            vel = vel + look  * spd
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            vel = vel - look  * spd
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            vel = vel + right * spd
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            vel = vel - right * spd
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + up * spd * 0.8
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
        or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel - up * spd * 0.8
        end

        -- Mobile: Virtual Joystick (X=strafe, Y=forward/back)
        if UIS.TouchEnabled and joyActive then
            local jx =  joyDelta.X
            local jy = -joyDelta.Y  -- Y screen ลง = ไปหลัง  →  ต้อง negate
            vel = vel + right * (jx * spd)
            vel = vel + look  * (jy * spd)
        end

        -- Mobile: Up/Down buttons
        if flyBtnUp   then vel = vel + up * spd * 0.8 end
        if flyBtnDown then vel = vel - up * spd * 0.8 end

        bvNow.Velocity = vel

        -- ล็อค rotation ตาม camera (แกนนอนเท่านั้น)
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            bgNow.CFrame = CFrame.new(rNow.Position, rNow.Position + flatLook)
        end

        -- ป้องกัน humanoid ล้ม
        local hh = hum()
        if hh then
            local st = hh:GetState()
            if st == Enum.HumanoidStateType.Freefall
            or st == Enum.HumanoidStateType.FallingDown then
                hh:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

local function stopFly()
    killConn("fly")
    destroyJoystick()

    local r = hrp()
    if r then
        local bv = r:FindFirstChild("BDFlyBV"); if bv then bv:Destroy() end
        local bg = r:FindFirstChild("BDFlyBG"); if bg then bg:Destroy() end
    end

    local h = hum()
    if h then
        h.PlatformStand = false
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
    end
end

-- ═══════════════════════════════════════════════════════════
--  RAYFIELD WINDOW
-- ═══════════════════════════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name             = "⚡ BomDev Hub  v7.0",
    LoadingTitle     = "BomDev Hub",
    LoadingSubtitle  = "Dev : BomDev  |  v7.0",
    Theme            = "Default",
    DisableBuildWarnings = true,
    ConfigurationSaving  = { Enabled = false },
    Discord              = { Enabled = false },
    KeySystem            = false,
})

-- ── Tabs ────────────────────────────────────────────────
local tabMove = Window:CreateTab("Movement",  "person-running")
local tabComb = Window:CreateTab("Combat",    "sword")
local tabVis  = Window:CreateTab("Visual",    "eye")
local tabPlay = Window:CreateTab("Player",    "user")
local tabTele = Window:CreateTab("Teleport",  "map-pin")
local tabUtil = Window:CreateTab("Utils",     "wrench")
local tabDl   = Window:CreateTab("Download",  "download")

-- ═══════════════════════════════════════════════════════════
--  TAB: MOVEMENT
-- ═══════════════════════════════════════════════════════════

tabMove:CreateSection("✈ Flight")

tabMove:CreateToggle({
    Name         = "Fly Mode  [F1]",
    CurrentValue = false,
    Flag         = "fly",
    Callback = function(v)
        S.fly = v
        if v then
            startFly()
            if UIS.TouchEnabled then
                notify("✈ Fly","เปิดแล้ว! ใช้จอย (ซ้ายล่าง) เดิน  ⬆⬇ บินขึ้น/ลง",5,"plane")
            else
                notify("✈ Fly","เปิดแล้ว! WASD เดิน  Space=ขึ้น  Ctrl=ลง",4,"plane")
            end
        else
            stopFly()
            notify("✈ Fly","ปิดแล้ว",2,"plane")
        end
    end,
})

tabMove:CreateSlider({
    Name         = "Fly Speed",
    Range        = {5, 500},
    Increment    = 5,
    CurrentValue = 60,
    Flag         = "flySpeed",
    Callback = function(v) S.flySpeed = v end,
})

tabMove:CreateButton({
    Name     = "🚁 Hover (Speed → 0)",
    Callback = function()
        S.flySpeed = 0
        notify("Hover","ลอยอยู่กับที่ Speed=0",2,"plane")
    end,
})

tabMove:CreateButton({
    Name     = "🔄 Reset Fly Speed",
    Callback = function()
        S.flySpeed = 60
        notify("Fly Speed","รีเซ็ตเป็น 60",2,"plane")
    end,
})

-- ── Speed & Jump ─────────────────────────────────────────

tabMove:CreateSection("🏃 Speed & Jump")

tabMove:CreateToggle({
    Name         = "Super Speed  [F2]",
    CurrentValue = false,
    Flag         = "speed",
    Callback = function(v)
        S.speed = v
        local h = hum(); if h then h.WalkSpeed = v and S.speedVal or 16 end
        notify("Speed", v and "เปิด 💨" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 500},
    Increment    = 1,
    CurrentValue = 60,
    Flag         = "speedVal",
    Callback = function(v)
        S.speedVal = v
        if S.speed then local h=hum(); if h then h.WalkSpeed=v end end
    end,
})

tabMove:CreateToggle({
    Name         = "High Jump",
    CurrentValue = false,
    Flag         = "jump",
    Callback = function(v)
        S.jump = v
        local h = hum(); if h then h.JumpPower = v and S.jumpVal or 50 end
        notify("Jump", v and "เปิด 🦘" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateSlider({
    Name         = "Jump Power",
    Range        = {50, 1000},
    Increment    = 10,
    CurrentValue = 100,
    Flag         = "jumpVal",
    Callback = function(v)
        S.jumpVal = v
        if S.jump then local h=hum(); if h then h.JumpPower=v end end
    end,
})

tabMove:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "infJump",
    Callback = function(v)
        S.infJump = v; killConn("infJump")
        if v then
            Conns.infJump = UIS.JumpRequest:Connect(function()
                local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("Infinite Jump", v and "เปิด" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateToggle({
    Name         = "BunnyHop",
    CurrentValue = false,
    Flag         = "bhop",
    Callback = function(v)
        S.bhop = v; killConn("bhop")
        if v then
            Conns.bhop = RunService.Heartbeat:Connect(function()
                if not S.bhop then return end
                local h=hum()
                if h and h:GetState()==Enum.HumanoidStateType.Landed then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        notify("BunnyHop", v and "เปิด 🐇" or "ปิด", 2, "zap")
    end,
})

-- ── Physics ──────────────────────────────────────────────

tabMove:CreateSection("🧱 Physics")

tabMove:CreateToggle({
    Name         = "NoClip  [F4]",
    CurrentValue = false,
    Flag         = "noclip",
    Callback = function(v)
        S.noclip = v; killConn("noclip")
        if v then
            Conns.noclip = RunService.Stepped:Connect(function()
                if not S.noclip then return end
                local c=char(); if not c then return end
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        end
        notify("NoClip", v and "เปิด 👻" or "ปิด", 2, "layers")
    end,
})

tabMove:CreateToggle({
    Name         = "No Fall Damage",
    CurrentValue = false,
    Flag         = "noFall",
    Callback = function(v)
        S.noFall = v
        local h=hum()
        if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "เปิด" or "ปิด", 2, "shield")
    end,
})

tabMove:CreateSection("🌍 Gravity")

tabMove:CreateSlider({
    Name         = "Gravity",
    Range        = {0, 400},
    Increment    = 2,
    CurrentValue = 196,
    Flag         = "gravity",
    Callback = function(v) workspace.Gravity = v end,
})

tabMove:CreateButton({
    Name = "🌙 Low Gravity",
    Callback = function() workspace.Gravity=40; notify("Gravity","Low 🌙",2,"moon") end,
})

tabMove:CreateButton({
    Name = "🌍 Normal Gravity",
    Callback = function() workspace.Gravity=196; notify("Gravity","Normal 🌍",2,"globe") end,
})

tabMove:CreateButton({
    Name = "🚀 Zero Gravity",
    Callback = function() workspace.Gravity=0; notify("Gravity","Zero-G 🚀",2,"rocket") end,
})

tabMove:CreateSection("⚡ Quick Actions")

tabMove:CreateButton({
    Name = "💨 Dash Forward 30",
    Callback = function()
        local r=hrp(); if r then r.CFrame=r.CFrame+r.CFrame.LookVector*30 end
        notify("Dash","ไปข้างหน้า 30 studs!",1,"zap")
    end,
})

tabMove:CreateButton({
    Name = "🚀 Super Launch",
    Callback = function()
        local r=hrp()
        if r then r.AssemblyLinearVelocity=Vector3.new(0,300,0) end
        notify("Launch","🚀!",1,"zap")
    end,
})

tabMove:CreateButton({
    Name = "⚡ Speed Burst (3s)",
    Callback = function()
        local h=hum(); if not h then return end
        local orig=h.WalkSpeed; h.WalkSpeed=500
        notify("Speed Burst","3 วินาที!",2,"zap")
        task.delay(3,function() if h and h.Parent then h.WalkSpeed=orig end end)
    end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: COMBAT
-- ═══════════════════════════════════════════════════════════

tabComb:CreateSection("🎯 Aimbot")

tabComb:CreateToggle({
    Name         = "Aimbot",
    CurrentValue = false,
    Flag         = "aimbot",
    Callback = function(v)
        S.aimbot = v; killConn("aimbot")
        if v then
            Conns.aimbot = RunService.RenderStepped:Connect(function()
                if not S.aimbot then return end
                local best, bestD = nil, math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==LP then continue end
                    local inWL=false
                    for _,n in ipairs(WL) do if n==p.Name then inWL=true; break end end
                    if inWL then continue end
                    local c=p.Character; if not c then continue end
                    local head=c:FindFirstChild("Head"); if not head then continue end
                    local dist=(Cam.CFrame.Position-head.Position).Magnitude
                    if dist>S.abRange then continue end
                    local sp,onS=Cam:WorldToScreenPoint(head.Position)
                    if not onS then continue end
                    local sc=Vector2.new(sp.X,sp.Y)
                    local ctr=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
                    local sd=(sc-ctr).Magnitude
                    if sd<bestD then bestD=sd; best=head end
                end
                if best then
                    local t=CFrame.new(Cam.CFrame.Position,best.Position)
                    Cam.CFrame=Cam.CFrame:Lerp(t,S.abSmooth)
                end
            end)
        end
        notify("Aimbot", v and "เปิด 🎯" or "ปิด", 2, "crosshair")
    end,
})

tabComb:CreateSlider({
    Name="Aimbot Range", Range={50,1000}, Increment=10,
    Suffix=" studs", CurrentValue=200, Flag="abRange",
    Callback=function(v) S.abRange=v end,
})

tabComb:CreateSlider({
    Name="Aimbot Smooth", Range={1,100}, Increment=1,
    Suffix="%", CurrentValue=15, Flag="abSmooth",
    Callback=function(v) S.abSmooth=v/100 end,
})

tabComb:CreateSection("🛡 Whitelist")

tabComb:CreateInput({
    Name="Add to Whitelist", PlaceholderText="ชื่อผู้เล่น...",
    RemoveTextAfterFocusLost=true,
    Callback=function(name)
        if name=="" then return end
        for _,n in ipairs(WL) do if n==name then notify("WL",name.." มีแล้ว",2); return end end
        WL[#WL+1]=name; notify("WL","เพิ่ม: "..name,2,"shield")
    end,
})

tabComb:CreateButton({
    Name="Clear Whitelist",
    Callback=function() WL={}; notify("WL","ล้างแล้ว",2,"trash") end,
})

tabComb:CreateSection("💥 Hitbox")

tabComb:CreateToggle({
    Name="Hitbox Expander", CurrentValue=false, Flag="hitbox",
    Callback=function(v)
        S.hitbox=v
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character; if not c then continue end
            local r=c:FindFirstChild("HumanoidRootPart")
            if r then r.Size=v and Vector3.new(S.hitboxSz,S.hitboxSz,S.hitboxSz) or Vector3.new(2,2,1) end
        end
        notify("Hitbox", v and "เปิด 💥" or "ปิด", 2, "box")
    end,
})

tabComb:CreateSlider({
    Name="Hitbox Size", Range={1,60}, Increment=1,
    CurrentValue=10, Flag="hitboxSz",
    Callback=function(v)
        S.hitboxSz=v
        if not S.hitbox then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character; if not c then continue end
            local r=c:FindFirstChild("HumanoidRootPart")
            if r then r.Size=Vector3.new(v,v,v) end
        end
    end,
})

tabComb:CreateSection("⚔️ Kill Aura")

tabComb:CreateToggle({
    Name="Kill Aura", CurrentValue=false, Flag="killAura",
    Callback=function(v)
        S.killAura=v; killConn("killAura")
        if v then
            Conns.killAura=RunService.Heartbeat:Connect(function()
                if not S.killAura then return end
                local myR=hrp(); if not myR then return end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==LP then continue end
                    local c=p.Character; if not c then continue end
                    local r=c:FindFirstChild("HumanoidRootPart")
                    local h=c:FindFirstChildOfClass("Humanoid")
                    if r and h and (myR.Position-r.Position).Magnitude<=S.kaRange then
                        h.Health=0
                    end
                end
            end)
        end
        notify("Kill Aura", v and "เปิด ⚔️" or "ปิด", 2, "sword")
    end,
})

tabComb:CreateSlider({
    Name="Kill Aura Range", Range={5,100}, Increment=1,
    Suffix=" studs", CurrentValue=15, Flag="kaRange",
    Callback=function(v) S.kaRange=v end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: VISUAL
-- ═══════════════════════════════════════════════════════════

tabVis:CreateSection("👁 ESP")

tabVis:CreateToggle({
    Name="Player ESP", CurrentValue=false, Flag="esp",
    Callback=function(v)
        S.esp=v
        for _,c in ipairs(EspConns) do pcall(function() c:Disconnect() end) end
        EspConns={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character
            if c then local e=c:FindFirstChild("BomDevESP"); if e then e:Destroy() end end
        end
        if not v then notify("ESP","ปิด",2); return end
        local function addESP(pl)
            local c=pl.Character; if not c then return end
            if c:FindFirstChild("BomDevESP") then return end
            local hl=Instance.new("Highlight")
            hl.Name="BomDevESP"; hl.FillTransparency=0.65
            hl.OutlineTransparency=0; hl.Parent=c
            local uc=RunService.Heartbeat:Connect(function()
                if not S.esp then return end
                local myR=hrp()
                local rNow=c:FindFirstChild("HumanoidRootPart")
                if not(myR and rNow) then return end
                local d=math.clamp((myR.Position-rNow.Position).Magnitude/200,0,1)
                hl.FillColor=Color3.new(d,1-d,0.2)
                hl.OutlineColor=Color3.new(d,1-d,0.2)
            end)
            EspConns[#EspConns+1]=uc
        end
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        local conn=Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(1); if S.esp then addESP(p) end
            end)
        end)
        EspConns[#EspConns+1]=conn
        notify("ESP","เปิด 👁 (สีตามระยะ)",2,"eye")
    end,
})

tabVis:CreateSection("✚ Crosshair")

tabVis:CreateToggle({
    Name="Custom Crosshair", CurrentValue=false, Flag="crosshair",
    Callback=function(v)
        S.crosshair=v
        local ex=CoreGui:FindFirstChild("BomDevCH"); if ex then ex:Destroy() end
        if not v then notify("Crosshair","ปิด",2); return end
        local sg=Instance.new("ScreenGui")
        sg.Name="BomDevCH"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
        local ok=pcall(function() sg.Parent=CoreGui end)
        if not ok then sg.Parent=LP:WaitForChild("PlayerGui") end
        local function mk(sz,pos)
            local f=Instance.new("Frame")
            f.Size=sz; f.Position=pos
            f.BackgroundColor3=Color3.fromRGB(80,200,255)
            f.BorderSizePixel=0; f.Parent=sg
            Instance.new("UICorner",f).CornerRadius=UDim.new(0,2)
        end
        mk(UDim2.new(0,20,0,2),UDim2.new(0.5,5,0.5,-1))
        mk(UDim2.new(0,20,0,2),UDim2.new(0.5,-25,0.5,-1))
        mk(UDim2.new(0,2,0,20),UDim2.new(0.5,-1,0.5,5))
        mk(UDim2.new(0,2,0,20),UDim2.new(0.5,-1,0.5,-25))
        local dot=Instance.new("Frame")
        dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0.5,-2,0.5,-2)
        dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0; dot.Parent=sg
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        notify("Crosshair","เปิด ✚",2,"crosshair")
    end,
})

tabVis:CreateSection("💡 Lighting")

tabVis:CreateToggle({
    Name="Fullbright", CurrentValue=false, Flag="fullbright",
    Callback=function(v)
        if v then
            Lighting.Brightness=5; Lighting.ClockTime=14
            Lighting.FogEnd=1e5; Lighting.GlobalShadows=false
            Lighting.Ambient=Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness=2; Lighting.ClockTime=12
            Lighting.GlobalShadows=true
            Lighting.Ambient=Color3.fromRGB(127,127,127)
        end
        notify("Fullbright", v and "เปิด ☀️" or "ปิด", 2, "sun")
    end,
})

tabVis:CreateToggle({
    Name="Night Vision", CurrentValue=false, Flag="nightVis",
    Callback=function(v)
        if v then
            Lighting.Brightness=6; Lighting.Ambient=Color3.fromRGB(80,255,120)
            Lighting.GlobalShadows=false
        else
            Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(127,127,127)
            Lighting.GlobalShadows=true
        end
        notify("Night Vision", v and "เปิด 🌃" or "ปิด", 2, "moon")
    end,
})

tabVis:CreateButton({
    Name="Remove Fog",
    Callback=function()
        Lighting.FogEnd=999999
        notify("Fog","ลบแล้ว ☁️",2,"cloud")
    end,
})

tabVis:CreateSlider({
    Name="Clock Time", Range={0,24}, Increment=1,
    Suffix="h", CurrentValue=14, Flag="clockTime",
    Callback=function(v) Lighting.ClockTime=v end,
})

tabVis:CreateSection("📊 Stats HUD")

tabVis:CreateToggle({
    Name="Stats HUD", CurrentValue=false, Flag="statsHUD",
    Callback=function(v)
        S.stats=v
        local ex=CoreGui:FindFirstChild("BomDevStats"); if ex then ex:Destroy() end
        if not v then notify("Stats","ปิด",2); return end
        local sg=Instance.new("ScreenGui")
        sg.Name="BomDevStats"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
        local ok=pcall(function() sg.Parent=CoreGui end)
        if not ok then sg.Parent=LP:WaitForChild("PlayerGui") end
        local box=Instance.new("Frame")
        box.Size=UDim2.new(0,200,0,100); box.Position=UDim2.new(0,8,0,90)
        box.BackgroundColor3=Color3.fromRGB(12,12,22)
        box.BackgroundTransparency=0.25; box.BorderSizePixel=0; box.Parent=sg
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,10)
        local st=Instance.new("UIStroke",box); st.Color=Color3.fromRGB(80,160,255); st.Thickness=1.5
        local ttl=Instance.new("TextLabel",box)
        ttl.Size=UDim2.new(1,0,0,22); ttl.BackgroundTransparency=1
        ttl.Text="⚡ BomDev Stats"; ttl.TextSize=11; ttl.Font=Enum.Font.GothamBold
        ttl.TextColor3=Color3.fromRGB(80,160,255); ttl.TextXAlignment=Enum.TextXAlignment.Center
        local lines={"FPS","Speed","HP","Pos"}; local lbls={}
        for i,n in ipairs(lines) do
            local l=Instance.new("TextLabel",box)
            l.Size=UDim2.new(1,-12,0,18); l.Position=UDim2.new(0,8,0,20+(i-1)*19)
            l.BackgroundTransparency=1; l.Text=n..": ..."
            l.TextSize=10; l.Font=Enum.Font.Code
            l.TextColor3=Color3.fromRGB(215,225,245)
            l.TextXAlignment=Enum.TextXAlignment.Left; lbls[n]=l
        end
        local fc,lt=0,tick()
        RunService.RenderStepped:Connect(function()
            if not S.stats then return end
            fc=fc+1; local now=tick()
            if now-lt>=1 then
                local fps=math.floor(fc/(now-lt)); fc=0; lt=now
                local hh=hum(); local r=hrp()
                local hp=hh and math.floor(hh.Health) or 0
                local mhp=hh and math.floor(hh.MaxHealth) or 100
                local sp=hh and math.floor(hh.WalkSpeed) or 0
                local pos=r and r.Position or Vector3.zero
                if lbls.FPS   then lbls.FPS.Text  ="FPS    "..fps end
                if lbls.Speed then lbls.Speed.Text ="Speed  "..sp end
                if lbls.HP    then lbls.HP.Text    ="HP     "..hp.."/"..mhp end
                if lbls.Pos   then lbls.Pos.Text   =math.floor(pos.X).." "..math.floor(pos.Y).." "..math.floor(pos.Z) end
            end
        end)
        notify("Stats","เปิด 📊",2,"bar-chart")
    end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: PLAYER
-- ═══════════════════════════════════════════════════════════

tabPlay:CreateSection("🛡 Protection")

tabPlay:CreateToggle({
    Name="God Mode  [F3]", CurrentValue=false, Flag="god",
    Callback=function(v)
        S.god=v; killConn("god"); local h=hum()
        if v then
            if h then
                h.MaxHealth=math.huge; h.Health=math.huge
                h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
            end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum()
                if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
        else
            if h then
                h.MaxHealth=100; h.Health=100
                h:SetStateEnabled(Enum.HumanoidStateType.Dead,true)
            end
        end
        notify("God Mode", v and "เปิด 🛡" or "ปิด", 2, "shield")
    end,
})

tabPlay:CreateToggle({
    Name="Anti AFK", CurrentValue=false, Flag="antiAfk",
    Callback=function(v)
        S.antiAfk=v; killConn("antiAfk")
        if v then
            Conns.antiAfk=LP.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.zero,Cam.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.zero,Cam.CFrame)
            end)
        end
        notify("Anti AFK", v and "เปิด" or "ปิด", 2, "clock")
    end,
})

tabPlay:CreateToggle({
    Name="Invisible", CurrentValue=false, Flag="invis",
    Callback=function(v)
        S.invis=v; local c=char(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end
            if p:IsA("Decal")    then p.Transparency=v and 1 or 0 end
        end
        notify("Invisible", v and "เปิด 👻" or "ปิด", 2, "ghost")
    end,
})

tabPlay:CreateSection("👤 Character")

tabPlay:CreateSlider({
    Name="Character Scale", Range={10,300}, Increment=5,
    Suffix="%", CurrentValue=100, Flag="charScale",
    Callback=function(v)
        local h=hum(); if not h then return end
        local s=v/100
        safe(function()
            h.BodyDepthScale.Value=s; h.BodyHeightScale.Value=s
            h.BodyWidthScale.Value=s; h.HeadScale.Value=s
        end)
    end,
})

tabPlay:CreateButton({
    Name="Reset Character",
    Callback=function()
        local h=hum(); if h then h.Health=0 end
        notify("Reset","Reset แล้ว",1,"refresh-cw")
    end,
})

tabPlay:CreateInput({
    Name="Play Animation (ID)", PlaceholderText="ใส่ Animation ID...",
    RemoveTextAfterFocusLost=true,
    Callback=function(txt)
        if not txt or #txt==0 then return end
        local h=hum(); if not h then return end
        local a=Instance.new("Animation"); a.AnimationId="rbxassetid://"..txt
        local t=h:LoadAnimation(a); t:Play()
        notify("Anim","▶ กำลังเล่น "..txt,2,"play")
    end,
})

tabPlay:CreateSection("✨ Effects")

tabPlay:CreateToggle({
    Name="Character Glow", CurrentValue=false, Flag="glow",
    Callback=function(v)
        S.glow=v; local c=char(); if not c then return end
        local ex=c:FindFirstChild("BomDevGlow"); if ex then ex:Destroy() end
        if v then
            local hl=Instance.new("Highlight",c)
            hl.Name="BomDevGlow"; hl.FillTransparency=0.7
            hl.FillColor=Color3.fromRGB(130,70,255)
            hl.OutlineColor=Color3.fromRGB(60,185,255)
            hl.OutlineTransparency=0
        end
        notify("Glow", v and "เปิด ✨" or "ปิด", 2, "sparkles")
    end,
})

tabPlay:CreateToggle({
    Name="Fire Effect", CurrentValue=false, Flag="fire",
    Callback=function(v)
        S.fire=v; local c=char(); if not c then return end
        if v then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    local f=Instance.new("Fire",p)
                    f.Name="BomDevFire"; f.Heat=5; f.Size=3
                end
            end
        else
            for _,p in ipairs(c:GetDescendants()) do
                local f=p:FindFirstChild("BomDevFire"); if f then f:Destroy() end
            end
        end
        notify("Fire", v and "เปิด 🔥" or "ปิด", 2, "flame")
    end,
})

tabPlay:CreateToggle({
    Name="Sparkle Effect", CurrentValue=false, Flag="sparkle",
    Callback=function(v)
        S.sparkle=v; local c=char(); if not c then return end
        if v then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    local sp=Instance.new("Sparkles",p)
                    sp.Name="BomDevSparkle"; sp.SparkleColor=Color3.fromRGB(60,185,255)
                end
            end
        else
            for _,p in ipairs(c:GetDescendants()) do
                local sp=p:FindFirstChild("BomDevSparkle"); if sp then sp:Destroy() end
            end
        end
        notify("Sparkle", v and "เปิด ✨" or "ปิด", 2, "star")
    end,
})

tabPlay:CreateToggle({
    Name="Trail Effect", CurrentValue=false, Flag="trail",
    Callback=function(v)
        S.trail=v; local r=hrp(); if not r then return end
        for _,n in ipairs({"BomDevTrail","_TrlA","_TrlB"}) do
            local ex=r:FindFirstChild(n); if ex then ex:Destroy() end
        end
        if v then
            local a0=Instance.new("Attachment",r); a0.Name="_TrlA"; a0.Position=Vector3.new(0,1,0)
            local a1=Instance.new("Attachment",r); a1.Name="_TrlB"; a1.Position=Vector3.new(0,-1,0)
            local tr=Instance.new("Trail",r)
            tr.Name="BomDevTrail"; tr.Attachment0=a0; tr.Attachment1=a1
            tr.Lifetime=0.8; tr.MinLength=0; tr.FaceCamera=true
            tr.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(130,70,255)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(60,185,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255)),
            })
            tr.Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,0),
                NumberSequenceKeypoint.new(1,1),
            })
        end
        notify("Trail", v and "เปิด 💫" or "ปิด", 2, "sparkles")
    end,
})

tabPlay:CreateToggle({
    Name="Rainbow Mode", CurrentValue=false, Flag="rainbow",
    Callback=function(v)
        S.rainbow=v; killConn("rainbow")
        if v then
            Conns.rainbow=RunService.Heartbeat:Connect(function()
                if not S.rainbow then return end
                local c=char(); if not c then return end
                local t=tick()%5/5
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color=Color3.fromHSV(t,1,1) end
                end
            end)
        end
        notify("Rainbow", v and "เปิด 🌈" or "ปิด", 2, "palette")
    end,
})

tabPlay:CreateToggle({
    Name="Force Field", CurrentValue=false, Flag="forceField",
    Callback=function(v)
        local c=char(); if not c then return end
        local ex=c:FindFirstChildOfClass("ForceField"); if ex then ex:Destroy() end
        if v then
            local ff=Instance.new("ForceField",c); ff.Visible=true
        end
        notify("Force Field", v and "เปิด 🔵" or "ปิด", 2, "shield")
    end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: TELEPORT
-- ═══════════════════════════════════════════════════════════

tabTele:CreateSection("🎯 Target Player")

local selPlayer = nil

tabTele:CreateDropdown({
    Name="Target Player",
    Options=(function()
        local t={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then t[#t+1]=p.Name end
        end
        if #t==0 then t={"(ว่าง)"} end
        return t
    end)(),
    CurrentOption={"(ว่าง)"},
    MultipleOptions=false,
    Flag="targetPlayer",
    Callback=function(opts)
        local name=(type(opts)=="table") and opts[1] or opts
        if name=="(ว่าง)" then selPlayer=nil; return end
        selPlayer=Players:FindFirstChild(name)
        notify("Target", selPlayer and "เลือก: "..name or "ไม่พบ", 2, "map-pin")
    end,
})

tabTele:CreateButton({
    Name="🔄 Refresh List (เปิด Dropdown ใหม่)",
    Callback=function()
        notify("Refresh","รีเฟรชแล้ว — เลือกใหม่ในช่อง Dropdown",3,"refresh-cw")
    end,
})

tabTele:CreateSection("⚡ Player Actions")

tabTele:CreateButton({
    Name="🔀 Warp to Target",
    Callback=function()
        if not selPlayer or not selPlayer.Character then
            notify("Warp","ไม่มีเป้าหมาย",2,"alert-triangle"); return
        end
        local r=hrp(); local tr=selPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then r.CFrame=tr.CFrame+Vector3.new(0,3,0) end
        notify("Warp","ไปหา "..selPlayer.Name,2,"map-pin")
    end,
})

tabTele:CreateButton({
    Name="🧲 Pull Target Here",
    Callback=function()
        if not selPlayer or not selPlayer.Character then
            notify("Pull","ไม่มีเป้าหมาย",2,"alert-triangle"); return
        end
        local tr=selPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myR=hrp()
        if not(tr and myR) then return end
        local ex=tr:FindFirstChild("BDPull"); if ex then ex:Destroy() end
        local bp=Instance.new("BodyPosition",tr)
        bp.Name="BDPull"; bp.MaxForce=Vector3.new(9e9,9e9,9e9)
        bp.P=8e3; bp.D=600; bp.Position=myR.Position+myR.CFrame.LookVector*3
        notify("Pull","ดึง "..selPlayer.Name,2,"zap")
        task.delay(2,function() if bp and bp.Parent then bp:Destroy() end end)
    end,
})

tabTele:CreateToggle({
    Name="Spectate Target", CurrentValue=false, Flag="spectate",
    Callback=function(v)
        killConn("spectate")
        if v then
            if not selPlayer or not selPlayer.Character then
                notify("Spectate","ไม่มีเป้าหมาย",2,"alert-triangle"); return
            end
            local h=selPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then Cam.CameraSubject=h end
            notify("Spectate","ดู "..selPlayer.Name,2,"eye")
        else
            Cam.CameraSubject=hum()
            notify("Spectate","ปิด",2,"eye")
        end
    end,
})

tabTele:CreateSection("📍 Saved Positions (5 Slots)")

for i=1,5 do
    local idx=i
    tabTele:CreateButton({
        Name="💾 Save → Slot "..i,
        Callback=function()
            local r=hrp()
            if r then Slots[idx]=r.CFrame; notify("Saved","Slot "..idx.." 💾",2,"save")
            else notify("Save","ไม่มี character",2,"alert-triangle") end
        end,
    })
    tabTele:CreateButton({
        Name="🔀 Warp → Slot "..i,
        Callback=function()
            if Slots[idx] then
                local r=hrp(); if r then r.CFrame=Slots[idx]+Vector3.new(0,3,0) end
                notify("Warp","Slot "..idx,2,"map-pin")
            else
                notify("Warp","Slot "..idx.." ว่าง",2,"alert-triangle")
            end
        end,
    })
end

tabTele:CreateSection("📍 Quick Teleport")

tabTele:CreateButton({
    Name="⬆ +50 Studs Up",
    Callback=function()
        local r=hrp(); if r then r.CFrame=r.CFrame+Vector3.new(0,50,0) end
        notify("TP","+50 ⬆",1,"arrow-up")
    end,
})

tabTele:CreateButton({
    Name="🎯 Origin (0,0,0)",
    Callback=function()
        local r=hrp(); if r then r.CFrame=CFrame.new(0,50,0) end
        notify("TP","Origin!",1,"map-pin")
    end,
})

tabTele:CreateButton({
    Name="🎲 Random Position",
    Callback=function()
        local r=hrp()
        if r then r.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500)) end
        notify("TP","Random! 🎲",1,"shuffle")
    end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: UTILS
-- ═══════════════════════════════════════════════════════════

tabUtil:CreateSection("🌐 Server")

tabUtil:CreateButton({
    Name="🔄 Rejoin",
    Callback=function()
        notify("Rejoin","กำลัง Rejoin...",2,"refresh-cw")
        task.delay(1,function() TeleportSvc:Teleport(game.PlaceId,LP) end)
    end,
})

tabUtil:CreateButton({
    Name="🔀 Server Hop",
    Callback=function()
        notify("Server Hop","กำลังหา server...",2,"shuffle")
        safe(function()
            local data=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local ok,parsed=pcall(function() return HttpService:JSONDecode(data) end)
            if ok and parsed and parsed.data then
                for _,s in ipairs(parsed.data) do
                    if s.id~=game.JobId and s.playing<s.maxPlayers then
                        TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,LP); return
                    end
                end
            end
            notify("Server Hop","ไม่พบ server ว่าง",2,"alert-triangle")
        end)
    end,
})

tabUtil:CreateButton({
    Name="📋 Copy Place ID",
    Callback=function()
        safe(function() setclipboard(tostring(game.PlaceId)) end)
        notify("Copied","Place ID: "..game.PlaceId,2,"clipboard")
    end,
})

tabUtil:CreateButton({
    Name="ℹ️ Server Info",
    Callback=function()
        notify("Server Info","Place: "..game.PlaceId.."  Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,5,"info")
    end,
})

tabUtil:CreateSection("🎵 Music Player")

local musicId, musicObj, musicVol = "", nil, 0.5

tabUtil:CreateInput({
    Name="Sound ID", PlaceholderText="ใส่ Sound ID...",
    RemoveTextAfterFocusLost=false,
    Callback=function(txt) musicId=txt end,
})

tabUtil:CreateSlider({
    Name="Volume", Range={0,100}, Increment=1,
    Suffix="%", CurrentValue=50, Flag="musicVol",
    Callback=function(v)
        musicVol=v/100
        if musicObj then musicObj.Volume=musicVol end
    end,
})

tabUtil:CreateButton({
    Name="▶ Play",
    Callback=function()
        if musicObj then musicObj:Destroy(); musicObj=nil end
        if musicId=="" then notify("Music","ใส่ Sound ID ก่อน!",2,"alert-triangle"); return end
        local snd=Instance.new("Sound")
        snd.SoundId="rbxassetid://"..musicId; snd.Volume=musicVol; snd.Looped=true
        snd.Parent=LP:WaitForChild("PlayerGui"); snd:Play()
        musicObj=snd
        notify("Music","▶ เล่น: "..musicId,2,"music")
    end,
})

tabUtil:CreateButton({
    Name="⏹ Stop",
    Callback=function()
        if musicObj then musicObj:Destroy(); musicObj=nil end
        notify("Music","⏹ หยุดแล้ว",2,"music")
    end,
})

tabUtil:CreateSection("🤖 Auto Systems")

tabUtil:CreateToggle({
    Name="Auto Farm", CurrentValue=false, Flag="autoFarm",
    Callback=function(v)
        S.autoFarm=v
        if v then
            task.spawn(function()
                while S.autoFarm do
                    local r=hrp()
                    if r then
                        local closest,closestD=nil,60
                        for _,obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local n=obj.Name:lower()
                                if n:match("coin") or n:match("gem") or n:match("pickup") or n:match("collect") or n:match("orb") then
                                    local d=(r.Position-obj.Position).Magnitude
                                    if d<closestD then closestD=d; closest=obj end
                                end
                            end
                        end
                        if closest then r.CFrame=CFrame.new(closest.Position+Vector3.new(0,3,0)) end
                    end
                    task.wait(0.1)
                end
            end)
        end
        notify("Auto Farm", v and "เปิด 🤖" or "ปิด", 2, "cpu")
    end,
})

tabUtil:CreateSection("🌍 World Tools")

tabUtil:CreateInput({
    Name="Find & TP to Part", PlaceholderText="ชื่อ Part ที่ต้องการหา...",
    RemoveTextAfterFocusLost=true,
    Callback=function(txt)
        if not txt or #txt==0 then return end
        local r=hrp(); if not r then return end
        local found,closest,closestD=0,nil,math.huge
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find(txt:lower()) and obj:IsA("BasePart") then
                found=found+1
                local d=(r.Position-obj.Position).Magnitude
                if d<closestD then closestD=d; closest=obj end
            end
        end
        notify("Find","พบ "..found.." parts",3,"search")
        if closest then r.CFrame=CFrame.new(closest.Position+Vector3.new(0,5,0)) end
    end,
})

tabUtil:CreateButton({
    Name="💬 Join BomDev Discord",
    Callback=function()
        safe(function() setclipboard("discord.gg/4Vn8WwyV3u") end)
        safe(function() GuiService:OpenBrowserWindow("https://discord.gg/4Vn8WwyV3u") end)
        notify("Discord","เปิดแล้ว! คัดลอก invite แล้ว 💬",3,"message-circle")
    end,
})

-- ═══════════════════════════════════════════════════════════
--  TAB: DOWNLOAD
-- ═══════════════════════════════════════════════════════════

tabDl:CreateSection("🔥 BomDev Official Scripts")

local function dlCard(name,desc)
    tabDl:CreateButton({
        Name=name.."  —  "..desc,
        Callback=function()
            safe(function() setclipboard("discord.gg/4Vn8WwyV3u") end)
            safe(function() GuiService:OpenBrowserWindow("https://discord.gg/4Vn8WwyV3u") end)
            notify("Download 📥",name.." — เปิด Discord เพื่อดาวน์โหลด!",3,"download")
        end,
    })
end

dlCard("BomDev Hub v7","Latest hub — PC + Mobile")
dlCard("AutoFarm Pro","Multi-game auto farm")
dlCard("ESP Suite","Player ESP + Radar")
dlCard("Speed Kit","Movement bundle")

tabDl:CreateSection("🎮 Game Scripts")

dlCard("Blox Fruits","Auto farm + Raids + Boss")
dlCard("Pet Sim X","Pets & coins auto")
dlCard("Murder Mystery 2","ESP + Silent aim")
dlCard("Arsenal","Aimbot + ESP")
dlCard("Da Hood","Silent aim + Btoolz")
dlCard("Adopt Me","Auto bucks + pets")

tabDl:CreateSection("💬 Community")

tabDl:CreateButton({
    Name="🔗 Join BomDev Discord",
    Callback=function()
        safe(function() setclipboard("discord.gg/4Vn8WwyV3u") end)
        safe(function() GuiService:OpenBrowserWindow("https://discord.gg/4Vn8WwyV3u") end)
        notify("Discord","discord.gg/4Vn8WwyV3u — คัดลอกแล้ว! 💬",4,"message-circle")
    end,
})

-- ═══════════════════════════════════════════════════════════
--  HOTKEYS: F1 F2 F3 F4
-- ═══════════════════════════════════════════════════════════

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end

    -- F1: Fly
    if inp.KeyCode == Enum.KeyCode.F1 then
        S.fly = not S.fly
        if S.fly then
            startFly()
            notify("✈ Fly","F1 — เปิด",1,"plane")
        else
            stopFly()
            notify("✈ Fly","F1 — ปิด",1,"plane")
        end

    -- F2: Speed
    elseif inp.KeyCode == Enum.KeyCode.F2 then
        S.speed = not S.speed
        local h=hum(); if h then h.WalkSpeed = S.speed and S.speedVal or 16 end
        notify("Speed","F2 — "..(S.speed and "เปิด 💨" or "ปิด"),1,"zap")

    -- F3: God
    elseif inp.KeyCode == Enum.KeyCode.F3 then
        S.god = not S.god; killConn("god"); local h=hum()
        if S.god then
            if h then
                h.MaxHealth=math.huge; h.Health=math.huge
                h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
            end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum()
                if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
            notify("God","F3 — เปิด 🛡",1,"shield")
        else
            if h then
                h.MaxHealth=100; h.Health=100
                h:SetStateEnabled(Enum.HumanoidStateType.Dead,true)
            end
            notify("God","F3 — ปิด",1,"shield")
        end

    -- F4: NoClip
    elseif inp.KeyCode == Enum.KeyCode.F4 then
        S.noclip = not S.noclip; killConn("noclip")
        if S.noclip then
            Conns.noclip=RunService.Stepped:Connect(function()
                if not S.noclip then return end
                local c=char(); if not c then return end
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        end
        notify("NoClip","F4 — "..(S.noclip and "เปิด 👻" or "ปิด"),1,"layers")
    end
end)

-- ═══════════════════════════════════════════════════════════
--  CHARACTER RESPAWN — คืนค่า State หลัง respawn
-- ═══════════════════════════════════════════════════════════

LP.CharacterAdded:Connect(function(c)
    task.wait(1)

    if S.speed then
        local h=c:WaitForChild("Humanoid")
        h.WalkSpeed = S.speedVal
    end
    if S.jump then
        local h=c:WaitForChild("Humanoid")
        h.JumpPower = S.jumpVal
    end
    if S.noFall then
        local h=c:WaitForChild("Humanoid")
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    end
    if S.god then
        local h=c:WaitForChild("Humanoid")
        h.MaxHealth=math.huge; h.Health=math.huge
        h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
        killConn("god")
        Conns.god=RunService.Heartbeat:Connect(function()
            local hh=hum()
            if hh and hh.Health<1e10 then hh.Health=math.huge end
        end)
    end
    if S.glow then
        local hl=Instance.new("Highlight",c)
        hl.Name="BomDevGlow"; hl.FillTransparency=0.7
        hl.FillColor=Color3.fromRGB(130,70,255)
        hl.OutlineColor=Color3.fromRGB(60,185,255); hl.OutlineTransparency=0
    end
    if S.fly then
        task.wait(0.5); startFly()
    end
end)

-- ── Welcome Notification ────────────────────────────────
notify(
    "⚡ BomDev Hub v7.0",
    "โหลดสำเร็จ! Dev: BomDev\nF1=Fly  F2=Speed  F3=God  F4=NoClip",
    6,
    "zap"
)
