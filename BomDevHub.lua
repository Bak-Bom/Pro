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

local State = {
    fly=false, flySpeed=60,
    speed=false, speedVal=60,
    jump=false, jumpVal=100,
    noclip=false,
    god=false,
    infJump=false,
    bhop=false,
    hitbox=false, hitboxSz=10,
    aimbot=false, abRange=200, abSmooth=0.15,
    esp=false,
    tracker=false,
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
    noFrict=false,
    walkWater=false,
    stats=false,
    cinema=false,
    crosshair=false,
}

local Conns    = {}
local SavedPos = {}
local WL       = {}
local DISCORD  = "https://discord.gg/4Vn8WwyV3u"

local function killConn(name)
    if Conns[name] then
        pcall(function() Conns[name]:Disconnect() end)
        Conns[name] = nil
    end
end

local function safe(fn) pcall(fn) end
local function char()  return LP.Character end
local function hrp()   local c=char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()   local c=char(); return c and c:FindFirstChildOfClass("Humanoid") end

local C = {
    bg0   = Color3.fromRGB(5,4,12),
    bg1   = Color3.fromRGB(9,8,20),
    bg2   = Color3.fromRGB(13,12,26),
    bg3   = Color3.fromRGB(19,17,36),
    bg4   = Color3.fromRGB(26,23,46),
    bord  = Color3.fromRGB(42,38,72),
    bor2  = Color3.fromRGB(65,58,105),
    p1    = Color3.fromRGB(130,70,255),
    p2    = Color3.fromRGB(175,110,255),
    p3    = Color3.fromRGB(200,145,255),
    b1    = Color3.fromRGB(60,185,255),
    b2    = Color3.fromRGB(100,220,255),
    cy    = Color3.fromRGB(50,240,200),
    g1    = Color3.fromRGB(55,220,115),
    g2    = Color3.fromRGB(80,255,150),
    r1    = Color3.fromRGB(240,65,90),
    y1    = Color3.fromRGB(255,210,60),
    o1    = Color3.fromRGB(255,145,60),
    txt   = Color3.fromRGB(232,226,250),
    tx2   = Color3.fromRGB(150,140,180),
    tx3   = Color3.fromRGB(80,72,112),
    wht   = Color3.fromRGB(255,255,255),
}

local SG = Instance.new("ScreenGui")
SG.Name           = "BomDevHub_v6"
SG.ResetOnSpawn   = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
safe(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = LP:WaitForChild("PlayerGui") end

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
    return New("UIStroke",{Color=col or C.bord, Thickness=thick or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p)
end

local function Grad(p, c1, c2, rot)
    return New("UIGradient",{Color=ColorSequence.new(c1,c2), Rotation=rot or 90},p)
end

local function Pad(p,l,r,t,b)
    return New("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0),
        PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),
        PaddingBottom=UDim.new(0,b or 0),
    },p)
end

local function MkFrame(props, parent)
    local f = New("Frame",{BackgroundColor3=C.bg2, BorderSizePixel=0},nil)
    for k,v in pairs(props) do f[k]=v end
    if parent then f.Parent=parent end
    return f
end

local TF = TweenInfo.new(0.12,Enum.EasingStyle.Quart)
local TM = TweenInfo.new(0.22,Enum.EasingStyle.Quart)
local TS = TweenInfo.new(0.38,Enum.EasingStyle.Quart)
local TB = TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

local function Tw(obj,info,props)
    TweenService:Create(obj,info,props):Play()
end

local notifStack = {}
local function Notify(title,body,dur,col)
    local accent = col or C.p1
    local nf = MkFrame({
        Size=UDim2.new(0,320,0,76),
        Position=UDim2.new(1,20,1,-88),
        ZIndex=400,
        BackgroundColor3=C.bg1,
    },SG)
    Corner(nf,14)
    Grad(nf,Color3.fromRGB(14,10,28),C.bg1,130)
    Stroke(nf,accent,1.2)

    local accentBar = MkFrame({
        Size=UDim2.new(0,3,1,-20),
        Position=UDim2.new(0,10,0,10),
        BackgroundColor3=accent,
        ZIndex=401,
    },nf)
    Corner(accentBar,2)
    Grad(accentBar,accent,C.b1,90)

    local glowDot = MkFrame({
        Size=UDim2.new(0,28,0,28),
        Position=UDim2.new(0,20,0.5,-14),
        BackgroundColor3=accent,
        ZIndex=401,
    },nf)
    Corner(glowDot,14)
    New("UIGradient",{Color=ColorSequence.new(accent,C.b1),Rotation=135},glowDot)
    glowDot.BackgroundTransparency=0.3

    New("TextLabel",{
        Size=UDim2.new(1,-64,0,26),
        Position=UDim2.new(0,56,0,12),
        BackgroundTransparency=1,
        Text=title,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=402,
    },nf)

    New("TextLabel",{
        Size=UDim2.new(1,-64,0,20),
        Position=UDim2.new(0,56,0,38),
        BackgroundTransparency=1,
        Text=body or "",TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.tx2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=402,
    },nf)

    local prog = MkFrame({
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=accent,ZIndex=402,
    },nf)
    Corner(prog,1)
    Grad(prog,accent,C.b1,0)
    Tw(prog,TweenInfo.new(dur or 3,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)})

    notifStack[#notifStack+1]=nf
    local myI = #notifStack
    local function restack()
        for i=#notifStack,1,-1 do
            local f=notifStack[i]
            if f and f.Parent then
                Tw(f,TM,{Position=UDim2.new(1,-330,1,-((#notifStack-i+1)*84))})
            end
        end
    end
    Tw(nf,TM,{Position=UDim2.new(1,-330,1,-(myI*84))})
    restack()
    task.delay(dur or 3,function()
        Tw(nf,TM,{Position=UDim2.new(1,20,1,-(myI*84))})
        task.wait(0.3)
        for i,f in ipairs(notifStack) do if f==nf then table.remove(notifStack,i); break end end
        if nf.Parent then nf:Destroy() end
        restack()
    end)
end

local LS = MkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg0,ZIndex=600},SG)
Grad(LS,Color3.fromRGB(8,5,20),Color3.fromRGB(3,2,8),135)

local function mkOrb(col,sz,px,py,tr)
    local g=MkFrame({
        Size=UDim2.new(0,sz,0,sz),
        Position=UDim2.new(0,px,0,py),
        BackgroundColor3=col,BackgroundTransparency=tr,ZIndex=601,
    },LS)
    Corner(g,sz//2)
    return g
end
local gA=mkOrb(C.p1,700,200,  0,0.82)
local gB=mkOrb(C.b1,500,620,180,0.86)
local gC=mkOrb(C.p2,350,100,320,0.88)
local gD=mkOrb(C.cy, 250,900, 50,0.90)

local gridConns={}
for i=0,9 do
    MkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,i*(720//9)),BackgroundColor3=Color3.fromRGB(90,80,140),BackgroundTransparency=0.95,ZIndex=601},LS)
end
for i=0,15 do
    MkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(0,i*(1280//15),0,0),BackgroundColor3=Color3.fromRGB(90,80,140),BackgroundTransparency=0.95,ZIndex=601},LS)
end

do
    local t=0
    Conns._loadGlow=RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.6
        gA.BackgroundTransparency=0.82+math.sin(t)*0.05
        gB.BackgroundTransparency=0.86+math.sin(t*1.3)*0.04
        gC.BackgroundTransparency=0.88+math.sin(t*0.8)*0.04
        gD.BackgroundTransparency=0.90+math.sin(t*1.1)*0.03
    end)
end

local LSCard=MkFrame({
    Size=UDim2.new(0,420,0,380),
    Position=UDim2.new(0.5,-210,0.5,-190),
    BackgroundColor3=C.bg1,ZIndex=602,
},LS)
Corner(LSCard,26)
Grad(LSCard,Color3.fromRGB(14,9,32),C.bg1,155)

local cardStroke=New("UIStroke",{Thickness=1.8,Color=C.p1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},LSCard)
do
    local t=0
    Conns._cardStroke=RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.5
        cardStroke.Color=C.p1:Lerp(C.b1,(math.sin(t)*0.5+0.5))
        cardStroke.Transparency=0.1+math.sin(t*0.7)*0.08
    end)
end

local lsOuter=MkFrame({
    Size=UDim2.new(0,96,0,96),
    Position=UDim2.new(0.5,-48,0,26),
    BackgroundColor3=C.p1,ZIndex=603,
},LSCard)
Corner(lsOuter,48)
lsOuter.BackgroundTransparency=0.15
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},lsOuter)

local lsLogo=MkFrame({
    Size=UDim2.new(0,76,0,76),
    Position=UDim2.new(0.5,-38,0,36),
    BackgroundColor3=C.p1,ZIndex=604,
},LSCard)
Corner(lsLogo,38)
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},lsLogo)
New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⚡",TextSize=44,Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=605},lsLogo)

do
    local t=0
    Conns._logoPulse=RunService.Heartbeat:Connect(function(dt)
        t=t+dt*1.8
        local s=1+math.sin(t)*0.07
        lsOuter.Size=UDim2.new(0,96*s,0,96*s)
        lsOuter.Position=UDim2.new(0.5,-48*s,0,26-(96*(s-1)/2))
    end)
end

New("TextLabel",{
    Size=UDim2.new(1,-24,0,36),Position=UDim2.new(0,12,0,140),
    BackgroundTransparency=1,Text="BomDev Hub",TextSize=28,Font=Enum.Font.GothamBold,
    TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=603,
},LSCard)

New("TextLabel",{
    Size=UDim2.new(1,-24,0,20),Position=UDim2.new(0,12,0,178),
    BackgroundTransparency=1,Text="v6.0  ·  Dev: BomDev",TextSize=12,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=603,
},LSCard)

local lsBarBg=MkFrame({
    Size=UDim2.new(1,-48,0,7),Position=UDim2.new(0,24,0,218),
    BackgroundColor3=C.bg3,ZIndex=603,
},LSCard)
Corner(lsBarBg,4)

local lsBar=MkFrame({
    Size=UDim2.new(0,0,1,0),BackgroundColor3=C.p1,ZIndex=604,
},lsBarBg)
Corner(lsBar,4)
Grad(lsBar,C.p1,C.b1,0)

local lsGlow=MkFrame({
    Size=UDim2.new(0,0,1,8),Position=UDim2.new(0,0,0,-4),
    BackgroundColor3=C.p1,BackgroundTransparency=0.7,ZIndex=603,
},lsBarBg)
Corner(lsGlow,4)
Grad(lsGlow,C.p1,C.b1,0)

local lsStatus=New("TextLabel",{
    Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,12,0,232),
    BackgroundTransparency=1,Text="กำลังเริ่มต้น...",TextSize=11,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=603,
},LSCard)

local lsPct=New("TextLabel",{
    Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,12,0,216),
    BackgroundTransparency=1,Text="0%",TextSize=9,Font=Enum.Font.GothamBold,
    TextColor3=C.p2,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=603,
},LSCard)

