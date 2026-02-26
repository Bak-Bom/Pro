local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
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
local fpsBoostEnabled = false
local cinematicEnabled = false
local weatherEnabled = false
local weatherState = "Clear"
local infiniteJumpEnabled = false
local bunnyHopEnabled = false
local hitboxEnabled = false
local hitboxSize = 10
local reachEnabled = false
local reachDist = 30
local lagEnabled = false
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
local autoHealEnabled = false
local followEnabled = false
local killAuraEnabled = false
local killAuraRange = 15
local nightVisionEnabled = false
local statMonitorEnabled = false
local silentAimEnabled = false
local originalMaterials = {}
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
local autoHealConn = nil
local killAuraConn = nil
local followConn = nil
local statGui = nil
local trackerGui = nil
local crosshairGui = nil
local aimbotFOVGui = nil
local antiAFKConn = nil
local specConn = nil
local safeSpeedConn = nil

local DISCORD_LINK = "https://discord.gg/4Vn8WwyV3u"

local function getChar()
    return LocalPlayer.Character
end

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

local GUI = Instance.new("ScreenGui")
GUI.Name = "BomDevHub"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
safe(function() GUI.Parent = CoreGui end)
if not GUI.Parent then GUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local DARK = Color3.fromRGB(10, 10, 14)
local DARK2 = Color3.fromRGB(16, 16, 22)
local DARK3 = Color3.fromRGB(22, 22, 32)
local ACCENT = Color3.fromRGB(120, 70, 255)
local ACCENT2 = Color3.fromRGB(80, 200, 255)
local WHITE = Color3.fromRGB(235, 235, 245)
local GREY = Color3.fromRGB(120, 120, 140)
local GREEN = Color3.fromRGB(60, 220, 120)
local RED = Color3.fromRGB(220, 60, 80)

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function stroke(p, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or ACCENT
    s.Thickness = thickness or 1
    s.Parent = p
    return s
end

local function gradient(p, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or DARK, c2 or DARK2)
    g.Rotation = rotation or 90
    g.Parent = p
    return g
end

local function label(parent, text, size, color, font, pos, sz, xalign)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size or 14
    l.TextColor3 = color or WHITE
    l.Font = font or Enum.Font.GothamMedium
    l.BackgroundTransparency = 1
    l.Position = pos or UDim2.new(0,0,0,0)
    l.Size = sz or UDim2.new(1,0,1,0)
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 460)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
MainFrame.BackgroundColor3 = DARK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = GUI
corner(MainFrame, 12)
stroke(MainFrame, ACCENT, 1.5)

gradient(MainFrame, Color3.fromRGB(14, 10, 26), Color3.fromRGB(8, 6, 16), 135)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = DARK2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
corner(TopBar, 12)

local TopBarBottom = Instance.new("Frame")
TopBarBottom.Size = UDim2.new(1, 0, 0.5, 0)
TopBarBottom.Position = UDim2.new(0, 0, 0.5, 0)
TopBarBottom.BackgroundColor3 = DARK2
TopBarBottom.BorderSizePixel = 0
TopBarBottom.Parent = TopBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.BackgroundColor3 = ACCENT
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TopBar

local accentLineGrad = Instance.new("UIGradient")
accentLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ACCENT),
    ColorSequenceKeypoint.new(0.5, ACCENT2),
    ColorSequenceKeypoint.new(1, ACCENT),
})
accentLineGrad.Parent = AccentLine

-- Icon/Logo box
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(0, 34, 0, 34)
LogoFrame.Position = UDim2.new(0, 10, 0.5, -17)
LogoFrame.BackgroundColor3 = ACCENT
LogoFrame.BorderSizePixel = 0
LogoFrame.Parent = TopBar
corner(LogoFrame, 8)
local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new(ACCENT, ACCENT2)
logoGrad.Rotation = 135
logoGrad.Parent = LogoFrame
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "B"
LogoText.TextSize = 18
LogoText.Font = Enum.Font.GothamBold
LogoText.TextColor3 = WHITE
LogoText.Parent = LogoFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 0, 22)
TitleLabel.Position = UDim2.new(0, 52, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BomDev Hub"
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextColor3 = WHITE
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new(WHITE, ACCENT2)
TitleGrad.Rotation = 0
TitleGrad.Parent = TitleLabel

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 14)
SubLabel.Position = UDim2.new(0, 52, 0, 28)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Dev : BomDev  •  v2.2"
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextColor3 = GREY
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Discord Button in TopBar
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(0, 32, 0, 32)
DiscordBtn.Position = UDim2.new(1, -116, 0.5, -16)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.BorderSizePixel = 0
DiscordBtn.Text = ""
DiscordBtn.Parent = TopBar
corner(DiscordBtn, 8)

-- Discord SVG-like icon using text
local DiscordIcon = Instance.new("TextLabel")
DiscordIcon.Size = UDim2.new(1, 0, 1, 0)
DiscordIcon.BackgroundTransparency = 1
DiscordIcon.Text = "💬"
DiscordIcon.TextSize = 16
DiscordIcon.Font = Enum.Font.GothamBold
DiscordIcon.TextColor3 = WHITE
DiscordIcon.Parent = DiscordBtn

local discordTooltip = Instance.new("TextLabel")
discordTooltip.Size = UDim2.new(0, 120, 0, 24)
discordTooltip.Position = UDim2.new(1, -122, 1, 4)
discordTooltip.BackgroundColor3 = DARK3
discordTooltip.BorderSizePixel = 0
discordTooltip.Text = "Join BomDev Discord"
discordTooltip.TextSize = 10
discordTooltip.Font = Enum.Font.Gotham
discordTooltip.TextColor3 = WHITE
discordTooltip.Visible = false
discordTooltip.ZIndex = 50
discordTooltip.Parent = TopBar
corner(discordTooltip, 4)

DiscordBtn.MouseEnter:Connect(function()
    discordTooltip.Visible = true
    TweenService:Create(DiscordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(108, 121, 255)}):Play()
end)
DiscordBtn.MouseLeave:Connect(function()
    discordTooltip.Visible = false
    TweenService:Create(DiscordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
end)
DiscordBtn.MouseButton1Click:Connect(function()
    safe(function() setclipboard(DISCORD_LINK) end)
    safe(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK) end)
    notify("Discord", "discord.gg/bakbom - copied to clipboard!", 3)
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 80)
CloseBtn.Text = "✕"
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = WHITE
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
corner(CloseBtn, 7)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 100)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 80)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -76, 0.5, -14)
MinBtn.BackgroundColor3 = DARK3
MinBtn.Text = "─"
MinBtn.TextSize = 12
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = GREY
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
corner(MinBtn, 7)
stroke(MinBtn, Color3.fromRGB(60, 60, 80), 1)

