local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flyEnabled = false
local flySpeed = 60
local speedEnabled = false
local speedValue = 60
local jumpEnabled = false
local jumpValue = 100
local noclipEnabled = false
local invisEnabled = false
local espEnabled = false
local espDetailEnabled = false
local aimbotEnabled = false
local aimbotRange = 200
local aimbotSmooth = 0.15
local selectedPlayer = nil
local godEnabled = false
local infiniteJumpEnabled = false
local bunnyHopEnabled = false
local hitboxEnabled = false
local hitboxSize = 10
local reachEnabled = false
local reachDist = 30
local autoFarmEnabled = false
local noFrictionEnabled = false
local rainbowEnabled = false
local walkWaterEnabled = false
local savedPos = {}
local aimbotWL = {}
local musicObj = nil
local currentMusicId = ""
local trackerEnabled = false
local espConns = {}
local trackerConns = {}
local noFallEnabled = false
local antiAFKEnabled = false
local glowEnabled = false
local fireEnabled = false
local sparkleEnabled = false
local trailEnabled = false
local followEnabled = false
local killAuraEnabled = false
local killAuraRange = 15
local nightVisionEnabled = false
local statMonitorEnabled = false
local weatherEnabled = false
local cinematicEnabled = false
local flyConns = {}
local flyBV = nil
local flyBG = nil
local bhopConn = nil
local noclipConn = nil
local noFrictionConn = nil
local waterPart = nil
local waterConn = nil
local rainbowConn = nil
local infJumpConn = nil
local aimbotConn = nil
local godConn = nil
local killAuraConn = nil
local followConn = nil
local statGui = nil
local trackerGui = nil
local crosshairGui = nil
local antiAFKConn = nil
local specConn = nil

local DISCORD_LINK = "https://discord.gg/4Vn8WwyV3u"

local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    if c then return c:FindFirstChild("HumanoidRootPart") end
end
local function getHum()
    local c = getChar()
    if c then return c:FindFirstChildOfClass("Humanoid") end
end
local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[BomDev]", err) end
    return ok
end
local function getPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end
local function inWL(p)
    for _, n in ipairs(aimbotWL) do
        if n == p.Name then return true end
    end
    return false
end

local BG = Color3.fromRGB(8, 8, 14)
local BG2 = Color3.fromRGB(13, 13, 20)
local BG3 = Color3.fromRGB(18, 18, 28)
local BG4 = Color3.fromRGB(24, 24, 36)
local ACC = Color3.fromRGB(100, 60, 255)
local ACC2 = Color3.fromRGB(60, 180, 255)
local ACC3 = Color3.fromRGB(200, 80, 255)
local WHT = Color3.fromRGB(230, 230, 242)
local GRY = Color3.fromRGB(100, 100, 120)
local GRN = Color3.fromRGB(50, 210, 110)
local RED = Color3.fromRGB(220, 55, 75)
local YLW = Color3.fromRGB(255, 200, 50)

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end
local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or ACC
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end
local function grad(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 90
    g.Parent = p
    return g
end
local function pad(p, l, r, t, b)
    local pk = Instance.new("UIPadding")
    pk.PaddingLeft = UDim.new(0, l or 0)
    pk.PaddingRight = UDim.new(0, r or 0)
    pk.PaddingTop = UDim.new(0, t or 0)
    pk.PaddingBottom = UDim.new(0, b or 0)
    pk.Parent = p
    return pk
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "BomDevHub_v3"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
safe(function() GUI.Parent = CoreGui end)
if not GUI.Parent then GUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local notifStack = {}
local function notify(title, msg, dur)
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(0, 300, 0, 72)
    nf.BackgroundColor3 = BG2
    nf.BorderSizePixel = 0
    nf.ZIndex = 200
    nf.Parent = GUI
    corner(nf, 10)
    stroke(nf, ACC, 1.2)
    grad(nf, Color3.fromRGB(16, 12, 30), BG2, 130)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -12)
    accentBar.Position = UDim2.new(0, 6, 0, 6)
    accentBar.BackgroundColor3 = ACC
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 201
    accentBar.Parent = nf
    corner(accentBar, 2)
    grad(accentBar, ACC, ACC2, 90)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -28, 0, 26)
    tl.Position = UDim2.new(0, 18, 0, 8)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextSize = 13
    tl.Font = Enum.Font.GothamBold
    tl.TextColor3 = WHT
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 201
    tl.Parent = nf

    local ml = Instance.new("TextLabel")
    ml.Size = UDim2.new(1, -28, 0, 26)
    ml.Position = UDim2.new(0, 18, 0, 36)
    ml.BackgroundTransparency = 1
    ml.Text = msg or ""
    ml.TextSize = 11
    ml.Font = Enum.Font.Gotham
    ml.TextColor3 = GRY
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.ZIndex = 201
    ml.Parent = nf

    table.insert(notifStack, nf)
    local idx = #notifStack

    local function reflow()
        for i, f in ipairs(notifStack) do
            local targetY = -(i * 82)
            TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, -310, 1, targetY)
            }):Play()
        end
    end

    nf.Position = UDim2.new(1, 10, 1, -(idx * 82))
    TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -310, 1, -(idx * 82))
    }):Play()

    task.delay(dur or 3, function()
        TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 10, 1, -(idx * 82))
        }):Play()
        task.wait(0.3)
        for i, f in ipairs(notifStack) do
            if f == nf then table.remove(notifStack, i) break end
        end
        nf:Destroy()
        reflow()
    end)
end

local MF = Instance.new("Frame")
MF.Name = "MainFrame"
MF.Size = UDim2.new(0, 720, 0, 500)
MF.Position = UDim2.new(0.5, -360, 0.5, -250)
MF.BackgroundColor3 = BG
MF.BorderSizePixel = 0
MF.Active = true
MF.Draggable = true
MF.ZIndex = 10
MF.Parent = GUI
corner(MF, 14)
grad(MF, Color3.fromRGB(10, 8, 20), Color3.fromRGB(6, 5, 12), 145)

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = ACC
mfStroke.Thickness = 1.5
mfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mfStroke.Parent = MF

RunService.Heartbeat:Connect(function()
    local t = tick() * 0.4
    mfStroke.Color = Color3.fromHSV(
        (t % 1),
        0.8,
        0.9
    )
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = BG2
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 11
TopBar.Parent = MF
corner(TopBar, 14)
grad(TopBar, Color3.fromRGB(18, 12, 36), BG2, 90)

local TBFix = Instance.new("Frame")
TBFix.Size = UDim2.new(1, 0, 0.5, 0)
TBFix.Position = UDim2.new(0, 0, 0.5, 0)
TBFix.BackgroundColor3 = BG2
TBFix.BorderSizePixel = 0
TBFix.ZIndex = 11
TBFix.Parent = TopBar

local AccLine = Instance.new("Frame")
AccLine.Size = UDim2.new(1, 0, 0, 2)
AccLine.Position = UDim2.new(0, 0, 1, -2)
AccLine.BackgroundColor3 = ACC
AccLine.BorderSizePixel = 0
AccLine.ZIndex = 12
AccLine.Parent = TopBar
local acLineG = Instance.new("UIGradient")
acLineG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACC3),
    ColorSequenceKeypoint.new(0.3, ACC),
    ColorSequenceKeypoint.new(0.7, ACC2),
    ColorSequenceKeypoint.new(1, ACC3),
})
acLineG.Parent = AccLine

RunService.Heartbeat:Connect(function()
    local t = (tick() * 0.3) % 1
    acLineG.Offset = Vector2.new(t * 2 - 1, 0)
end)

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 36, 0, 36)
LogoBox.Position = UDim2.new(0, 12, 0.5, -18)
LogoBox.BackgroundColor3 = ACC
LogoBox.BorderSizePixel = 0
LogoBox.ZIndex = 12
LogoBox.Parent = TopBar
corner(LogoBox, 10)
grad(LogoBox, ACC3, ACC2, 135)

local LogoTxt = Instance.new("TextLabel")
LogoTxt.Size = UDim2.new(1, 0, 1, 0)
LogoTxt.BackgroundTransparency = 1
LogoTxt.Text = "⚡"
LogoTxt.TextSize = 18
LogoTxt.Font = Enum.Font.GothamBold
LogoTxt.TextColor3 = WHT
LogoTxt.ZIndex = 13
LogoTxt.Parent = LogoBox

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 220, 0, 24)
TitleLbl.Position = UDim2.new(0, 56, 0, 6)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "BomDev Hub"
TitleLbl.TextSize = 17
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextColor3 = WHT
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 12
TitleLbl.Parent = TopBar
grad(TitleLbl, WHT, ACC2, 0)

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(0, 220, 0, 14)
SubLbl.Position = UDim2.new(0, 56, 0, 30)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Dev: BomDev  ·  v3.0  ·  ] ซ่อน/แสดง"
SubLbl.TextSize = 10
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextColor3 = GRY
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 12
SubLbl.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -14)
CloseBtn.BackgroundColor3 = RED
CloseBtn.Text = "✕"
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = WHT
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.Parent = TopBar
corner(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255,70,90)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = RED}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -78, 0.5, -14)
MinBtn.BackgroundColor3 = BG4
MinBtn.Text = "─"
MinBtn.TextSize = 11
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = GRY
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 12
MinBtn.Parent = TopBar
corner(MinBtn, 8)
stroke(MinBtn, Color3.fromRGB(45, 45, 65), 1)

local DiscBtn = Instance.new("TextButton")
DiscBtn.Size = UDim2.new(0, 28, 0, 28)
DiscBtn.Position = UDim2.new(1, -114, 0.5, -14)
DiscBtn.BackgroundColor3 = Color3.fromRGB(80, 95, 230)
DiscBtn.Text = "D"
DiscBtn.TextSize = 12
DiscBtn.Font = Enum.Font.GothamBold
DiscBtn.TextColor3 = WHT
DiscBtn.BorderSizePixel = 0
DiscBtn.ZIndex = 12
DiscBtn.Parent = TopBar
corner(DiscBtn, 8)
DiscBtn.MouseButton1Click:Connect(function()
    safe(function() setclipboard(DISCORD_LINK) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK) end)
    notify("Discord", "Copied & Opened: discord.gg/4Vn8WwyV3u", 3)
end)

local minimized = false
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, 0, 1, -54)
ContentArea.Position = UDim2.new(0, 0, 0, 54)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 10
ContentArea.Parent = MF

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentArea.Visible = not minimized
    TweenService:Create(MF, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
        Size = minimized and UDim2.new(0, 720, 0, 54) or UDim2.new(0, 720, 0, 500)
    }):Play()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 158, 1, 0)
Sidebar.BackgroundColor3 = BG2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = ContentArea
grad(Sidebar, BG2, Color3.fromRGB(10, 10, 18), 180)

local SBRight = Instance.new("Frame")
SBRight.Size = UDim2.new(0, 1, 1, 0)
SBRight.Position = UDim2.new(1, -1, 0, 0)
SBRight.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
SBRight.BorderSizePixel = 0
SBRight.ZIndex = 12
SBRight.Parent = Sidebar

