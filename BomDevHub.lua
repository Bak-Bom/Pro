-- BomDevHub v5.0 | Dev: BomDev | Clean Rewrite
-- UI: Loading Screen + Full Dashboard + Fixed Fly
-- ================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local CoreGui       = game:GetService("CoreGui")
local Lighting      = game:GetService("Lighting")
local StarterGui    = game:GetService("StarterGui")
local VirtualUser   = game:GetService("VirtualUser")
local TeleportSvc   = game:GetService("TeleportService")
local LP            = Players.LocalPlayer
local Cam           = workspace.CurrentCamera

-- ══════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════
local State = {
    fly        = false, flySpeed = 60,
    speed      = false, speedVal = 60,
    jump       = false, jumpVal  = 100,
    noclip     = false,
    god        = false,
    infJump    = false,
    bhop       = false,
    hitbox     = false, hitboxSz = 10,
    aimbot     = false, abRange  = 200, abSmooth = 0.15,
    esp        = false,
    tracker    = false,
    rainbow    = false,
    glow       = false,
    fire       = false,
    sparkle    = false,
    trail      = false,
    invis      = false,
    killAura   = false, kaRange  = 15,
    antiAfk    = false,
    autoFarm   = false,
    noFall     = false,
    noFrict    = false,
    walkWater  = false,
    stats      = false,
    cinema     = false,
    crosshair  = false,
}

local Conns   = {}
local SavedPos = {}
local WL      = {}
local DISCORD = "https://discord.gg/4Vn8WwyV3u"

-- helper: disconnect a named connection
local function killConn(name)
    if Conns[name] then
        pcall(function() Conns[name]:Disconnect() end)
        Conns[name] = nil
    end
end

local function safe(fn) pcall(fn) end
local function char()  return LP.Character end
local function hrp()   local c=char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════════
--  COLORS
-- ══════════════════════════════════════════
local C = {
    bg0  = Color3.fromRGB(7,   6,  15),
    bg1  = Color3.fromRGB(12,  11, 22),
    bg2  = Color3.fromRGB(17,  16, 30),
    bg3  = Color3.fromRGB(23,  21, 40),
    bg4  = Color3.fromRGB(30,  28, 50),
    bord = Color3.fromRGB(48,  44, 80),
    bor2 = Color3.fromRGB(70,  64,110),
    p1   = Color3.fromRGB(115, 65,255),
    p2   = Color3.fromRGB(165,100,255),
    b1   = Color3.fromRGB( 55,175,255),
    b2   = Color3.fromRGB( 95,215,255),
    g1   = Color3.fromRGB( 50,210,110),
    r1   = Color3.fromRGB(230, 60, 85),
    y1   = Color3.fromRGB(255,200, 55),
    txt  = Color3.fromRGB(228,222,245),
    tx2  = Color3.fromRGB(145,135,170),
    tx3  = Color3.fromRGB( 82, 76,115),
    wht  = Color3.fromRGB(255,255,255),
}

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name            = "BomDevHub_v5"
SG.ResetOnSpawn    = false
SG.IgnoreGuiInset  = true
SG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
safe(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = LP:WaitForChild("PlayerGui") end

-- ══════════════════════════════════════════
--  INSTANCE HELPERS
-- ══════════════════════════════════════════
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent = parent end
    return o
end

local function Corner(p, r)
    return New("UICorner",{CornerRadius=UDim.new(0,r or 8)},p)
end

local function Stroke(p, col, thick)
    return New("UIStroke",{Color=col or C.bord, Thickness=thick or 1},p)
end

local function Grad(p, c1, c2, rot)
    return New("UIGradient",{
        Color    = ColorSequence.new(c1,c2),
        Rotation = rot or 90,
    },p)
end

local function Pad(p,l,r,t,b)
    return New("UIPadding",{
        PaddingLeft   = UDim.new(0,l or 0),
        PaddingRight  = UDim.new(0,r or 0),
        PaddingTop    = UDim.new(0,t or 0),
        PaddingBottom = UDim.new(0,b or 0),
    },p)
end

local function Frame(props, parent)
    local f = New("Frame",{
        BackgroundColor3 = C.bg2,
        BorderSizePixel  = 0,
    }, nil)
    for k,v in pairs(props) do f[k]=v end
    if parent then f.Parent = parent end
    return f
end

local TF = TweenInfo.new(0.12, Enum.EasingStyle.Quart)
local TM = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
local TS = TweenInfo.new(0.40, Enum.EasingStyle.Quart)
local TB = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function Tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- ══════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════
local notifStack = {}

local function Notify(title, body, dur)
    local nf = Frame({
        Size = UDim2.new(0,310,0,68),
        Position = UDim2.new(1,20,1,-80),
        ZIndex = 300,
    }, SG)
    Corner(nf, 12)
    Grad(nf, Color3.fromRGB(16,12,28), C.bg2, 130)
    Stroke(nf, C.p1, 1)

    Frame({
        Size = UDim2.new(0,3,1,-16),
        Position = UDim2.new(0,8,0,8),
        BackgroundColor3 = C.p1,
        ZIndex = 301,
    }, nf)

    New("TextLabel",{
        Size=UDim2.new(1,-28,0,24), Position=UDim2.new(0,18,0,8),
        BackgroundTransparency=1,
        Text=title, TextSize=13, Font=Enum.Font.GothamBold,
        TextColor3=C.txt, TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=301,
    }, nf)

    New("TextLabel",{
        Size=UDim2.new(1,-28,0,20), Position=UDim2.new(0,18,0,34),
        BackgroundTransparency=1,
        Text=body or "", TextSize=10, Font=Enum.Font.Gotham,
        TextColor3=C.tx2, TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=301,
    }, nf)

    notifStack[#notifStack+1] = nf
    local myI = #notifStack

    local function restack()
        for i=#notifStack,1,-1 do
            local f=notifStack[i]
            if f and f.Parent then
                Tw(f, TM, {Position=UDim2.new(1,-320,1,-(( #notifStack-i+1)*76))})
            end
        end
    end

    Tw(nf, TM, {Position=UDim2.new(1,-320,1,-(myI*76))})
    restack()

    task.delay(dur or 3, function()
        Tw(nf, TM, {Position=UDim2.new(1,20,1,-(myI*76))})
        task.wait(0.35)
        for i,f in ipairs(notifStack) do
            if f==nf then table.remove(notifStack,i) break end
        end
        if nf.Parent then nf:Destroy() end
        restack()
    end)
end

-- ══════════════════════════════════════════
--  LOADING SCREEN
-- ══════════════════════════════════════════
local LS = Frame({
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=C.bg0,
    ZIndex=500,
}, SG)
Grad(LS, Color3.fromRGB(9,6,22), Color3.fromRGB(4,3,10), 135)

-- bg glows
local function mkGlow(col, sz, posX, posY, tr)
    local g = Frame({
        Size=UDim2.new(0,sz,0,sz),
        Position=UDim2.new(0,posX,0,posY),
        BackgroundColor3=col,
        BackgroundTransparency=tr,
        ZIndex=501,
    }, LS)
    Corner(g, sz//2)
    return g
end

local vp = Vector2.new(1280,720)
local gA = mkGlow(C.p1, 600, 340,  60, 0.84)
local gB = mkGlow(C.b1, 450, 700, 220, 0.88)
local gC = mkGlow(C.p2, 300, 200, 340, 0.90)

-- pulse glow
do
    local t=0
    Conns._loadGlow = RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.7
        gA.BackgroundTransparency = 0.84+math.sin(t)*0.06
        gB.BackgroundTransparency = 0.88+math.sin(t*1.2)*0.05
        gC.BackgroundTransparency = 0.90+math.sin(t*0.9)*0.04
    end)
end

-- grid lines decoration
for i=0,8 do
    local ln = Frame({
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,0,i*(SG.AbsoluteSize.Y or 720)//8),
        BackgroundColor3=Color3.fromRGB(80,70,130),
        BackgroundTransparency=0.94, ZIndex=501,
    }, LS)
end
for i=0,12 do
    local ln = Frame({
        Size=UDim2.new(0,1,1,0),
        Position=UDim2.new(0,i*(SG.AbsoluteSize.X or 1280)//12,0,0),
        BackgroundColor3=Color3.fromRGB(80,70,130),
        BackgroundTransparency=0.94, ZIndex=501,
    }, LS)
end

-- center card
local LSCard = Frame({
    Size=UDim2.new(0,380,0,340),
    Position=UDim2.new(0.5,-190,0.5,-170),
    BackgroundColor3=C.bg1,
    ZIndex=502,
}, LS)
Corner(LSCard, 22)
Grad(LSCard, Color3.fromRGB(16,11,32), C.bg1, 150)
Stroke(LSCard, C.p1, 1.5)

-- animated stroke
do
    local s = New("UIStroke",{Thickness=1.5, Color=C.p1},LSCard)
    local t=0
    Conns._cardStroke = RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.4
        local r = (math.sin(t)*0.5+0.5)
        s.Color = C.p1:Lerp(C.b1, r)
    end)
end

-- logo
local lsLogo = Frame({
    Size=UDim2.new(0,76,0,76),
    Position=UDim2.new(0.5,-38,0,28),
    BackgroundColor3=C.p1, ZIndex=503,
}, LSCard)
Corner(lsLogo, 22)
Grad(lsLogo, C.p1, C.b1, 135)

New("TextLabel",{
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    Text="⚡", TextSize=40,
    Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=504,
}, lsLogo)

-- logo pulse
do
    local t=0
    Conns._logoPulse = RunService.Heartbeat:Connect(function(dt)
        t=t+dt*1.5
        local s=1+math.sin(t)*0.06
        lsLogo.Size = UDim2.new(0,76*s,0,76*s)
        lsLogo.Position = UDim2.new(0.5,-38*s,0,28-(76*(s-1)/2))
    end)
end

New("TextLabel",{
    Size=UDim2.new(1,-20,0,32),
    Position=UDim2.new(0,10,0,118),
    BackgroundTransparency=1,
    Text="BomDev Hub", TextSize=24,
    Font=Enum.Font.GothamBold,
    TextColor3=C.txt,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=503,
}, LSCard)

New("TextLabel",{
    Size=UDim2.new(1,-20,0,18),
    Position=UDim2.new(0,10,0,152),
    BackgroundTransparency=1,
    Text="v5.0  ·  Dev: BomDev",
    TextSize=11, Font=Enum.Font.Gotham,
    TextColor3=C.tx3,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=503,
}, LSCard)

-- progress bar background
local lsBarBg = Frame({
    Size=UDim2.new(1,-44,0,6),
    Position=UDim2.new(0,22,0,192),
    BackgroundColor3=C.bg3,
    ZIndex=503,
}, LSCard)
Corner(lsBarBg, 3)

local lsBar = Frame({
    Size=UDim2.new(0,0,1,0),
    BackgroundColor3=C.p1,
    ZIndex=504,
}, lsBarBg)
Corner(lsBar, 3)
Grad(lsBar, C.p1, C.b1, 0)

-- status text
local lsStatus = New("TextLabel",{
    Size=UDim2.new(1,-20,0,16),
    Position=UDim2.new(0,10,0,206),
    BackgroundTransparency=1,
    Text="กำลังเริ่มต้น...",
    TextSize=10, Font=Enum.Font.Gotham,
    TextColor3=C.tx3,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=503,
}, LSCard)

-- dots
local lsDots = {}
for i=1,5 do
    local d = Frame({
        Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0.5,-28+(i-1)*14,0,232),
        BackgroundColor3=C.bord, ZIndex=503,
    }, LSCard)
    Corner(d,4)
    lsDots[i]=d
end

Frame({
    Size=UDim2.new(1,-40,0,1),
    Position=UDim2.new(0,20,0,262),
    BackgroundColor3=C.bord, ZIndex=503,
}, LSCard)

New("TextLabel",{
    Size=UDim2.new(1,-20,0,14),
    Position=UDim2.new(0,10,0,272),
    BackgroundTransparency=1,
    Text="discord.gg/4Vn8WwyV3u",
    TextSize=9, Font=Enum.Font.Gotham,
    TextColor3=C.tx3,
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=503,
}, LSCard)

-- dot animation
do
    local t=0
    Conns._dots = RunService.Heartbeat:Connect(function(dt)
        t=t+dt*2.5
        for i,d in ipairs(lsDots) do
            local phase=(t-(i-1)*0.3)%(#lsDots*0.4)
            local bright=math.max(0,1-math.abs(phase-0.3)*5)
            d.BackgroundColor3=C.p1:Lerp(C.bord,1-bright)
        end
    end)
end

-- loading steps
local loadSteps = {
    {prog=0.12, txt="กำลังสร้าง UI..."},
    {prog=0.28, txt="กำลังโหลดระบบบิน..."},
    {prog=0.44, txt="กำลังโหลดระบบ Combat..."},
    {prog=0.60, txt="กำลังโหลดระบบ Visual..."},
    {prog=0.75, txt="กำลังโหลดระบบ Teleport..."},
    {prog=0.88, txt="กำลังโหลด Download..."},
    {prog=1.00, txt="พร้อมแล้ว! 🚀"},
}

local function doLoad()
    for _,step in ipairs(loadSteps) do
        task.wait(0.16)
        Tw(lsBar, TM, {Size=UDim2.new(step.prog,0,1,0)})
        lsStatus.Text = step.txt
    end
    task.wait(0.3)

    killConn("_dots")
    killConn("_loadGlow")
    killConn("_cardStroke")
    killConn("_logoPulse")

    -- fade out
    Tw(LSCard, TM, {BackgroundTransparency=1})
    for _,d in ipairs(LSCard:GetDescendants()) do
        local ok=pcall(function() Tw(d,TM,{BackgroundTransparency=1,TextTransparency=1}) end)
    end
    task.wait(0.28)
    Tw(LS, TM, {BackgroundTransparency=1})
    task.wait(0.28)
    LS:Destroy()

    Notify("⚡ BomDev Hub v5.0","โหลดสำเร็จ! ] = ซ่อน/แสดง",4)
end

-- ══════════════════════════════════════════
--  MAIN FRAME
-- ══════════════════════════════════════════
local MF = Frame({
    Size=UDim2.new(0,750,0,530),
    Position=UDim2.new(0.5,-375,0.5,-265),
    BackgroundColor3=C.bg0,
    Active=true, Draggable=true,
    ZIndex=10,
}, SG)
Corner(MF,16)
Grad(MF, Color3.fromRGB(10,8,22), Color3.fromRGB(6,5,14), 150)

-- animated border
do
    local sk = Stroke(MF, C.p1, 1.5)
    local t=0
    RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.35
        sk.Color = C.p1:Lerp(C.b1,(math.sin(t)*0.5+0.5))
    end)
end

-- ══════════════════════════════════════════
--  TOPBAR
-- ══════════════════════════════════════════
local TB2 = Frame({
    Size=UDim2.new(1,0,0,54),
    BackgroundColor3=C.bg1,
    ZIndex=11,
}, MF)
Corner(TB2, 16)
Grad(TB2, Color3.fromRGB(16,12,32), C.bg1, 90)

Frame({
    Size=UDim2.new(1,0,0.5,0),
    Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=C.bg1, ZIndex=11,
}, TB2)

-- accent line
local acLine = Frame({
    Size=UDim2.new(1,0,0,2),
    Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=C.p1, ZIndex=12,
}, TB2)

do
    local g = New("UIGradient",{
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.p1),
            ColorSequenceKeypoint.new(0.5,C.b1),
            ColorSequenceKeypoint.new(1,C.p1),
        }),
        Rotation=0,
    }, acLine)
    local t=0
    RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.5
        local mid=((math.sin(t)*0.5+0.5)*0.8+0.1)
        local ok=pcall(function()
            g.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,C.p1),
                ColorSequenceKeypoint.new(mid,C.b1),
                ColorSequenceKeypoint.new(1,C.p1),
            })
        end)
    end)