local minimized = false
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, 0, 1, -48)
ContentArea.Position = UDim2.new(0, 0, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentArea.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 680, 0, 50) or UDim2.new(0, 680, 0, 460)
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = DARK2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentArea
corner(Sidebar, 0)

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Size = UDim2.new(1, -1, 1, -60)
NavList.Position = UDim2.new(0, 0, 0, 8)
NavList.BackgroundTransparency = 1
NavList.ScrollBarThickness = 0
NavList.CanvasSize = UDim2.new(0, 0, 0, 0)
NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 2)
NavLayout.Parent = NavList
NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NavList.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 10)
end)

local PageArea = Instance.new("Frame")
PageArea.Size = UDim2.new(1, -158, 1, -10)
PageArea.Position = UDim2.new(0, 155, 0, 5)
PageArea.BackgroundTransparency = 1
PageArea.Parent = ContentArea

local pages = {}
local navBtns = {}
local currentPage = nil

local function notify(title, msg, duration)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 280, 0, 60)
    notifFrame.Position = UDim2.new(1, -290, 1, -70)
    notifFrame.BackgroundColor3 = DARK2
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 100
    notifFrame.Parent = GUI
    corner(notifFrame, 8)
    stroke(notifFrame, ACCENT, 1)

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -12, 0, 22)
    notifTitle.Position = UDim2.new(0, 10, 0, 6)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextSize = 13
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextColor3 = ACCENT2
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.ZIndex = 101
    notifTitle.Parent = notifFrame

    local notifMsg = Instance.new("TextLabel")
    notifMsg.Size = UDim2.new(1, -12, 0, 22)
    notifMsg.Position = UDim2.new(0, 10, 0, 28)
    notifMsg.BackgroundTransparency = 1
    notifMsg.Text = msg or ""
    notifMsg.TextSize = 11
    notifMsg.Font = Enum.Font.Gotham
    notifMsg.TextColor3 = GREY
    notifMsg.TextXAlignment = Enum.TextXAlignment.Left
    notifMsg.ZIndex = 101
    notifMsg.Parent = notifFrame

    notifFrame.Position = UDim2.new(1, 10, 1, -70)
    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -290, 1, -70)
    }):Play()

    task.delay(duration or 3, function()
        TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 10, 1, -70)
        }):Play()
        task.wait(0.3)
        notifFrame:Destroy()
    end)
end

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = PageArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 6)
    pad.Parent = page

    pages[name] = page

    local navBtn = Instance.new("TextButton")
    navBtn.Size = UDim2.new(1, -8, 0, 36)
    navBtn.Position = UDim2.new(0, 4, 0, 0)
    navBtn.BackgroundColor3 = DARK3
    navBtn.BackgroundTransparency = 1
    navBtn.Text = name
    navBtn.TextSize = 13
    navBtn.Font = Enum.Font.GothamMedium
    navBtn.TextColor3 = GREY
    navBtn.TextXAlignment = Enum.TextXAlignment.Left
    navBtn.BorderSizePixel = 0
    navBtn.Parent = NavList
    corner(navBtn, 6)

    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 12)
    navPad.Parent = navBtn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, -12, 0.2, 0)
    indicator.BackgroundColor3 = ACCENT
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = navBtn
    corner(indicator, 2)

    navBtns[name] = {btn = navBtn, ind = indicator}

    navBtn.MouseButton1Click:Connect(function()
        if currentPage then
            pages[currentPage].Visible = false
            local old = navBtns[currentPage]
            if old then
                TweenService:Create(old.btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = GREY}):Play()
                TweenService:Create(old.ind, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end
        currentPage = name
        page.Visible = true
        TweenService:Create(navBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextColor3 = WHITE}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    navBtn.MouseEnter:Connect(function()
        if currentPage ~= name then
            TweenService:Create(navBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.7, TextColor3 = WHITE}):Play()
        end
    end)
    navBtn.MouseLeave:Connect(function()
        if currentPage ~= name then
            TweenService:Create(navBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextColor3 = GREY}):Play()
        end
    end)

    return page
end

local function addToggle(page, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = DARK3
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 8)

    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = ColorSequence.new(DARK3, Color3.fromRGB(18,18,28))
    rowGrad.Rotation = 90
    rowGrad.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleTrack = Instance.new("Frame")
    toggleTrack.Size = UDim2.new(0, 40, 0, 22)
    toggleTrack.Position = UDim2.new(1, -54, 0.5, -11)
    toggleTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Parent = row
    corner(toggleTrack, 11)
    stroke(toggleTrack, Color3.fromRGB(50, 50, 70), 1)

    local toggleThumb = Instance.new("Frame")
    toggleThumb.Size = UDim2.new(0, 16, 0, 16)
    toggleThumb.Position = UDim2.new(0, 3, 0.5, -8)
    toggleThumb.BackgroundColor3 = GREY
    toggleThumb.BorderSizePixel = 0
    toggleThumb.Parent = toggleTrack
    corner(toggleThumb, 8)

    local state = default or false

    local function updateVisual()
        if state then
            TweenService:Create(toggleThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, -19, 0.5, -8),
                BackgroundColor3 = ACCENT2
            }):Play()
            TweenService:Create(toggleTrack, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 50, 80)
            }):Play()
        else
            TweenService:Create(toggleThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = GREY
            }):Play()
            TweenService:Create(toggleTrack, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            }):Play()
        end
    end

    updateVisual()

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then callback(state) end
    end)

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26,26,38)}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = DARK3}):Play()
    end)

    return {
        setState = function(v)
            state = v
            updateVisual()
        end,
        getState = function() return state end
    }
end