local PlayerInfoBox = Instance.new("Frame")
PlayerInfoBox.Size = UDim2.new(1, 0, 0, 62)
PlayerInfoBox.BackgroundColor3 = BG3
PlayerInfoBox.BorderSizePixel = 0
PlayerInfoBox.ZIndex = 12
PlayerInfoBox.Parent = Sidebar
grad(PlayerInfoBox, Color3.fromRGB(18, 12, 32), BG3, 135)

local PlayerIcon = Instance.new("Frame")
PlayerIcon.Size = UDim2.new(0, 30, 0, 30)
PlayerIcon.Position = UDim2.new(0, 8, 0.5, -15)
PlayerIcon.BackgroundColor3 = ACC
PlayerIcon.BorderSizePixel = 0
PlayerIcon.ZIndex = 13
PlayerIcon.Parent = PlayerInfoBox
corner(PlayerIcon, 15)
grad(PlayerIcon, ACC3, ACC2, 135)

local PlayerIconTxt = Instance.new("TextLabel")
PlayerIconTxt.Size = UDim2.new(1, 0, 1, 0)
PlayerIconTxt.BackgroundTransparency = 1
PlayerIconTxt.Text = string.sub(LocalPlayer.Name, 1, 1):upper()
PlayerIconTxt.TextSize = 14
PlayerIconTxt.Font = Enum.Font.GothamBold
PlayerIconTxt.TextColor3 = WHT
PlayerIconTxt.ZIndex = 14
PlayerIconTxt.Parent = PlayerIcon

local PlayerNameLbl = Instance.new("TextLabel")
PlayerNameLbl.Size = UDim2.new(1, -48, 0, 18)
PlayerNameLbl.Position = UDim2.new(0, 44, 0, 12)
PlayerNameLbl.BackgroundTransparency = 1
PlayerNameLbl.Text = LocalPlayer.Name
PlayerNameLbl.TextSize = 11
PlayerNameLbl.Font = Enum.Font.GothamBold
PlayerNameLbl.TextColor3 = WHT
PlayerNameLbl.TextXAlignment = Enum.TextXAlignment.Left
PlayerNameLbl.ZIndex = 13
PlayerNameLbl.Parent = PlayerInfoBox

local PlayerSubLbl = Instance.new("TextLabel")
PlayerSubLbl.Size = UDim2.new(1, -48, 0, 14)
PlayerSubLbl.Position = UDim2.new(0, 44, 0, 32)
PlayerSubLbl.BackgroundTransparency = 1
PlayerSubLbl.Text = "ID: " .. LocalPlayer.UserId
PlayerSubLbl.TextSize = 9
PlayerSubLbl.Font = Enum.Font.Gotham
PlayerSubLbl.TextColor3 = GRY
PlayerSubLbl.TextXAlignment = Enum.TextXAlignment.Left
PlayerSubLbl.ZIndex = 13
PlayerSubLbl.Parent = PlayerInfoBox

local PIBorder = Instance.new("Frame")
PIBorder.Size = UDim2.new(1, 0, 0, 1)
PIBorder.Position = UDim2.new(0, 0, 1, -1)
PIBorder.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
PIBorder.BorderSizePixel = 0
PIBorder.ZIndex = 13
PIBorder.Parent = PlayerInfoBox

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, 0, 1, -100)
NavList.Position = UDim2.new(0, 0, 0, 62)
NavList.BackgroundTransparency = 1
NavList.ScrollBarThickness = 2
NavList.ScrollBarImageColor3 = ACC
NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
NavList.ZIndex = 12
NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 3)
NavLayout.Parent = NavList
pad(NavList, 6, 6, 8, 0)
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavList.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 16)
end)

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(1, 0, 0, 34)
VerLbl.Position = UDim2.new(0, 0, 1, -38)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "BomDev Hub  v3.0"
VerLbl.TextSize = 9
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextColor3 = Color3.fromRGB(50, 50, 70)
VerLbl.ZIndex = 12
VerLbl.Parent = Sidebar

local PageArea = Instance.new("Frame")
PageArea.Size = UDim2.new(1, -165, 1, -8)
PageArea.Position = UDim2.new(0, 162, 0, 4)
PageArea.BackgroundTransparency = 1
PageArea.ZIndex = 11
PageArea.Parent = ContentArea

local pages = {}
local navBtns = {}
local currentPage = nil

local NAV_ICONS = {
    ["Movement"] = "🏃",
    ["Combat"] = "⚔️",
    ["Visual"] = "👁️",
    ["Player"] = "👤",
    ["Teleport"] = "🔀",
    ["Utilities"] = "🔧",
    ["Download"] = "📥",
    ["Settings"] = "⚙️",
}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACC
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 11
    page.Parent = PageArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = page
    pad(page, 2, 6, 4, 8)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    pages[name] = page

    local navBtn = Instance.new("Frame")
    navBtn.Size = UDim2.new(1, 0, 0, 38)
    navBtn.BackgroundColor3 = BG3
    navBtn.BackgroundTransparency = 1
    navBtn.BorderSizePixel = 0
    navBtn.ZIndex = 12
    navBtn.Parent = NavList
    corner(navBtn, 8)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.55, 0)
    indicator.Position = UDim2.new(0, 0, 0.22, 0)
    indicator.BackgroundColor3 = ACC
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 14
    indicator.Parent = navBtn
    corner(indicator, 2)
    grad(indicator, ACC, ACC2, 90)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 22, 1, 0)
    iconLbl.Position = UDim2.new(0, 10, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = NAV_ICONS[name] or "◆"
    iconLbl.TextSize = 14
    iconLbl.Font = Enum.Font.GothamMedium
    iconLbl.TextColor3 = GRY
    iconLbl.ZIndex = 13
    iconLbl.Parent = navBtn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -38, 1, 0)
    nameLbl.Position = UDim2.new(0, 36, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextColor3 = GRY
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 13
    nameLbl.Parent = navBtn

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 14
    clickBtn.Parent = navBtn

    navBtns[name] = {frame = navBtn, ind = indicator, icon = iconLbl, lbl = nameLbl}

    local function setActive(v)
        if v then
            TweenService:Create(navBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(nameLbl, TweenInfo.new(0.2), {TextColor3 = WHT}):Play()
            TweenService:Create(iconLbl, TweenInfo.new(0.2), {TextColor3 = ACC2}):Play()
        else
            TweenService:Create(navBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(nameLbl, TweenInfo.new(0.2), {TextColor3 = GRY}):Play()
            TweenService:Create(iconLbl, TweenInfo.new(0.2), {TextColor3 = GRY}):Play()
        end
    end

    clickBtn.MouseButton1Click:Connect(function()
        if currentPage then
            pages[currentPage].Visible = false
            local old = navBtns[currentPage]
            if old then setActive(false) end
        end
        currentPage = name
        page.Visible = true
        setActive(true)
    end)

    clickBtn.MouseEnter:Connect(function()
        if currentPage ~= name then
            TweenService:Create(navBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
            TweenService:Create(nameLbl, TweenInfo.new(0.15), {TextColor3 = WHT}):Play()
        end
    end)
    clickBtn.MouseLeave:Connect(function()
        if currentPage ~= name then
            TweenService:Create(navBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            TweenService:Create(nameLbl, TweenInfo.new(0.15), {TextColor3 = GRY}):Play()
        end
    end)

    return page
end

local function addSectionLabel(page, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = BG3
    f.BorderSizePixel = 0
    f.ZIndex = 12
    f.Parent = page
    corner(f, 6)
    grad(f, Color3.fromRGB(20, 15, 36), BG3, 135)

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0.6, 0)
    line.Position = UDim2.new(0, 8, 0.2, 0)
    line.BackgroundColor3 = ACC
    line.BorderSizePixel = 0
    line.ZIndex = 13
    line.Parent = f
    corner(line, 2)
    grad(line, ACC, ACC2, 90)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = ACC2
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = f

    return f
end

local function addSpacer(page)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
    s.BorderSizePixel = 0
    s.ZIndex = 12
    s.Parent = page
    return s
end

local function addToggle(page, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = BG3
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.Parent = page
    corner(row, 8)
    grad(row, BG3, Color3.fromRGB(15, 15, 24), 110)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -64, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 23)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
    track.BorderSizePixel = 0
    track.ZIndex = 13
    track.Parent = row
    corner(track, 12)
    stroke(track, Color3.fromRGB(40, 40, 60), 1)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 17, 0, 17)
    thumb.Position = UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = GRY
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 14
    thumb.Parent = track
    corner(thumb, 9)

    local state = default or false
    local function updateVis()
        if state then
            TweenService:Create(thumb, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, -20, 0.5, -8),
                BackgroundColor3 = ACC2
            }):Play()
            TweenService:Create(track, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(25, 45, 75)
            }):Play()
        else
            TweenService:Create(thumb, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = GRY
            }):Play()
            TweenService:Create(track, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 52)
            }):Play()
        end
    end
    updateVis()

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 15
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVis()
        if callback then callback(state) end
    end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 34)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = BG3}):Play()
    end)

    return {
        setState = function(v) state = v updateVis() end,
        getState = function() return state end
    }
end

local function addButton(page, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BG4
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = WHT
    btn.ZIndex = 12
    btn.Parent = page
    corner(btn, 8)
    stroke(btn, Color3.fromRGB(38, 38, 58), 1)
    grad(btn, BG4, Color3.fromRGB(16, 16, 26), 110)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 28, 48)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BG4}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(38, 28, 70)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(30, 28, 48)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function addAccentButton(page, labelText, callback, col1, col2)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = col1 or ACC
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = WHT
    btn.ZIndex = 12
    btn.Parent = page
    corner(btn, 8)
    grad(btn, col1 or ACC, col2 or ACC2, 90)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(120, 80, 255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = col1 or ACC}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function addSlider(page, labelText, min, max, default, suffix, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundColor3 = BG3
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = page
    corner(container, 8)
    grad(container, BG3, Color3.fromRGB(15, 15, 24), 110)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 0, 26)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.35, -14, 0, 26)
    valLbl.Position = UDim2.new(0.65, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. (suffix or "")
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextColor3 = ACC2
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 13
    valLbl.Parent = container

    local sbg = Instance.new("Frame")
    sbg.Size = UDim2.new(1, -24, 0, 5)
    sbg.Position = UDim2.new(0, 12, 0, 40)
    sbg.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    sbg.BorderSizePixel = 0
    sbg.ZIndex = 13
    sbg.Parent = container
    corner(sbg, 3)

    local sfill = Instance.new("Frame")
    sfill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sfill.BackgroundColor3 = ACC
    sfill.BorderSizePixel = 0
    sfill.ZIndex = 14
    sfill.Parent = sbg
    corner(sfill, 3)
    grad(sfill, ACC, ACC2, 0)

    local sthumb = Instance.new("Frame")
    sthumb.Size = UDim2.new(0, 14, 0, 14)
    sthumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    sthumb.BackgroundColor3 = WHT
    sthumb.BorderSizePixel = 0
    sthumb.ZIndex = 15
    sthumb.Parent = sbg
    corner(sthumb, 7)
    stroke(sthumb, ACC, 1.5)

    local currentVal = default
    local dragging = false

    local function updateSlider(v)
        v = math.clamp(v, min, max)
        local rounded = math.floor(v + 0.5)
        currentVal = rounded
        local ratio = (rounded - min) / (max - min)
        sfill.Size = UDim2.new(ratio, 0, 1, 0)
        sthumb.Position = UDim2.new(ratio, -7, 0.5, -7)
        valLbl.Text = tostring(rounded) .. (suffix or "")
        if callback then callback(rounded) end
    end

    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1, 20, 1, 20)
    sBtn.Position = UDim2.new(0, -10, 0, -10)
    sBtn.BackgroundTransparency = 1
    sBtn.Text = ""
    sBtn.ZIndex = 16
    sBtn.Parent = sbg

    sBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = sbg.AbsolutePosition.X
            local sz = sbg.AbsoluteSize.X
            local ratio = math.clamp((inp.Position.X - pos) / sz, 0, 1)
            updateSlider(min + ratio * (max - min))
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    sBtn.TouchMoved:Connect(function(touch)
        local pos = sbg.AbsolutePosition.X
        local sz = sbg.AbsoluteSize.X
        local ratio = math.clamp((touch.Position.X - pos) / sz, 0, 1)
        updateSlider(min + ratio * (max - min))
    end)

    return {getValue = function() return currentVal end}