local lsDots={}
for i=1,7 do
    local d=MkFrame({
        Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0.5,-36+(i-1)*12,0,258),
        BackgroundColor3=C.bord,ZIndex=603,
    },LSCard)
    Corner(d,4)
    lsDots[i]=d
end

do
    local t=0
    Conns._dots=RunService.Heartbeat:Connect(function(dt)
        t=t+dt*2.8
        for i,d in ipairs(lsDots) do
            local phase=(t-(i-1)*0.25)%(#lsDots*0.38)
            local bright=math.max(0,1-math.abs(phase-0.25)*6)
            d.BackgroundColor3=C.p1:Lerp(C.bord,1-bright)
            d.Size=UDim2.new(0,8+bright*4,0,8+bright*4)
            d.Position=UDim2.new(0.5,-36+(i-1)*12-(bright*2),0,258-(bright*2))
        end
    end)
end

MkFrame({
    Size=UDim2.new(1,-40,0,1),Position=UDim2.new(0,20,0,290),
    BackgroundColor3=C.bord,ZIndex=603,
},LSCard)

New("TextLabel",{
    Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,298),
    BackgroundTransparency=1,Text="💬  discord.gg/4Vn8WwyV3u",TextSize=10,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=603,
},LSCard)

New("TextLabel",{
    Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,318),
    BackgroundTransparency=1,Text="⚡ Powered by BomDev — All Rights Reserved",TextSize=8,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=603,
},LSCard)

local loadSteps={
    {prog=0.10,txt="🔧 กำลังสร้าง UI Framework..."},
    {prog=0.22,txt="✈️ กำลังโหลดระบบบิน (Fly)..."},
    {prog=0.36,txt="⚔️ กำลังโหลด Combat System..."},
    {prog=0.50,txt="👁 กำลังโหลด ESP / Visual..."},
    {prog=0.65,txt="🔀 กำลังโหลด Teleport System..."},
    {prog=0.78,txt="🤖 กำลังโหลด Auto Systems..."},
    {prog=0.90,txt="📥 กำลังโหลด Download Hub..."},
    {prog=1.00,txt="🚀 พร้อมแล้ว! ยินดีต้อนรับ!"},
}

local function doLoad()
    for _,step in ipairs(loadSteps) do
        task.wait(0.15)
        local p=step.prog
        Tw(lsBar,TM,{Size=UDim2.new(p,0,1,0)})
        Tw(lsGlow,TM,{Size=UDim2.new(p,0,1,8)})
        lsStatus.Text=step.txt
        lsPct.Text=math.floor(p*100).."%"
    end
    task.wait(0.4)
    killConn("_dots"); killConn("_loadGlow"); killConn("_cardStroke"); killConn("_logoPulse")
    for _,d in ipairs(LSCard:GetDescendants()) do
        pcall(function() Tw(d,TM,{BackgroundTransparency=1,TextTransparency=1}) end)
    end
    Tw(LSCard,TM,{BackgroundTransparency=1})
    task.wait(0.3)
    Tw(LS,TM,{BackgroundTransparency=1})
    task.wait(0.3)
    LS:Destroy()
    Notify("⚡ BomDev Hub v6.0","โหลดสำเร็จ!  กด ] เพื่อซ่อน/แสดง",4,C.p1)
end

local MF=MkFrame({
    Size=UDim2.new(0,800,0,560),
    Position=UDim2.new(0.5,-400,0.5,-280),
    BackgroundColor3=C.bg0,Active=true,Draggable=true,ZIndex=10,
},SG)
Corner(MF,18)
Grad(MF,Color3.fromRGB(8,6,20),Color3.fromRGB(4,3,10),155)

local mfBorder=New("UIStroke",{Thickness=1.5,Color=C.p1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},MF)
local mfInnerGlow=MkFrame({
    Size=UDim2.new(1,-2,1,-2),Position=UDim2.new(0,1,0,1),
    BackgroundTransparency=1,ZIndex=10,
},MF)
Corner(mfInnerGlow,17)
New("UIStroke",{Thickness=1,Color=C.p2,Transparency=0.7,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},mfInnerGlow)

do
    local t=0
    RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.3
        mfBorder.Color=C.p1:Lerp(C.b1,(math.sin(t)*0.5+0.5))
        mfBorder.Transparency=0.05+math.sin(t*0.9)*0.05
    end)
end

local TB2=MkFrame({
    Size=UDim2.new(1,0,0,60),
    BackgroundColor3=C.bg1,ZIndex=11,
},MF)
Corner(TB2,18)
Grad(TB2,Color3.fromRGB(14,10,30),C.bg1,90)
MkFrame({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.bg1,ZIndex=11},TB2)

local acLine=MkFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.p1,ZIndex=12},TB2)
do
    local g=New("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,C.p1),
        ColorSequenceKeypoint.new(0.35,C.b1),
        ColorSequenceKeypoint.new(0.65,C.cy),
        ColorSequenceKeypoint.new(1,C.p1),
    }),Rotation=0},acLine)
    local t=0
    RunService.Heartbeat:Connect(function(dt)
        t=t+dt*0.6
        local v1=(math.sin(t)*0.5+0.5)*0.6+0.1
        local v2=math.clamp(v1+0.3,0,1)
        pcall(function()
            g.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,C.p1),
                ColorSequenceKeypoint.new(v1,C.b1),
                ColorSequenceKeypoint.new(v2,C.cy),
                ColorSequenceKeypoint.new(1,C.p1),
            })
        end)
    end)
end

local logoOuter=MkFrame({
    Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,12,0.5,-24),
    BackgroundColor3=C.p1,BackgroundTransparency=0.2,ZIndex=12,
},TB2)
Corner(logoOuter,24)
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},logoOuter)

local logoF=MkFrame({
    Size=UDim2.new(0,36,0,36),Position=UDim2.new(0.5,-18,0.5,-18),
    BackgroundColor3=C.p1,ZIndex=13,
},logoOuter)
Corner(logoF,18)
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},logoF)
New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⚡",TextSize=22,Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=14},logoF)

do
    local t=0
    RunService.Heartbeat:Connect(function(dt)
        t=t+dt*2
        local s=1+math.sin(t)*0.04
        logoOuter.Size=UDim2.new(0,48*s,0,48*s)
        logoOuter.Position=UDim2.new(0,12-48*(s-1)/2,0.5,-24*s)
    end)
end

New("TextLabel",{
    Size=UDim2.new(0,200,0,28),Position=UDim2.new(0,70,0,7),
    BackgroundTransparency=1,Text="BomDev Hub",TextSize=19,Font=Enum.Font.GothamBold,
    TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,
},TB2)

New("TextLabel",{
    Size=UDim2.new(0,300,0,16),Position=UDim2.new(0,70,0,35),
    BackgroundTransparency=1,Text="v6.0  ·  Dev: BomDev  ·  Press ] to toggle",TextSize=9,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,
},TB2)

local topRight=MkFrame({
    Size=UDim2.new(0,120,0,40),
    Position=UDim2.new(1,-130,0.5,-20),
    BackgroundTransparency=1,ZIndex=12,
},TB2)

local function MkTopBtn(icon,posX,cb,accentC)
    local b=New("TextButton",{
        Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,posX,0.5,-18),
        BackgroundColor3=C.bg3,Text=icon,TextSize=14,Font=Enum.Font.GothamBold,
        TextColor3=C.tx2,BorderSizePixel=0,ZIndex=13,
    },topRight)
    Corner(b,10)
    Stroke(b,C.bord,1)
    b.MouseEnter:Connect(function()
        Tw(b,TF,{BackgroundColor3=accentC or C.bg4,TextColor3=C.txt})
    end)
    b.MouseLeave:Connect(function()
        Tw(b,TF,{BackgroundColor3=C.bg3,TextColor3=C.tx2})
    end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

MkTopBtn("💬",0,function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","คัดลอกและเปิดแล้ว!",3,Color3.fromRGB(88,101,242))
end,Color3.fromRGB(68,82,210))

MkTopBtn("—",42,function() MF.Visible=false end,C.bg4)
MkTopBtn("✕",84,function()
    Notify("BomDev","ปิดแล้ว! รีสคริปต์เพื่อเปิดใหม่",3,C.r1)
    task.delay(0.5,function() SG:Destroy() end)
end,Color3.fromRGB(40,18,22))

local ContentWrap=MkFrame({
    Size=UDim2.new(1,0,1,-62),Position=UDim2.new(0,0,0,62),
    BackgroundTransparency=1,ZIndex=11,
},MF)

local Sidebar=MkFrame({
    Size=UDim2.new(0,175,1,0),BackgroundColor3=C.bg1,ZIndex=11,
},ContentWrap)
Grad(Sidebar,C.bg1,Color3.fromRGB(7,6,16),180)
MkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.bord,ZIndex=12},Sidebar)

local PIBox=MkFrame({
    Size=UDim2.new(1,0,0,72),BackgroundColor3=C.bg2,ZIndex=12,
},Sidebar)
Grad(PIBox,Color3.fromRGB(16,10,34),C.bg2,140)

local pIconOuter=MkFrame({
    Size=UDim2.new(0,46,0,46),Position=UDim2.new(0,10,0.5,-23),
    BackgroundColor3=C.p1,BackgroundTransparency=0.25,ZIndex=13,
},PIBox)
Corner(pIconOuter,23)
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},pIconOuter)

local pIcon=MkFrame({
    Size=UDim2.new(0,36,0,36),Position=UDim2.new(0.5,-18,0.5,-18),
    BackgroundColor3=C.p1,ZIndex=14,
},pIconOuter)
Corner(pIcon,18)
New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=135},pIcon)
New("TextLabel",{
    Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text=string.upper(string.sub(LP.Name,1,1)),TextSize=18,Font=Enum.Font.GothamBold,
    TextColor3=C.wht,ZIndex=15,
},pIcon)