end

-- logo
local logoF = Frame({
    Size=UDim2.new(0,38,0,38),
    Position=UDim2.new(0,12,0.5,-19),
    BackgroundColor3=C.p1, ZIndex=12,
}, TB2)
Corner(logoF,11)
Grad(logoF,C.p1,C.b1,135)
New("TextLabel",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="⚡", TextSize=20, Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=13,
}, logoF)

New("TextLabel",{
    Size=UDim2.new(0,180,0,24),
    Position=UDim2.new(0,58,0,7),
    BackgroundTransparency=1,
    Text="BomDev Hub", TextSize=17,
    Font=Enum.Font.GothamBold,
    TextColor3=C.txt,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=12,
}, TB2)

New("TextLabel",{
    Size=UDim2.new(0,260,0,14),
    Position=UDim2.new(0,58,0,32),
    BackgroundTransparency=1,
    Text="v5.0  ·  Dev: BomDev  ·  ] ซ่อน/แสดง",
    TextSize=9, Font=Enum.Font.Gotham,
    TextColor3=C.tx3,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=12,
}, TB2)

-- close / minimize / discord buttons
local function mkTopBtn(txt, offX, bg, hov, fn)
    local b = New("TextButton",{
        Size=UDim2.new(0,30,0,30),
        Position=UDim2.new(1,offX,0.5,-15),
        BackgroundColor3=bg,
        Text=txt, TextSize=12,
        Font=Enum.Font.GothamBold,
        TextColor3=C.txt, BorderSizePixel=0, ZIndex=12,
    }, TB2)
    Corner(b,8)
    Stroke(b,C.bord,1)
    b.MouseEnter:Connect(function() Tw(b,TF,{BackgroundColor3=hov}) end)
    b.MouseLeave:Connect(function() Tw(b,TF,{BackgroundColor3=bg}) end)
    b.MouseButton1Click:Connect(fn)
    return b
end

mkTopBtn("✕",-40,Color3.fromRGB(135,38,55),Color3.fromRGB(195,55,78),function()
    Tw(MF,TM,{BackgroundTransparency=1,Size=UDim2.new(0,750,0,0)})
    task.wait(0.3); SG:Destroy()
end)

local minimized=false
local ContentWrap = Frame({
    Size=UDim2.new(1,0,1,-56),
    Position=UDim2.new(0,0,0,56),
    BackgroundTransparency=1, ZIndex=10,
}, MF)

mkTopBtn("─",-76,C.bg3,C.bg4,function()
    minimized=not minimized
    ContentWrap.Visible=not minimized
    Tw(MF,TM,{Size=minimized and UDim2.new(0,750,0,56) or UDim2.new(0,750,0,530)})
end)

mkTopBtn("D",-116,Color3.fromRGB(50,65,180),Color3.fromRGB(70,88,215),function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","คัดลอกและเปิดแล้ว!",3)
end)

-- ══════════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════════
local Sidebar = Frame({
    Size=UDim2.new(0,168,1,0),
    BackgroundColor3=C.bg1,
    ZIndex=11,
}, ContentWrap)
Grad(Sidebar,C.bg1,Color3.fromRGB(9,8,18),180)

Frame({
    Size=UDim2.new(0,1,1,0),
    Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.bord, ZIndex=12,
}, Sidebar)

-- player info box
local PIBox = Frame({
    Size=UDim2.new(1,0,0,66),
    BackgroundColor3=C.bg2, ZIndex=12,
}, Sidebar)
Grad(PIBox,Color3.fromRGB(18,12,36),C.bg2,135)

local pIcon = Frame({
    Size=UDim2.new(0,36,0,36),
    Position=UDim2.new(0,10,0.5,-18),
    BackgroundColor3=C.p1, ZIndex=13,
}, PIBox)
Corner(pIcon,18)
Grad(pIcon,C.p1,C.b1,135)

New("TextLabel",{
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    Text=string.upper(string.sub(LP.Name,1,1)),
    TextSize=17, Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=14,
}, pIcon)

New("TextLabel",{
    Size=UDim2.new(1,-56,0,20),
    Position=UDim2.new(0,52,0,13),
    BackgroundTransparency=1,
    Text=LP.Name, TextSize=12,
    Font=Enum.Font.GothamBold,
    TextColor3=C.txt,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13,
}, PIBox)

New("TextLabel",{
    Size=UDim2.new(1,-56,0,14),
    Position=UDim2.new(0,52,0,35),
    BackgroundTransparency=1,
    Text="ID: "..LP.UserId,
    TextSize=9, Font=Enum.Font.Gotham,
    TextColor3=C.tx3,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13,
}, PIBox)

Frame({
    Size=UDim2.new(1,0,0,1),
    Position=UDim2.new(0,0,1,-1),
    BackgroundColor3=C.bord, ZIndex=13,
}, PIBox)