end

local function addInput(page, labelText, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundColor3 = BG3
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = page
    corner(container, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = GRY
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = container

    local ibox = Instance.new("TextBox")
    ibox.Size = UDim2.new(1, -28, 0, 24)
    ibox.Position = UDim2.new(0, 14, 0, 28)
    ibox.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    ibox.BorderSizePixel = 0
    ibox.Text = ""
    ibox.PlaceholderText = placeholder or ""
    ibox.PlaceholderColor3 = Color3.fromRGB(70, 70, 90)
    ibox.TextSize = 11
    ibox.Font = Enum.Font.Gotham
    ibox.TextColor3 = WHT
    ibox.ClearTextOnFocus = false
    ibox.ZIndex = 13
    ibox.Parent = container
    corner(ibox, 5)
    stroke(ibox, Color3.fromRGB(40, 40, 60), 1)
    pad(ibox, 8, 0, 0, 0)

    ibox.FocusLost:Connect(function(enter)
        if enter and callback then callback(ibox.Text) end
    end)
    return ibox
end

local function addDropdown(page, labelText, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = BG3
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 12
    container.Parent = page
    corner(container, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = container

    local selLbl = Instance.new("TextLabel")
    selLbl.Size = UDim2.new(0.46, -8, 0.75, 0)
    selLbl.Position = UDim2.new(0.52, 0, 0.12, 0)
    selLbl.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    selLbl.BorderSizePixel = 0
    selLbl.Text = (options[1] or "select") .. " ▾"
    selLbl.TextSize = 10
    selLbl.Font = Enum.Font.Gotham
    selLbl.TextColor3 = GRY
    selLbl.ZIndex = 13
    selLbl.Parent = container
    corner(selLbl, 5)
    stroke(selLbl, Color3.fromRGB(40, 40, 60), 1)
    pad(selLbl, 8, 0, 0, 0)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(0.46, -8, 0, 0)
    dropFrame.Position = UDim2.new(0.52, 0, 1, 3)
    dropFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    dropFrame.BorderSizePixel = 0
    dropFrame.ClipsDescendants = true
    dropFrame.ZIndex = 30
    dropFrame.Parent = container
    corner(dropFrame, 6)
    stroke(dropFrame, ACC, 1)

    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Parent = dropFrame

    local dropOpen = false

    local function populate(opts)
        for _, ch in ipairs(dropFrame:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _, opt in ipairs(opts) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 26)
            ob.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            ob.BackgroundTransparency = 0
            ob.Text = opt
            ob.TextSize = 10
            ob.Font = Enum.Font.Gotham
            ob.TextColor3 = WHT
            ob.BorderSizePixel = 0
            ob.ZIndex = 31
            ob.Parent = dropFrame
            pad(ob, 8, 0, 0, 0)
            ob.TextXAlignment = Enum.TextXAlignment.Left

            ob.MouseEnter:Connect(function()
                TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32, 28, 52)}):Play()
            end)
            ob.MouseLeave:Connect(function()
                TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 30)}):Play()
            end)
            ob.MouseButton1Click:Connect(function()
                selLbl.Text = opt .. " ▾"
                if callback then callback(opt) end
                dropOpen = false
                TweenService:Create(dropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Size = UDim2.new(0.46, -8, 0, 0)}):Play()
            end)
        end
    end

    populate(options)
    dropFrame.Size = UDim2.new(0.46, -8, 0, 0)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.46, -8, 0.75, 0)
    toggleBtn.Position = UDim2.new(0.52, 0, 0.12, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 15
    toggleBtn.Parent = container

    toggleBtn.MouseButton1Click:Connect(function()
        dropOpen = not dropOpen
        local count = 0
        for _, ch in ipairs(dropFrame:GetChildren()) do
            if ch:IsA("TextButton") then count = count + 1 end
        end
        TweenService:Create(dropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            Size = dropOpen and UDim2.new(0.46, -8, 0, count * 26) or UDim2.new(0.46, -8, 0, 0)
        }):Play()
    end)

    return {
        Set = function(newOpts)
            populate(newOpts)
            dropFrame.Size = UDim2.new(0.46, -8, 0, 0)
            dropOpen = false
            selLbl.Text = (newOpts[1] or "select") .. " ▾"
        end
    }
end

local pageMovement = createPage("Movement")
local pageCombat = createPage("Combat")
local pageVisual = createPage("Visual")
local pagePlayer = createPage("Player")
local pageTeleport = createPage("Teleport")
local pageUtils = createPage("Utilities")
local pageDownload = createPage("Download")
local pageSettings = createPage("Settings")