New("TextLabel",{
    Size=UDim2.new(1,-62,0,20),Position=UDim2.new(0,62,0,14),
    BackgroundTransparency=1,Text=LP.Name,TextSize=12,Font=Enum.Font.GothamBold,
    TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,
},PIBox)
New("TextLabel",{
    Size=UDim2.new(1,-62,0,14),Position=UDim2.new(0,62,0,36),
    BackgroundTransparency=1,Text="⚡ BomDev Member",TextSize=9,Font=Enum.Font.GothamMedium,
    TextColor3=C.p2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,
},PIBox)
New("TextLabel",{
    Size=UDim2.new(1,-62,0,12),Position=UDim2.new(0,62,0,52),
    BackgroundTransparency=1,Text="ID: "..LP.UserId,TextSize=8,Font=Enum.Font.Gotham,
    TextColor3=C.tx3,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,
},PIBox)
MkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.bord,ZIndex=13},PIBox)

local NavScroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-118),Position=UDim2.new(0,0,0,72),
    BackgroundTransparency=1,ScrollBarThickness=2,ScrollBarImageColor3=C.p1,
    CanvasSize=UDim2.new(0,0,0,0),ZIndex=12,BorderSizePixel=0,
},Sidebar)
Pad(NavScroll,5,5,6,6)

local NavLayout=New("UIListLayout",{
    Padding=UDim.new(0,3),FillDirection=Enum.FillDirection.Vertical,
    HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,
},NavScroll)
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavScroll.CanvasSize=UDim2.new(0,0,0,NavLayout.AbsoluteContentSize.Y+14)
end)

local sideFooter=MkFrame({
    Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,1,-46),
    BackgroundColor3=C.bg2,ZIndex=12,
},Sidebar)
Grad(sideFooter,C.bg2,Color3.fromRGB(9,8,18),90)
MkFrame({Size=UDim2.new(1,0,0,1),BackgroundColor3=C.bord,ZIndex=13},sideFooter)
New("TextLabel",{
    Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text="BomDev v6.0",TextSize=9,Font=Enum.Font.GothamBold,
    TextColor3=C.tx3,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Center,
},sideFooter)

local PageArea=MkFrame({
    Size=UDim2.new(1,-182,1,-8),Position=UDim2.new(0,179,0,4),
    BackgroundTransparency=1,ZIndex=11,
},ContentWrap)

local Pages={}
local NavBtns={}
local curPage=nil

local NAV_ITEMS={
    {name="Movement",icon="✈️",col=C.b1},
    {name="Combat",  icon="⚔️",col=C.r1},
    {name="Visual",  icon="👁️",col=C.cy},
    {name="Player",  icon="👤",col=C.p2},
    {name="Teleport",icon="🔀",col=C.g1},
    {name="Utils",   icon="🔧",col=C.y1},
    {name="Download",icon="📥",col=C.o1},
    {name="Settings",icon="⚙️",col=C.tx2},
}

local function switchPage(name)
    if curPage==name then return end
    if curPage then
        Pages[curPage].Visible=false
        local ob=NavBtns[curPage]
        if ob then
            Tw(ob.bg,TF,{BackgroundTransparency=1,BackgroundColor3=C.bg3})
            Tw(ob.bar,TF,{BackgroundTransparency=1})
            Tw(ob.namL,TF,{TextColor3=C.tx2})
            Tw(ob.icnL,TF,{TextColor3=C.tx3})
        end
    end
    curPage=name
    Pages[name].Visible=true
    local nb=NavBtns[name]
    if nb then
        Tw(nb.bg,TF,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(22,18,42)})
        Tw(nb.bar,TF,{BackgroundTransparency=0})
        Tw(nb.namL,TF,{TextColor3=C.txt})
        Tw(nb.icnL,TF,{TextColor3=nb.col})
    end
end

for idx,item in ipairs(NAV_ITEMS) do
    local pg=New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        ScrollBarThickness=3,ScrollBarImageColor3=C.p1,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=11,BorderSizePixel=0,
    },PageArea)
    Pad(pg,2,8,6,12)
    local pgL=New("UIListLayout",{
        Padding=UDim.new(0,5),FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,
    },pg)
    pgL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize=UDim2.new(0,0,0,pgL.AbsoluteContentSize.Y+24)
    end)
    Pages[item.name]=pg

    local navRow=MkFrame({
        Size=UDim2.new(1,0,0,42),BackgroundColor3=C.bg3,BackgroundTransparency=1,ZIndex=12,LayoutOrder=idx,
    },NavScroll)
    Corner(navRow,10)

    local bar=MkFrame({
        Size=UDim2.new(0,3,0.55,0),Position=UDim2.new(0,0,0.22,0),
        BackgroundColor3=item.col,BackgroundTransparency=1,ZIndex=14,
    },navRow)
    Corner(bar,2)
    Grad(bar,item.col,C.b1,90)

    local icnBg=MkFrame({
        Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,9,0.5,-14),
        BackgroundColor3=item.col,BackgroundTransparency=0.85,ZIndex=13,
    },navRow)
    Corner(icnBg,8)

    local icnL=New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=item.icon,TextSize=13,Font=Enum.Font.GothamMedium,
        TextColor3=C.tx3,ZIndex=14,TextXAlignment=Enum.TextXAlignment.Center,
    },icnBg)

    local namL=New("TextLabel",{
        Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,44,0,0),
        BackgroundTransparency=1,Text=item.name,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },navRow)

    local clk=New("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15,
    },navRow)

    NavBtns[item.name]={bg=navRow,bar=bar,icnL=icnL,namL=namL,col=item.col}
    local pName=item.name
    clk.MouseButton1Click:Connect(function() switchPage(pName) end)
    clk.MouseEnter:Connect(function()
        if curPage~=pName then
            Tw(navRow,TF,{BackgroundTransparency=0.7,BackgroundColor3=Color3.fromRGB(18,16,32)})
            Tw(namL,TF,{TextColor3=C.txt})
            Tw(icnL,TF,{TextColor3=item.col})
        end
    end)
    clk.MouseLeave:Connect(function()
        if curPage~=pName then
            Tw(navRow,TF,{BackgroundTransparency=1})
            Tw(namL,TF,{TextColor3=C.tx2})
            Tw(icnL,TF,{TextColor3=C.tx3})
        end
    end)
end

local function Section(page,text,col)
    local f=MkFrame({Size=UDim2.new(1,0,0,28),BackgroundColor3=C.bg2,ZIndex=12},page)
    Corner(f,7)
    Grad(f,Color3.fromRGB(18,13,38),C.bg2,140)

    local bar=MkFrame({
        Size=UDim2.new(0,3,0.6,0),Position=UDim2.new(0,9,0.2,0),
        BackgroundColor3=col or C.p1,ZIndex=13,
    },f)
    Corner(bar,2)
    Grad(bar,col or C.p1,C.b1,90)

    New("TextLabel",{
        Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1,Text=text,TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=col or C.b1,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },f)
    return f
end

local function Spacer(page)
    MkFrame({Size=UDim2.new(1,0,0,1),BackgroundColor3=C.bord,ZIndex=12},page)
end

local function Toggle(page,text,default,cb)
    local row=MkFrame({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.bg3,ZIndex=12},page)
    Corner(row,10)
    Grad(row,C.bg3,Color3.fromRGB(13,12,23),115)
    Stroke(row,C.bord,0.8)

    New("TextLabel",{
        Size=UDim2.new(1,-72,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=text,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.txt,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },row)

    local track=MkFrame({
        Size=UDim2.new(0,48,0,26),Position=UDim2.new(1,-62,0.5,-13),
        BackgroundColor3=Color3.fromRGB(24,22,44),ZIndex=13,
    },row)
    Corner(track,13)
    Stroke(track,C.bord,1)

    local trackGlow=New("UIStroke",{Thickness=1.5,Color=C.p1,Transparency=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},track)

    local thumb=MkFrame({
        Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,3,0.5,-10),
        BackgroundColor3=C.tx3,ZIndex=14,
    },track)
    Corner(thumb,10)

    local state=default or false

    local function setVisual(animate)
        local inf=animate and TweenInfo.new(0.22,Enum.EasingStyle.Quart) or TweenInfo.new(0)
        if state then
            Tw(thumb,inf,{Position=UDim2.new(1,-23,0.5,-10),BackgroundColor3=C.wht})
            Tw(track,inf,{BackgroundColor3=Color3.fromRGB(18,42,72)})
            Tw(trackGlow,inf,{Transparency=0.2})
        else
            Tw(thumb,inf,{Position=UDim2.new(0,3,0.5,-10),BackgroundColor3=C.tx3})
            Tw(track,inf,{BackgroundColor3=Color3.fromRGB(24,22,44)})
            Tw(trackGlow,inf,{Transparency=1})
        end
    end
    setVisual(false)

    local clk=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15},row)
    clk.MouseButton1Click:Connect(function()
        state=not state
        setVisual(true)
        if cb then cb(state) end
    end)
    row.MouseEnter:Connect(function() Tw(row,TF,{BackgroundColor3=Color3.fromRGB(20,18,36)}) end)
    row.MouseLeave:Connect(function() Tw(row,TF,{BackgroundColor3=C.bg3}) end)

    return {
        setState=function(v) state=v; setVisual(true) end,
        getState=function() return state end,
    }
end