local function addButton(page, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 38)
    btn.BackgroundColor3 = DARK3
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = WHITE
    btn.Parent = page
    corner(btn, 8)
    stroke(btn, Color3.fromRGB(50, 50, 70), 1)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = DARK3}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 30, 80)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 50)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function addAccentButton(page, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 38)
    btn.BackgroundColor3 = ACCENT
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = WHITE
    btn.Parent = page
    corner(btn, 8)

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(ACCENT, ACCENT2)
    g.Rotation = 90
    g.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(120, 80, 255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function addSlider(page, labelText, min, max, default, suffix, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 56)
    container.BackgroundColor3 = DARK3
    container.BorderSizePixel = 0
    container.Parent = page
    corner(container, 8)

    local rowGrad = Instance.new("UIGradient")
    rowGrad.Color = ColorSequence.new(DARK3, Color3.fromRGB(18,18,28))
    rowGrad.Rotation = 90
    rowGrad.Parent = container

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 26)
    topRow.BackgroundTransparency = 1
    topRow.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = topRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, -14, 1, 0)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. (suffix or "")
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextColor3 = ACCENT2
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = topRow

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 36)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    corner(sliderBg, 3)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    corner(sliderFill, 3)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new(ACCENT, ACCENT2)
    fillGrad.Rotation = 0
    fillGrad.Parent = sliderFill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    thumb.BackgroundColor3 = WHITE
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = sliderBg
    corner(thumb, 7)
    stroke(thumb, ACCENT, 1.5)

    local currentVal = default
    local dragging = false

    local function updateSlider(v)
        v = math.clamp(v, min, max)
        local rounded = math.floor(v / 1 + 0.5)
        currentVal = rounded
        local ratio = (rounded - min) / (max - min)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -7, 0.5, -7)
        valLbl.Text = tostring(rounded) .. (suffix or "")
        if callback then callback(rounded) end
    end

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 6
    sliderBtn.Parent = sliderBg

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local bgPos = sliderBg.AbsolutePosition.X
            local bgSize = sliderBg.AbsoluteSize.X
            local mouseX = inp.Position.X
            local ratio = math.clamp((mouseX - bgPos) / bgSize, 0, 1)
            updateSlider(min + ratio * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderBtn.TouchMoved:Connect(function(touch)
        local bgPos = sliderBg.AbsolutePosition.X
        local bgSize = sliderBg.AbsoluteSize.X
        local ratio = math.clamp((touch.Position.X - bgPos) / bgSize, 0, 1)
        updateSlider(min + ratio * (max - min))
    end)

    return {getValue = function() return currentVal end}
end

local function addInput(page, labelText, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 56)
    container.BackgroundColor3 = DARK3
    container.BorderSizePixel = 0
    container.Parent = page
    corner(container, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = GREY
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -28, 0, 24)
    inputBox.Position = UDim2.new(0, 14, 0, 26)
    inputBox.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or ""
    inputBox.PlaceholderColor3 = GREY
    inputBox.TextSize = 12
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextColor3 = WHITE
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    corner(inputBox, 4)
    stroke(inputBox, Color3.fromRGB(50,50,70), 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = inputBox

    inputBox.FocusLost:Connect(function(enter)
        if enter and callback then callback(inputBox.Text) end
    end)

    return inputBox
end

local function addDropdown(page, labelText, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 40)
    container.BackgroundColor3 = DARK3
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = page
    corner(container, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.45, 0, 0.8, 0)
    selectedLbl.Position = UDim2.new(0.52, 0, 0.1, 0)
    selectedLbl.BackgroundColor3 = Color3.fromRGB(28,28,42)
    selectedLbl.BorderSizePixel = 0
    selectedLbl.Text = options[1] or "select"
    selectedLbl.TextSize = 11
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextColor3 = GREY
    selectedLbl.Parent = container
    corner(selectedLbl, 4)
    stroke(selectedLbl, Color3.fromRGB(50,50,70), 1)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(0.45, 0, 0, 0)
    dropFrame.Position = UDim2.new(0.52, 0, 1, 2)
    dropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    dropFrame.BorderSizePixel = 0
    dropFrame.ClipsDescendants = true
    dropFrame.ZIndex = 20
    dropFrame.Parent = container
    corner(dropFrame, 6)
    stroke(dropFrame, ACCENT, 1)

    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Parent = dropFrame

    local dropOpen = false

    local function populateOptions(opts)
        for _, ch in ipairs(dropFrame:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for _, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(22,22,34)
            optBtn.BackgroundTransparency = 0
            optBtn.Text = opt
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextColor3 = WHITE
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 21
            optBtn.Parent = dropFrame

            optBtn.MouseEnter:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35,35,55)}):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22,22,34)}):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selectedLbl.Text = opt
                if callback then callback(opt) end
                dropOpen = false
                TweenService:Create(dropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.45, 0, 0, 0)}):Play()
            end)
        end
        dropFrame.Size = UDim2.new(0.45, 0, 0, #opts * 28)
    end

    populateOptions(options)
    dropFrame.Size = UDim2.new(0.45, 0, 0, 0)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
    toggleBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = container

    toggleBtn.MouseButton1Click:Connect(function()
        dropOpen = not dropOpen
        if dropOpen then
            TweenService:Create(dropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0.45, 0, 0, #dropFrame:GetChildren() * 28)
            }):Play()
        else
            TweenService:Create(dropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0.45, 0, 0, 0)
            }):Play()
        end
    end)

    return {
        Set = function(newOpts)
            populateOptions(newOpts)
            dropFrame.Size = UDim2.new(0.45, 0, 0, 0)
            dropOpen = false
        end
    }
end