-- nav scroll
local NavScroll = New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-108),
    Position=UDim2.new(0,0,0,66),
    BackgroundTransparency=1,
    ScrollBarThickness=2,
    ScrollBarImageColor3=C.p1,
    CanvasSize=UDim2.new(0,0,0,0),
    ZIndex=12, BorderSizePixel=0,
}, Sidebar)
Pad(NavScroll,5,5,5,5)

local NavLayout = New("UIListLayout",{
    Padding=UDim.new(0,3),
    FillDirection=Enum.FillDirection.Vertical,
    HorizontalAlignment=Enum.HorizontalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder,
}, NavScroll)

NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavScroll.CanvasSize=UDim2.new(0,0,0,NavLayout.AbsoluteContentSize.Y+12)
end)

New("TextLabel",{
    Size=UDim2.new(1,0,0,34),
    Position=UDim2.new(0,0,1,-38),
    BackgroundTransparency=1,
    Text="BomDev v5.0",
    TextSize=9, Font=Enum.Font.Gotham,
    TextColor3=C.tx3, ZIndex=12,
    TextXAlignment=Enum.TextXAlignment.Center,
}, Sidebar)

-- page area
local PageArea = Frame({
    Size=UDim2.new(1,-175,1,-8),
    Position=UDim2.new(0,172,0,4),
    BackgroundTransparency=1, ZIndex=11,
}, ContentWrap)

-- ══════════════════════════════════════════
--  PAGE SYSTEM
-- ══════════════════════════════════════════
local Pages   = {}
local NavBtns = {}
local curPage = nil

local NAV_ITEMS = {
    {name="Movement", icon="🏃"},
    {name="Combat",   icon="⚔️"},
    {name="Visual",   icon="👁️"},
    {name="Player",   icon="👤"},
    {name="Teleport", icon="🔀"},
    {name="Utils",    icon="🔧"},
    {name="Download", icon="📥"},
    {name="Settings", icon="⚙️"},
}

local function switchPage(name)
    if curPage==name then return end
    if curPage then
        Pages[curPage].Visible=false
        local ob=NavBtns[curPage]
        if ob then
            Tw(ob.bg,TF,{BackgroundTransparency=1})
            Tw(ob.bar,TF,{BackgroundTransparency=1})
            Tw(ob.namL,TF,{TextColor3=C.tx2})
            Tw(ob.icnL,TF,{TextColor3=C.tx3})
        end
    end
    curPage=name
    Pages[name].Visible=true
    local nb=NavBtns[name]
    if nb then
        Tw(nb.bg,TF,{BackgroundTransparency=0})
        Tw(nb.bar,TF,{BackgroundTransparency=0})
        Tw(nb.namL,TF,{TextColor3=C.txt})
        Tw(nb.icnL,TF,{TextColor3=C.b1})
    end
end

for idx,item in ipairs(NAV_ITEMS) do
    -- page
    local pg = New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        ScrollBarThickness=3,
        ScrollBarImageColor3=C.p1,
        CanvasSize=UDim2.new(0,0,0,0),
        Visible=false, ZIndex=11,
        BorderSizePixel=0,
    }, PageArea)
    Pad(pg,2,6,4,8)

    local pgLayout=New("UIListLayout",{
        Padding=UDim.new(0,5),
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
    }, pg)

    pgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize=UDim2.new(0,0,0,pgLayout.AbsoluteContentSize.Y+20)
    end)

    Pages[item.name]=pg

    -- nav button
    local navRow=Frame({
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=C.bg3,
        BackgroundTransparency=1,
        ZIndex=12,
        LayoutOrder=idx,
    }, NavScroll)
    Corner(navRow,9)

    local bar=Frame({
        Size=UDim2.new(0,3,0.55,0),
        Position=UDim2.new(0,0,0.22,0),
        BackgroundColor3=C.p1,
        BackgroundTransparency=1,
        ZIndex=14,
    }, navRow)
    Corner(bar,2)
    Grad(bar,C.p1,C.b1,90)

    local icnL=New("TextLabel",{
        Size=UDim2.new(0,24,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text=item.icon, TextSize=14,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.tx3, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Center,
    }, navRow)

    local namL=New("TextLabel",{
        Size=UDim2.new(1,-42,1,0),
        Position=UDim2.new(0,38,0,0),
        BackgroundTransparency=1,
        Text=item.name, TextSize=12,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, navRow)

    local clk=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="", ZIndex=15,
    }, navRow)

    NavBtns[item.name]={bg=navRow,bar=bar,icnL=icnL,namL=namL}

    local pageName=item.name
    clk.MouseButton1Click:Connect(function() switchPage(pageName) end)
    clk.MouseEnter:Connect(function()
        if curPage~=pageName then
            Tw(navRow,TF,{BackgroundTransparency=0.65})
            Tw(namL,TF,{TextColor3=C.txt})
        end
    end)
    clk.MouseLeave:Connect(function()
        if curPage~=pageName then
            Tw(navRow,TF,{BackgroundTransparency=1})
            Tw(namL,TF,{TextColor3=C.tx2})
        end
    end)
end

-- ══════════════════════════════════════════
--  UI COMPONENT BUILDERS
-- ══════════════════════════════════════════