local function Button(page,text,cb,accent)
    local bg=accent and C.p1 or C.bg4
    local hov=accent and C.p2 or Color3.fromRGB(26,24,44)
    local btn=New("TextButton",{
        Size=UDim2.new(1,0,0,42),BackgroundColor3=bg,
        Text=text,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.txt,BorderSizePixel=0,ZIndex=12,
    },page)
    Corner(btn,10)
    if accent then
        New("UIGradient",{Color=ColorSequence.new(C.p1,C.b1),Rotation=90},btn)
    else
        Grad(btn,C.bg4,Color3.fromRGB(13,12,24),115)
        Stroke(btn,C.bord,0.8)
    end

    btn.MouseEnter:Connect(function() Tw(btn,TF,{BackgroundColor3=hov}) end)
    btn.MouseLeave:Connect(function() Tw(btn,TF,{BackgroundColor3=bg}) end)
    btn.MouseButton1Down:Connect(function()
        Tw(btn,TweenInfo.new(0.08),{BackgroundColor3=accent and Color3.fromRGB(80,40,190) or Color3.fromRGB(30,24,56)})
    end)
    btn.MouseButton1Up:Connect(function()
        Tw(btn,TweenInfo.new(0.08),{BackgroundColor3=hov})
    end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

local function Slider(page,text,vmin,vmax,vdef,suf,cb)
    local con=MkFrame({Size=UDim2.new(1,0,0,60),BackgroundColor3=C.bg3,ZIndex=12},page)
    Corner(con,10)
    Grad(con,C.bg3,Color3.fromRGB(13,12,23),115)
    Stroke(con,C.bord,0.8)

    New("TextLabel",{
        Size=UDim2.new(0.6,0,0,28),Position=UDim2.new(0,14,0,4),
        BackgroundTransparency=1,Text=text,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.txt,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },con)

    local valL=New("TextLabel",{
        Size=UDim2.new(0.4,-14,0,28),Position=UDim2.new(0.6,0,0,4),
        BackgroundTransparency=1,Text=tostring(vdef)..(suf or ""),
        TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=C.p2,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Right,
    },con)

    local sbg=MkFrame({
        Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,0,44),
        BackgroundColor3=Color3.fromRGB(20,18,36),ZIndex=13,
    },con)
    Corner(sbg,3)

    local sfill=MkFrame({
        Size=UDim2.new((vdef-vmin)/(vmax-vmin),0,1,0),BackgroundColor3=C.p1,ZIndex=14,
    },sbg)
    Corner(sfill,3)
    Grad(sfill,C.p1,C.b1,0)

    local sfillGlow=MkFrame({
        Size=UDim2.new((vdef-vmin)/(vmax-vmin),0,1,8),Position=UDim2.new(0,0,0,-4),
        BackgroundColor3=C.p1,BackgroundTransparency=0.75,ZIndex=13,
    },sbg)
    Corner(sfillGlow,3)
    Grad(sfillGlow,C.p1,C.b1,0)

    local sknob=MkFrame({
        Size=UDim2.new(0,16,0,16),Position=UDim2.new((vdef-vmin)/(vmax-vmin),-8,0.5,-8),
        BackgroundColor3=C.wht,ZIndex=15,
    },sbg)
    Corner(sknob,8)
    Stroke(sknob,C.p1,1.5)

    local cur=vdef
    local dragging=false

    local function update(v)
        v=math.clamp(v,vmin,vmax)
        cur=math.floor(v+0.5)
        local r=(cur-vmin)/(vmax-vmin)
        sfill.Size=UDim2.new(r,0,1,0)
        sfillGlow.Size=UDim2.new(r,0,1,8)
        sknob.Position=UDim2.new(r,-8,0.5,-8)
        valL.Text=tostring(cur)..(suf or "")
        if cb then cb(cur) end
    end

    local hit=New("TextButton",{
        Size=UDim2.new(1,20,1,20),Position=UDim2.new(0,-10,0,-10),
        BackgroundTransparency=1,Text="",ZIndex=16,
    },sbg)

    hit.MouseButton1Down:Connect(function()
        dragging=true
        local bx=sbg.AbsolutePosition.X
        local bw=sbg.AbsoluteSize.X
        local mp=UIS:GetMouseLocation()
        update(vmin+math.clamp((mp.X-bx)/bw,0,1)*(vmax-vmin))
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement then
            local bx=sbg.AbsolutePosition.X
            local bw=sbg.AbsoluteSize.X
            update(vmin+math.clamp((inp.Position.X-bx)/bw,0,1)*(vmax-vmin))
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return {getValue=function() return cur end}
end

local function Input(page,text,placeholder,cb)
    local con=MkFrame({Size=UDim2.new(1,0,0,62),BackgroundColor3=C.bg3,ZIndex=12},page)
    Corner(con,10)
    Stroke(con,C.bord,0.8)

    New("TextLabel",{
        Size=UDim2.new(1,-14,0,24),Position=UDim2.new(0,14,0,4),
        BackgroundTransparency=1,Text=text,TextSize=11,Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },con)

    local ibox=New("TextBox",{
        Size=UDim2.new(1,-28,0,26),Position=UDim2.new(0,14,0,30),
        BackgroundColor3=Color3.fromRGB(12,11,22),BorderSizePixel=0,
        Text="",PlaceholderText=placeholder or "",PlaceholderColor3=C.tx3,
        TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.txt,
        ClearTextOnFocus=false,ZIndex=13,
    },con)
    Corner(ibox,6)
    Stroke(ibox,C.bord,1)
    Pad(ibox,8,0,0,0)

    ibox.Focused:Connect(function() Tw(ibox,TF,{BackgroundColor3=Color3.fromRGB(16,14,30)}) end)
    ibox.FocusLost:Connect(function(enter)
        Tw(ibox,TF,{BackgroundColor3=Color3.fromRGB(12,11,22)})
        if enter and cb then cb(ibox.Text) end
    end)
    return ibox
end

local function Dropdown(page,text,opts,cb)
    local con=MkFrame({
        Size=UDim2.new(1,0,0,44),BackgroundColor3=C.bg3,ZIndex=12,ClipsDescendants=false,
    },page)
    Corner(con,10)
    Stroke(con,C.bord,0.8)

    New("TextLabel",{
        Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=text,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.txt,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },con)

    local selF=MkFrame({
        Size=UDim2.new(0.48,-6,0.65,0),Position=UDim2.new(0.52,0,0.175,0),
        BackgroundColor3=Color3.fromRGB(12,11,22),ZIndex=13,
    },con)
    Corner(selF,7)
    Stroke(selF,C.bord,1)
    Pad(selF,8,4,0,0)

    local selL=New("TextLabel",{
        Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text=opts[1] or "—",
        TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.tx2,ZIndex=14,TextXAlignment=Enum.TextXAlignment.Left,
    },selF)

    New("TextLabel",{
        Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-18,0,0),BackgroundTransparency=1,
        Text="▾",TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.tx3,ZIndex=14,
    },selF)

    local dropF=MkFrame({
        Size=UDim2.new(0.48,-6,0,0),Position=UDim2.new(0.52,0,1,4),
        BackgroundColor3=Color3.fromRGB(11,10,21),ZIndex=50,ClipsDescendants=true,
    },con)
    Corner(dropF,8)
    Stroke(dropF,C.p1,1)

    local dLayout=New("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,HorizontalAlignment=Enum.HorizontalAlignment.Center},dropF)
    local isOpen=false

    local function populate(list)
        for _,ch in ipairs(dropF:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _,opt in ipairs(list) do
            local ob=New("TextButton",{
                Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(11,10,21),
                Text=opt,TextSize=10,Font=Enum.Font.Gotham,
                TextColor3=C.txt,BorderSizePixel=0,ZIndex=51,TextXAlignment=Enum.TextXAlignment.Left,
            },dropF)
            Pad(ob,10,0,0,0)
            ob.MouseEnter:Connect(function() Tw(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,18,44)}) end)
            ob.MouseLeave:Connect(function() Tw(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(11,10,21)}) end)
            local cap=opt
            ob.MouseButton1Click:Connect(function()
                selL.Text=cap
                if cb then cb(cap) end
                isOpen=false
                Tw(dropF,TF,{Size=UDim2.new(0.48,-6,0,0)})
            end)
        end
    end
    populate(opts)

    local toggle=New("TextButton",{
        Size=UDim2.new(0.48,-6,0.65,0),Position=UDim2.new(0.52,0,0.175,0),
        BackgroundTransparency=1,Text="",ZIndex=15,
    },con)
    toggle.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        local cnt=0
        for _,ch in ipairs(dropF:GetChildren()) do if ch:IsA("TextButton") then cnt=cnt+1 end end
        Tw(dropF,TF,{Size=isOpen and UDim2.new(0.48,-6,0,cnt*28) or UDim2.new(0.48,-6,0,0)})
    end)
    return {Set=function(list) populate(list); isOpen=false; Tw(dropF,TF,{Size=UDim2.new(0.48,-6,0,0)}); selL.Text=list[1] or "—" end}
end

local pMov=Pages["Movement"]