local function addSectionLabel(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
    lbl.BorderSizePixel = 0
    lbl.Text = text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = ACCENT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = page
    corner(lbl, 4)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = lbl

    return lbl
end

local function addSpacer(page)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -4, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    s.BorderSizePixel = 0
    s.Parent = page
end

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(1, 0, 0, 60)
VersionLabel.Position = UDim2.new(0, 0, 1, -60)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "BomDev Hub  v2.2"
VersionLabel.TextSize = 10
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextColor3 = Color3.fromRGB(60, 60, 80)
VersionLabel.TextXAlignment = Enum.TextXAlignment.Center
VersionLabel.Parent = Sidebar

local pageMovement = createPage("Movement")
local pageCombat = createPage("Combat")
local pageVisual = createPage("Visual")
local pagePlayer = createPage("Player")
local pageTeleport = createPage("Teleport")
local pageUtils = createPage("Utilities")
local pageSettings = createPage("Settings")

do
    addSectionLabel(pageMovement, "FLIGHT")

    addToggle(pageMovement, "Fly Mode", false, function(v)
        flyEnabled = v

        if flyEnabled then
            local char = getChar()
            if not char then flyEnabled = false return end
            local hrp = getHRP()
            if not hrp then flyEnabled = false return end
            local hum = getHum()
            if not hum then flyEnabled = false return end

            local bv = Instance.new("BodyVelocity")
            bv.Name = "BomDevFlyBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            flyBV = bv

            local bg = Instance.new("BodyGyro")
            bg.Name = "BomDevFlyBG"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 5000
            bg.D = 500
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            flyBG = bg

            notify("Fly", "Flight mode enabled", 2)

            local conn = RunService.Heartbeat:Connect(function()
                if not flyEnabled then
                    for _, c in pairs(flyConns) do
                        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
                    end
                    flyConns = {}
                    if flyBV and flyBV.Parent then flyBV:Destroy() end
                    if flyBG and flyBG.Parent then flyBG:Destroy() end
                    flyBV = nil
                    flyBG = nil
                    return
                end

                if not hrp or not hrp.Parent then return end

                local camCF = Camera.CFrame
                local look = camCF.LookVector
                local right = camCF.RightVector
                local flatLook = Vector3.new(look.X, 0, look.Z)
                local flatRight = Vector3.new(right.X, 0, right.Z)

                if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(0,0,-1) end
                if flatRight.Magnitude < 0.01 then flatRight = Vector3.new(1,0,0) end

                flatLook = flatLook.Unit
                flatRight = flatRight.Unit

                local md = hum.MoveDirection
                local vel = Vector3.zero

                if md.Magnitude > 0.01 then
                    local fwd = -md.Z
                    local rgt = md.X
                    vel = (flatLook * fwd + flatRight * rgt) * flySpeed

                    if math.abs(look.Y) > 0.3 then
                        vel = vel + Vector3.new(0, look.Y * flySpeed * fwd, 0)
                    end
                end

                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vel = vel + Vector3.new(0, flySpeed * 0.6, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
                   UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    vel = vel - Vector3.new(0, flySpeed * 0.6, 0)
                end

                flyBV.Velocity = vel

                local targetLook = Vector3.new(look.X, 0, look.Z)
                if targetLook.Magnitude > 0.01 then
                    flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + targetLook)
                end
            end)

            table.insert(flyConns, conn)
        else
            for _, c in pairs(flyConns) do
                if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
            end
            flyConns = {}
            if flyBV and flyBV.Parent then flyBV:Destroy() end
            if flyBG and flyBG.Parent then flyBG:Destroy() end
            flyBV = nil
            flyBG = nil
            notify("Fly", "Flight mode disabled", 2)
        end
    end)

    addSlider(pageMovement, "Fly Speed", 10, 500, 60, "", function(v) flySpeed = v end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "SPEED & JUMP")

    addToggle(pageMovement, "Super Speed", false, function(v)
        speedEnabled = v
        local hum = getHum()
        if hum then hum.WalkSpeed = v and speedValue or 16 end
        notify("Speed", v and "Speed hack on" or "Speed hack off", 2)
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
        notify("Jump", v and "High jump on" or "High jump off", 2)
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
        notify("Infinite Jump", v and "On" or "Off", 2)
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
        notify("BunnyHop", v and "On" or "Off", 2)
    end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "PHYSICS")

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
        notify("NoClip", v and "On" or "Off", 2)
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
        notify("No Friction", v and "On" or "Off", 2)
    end)

    addToggle(pageMovement, "No Fall Damage", false, function(v)
        noFallEnabled = v
        local hum = getHum()
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "On" or "Off", 2)
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
        notify("Walk on Water", v and "On" or "Off", 2)
    end)

    addSpacer(pageMovement)

    addButton(pageMovement, "Speed Burst (3s max speed)", function()
        local hum = getHum()
        if not hum then return end
        local orig = hum.WalkSpeed
        hum.WalkSpeed = 500
        notify("Speed Burst", "3 seconds", 2)
        task.delay(3, function()
            if hum and hum.Parent then hum.WalkSpeed = orig end
        end)
    end)

    addButton(pageMovement, "Dash Forward 30 studs", function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 30
        end
    end)

    addButton(pageMovement, "Super Jump (instant)", function()
        local hrp = getHRP()
        if hrp then hrp.Velocity = Vector3.new(0, 200, 0) end
    end)

    addSpacer(pageMovement)
    addSectionLabel(pageMovement, "GRAVITY")

    addSlider(pageMovement, "Gravity", 0, 300, 196, "", function(v)
        workspace.Gravity = v
    end)

    addButton(pageMovement, "Low Gravity (40)", function()
        workspace.Gravity = 40
        notify("Gravity", "Low gravity", 2)
    end)

    addButton(pageMovement, "Normal Gravity (196)", function()
        workspace.Gravity = 196
        notify("Gravity", "Normal gravity", 2)
    end)
end