local function Section(page, text)
    local f=Frame({
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=C.bg2, ZIndex=12,
    }, page)
    Corner(f,6)
    Grad(f,Color3.fromRGB(20,15,40),C.bg2,135)

    Frame({
        Size=UDim2.new(0,3,0.55,0),
        Position=UDim2.new(0,8,0.22,0),
        BackgroundColor3=C.p1, ZIndex=13,
    }, f)

    New("TextLabel",{
        Size=UDim2.new(1,-24,1,0),
        Position=UDim2.new(0,18,0,0),
        BackgroundTransparency=1,
        Text=text, TextSize=10,
        Font=Enum.Font.GothamBold,
        TextColor3=C.b1, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
    return f
end

local function Spacer(page)
    Frame({
        Size=UDim2.new(1,0,0,1),
        BackgroundColor3=C.bord, ZIndex=12,
    }, page)
end

local function Toggle(page, text, default, cb)
    local row=Frame({
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.bg3, ZIndex=12,
    }, page)
    Corner(row,9)
    Grad(row,C.bg3,Color3.fromRGB(15,14,25),110)

    New("TextLabel",{
        Size=UDim2.new(1,-66,1,0),
        Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.txt, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)

    local track=Frame({
        Size=UDim2.new(0,44,0,24),
        Position=UDim2.new(1,-58,0.5,-12),
        BackgroundColor3=Color3.fromRGB(28,26,48),
        ZIndex=13,
    }, row)
    Corner(track,12)
    Stroke(track,C.bord,1)

    local thumb=Frame({
        Size=UDim2.new(0,18,0,18),
        Position=UDim2.new(0,3,0.5,-9),
        BackgroundColor3=C.tx3, ZIndex=14,
    }, track)
    Corner(thumb,9)

    local state=default or false

    local function setVisual(animate)
        local info = animate and TweenInfo.new(0.2,Enum.EasingStyle.Quart) or TweenInfo.new(0)
        if state then
            Tw(thumb,info,{Position=UDim2.new(1,-21,0.5,-9),BackgroundColor3=C.b1})
            Tw(track,info,{BackgroundColor3=Color3.fromRGB(20,44,68)})
        else
            Tw(thumb,info,{Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=C.tx3})
            Tw(track,info,{BackgroundColor3=Color3.fromRGB(28,26,48)})
        end
    end

    setVisual(false)

    local clk=New("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="", ZIndex=15,
    }, row)

    clk.MouseButton1Click:Connect(function()
        state=not state
        setVisual(true)
        if cb then cb(state) end
    end)
    row.MouseEnter:Connect(function() Tw(row,TF,{BackgroundColor3=Color3.fromRGB(22,20,38)}) end)
    row.MouseLeave:Connect(function() Tw(row,TF,{BackgroundColor3=C.bg3}) end)

    return {
        setState=function(v) state=v; setVisual(true) end,
        getState=function() return state end,
    }
end

local function Button(page, text, cb, accent)
    local bg=accent and C.p1 or C.bg4
    local hov=accent and C.p2 or Color3.fromRGB(28,26,46)
    local btn=New("TextButton",{
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=bg,
        Text=text, TextSize=12,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.txt, BorderSizePixel=0, ZIndex=12,
    }, page)
    Corner(btn,9)
    if accent then
        Grad(btn,C.p1,C.b1,90)
    else
        Grad(btn,C.bg4,Color3.fromRGB(15,14,26),110)
        Stroke(btn,C.bord,1)
    end
    btn.MouseEnter:Connect(function() Tw(btn,TF,{BackgroundColor3=hov}) end)
    btn.MouseLeave:Connect(function() Tw(btn,TF,{BackgroundColor3=bg}) end)
    btn.MouseButton1Down:Connect(function()
        Tw(btn,TweenInfo.new(0.08),{BackgroundColor3=accent and Color3.fromRGB(88,48,200) or Color3.fromRGB(34,28,64)})
    end)
    btn.MouseButton1Up:Connect(function()
        Tw(btn,TweenInfo.new(0.08),{BackgroundColor3=hov})
    end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

local function Slider(page, text, vmin, vmax, vdef, suf, cb)
    local con=Frame({
        Size=UDim2.new(1,0,0,56),
        BackgroundColor3=C.bg3, ZIndex=12,
    }, page)
    Corner(con,9)
    Grad(con,C.bg3,Color3.fromRGB(15,14,25),110)

    New("TextLabel",{
        Size=UDim2.new(0.6,0,0,26),
        Position=UDim2.new(0,14,0,4),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.txt, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, con)

    local valL=New("TextLabel",{
        Size=UDim2.new(0.4,-14,0,26),
        Position=UDim2.new(0.6,0,0,4),
        BackgroundTransparency=1,
        Text=tostring(vdef)..(suf or ""),
        TextSize=11, Font=Enum.Font.GothamMedium,
        TextColor3=C.b1, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, con)

    local sbg=Frame({
        Size=UDim2.new(1,-24,0,5),
        Position=UDim2.new(0,12,0,41),
        BackgroundColor3=Color3.fromRGB(24,22,40),
        ZIndex=13,
    }, con)
    Corner(sbg,3)

    local sfill=Frame({
        Size=UDim2.new((vdef-vmin)/(vmax-vmin),0,1,0),
        BackgroundColor3=C.p1, ZIndex=14,
    }, sbg)
    Corner(sfill,3)
    Grad(sfill,C.p1,C.b1,0)

    local sknob=Frame({
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new((vdef-vmin)/(vmax-vmin),-7,0.5,-7),
        BackgroundColor3=C.wht, ZIndex=15,
    }, sbg)
    Corner(sknob,7)
    Stroke(sknob,C.p1,1.5)

    local cur=vdef
    local dragging=false

    local function update(v)
        v=math.clamp(v,vmin,vmax)
        cur=math.floor(v+0.5)
        local r=(cur-vmin)/(vmax-vmin)
        sfill.Size=UDim2.new(r,0,1,0)
        sknob.Position=UDim2.new(r,-7,0.5,-7)
        valL.Text=tostring(cur)..(suf or "")
        if cb then cb(cur) end
    end

    local hit=New("TextButton",{
        Size=UDim2.new(1,20,1,20),
        Position=UDim2.new(0,-10,0,-10),
        BackgroundTransparency=1,
        Text="", ZIndex=16,
    }, sbg)

    hit.MouseButton1Down:Connect(function() dragging=true end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement then
            local bx=sbg.AbsolutePosition.X
            local bw=sbg.AbsoluteSize.X
            update(vmin+math.clamp((inp.Position.X-bx)/bw,0,1)*(vmax-vmin))
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)

    return {getValue=function() return cur end}
end

local function Input(page, text, placeholder, cb)
    local con=Frame({
        Size=UDim2.new(1,0,0,58),
        BackgroundColor3=C.bg3, ZIndex=12,
    }, page)
    Corner(con,9)

    New("TextLabel",{
        Size=UDim2.new(1,-14,0,22),
        Position=UDim2.new(0,14,0,4),
        BackgroundTransparency=1,
        Text=text, TextSize=11,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, con)

    local ibox=New("TextBox",{
        Size=UDim2.new(1,-28,0,24),
        Position=UDim2.new(0,14,0,28),
        BackgroundColor3=Color3.fromRGB(15,14,26),
        BorderSizePixel=0,
        Text="", PlaceholderText=placeholder or "",
        PlaceholderColor3=C.tx3,
        TextSize=11, Font=Enum.Font.Gotham,
        TextColor3=C.txt,
        ClearTextOnFocus=false,
        ZIndex=13,
    }, con)
    Corner(ibox,5)
    Stroke(ibox,C.bord,1)
    Pad(ibox,8,0,0,0)

    ibox.FocusLost:Connect(function(enter)
        if enter and cb then cb(ibox.Text) end
    end)
    return ibox
end

local function Dropdown(page, text, opts, cb)
    local con=Frame({
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.bg3, ZIndex=12,
        ClipsDescendants=false,
    }, page)
    Corner(con,9)

    New("TextLabel",{
        Size=UDim2.new(0.5,0,1,0),
        Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.txt, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, con)

    local selF=Frame({
        Size=UDim2.new(0.45,-6,0.7,0),
        Position=UDim2.new(0.53,0,0.15,0),
        BackgroundColor3=Color3.fromRGB(14,13,24),
        ZIndex=13,
    }, con)
    Corner(selF,5)
    Stroke(selF,C.bord,1)
    Pad(selF,8,4,0,0)

    local selL=New("TextLabel",{
        Size=UDim2.new(1,-18,1,0),
        BackgroundTransparency=1,
        Text=opts[1] or "—",
        TextSize=10, Font=Enum.Font.Gotham,
        TextColor3=C.tx2, ZIndex=14,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, selF)

    New("TextLabel",{
        Size=UDim2.new(0,16,1,0),
        Position=UDim2.new(1,-17,0,0),
        BackgroundTransparency=1,
        Text="▾", TextSize=10,
        Font=Enum.Font.GothamBold,
        TextColor3=C.tx3, ZIndex=14,
    }, selF)

    local dropF=Frame({
        Size=UDim2.new(0.45,-6,0,0),
        Position=UDim2.new(0.53,0,1,3),
        BackgroundColor3=Color3.fromRGB(13,12,23),
        ZIndex=30, ClipsDescendants=true,
    }, con)
    Corner(dropF,7)
    Stroke(dropF,C.p1,1)

    local dLayout=New("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
    }, dropF)

    local isOpen=false

    local function populate(list)
        for _,ch in ipairs(dropF:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _,opt in ipairs(list) do
            local ob=New("TextButton",{
                Size=UDim2.new(1,0,0,26),
                BackgroundColor3=Color3.fromRGB(13,12,23),
                Text=opt, TextSize=10,
                Font=Enum.Font.Gotham,
                TextColor3=C.txt, BorderSizePixel=0, ZIndex=31,
                TextXAlignment=Enum.TextXAlignment.Left,
            }, dropF)
            Pad(ob,10,0,0,0)
            ob.MouseEnter:Connect(function()
                Tw(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(24,20,46)})
            end)
            ob.MouseLeave:Connect(function()
                Tw(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(13,12,23)})
            end)
            local captured=opt
            ob.MouseButton1Click:Connect(function()
                selL.Text=captured
                if cb then cb(captured) end
                isOpen=false
                Tw(dropF,TF,{Size=UDim2.new(0.45,-6,0,0)})
            end)
        end
    end

    populate(opts)

    local toggle=New("TextButton",{
        Size=UDim2.new(0.45,-6,0.7,0),
        Position=UDim2.new(0.53,0,0.15,0),
        BackgroundTransparency=1,
        Text="", ZIndex=15,
    }, con)

    toggle.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        local cnt=0
        for _,ch in ipairs(dropF:GetChildren()) do
            if ch:IsA("TextButton") then cnt=cnt+1 end
        end
        Tw(dropF,TF,{
            Size=isOpen and UDim2.new(0.45,-6,0,cnt*26) or UDim2.new(0.45,-6,0,0)
        })
    end)

    return {
        Set=function(list)
            populate(list)
            isOpen=false
            Tw(dropF,TF,{Size=UDim2.new(0.45,-6,0,0)})
            selL.Text=list[1] or "—"
        end
    }
end

-- ══════════════════════════════════════════
--  MOVEMENT PAGE
-- ══════════════════════════════════════════
local pMov=Pages["Movement"]

-- FLY (clean implementation)
Section(pMov,"✈  FLIGHT")

local function startFly()
    local c=char(); if not c then return end
    local r=hrp();  if not r then return end
    local h=hum();  if not h then return end

    h.PlatformStand=true

    local bv=Instance.new("BodyVelocity")
    bv.Name="BDFlyBV"
    bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=Vector3.new(0,0,0)
    bv.Parent=r

    local bg=Instance.new("BodyGyro")
    bg.Name="BDFlyBG"
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.P=5e3; bg.D=400
    bg.CFrame=r.CFrame
    bg.Parent=r

    Conns.fly=RunService.Heartbeat:Connect(function()
        if not State.fly then return end
        local rNow=hrp()
        if not rNow then return end
        local bvNow=rNow:FindFirstChild("BDFlyBV")
        local bgNow=rNow:FindFirstChild("BDFlyBG")
        if not (bvNow and bgNow) then return end

        local cf   = Cam.CFrame
        local look = cf.LookVector
        local rght = cf.RightVector
        local vel  = Vector3.new(0,0,0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+look*State.flySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-look*State.flySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+rght*State.flySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-rght*State.flySpeed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vel=vel+Vector3.new(0,State.flySpeed*0.75,0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or
           UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel=vel-Vector3.new(0,State.flySpeed*0.75,0)
        end

        bvNow.Velocity=vel

        local flat=Vector3.new(look.X,0,look.Z)
        if flat.Magnitude>0.01 then
            bgNow.CFrame=CFrame.new(rNow.Position,rNow.Position+flat)
        end
    end)
end

local function stopFly()
    killConn("fly")
    local r=hrp()
    if r then
        local bvNow=r:FindFirstChild("BDFlyBV")
        local bgNow=r:FindFirstChild("BDFlyBG")
        if bvNow then bvNow:Destroy() end
        if bgNow then bgNow:Destroy() end
    end
    local h=hum()
    if h then h.PlatformStand=false end
end

Toggle(pMov,"Fly Mode",false,function(v)
    State.fly=v
    if v then startFly(); Notify("Fly","เปิด — WASD+Space+Ctrl",3)
    else stopFly(); Notify("Fly","ปิด",2) end
end)

Slider(pMov,"Fly Speed",5,500,60,"",function(v)
    State.flySpeed=v
end)

Spacer(pMov)
Section(pMov,"🏃  SPEED & JUMP")

Toggle(pMov,"Super Speed",false,function(v)
    State.speed=v
    local h=hum()
    if h then h.WalkSpeed=v and State.speedVal or 16 end
    Notify("Speed",v and "เปิด" or "ปิด",2)
end)

Slider(pMov,"Walk Speed",16,500,60,"",function(v)
    State.speedVal=v
    if State.speed then local h=hum() if h then h.WalkSpeed=v end end
end)

Toggle(pMov,"High Jump",false,function(v)
    State.jump=v
    local h=hum()
    if h then h.JumpPower=v and State.jumpVal or 50 end
    Notify("High Jump",v and "เปิด" or "ปิด",2)
end)

Slider(pMov,"Jump Power",50,1000,100,"",function(v)
    State.jumpVal=v
    if State.jump then local h=hum() if h then h.JumpPower=v end end
end)

Toggle(pMov,"Infinite Jump",false,function(v)
    State.infJump=v
    killConn("infJump")
    if v then
        Conns.infJump=UIS.JumpRequest:Connect(function()
            local h=hum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    Notify("Infinite Jump",v and "เปิด" or "ปิด",2)
end)

Toggle(pMov,"BunnyHop",false,function(v)
    State.bhop=v
    killConn("bhop")
    if v then
        Conns.bhop=RunService.Heartbeat:Connect(function()
            if not State.bhop then return end
            local h=hum()
            if h and h:GetState()==Enum.HumanoidStateType.Landed then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
    Notify("BunnyHop",v and "เปิด" or "ปิด",2)
end)

Spacer(pMov)
Section(pMov,"🧱  PHYSICS")

Toggle(pMov,"NoClip",false,function(v)
    State.noclip=v
    killConn("noclip")
    if v then
        Conns.noclip=RunService.Stepped:Connect(function()
            if not State.noclip then return end
            local c=char(); if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    end
    Notify("NoClip",v and "เปิด" or "ปิด",2)
end)

Toggle(pMov,"No Friction",false,function(v)
    State.noFrict=v
    killConn("noFrict")
    if v then
        Conns.noFrict=RunService.Heartbeat:Connect(function()
            if not State.noFrict then return end
            local c=char(); if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CustomPhysicalProperties=PhysicalProperties.new(0.3,0,0,0,0)
                end
            end
        end)
    end
    Notify("No Friction",v and "เปิด" or "ปิด",2)
end)

Toggle(pMov,"No Fall Damage",false,function(v)
    State.noFall=v
    local h=hum()
    if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,not v) end
    Notify("No Fall Damage",v and "เปิด" or "ปิด",2)
end)

Spacer(pMov)
Section(pMov,"⚡  QUICK ACTIONS")

Button(pMov,"💨 Dash Forward 30 studs",function()
    local r=hrp(); if r then r.CFrame=r.CFrame+r.CFrame.LookVector*30 end
end)

Button(pMov,"🚀 Super Jump (launch)",function()
    local r=hrp(); if r then r.Velocity=Vector3.new(0,200,0) end
end)

Button(pMov,"⚡ Speed Burst 3s",function()
    local h=hum(); if not h then return end
    local orig=h.WalkSpeed; h.WalkSpeed=500
    Notify("Speed Burst","3 วินาที!",2)
    task.delay(3,function() if h and h.Parent then h.WalkSpeed=orig end end)
end)

Spacer(pMov)
Section(pMov,"🌍  GRAVITY")

Slider(pMov,"Gravity",0,300,196,"",function(v) workspace.Gravity=v end)

Button(pMov,"Low Gravity (40)",function()
    workspace.Gravity=40; Notify("Gravity","Low 🌙",2)
end)
Button(pMov,"Normal Gravity (196)",function()
    workspace.Gravity=196; Notify("Gravity","Normal",2)
end)

-- ══════════════════════════════════════════
--  COMBAT PAGE
-- ══════════════════════════════════════════
local pCom=Pages["Combat"]

Section(pCom,"🎯  AIMBOT")

Toggle(pCom,"Aimbot",false,function(v)
    State.aimbot=v
    killConn("aimbot")
    if v then
        Conns.aimbot=RunService.RenderStepped:Connect(function()
            if not State.aimbot then return end
            local best,bestD=nil,math.huge
            local myR=hrp(); if not myR then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p==LP then continue end
                if (function() for _,n in ipairs(WL) do if n==p.Name then return true end end return false end)() then continue end
                local c=p.Character; if not c then continue end
                local head=c:FindFirstChild("Head"); if not head then continue end
                local sp,onS=Cam:WorldToScreenPoint(head.Position)
                if not onS then continue end
                local dist=(Cam.CFrame.Position-head.Position).Magnitude
                if dist>State.abRange then continue end
                local sc=Vector2.new(sp.X,sp.Y)
                local ctr=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
                local sd=(sc-ctr).Magnitude
                if sd<bestD then bestD=sd; best=head end
            end
            if best then
                local t=CFrame.new(Cam.CFrame.Position,best.Position)
                Cam.CFrame=Cam.CFrame:Lerp(t,State.abSmooth)
            end
        end)
    end
    Notify("Aimbot",v and "เปิด" or "ปิด",2)
end)

Slider(pCom,"Aimbot Range",50,1000,200," studs",function(v) State.abRange=v end)
Slider(pCom,"Aimbot Smooth",1,100,15,"%",function(v) State.abSmooth=v/100 end)

Spacer(pCom)
Section(pCom,"🛡  WHITELIST")

local wlPDD=Dropdown(pCom,"Add to WL",
    (function() local t={} for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end if #t==0 then t={"(ว่าง)"} end return t end)(),
    function(name)
        if name=="(ว่าง)" then return end
        for _,n in ipairs(WL) do if n==name then Notify("WL",name.." มีแล้ว",2) return end end
        WL[#WL+1]=name; Notify("WL","เพิ่ม "..name,2)
    end
)

Button(pCom,"Refresh Player List",function()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end
    if #t==0 then t={"(ว่าง)"} end
    wlPDD.Set(t)
end)

Button(pCom,"Clear Whitelist",function()
    WL={}; Notify("WL","ล้างแล้ว",2)
end)

Spacer(pCom)
Section(pCom,"💥  HITBOX")

Toggle(pCom,"Hitbox Expander",false,function(v)
    State.hitbox=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart")
        if r then r.Size=v and Vector3.new(State.hitboxSz,State.hitboxSz,State.hitboxSz) or Vector3.new(2,2,1) end
    end
    Notify("Hitbox",v and "เปิด" or "ปิด",2)
end)

Slider(pCom,"Hitbox Size",1,50,10,"",function(v)
    State.hitboxSz=v
    if not State.hitbox then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart")
        if r then r.Size=Vector3.new(v,v,v) end
    end
end)

Spacer(pCom)
Section(pCom,"⚔️  KILL AURA")

Toggle(pCom,"Kill Aura",false,function(v)
    State.killAura=v
    killConn("killAura")
    if v then
        Conns.killAura=RunService.Heartbeat:Connect(function()
            if not State.killAura then return end
            local myR=hrp(); if not myR then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p==LP then continue end
                local c=p.Character; if not c then continue end
                local r=c:FindFirstChild("HumanoidRootPart")
                local h=c:FindFirstChildOfClass("Humanoid")
                if r and h and (myR.Position-r.Position).Magnitude<=State.kaRange then
                    h.Health=0
                end
            end
        end)
    end
    Notify("Kill Aura",v and "เปิด" or "ปิด",2)
end)

Slider(pCom,"Kill Aura Range",5,100,15," studs",function(v) State.kaRange=v end)

-- ══════════════════════════════════════════
--  VISUAL PAGE
-- ══════════════════════════════════════════
local pVis=Pages["Visual"]

Section(pVis,"👁  ESP")

local espConns={}

Toggle(pVis,"Player ESP",false,function(v)
    State.esp=v
    for _,c in ipairs(espConns) do pcall(function() c:Disconnect() end) end
    espConns={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if c then
            local e=c:FindFirstChild("BomDevESP"); if e then e:Destroy() end
        end
    end
    if not v then Notify("ESP","ปิด",2); return end

    local function addESP(pl)
        local c=pl.Character; if not c then return end
        if c:FindFirstChild("BomDevESP") then return end
        local hl=Instance.new("Highlight")
        hl.Name="BomDevESP"
        hl.FillTransparency=0.7; hl.OutlineTransparency=0
        hl.Parent=c
        local myR=nil
        local uc=RunService.Heartbeat:Connect(function()
            if not State.esp then return end
            myR=hrp()
            local rNow=c:FindFirstChild("HumanoidRootPart")
            if not (myR and rNow) then return end
            local d=math.clamp((myR.Position-rNow.Position).Magnitude/200,0,1)
            hl.FillColor=Color3.new(d,1-d,0.2)
            hl.OutlineColor=Color3.new(d,1-d,0.2)
        end)
        espConns[#espConns+1]=uc
    end

    for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
    local conn=Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(1)
            if State.esp then addESP(p) end
        end)
    end)
    espConns[#espConns+1]=conn
    Notify("ESP","เปิด — สีตามระยะ",2)
end)

Spacer(pVis)
Section(pVis,"✚  CROSSHAIR")

Toggle(pVis,"Custom Crosshair",false,function(v)
    State.crosshair=v
    local ex=SG:FindFirstChild("BomDevCH")
    if ex then ex:Destroy() end
    if not v then Notify("Crosshair","ปิด",2); return end

    local csg=Instance.new("ScreenGui")
    csg.Name="BomDevCH"; csg.ResetOnSpawn=false; csg.IgnoreGuiInset=true
    safe(function() csg.Parent=CoreGui end)
    if not csg.Parent then csg.Parent=LP:WaitForChild("PlayerGui") end

    for _,d in ipairs({
        {UDim2.new(0,16,0,2),UDim2.new(0.5,6,0.5,-1)},
        {UDim2.new(0,16,0,2),UDim2.new(0.5,-22,0.5,-1)},
        {UDim2.new(0,2,0,16),UDim2.new(0.5,-1,0.5,6)},
        {UDim2.new(0,2,0,16),UDim2.new(0.5,-1,0.5,-22)},
    }) do
        Frame({Size=d[1],Position=d[2],BackgroundColor3=C.b1,ZIndex=1},csg)
    end
    local dot=Frame({
        Size=UDim2.new(0,4,0,4),
        Position=UDim2.new(0.5,-2,0.5,-2),
        BackgroundColor3=C.wht, ZIndex=1,
    },csg)
    Corner(dot,2)
    Notify("Crosshair","เปิด",2)
end)

Spacer(pVis)
Section(pVis,"💡  LIGHTING")

Toggle(pVis,"Fullbright",false,function(v)
    if v then
        Lighting.Brightness=3; Lighting.ClockTime=14
        Lighting.FogEnd=1e5; Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness=1; Lighting.ClockTime=12
        Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127)
    end
    Notify("Fullbright",v and "เปิด" or "ปิด",2)
end)

Toggle(pVis,"Night Vision",false,function(v)
    if v then
        Lighting.Brightness=5
        Lighting.Ambient=Color3.fromRGB(80,255,120)
        Lighting.GlobalShadows=false
    else
        Lighting.Brightness=2
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.GlobalShadows=true
    end
    Notify("Night Vision",v and "เปิด" or "ปิด",2)
end)

Button(pVis,"Remove Fog",function()
    Lighting.FogEnd=999999; Notify("Fog","ลบแล้ว",2)
end)

Spacer(pVis)
Section(pVis,"✨  CHARACTER FX")

Toggle(pVis,"Rainbow Mode",false,function(v)
    State.rainbow=v
    killConn("rainbow")
    if v then
        Conns.rainbow=RunService.Heartbeat:Connect(function()
            if not State.rainbow then return end
            local c=char(); if not c then return end
            local t=tick()%5/5
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.Color=Color3.fromHSV(t,1,1) end
            end
        end)
    end
    Notify("Rainbow",v and "เปิด" or "ปิด",2)
end)

Toggle(pVis,"Cinematic Mode",false,function(v)
    State.cinema=v
    safe(function() StarterGui:SetCore("TopbarEnabled",not v) end)
    Notify("Cinematic",v and "เปิด" or "ปิด",2)
end)

Spacer(pVis)
Section(pVis,"📊  STAT MONITOR")

Toggle(pVis,"Stats HUD",false,function(v)
    State.stats=v
    local ex=SG:FindFirstChild("BomDevStats")
    if ex then ex:Destroy() end
    if not v then Notify("Stats","ปิด",2); return end

    local ssg=Instance.new("ScreenGui")
    ssg.Name="BomDevStats"; ssg.ResetOnSpawn=false; ssg.IgnoreGuiInset=true
    safe(function() ssg.Parent=CoreGui end)
    if not ssg.Parent then ssg.Parent=LP:WaitForChild("PlayerGui") end

    local box=Frame({
        Size=UDim2.new(0,195,0,100),
        Position=UDim2.new(0,10,0,90),
        BackgroundColor3=C.bg1, ZIndex=50,
    },ssg)
    Corner(box,10)
    Stroke(box,C.p1,1.2)
    Grad(box,Color3.fromRGB(12,8,24),C.bg1,135)

    New("TextLabel",{
        Size=UDim2.new(1,0,0,22),
        BackgroundTransparency=1,
        Text="⚡ BomDev Stats", TextSize=10,
        Font=Enum.Font.GothamBold,
        TextColor3=C.b1, ZIndex=51,
        TextXAlignment=Enum.TextXAlignment.Center,
    },box)

    local lines={"FPS","Speed","Health","Position"}
    local lbls={}
    for i,n in ipairs(lines) do
        local sl=New("TextLabel",{
            Size=UDim2.new(1,-14,0,17),
            Position=UDim2.new(0,8,0,20+(i-1)*18),
            BackgroundTransparency=1,
            Text=n..": ...", TextSize=10,
            Font=Enum.Font.Code,
            TextColor3=C.txt, ZIndex=51,
            TextXAlignment=Enum.TextXAlignment.Left,
        },box)
        lbls[n]=sl
    end

    local fc,lastT=0,tick()
    RunService.RenderStepped:Connect(function()
        if not State.stats then return end
        fc=fc+1
        local now=tick()
        if now-lastT>=1 then
            local fps=math.floor(fc/(now-lastT))
            fc=0; lastT=now
            local h=hum(); local r=hrp()
            local hp=h and math.floor(h.Health) or 0
            local mhp=h and math.floor(h.MaxHealth) or 100
            local sp=h and math.floor(h.WalkSpeed) or 0
            local pos=r and r.Position or Vector3.new()
            if lbls.FPS      then lbls.FPS.Text="FPS    "..fps end
            if lbls.Speed    then lbls.Speed.Text="Speed  "..sp end
            if lbls.Health   then lbls.Health.Text="HP     "..hp.."/"..mhp end
            if lbls.Position then
                lbls.Position.Text=math.floor(pos.X).." "..math.floor(pos.Y).." "..math.floor(pos.Z)
            end
        end
    end)
    Notify("Stats","เปิด",2)
end)

-- ══════════════════════════════════════════
--  PLAYER PAGE
-- ══════════════════════════════════════════
local pPly=Pages["Player"]

Section(pPly,"🛡  PROTECTION")

Toggle(pPly,"God Mode",false,function(v)
    State.god=v
    killConn("god")
    local h=hum()
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
    Notify("God Mode",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Anti AFK",false,function(v)
    State.antiAfk=v
    killConn("antiAfk")
    if v then
        Conns.antiAfk=LP.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0),Cam.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0,0),Cam.CFrame)
        end)
    end
    Notify("Anti AFK",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Invisible",false,function(v)
    State.invis=v
    local c=char(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end
        if p:IsA("Decal")    then p.Transparency=v and 1 or 0 end
    end
    Notify("Invisible",v and "เปิด" or "ปิด",2)
end)

Spacer(pPly)
Section(pPly,"👤  CHARACTER")

Slider(pPly,"Character Scale",10,300,100,"%",function(v)
    local h=hum(); if not h then return end
    local s=v/100
    safe(function()
        h.BodyDepthScale.Value=s
        h.BodyHeightScale.Value=s
        h.BodyWidthScale.Value=s
        h.HeadScale.Value=s
    end)
end)

Dropdown(pPly,"Body Color",
    {"Default","Red","Blue","Green","Yellow","Purple","Black","White"},
    function(opt)
        local map={
            Red=Color3.fromRGB(200,50,50), Blue=Color3.fromRGB(50,100,220),
            Green=Color3.fromRGB(50,180,80), Yellow=Color3.fromRGB(230,210,50),
            Purple=Color3.fromRGB(130,60,220), Black=Color3.fromRGB(25,25,25),
            White=Color3.fromRGB(240,240,240),
        }
        local c=char(); if not c then return end
        local col=map[opt]
        if col then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    p.Color=col
                end
            end
        end
        Notify("Body Color",opt,2)
    end
)

Spacer(pPly)
Section(pPly,"✨  EFFECTS")

Toggle(pPly,"Character Glow",false,function(v)
    State.glow=v
    local c=char(); if not c then return end
    local ex=c:FindFirstChild("BomDevGlow"); if ex then ex:Destroy() end
    if v then
        local hl=Instance.new("Highlight")
        hl.Name="BomDevGlow"
        hl.FillColor=C.p1; hl.FillTransparency=0.7
        hl.OutlineColor=C.b1; hl.OutlineTransparency=0
        hl.Parent=c
    end
    Notify("Glow",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Fire Effect",false,function(v)
    State.fire=v
    local c=char(); if not c then return end
    if v then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                local f=Instance.new("Fire")
                f.Name="BomDevFire"; f.Heat=5; f.Size=3; f.Parent=p
            end
        end
    else
        for _,p in ipairs(c:GetDescendants()) do
            local f=p:FindFirstChild("BomDevFire"); if f then f:Destroy() end
        end
    end
    Notify("Fire",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Sparkle Effect",false,function(v)
    State.sparkle=v
    local c=char(); if not c then return end
    if v then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                local sp=Instance.new("Sparkles")
                sp.Name="BomDevSparkle"; sp.SparkleColor=C.b1; sp.Parent=p
            end
        end
    else
        for _,p in ipairs(c:GetDescendants()) do
            local sp=p:FindFirstChild("BomDevSparkle"); if sp then sp:Destroy() end
        end
    end
    Notify("Sparkle",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Force Field",false,function(v)
    local c=char(); if not c then return end
    local ex=c:FindFirstChildOfClass("ForceField"); if ex then ex:Destroy() end
    if v then
        local ff=Instance.new("ForceField"); ff.Visible=true; ff.Parent=c
    end
    Notify("Force Field",v and "เปิด" or "ปิด",2)
end)

Toggle(pPly,"Trail Effect",false,function(v)
    State.trail=v
    local r=hrp(); if not r then return end
    for _,n in ipairs({"BomDevTrail","_TrlA","_TrlB"}) do
        local ex=r:FindFirstChild(n); if ex then ex:Destroy() end
    end
    if v then
        local a0=Instance.new("Attachment",r); a0.Name="_TrlA"; a0.Position=Vector3.new(0,1,0)
        local a1=Instance.new("Attachment",r); a1.Name="_TrlB"; a1.Position=Vector3.new(0,-1,0)
        local tr=Instance.new("Trail")
        tr.Name="BomDevTrail"
        tr.Attachment0=a0; tr.Attachment1=a1
        tr.Lifetime=0.8; tr.MinLength=0; tr.FaceCamera=true
        tr.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.p1),
            ColorSequenceKeypoint.new(0.5,C.b1),
            ColorSequenceKeypoint.new(1,C.wht),
        })
        tr.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        })
        tr.Parent=r
    end
    Notify("Trail",v and "เปิด" or "ปิด",2)
end)

Button(pPly,"Reset Character",function()
    local h=hum(); if h then h.Health=0 end
end)

Input(pPly,"Play Animation","Animation ID (ตัวเลข)",function(text)
    if not text or #text==0 then return end
    local h=hum(); if not h then return end
    local anim=Instance.new("Animation")
    anim.AnimationId="rbxassetid://"..text
    local t=h:LoadAnimation(anim); t:Play()
    Notify("Anim","กำลังเล่น "..text,2)
end)

-- ══════════════════════════════════════════
--  TELEPORT PAGE
-- ══════════════════════════════════════════
local pTel=Pages["Teleport"]
local selectedPlayer=nil

Section(pTel,"🎯  TARGET")

local function getPlayerNames()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then t[#t+1]=p.Name end
    end
    if #t==0 then t={"(ว่าง)"} end
    return t
end

local pDD=Dropdown(pTel,"Target Player",getPlayerNames(),function(name)
    if name=="(ว่าง)" then selectedPlayer=nil; return end
    selectedPlayer=Players:FindFirstChild(name)
    Notify("Target",selectedPlayer and "เลือก: "..name or "ไม่พบ",2)
end)

Button(pTel,"Refresh",function() pDD.Set(getPlayerNames()) end)

Spacer(pTel)
Section(pTel,"⚡  ACTIONS")

Button(pTel,"🔀 Warp to Target",function()
    if not selectedPlayer or not selectedPlayer.Character then
        Notify("Warp","ไม่มีเป้าหมาย",2); return
    end
    local r=hrp()
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then r.CFrame=tr.CFrame+Vector3.new(0,3,0) end
    Notify("Warp","ไปหา "..selectedPlayer.Name,2)
end)

Button(pTel,"🧲 Pull Target Here",function()
    if not selectedPlayer or not selectedPlayer.Character then
        Notify("Pull","ไม่มีเป้าหมาย",2); return
    end
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myR=hrp()
    if not (tr and myR) then return end
    local ex=tr:FindFirstChild("BDPull"); if ex then ex:Destroy() end
    local bp=Instance.new("BodyPosition")
    bp.Name="BDPull"; bp.MaxForce=Vector3.new(9e9,9e9,9e9); bp.P=8e3; bp.D=600
    bp.Position=myR.Position+myR.CFrame.LookVector*3; bp.Parent=tr
    Notify("Pull","ดึง "..selectedPlayer.Name,2)
    task.delay(2,function() if bp and bp.Parent then bp:Destroy() end end)
end)

Toggle(pTel,"Freeze Target",false,function(v)
    if not selectedPlayer or not selectedPlayer.Character then
        Notify("Freeze","ไม่มีเป้าหมาย",2); return
    end
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    if v then
        local bf=Instance.new("BodyForce")
        bf.Name="BDFreeze"; bf.Force=Vector3.new(0,workspace.Gravity*tr:GetMass(),0); bf.Parent=tr
        local ba=Instance.new("BodyAngularVelocity")
        ba.Name="BDFreezeA"; ba.AngularVelocity=Vector3.new(0,0,0)
        ba.MaxTorque=Vector3.new(1e9,1e9,1e9); ba.Parent=tr
    else
        local f=tr:FindFirstChild("BDFreeze"); if f then f:Destroy() end
        local a=tr:FindFirstChild("BDFreezeA"); if a then a:Destroy() end
    end
    Notify("Freeze",v and selectedPlayer.Name.." หยุด" or "ปลดแล้ว",2)
end)

Toggle(pTel,"Spectate",false,function(v)
    killConn("spectate")
    if v then
        if not selectedPlayer or not selectedPlayer.Character then
            Notify("Spectate","ไม่มีเป้าหมาย",2); return
        end
        local h=selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then Cam.CameraSubject=h end
        Notify("Spectate","ดู "..selectedPlayer.Name,2)
    else
        Cam.CameraSubject=hum()
        Notify("Spectate","ปิด",2)
    end
end)

Spacer(pTel)
Section(pTel,"📍  SAVED POS")

for slot=1,5 do
    local row=Frame({
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=C.bg3, ZIndex=12,
    }, pTel)
    Corner(row,9)

    New("TextLabel",{
        Size=UDim2.new(0.36,0,1,0),
        Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,
        Text="📌 Slot "..slot,
        TextSize=11, Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)

    local saveB=New("TextButton",{
        Size=UDim2.new(0.29,-4,0.7,0),
        Position=UDim2.new(0.38,0,0.15,0),
        BackgroundColor3=Color3.fromRGB(20,40,20),
        Text="Save", TextSize=10,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.g1, BorderSizePixel=0, ZIndex=13,
    }, row)
    Corner(saveB,4)

    local tpB=New("TextButton",{
        Size=UDim2.new(0.29,-4,0.7,0),
        Position=UDim2.new(0.69,0,0.15,0),
        BackgroundColor3=Color3.fromRGB(20,20,45),
        Text="Warp", TextSize=10,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.b1, BorderSizePixel=0, ZIndex=13,
    }, row)
    Corner(tpB,4)

    local s=slot
    saveB.MouseButton1Click:Connect(function()
        local r=hrp()
        if r then SavedPos[s]=r.CFrame; Notify("Saved","Slot "..s,2) end
    end)
    tpB.MouseButton1Click:Connect(function()
        if SavedPos[s] then
            local r=hrp()
            if r then r.CFrame=SavedPos[s]+Vector3.new(0,3,0); Notify("Warp","Slot "..s,2) end
        else
            Notify("Warp","Slot "..s.." ว่าง",2)
        end
    end)
end

Spacer(pTel)
Button(pTel,"⬆ +50 Studs Up",function()
    local r=hrp(); if r then r.CFrame=r.CFrame+Vector3.new(0,50,0) end
end)
Button(pTel,"🎯 Teleport Origin (0,0,0)",function()
    local r=hrp(); if r then r.CFrame=CFrame.new(0,50,0) end
end)
Button(pTel,"🎲 Random Teleport",function()
    local r=hrp()
    if r then r.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500)) end
end)

-- ══════════════════════════════════════════
--  UTILS PAGE
-- ══════════════════════════════════════════
local pUti=Pages["Utils"]

Section(pUti,"🌐  SERVER")

Button(pUti,"🔄 Rejoin",function()
    TeleportSvc:Teleport(game.PlaceId,LP)
end)

Button(pUti,"🔀 Server Hop",function()
    Notify("Server Hop","กำลังหา...",2)
    safe(function()
        local data=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local ok,parsed=pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
        if ok and parsed and parsed.data then
            for _,s in ipairs(parsed.data) do
                if s.id~=game.JobId and s.playing<s.maxPlayers then
                    TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,LP)
                    return
                end
            end
        end
        Notify("Server Hop","ไม่พบ server ว่าง",2)
    end)
end)

Button(pUti,"📋 Copy Place ID",function()
    safe(function() setclipboard(tostring(game.PlaceId)) end)
    Notify("Copied","Place ID: "..game.PlaceId,2)
end)

Button(pUti,"ℹ️ Server Info",function()
    Notify("Server","Place: "..game.PlaceId.."  Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,4)
end)

Spacer(pUti)
Section(pUti,"🎵  MUSIC")

local musicId=""
local musicObj=nil

Input(pUti,"Sound ID","ใส่ Sound ID...",function(txt)
    musicId=txt
end)

Button(pUti,"▶ Play",function()
    if musicObj then musicObj:Destroy(); musicObj=nil end
    if musicId=="" then Notify("Music","ใส่ ID ก่อน",2); return end
    local snd=Instance.new("Sound")
    snd.SoundId="rbxassetid://"..musicId
    snd.Volume=0.5; snd.Looped=true
    snd.Parent=LP:WaitForChild("PlayerGui"); snd:Play()
    musicObj=snd
    Notify("Music","เล่น "..musicId,2)
end)

Button(pUti,"⏹ Stop",function()
    if musicObj then musicObj:Destroy(); musicObj=nil end
    Notify("Music","หยุด",2)
end)

Spacer(pUti)
Section(pUti,"🤖  AUTO")

Toggle(pUti,"Auto Farm",false,function(v)
    State.autoFarm=v
    if v then
        task.spawn(function()
            while State.autoFarm do
                local r=hrp()
                if r then
                    local closest,closestD=nil,50
                    for _,obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n=obj.Name:lower()
                            if n:match("coin") or n:match("gem") or
                               n:match("pickup") or n:match("collect") or n:match("orb") then
                                local d=(r.Position-obj.Position).Magnitude
                                if d<closestD then
                                    closestD=d; closest=obj
                                end
                            end
                        end
                    end
                    if closest then
                        r.CFrame=CFrame.new(closest.Position+Vector3.new(0,3,0))
                    end
                end
                task.wait(0.1)
            end
        end)
    end
    Notify("Auto Farm",v and "เปิด" or "ปิด",2)
end)

Spacer(pUti)
Section(pUti,"🌍  WORLD")

Input(pUti,"Find & Teleport Part","ชื่อ Part...",function(text)
    if not text or #text==0 then return end
    local r=hrp(); if not r then return end
    local found,closest,closestD=0,nil,math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(text:lower()) and obj:IsA("BasePart") then
            found=found+1
            local d=(r.Position-obj.Position).Magnitude
            if d<closestD then
                closestD=d; closest=obj
            end
        end
    end
    Notify("Find","พบ "..found.." parts",3)
    if closest then r.CFrame=CFrame.new(closest.Position+Vector3.new(0,5,0)) end
end)

Spacer(pUti)
Button(pUti,"💬 Join Discord",function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","เปิดแล้ว!",3)
end,true)

-- ══════════════════════════════════════════
--  DOWNLOAD PAGE
-- ══════════════════════════════════════════
local pDl=Pages["Download"]

-- hero banner
local hero=Frame({
    Size=UDim2.new(1,0,0,88),
    BackgroundColor3=C.p1, ZIndex=12,
}, pDl)
Corner(hero,12)
Grad(hero,Color3.fromRGB(65,22,158),Color3.fromRGB(20,108,210),135)

New("TextLabel",{
    Size=UDim2.new(0,54,0,54),
    Position=UDim2.new(0,14,0.5,-27),
    BackgroundTransparency=1,
    Text="⚡", TextSize=38,
    Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=13,
}, hero)

New("TextLabel",{
    Size=UDim2.new(1,-80,0,28),
    Position=UDim2.new(0,72,0,14),
    BackgroundTransparency=1,
    Text="BomDev Downloads",
    TextSize=15, Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=13,
    TextXAlignment=Enum.TextXAlignment.Left,
}, hero)

New("TextLabel",{
    Size=UDim2.new(1,-80,0,18),
    Position=UDim2.new(0,72,0,46),
    BackgroundTransparency=1,
    Text="Scripts & Tools จาก BomDev Community",
    TextSize=10, Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(200,205,230), ZIndex=13,
    TextXAlignment=Enum.TextXAlignment.Left,
}, hero)

local function DlCard(parent, title, desc, badge, badgeCol)
    local card=Frame({
        Size=UDim2.new(1,0,0,72),
        BackgroundColor3=C.bg3, ZIndex=12,
    }, parent)
    Corner(card,10)
    Grad(card,Color3.fromRGB(18,14,30),C.bg3,145)
    Stroke(card,C.bord,1)

    local ib=Frame({
        Size=UDim2.new(0,42,0,42),
        Position=UDim2.new(0,12,0.5,-21),
        BackgroundColor3=badgeCol or C.p1, ZIndex=13,
    }, card)
    Corner(ib,10)
    Grad(ib,badgeCol or C.p1,C.b1,135)

    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="📥", TextSize=18,
        Font=Enum.Font.GothamBold,
        TextColor3=C.wht, ZIndex=14,
    }, ib)

    New("TextLabel",{
        Size=UDim2.new(1,-135,0,22),
        Position=UDim2.new(0,64,0,10),
        BackgroundTransparency=1,
        Text=title, TextSize=12,
        Font=Enum.Font.GothamBold,
        TextColor3=C.txt, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)

    New("TextLabel",{
        Size=UDim2.new(1,-135,0,18),
        Position=UDim2.new(0,64,0,34),
        BackgroundTransparency=1,
        Text=desc, TextSize=10,
        Font=Enum.Font.Gotham,
        TextColor3=C.tx2, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)

    local bf=Frame({
        Size=UDim2.new(0,58,0,17),
        Position=UDim2.new(0,64,0,53),
        BackgroundColor3=badgeCol or C.p1, ZIndex=13,
    }, card)
    Corner(bf,9)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=badge or "FREE",
        TextSize=9, Font=Enum.Font.GothamBold,
        TextColor3=C.wht, ZIndex=14,
    }, bf)

    local gb=New("TextButton",{
        Size=UDim2.new(0,64,0,26),
        Position=UDim2.new(1,-76,0.5,-13),
        BackgroundColor3=badgeCol or C.p1,
        Text="Get", TextSize=11,
        Font=Enum.Font.GothamBold,
        TextColor3=C.wht, BorderSizePixel=0, ZIndex=13,
    }, card)
    Corner(gb,7)
    Grad(gb,badgeCol or C.p1,C.b1,90)

    gb.MouseEnter:Connect(function()
        Tw(card,TF,{BackgroundColor3=Color3.fromRGB(24,20,40)})
    end)
    gb.MouseLeave:Connect(function()
        Tw(card,TF,{BackgroundColor3=C.bg3})
    end)
    gb.MouseButton1Click:Connect(function()
        safe(function() setclipboard(DISCORD) end)
        safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
        Notify("Download",title.." — เปิด Discord!",3)
    end)
end

Spacer(pDl)
Section(pDl,"🔥  FEATURED")
DlCard(pDl,"BomDev Hub v5.0",       "Main hub script",                "LATEST",Color3.fromRGB(100,55,240))
DlCard(pDl,"AutoFarm Pro",          "Multi-game auto farm",           "PRO",   Color3.fromRGB(210,140,0))
DlCard(pDl,"ESP Suite",             "Player ESP + Radar",             "FREE",  Color3.fromRGB(45,185,75))
DlCard(pDl,"Speed Kit",             "Movement bundle",                "FREE",  Color3.fromRGB(45,165,215))

Spacer(pDl)
Section(pDl,"🎮  GAME SCRIPTS")
DlCard(pDl,"Blox Fruits Farm",      "Auto farm + raids + boss",       "HOT",   Color3.fromRGB(215,115,45))
DlCard(pDl,"Pet Simulator Farm",    "Pets & coins auto",              "FREE",  Color3.fromRGB(45,195,125))
DlCard(pDl,"Murder Mystery 2 ESP",  "Knife & gun ESP",                "FREE",  Color3.fromRGB(200,45,75))
DlCard(pDl,"Arsenal Suite",         "Aimbot + ESP",                   "PRO",   Color3.fromRGB(70,155,245))
DlCard(pDl,"Adopt Me Farm",         "Auto bucks & pets",              "FREE",  Color3.fromRGB(245,175,75))
DlCard(pDl,"Da Hood",               "Silent aim + btoolz",            "PRO",   Color3.fromRGB(185,55,55))

Spacer(pDl)
Section(pDl,"🔧  TOOLS")
DlCard(pDl,"Executor Checker",      "Check executor features",        "FREE",  Color3.fromRGB(80,80,160))
DlCard(pDl,"Anti-Ban Kit",          "Bypass detection methods",       "PRO",   Color3.fromRGB(180,80,80))

Spacer(pDl)

local dscCard=Frame({
    Size=UDim2.new(1,0,0,60),
    BackgroundColor3=Color3.fromRGB(68,85,218), ZIndex=12,
}, pDl)
Corner(dscCard,10)
Grad(dscCard,Color3.fromRGB(55,68,200),Color3.fromRGB(90,110,245),135)

New("TextLabel",{
    Size=UDim2.new(0,40,0,40),
    Position=UDim2.new(0,12,0.5,-20),
    BackgroundTransparency=1,
    Text="💬", TextSize=26,
    Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=13,
}, dscCard)

New("TextLabel",{
    Size=UDim2.new(1,-155,0,22),
    Position=UDim2.new(0,58,0,10),
    BackgroundTransparency=1,
    Text="BomDev Discord",
    TextSize=13, Font=Enum.Font.GothamBold,
    TextColor3=C.wht, ZIndex=13,
    TextXAlignment=Enum.TextXAlignment.Left,
}, dscCard)

New("TextLabel",{
    Size=UDim2.new(1,-155,0,16),
    Position=UDim2.new(0,58,0,34),
    BackgroundTransparency=1,
    Text="Scripts อัปเดต + Community",
    TextSize=10, Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(200,205,235), ZIndex=13,
    TextXAlignment=Enum.TextXAlignment.Left,
}, dscCard)

local jb=New("TextButton",{
    Size=UDim2.new(0,64,0,26),
    Position=UDim2.new(1,-76,0.5,-13),
    BackgroundColor3=C.wht,
    Text="Join", TextSize=11,
    Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(68,85,218),
    BorderSizePixel=0, ZIndex=13,
}, dscCard)
Corner(jb,7)
jb.MouseButton1Click:Connect(function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","เปิดแล้ว!",2)
end)

-- ══════════════════════════════════════════
--  SETTINGS PAGE
-- ══════════════════════════════════════════
local pSet=Pages["Settings"]

Section(pSet,"📷  CAMERA")
Slider(pSet,"FOV",50,120,70,"°",function(v) Cam.FieldOfView=v end)
Button(pSet,"FOV 70 (Default)",function() Cam.FieldOfView=70 end)
Button(pSet,"FOV 110 (Wide)",function() Cam.FieldOfView=110 end)

Spacer(pSet)
Section(pSet,"💡  LIGHTING")
Slider(pSet,"Clock Time",0,24,14,"h",function(v) Lighting.ClockTime=v end)
Slider(pSet,"Brightness",0,10,2,"x",function(v) Lighting.Brightness=v end)
Toggle(pSet,"Global Shadows",true,function(v) Lighting.GlobalShadows=v end)

Spacer(pSet)
Section(pSet,"⌨  HOTKEYS")

local hkF=Frame({
    Size=UDim2.new(1,0,0,132),
    BackgroundColor3=C.bg3, ZIndex=12,
}, pSet)
Corner(hkF,10)
Grad(hkF,Color3.fromRGB(16,12,28),C.bg3,135)

local hkeys={
    {"F1","Fly toggle"},
    {"F2","Speed toggle"},
    {"F3","God Mode toggle"},
    {"F4","NoClip toggle"},
    {"]","ซ่อน / แสดง GUI"},
    {"W/A/S/D","บินตามกล้อง"},
    {"Space","บินขึ้น"},
    {"LCtrl / LShift","บินลง"},
}

for i,pair in ipairs(hkeys) do
    local row=Frame({
        Size=UDim2.new(1,-16,0,14),
        Position=UDim2.new(0,8,0,4+(i-1)*15),
        BackgroundTransparency=1, ZIndex=13,
    }, hkF)
    New("TextLabel",{
        Size=UDim2.new(0,115,1,0),
        BackgroundTransparency=1,
        Text=pair[1], TextSize=10,
        Font=Enum.Font.Code,
        TextColor3=C.b1, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)
    New("TextLabel",{
        Size=UDim2.new(1,-122,1,0),
        Position=UDim2.new(0,122,0,0),
        BackgroundTransparency=1,
        Text=pair[2], TextSize=10,
        Font=Enum.Font.Gotham,
        TextColor3=C.tx2, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)
end

Spacer(pSet)
Section(pSet,"ℹ️  ABOUT")

local aboutF=Frame({
    Size=UDim2.new(1,0,0,95),
    BackgroundColor3=C.bg3, ZIndex=12,
}, pSet)
Corner(aboutF,10)
Grad(aboutF,Color3.fromRGB(16,10,30),C.bg3,135)
Stroke(aboutF,C.bord,1)

local abLines={
    {"⚡ BomDev Hub  v5.0",          Enum.Font.GothamBold, C.txt},
    {"Dev: BomDev",                   Enum.Font.Gotham,     C.tx2},
    {"discord.gg/4Vn8WwyV3u",         Enum.Font.Gotham,     C.tx2},
    {"",                               Enum.Font.Gotham,     C.tx3},
    {"✅ Fly แก้ไขแล้ว — WASD ตามกล้อง", Enum.Font.Gotham, C.g1},
    {"✅ UI ใหม่ + Loading Screen",   Enum.Font.Gotham,     C.g1},
    {"✅ ทุก Bug แก้ไขเรียบร้อย",    Enum.Font.Gotham,     C.g1},
}

for i,ln in ipairs(abLines) do
    New("TextLabel",{
        Size=UDim2.new(1,-20,0,12),
        Position=UDim2.new(0,12,0,2+(i-1)*13),
        BackgroundTransparency=1,
        Text=ln[1], TextSize=10,
        Font=ln[2], TextColor3=ln[3],
        ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, aboutF)
end

-- ══════════════════════════════════════════
--  HOTKEYS
-- ══════════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end

    if inp.KeyCode==Enum.KeyCode.F1 then
        State.fly=not State.fly
        if State.fly then startFly(); Notify("Fly","F1 — เปิด",1)
        else stopFly(); Notify("Fly","F1 — ปิด",1) end
    end

    if inp.KeyCode==Enum.KeyCode.F2 then
        State.speed=not State.speed
        local h=hum()
        if h then h.WalkSpeed=State.speed and State.speedVal or 16 end
        Notify("Speed",State.speed and "F2 — เปิด" or "F2 — ปิด",1)
    end

    if inp.KeyCode==Enum.KeyCode.F3 then
        State.god=not State.god
        killConn("god")
        local h=hum()
        if State.god then
            if h then
                h.MaxHealth=math.huge; h.Health=math.huge
                h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
            end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum()
                if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
            Notify("God","F3 — เปิด",1)
        else
            if h then h.MaxHealth=100; h.Health=100; h:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end
            Notify("God","F3 — ปิด",1)
        end
    end

    if inp.KeyCode==Enum.KeyCode.F4 then
        State.noclip=not State.noclip
        killConn("noclip")
        if State.noclip then
            Conns.noclip=RunService.Stepped:Connect(function()
                if not State.noclip then return end
                local c=char(); if not c then return end
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        end
        Notify("NoClip",State.noclip and "F4 — เปิด" or "F4 — ปิด",1)
    end

    if inp.KeyCode==Enum.KeyCode.RightBracket then
        MF.Visible=not MF.Visible
    end
end)

-- ══════════════════════════════════════════
--  CHARACTER RESPAWN HANDLER
-- ══════════════════════════════════════════
LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    if State.speed then local h=c:WaitForChild("Humanoid"); h.WalkSpeed=State.speedVal end
    if State.jump  then local h=c:WaitForChild("Humanoid"); h.JumpPower=State.jumpVal  end
    if State.noFall then
        local h=c:WaitForChild("Humanoid")
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    end
    if State.god then
        local h=c:WaitForChild("Humanoid")
        h.MaxHealth=math.huge; h.Health=math.huge
        h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
    end
    if State.glow then
        local hl=Instance.new("Highlight")
        hl.Name="BomDevGlow"
        hl.FillColor=C.p1; hl.FillTransparency=0.7
        hl.OutlineColor=C.b1; hl.OutlineTransparency=0
        hl.Parent=c
    end
    if State.fly then
        task.wait(0.5)
        startFly()
    end
end)

-- ══════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════
task.defer(function()
    switchPage("Movement")
end)

task.spawn(doLoad)