local function startFly()
    local c=char(); if not c then return end
    local r=hrp();  if not r then return end
    local h=hum();  if not h then return end

    -- cleanup leftovers
    for _,n in ipairs({"BDFlyBV","BDFlyBG"}) do
        local ex=r:FindFirstChild(n); if ex then ex:Destroy() end
    end

    -- BodyVelocity: ต้านแรงโน้มถ่วง + ควบคุม velocity
    local bv = Instance.new("BodyVelocity")
    bv.Name      = "BDFlyBV"
    bv.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity  = Vector3.zero
    bv.Parent    = r

    -- BodyGyro: ล็อคการหมุน
    local bg = Instance.new("BodyGyro")
    bg.Name      = "BDFlyBG"
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.P         = 1e4
    bg.D         = 500
    bg.CFrame    = r.CFrame
    bg.Parent    = r

    -- ปิด humanoid state ที่รบกวนการบิน
    h:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    h:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    h.PlatformStand = false  -- อย่าเปิด PlatformStand เพราะมันบล็อก input

    Conns.fly = RunService.RenderStepped:Connect(function(dt)
        if not State.fly then return end
        local rNow = hrp()
        if not rNow then return end

        local bvNow = rNow:FindFirstChild("BDFlyBV")
        local bgNow = rNow:FindFirstChild("BDFlyBG")

        -- ถ้า objects หายไป (respawn) ให้หยุด loop แล้ว restart
        if not bvNow or not bgNow then
            killConn("fly")
            task.wait(0.1)
            if State.fly then startFly() end
            return
        end

        local camCF = Cam.CFrame
        local look  = camCF.LookVector
        local right = camCF.RightVector
        local up    = Vector3.new(0, 1, 0)
        local spd   = State.flySpeed

        local vel = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            vel = vel + look * spd
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            vel = vel - look * spd
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

        -- ถ้าไม่กดอะไร ให้ hover อยู่กับที่ (ต้านโน้มถ่วง)
        if vel == Vector3.zero then
            bvNow.Velocity = Vector3.new(0, 0, 0)
        else
            bvNow.Velocity = vel
        end

        -- หมุน character ตามทิศบิน (ไม่หมุน Y axis ให้ดูธรรมชาติ)
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            bgNow.CFrame = CFrame.new(rNow.Position, rNow.Position + flatLook)
        end

        -- ป้องกัน humanoid ล้มลง ทุก frame
        local hh = hum()
        if hh then
            if hh:GetState() == Enum.HumanoidStateType.Freefall
            or hh:GetState() == Enum.HumanoidStateType.FallingDown then
                hh:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

local function stopFly()
    killConn("fly")
    local r = hrp()
    if r then
        local bvNow = r:FindFirstChild("BDFlyBV"); if bvNow then bvNow:Destroy() end
        local bgNow = r:FindFirstChild("BDFlyBG"); if bgNow then bgNow:Destroy() end
    end
    local h = hum()
    if h then
        h.PlatformStand = false
        h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        h:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end

Section(pMov,"✈  FLIGHT",C.b1)
Toggle(pMov,"Fly Mode",false,function(v)
    State.fly=v
    if v then startFly(); Notify("✈ Fly","เปิด — WASD + Space + Ctrl",3,C.b1)
    else stopFly(); Notify("✈ Fly","ปิด",2) end
end)
Slider(pMov,"Fly Speed",5,500,60,"",function(v) State.flySpeed=v end)
Button(pMov,"🚁 Hover (Speed 0)",function()
    State.flySpeed=0
    Notify("Fly","Hover mode — Speed=0",2,C.b1)
end)

Spacer(pMov)
Section(pMov,"🏃  SPEED & JUMP",C.g1)
Toggle(pMov,"Super Speed",false,function(v)
    State.speed=v
    local h=hum(); if h then h.WalkSpeed=v and State.speedVal or 16 end
    Notify("Speed",v and "เปิด" or "ปิด",2,C.g1)
end)
Slider(pMov,"Walk Speed",16,500,60,"",function(v)
    State.speedVal=v
    if State.speed then local h=hum(); if h then h.WalkSpeed=v end end
end)
Toggle(pMov,"High Jump",false,function(v)
    State.jump=v
    local h=hum(); if h then h.JumpPower=v and State.jumpVal or 50 end
    Notify("High Jump",v and "เปิด" or "ปิด",2,C.g1)
end)
Slider(pMov,"Jump Power",50,1000,100,"",function(v)
    State.jumpVal=v
    if State.jump then local h=hum(); if h then h.JumpPower=v end end
end)
Toggle(pMov,"Infinite Jump",false,function(v)
    State.infJump=v
    killConn("infJump")
    if v then
        Conns.infJump=UIS.JumpRequest:Connect(function()
            local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    Notify("Infinite Jump",v and "เปิด" or "ปิด",2,C.g1)
end)
Toggle(pMov,"BunnyHop",false,function(v)
    State.bhop=v
    killConn("bhop")
    if v then
        Conns.bhop=RunService.Heartbeat:Connect(function()
            if not State.bhop then return end
            local h=hum()
            if h and h:GetState()==Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    Notify("BunnyHop",v and "เปิด" or "ปิด",2)
end)

Spacer(pMov)
Section(pMov,"🧱  PHYSICS",C.y1)
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
    Notify("NoClip",v and "เปิด" or "ปิด",2,C.y1)
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
    local h=hum(); if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,not v) end
    Notify("No Fall Damage",v and "เปิด" or "ปิด",2)
end)

Spacer(pMov)
Section(pMov,"⚡  QUICK ACTIONS",C.o1)
Button(pMov,"💨 Dash Forward 30 studs",function()
    local r=hrp(); if r then r.CFrame=r.CFrame+r.CFrame.LookVector*30 end
    Notify("Dash","บินไปข้างหน้า 30!",1,C.o1)
end)
Button(pMov,"🚀 Super Launch",function()
    local r=hrp(); if r then r.AssemblyLinearVelocity=Vector3.new(0,250,0) end
    Notify("Launch","ปล่อยจรวด!",1,C.o1)
end)
Button(pMov,"⚡ Speed Burst 3s",function()
    local h=hum(); if not h then return end
    local orig=h.WalkSpeed; h.WalkSpeed=500
    Notify("Speed Burst","3 วินาที! Whoosh!",2,C.o1)
    task.delay(3,function() if h and h.Parent then h.WalkSpeed=orig end end)
end)

Spacer(pMov)
Section(pMov,"🌍  GRAVITY",C.cy)
Slider(pMov,"Gravity",0,300,196,"",function(v) workspace.Gravity=v end)
Button(pMov,"🌙 Low Gravity (40)",function() workspace.Gravity=40; Notify("Gravity","Low 🌙",2,C.cy) end)
Button(pMov,"🌍 Normal (196)",function() workspace.Gravity=196; Notify("Gravity","Normal",2) end)
Button(pMov,"🚀 Zero Gravity",function() workspace.Gravity=0; Notify("Gravity","Zero-G!",2,C.cy) end)

local pCom=Pages["Combat"]

Section(pCom,"🎯  AIMBOT",C.r1)
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
                local inWL=false
                for _,n in ipairs(WL) do if n==p.Name then inWL=true; break end end
                if inWL then continue end
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
    Notify("Aimbot",v and "เปิด 🎯" or "ปิด",2,C.r1)
end)
Slider(pCom,"Aimbot Range",50,1000,200," studs",function(v) State.abRange=v end)
Slider(pCom,"Aimbot Smooth",1,100,15,"%",function(v) State.abSmooth=v/100 end)