do
    addSectionLabel(pageCombat, "AIMBOT")

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
        notify("Aimbot", v and "On - whitelist: " .. #aimbotWL .. " players" or "Off", 2)
    end)

    addSlider(pageCombat, "Aimbot Range", 50, 1000, 200, " studs", function(v) aimbotRange = v end)
    addSlider(pageCombat, "Aimbot Smoothing", 1, 100, 15, "%", function(v) aimbotSmooth = v / 100 end)

    addSpacer(pageCombat)
    addSectionLabel(pageCombat, "AIMBOT WHITELIST")

    local wlDropdown = addDropdown(pageCombat, "Add to Whitelist", getPlayerList(), function(name)
        for _, n in ipairs(aimbotWL) do
            if n == name then
                notify("Whitelist", name .. " already in list", 2)
                return
            end
        end
        table.insert(aimbotWL, name)
        notify("Whitelist", "Added " .. name .. " - aimbot will skip them", 3)
    end)

    addButton(pageCombat, "Refresh player list", function()
        wlDropdown.Set(getPlayerList())
        notify("Whitelist", "Player list refreshed", 2)
    end)

    local removeDropdown = addDropdown(pageCombat, "Remove from Whitelist", {"(empty)"}, function(name)
        if name == "(empty)" then return end
        for i, n in ipairs(aimbotWL) do
            if n == name then
                table.remove(aimbotWL, i)
                notify("Whitelist", "Removed " .. name, 2)
                local newList = #aimbotWL > 0 and aimbotWL or {"(empty)"}
                removeDropdown.Set(newList)
                return
            end
        end
    end)

    addButton(pageCombat, "Update remove list", function()
        local list = #aimbotWL > 0 and aimbotWL or {"(empty)"}
        removeDropdown.Set(list)
        notify("Whitelist", #aimbotWL .. " players whitelisted", 2)
    end)

    addButton(pageCombat, "Clear all whitelist", function()
        aimbotWL = {}
        removeDropdown.Set({"(empty)"})
        notify("Whitelist", "Cleared", 2)
    end)

    addSpacer(pageCombat)
    addSectionLabel(pageCombat, "HITBOX & REACH")

    addToggle(pageCombat, "Hitbox Expander", false, function(v)
        hitboxEnabled = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if v then
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 0.9
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                end
            end
        end
        notify("Hitbox", v and "Expanded to " .. hitboxSize or "Reset", 2)
    end)

    addSlider(pageCombat, "Hitbox Size", 3, 50, 10, "", function(v)
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

    addSpacer(pageCombat)
    addSectionLabel(pageCombat, "AUTO")

    addToggle(pageCombat, "Auto Heal", false, function(v)
        autoHealEnabled = v
        if autoHealConn then autoHealConn:Disconnect() autoHealConn = nil end
        if v then
            autoHealConn = RunService.Heartbeat:Connect(function()
                if not autoHealEnabled then return end
                local hum = getHum()
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = math.min(hum.Health + 1, hum.MaxHealth)
                end
            end)
        end
        notify("Auto Heal", v and "On" or "Off", 2)
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
                    if inWL(p) then continue end
                    local char = p.Character
                    if not char then continue end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        if (myHRP.Position - hrp.Position).Magnitude <= killAuraRange then
                            safe(function()
                                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                if tool then
                                    local remote = tool:FindFirstChildOfClass("RemoteEvent")
                                    if remote then remote:FireServer(hum) end
                                end
                            end)
                        end
                    end
                end
            end)
        end
        notify("Kill Aura", v and "Range: " .. killAuraRange or "Off", 2)
    end)

    addSlider(pageCombat, "Kill Aura Range", 5, 50, 15, " studs", function(v) killAuraRange = v end)

    addToggle(pageCombat, "Silent Aim", false, function(v)
        silentAimEnabled = v
        notify("Silent Aim", v and "On" or "Off", 2)
    end)

    addToggle(pageCombat, "Lag Switch", false, function(v)
        lagEnabled = v
        notify("Lag Switch", v and "On - may get kicked" or "Off", 2)
        if v then
            task.spawn(function()
                while lagEnabled do
                    local hrp = getHRP()
                    if hrp then hrp.CFrame = hrp.CFrame end
                    task.wait(0.001)
                end
            end)
        end
    end)
end

do
    addSectionLabel(pageVisual, "ESP")

    addToggle(pageVisual, "Player ESP", false, function(v)
        espEnabled = v
        if not v then
            for _, conn in pairs(espConns) do
                if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
            end
            espConns = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("BomDevESP")
                    if hl then hl:Destroy() end
                    local bb = p.Character:FindFirstChild("BomDevESPBB")
                    if bb then bb:Destroy() end
                end
            end
        else
            local function addESP(player)
                if player == LocalPlayer then return end
                if not player.Character then return end
                local char = player.Character
                if char:FindFirstChild("BomDevESP") then return end

                local hl = Instance.new("Highlight")
                hl.Name = "BomDevESP"
                hl.FillTransparency = 0.6
                hl.FillColor = Color3.fromRGB(200, 60, 60)
                hl.OutlineColor = Color3.fromRGB(255, 220, 0)
                hl.OutlineTransparency = 0
                hl.Parent = char

                if espDetailEnabled then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "BomDevESPBB"
                        bb.Size = UDim2.new(0, 120, 0, 44)
                        bb.StudsOffset = Vector3.new(0, 3.2, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = hrp
                        bb.Parent = char

                        local nameLbl = Instance.new("TextLabel")
                        nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLbl.BackgroundTransparency = 1
                        nameLbl.Text = player.Name
                        nameLbl.TextSize = 13
                        nameLbl.Font = Enum.Font.GothamBold
                        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 100)
                        nameLbl.TextStrokeTransparency = 0
                        nameLbl.Parent = bb

                        local infoLbl = Instance.new("TextLabel")
                        infoLbl.Name = "InfoLbl"
                        infoLbl.Size = UDim2.new(1, 0, 0.5, 0)
                        infoLbl.Position = UDim2.new(0, 0, 0.5, 0)
                        infoLbl.BackgroundTransparency = 1
                        infoLbl.Text = "HP: ?"
                        infoLbl.TextSize = 11
                        infoLbl.Font = Enum.Font.Gotham
                        infoLbl.TextColor3 = Color3.fromRGB(180, 255, 180)
                        infoLbl.TextStrokeTransparency = 0
                        infoLbl.Parent = bb

                        local uc = RunService.Heartbeat:Connect(function()
                            if not espEnabled then return end
                            local c = player.Character
                            if not c then return end
                            local hum = c:FindFirstChildOfClass("Humanoid")
                            local myH = getHRP()
                            local theirH = c:FindFirstChild("HumanoidRootPart")
                            local hp = hum and math.floor(hum.Health) or 0
                            local maxHp = hum and math.floor(hum.MaxHealth) or 100
                            local dist = (myH and theirH) and
                                math.floor((myH.Position - theirH.Position).Magnitude) or 0
                            if infoLbl and infoLbl.Parent then
                                infoLbl.Text = hp .. "/" .. maxHp .. " hp  " .. dist .. "m"
                            end
                            if hl and hl.Parent then
                                local ratio = math.clamp(hp / math.max(maxHp, 1), 0, 1)
                                hl.FillColor = Color3.fromRGB(
                                    math.floor(255 * (1 - ratio)),
                                    math.floor(220 * ratio),
                                    50
                                )
                            end
                        end)
                        table.insert(espConns, uc)
                    end
                end
            end

            for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
            local conn = Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    task.wait(1)
                    if espEnabled then addESP(p) end
                end)
            end)
            table.insert(espConns, conn)
        end
        notify("ESP", v and "On" or "Off", 2)
    end)

    addToggle(pageVisual, "ESP Details (HP + Distance)", false, function(v)
        espDetailEnabled = v
        notify("ESP Detail", v and "On - restart ESP to apply" or "Off", 2)
    end)

    addToggle(pageVisual, "Player Name Tracker", false, function(v)
        trackerEnabled = v
        for _, c in pairs(trackerConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        trackerConns = {}
        if trackerGui then trackerGui:Destroy() trackerGui = nil end

        if not v then
            notify("Tracker", "Off", 2)
            return
        end

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
                lb.Size = UDim2.new(0, 110, 0, 22)
                lb.Position = UDim2.new(0, screenPos.X - 55, 0, screenPos.Y - 28)
                lb.BackgroundColor3 = Color3.fromRGB(0,0,0)
                lb.BackgroundTransparency = 0.4
                lb.TextColor3 = Color3.fromRGB(255, 220, 0)
                lb.Font = Enum.Font.GothamBold
                lb.TextScaled = true
                lb.Text = p.Name .. "  " .. dist .. "m"
                lb.ZIndex = 15
                lb.Parent = trackerGui
                corner(lb, 4)
                table.insert(labels, lb)
            end
        end)
        table.insert(trackerConns, uc)
        notify("Tracker", "On", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "CROSSHAIR")

    addToggle(pageVisual, "Custom Crosshair", false, function(v)
        if crosshairGui then crosshairGui:Destroy() crosshairGui = nil end
        if not v then notify("Crosshair", "Off", 2) return end

        crosshairGui = Instance.new("ScreenGui")
        crosshairGui.Name = "BomDevCH"
        crosshairGui.IgnoreGuiInset = true
        crosshairGui.ResetOnSpawn = false
        safe(function() crosshairGui.Parent = CoreGui end)
        if not crosshairGui.Parent then crosshairGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local lines = {
            {UDim2.new(0, 14, 0, 2), UDim2.new(0.5, 7, 0.5, -1)},
            {UDim2.new(0, 14, 0, 2), UDim2.new(0.5, -21, 0.5, -1)},
            {UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, 7)},
            {UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, -21)},
        }
        for _, ld in ipairs(lines) do
            local f = Instance.new("Frame")
            f.Size = ld[1]
            f.Position = ld[2]
            f.BackgroundColor3 = ACCENT2
            f.BorderSizePixel = 0
            f.Parent = crosshairGui
        end
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -2, 0.5, -2)
        dot.BackgroundColor3 = WHITE
        dot.BorderSizePixel = 0
        dot.Parent = crosshairGui
        corner(dot, 2)

        notify("Crosshair", "On", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "LIGHTING")

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
        notify("Fullbright", v and "On" or "Off", 2)
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
        notify("Night Vision", v and "On" or "Off", 2)
    end)

    addToggle(pageVisual, "Realistic Graphics", false, function(v)
        for _, fx in pairs(Lighting:GetChildren()) do
            if fx:IsA("BloomEffect") or fx:IsA("SunRaysEffect") or
               fx:IsA("ColorCorrectionEffect") or fx:IsA("DepthOfFieldEffect") then
                fx:Destroy()
            end
        end
        if v then
            Lighting.Brightness = 3
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.5
            Lighting.EnvironmentSpecularScale = 1
            Lighting.ClockTime = 16
            local bloom = Instance.new("BloomEffect", Lighting) bloom.Intensity = 0.4 bloom.Size = 24
            local cc = Instance.new("ColorCorrectionEffect", Lighting) cc.Saturation = 0.2 cc.Contrast = 0.3
            local sun = Instance.new("SunRaysEffect", Lighting) sun.Intensity = 0.2
        end
        notify("Realistic", v and "On" or "Off", 2)
    end)

    addButton(pageVisual, "Remove Fog", function()
        Lighting.FogEnd = 999999
        notify("Fog", "Removed", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "WEATHER")

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
            notify("Weather", "On - select mode below", 2)
        end
    end)

    addDropdown(pageVisual, "Weather Mode", {"Clear", "Rain", "Storm", "Sunset", "Night", "Fog"}, function(opt)
        if not weatherEnabled then notify("Weather", "Enable Dynamic Weather first", 2) return end
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
    addSectionLabel(pageVisual, "EFFECTS")

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
        notify("Rainbow", v and "On" or "Off", 2)
    end)

    addToggle(pageVisual, "Cinematic Mode", false, function(v)
        cinematicEnabled = v
        safe(function() StarterGui:SetCore("TopbarEnabled", not v) end)
        for _, g in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if g:IsA("ScreenGui") and g.Name ~= "BomDevHub" and g.Name ~= "BomDevTracker" then
                g.Enabled = not v
            end
        end
        notify("Cinematic", v and "On" or "Off", 2)
    end)

    addToggle(pageVisual, "Camera Shake", false, function(v)
        if v then
            RunService.RenderStepped:Connect(function()
                if not v then return end
                local s = 0.25
                Camera.CFrame = Camera.CFrame *
                    CFrame.Angles(math.random() * s * 2 - s, math.random() * s * 2 - s, 0)
            end)
        end
        notify("Camera Shake", v and "On" or "Off", 2)
    end)

    addSpacer(pageVisual)
    addSectionLabel(pageVisual, "STATS")

    addToggle(pageVisual, "Stat Monitor (FPS / HP / Speed)", false, function(v)
        statMonitorEnabled = v
        if statGui then statGui:Destroy() statGui = nil end
        if not v then notify("Stats", "Off", 2) return end

        statGui = Instance.new("ScreenGui")
        statGui.Name = "BomDevStats"
        statGui.IgnoreGuiInset = true
        statGui.ResetOnSpawn = false
        safe(function() statGui.Parent = CoreGui end)
        if not statGui.Parent then statGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 180, 0, 110)
        box.Position = UDim2.new(0, 10, 0, 90)
        box.BackgroundColor3 = DARK2
        box.BackgroundTransparency = 0.2
        box.Parent = statGui
        corner(box, 8)
        stroke(box, ACCENT, 1)

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Text = "BomDev Stats"
        header.TextSize = 11
        header.Font = Enum.Font.GothamBold
        header.TextColor3 = ACCENT2
        header.Parent = box

        local statLabels = {}
        local statNames = {"FPS", "Speed", "Health", "Position"}
        for i, name in ipairs(statNames) do
            local sl = Instance.new("TextLabel")
            sl.Name = name
            sl.Size = UDim2.new(1, -12, 0, 18)
            sl.Position = UDim2.new(0, 8, 0, 20 + (i-1) * 20)
            sl.BackgroundTransparency = 1
            sl.TextColor3 = WHITE
            sl.Font = Enum.Font.Code
            sl.TextSize = 11
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Text = name .. ": ..."
            sl.Parent = box
            statLabels[name] = sl
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

        notify("Stats", "On", 2)
    end)