do
    addSectionLabel(pageMovement, "✈  FLIGHT")

    addToggle(pageMovement, "Fly Mode", false, function(v)
        flyEnabled = v

        for _, c in pairs(flyConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        flyConns = {}
        if flyBV and flyBV.Parent then flyBV:Destroy() end
        if flyBG and flyBG.Parent then flyBG:Destroy() end
        flyBV = nil
        flyBG = nil

        if not flyEnabled then
            local hum = getHum()
            if hum then hum.PlatformStand = false end
            notify("Fly", "ปิดแล้ว", 2)
            return
        end

        local char = getChar()
        if not char then flyEnabled = false return end
        local hrp = getHRP()
        if not hrp then flyEnabled = false return end
        local hum = getHum()
        if not hum then flyEnabled = false return end

        hum.PlatformStand = true

        local bv = Instance.new("BodyVelocity")
        bv.Name = "BomDevFlyBV"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        flyBV = bv

        local bg = Instance.new("BodyGyro")
        bg.Name = "BomDevFlyBG"
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 6000
        bg.D = 600
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        flyBG = bg

        notify("Fly", "เปิดแล้ว — WASD ตามกล้อง", 2)

        local conn = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            if not hrp or not hrp.Parent then return end

            local camCF = Camera.CFrame
            local camLook = camCF.LookVector
            local camRight = camCF.RightVector
            local camUp = camCF.UpVector

            local vel = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + camLook * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - camLook * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + camRight * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - camRight * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, flySpeed * 0.7, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
               UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel - Vector3.new(0, flySpeed * 0.7, 0)
            end

            if vel.Magnitude < 0.01 then
                flyBV.Velocity = Vector3.zero
            else
                flyBV.Velocity = vel
            end

            local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
            if flatLook.Magnitude > 0.01 then
                flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook.Unit)
            end
        end)

        table.insert(flyConns, conn)
    end)

    addSlider(pageMovement, "Fly Speed", 10, 500, 60, "", function(v) flySpeed = v end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "🏃  SPEED & JUMP")

    addToggle(pageMovement, "Super Speed", false, function(v)
        speedEnabled = v
        local hum = getHum()
        if hum then hum.WalkSpeed = v and speedValue or 16 end
        notify("Speed", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSlider(pageMovement, "Walk Speed", 16, 500, 60, "", function(v)
        speedValue = v
        if speedEnabled then
            local hum = getHum()
            if hum then hum.WalkSpeed = v end
        end
    end)

    addToggle(pageMovement, "High Jump", false, function(v)
        jumpEnabled = v
        local hum = getHum()
        if hum then hum.JumpPower = v and jumpValue or 50 end
        notify("Jump", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSlider(pageMovement, "Jump Power", 50, 1000, 100, "", function(v)
        jumpValue = v
        if jumpEnabled then
            local hum = getHum()
            if hum then hum.JumpPower = v end
        end
    end)

    addToggle(pageMovement, "Infinite Jump", false, function(v)
        infiniteJumpEnabled = v
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
        if v then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = getHum()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("Infinite Jump", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageMovement, "BunnyHop", false, function(v)
        bunnyHopEnabled = v
        if bhopConn then bhopConn:Disconnect() bhopConn = nil end
        if v then
            bhopConn = RunService.Heartbeat:Connect(function()
                local hum = getHum()
                if not hum then return end
                if hum:GetState() == Enum.HumanoidStateType.Landed then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        notify("BunnyHop", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "⚙  PHYSICS")

    addToggle(pageMovement, "NoClip", false, function(v)
        noclipEnabled = v
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if v then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = getChar()
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        notify("NoClip", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageMovement, "No Friction", false, function(v)
        noFrictionEnabled = v
        if noFrictionConn then noFrictionConn:Disconnect() noFrictionConn = nil end
        if v then
            noFrictionConn = RunService.Heartbeat:Connect(function()
                if not noFrictionEnabled then return end
                local char = getChar()
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CustomPhysicalProperties = PhysicalProperties.new(0.3, 0, 0, 0, 0)
                        end
                    end
                end
            end)
        else
            local char = getChar()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CustomPhysicalProperties = PhysicalProperties.new(0.3, 0.3, 0.5, 0.1, 1)
                    end
                end
            end
        end
        notify("No Friction", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageMovement, "No Fall Damage", false, function(v)
        noFallEnabled = v
        local hum = getHum()
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageMovement, "Walk on Water", false, function(v)
        walkWaterEnabled = v
        if waterConn then waterConn:Disconnect() waterConn = nil end
        if waterPart then waterPart:Destroy() waterPart = nil end
        if v then
            local hrp = getHRP()
            if not hrp then return end
            waterPart = Instance.new("Part")
            waterPart.Name = "BomDevWater"
            waterPart.Size = Vector3.new(1000, 1, 1000)
            waterPart.Anchored = true
            waterPart.CanCollide = true
            waterPart.Transparency = 1
            waterPart.Position = Vector3.new(hrp.Position.X, workspace.Terrain.WaterLevel, hrp.Position.Z)
            waterPart.Parent = workspace
            waterConn = RunService.Heartbeat:Connect(function()
                local h = getHRP()
                if h and waterPart and waterPart.Parent then
                    waterPart.Position = Vector3.new(h.Position.X, workspace.Terrain.WaterLevel, h.Position.Z)
                end
            end)
        end
        notify("Walk on Water", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "⚡  ACTIONS")

    addButton(pageMovement, "⚡ Speed Burst (3s)", function()
        local hum = getHum()
        if not hum then return end
        local orig = hum.WalkSpeed
        hum.WalkSpeed = 500
        notify("Speed Burst", "3 วินาที!", 2)
        task.delay(3, function()
            if hum and hum.Parent then hum.WalkSpeed = orig end
        end)
    end)

    addButton(pageMovement, "💨 Dash Forward 30 studs", function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 30
        end
    end)

    addButton(pageMovement, "🚀 Super Jump", function()
        local hrp = getHRP()
        if hrp then hrp.Velocity = Vector3.new(0, 200, 0) end
    end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "🌍  GRAVITY")

    addSlider(pageMovement, "Gravity", 0, 300, 196, "", function(v)
        workspace.Gravity = v
    end)

    addButton(pageMovement, "Low Gravity (40)", function()
        workspace.Gravity = 40
        notify("Gravity", "Low", 2)
    end)

    addButton(pageMovement, "Normal Gravity (196)", function()
        workspace.Gravity = 196
        notify("Gravity", "Normal", 2)
    end)
end

do
    addSectionLabel(pageCombat, "🎯  AIMBOT")

    addToggle(pageCombat, "Aimbot", false, function(v)
        aimbotEnabled = v
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
        if v then
            aimbotConn = RunService.RenderStepped:Connect(function()
                if not aimbotEnabled then return end
                local closest, closestD = nil, math.huge
                local myHRP = getHRP()
                if not myHRP then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    if inWL(p) then continue end
                    local char = p.Character
                    if not char then continue end
                    local target = char:FindFirstChild("Head")
                    if not target then continue end
                    local screenPos, onScreen = Camera:WorldToScreenPoint(target.Position)
                    if not onScreen then continue end
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    local worldDist = (Camera.CFrame.Position - target.Position).Magnitude
                    if worldDist < aimbotRange and screenDist < closestD then
                        closestD = screenDist
                        closest = target
                    end
                end
                if closest then
                    local targetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimbotSmooth)
                end
            end)
        end
        notify("Aimbot", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSlider(pageCombat, "Aimbot Range", 50, 1000, 200, " studs", function(v) aimbotRange = v end)
    addSlider(pageCombat, "Aimbot Smoothing", 1, 100, 15, "%", function(v) aimbotSmooth = v / 100 end)

    addSpacer(pageCombat)
    addSectionLabel(pageCombat, "🛡  WHITELIST")

    local wlDD = addDropdown(pageCombat, "Add to Whitelist", getPlayerList(), function(name)
        for _, n in ipairs(aimbotWL) do
            if n == name then notify("Whitelist", name .. " มีอยู่แล้ว", 2) return end
        end
        table.insert(aimbotWL, name)
        notify("Whitelist", "เพิ่ม " .. name, 2)
    end)

    addButton(pageCombat, "Refresh Player List", function()
        wlDD.Set(getPlayerList())
        notify("Players", "รีเฟรชแล้ว", 2)
    end)

    local removeDD = addDropdown(pageCombat, "Remove from Whitelist", {"(empty)"}, function(name)
        if name == "(empty)" then return end
        for i, n in ipairs(aimbotWL) do
            if n == name then
                table.remove(aimbotWL, i)
                notify("Whitelist", "ลบ " .. name, 2)
                removeDD.Set(#aimbotWL > 0 and aimbotWL or {"(empty)"})
                return
            end
        end
    end)

    addButton(pageCombat, "Update Remove List", function()
        removeDD.Set(#aimbotWL > 0 and aimbotWL or {"(empty)"})
        notify("Whitelist", #aimbotWL .. " คน", 2)
    end)

    addButton(pageCombat, "Clear All Whitelist", function()
        aimbotWL = {}
        removeDD.Set({"(empty)"})
        notify("Whitelist", "ล้างแล้ว", 2)
    end)

    addSpacer(pageCombat)
    addSectionLabel(pageCombat, "💥  HITBOX & REACH")

    addToggle(pageCombat, "Hitbox Expander", false, function(v)
        hitboxEnabled = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = v and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or Vector3.new(2,2,1) end
        end
        notify("Hitbox", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSlider(pageCombat, "Hitbox Size", 1, 50, 10, "", function(v)
        hitboxSize = v
        if hitboxEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local char = p.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(v, v, v) end
            end
        end
    end)

    addToggle(pageCombat, "Kill Aura", false, function(v)
        killAuraEnabled = v
        if killAuraConn then killAuraConn:Disconnect() killAuraConn = nil end
        if v then
            killAuraConn = RunService.Heartbeat:Connect(function()
                if not killAuraEnabled then return end
                local myHRP = getHRP()
                if not myHRP then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    local char = p.Character
                    if not char then continue end
                    local theirHRP = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if theirHRP and hum then
                        if (myHRP.Position - theirHRP.Position).Magnitude <= killAuraRange then
                            hum.Health = 0
                        end
                    end
                end
            end)
        end
        notify("Kill Aura", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSlider(pageCombat, "Kill Aura Range", 5, 100, 15, " studs", function(v) killAuraRange = v end)
end

do
    addSectionLabel(pageVisual, "👁  ESP")

    addToggle(pageVisual, "ESP", false, function(v)
        espEnabled = v
        for _, c in pairs(espConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        espConns = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            if char then
                local ex = char:FindFirstChild("BomDevESP")
                if ex then ex:Destroy() end
            end
        end
        if not v then notify("ESP", "ปิดแล้ว", 2) return end

        local function addESP(player)
            local char = player.Character
            if not char then return end
            if char:FindFirstChild("BomDevESP") then return end
            local hl = Instance.new("Highlight")
            hl.Name = "BomDevESP"
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.Parent = char

            local uc = RunService.Heartbeat:Connect(function()
                if not espEnabled then return end
                local myHRP = getHRP()
                local theirHRP = char:FindFirstChild("HumanoidRootPart")
                if not (myHRP and theirHRP) then return end
                local dist = (myHRP.Position - theirHRP.Position).Magnitude
                local ratio = math.clamp(dist / 200, 0, 1)
                hl.FillColor = Color3.fromRGB(
                    math.floor(50 + 200 * ratio),
                    math.floor(210 * (1 - ratio)),
                    50
                )
                hl.OutlineColor = Color3.fromRGB(
                    math.floor(50 + 200 * ratio),
                    math.floor(210 * (1 - ratio)),
                    50
                )
            end)
            table.insert(espConns, uc)
        end

        for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
        local conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(1)
                if espEnabled then addESP(p) end
            end)
        end)
        table.insert(espConns, conn)
        notify("ESP", "เปิดแล้ว", 2)
    end)

    addToggle(pageVisual, "Player Name Tracker", false, function(v)
        trackerEnabled = v
        for _, c in pairs(trackerConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        trackerConns = {}
        if trackerGui then trackerGui:Destroy() trackerGui = nil end
        if not v then notify("Tracker", "ปิดแล้ว", 2) return end

        trackerGui = Instance.new("ScreenGui")
        trackerGui.Name = "BomDevTracker"
        trackerGui.ResetOnSpawn = false
        trackerGui.IgnoreGuiInset = true
        safe(function() trackerGui.Parent = CoreGui end)
        if not trackerGui.Parent then trackerGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local labels = {}
        local uc = RunService.RenderStepped:Connect(function()
            if not trackerEnabled then return end
            for _, lb in pairs(labels) do lb:Destroy() end
            labels = {}
            local myHRP = getHRP()
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local char = p.Character
                if not char then continue end
                local head = char:FindFirstChild("Head")
                if not head then continue end
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if not onScreen then continue end
                local dist = myHRP and math.floor((myHRP.Position - head.Position).Magnitude) or 0
                local lb = Instance.new("TextLabel")
                lb.Size = UDim2.new(0, 120, 0, 22)
                lb.Position = UDim2.new(0, screenPos.X - 60, 0, screenPos.Y - 30)
                lb.BackgroundColor3 = Color3.fromRGB(0,0,0)
                lb.BackgroundTransparency = 0.4
                lb.TextColor3 = YLW
                lb.Font = Enum.Font.GothamBold
                lb.TextScaled = true
                lb.Text = p.Name .. " [" .. dist .. "m]"
                lb.ZIndex = 15
                lb.Parent = trackerGui
                corner(lb, 4)
                table.insert(labels, lb)
            end
        end)
        table.insert(trackerConns, uc)
        notify("Tracker", "เปิดแล้ว", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "✚  CROSSHAIR")

    addToggle(pageVisual, "Custom Crosshair", false, function(v)
        if crosshairGui then crosshairGui:Destroy() crosshairGui = nil end
        if not v then notify("Crosshair", "ปิดแล้ว", 2) return end

        crosshairGui = Instance.new("ScreenGui")
        crosshairGui.Name = "BomDevCH"
        crosshairGui.IgnoreGuiInset = true
        crosshairGui.ResetOnSpawn = false
        safe(function() crosshairGui.Parent = CoreGui end)
        if not crosshairGui.Parent then crosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local lines = {
            {UDim2.new(0, 16, 0, 2), UDim2.new(0.5, 7, 0.5, -1)},
            {UDim2.new(0, 16, 0, 2), UDim2.new(0.5, -23, 0.5, -1)},
            {UDim2.new(0, 2, 0, 16), UDim2.new(0.5, -1, 0.5, 7)},
            {UDim2.new(0, 2, 0, 16), UDim2.new(0.5, -1, 0.5, -23)},
        }
        for _, ld in ipairs(lines) do
            local f = Instance.new("Frame")
            f.Size = ld[1]
            f.Position = ld[2]
            f.BackgroundColor3 = ACC2
            f.BorderSizePixel = 0
            f.Parent = crosshairGui
        end
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -2, 0.5, -2)
        dot.BackgroundColor3 = WHT
        dot.BorderSizePixel = 0
        dot.Parent = crosshairGui
        corner(dot, 2)
        notify("Crosshair", "เปิดแล้ว", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "💡  LIGHTING")

    addToggle(pageVisual, "Fullbright", false, function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(127,127,127)
        end
        notify("Fullbright", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageVisual, "Night Vision", false, function(v)
        nightVisionEnabled = v
        if v then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.fromRGB(80, 255, 120)
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.GlobalShadows = true
        end
        notify("Night Vision", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addButton(pageVisual, "Remove Fog", function()
        Lighting.FogEnd = 999999
        notify("Fog", "ลบหมอกแล้ว", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "🌦  WEATHER")

    addToggle(pageVisual, "Dynamic Weather", false, function(v)
        weatherEnabled = v
        if not v then
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx.Name:match("^BDW_") then fx:Destroy() end
            end
            for _, fx in ipairs(workspace:GetDescendants()) do
                if fx.Name == "BDW_Rain" then fx:Destroy() end
            end
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        else
            notify("Weather", "เปิดแล้ว — เลือก Mode ด้านล่าง", 2)
        end
    end)

    addDropdown(pageVisual, "Weather Mode", {"Clear", "Rain", "Storm", "Sunset", "Night", "Fog"}, function(opt)
        if not weatherEnabled then notify("Weather", "เปิด Dynamic Weather ก่อน", 2) return end
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx.Name:match("^BDW_") then fx:Destroy() end
        end
        for _, fx in ipairs(workspace:GetDescendants()) do
            if fx.Name == "BDW_Rain" then fx:Destroy() end
        end
        if opt == "Rain" then
            local rain = Instance.new("ParticleEmitter")
            rain.Name = "BDW_Rain"
            rain.Rate = 500
            rain.Lifetime = NumberRange.new(1, 1.5)
            rain.Speed = NumberRange.new(60, 80)
            rain.Size = NumberSequence.new(0.2)
            rain.Texture = "rbxassetid://241594314"
            rain.Parent = workspace.Terrain
            Lighting.FogEnd = 2500
            Lighting.Brightness = 1.2
        elseif opt == "Storm" then
            Lighting.Brightness = 0.8
            Lighting.ClockTime = 20
            Lighting.FogEnd = 1000
        elseif opt == "Sunset" then
            Lighting.ClockTime = 18
            Lighting.Ambient = Color3.fromRGB(255,200,170)
            local bloom = Instance.new("BloomEffect", Lighting)
            bloom.Name = "BDW_Bloom"
            bloom.Intensity = 0.5
        elseif opt == "Night" then
            Lighting.ClockTime = 22
            Lighting.Brightness = 0.5
        elseif opt == "Fog" then
            Lighting.FogEnd = 150
            Lighting.FogStart = 5
            Lighting.FogColor = Color3.fromRGB(190,190,190)
        else
            Lighting.ClockTime = 14
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
        end
        notify("Weather", opt, 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "✨  EFFECTS")

    addToggle(pageVisual, "Rainbow Mode", false, function(v)
        rainbowEnabled = v
        if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
        if v then
            rainbowConn = RunService.Heartbeat:Connect(function()
                if not rainbowEnabled then return end
                local char = getChar()
                if not char then return end
                local t = tick() % 5 / 5
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.Color = Color3.fromHSV(t, 1, 1) end
                end
            end)
        end
        notify("Rainbow", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageVisual, "Cinematic Mode", false, function(v)
        cinematicEnabled = v
        safe(function() StarterGui:SetCore("TopbarEnabled", not v) end)
        for _, g in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if g:IsA("ScreenGui") and g.Name ~= "BomDevHub_v3" then
                g.Enabled = not v
            end
        end
        notify("Cinematic", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "📊  STATS")

    addToggle(pageVisual, "Stat Monitor", false, function(v)
        statMonitorEnabled = v
        if statGui then statGui:Destroy() statGui = nil end
        if not v then notify("Stats", "ปิดแล้ว", 2) return end

        statGui = Instance.new("ScreenGui")
        statGui.Name = "BomDevStats"
        statGui.IgnoreGuiInset = true
        statGui.ResetOnSpawn = false
        safe(function() statGui.Parent = CoreGui end)
        if not statGui.Parent then statGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 190, 0, 110)
        box.Position = UDim2.new(0, 10, 0, 90)
        box.BackgroundColor3 = BG2
        box.BackgroundTransparency = 0.1
        box.Parent = statGui
        corner(box, 10)
        stroke(box, ACC, 1.2)
        grad(box, Color3.fromRGB(14, 10, 26), BG2, 135)

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 24)
        header.BackgroundTransparency = 1
        header.Text = "⚡ BomDev Stats"
        header.TextSize = 11
        header.Font = Enum.Font.GothamBold
        header.TextColor3 = ACC2
        header.Parent = box

        local statNames = {"FPS", "Speed", "Health", "Position"}
        local statLabels = {}
        for i, sname in ipairs(statNames) do
            local sl = Instance.new("TextLabel")
            sl.Name = sname
            sl.Size = UDim2.new(1, -14, 0, 18)
            sl.Position = UDim2.new(0, 8, 0, 22 + (i-1) * 20)
            sl.BackgroundTransparency = 1
            sl.TextColor3 = WHT
            sl.Font = Enum.Font.Code
            sl.TextSize = 10
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Text = sname .. ": ..."
            sl.Parent = box
            statLabels[sname] = sl
        end

        local lastT = tick()
        local frameC = 0
        RunService.RenderStepped:Connect(function()
            if not statMonitorEnabled then return end
            frameC = frameC + 1
            local now = tick()
            if now - lastT >= 1 then
                local fps = math.floor(frameC / (now - lastT))
                frameC = 0
                lastT = now
                local hum = getHum()
                local hrp = getHRP()
                local hp = hum and math.floor(hum.Health) or 0
                local mhp = hum and math.floor(hum.MaxHealth) or 100
                local spd = hum and math.floor(hum.WalkSpeed) or 0
                local pos = hrp and hrp.Position or Vector3.zero
                if statLabels.FPS then statLabels.FPS.Text = "FPS  " .. fps end
                if statLabels.Speed then statLabels.Speed.Text = "Speed  " .. spd end
                if statLabels.Health then statLabels.Health.Text = "HP  " .. hp .. "/" .. mhp end
                if statLabels.Position then
                    statLabels.Position.Text = math.floor(pos.X) .. " " .. math.floor(pos.Y) .. " " .. math.floor(pos.Z)
                end
            end
        end)
        notify("Stats", "เปิดแล้ว", 2)
    end)
end

do
    addSectionLabel(pagePlayer, "🛡  PROTECTION")

    addToggle(pagePlayer, "God Mode", false, function(v)
        if godConn then godConn:Disconnect() godConn = nil end
        godEnabled = v
        local hum = getHum()
        if hum then
            if v then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                godConn = RunService.Heartbeat:Connect(function()
                    local h = getHum()
                    if h and h.Health < 1e10 then h.Health = math.huge end
                end)
            else
                hum.MaxHealth = 100
                hum.Health = 100
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
        notify("God Mode", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Anti AFK", false, function(v)
        antiAFKEnabled = v
        if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
        if v then
            antiAFKConn = LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
            end)
        end
        notify("Anti AFK", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Invisible", false, function(v)
        invisEnabled = v
        local char = getChar()
        if not char then return end
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = v and 1 or 0
                if v then p.Material = Enum.Material.ForceField end
            elseif p:IsA("Decal") then
                p.Transparency = v and 1 or 0
            end
        end
        notify("Invisible", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "No Fall Damage", false, function(v)
        noFallEnabled = v
        local hum = getHum()
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSpacer(pagePlayer)
    addSectionLabel(pagePlayer, "👤  CHARACTER")

    addSlider(pagePlayer, "Character Scale", 10, 300, 100, "%", function(v)
        local char = getChar()
        if not char then return end
        local hum = getHum()
        if not hum then return end
        local scale = v / 100
        safe(function()
            hum.BodyDepthScale.Value = scale
            hum.BodyHeightScale.Value = scale
            hum.BodyWidthScale.Value = scale
            hum.HeadScale.Value = scale
        end)
    end)

    addSlider(pagePlayer, "Animation Speed", 0, 5, 1, "x", function(v)
        local hum = getHum()
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(v)
            end
        end
    end)

    addDropdown(pagePlayer, "Body Color", {"Default","Red","Blue","Green","Yellow","Purple","Black","White"}, function(opt)
        local colorMap = {
            Red = Color3.fromRGB(200,50,50),
            Blue = Color3.fromRGB(50,100,220),
            Green = Color3.fromRGB(50,180,80),
            Yellow = Color3.fromRGB(230,210,50),
            Purple = Color3.fromRGB(130,60,220),
            Black = Color3.fromRGB(25,25,25),
            White = Color3.fromRGB(240,240,240),
        }
        local char = getChar()
        if not char then return end
        local col = colorMap[opt]
        if col then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = col
                end
            end
            notify("Body Color", opt, 2)
        end
    end)

    addSpacer(pagePlayer)
    addSectionLabel(pagePlayer, "✨  EFFECTS")

    addToggle(pagePlayer, "Character Glow", false, function(v)
        glowEnabled = v
        local char = getChar()
        if not char then return end
        local ex = char:FindFirstChild("BomDevGlow")
        if ex then ex:Destroy() end
        if v then
            local hl = Instance.new("Highlight")
            hl.Name = "BomDevGlow"
            hl.FillColor = ACC
            hl.FillTransparency = 0.7
            hl.OutlineColor = ACC2
            hl.OutlineTransparency = 0
            hl.Parent = char
        end
        notify("Glow", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Fire Effect", false, function(v)
        fireEnabled = v
        local char = getChar()
        if not char then return end
        if v then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local f = Instance.new("Fire")
                    f.Name = "BomDevFire"
                    f.Heat = 5
                    f.Size = 3
                    f.Parent = p
                end
            end
        else
            for _, p in ipairs(char:GetDescendants()) do
                local f = p:FindFirstChild("BomDevFire")
                if f then f:Destroy() end
            end
        end
        notify("Fire", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Sparkle Effect", false, function(v)
        sparkleEnabled = v
        local char = getChar()
        if not char then return end
        if v then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local sp = Instance.new("Sparkles")
                    sp.Name = "BomDevSparkle"
                    sp.SparkleColor = ACC2
                    sp.Parent = p
                end
            end
        else
            for _, p in ipairs(char:GetDescendants()) do
                local sp = p:FindFirstChild("BomDevSparkle")
                if sp then sp:Destroy() end
            end
        end
        notify("Sparkle", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Force Field", false, function(v)
        local char = getChar()
        if not char then return end
        local ex = char:FindFirstChildOfClass("ForceField")
        if ex then ex:Destroy() end
        if v then
            local ff = Instance.new("ForceField")
            ff.Visible = true
            ff.Parent = char
        end
        notify("Force Field", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pagePlayer, "Trail Effect", false, function(v)
        trailEnabled = v
        local hrp = getHRP()
        if not hrp then return end
        local ex = hrp:FindFirstChild("BomDevTrail")
        if ex then ex:Destroy() end
        local a0 = hrp:FindFirstChild("BDTrailA0")
        if a0 then a0:Destroy() end
        local a1 = hrp:FindFirstChild("BDTrailA1")
        if a1 then a1:Destroy() end
        if v then
            local at0 = Instance.new("Attachment", hrp) at0.Name = "BDTrailA0" at0.Position = Vector3.new(0,1,0)
            local at1 = Instance.new("Attachment", hrp) at1.Name = "BDTrailA1" at1.Position = Vector3.new(0,-1,0)
            local trail = Instance.new("Trail")
            trail.Name = "BomDevTrail"
            trail.Attachment0 = at0
            trail.Attachment1 = at1
            trail.Lifetime = 0.8
            trail.MinLength = 0
            trail.FaceCamera = true
            trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, ACC),
                ColorSequenceKeypoint.new(0.5, ACC2),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
            })
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            trail.Parent = hrp
        end
        notify("Trail", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addButton(pagePlayer, "Reset Character", function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end)

    addSpacer(pagePlayer)
    addSectionLabel(pagePlayer, "🎭  EMOTES")

    addInput(pagePlayer, "Animation ID", "ใส่ Animation ID ที่นี่", function(text)
        if text and #text > 0 then
            local hum = getHum()
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. text
                local track = hum:LoadAnimation(anim)
                track:Play()
                notify("Emote", "กำลังเล่น ID: " .. text, 2)
            end
        end
    end)
end

do
    addSectionLabel(pageTeleport, "🎯  SELECT PLAYER")

    local pDD = addDropdown(pageTeleport, "Target Player", getPlayerList(), function(name)
        selectedPlayer = Players:FindFirstChild(name)
        notify("Target", selectedPlayer and "เลือก: " .. name or "ไม่พบผู้เล่น", 2)
    end)

    addButton(pageTeleport, "Refresh Player List", function()
        pDD.Set(getPlayerList())
        notify("Players", "รีเฟรชแล้ว", 2)
    end)

    addSpacer(pageTeleport)
    addSectionLabel(pageTeleport, "⚡  ACTIONS")

    addButton(pageTeleport, "🔀 Warp to Target", function()
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Warp", "ยังไม่ได้เลือกเป้าหมาย", 2)
            return
        end
        local hrp = getHRP()
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tHRP then
            hrp.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
            notify("Warp", "ไปหา " .. selectedPlayer.Name, 2)
        end
    end)

    addButton(pageTeleport, "🧲 Pull Target to Me", function()
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Pull", "ไม่มีเป้าหมาย", 2)
            return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = getHRP()
        if not (tHRP and myHRP) then return end
        if tHRP:FindFirstChild("BomDevPull") then tHRP.BomDevPull:Destroy() end
        local bp = Instance.new("BodyPosition")
        bp.Name = "BomDevPull"
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.P = 8000
        bp.D = 600
        bp.Position = myHRP.Position + myHRP.CFrame.LookVector * 3
        bp.Parent = tHRP
        notify("Pull", "ดึง " .. selectedPlayer.Name, 2)
        task.delay(1.5, function()
            if bp and bp.Parent then bp:Destroy() end
        end)
    end)

    addToggle(pageTeleport, "Freeze Target", false, function(v)
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Freeze", "ไม่มีเป้าหมาย", 2)
            return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then return end
        if v then
            local bf = Instance.new("BodyForce")
            bf.Name = "BomDevFreeze"
            bf.Force = Vector3.new(0, workspace.Gravity * tHRP:GetMass(), 0)
            bf.Parent = tHRP
            local ba = Instance.new("BodyAngularVelocity")
            ba.Name = "BomDevFreezeA"
            ba.AngularVelocity = Vector3.zero
            ba.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            ba.Parent = tHRP
            notify("Freeze", selectedPlayer.Name .. " หยุดแล้ว", 2)
        else
            local f = tHRP:FindFirstChild("BomDevFreeze")
            if f then f:Destroy() end
            local a = tHRP:FindFirstChild("BomDevFreezeA")
            if a then a:Destroy() end
            notify("Freeze", "ปลดแล้ว", 2)
        end
    end)

    addToggle(pageTeleport, "Spectate Target", false, function(v)
        if specConn then specConn:Disconnect() specConn = nil end
        if v then
            if not selectedPlayer or not selectedPlayer.Character then
                notify("Spectate", "ไม่มีเป้าหมาย", 2)
                return
            end
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
                Camera.CameraType = Enum.CameraType.Custom
            end
            notify("Spectate", "ดู " .. selectedPlayer.Name, 2)
        else
            Camera.CameraSubject = getHum()
            Camera.CameraType = Enum.CameraType.Custom
            notify("Spectate", "ปิดแล้ว", 2)
        end
    end)

    addToggle(pageTeleport, "Follow Target", false, function(v)
        followEnabled = v
        if followConn then followConn:Disconnect() followConn = nil end
        if v and selectedPlayer then
            followConn = RunService.Heartbeat:Connect(function()
                if not followEnabled then return end
                local myHRP = getHRP()
                local tHRP = selectedPlayer and selectedPlayer.Character and
                              selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and tHRP then
                    local dist = (myHRP.Position - tHRP.Position).Magnitude
                    if dist > 5 then
                        local dir = (tHRP.Position - myHRP.Position).Unit
                        myHRP.CFrame = myHRP.CFrame + dir * 0.5
                    end
                end
            end)
            notify("Follow", "ติดตาม " .. (selectedPlayer and selectedPlayer.Name or "?"), 2)
        else
            notify("Follow", "ปิดแล้ว", 2)
        end
    end)

    addSpacer(pageTeleport)
    addSectionLabel(pageTeleport, "📍  SAVED POSITIONS")

    for slot = 1, 5 do
        local slotRow = Instance.new("Frame")
        slotRow.Size = UDim2.new(1, 0, 0, 38)
        slotRow.BackgroundColor3 = BG3
        slotRow.BorderSizePixel = 0
        slotRow.ZIndex = 12
        slotRow.Parent = pageTeleport
        corner(slotRow, 8)
        grad(slotRow, BG3, Color3.fromRGB(15, 15, 24), 110)

        local slotLbl = Instance.new("TextLabel")
        slotLbl.Size = UDim2.new(0.35, 0, 1, 0)
        slotLbl.Position = UDim2.new(0, 14, 0, 0)
        slotLbl.BackgroundTransparency = 1
        slotLbl.Text = "📌 Slot " .. slot
        slotLbl.TextSize = 11
        slotLbl.Font = Enum.Font.GothamMedium
        slotLbl.TextColor3 = GRY
        slotLbl.TextXAlignment = Enum.TextXAlignment.Left
        slotLbl.ZIndex = 13
        slotLbl.Parent = slotRow

        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.28, -4, 0.7, 0)
        saveBtn.Position = UDim2.new(0.37, 0, 0.15, 0)
        saveBtn.BackgroundColor3 = Color3.fromRGB(22, 44, 22)
        saveBtn.BorderSizePixel = 0
        saveBtn.Text = "Save"
        saveBtn.TextSize = 10
        saveBtn.Font = Enum.Font.GothamMedium
        saveBtn.TextColor3 = GRN
        saveBtn.ZIndex = 13
        saveBtn.Parent = slotRow
        corner(saveBtn, 4)

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.28, -4, 0.7, 0)
        tpBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 44)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "Warp"
        tpBtn.TextSize = 10
        tpBtn.Font = Enum.Font.GothamMedium
        tpBtn.TextColor3 = ACC2
        tpBtn.ZIndex = 13
        tpBtn.Parent = slotRow
        corner(tpBtn, 4)

        saveBtn.MouseButton1Click:Connect(function()
            local hrp = getHRP()
            if hrp then
                savedPos[slot] = hrp.CFrame
                notify("Saved", "Slot " .. slot .. " บันทึกแล้ว", 2)
                slotLbl.TextColor3 = GRN
            end
        end)

        tpBtn.MouseButton1Click:Connect(function()
            if savedPos[slot] then
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = savedPos[slot] + Vector3.new(0, 3, 0)
                    notify("Warp", "Slot " .. slot, 2)
                end
            else
                notify("Warp", "Slot " .. slot .. " ว่างอยู่", 2)
            end
        end)
    end

    addSpacer(pageTeleport)

    addButton(pageTeleport, "⬆ Teleport Up 50 studs", function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
    end)

    addButton(pageTeleport, "🎯 Teleport to 0,0,0", function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(0, 50, 0) end
    end)

    addButton(pageTeleport, "🎲 Random Teleport", function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(math.random(-500,500), 100, math.random(-500,500))
        end
    end)
end

do
    addSectionLabel(pageUtils, "🌐  SERVER")

    addButton(pageUtils, "🔄 Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    addButton(pageUtils, "🔀 Server Hop", function()
        notify("Server Hop", "กำลังหา server ใหม่...", 2)
        safe(function()
            local data = HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" ..
                    game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            notify("Server Hop", "ไม่พบ server ว่าง", 2)
        end)
    end)

    addButton(pageUtils, "📋 Copy Place ID", function()
        safe(function() setclipboard(tostring(game.PlaceId)) end)
        notify("Copied", "Place ID: " .. game.PlaceId, 2)
    end)

    addButton(pageUtils, "📋 Copy User ID", function()
        safe(function() setclipboard(tostring(LocalPlayer.UserId)) end)
        notify("Copied", "User ID: " .. LocalPlayer.UserId, 2)
    end)

    addButton(pageUtils, "ℹ️ Server Info", function()
        notify("Server",
            "Place: " .. game.PlaceId .. "  Players: " ..
            #Players:GetPlayers() .. "/" .. Players.MaxPlayers, 4)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "🎵  MUSIC")

    addInput(pageUtils, "Sound ID", "วาง Sound ID ที่นี่ (ตัวเลขเท่านั้น)", function(text)
        currentMusicId = text
    end)

    addButton(pageUtils, "▶ Play Music", function()
        if musicObj then musicObj:Stop() musicObj:Destroy() musicObj = nil end
        if currentMusicId == "" then notify("Music", "ใส่ Sound ID ก่อน", 2) return end
        local snd = Instance.new("Sound")
        snd.Name = "BomDevMusic"
        snd.SoundId = "rbxassetid://" .. currentMusicId
        snd.Volume = 0.5
        snd.Looped = true
        snd.Parent = LocalPlayer:WaitForChild("PlayerGui")
        snd:Play()
        musicObj = snd
        notify("Music", "กำลังเล่น ID: " .. currentMusicId, 2)
    end)

    addButton(pageUtils, "⏹ Stop Music", function()
        if musicObj then
            musicObj:Stop()
            musicObj:Destroy()
            musicObj = nil
        end
        notify("Music", "หยุดแล้ว", 2)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "🤖  AUTO")

    addToggle(pageUtils, "Auto Farm", false, function(v)
        autoFarmEnabled = v
        if v then
            task.spawn(function()
                while autoFarmEnabled do
                    local hrp = getHRP()
                    if hrp then
                        local closest, closestD = nil, 50
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local name = obj.Name:lower()
                                if name:match("coin") or name:match("gem") or
                                   name:match("pickup") or name:match("collect") or name:match("orb") then
                                    local d = (hrp.Position - obj.Position).Magnitude
                                    if d < closestD then
                                        closestD = d
                                        closest = obj
                                    end
                                end
                            end
                        end
                        if closest then
                            hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 3, 0))
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
        notify("Auto Farm", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addToggle(pageUtils, "Auto Respawn", false, function(v)
        if v then
            local char = getChar()
            if char then
                local hum = getHum()
                if hum then
                    hum.Died:Connect(function()
                        task.wait(1)
                        LocalPlayer:LoadCharacter()
                    end)
                end
            end
            LocalPlayer.CharacterAdded:Connect(function(c)
                local h = c:WaitForChild("Humanoid")
                h.Died:Connect(function()
                    task.wait(1)
                    LocalPlayer:LoadCharacter()
                end)
            end)
        end
        notify("Auto Respawn", v and "เปิดแล้ว" or "ปิดแล้ว", 2)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "🌍  WORLD")

    addInput(pageUtils, "Find & Teleport to Part", "ชื่อ part", function(text)
        if not text or #text == 0 then return end
        local hrp = getHRP()
        if not hrp then return end
        local found, closest, closestD = 0, nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find(text:lower()) and obj:IsA("BasePart") then
                found = found + 1
                local d = (hrp.Position - obj.Position).Magnitude
                if d < closestD then closestD = d closest = obj end
            end
        end
        notify("Find", "พบ " .. found .. " parts ชื่อ '" .. text .. "'", 3)
        if closest then hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0)) end
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "💬  DISCORD")

    addAccentButton(pageUtils, "💬 Join BomDev Discord", function()
        safe(function() setclipboard(DISCORD_LINK) end)
        safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK) end)
        notify("Discord", "เปิดแล้ว + คัดลอก: discord.gg/4Vn8WwyV3u", 4)
    end, Color3.fromRGB(80, 95, 230), Color3.fromRGB(110, 125, 255))
end

do
    local function dlCard(page, title, desc, link, badgeText, badgeCol)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 80)
        card.BackgroundColor3 = BG3
        card.BorderSizePixel = 0
        card.ZIndex = 12
        card.Parent = page
        corner(card, 10)
        grad(card, Color3.fromRGB(18, 14, 32), BG3, 145)
        stroke(card, Color3.fromRGB(36, 30, 60), 1)

        local iconBox = Instance.new("Frame")
        iconBox.Size = UDim2.new(0, 46, 0, 46)
        iconBox.Position = UDim2.new(0, 12, 0.5, -23)
        iconBox.BackgroundColor3 = badgeCol or ACC
        iconBox.BorderSizePixel = 0
        iconBox.ZIndex = 13
        iconBox.Parent = card
        corner(iconBox, 10)
        grad(iconBox, badgeCol or ACC, ACC2, 135)

        local iconTxt = Instance.new("TextLabel")
        iconTxt.Size = UDim2.new(1, 0, 1, 0)
        iconTxt.BackgroundTransparency = 1
        iconTxt.Text = "📥"
        iconTxt.TextSize = 20
        iconTxt.Font = Enum.Font.GothamBold
        iconTxt.TextColor3 = WHT
        iconTxt.ZIndex = 14
        iconTxt.Parent = iconBox

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -130, 0, 22)
        titleLbl.Position = UDim2.new(0, 68, 0, 12)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextSize = 13
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextColor3 = WHT
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 13
        titleLbl.Parent = card

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -130, 0, 18)
        descLbl.Position = UDim2.new(0, 68, 0, 36)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.TextSize = 10
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextColor3 = GRY
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 13
        descLbl.Parent = card

        local badgeFrame = Instance.new("Frame")
        badgeFrame.Size = UDim2.new(0, 60, 0, 20)
        badgeFrame.Position = UDim2.new(0, 68, 0, 56)
        badgeFrame.BackgroundColor3 = badgeCol or ACC
        badgeFrame.BorderSizePixel = 0
        badgeFrame.ZIndex = 13
        badgeFrame.Parent = card
        corner(badgeFrame, 10)

        local badgeTxt = Instance.new("TextLabel")
        badgeTxt.Size = UDim2.new(1, 0, 1, 0)
        badgeTxt.BackgroundTransparency = 1
        badgeTxt.Text = badgeText or "FREE"
        badgeTxt.TextSize = 9
        badgeTxt.Font = Enum.Font.GothamBold
        badgeTxt.TextColor3 = WHT
        badgeTxt.ZIndex = 14
        badgeTxt.Parent = badgeFrame

        local dlBtn = Instance.new("TextButton")
        dlBtn.Size = UDim2.new(0, 72, 0, 28)
        dlBtn.Position = UDim2.new(1, -84, 0.5, -14)
        dlBtn.BackgroundColor3 = badgeCol or ACC
        dlBtn.BorderSizePixel = 0
        dlBtn.Text = "Get"
        dlBtn.TextSize = 11
        dlBtn.Font = Enum.Font.GothamBold
        dlBtn.TextColor3 = WHT
        dlBtn.ZIndex = 13
        dlBtn.Parent = card
        corner(dlBtn, 8)
        grad(dlBtn, badgeCol or ACC, ACC2, 90)

        dlBtn.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 20, 40)}):Play()
        end)
        dlBtn.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = BG3}):Play()
        end)
        dlBtn.MouseButton1Click:Connect(function()
            if link and link ~= "" then
                safe(function() setclipboard(link) end)
                safe(function() game:GetService("GuiService"):OpenBrowserWindow(link) end)
            end
            notify("Download", title .. " — คัดลอก link แล้ว!", 3)
        end)

        return card
    end

    local heroBanner = Instance.new("Frame")
    heroBanner.Size = UDim2.new(1, 0, 0, 90)
    heroBanner.BackgroundColor3 = ACC
    heroBanner.BorderSizePixel = 0
    heroBanner.ZIndex = 12
    heroBanner.Parent = pageDownload
    corner(heroBanner, 12)
    grad(heroBanner, Color3.fromRGB(80, 30, 180), Color3.fromRGB(30, 120, 220), 135)

    local heroIcon = Instance.new("TextLabel")
    heroIcon.Size = UDim2.new(0, 60, 0, 60)
    heroIcon.Position = UDim2.new(0, 16, 0.5, -30)
    heroIcon.BackgroundTransparency = 1
    heroIcon.Text = "⚡"
    heroIcon.TextSize = 40
    heroIcon.Font = Enum.Font.GothamBold
    heroIcon.TextColor3 = WHT
    heroIcon.ZIndex = 13
    heroIcon.Parent = heroBanner

    local heroTitle = Instance.new("TextLabel")
    heroTitle.Size = UDim2.new(1, -90, 0, 30)
    heroTitle.Position = UDim2.new(0, 84, 0, 14)
    heroTitle.BackgroundTransparency = 1
    heroTitle.Text = "BomDev Hub Downloads"
    heroTitle.TextSize = 16
    heroTitle.Font = Enum.Font.GothamBold
    heroTitle.TextColor3 = WHT
    heroTitle.TextXAlignment = Enum.TextXAlignment.Left
    heroTitle.ZIndex = 13
    heroTitle.Parent = heroBanner

    local heroSub = Instance.new("TextLabel")
    heroSub.Size = UDim2.new(1, -90, 0, 20)
    heroSub.Position = UDim2.new(0, 84, 0, 46)
    heroSub.BackgroundTransparency = 1
    heroSub.Text = "Scripts, Tools & Resources จาก BomDev Community"
    heroSub.TextSize = 10
    heroSub.Font = Enum.Font.Gotham
    heroSub.TextColor3 = Color3.fromRGB(200, 200, 230)
    heroSub.TextXAlignment = Enum.TextXAlignment.Left
    heroSub.ZIndex = 13
    heroSub.Parent = heroBanner

    addSpacer(pageDownload)
    addSectionLabel(pageDownload, "🔥  FEATURED SCRIPTS")

    dlCard(pageDownload,
        "BomDev Hub v3.0",
        "Main hub script — Full featured, updated",
        DISCORD_LINK,
        "LATEST",
        Color3.fromRGB(100, 60, 255)
    )

    dlCard(pageDownload,
        "BomDev AutoFarm Pro",
        "Advanced auto farm with multi-game support",
        DISCORD_LINK,
        "PREMIUM",
        Color3.fromRGB(220, 150, 0)
    )

    dlCard(pageDownload,
        "BomDev ESP Suite",
        "Enhanced ESP with player info & radar",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(50, 180, 80)
    )

    dlCard(pageDownload,
        "BomDev Speed Kit",
        "Advanced movement & speed hacks bundle",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(50, 180, 220)
    )

    addSpacer(pageDownload)
    addSectionLabel(pageDownload, "🛠  TOOLS & UTILITIES")

    dlCard(pageDownload,
        "BomDev Executor Checker",
        "Check your executor compatibility",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(60, 130, 220)
    )

    dlCard(pageDownload,
        "BomDev GUI Builder",
        "Build custom GUIs for your scripts",
        DISCORD_LINK,
        "TOOL",
        Color3.fromRGB(180, 80, 220)
    )

    dlCard(pageDownload,
        "BomDev Anti-Ban Kit",
        "Anti-detection utilities for safer scripting",
        DISCORD_LINK,
        "PRO",
        Color3.fromRGB(220, 80, 80)
    )

    addSpacer(pageDownload)
    addSectionLabel(pageDownload, "🎮  GAME-SPECIFIC")

    dlCard(pageDownload,
        "Blox Fruits Auto Farm",
        "Full auto farm for Blox Fruits by BomDev",
        DISCORD_LINK,
        "HOT",
        Color3.fromRGB(220, 120, 50)
    )

    dlCard(pageDownload,
        "Pet Simulator Auto Farm",
        "Farm pets & coins in Pet Simulator",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(50, 200, 130)
    )

    dlCard(pageDownload,
        "Murder Mystery 2 ESP",
        "Knife & gun ESP for Murder Mystery 2",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(200, 50, 80)
    )

    dlCard(pageDownload,
        "Arsenal Aimbot + ESP",
        "Full combat suite for Arsenal",
        DISCORD_LINK,
        "PRO",
        Color3.fromRGB(80, 160, 255)
    )

    dlCard(pageDownload,
        "Adopt Me Auto Farm",
        "Pet and bucks auto farm for Adopt Me",
        DISCORD_LINK,
        "FREE",
        Color3.fromRGB(255, 180, 80)
    )

    addSpacer(pageDownload)
    addSectionLabel(pageDownload, "🌐  COMMUNITY")

    local discordCard = Instance.new("Frame")
    discordCard.Size = UDim2.new(1, 0, 0, 70)
    discordCard.BackgroundColor3 = Color3.fromRGB(80, 95, 230)
    discordCard.BorderSizePixel = 0
    discordCard.ZIndex = 12
    discordCard.Parent = pageDownload
    corner(discordCard, 10)
    grad(discordCard, Color3.fromRGB(60, 75, 210), Color3.fromRGB(100, 115, 250), 135)

    local dIcon = Instance.new("TextLabel")
    dIcon.Size = UDim2.new(0, 50, 0, 50)
    dIcon.Position = UDim2.new(0, 12, 0.5, -25)
    dIcon.BackgroundTransparency = 1
    dIcon.Text = "💬"
    dIcon.TextSize = 28
    dIcon.Font = Enum.Font.GothamBold
    dIcon.TextColor3 = WHT
    dIcon.ZIndex = 13
    dIcon.Parent = discordCard

    local dTitle = Instance.new("TextLabel")
    dTitle.Size = UDim2.new(1, -150, 0, 24)
    dTitle.Position = UDim2.new(0, 72, 0, 12)
    dTitle.BackgroundTransparency = 1
    dTitle.Text = "BomDev Discord Server"
    dTitle.TextSize = 13
    dTitle.Font = Enum.Font.GothamBold
    dTitle.TextColor3 = WHT
    dTitle.TextXAlignment = Enum.TextXAlignment.Left
    dTitle.ZIndex = 13
    dTitle.Parent = discordCard

    local dSub = Instance.new("TextLabel")
    dSub.Size = UDim2.new(1, -150, 0, 18)
    dSub.Position = UDim2.new(0, 72, 0, 38)
    dSub.BackgroundTransparency = 1
    dSub.Text = "Scripts อัปเดต, Support, Community"
    dSub.TextSize = 10
    dSub.Font = Enum.Font.Gotham
    dSub.TextColor3 = Color3.fromRGB(200, 200, 240)
    dSub.TextXAlignment = Enum.TextXAlignment.Left
    dSub.ZIndex = 13
    dSub.Parent = discordCard

    local joinBtn = Instance.new("TextButton")
    joinBtn.Size = UDim2.new(0, 72, 0, 28)
    joinBtn.Position = UDim2.new(1, -84, 0.5, -14)
    joinBtn.BackgroundColor3 = WHT
    joinBtn.BorderSizePixel = 0
    joinBtn.Text = "Join"
    joinBtn.TextSize = 11
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.TextColor3 = Color3.fromRGB(80, 95, 230)
    joinBtn.ZIndex = 13
    joinBtn.Parent = discordCard
    corner(joinBtn, 8)
    joinBtn.MouseButton1Click:Connect(function()
        safe(function() setclipboard(DISCORD_LINK) end)
        safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK) end)
        notify("Discord", "เปิดแล้ว!", 2)
    end)

    addSpacer(pageDownload)

    local footNote = Instance.new("TextLabel")
    footNote.Size = UDim2.new(1, 0, 0, 40)
    footNote.BackgroundColor3 = BG3
    footNote.BorderSizePixel = 0
    footNote.Text = "🔒 Scripts ทั้งหมดผ่านการทดสอบ  ·  อัปเดตทุกสัปดาห์  ·  BomDev v3.0"
    footNote.TextSize = 10
    footNote.Font = Enum.Font.Gotham
    footNote.TextColor3 = GRY
    footNote.ZIndex = 12
    footNote.Parent = pageDownload
    corner(footNote, 8)
end

do
    addSectionLabel(pageSettings, "📷  CAMERA")

    addSlider(pageSettings, "Field of View", 50, 120, 70, "°", function(v)
        Camera.FieldOfView = v
    end)

    addButton(pageSettings, "FOV 70 (Default)", function()
        Camera.FieldOfView = 70
        notify("FOV", "รีเซ็ตเป็น 70", 2)
    end)

    addButton(pageSettings, "FOV 110 (Wide)", function()
        Camera.FieldOfView = 110
        notify("FOV", "110 — กว้าง", 2)
    end)

    addSpacer(pageSettings)
    addSectionLabel(pageSettings, "💡  LIGHTING")

    addSlider(pageSettings, "Clock Time", 0, 24, 14, "h", function(v)
        Lighting.ClockTime = v
    end)

    addSlider(pageSettings, "Brightness", 0, 10, 2, "x", function(v)
        Lighting.Brightness = v
    end)

    addToggle(pageSettings, "Global Shadows", true, function(v)
        Lighting.GlobalShadows = v
    end)

    addSpacer(pageSettings)
    addSectionLabel(pageSettings, "⌨  HOTKEYS (PC)")

    local hotkeyBox = Instance.new("Frame")
    hotkeyBox.Size = UDim2.new(1, 0, 0, 130)
    hotkeyBox.BackgroundColor3 = BG3
    hotkeyBox.BorderSizePixel = 0
    hotkeyBox.ZIndex = 12
    hotkeyBox.Parent = pageSettings
    corner(hotkeyBox, 10)
    grad(hotkeyBox, Color3.fromRGB(16, 12, 28), BG3, 135)

    local hkData = {
        {"F1", "Fly toggle"},
        {"F2", "Speed toggle"},
        {"F3", "God Mode toggle"},
        {"F4", "NoClip toggle"},
        {"]", "ซ่อน/แสดง GUI"},
        {"W/A/S/D", "บินตามกล้อง"},
        {"Space", "บินขึ้น"},
        {"LCtrl/LShift", "บินลง"},
    }

    for i, pair in ipairs(hkData) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -16, 0, 14)
        row.Position = UDim2.new(0, 8, 0, 6 + (i-1) * 15)
        row.BackgroundTransparency = 1
        row.ZIndex = 13
        row.Parent = hotkeyBox

        local keyLbl = Instance.new("TextLabel")
        keyLbl.Size = UDim2.new(0, 100, 1, 0)
        keyLbl.BackgroundTransparency = 1
        keyLbl.Text = pair[1]
        keyLbl.TextSize = 10
        keyLbl.Font = Enum.Font.Code
        keyLbl.TextColor3 = ACC2
        keyLbl.TextXAlignment = Enum.TextXAlignment.Left
        keyLbl.ZIndex = 13
        keyLbl.Parent = row

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -108, 1, 0)
        descLbl.Position = UDim2.new(0, 108, 0, 0)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = pair[2]
        descLbl.TextSize = 10
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextColor3 = GRY
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 13
        descLbl.Parent = row
    end

    addSpacer(pageSettings)
    addSectionLabel(pageSettings, "ℹ️  ABOUT")

    local aboutBox = Instance.new("Frame")
    aboutBox.Size = UDim2.new(1, 0, 0, 100)
    aboutBox.BackgroundColor3 = BG3
    aboutBox.BorderSizePixel = 0
    aboutBox.ZIndex = 12
    aboutBox.Parent = pageSettings
    corner(aboutBox, 10)
    grad(aboutBox, Color3.fromRGB(16, 10, 30), BG3, 135)
    stroke(aboutBox, Color3.fromRGB(36, 30, 60), 1)

    local aboutLines = {
        "⚡ BomDev Hub  v3.0",
        "Dev: BomDev",
        "Discord: discord.gg/4Vn8WwyV3u",
        "",
        "✅ Fly แก้ไขแล้ว — WASD ตามกล้อง 100%",
        "✅ UI ออกแบบใหม่ทั้งหมด",
        "✅ Download Page พร้อม Links",
    }

    for i, line in ipairs(aboutLines) do
        local al = Instance.new("TextLabel")
        al.Size = UDim2.new(1, -20, 0, 13)
        al.Position = UDim2.new(0, 12, 0, 4 + (i-1) * 13)
        al.BackgroundTransparency = 1
        al.Text = line
        al.TextSize = 10
        al.Font = i == 1 and Enum.Font.GothamBold or Enum.Font.Gotham
        al.TextColor3 = i == 1 and WHT or GRY
        al.TextXAlignment = Enum.TextXAlignment.Left
        al.ZIndex = 13
        al.Parent = aboutBox
    end
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F1 then
        flyEnabled = not flyEnabled
        local hum = getHum()
        if not flyEnabled then
            for _, c in pairs(flyConns) do
                if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
            end
            flyConns = {}
            if flyBV and flyBV.Parent then flyBV:Destroy() end
            if flyBG and flyBG.Parent then flyBG:Destroy() end
            flyBV = nil
            flyBG = nil
            if hum then hum.PlatformStand = false end
            notify("Fly", "F1 — ปิดแล้ว", 1)
        else
            local char = getChar()
            if not char then flyEnabled = false return end
            local hrp = getHRP()
            if not hrp then flyEnabled = false return end
            if not hum then flyEnabled = false return end
            hum.PlatformStand = true
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BomDevFlyBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            flyBV = bv
            local bg = Instance.new("BodyGyro")
            bg.Name = "BomDevFlyBG"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 6000
            bg.D = 600
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            flyBG = bg
            notify("Fly", "F1 — เปิดแล้ว (WASD ตามกล้อง)", 1)
            local conn = RunService.Heartbeat:Connect(function()
                if not flyEnabled then return end
                if not hrp or not hrp.Parent then return end
                local camCF = Camera.CFrame
                local camLook = camCF.LookVector
                local camRight = camCF.RightVector
                local vel = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + camLook * flySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - camLook * flySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + camRight * flySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - camRight * flySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, flySpeed * 0.7, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
                   UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, flySpeed * 0.7, 0) end
                flyBV.Velocity = vel.Magnitude < 0.01 and Vector3.zero or vel
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
                if flatLook.Magnitude > 0.01 then
                    flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook.Unit)
                end
            end)
            table.insert(flyConns, conn)
        end
    end
    if inp.KeyCode == Enum.KeyCode.F2 then
        speedEnabled = not speedEnabled
        local hum = getHum()
        if hum then hum.WalkSpeed = speedEnabled and speedValue or 16 end
        notify("Speed", speedEnabled and "F2 — เปิด" or "F2 — ปิด", 1)
    end
    if inp.KeyCode == Enum.KeyCode.F3 then
        if godConn then godConn:Disconnect() godConn = nil end
        godEnabled = not godEnabled
        local hum = getHum()
        if hum then
            if godEnabled then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                godConn = RunService.Heartbeat:Connect(function()
                    local h = getHum()
                    if h and h.Health < 1e10 then h.Health = math.huge end
                end)
            else
                hum.MaxHealth = 100
                hum.Health = 100
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
        notify("God Mode", godEnabled and "F3 — เปิด" or "F3 — ปิด", 1)
    end
    if inp.KeyCode == Enum.KeyCode.F4 then
        noclipEnabled = not noclipEnabled
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if noclipEnabled then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = getChar()
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
        notify("NoClip", noclipEnabled and "F4 — เปิด" or "F4 — ปิด", 1)
    end
    if inp.KeyCode == Enum.KeyCode.RightBracket then
        MF.Visible = not MF.Visible
    end
end)

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
    if godEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    if noFallEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
    if glowEnabled then
        local hl = Instance.new("Highlight")
        hl.Name = "BomDevGlow"
        hl.FillColor = ACC
        hl.FillTransparency = 0.7
        hl.OutlineColor = ACC2
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
end)

task.defer(function()
    if navBtns["Movement"] then
        navBtns["Movement"].frame:FindFirstChildOfClass("TextButton"):Fire and
        navBtns["Movement"].frame:FindFirstChildOfClass("TextButton"):Fire() or
        (function()
            pages["Movement"].Visible = true
            currentPage = "Movement"
            local nb = navBtns["Movement"]
            TweenService:Create(nb.frame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(nb.ind, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(nb.lbl, TweenInfo.new(0.2), {TextColor3 = WHT}):Play()
            TweenService:Create(nb.icon, TweenInfo.new(0.2), {TextColor3 = ACC2}):Play()
        end)()
    end
end)

task.spawn(function()
    task.wait(0.6)
    notify("⚡ BomDev Hub v3.0", "โหลดสำเร็จ!  Dev: BomDev  |  ] ซ่อน/แสดง", 5)
end)