Spacer(pCom)
Section(pCom,"🛡  WHITELIST",C.g1)
local wlPDD=Dropdown(pCom,"Add to WL",
    (function() local t={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end; if #t==0 then t={"(ว่าง)"} end; return t end)(),
    function(name)
        if name=="(ว่าง)" then return end
        for _,n in ipairs(WL) do if n==name then Notify("WL",name.." มีแล้ว",2); return end end
        WL[#WL+1]=name; Notify("WL","เพิ่ม "..name,2,C.g1)
    end
)
Button(pCom,"Refresh Player List",function()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end
    if #t==0 then t={"(ว่าง)"} end
    wlPDD.Set(t)
end)
Button(pCom,"Clear Whitelist",function() WL={}; Notify("WL","ล้างแล้ว",2) end)

Spacer(pCom)
Section(pCom,"💥  HITBOX",C.o1)
Toggle(pCom,"Hitbox Expander",false,function(v)
    State.hitbox=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart")
        if r then r.Size=v and Vector3.new(State.hitboxSz,State.hitboxSz,State.hitboxSz) or Vector3.new(2,2,1) end
    end
    Notify("Hitbox",v and "เปิด 💥" or "ปิด",2,C.o1)
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
Section(pCom,"⚔️  KILL AURA",C.r1)
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
    Notify("Kill Aura",v and "เปิด ⚔️" or "ปิด",2,C.r1)
end)
Slider(pCom,"Kill Aura Range",5,100,15," studs",function(v) State.kaRange=v end)

local pVis=Pages["Visual"]
local espConns={}

Section(pVis,"👁  ESP",C.cy)
Toggle(pVis,"Player ESP",false,function(v)
    State.esp=v
    for _,c in ipairs(espConns) do pcall(function() c:Disconnect() end) end
    espConns={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character; if c then local e=c:FindFirstChild("BomDevESP"); if e then e:Destroy() end end
    end
    if not v then Notify("ESP","ปิด",2); return end
    local function addESP(pl)
        local c=pl.Character; if not c then return end
        if c:FindFirstChild("BomDevESP") then return end
        local hl=Instance.new("Highlight")
        hl.Name="BomDevESP"; hl.FillTransparency=0.65; hl.OutlineTransparency=0; hl.Parent=c
        local uc=RunService.Heartbeat:Connect(function()
            if not State.esp then return end
            local myR=hrp()
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
        p.CharacterAdded:Connect(function() task.wait(1); if State.esp then addESP(p) end end)
    end)
    espConns[#espConns+1]=conn
    Notify("ESP","เปิด 👁 — สีตามระยะ",2,C.cy)
end)

Spacer(pVis)
Section(pVis,"✚  CROSSHAIR",C.b1)
Toggle(pVis,"Custom Crosshair",false,function(v)
    State.crosshair=v
    local ex=SG:FindFirstChild("BomDevCH"); if ex then ex:Destroy() end
    if not v then Notify("Crosshair","ปิด",2); return end
    local csg=Instance.new("ScreenGui")
    csg.Name="BomDevCH"; csg.ResetOnSpawn=false; csg.IgnoreGuiInset=true
    safe(function() csg.Parent=CoreGui end)
    if not csg.Parent then csg.Parent=LP:WaitForChild("PlayerGui") end
    local lines={
        {UDim2.new(0,18,0,2),UDim2.new(0.5,7,0.5,-1)},
        {UDim2.new(0,18,0,2),UDim2.new(0.5,-25,0.5,-1)},
        {UDim2.new(0,2,0,18),UDim2.new(0.5,-1,0.5,7)},
        {UDim2.new(0,2,0,18),UDim2.new(0.5,-1,0.5,-25)},
    }
    for _,d in ipairs(lines) do
        local ln=MkFrame({Size=d[1],Position=d[2],BackgroundColor3=C.b1,ZIndex=1},csg)
        Corner(ln,1)
    end
    local dot=MkFrame({Size=UDim2.new(0,4,0,4),Position=UDim2.new(0.5,-2,0.5,-2),BackgroundColor3=C.wht,ZIndex=1},csg)
    Corner(dot,2)
    Notify("Crosshair","เปิด ✚",2,C.b1)
end)

Spacer(pVis)
Section(pVis,"💡  LIGHTING",C.y1)
Toggle(pVis,"Fullbright",false,function(v)
    if v then
        Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.FogEnd=1e5
        Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness=1; Lighting.ClockTime=12; Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127)
    end
    Notify("Fullbright",v and "เปิด ☀️" or "ปิด",2,C.y1)
end)
Toggle(pVis,"Night Vision",false,function(v)
    if v then
        Lighting.Brightness=5; Lighting.Ambient=Color3.fromRGB(80,255,120); Lighting.GlobalShadows=false
    else
        Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(127,127,127); Lighting.GlobalShadows=true
    end
    Notify("Night Vision",v and "เปิด 🌃" or "ปิด",2,C.g1)
end)
Button(pVis,"Remove Fog",function() Lighting.FogEnd=999999; Notify("Fog","ลบแล้ว",2) end)

Spacer(pVis)
Section(pVis,"✨  CHARACTER FX",C.p2)
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
    Notify("Rainbow",v and "เปิด 🌈" or "ปิด",2,C.p2)
end)
Toggle(pVis,"Cinematic Mode",false,function(v)
    State.cinema=v
    safe(function() StarterGui:SetCore("TopbarEnabled",not v) end)
    Notify("Cinematic",v and "เปิด 🎬" or "ปิด",2)
end)

Spacer(pVis)
Section(pVis,"📊  STAT MONITOR",C.b1)
Toggle(pVis,"Stats HUD",false,function(v)
    State.stats=v
    local ex=SG:FindFirstChild("BomDevStats"); if ex then ex:Destroy() end
    if not v then Notify("Stats","ปิด",2); return end
    local ssg=Instance.new("ScreenGui")
    ssg.Name="BomDevStats"; ssg.ResetOnSpawn=false; ssg.IgnoreGuiInset=true
    safe(function() ssg.Parent=CoreGui end)
    if not ssg.Parent then ssg.Parent=LP:WaitForChild("PlayerGui") end
    local box=MkFrame({Size=UDim2.new(0,200,0,112),Position=UDim2.new(0,10,0,90),BackgroundColor3=C.bg1,ZIndex=50},ssg)
    Corner(box,12)
    Stroke(box,C.p1,1.2)
    Grad(box,Color3.fromRGB(10,7,22),C.bg1,140)
    New("TextLabel",{
        Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Text="⚡ BomDev Stats",TextSize=11,
        Font=Enum.Font.GothamBold,TextColor3=C.b1,ZIndex=51,TextXAlignment=Enum.TextXAlignment.Center,
    },box)
    local lines={"FPS","Speed","Health","Position"}
    local lbls={}
    for i,n in ipairs(lines) do
        local sl=New("TextLabel",{
            Size=UDim2.new(1,-14,0,18),Position=UDim2.new(0,8,0,22+(i-1)*20),
            BackgroundTransparency=1,Text=n..": ...",TextSize=10,Font=Enum.Font.Code,
            TextColor3=C.txt,ZIndex=51,TextXAlignment=Enum.TextXAlignment.Left,
        },box)
        lbls[n]=sl
    end
    local fc,lastT=0,tick()
    RunService.RenderStepped:Connect(function()
        if not State.stats then return end
        fc=fc+1
        local now=tick()
        if now-lastT>=1 then
            local fps=math.floor(fc/(now-lastT)); fc=0; lastT=now
            local h=hum(); local r=hrp()
            local hp=h and math.floor(h.Health) or 0
            local mhp=h and math.floor(h.MaxHealth) or 100
            local sp=h and math.floor(h.WalkSpeed) or 0
            local pos=r and r.Position or Vector3.zero
            if lbls.FPS      then lbls.FPS.Text="FPS    "..fps end
            if lbls.Speed    then lbls.Speed.Text="Speed  "..sp end
            if lbls.Health   then lbls.Health.Text="HP     "..hp.."/"..mhp end
            if lbls.Position then lbls.Position.Text=math.floor(pos.X).." "..math.floor(pos.Y).." "..math.floor(pos.Z) end
        end
    end)
    Notify("Stats","เปิด 📊",2,C.b1)
end)

local pPly=Pages["Player"]

Section(pPly,"🛡  PROTECTION",C.g1)
Toggle(pPly,"God Mode",false,function(v)
    State.god=v
    killConn("god")
    local h=hum()
    if v then
        if h then h.MaxHealth=math.huge; h.Health=math.huge; h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end
        Conns.god=RunService.Heartbeat:Connect(function()
            local hh=hum(); if hh and hh.Health<1e10 then hh.Health=math.huge end
        end)
    else
        if h then h.MaxHealth=100; h.Health=100; h:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end
    end
    Notify("God Mode",v and "เปิด 🛡" or "ปิด",2,C.g1)
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
    Notify("Invisible",v and "เปิด 👻" or "ปิด",2)
end)

Spacer(pPly)
Section(pPly,"👤  CHARACTER",C.p2)
Slider(pPly,"Character Scale",10,300,100,"%",function(v)
    local h=hum(); if not h then return end
    local s=v/100
    safe(function()
        h.BodyDepthScale.Value=s; h.BodyHeightScale.Value=s
        h.BodyWidthScale.Value=s; h.HeadScale.Value=s
    end)
end)
Dropdown(pPly,"Body Color",
    {"Default","Red","Blue","Green","Yellow","Purple","Black","White","Cyan","Pink"},
    function(opt)
        local map={
            Red=Color3.fromRGB(200,50,50),Blue=Color3.fromRGB(50,100,220),
            Green=Color3.fromRGB(50,180,80),Yellow=Color3.fromRGB(230,210,50),
            Purple=Color3.fromRGB(130,60,220),Black=Color3.fromRGB(25,25,25),
            White=Color3.fromRGB(240,240,240),Cyan=Color3.fromRGB(50,220,220),
            Pink=Color3.fromRGB(240,100,180),
        }
        local c=char(); if not c then return end
        local col=map[opt]
        if col then
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Color=col end
            end
        end
        Notify("Body Color",opt,2,C.p2)
    end
)

Spacer(pPly)
Section(pPly,"✨  EFFECTS",C.p1)
Toggle(pPly,"Character Glow",false,function(v)
    State.glow=v
    local c=char(); if not c then return end
    local ex=c:FindFirstChild("BomDevGlow"); if ex then ex:Destroy() end
    if v then
        local hl=Instance.new("Highlight")
        hl.Name="BomDevGlow"; hl.FillColor=C.p1; hl.FillTransparency=0.7
        hl.OutlineColor=C.b1; hl.OutlineTransparency=0; hl.Parent=c
    end
    Notify("Glow",v and "เปิด ✨" or "ปิด",2,C.p1)
end)
Toggle(pPly,"Fire Effect",false,function(v)
    State.fire=v
    local c=char(); if not c then return end
    if v then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                local f=Instance.new("Fire"); f.Name="BomDevFire"; f.Heat=5; f.Size=3; f.Parent=p
            end
        end
    else
        for _,p in ipairs(c:GetDescendants()) do
            local f=p:FindFirstChild("BomDevFire"); if f then f:Destroy() end
        end
    end
    Notify("Fire",v and "เปิด 🔥" or "ปิด",2,C.r1)
end)
Toggle(pPly,"Sparkle Effect",false,function(v)
    State.sparkle=v
    local c=char(); if not c then return end
    if v then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                local sp=Instance.new("Sparkles"); sp.Name="BomDevSparkle"; sp.SparkleColor=C.b1; sp.Parent=p
            end
        end
    else
        for _,p in ipairs(c:GetDescendants()) do
            local sp=p:FindFirstChild("BomDevSparkle"); if sp then sp:Destroy() end
        end
    end
    Notify("Sparkle",v and "เปิด ✨" or "ปิด",2,C.b1)
end)
Toggle(pPly,"Force Field",false,function(v)
    local c=char(); if not c then return end
    local ex=c:FindFirstChildOfClass("ForceField"); if ex then ex:Destroy() end
    if v then local ff=Instance.new("ForceField"); ff.Visible=true; ff.Parent=c end
    Notify("Force Field",v and "เปิด 🔵" or "ปิด",2,C.b1)
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
        local tr=Instance.new("Trail"); tr.Name="BomDevTrail"
        tr.Attachment0=a0; tr.Attachment1=a1; tr.Lifetime=0.8; tr.MinLength=0; tr.FaceCamera=true
        tr.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.p1),
            ColorSequenceKeypoint.new(0.5,C.b1),
            ColorSequenceKeypoint.new(1,C.wht),
        })
        tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
        tr.Parent=r
    end
    Notify("Trail",v and "เปิด 💫" or "ปิด",2,C.p1)
end)

Button(pPly,"Reset Character",function()
    local h=hum(); if h then h.Health=0 end
end)
Input(pPly,"Play Animation","Animation ID (ตัวเลข)",function(text)
    if not text or #text==0 then return end
    local h=hum(); if not h then return end
    local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://"..text
    local t=h:LoadAnimation(anim); t:Play()
    Notify("Anim","กำลังเล่น "..text,2,C.p2)
end)

local pTel=Pages["Teleport"]
local selectedPlayer=nil

Section(pTel,"🎯  TARGET",C.g1)
local function getPlayerNames()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end
    if #t==0 then t={"(ว่าง)"} end
    return t
end
local pDD=Dropdown(pTel,"Target Player",getPlayerNames(),function(name)
    if name=="(ว่าง)" then selectedPlayer=nil; return end
    selectedPlayer=Players:FindFirstChild(name)
    Notify("Target",selectedPlayer and "เลือก: "..name or "ไม่พบ",2,C.g1)
end)
Button(pTel,"Refresh Player List",function() pDD.Set(getPlayerNames()) end)

Spacer(pTel)
Section(pTel,"⚡  ACTIONS",C.b1)
Button(pTel,"🔀 Warp to Target",function()
    if not selectedPlayer or not selectedPlayer.Character then Notify("Warp","ไม่มีเป้าหมาย",2,C.r1); return end
    local r=hrp()
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then r.CFrame=tr.CFrame+Vector3.new(0,3,0) end
    Notify("Warp","ไปหา "..selectedPlayer.Name,2,C.b1)
end)
Button(pTel,"🧲 Pull Target Here",function()
    if not selectedPlayer or not selectedPlayer.Character then Notify("Pull","ไม่มีเป้าหมาย",2,C.r1); return end
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myR=hrp()
    if not (tr and myR) then return end
    local ex=tr:FindFirstChild("BDPull"); if ex then ex:Destroy() end
    local bp=Instance.new("BodyPosition")
    bp.Name="BDPull"; bp.MaxForce=Vector3.new(9e9,9e9,9e9); bp.P=8e3; bp.D=600
    bp.Position=myR.Position+myR.CFrame.LookVector*3; bp.Parent=tr
    Notify("Pull","ดึง "..selectedPlayer.Name,2,C.g1)
    task.delay(2,function() if bp and bp.Parent then bp:Destroy() end end)
end)
Toggle(pTel,"Freeze Target",false,function(v)
    if not selectedPlayer or not selectedPlayer.Character then Notify("Freeze","ไม่มีเป้าหมาย",2,C.r1); return end
    local tr=selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end
    if v then
        local bf=Instance.new("BodyForce")
        bf.Name="BDFreeze"; bf.Force=Vector3.new(0,workspace.Gravity*tr:GetMass(),0); bf.Parent=tr
        local ba=Instance.new("BodyAngularVelocity")
        ba.Name="BDFreezeA"; ba.AngularVelocity=Vector3.zero; ba.MaxTorque=Vector3.new(1e9,1e9,1e9); ba.Parent=tr
    else
        local f=tr:FindFirstChild("BDFreeze"); if f then f:Destroy() end
        local a=tr:FindFirstChild("BDFreezeA"); if a then a:Destroy() end
    end
    Notify("Freeze",v and selectedPlayer.Name.." หยุด ❄️" or "ปลดแล้ว",2,C.cy)
end)
Toggle(pTel,"Spectate",false,function(v)
    killConn("spectate")
    if v then
        if not selectedPlayer or not selectedPlayer.Character then Notify("Spectate","ไม่มีเป้าหมาย",2,C.r1); return end
        local h=selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then Cam.CameraSubject=h end
        Notify("Spectate","ดู "..selectedPlayer.Name,2)
    else
        Cam.CameraSubject=hum(); Notify("Spectate","ปิด",2)
    end
end)