end

do
    addSectionLabel(pagePlayer, "PROTECTION")

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
        notify("God Mode", v and "On" or "Off", 2)
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
        notify("Anti AFK", v and "On" or "Off", 2)
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
        notify("Invisible", v and "On" or "Off", 2)
    end)

    addToggle(pagePlayer, "No Fall Damage", false, function(v)
        noFallEnabled = v
        local hum = getHum()
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "On" or "Off", 2)
    end)

    addSpacer(pagePlayer)
    addSectionLabel(pagePlayer, "CHARACTER")

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

    addDropdown(pagePlayer, "Body Color", {"Default", "Red", "Blue", "Green", "Yellow", "Purple", "Black", "White"}, function(opt)
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
    addSectionLabel(pagePlayer, "EFFECTS")

    addToggle(pagePlayer, "Character Glow", false, function(v)
        glowEnabled = v
        local char = getChar()
        if not char then return end
        local ex = char:FindFirstChild("BomDevGlow")
        if ex then ex:Destroy() end
        if v then
            local hl = Instance.new("Highlight")
            hl.Name = "BomDevGlow"
            hl.FillColor = ACCENT
            hl.FillTransparency = 0.7
            hl.OutlineColor = ACCENT2
            hl.OutlineTransparency = 0
            hl.Parent = char
        end
        notify("Glow", v and "On" or "Off", 2)
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
        notify("Fire", v and "On" or "Off", 2)
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
                    sp.SparkleColor = ACCENT2
                    sp.Parent = p
                end
            end
        else
            for _, p in ipairs(char:GetDescendants()) do
                local sp = p:FindFirstChild("BomDevSparkle")
                if sp then sp:Destroy() end
            end
        end
        notify("Sparkle", v and "On" or "Off", 2)
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
        notify("Force Field", v and "On" or "Off", 2)
    end)

    addToggle(pagePlayer, "Trail", false, function(v)
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
                ColorSequenceKeypoint.new(0, ACCENT),
                ColorSequenceKeypoint.new(0.5, ACCENT2),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
            })
            trail.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            trail.Parent = hrp
        end
        notify("Trail", v and "On" or "Off", 2)
    end)

    addButton(pagePlayer, "Reset character", function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end)

    addSpacer(pagePlayer)
    addSectionLabel(pagePlayer, "EMOTES")

    addInput(pagePlayer, "Animation ID", "paste anim id here", function(text)
        if text and #text > 0 then
            local char = getChar()
            local hum = getHum()
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. text
                local track = hum:LoadAnimation(anim)
                track:Play()
                notify("Emote", "Playing " .. text, 2)
            end
        end
    end)