Spacer(pTel)
Section(pTel,"📍  SAVED POSITIONS",C.p2)
for slot=1,5 do
    local row=MkFrame({Size=UDim2.new(1,0,0,42),BackgroundColor3=C.bg3,ZIndex=12},pTel)
    Corner(row,10)
    Stroke(row,C.bord,0.8)
    New("TextLabel",{
        Size=UDim2.new(0.36,0,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text="📌 Slot "..slot,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.tx2,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },row)
    local saveB=New("TextButton",{
        Size=UDim2.new(0.29,-4,0.65,0),Position=UDim2.new(0.38,0,0.175,0),
        BackgroundColor3=Color3.fromRGB(18,36,18),Text="💾 Save",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.g1,BorderSizePixel=0,ZIndex=13,
    },row)
    Corner(saveB,6)
    Stroke(saveB,Color3.fromRGB(30,65,30),1)
    local tpB=New("TextButton",{
        Size=UDim2.new(0.29,-4,0.65,0),Position=UDim2.new(0.69,0,0.175,0),
        BackgroundColor3=Color3.fromRGB(16,18,40),Text="🔀 Warp",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.b1,BorderSizePixel=0,ZIndex=13,
    },row)
    Corner(tpB,6)
    Stroke(tpB,Color3.fromRGB(28,32,70),1)
    local s=slot
    saveB.MouseButton1Click:Connect(function()
        local r=hrp(); if r then SavedPos[s]=r.CFrame; Notify("Saved","Slot "..s.." 💾",2,C.g1) end
    end)
    tpB.MouseButton1Click:Connect(function()
        if SavedPos[s] then
            local r=hrp(); if r then r.CFrame=SavedPos[s]+Vector3.new(0,3,0); Notify("Warp","Slot "..s,2,C.b1) end
        else
            Notify("Warp","Slot "..s.." ว่าง",2,C.r1)
        end
    end)
    row.MouseEnter:Connect(function() Tw(row,TF,{BackgroundColor3=Color3.fromRGB(20,18,34)}) end)
    row.MouseLeave:Connect(function() Tw(row,TF,{BackgroundColor3=C.bg3}) end)
end

Spacer(pTel)
Button(pTel,"⬆ +50 Studs Up",function()
    local r=hrp(); if r then r.CFrame=r.CFrame+Vector3.new(0,50,0) end
    Notify("Teleport","+50 Studs ⬆",1,C.b1)
end)
Button(pTel,"🎯 Origin (0,0,0)",function()
    local r=hrp(); if r then r.CFrame=CFrame.new(0,50,0) end
    Notify("Teleport","Origin!",1)
end)
Button(pTel,"🎲 Random Position",function()
    local r=hrp()
    if r then r.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500)) end
    Notify("Teleport","Random! 🎲",1)
end)

local pUti=Pages["Utils"]

Section(pUti,"🌐  SERVER",C.b1)
Button(pUti,"🔄 Rejoin",function()
    Notify("Rejoin","กำลัง rejoin...",2,C.b1)
    task.delay(1,function() TeleportSvc:Teleport(game.PlaceId,LP) end)
end)
Button(pUti,"🔀 Server Hop",function()
    Notify("Server Hop","กำลังหา server...",2,C.b1)
    safe(function()
        local data=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local ok,parsed=pcall(function() return game:GetService("HttpService"):JSONDecode(data) end)
        if ok and parsed and parsed.data then
            for _,s in ipairs(parsed.data) do
                if s.id~=game.JobId and s.playing<s.maxPlayers then
                    TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,LP); return
                end
            end
        end
        Notify("Server Hop","ไม่พบ server ว่าง",2,C.r1)
    end)
end)
Button(pUti,"📋 Copy Place ID",function()
    safe(function() setclipboard(tostring(game.PlaceId)) end)
    Notify("Copied","Place ID: "..game.PlaceId,2,C.g1)
end)
Button(pUti,"ℹ️ Server Info",function()
    Notify("Server Info","Place: "..game.PlaceId.."  Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,4,C.b1)
end)

Spacer(pUti)
Section(pUti,"🎵  MUSIC PLAYER",C.p2)
local musicId=""
local musicObj=nil
Input(pUti,"Sound ID","ใส่ Sound ID (ตัวเลข)...",function(txt) musicId=txt end)
local musicVol=Slider(pUti,"Volume",0,100,50,"%",function(v)
    if musicObj then musicObj.Volume=v/100 end
end)
Button(pUti,"▶ Play",function()
    if musicObj then musicObj:Destroy(); musicObj=nil end
    if musicId=="" then Notify("Music","ใส่ Sound ID ก่อน!",2,C.r1); return end
    local snd=Instance.new("Sound")
    snd.SoundId="rbxassetid://"..musicId; snd.Volume=musicVol.getValue()/100
    snd.Looped=true; snd.Parent=LP:WaitForChild("PlayerGui"); snd:Play()
    musicObj=snd
    Notify("Music","▶ เล่น "..musicId,2,C.p2)
end)
Button(pUti,"⏹ Stop",function()
    if musicObj then musicObj:Destroy(); musicObj=nil end
    Notify("Music","⏹ หยุดแล้ว",2)
end)

Spacer(pUti)
Section(pUti,"🤖  AUTO SYSTEMS",C.o1)
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
    Notify("Auto Farm",v and "เปิด 🤖" or "ปิด",2,C.o1)
end)

Spacer(pUti)
Section(pUti,"🌍  WORLD",C.cy)
Input(pUti,"Find & Teleport Part","ชื่อ Part...",function(text)
    if not text or #text==0 then return end
    local r=hrp(); if not r then return end
    local found,closest,closestD=0,nil,math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(text:lower()) and obj:IsA("BasePart") then
            found=found+1
            local d=(r.Position-obj.Position).Magnitude
            if d<closestD then closestD=d; closest=obj end
        end
    end
    Notify("Find","พบ "..found.." parts",3,C.cy)
    if closest then r.CFrame=CFrame.new(closest.Position+Vector3.new(0,5,0)) end
end)

Spacer(pUti)
Button(pUti,"💬 Join Discord",function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","เปิดแล้ว! 💬",3,Color3.fromRGB(88,101,242))
end,true)

local pDl=Pages["Download"]

local hero=MkFrame({Size=UDim2.new(1,0,0,96),BackgroundColor3=C.p1,ZIndex=12},pDl)
Corner(hero,14)
New("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(60,20,160)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,80,200)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(20,160,220)),
}),Rotation=130},hero)

local heroIconBg=MkFrame({
    Size=UDim2.new(0,62,0,62),Position=UDim2.new(0,14,0.5,-31),
    BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.15,ZIndex=13,
},hero)
Corner(heroIconBg,31)
New("TextLabel",{
    Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⚡",TextSize=40,
    Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=14,
},heroIconBg)

New("TextLabel",{
    Size=UDim2.new(1,-92,0,30),Position=UDim2.new(0,86,0,16),
    BackgroundTransparency=1,Text="BomDev Downloads",TextSize=17,Font=Enum.Font.GothamBold,
    TextColor3=C.wht,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
},hero)
New("TextLabel",{
    Size=UDim2.new(1,-92,0,18),Position=UDim2.new(0,86,0,50),
    BackgroundTransparency=1,Text="Scripts & Tools จาก BomDev Community",TextSize=10,Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(200,210,235),ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
},hero)
New("TextLabel",{
    Size=UDim2.new(1,-92,0,14),Position=UDim2.new(0,86,0,70),
    BackgroundTransparency=1,Text="💬 discord.gg/4Vn8WwyV3u",TextSize=9,Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(160,180,220),ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
},hero)

local function DlCard(parent,title,desc,badge,badgeCol)
    local card=MkFrame({Size=UDim2.new(1,0,0,78),BackgroundColor3=C.bg3,ZIndex=12},parent)
    Corner(card,12)
    Grad(card,Color3.fromRGB(16,12,28),C.bg3,150)
    Stroke(card,C.bord,0.8)

    local ib=MkFrame({
        Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,12,0.5,-24),
        BackgroundColor3=badgeCol or C.p1,ZIndex=13,
    },card)
    Corner(ib,12)
    New("UIGradient",{Color=ColorSequence.new(badgeCol or C.p1,C.b1),Rotation=135},ib)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="📥",TextSize=22,Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=14},ib)

    New("TextLabel",{
        Size=UDim2.new(1,-145,0,22),Position=UDim2.new(0,70,0,10),
        BackgroundTransparency=1,Text=title,TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=C.txt,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },card)
    New("TextLabel",{
        Size=UDim2.new(1,-145,0,18),Position=UDim2.new(0,70,0,34),
        BackgroundTransparency=1,Text=desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.tx2,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },card)

    local bf=MkFrame({
        Size=UDim2.new(0,52,0,18),Position=UDim2.new(0,70,0,57),
        BackgroundColor3=badgeCol or C.p1,ZIndex=13,
    },card)
    Corner(bf,9)
    New("UIGradient",{Color=ColorSequence.new(badgeCol or C.p1,C.b1),Rotation=90},bf)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=badge or "FREE",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=14},bf)

    local gb=New("TextButton",{
        Size=UDim2.new(0,68,0,30),Position=UDim2.new(1,-80,0.5,-15),
        BackgroundColor3=badgeCol or C.p1,Text="Get",TextSize=11,Font=Enum.Font.GothamBold,
        TextColor3=C.wht,BorderSizePixel=0,ZIndex=13,
    },card)
    Corner(gb,8)
    New("UIGradient",{Color=ColorSequence.new(badgeCol or C.p1,C.b1),Rotation=90},gb)
    gb.MouseEnter:Connect(function() Tw(card,TF,{BackgroundColor3=Color3.fromRGB(22,18,38)}); Tw(gb,TF,{BackgroundColor3=(badgeCol or C.p1)}) end)
    gb.MouseLeave:Connect(function() Tw(card,TF,{BackgroundColor3=C.bg3}) end)
    gb.MouseButton1Click:Connect(function()
        safe(function() setclipboard(DISCORD) end)
        safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
        Notify("Download 📥",title.." — เปิด Discord!",3,badgeCol or C.p1)
    end)
    return card