end

do
    addSectionLabel(pageTeleport, "SELECT PLAYER")

    local pDropdown = addDropdown(pageTeleport, "Target Player", getPlayerList(), function(name)
        selectedPlayer = Players:FindFirstChild(name)
        if selectedPlayer then
            notify("Target", "Selected: " .. name, 2)
        else
            notify("Target", "Player not found", 2)
        end
    end)

    addButton(pageTeleport, "Refresh player list", function()
        pDropdown.Set(getPlayerList())
        notify("Players", "List refreshed", 2)
    end)

    addSpacer(pageTeleport)
    addSectionLabel(pageTeleport, "ACTIONS")

    addButton(pageTeleport, "Warp to target", function()
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Warp", "No target selected", 2)
            return
        end
        local hrp = getHRP()
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tHRP then
            hrp.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
            notify("Warp", "Teleported to " .. selectedPlayer.Name, 2)
        end
    end)

    addButton(pageTeleport, "Pull target to me", function()
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Pull", "No target", 2)
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
        notify("Pull", "Pulling " .. selectedPlayer.Name, 2)
        task.delay(1.5, function()
            if bp and bp.Parent then bp:Destroy() end
        end)
    end)

    addToggle(pageTeleport, "Freeze target", false, function(v)
        if not selectedPlayer or not selectedPlayer.Character then
            notify("Freeze", "No target", 2)
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
            notify("Freeze", selectedPlayer.Name .. " frozen", 2)
        else
            local f = tHRP:FindFirstChild("BomDevFreeze")
            if f then f:Destroy() end
            local a = tHRP:FindFirstChild("BomDevFreezeA")
            if a then a:Destroy() end
            notify("Freeze", "Unfrozen", 2)
        end
    end)

    addToggle(pageTeleport, "Spectate target", false, function(v)
        if specConn then specConn:Disconnect() specConn = nil end
        if v then
            if not selectedPlayer or not selectedPlayer.Character then
                notify("Spectate", "No target", 2)
                return
            end
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
                Camera.CameraType = Enum.CameraType.Custom
            end
            specConn = RunService.Heartbeat:Connect(function()
                if not v then return end
                if not selectedPlayer or not selectedPlayer.Parent then
                    Camera.CameraSubject = getHum()
                    return
                end
            end)
            notify("Spectate", "Watching " .. selectedPlayer.Name, 2)
        else
            Camera.CameraSubject = getHum()
            Camera.CameraType = Enum.CameraType.Custom
            notify("Spectate", "Off", 2)
        end
    end)

    addToggle(pageTeleport, "Follow target", false, function(v)
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
            notify("Follow", "Following " .. (selectedPlayer and selectedPlayer.Name or "?"), 2)
        else
            notify("Follow", "Off", 2)
        end
    end)

    addSpacer(pageTeleport)
    addSectionLabel(pageTeleport, "SAVED POSITIONS")

    for slot = 1, 5 do
        local slotRow = Instance.new("Frame")
        slotRow.Size = UDim2.new(1, -4, 0, 38)
        slotRow.BackgroundColor3 = DARK3
        slotRow.BorderSizePixel = 0
        slotRow.Parent = pageTeleport
        corner(slotRow, 8)

        local slotLbl = Instance.new("TextLabel")
        slotLbl.Size = UDim2.new(0.35, 0, 1, 0)
        slotLbl.Position = UDim2.new(0, 14, 0, 0)
        slotLbl.BackgroundTransparency = 1
        slotLbl.Text = "Slot " .. slot
        slotLbl.TextSize = 12
        slotLbl.Font = Enum.Font.GothamMedium
        slotLbl.TextColor3 = GREY
        slotLbl.TextXAlignment = Enum.TextXAlignment.Left
        slotLbl.Parent = slotRow

        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.28, -4, 0.7, 0)
        saveBtn.Position = UDim2.new(0.37, 0, 0.15, 0)
        saveBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
        saveBtn.BorderSizePixel = 0
        saveBtn.Text = "Save"
        saveBtn.TextSize = 11
        saveBtn.Font = Enum.Font.GothamMedium
        saveBtn.TextColor3 = GREEN
        saveBtn.Parent = slotRow
        corner(saveBtn, 4)

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.28, -4, 0.7, 0)
        tpBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "Warp"
        tpBtn.TextSize = 11
        tpBtn.Font = Enum.Font.GothamMedium
        tpBtn.TextColor3 = ACCENT2
        tpBtn.Parent = slotRow
        corner(tpBtn, 4)

        saveBtn.MouseButton1Click:Connect(function()
            local hrp = getHRP()
            if hrp then
                savedPos[slot] = hrp.CFrame
                notify("Saved", "Slot " .. slot .. " saved", 2)
                slotLbl.TextColor3 = GREEN
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
                notify("Warp", "Slot " .. slot .. " is empty", 2)
            end
        end)
    end

    addSpacer(pageTeleport)

    addButton(pageTeleport, "Teleport up 50 studs", function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0) end
    end)

    addButton(pageTeleport, "Teleport to 0 0 0", function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(0, 50, 0) end
    end)

    addButton(pageTeleport, "Random teleport", function()
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(math.random(-500,500), 100, math.random(-500,500))
        end
    end)
end

do
    addSectionLabel(pageUtils, "SERVER")

    addButton(pageUtils, "Rejoin server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    addButton(pageUtils, "Server hop", function()
        notify("Server Hop", "Finding new server...", 2)
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
            notify("Server Hop", "No empty servers found", 2)
        end)
    end)

    addButton(pageUtils, "Copy Place ID", function()
        safe(function() setclipboard(tostring(game.PlaceId)) end)
        notify("Copied", "Place ID: " .. game.PlaceId, 2)
    end)

    addButton(pageUtils, "Copy User ID", function()
        safe(function() setclipboard(tostring(LocalPlayer.UserId)) end)
        notify("Copied", "User ID: " .. LocalPlayer.UserId, 2)
    end)

    addButton(pageUtils, "Show server info", function()
        notify("Server Info",
            "Place: " .. game.PlaceId .. "  Players: " ..
            #Players:GetPlayers() .. "/" .. Players.MaxPlayers, 4)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "MUSIC")

    addInput(pageUtils, "Sound ID", "paste sound id (numbers only)", function(text)
        currentMusicId = text
    end)

    addButton(pageUtils, "Play music", function()
        if musicObj then musicObj:Stop() musicObj:Destroy() musicObj = nil end
        if currentMusicId == "" then notify("Music", "Enter a sound ID first", 2) return end
        local snd = Instance.new("Sound")
        snd.Name = "BomDevMusic"
        snd.SoundId = "rbxassetid://" .. currentMusicId
        snd.Volume = 0.5
        snd.Looped = true
        snd.Parent = LocalPlayer:WaitForChild("PlayerGui")
        snd:Play()
        musicObj = snd
        notify("Music", "Playing ID: " .. currentMusicId, 2)
    end)

    addButton(pageUtils, "Stop music", function()
        if musicObj then
            musicObj:Stop()
            musicObj:Destroy()
            musicObj = nil
        end
        notify("Music", "Stopped", 2)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "AUTO")

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
        notify("Auto Farm", v and "On" or "Off", 2)
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
        notify("Auto Respawn", v and "On" or "Off", 2)
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "WORLD")

    addInput(pageUtils, "Find and teleport to part", "part name", function(text)
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
        notify("Find", "Found " .. found .. " parts named '" .. text .. "'", 3)
        if closest then hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0)) end
    end)

    addSpacer(pageUtils)
    addSectionLabel(pageUtils, "DISCORD")

    addAccentButton(pageUtils, "Join BomDev Discord", function()
        safe(function()
            setclipboard(DISCORD_LINK)
        end)
        safe(function()
            game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK)
        end)
        notify("Discord", "Opened discord.gg/bakbom - also copied to clipboard", 4)
    end)
end

do
    addSectionLabel(pageSettings, "CAMERA")

    addSlider(pageSettings, "Field of View", 50, 120, 70, " deg", function(v)
        Camera.FieldOfView = v
    end)

    addButton(pageSettings, "FOV 70 (default)", function()
        Camera.FieldOfView = 70
    end)

    addButton(pageSettings, "FOV 110 (wide)", function()
        Camera.FieldOfView = 110
    end)

    addSpacer(pageSettings)
    addSectionLabel(pageSettings, "LIGHTING")

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
    addSectionLabel(pageSettings, "HOTKEYS (PC only)")

    local hotkeyInfo = Instance.new("TextLabel")
    hotkeyInfo.Size = UDim2.new(1, -4, 0, 100)
    hotkeyInfo.BackgroundColor3 = DARK3
    hotkeyInfo.BorderSizePixel = 0
    hotkeyInfo.Text = "F1  Fly toggle\nF2  Speed toggle\nF3  God mode toggle\nF4  NoClip toggle\n\nSpace  fly up\nLCtrl / LShift  fly down"
    hotkeyInfo.TextSize = 12
    hotkeyInfo.Font = Enum.Font.Code
    hotkeyInfo.TextColor3 = GREY
    hotkeyInfo.TextXAlignment = Enum.TextXAlignment.Left
    hotkeyInfo.TextYAlignment = Enum.TextYAlignment.Top
    hotkeyInfo.Parent = pageSettings
    corner(hotkeyInfo, 8)

    local hkPad = Instance.new("UIPadding")
    hkPad.PaddingLeft = UDim.new(0, 12)
    hkPad.PaddingTop = UDim.new(0, 8)
    hkPad.Parent = hotkeyInfo

    addSpacer(pageSettings)
    addSectionLabel(pageSettings, "ABOUT")

    local aboutBox = Instance.new("TextLabel")
    aboutBox.Size = UDim2.new(1, -4, 0, 80)
    aboutBox.BackgroundColor3 = DARK3
    aboutBox.BorderSizePixel = 0
    aboutBox.Text = "BomDev Hub  v2.2\n\nDev: BomDev\nDiscord: discord.gg/bakbom\n\nFly direction fixed - follows camera 100%"
    aboutBox.TextSize = 12
    aboutBox.Font = Enum.Font.Gotham
    aboutBox.TextColor3 = GREY
    aboutBox.TextXAlignment = Enum.TextXAlignment.Left
    aboutBox.TextYAlignment = Enum.TextYAlignment.Top
    aboutBox.Parent = pageSettings
    corner(aboutBox, 8)

    local abPad = Instance.new("UIPadding")
    abPad.PaddingLeft = UDim.new(0, 12)
    abPad.PaddingTop = UDim.new(0, 8)
    abPad.Parent = aboutBox
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F1 then
        flyEnabled = not flyEnabled
        local fakeToggle = {setState = function() end}
        if flyEnabled then
            flyEnabled = false
        end
        flyEnabled = not flyEnabled
        local ev = {flyEnabled}
    end
    if inp.KeyCode == Enum.KeyCode.F2 then
        speedEnabled = not speedEnabled
        local hum = getHum()
        if hum then hum.WalkSpeed = speedEnabled and speedValue or 16 end
        notify("Speed", speedEnabled and "On" or "Off", 1)
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
        notify("God Mode", godEnabled and "On" or "Off", 1)
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
        notify("NoClip", noclipEnabled and "On" or "Off", 1)
    end
    if inp.KeyCode == Enum.KeyCode.RightBracket then
        MainFrame.Visible = not MainFrame.Visible
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
        hl.FillColor = ACCENT
        hl.FillTransparency = 0.7
        hl.OutlineColor = ACCENT2
        hl.OutlineTransparency = 0
        hl.Parent = char
    end
end)

task.defer(function()
    navBtns["Movement"].btn.MouseButton1Click:Fire()
end)

task.spawn(function()
    task.wait(0.5)
    notify("BomDev Hub", "โหลดสำเร็จ! Dev: BomDev  |  ] เพื่อซ่อน/แสดง", 4)
end)