end

Spacer(pDl)
Section(pDl,"🔥  FEATURED",C.o1)
DlCard(pDl,"BomDev Hub v6.0","Main hub script — Latest","LATEST",Color3.fromRGB(110,55,245))
DlCard(pDl,"AutoFarm Pro","Multi-game auto farm","PRO",Color3.fromRGB(215,145,0))
DlCard(pDl,"ESP Suite","Player ESP + Radar","FREE",Color3.fromRGB(40,190,80))
DlCard(pDl,"Speed Kit","Movement bundle","FREE",Color3.fromRGB(40,170,220))

Spacer(pDl)
Section(pDl,"🎮  GAME SCRIPTS",C.b1)
DlCard(pDl,"Blox Fruits Farm","Auto farm + raids + boss","HOT",Color3.fromRGB(220,118,45))
DlCard(pDl,"Pet Simulator Farm","Pets & coins auto","FREE",Color3.fromRGB(45,200,130))
DlCard(pDl,"Murder Mystery 2 ESP","Knife & gun ESP","FREE",Color3.fromRGB(205,45,75))
DlCard(pDl,"Arsenal Suite","Aimbot + ESP","PRO",Color3.fromRGB(70,155,248))
DlCard(pDl,"Adopt Me Farm","Auto bucks & pets","FREE",Color3.fromRGB(248,178,75))
DlCard(pDl,"Da Hood","Silent aim + btoolz","PRO",Color3.fromRGB(188,55,55))

Spacer(pDl)
Section(pDl,"🔧  TOOLS",C.tx2)
DlCard(pDl,"Executor Checker","Check executor features","FREE",Color3.fromRGB(80,80,165))
DlCard(pDl,"Anti-Ban Kit","Bypass detection methods","PRO",Color3.fromRGB(185,80,80))

Spacer(pDl)
local dscCard=MkFrame({Size=UDim2.new(1,0,0,66),BackgroundColor3=Color3.fromRGB(68,85,218),ZIndex=12},pDl)
Corner(dscCard,12)
New("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(55,68,200)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(95,115,248)),
}),Rotation=135},dscCard)
New("TextLabel",{
    Size=UDim2.new(0,42,0,42),Position=UDim2.new(0,14,0.5,-21),
    BackgroundTransparency=1,Text="💬",TextSize=28,Font=Enum.Font.GothamBold,TextColor3=C.wht,ZIndex=13,
},dscCard)
New("TextLabel",{
    Size=UDim2.new(1,-155,0,22),Position=UDim2.new(0,62,0,10),
    BackgroundTransparency=1,Text="BomDev Discord",TextSize=13,Font=Enum.Font.GothamBold,
    TextColor3=C.wht,ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
},dscCard)
New("TextLabel",{
    Size=UDim2.new(1,-155,0,16),Position=UDim2.new(0,62,0,34),
    BackgroundTransparency=1,Text="Scripts อัปเดต + Community",TextSize=10,Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(200,208,240),ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
},dscCard)
local jb=New("TextButton",{
    Size=UDim2.new(0,68,0,28),Position=UDim2.new(1,-80,0.5,-14),
    BackgroundColor3=C.wht,Text="Join",TextSize=11,Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(68,85,218),BorderSizePixel=0,ZIndex=13,
},dscCard)
Corner(jb,8)
jb.MouseButton1Click:Connect(function()
    safe(function() setclipboard(DISCORD) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD) end)
    Notify("Discord","เปิดแล้ว! 💬",2,Color3.fromRGB(88,101,242))
end)

local pSet=Pages["Settings"]

Section(pSet,"📷  CAMERA",C.b1)
Slider(pSet,"FOV",50,120,70,"°",function(v) Cam.FieldOfView=v end)
Button(pSet,"FOV 70 (Default)",function() Cam.FieldOfView=70; Notify("FOV","70° (Default)",2) end)
Button(pSet,"FOV 110 (Wide)",function() Cam.FieldOfView=110; Notify("FOV","110° (Wide)",2,C.b1) end)

Spacer(pSet)
Section(pSet,"💡  LIGHTING",C.y1)
Slider(pSet,"Clock Time",0,24,14,"h",function(v) Lighting.ClockTime=v end)
Slider(pSet,"Brightness",0,10,2,"x",function(v) Lighting.Brightness=v end)
Toggle(pSet,"Global Shadows",true,function(v) Lighting.GlobalShadows=v end)

Spacer(pSet)
Section(pSet,"⌨  HOTKEYS",C.tx2)
local hkF=MkFrame({Size=UDim2.new(1,0,0,150),BackgroundColor3=C.bg3,ZIndex=12},pSet)
Corner(hkF,12)
Grad(hkF,Color3.fromRGB(14,11,26),C.bg3,140)
Stroke(hkF,C.bord,0.8)

local hkeys={
    {"F1","Fly toggle"},
    {"F2","Speed toggle"},
    {"F3","God Mode toggle"},
    {"F4","NoClip toggle"},
    {"]","ซ่อน / แสดง GUI"},
    {"WASD","บินตามกล้อง"},
    {"Space","บินขึ้น"},
    {"LCtrl / LShift","บินลง"},
    {"LMB + Drag","ลาก GUI (ใน Title)"},
}
for i,pair in ipairs(hkeys) do
    local row=MkFrame({
        Size=UDim2.new(1,-16,0,15),Position=UDim2.new(0,8,0,4+(i-1)*16),
        BackgroundTransparency=1,ZIndex=13,
    },hkF)
    local kBg=MkFrame({
        Size=UDim2.new(0,88,0,13),BackgroundColor3=Color3.fromRGB(14,13,24),ZIndex=14,
    },row)
    Corner(kBg,4)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=pair[1],TextSize=9,
        Font=Enum.Font.Code,TextColor3=C.b1,ZIndex=15,TextXAlignment=Enum.TextXAlignment.Center,
    },kBg)
    New("TextLabel",{
        Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,96,0,0),
        BackgroundTransparency=1,Text=pair[2],TextSize=9,Font=Enum.Font.Gotham,
        TextColor3=C.tx2,ZIndex=14,TextXAlignment=Enum.TextXAlignment.Left,
    },row)
end

Spacer(pSet)
Section(pSet,"ℹ️  ABOUT",C.p1)
local aboutF=MkFrame({Size=UDim2.new(1,0,0,108),BackgroundColor3=C.bg3,ZIndex=12},pSet)
Corner(aboutF,12)
Grad(aboutF,Color3.fromRGB(14,9,30),C.bg3,140)
Stroke(aboutF,Color3.fromRGB(60,40,100),1)

local abLines={
    {"⚡ BomDev Hub  v6.0",Enum.Font.GothamBold,C.txt},
    {"Dev: BomDev",Enum.Font.GothamMedium,C.p2},
    {"discord.gg/4Vn8WwyV3u",Enum.Font.Gotham,C.b1},
    {"",Enum.Font.Gotham,C.tx3},
    {"✅ Fly — WASD ตามกล้อง, Space/Ctrl",Enum.Font.Gotham,C.g1},
    {"✅ UI ใหม่ v6.0 — Ultra Premium",Enum.Font.Gotham,C.g1},
    {"✅ ทุก Bug แก้ไขเรียบร้อย 100%",Enum.Font.Gotham,C.g1},
    {"✅ Notifications พร้อม Progress Bar",Enum.Font.Gotham,C.g1},
}
for i,ln in ipairs(abLines) do
    New("TextLabel",{
        Size=UDim2.new(1,-20,0,12),Position=UDim2.new(0,12,0,2+(i-1)*13),
        BackgroundTransparency=1,Text=ln[1],TextSize=10,Font=ln[2],TextColor3=ln[3],
        ZIndex=13,TextXAlignment=Enum.TextXAlignment.Left,
    },aboutF)
end

UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.F1 then
        State.fly=not State.fly
        if State.fly then startFly(); Notify("✈ Fly","F1 — เปิด",1,C.b1)
        else stopFly(); Notify("✈ Fly","F1 — ปิด",1) end
    end
    if inp.KeyCode==Enum.KeyCode.F2 then
        State.speed=not State.speed
        local h=hum(); if h then h.WalkSpeed=State.speed and State.speedVal or 16 end
        Notify("Speed",State.speed and "F2 — เปิด" or "F2 — ปิด",1,C.g1)
    end
    if inp.KeyCode==Enum.KeyCode.F3 then
        State.god=not State.god
        killConn("god")
        local h=hum()
        if State.god then
            if h then h.MaxHealth=math.huge; h.Health=math.huge; h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum(); if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
            Notify("God","F3 — เปิด 🛡",1,C.g1)
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
        Notify("NoClip",State.noclip and "F4 — เปิด" or "F4 — ปิด",1,C.y1)
    end
    if inp.KeyCode==Enum.KeyCode.RightBracket then
        MF.Visible=not MF.Visible
        if MF.Visible then Notify("BomDev Hub","แสดงแล้ว 👁",1,C.p1) end
    end
end)

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
        hl.Name="BomDevGlow"; hl.FillColor=C.p1; hl.FillTransparency=0.7
        hl.OutlineColor=C.b1; hl.OutlineTransparency=0; hl.Parent=c
    end
    if State.fly then task.wait(0.5); startFly() end
end)

task.defer(function() switchPage("Movement") end)
task.spawn(doLoad)
