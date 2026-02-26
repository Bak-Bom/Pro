local BomDev = {}
BomDev.__index = BomDev

local TweenService  = game:GetService("TweenService")
local CoreGui       = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")

local Theme = {
    Background    = Color3.fromRGB(10, 10, 18),
    Surface       = Color3.fromRGB(16, 16, 28),
    SurfaceAlt    = Color3.fromRGB(22, 22, 38),
    Accent        = Color3.fromRGB(90, 160, 255),
    AccentHover   = Color3.fromRGB(110, 180, 255),
    AccentDim     = Color3.fromRGB(50, 90, 160),
    Success       = Color3.fromRGB(60, 200, 120),
    Warning       = Color3.fromRGB(255, 190, 60),
    Danger        = Color3.fromRGB(255, 80, 80),
    Text          = Color3.fromRGB(225, 230, 245),
    TextDim       = Color3.fromRGB(140, 150, 175),
    TextAccent    = Color3.fromRGB(90, 160, 255),
    Border        = Color3.fromRGB(40, 45, 70),
    BorderAccent  = Color3.fromRGB(70, 110, 200),
    Toggle_ON     = Color3.fromRGB(60, 200, 120),
    Toggle_OFF    = Color3.fromRGB(50, 50, 80),
    Shadow        = Color3.fromRGB(0, 0, 0),
    Gradient1     = Color3.fromRGB(90, 50, 200),
    Gradient2     = Color3.fromRGB(40, 130, 255),
}

local function tween(obj, goals, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, goals):Play()
end

local function addCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1.5
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function addGradient(parent, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0),
        ColorSequenceKeypoint.new(1, c1),
    })
    g.Rotation = rot or 90
    g.Parent = parent
    return g
end

local function addPadding(parent, px)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, px)
    p.PaddingRight  = UDim.new(0, px)
    p.PaddingTop    = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.Parent = parent
    return p
end

local function addListLayout(parent, dir, padding)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, padding or 0)
    l.Parent = parent
    return l
end

local function autoResize(layout, frame, extraH)
    local extra = extraH or 0
    local function upd()
        frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset,
                               0, layout.AbsoluteContentSize.Y + extra)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

local Icons = {
    ["plane"]         = "✈",
    ["zap"]           = "⚡",
    ["shield"]        = "🛡",
    ["eye"]           = "👁",
    ["layers"]        = "◈",
    ["crosshair"]     = "✚",
    ["sword"]         = "⚔️",
    ["box"]           = "📦",
    ["map-pin"]       = "📍",
    ["wrench"]        = "🔧",
    ["download"]      = "📥",
    ["info"]          = "ℹ",
    ["alert-triangle"]= "⚠",
    ["moon"]          = "🌙",
    ["sun"]           = "☀️",
    ["globe"]         = "🌍",
    ["rocket"]        = "🚀",
    ["cpu"]           = "🤖",
    ["clock"]         = "🕐",
    ["trash"]         = "🗑",
    ["music"]         = "🎵",
    ["star"]          = "⭐",
    ["sparkles"]      = "✨",
    ["flame"]         = "🔥",
    ["shuffle"]       = "🔀",
    ["refresh-cw"]    = "🔄",
    ["clipboard"]     = "📋",
    ["bar-chart"]     = "📊",
    ["search"]        = "🔍",
    ["save"]          = "💾",
    ["arrow-up"]      = "⬆",
    ["message-circle"]= "💬",
    ["user"]          = "👤",
    ["play"]          = "▶",
    ["palette"]       = "🎨",
    ["ghost"]         = "👻",
}

local function getIcon(name)
    return Icons[name] or "●"
end

function BomDev:CreateWindow(config)
    local self = setmetatable({}, BomDev)
    self._tabs = {}
    self._activeTab = nil
    self._flags = {}
    self._dragging = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BomDevUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 999

    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if not ok then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = ScreenGui

    local loadFrame = Instance.new("Frame")
    loadFrame.Name = "LoadScreen"
    loadFrame.Size = UDim2.fromScale(1, 1)
    loadFrame.BackgroundColor3 = Theme.Background
    loadFrame.BorderSizePixel = 0
    loadFrame.ZIndex = 1000
    loadFrame.Parent = ScreenGui

    local loadInner = Instance.new("Frame")
    loadInner.AnchorPoint = Vector2.new(0.5, 0.5)
    loadInner.Position = UDim2.fromScale(0.5, 0.5)
    loadInner.Size = UDim2.fromOffset(340, 140)
    loadInner.BackgroundColor3 = Theme.Surface
    loadInner.BorderSizePixel = 0
    loadInner.ZIndex = 1001
    loadInner.Parent = loadFrame
    addCorner(loadInner, 16)
    addStroke(loadInner, Theme.BorderAccent, 1.5)

    local loadGrad = addGradient(loadInner, Theme.Gradient1, Color3.fromRGB(10,14,24), 135)

    local loadTitle = Instance.new("TextLabel")
    loadTitle.Size = UDim2.new(1,0,0,42)
    loadTitle.Position = UDim2.new(0,0,0,14)
    loadTitle.BackgroundTransparency = 1
    loadTitle.Text = "⚡ " .. (config.LoadingTitle or "BomDev Hub")
    loadTitle.TextSize = 22
    loadTitle.Font = Enum.Font.GothamBold
    loadTitle.TextColor3 = Theme.Text
    loadTitle.ZIndex = 1002
    loadTitle.Parent = loadInner

    local loadSub = Instance.new("TextLabel")
    loadSub.Size = UDim2.new(1,0,0,22)
    loadSub.Position = UDim2.new(0,0,0,52)
    loadSub.BackgroundTransparency = 1
    loadSub.Text = config.LoadingSubtitle or "Dev : BomDev  |  v7.0"
    loadSub.TextSize = 13
    loadSub.Font = Enum.Font.Gotham
    loadSub.TextColor3 = Theme.TextDim
    loadSub.ZIndex = 1002
    loadSub.Parent = loadInner

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -40, 0, 6)
    barBg.Position = UDim2.new(0, 20, 0, 88)
    barBg.BackgroundColor3 = Theme.SurfaceAlt
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 1002
    barBg.Parent = loadInner
    addCorner(barBg, 3)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 1003
    barFill.Parent = barBg
    addCorner(barFill, 3)
    addGradient(barFill, Theme.Gradient1, Theme.Gradient2, 90)

    task.spawn(function()
        tween(barFill, {Size = UDim2.new(1, 0, 1, 0)}, 1.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        task.wait(1.5)
        tween(loadFrame, {BackgroundTransparency = 1}, 0.4)
        tween(loadInner, {BackgroundTransparency = 1}, 0.4)
        for _, d in ipairs(loadInner:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, {TextTransparency = 1}, 0.3) end
            if d:IsA("Frame") then tween(d, {BackgroundTransparency = 1}, 0.3) end
            if d:IsA("UIStroke") then tween(d, {Transparency = 1}, 0.3) end
        end
        task.wait(0.45)
        loadFrame:Destroy()
    end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromOffset(700, 500)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 14)
    addStroke(MainFrame, Theme.BorderAccent, 1.5)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundColor3 = Theme.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = MainFrame
    addGradient(TitleBar, Theme.Gradient1, Color3.fromRGB(16, 18, 32), 90)

    local TitleBarStroke = Instance.new("Frame")
    TitleBarStroke.Size = UDim2.new(1, 0, 0, 1)
    TitleBarStroke.Position = UDim2.new(0, 0, 1, -1)
    TitleBarStroke.BackgroundColor3 = Theme.BorderAccent
    TitleBarStroke.BackgroundTransparency = 0.5
    TitleBarStroke.BorderSizePixel = 0
    TitleBarStroke.ZIndex = 3
    TitleBarStroke.Parent = TitleBar

    local TitleLogo = Instance.new("TextLabel")
    TitleLogo.Size = UDim2.new(0, 36, 0, 36)
    TitleLogo.Position = UDim2.new(0, 12, 0.5, -18)
    TitleLogo.BackgroundColor3 = Theme.Accent
    TitleLogo.BackgroundTransparency = 0.2
    TitleLogo.Text = "BD"
    TitleLogo.TextSize = 14
    TitleLogo.Font = Enum.Font.GothamBlack
    TitleLogo.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLogo.ZIndex = 3
    TitleLogo.Parent = TitleBar
    addCorner(TitleLogo, 8)

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 280, 1, 0)
    TitleText.Position = UDim2.new(0, 56, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = config.Name or " BomDev Hub"
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextColor3 = Theme.Text
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 3
    TitleText.Parent = TitleBar

    local BadgeDev = Instance.new("TextLabel")
    BadgeDev.Size = UDim2.new(0, 90, 0, 22)
    BadgeDev.Position = UDim2.new(0, 56, 0.5, -11)
    BadgeDev.AnchorPoint = Vector2.new(0, 0)
    BadgeDev.BackgroundColor3 = Theme.AccentDim
    BadgeDev.Text = "DEV: BOMDEV"
    BadgeDev.TextSize = 9
    BadgeDev.Font = Enum.Font.GothamBold
    BadgeDev.TextColor3 = Theme.Accent
    BadgeDev.ZIndex = 3

    BadgeDev.Position = UDim2.new(0, 340, 0.5, -11)
    BadgeDev.Size = UDim2.new(0, 100, 0, 20)
    BadgeDev.Parent = TitleBar
    addCorner(BadgeDev, 5)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Text = "✕"
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.ZIndex = 4
    CloseBtn.Parent = TitleBar
    addCorner(CloseBtn, 8)

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(220, 50, 50)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.fromOffset(700, 0), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -82, 0.5, -16)
    MinBtn.BackgroundColor3 = Theme.SurfaceAlt
    MinBtn.BackgroundTransparency = 0.3
    MinBtn.Text = "─"
    MinBtn.TextSize = 14
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = Theme.TextDim
    MinBtn.ZIndex = 4
    MinBtn.Parent = TitleBar
    addCorner(MinBtn, 8)

    local minimized = false
    local ContentArea
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(MainFrame, {Size = UDim2.fromOffset(700, 52)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            MinBtn.Text = "×"
        else
            tween(MainFrame, {Size = UDim2.fromOffset(700, 500)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            MinBtn.Text = "─"
        end
    end)

    do
        local dragStart, startPos
        TitleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragStart = inp.Position
                startPos  = MainFrame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragStart = nil
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not dragStart then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                local delta = inp.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 155, 1, -52)
    TabBar.Position = UDim2.new(0, 0, 0, 52)
    TabBar.BackgroundColor3 = Theme.Surface
    TabBar.BorderSizePixel = 0
    TabBar.ClipsDescendants = true
    TabBar.Parent = MainFrame

    local TabBarStroke = Instance.new("Frame")
    TabBarStroke.Size = UDim2.new(0, 1, 1, 0)
    TabBarStroke.Position = UDim2.new(1, -1, 0, 0)
    TabBarStroke.BackgroundColor3 = Theme.Border
    TabBarStroke.BorderSizePixel = 0
    TabBarStroke.Parent = TabBar

    local TabBarInner = Instance.new("Frame")
    TabBarInner.Name = "TabBarInner"
    TabBarInner.Size = UDim2.new(1, 0, 0, 0)
    TabBarInner.BackgroundTransparency = 1
    TabBarInner.AutomaticSize = Enum.AutomaticSize.Y
    TabBarInner.Parent = TabBar
    addListLayout(TabBarInner, Enum.FillDirection.Vertical, 3)
    addPadding(TabBarInner, 8)

    local TabLogo = Instance.new("TextLabel")
    TabLogo.Size = UDim2.new(1, 0, 0, 38)
    TabLogo.Position = UDim2.new(0, 0, 1, -42)
    TabLogo.BackgroundTransparency = 1
    TabLogo.Text = "BomDev"
    TabLogo.TextSize = 10
    TabLogo.Font = Enum.Font.GothamBold
    TabLogo.TextColor3 = Theme.AccentDim
    TabLogo.Parent = TabBar

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Size = UDim2.new(1, -155, 1, -52)
    ContentScroll.Position = UDim2.new(0, 155, 0, 52)
    ContentScroll.BackgroundColor3 = Theme.Background
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 3
    ContentScroll.ScrollBarImageColor3 = Theme.AccentDim
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentScroll.Parent = MainFrame

    ContentArea = ContentScroll

    local ContentInner = Instance.new("Frame")
    ContentInner.Name = "ContentInner"
    ContentInner.Size = UDim2.new(1, 0, 0, 0)
    ContentInner.AutomaticSize = Enum.AutomaticSize.Y
    ContentInner.BackgroundTransparency = 1
    ContentInner.Parent = ContentScroll
    addListLayout(ContentInner, Enum.FillDirection.Vertical, 5)
    addPadding(ContentInner, 10)

    self.MainFrame    = MainFrame
    self.TabBarInner  = TabBarInner
    self.ContentInner = ContentInner
    self.ContentScroll= ContentScroll
    self.ScreenGui    = ScreenGui

    MainFrame.Size = UDim2.fromOffset(700, 0)
    tween(MainFrame, {Size = UDim2.fromOffset(700, 500)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return self
end

function BomDev:CreateTab(name, icon)
    local tabData = {}
    tabData._name = name
    tabData._elements = {}

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = "Tab_" .. name
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.SurfaceAlt
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.BorderSizePixel = 0
    TabBtn.ZIndex = 2
    TabBtn.Parent = self.TabBarInner

    local TabBtnCorner = addCorner(TabBtn, 8)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 22, 1, 0)
    iconLbl.Position = UDim2.new(0, 10, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = getIcon(icon or "star")
    iconLbl.TextSize = 15
    iconLbl.Font = Enum.Font.Gotham
    iconLbl.TextColor3 = Theme.TextDim
    iconLbl.ZIndex = 3
    iconLbl.Parent = TabBtn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -44, 1, 0)
    nameLbl.Position = UDim2.new(0, 38, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextColor3 = Theme.TextDim
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 3
    nameLbl.Parent = TabBtn

    local ActiveBar = Instance.new("Frame")
    ActiveBar.Size = UDim2.new(0, 3, 0.6, 0)
    ActiveBar.Position = UDim2.new(0, 1, 0.2, 0)
    ActiveBar.BackgroundColor3 = Theme.Accent
    ActiveBar.BackgroundTransparency = 1
    ActiveBar.BorderSizePixel = 0
    ActiveBar.ZIndex = 3
    ActiveBar.Parent = TabBtn
    addCorner(ActiveBar, 2)

    local Page = Instance.new("Frame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 0, 0)
    Page.AutomaticSize = Enum.AutomaticSize.Y
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = self.ContentInner
    tabData.Page = Page

    local function activate()
        for _, td in ipairs(self._tabs) do
            td.Page.Visible = false
            tween(td._activeBar,   {BackgroundTransparency = 1}, 0.15)
            tween(td._tabBtn,      {BackgroundTransparency = 1}, 0.15)
            tween(td._nameLbl,     {TextColor3 = Theme.TextDim}, 0.15)
            tween(td._iconLbl,     {TextColor3 = Theme.TextDim}, 0.15)
        end
        Page.Visible = true
        tween(ActiveBar, {BackgroundTransparency = 0}, 0.2)
        tween(TabBtn,    {BackgroundTransparency = 0.75}, 0.2)
        tween(nameLbl,   {TextColor3 = Theme.Accent}, 0.2)
        tween(iconLbl,   {TextColor3 = Theme.Accent}, 0.2)
        nameLbl.Font = Enum.Font.GothamBold
        self._activeTab = tabData
    end

    TabBtn.MouseButton1Click:Connect(activate)
    TabBtn.MouseEnter:Connect(function()
        if self._activeTab ~= tabData then
            tween(TabBtn, {BackgroundTransparency = 0.88}, 0.1)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if self._activeTab ~= tabData then
            tween(TabBtn, {BackgroundTransparency = 1}, 0.1)
        end
    end)

    tabData._tabBtn   = TabBtn
    tabData._activeBar= ActiveBar
    tabData._nameLbl  = nameLbl
    tabData._iconLbl  = iconLbl
    tabData._activate = activate
    tabData._win      = self

    if #self._tabs == 0 then
        task.defer(activate)
    end

    table.insert(self._tabs, tabData)

    function tabData:CreateSection(title)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, 0, 0, 32)
        sec.BackgroundTransparency = 1
        sec.BorderSizePixel = 0
        sec.Parent = self.Page

        local line1 = Instance.new("Frame")
        line1.Size = UDim2.new(0.18, 0, 0, 1)
        line1.Position = UDim2.new(0, 0, 0.5, 0)
        line1.BackgroundColor3 = Theme.Border
        line1.BorderSizePixel = 0
        line1.Parent = sec

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0.2, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Theme.TextDim
        lbl.Parent = sec

        local line2 = Instance.new("Frame")
        line2.Size = UDim2.new(0.18, 0, 0, 1)
        line2.Position = UDim2.new(0.82, 0, 0.5, 0)
        line2.BackgroundColor3 = Theme.Border
        line2.BorderSizePixel = 0
        line2.Parent = sec
    end

    function tabData:CreateButton(config)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Theme.SurfaceAlt
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = self.Page
        addCorner(btn, 8)
        addStroke(btn, Theme.Border, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = config.Name or "Button"
        lbl.TextSize = 13
        lbl.Font = Enum.Font.Gotham
        lbl.TextColor3 = Theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn

        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.AccentDim}, 0.12)
            tween(lbl, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.SurfaceAlt}, 0.12)
            tween(lbl, {TextColor3 = Theme.Text}, 0.12)
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.Accent}, 0.08)
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, {BackgroundColor3 = Theme.AccentDim}, 0.08)
        end)
        btn.MouseButton1Click:Connect(function()
            if config.Callback then pcall(config.Callback) end
        end)
    end

    function tabData:CreateToggle(config)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = Theme.SurfaceAlt
        row.BorderSizePixel = 0
        row.Parent = self.Page
        addCorner(row, 8)
        addStroke(row, Theme.Border, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -64, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = config.Name or "Toggle"
        lbl.TextSize = 13
        lbl.Font = Enum.Font.Gotham
        lbl.TextColor3 = Theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 44, 0, 24)
        track.Position = UDim2.new(1, -58, 0.5, -12)
        track.BackgroundColor3 = Theme.Toggle_OFF
        track.BorderSizePixel = 0
        track.Parent = row
        addCorner(track, 12)

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 18, 0, 18)
        thumb.Position = UDim2.new(0, 3, 0.5, -9)
        thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
        thumb.BorderSizePixel = 0
        thumb.Parent = track
        addCorner(thumb, 9)

        local val = config.CurrentValue or false
        if self._win and self._win._flags and config.Flag then
            self._win._flags[config.Flag] = val
        end

        local function setVal(v)
            val = v
            if self._win and self._win._flags and config.Flag then
                self._win._flags[config.Flag] = v
            end
            if v then
                tween(track, {BackgroundColor3 = Theme.Toggle_ON}, 0.2)
                tween(thumb, {Position = UDim2.new(0, 23, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            else
                tween(track, {BackgroundColor3 = Theme.Toggle_OFF}, 0.2)
                tween(thumb, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(200, 200, 215)}, 0.2)
            end
            if config.Callback then pcall(config.Callback, v) end
        end

        if val then setVal(true) end

        row.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                setVal(not val)
            end
        end)
        row.MouseEnter:Connect(function() tween(row, {BackgroundColor3 = Color3.fromRGB(26,26,44)}, 0.12) end)
        row.MouseLeave:Connect(function() tween(row, {BackgroundColor3 = Theme.SurfaceAlt}, 0.12) end)
    end

    function tabData:CreateSlider(config)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 58)
        row.BackgroundColor3 = Theme.SurfaceAlt
        row.BorderSizePixel = 0
        row.Parent = self.Page
        addCorner(row, 8)
        addStroke(row, Theme.Border, 1)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(0.6, 0, 0, 22)
        titleLbl.Position = UDim2.new(0, 14, 0, 8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = config.Name or "Slider"
        titleLbl.TextSize = 13
        titleLbl.Font = Enum.Font.Gotham
        titleLbl.TextColor3 = Theme.Text
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = row

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.4, -14, 0, 22)
        valLbl.Position = UDim2.new(0.6, 0, 0, 8)
        valLbl.BackgroundTransparency = 1
        valLbl.TextSize = 12
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextColor3 = Theme.Accent
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -28, 0, 6)
        track.Position = UDim2.new(0, 14, 0, 38)
        track.BackgroundColor3 = Color3.fromRGB(30, 32, 55)
        track.BorderSizePixel = 0
        track.Parent = row
        addCorner(track, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        addCorner(fill, 3)
        addGradient(fill, Theme.Gradient1, Theme.Gradient2, 90)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0, 0, 0.5, 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = track
        addCorner(dot, 7)

        local Range = config.Range or {0, 100}
        local Incr  = config.Increment or 1
        local Sfx   = config.Suffix or ""
        local curVal = config.CurrentValue or Range[1]

        local function setSlider(v)
            v = math.clamp(math.round(v / Incr) * Incr, Range[1], Range[2])
            curVal = v
            if config.Flag and self._win and self._win._flags then
                self._win._flags[config.Flag] = v
            end
            local pct = (v - Range[1]) / (Range[2] - Range[1])
            tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
            tween(dot,  {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.1)
            valLbl.Text = tostring(v) .. Sfx
            if config.Callback then pcall(config.Callback, v) end
        end

        setSlider(curVal)

        local dragging = false
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                local abs  = track.AbsolutePosition
                local size = track.AbsoluteSize
                local pct  = math.clamp((inp.Position.X - abs.X) / size.X, 0, 1)
                local v    = Range[1] + pct * (Range[2] - Range[1])
                setSlider(v)
            end
        end)
    end

    function tabData:CreateInput(config)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 56)
        row.BackgroundColor3 = Theme.SurfaceAlt
        row.BorderSizePixel = 0
        row.Parent = self.Page
        addCorner(row, 8)
        addStroke(row, Theme.Border, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 20)
        lbl.Position = UDim2.new(0, 14, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = config.Name or "Input"
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Theme.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -28, 0, 28)
        box.Position = UDim2.new(0, 14, 0, 24)
        box.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
        box.Text = ""
        box.PlaceholderText = config.PlaceholderText or "Type here..."
        box.PlaceholderColor3 = Theme.TextDim
        box.TextSize = 13
        box.Font = Enum.Font.Gotham
        box.TextColor3 = Theme.Text
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.BorderSizePixel = 0
        box.ClearTextOnFocus = false
        box.Parent = row
        addCorner(box, 6)
        addStroke(box, Theme.BorderAccent, 1, 0.5)
        addPadding(box, 6)

        box.FocusLost:Connect(function(enter)
            if config.Callback then pcall(config.Callback, box.Text) end
            if config.RemoveTextAfterFocusLost then box.Text = "" end
            tween(box, {BackgroundColor3 = Color3.fromRGB(14, 14, 26)}, 0.15)
        end)
        box.Focused:Connect(function()
            tween(box, {BackgroundColor3 = Color3.fromRGB(18, 20, 38)}, 0.15)
        end)
    end

    function tabData:CreateDropdown(config)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 56)
        row.BackgroundColor3 = Theme.SurfaceAlt
        row.BorderSizePixel = 0
        row.ZIndex = 10
        row.Parent = self.Page
        addCorner(row, 8)
        addStroke(row, Theme.Border, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0, 20)
        lbl.Position = UDim2.new(0, 14, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = config.Name or "Dropdown"
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Theme.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 11
        lbl.Parent = row

        local selBtn = Instance.new("TextButton")
        selBtn.Size = UDim2.new(1, -28, 0, 28)
        selBtn.Position = UDim2.new(0, 14, 0, 24)
        selBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
        local opts = config.CurrentOption or {"Select..."}
        selBtn.Text = (type(opts) == "table" and opts[1] or opts) .. "  ▾"
        selBtn.TextSize = 13
        selBtn.Font = Enum.Font.Gotham
        selBtn.TextColor3 = Theme.Text
        selBtn.BorderSizePixel = 0
        selBtn.ZIndex = 11
        selBtn.Parent = row
        addCorner(selBtn, 6)
        addStroke(selBtn, Theme.BorderAccent, 1, 0.5)

        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(1, -28, 0, 0)
        dropdown.Position = UDim2.new(0, 14, 1, 4)
        dropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
        dropdown.BorderSizePixel = 0
        dropdown.ClipsDescendants = true
        dropdown.ZIndex = 20
        dropdown.Visible = false
        dropdown.Parent = row
        addCorner(dropdown, 8)
        addStroke(dropdown, Theme.BorderAccent, 1)

        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, 0)
        listFrame.AutomaticSize = Enum.AutomaticSize.Y
        listFrame.BackgroundTransparency = 1
        listFrame.ZIndex = 21
        listFrame.Parent = dropdown
        addListLayout(listFrame, Enum.FillDirection.Vertical, 2)
        addPadding(listFrame, 5)

        local open = false
        local Options = config.Options or {}

        local function buildList()
            for _, c in ipairs(listFrame:GetChildren()) do
                if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
            end
            for _, opt in ipairs(Options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, 0, 0, 32)
                ob.BackgroundColor3 = Color3.fromRGB(24, 24, 42)
                ob.BackgroundTransparency = 0.5
                ob.Text = opt
                ob.TextSize = 13
                ob.Font = Enum.Font.Gotham
                ob.TextColor3 = Theme.Text
                ob.BorderSizePixel = 0
                ob.ZIndex = 22
                ob.Parent = listFrame
                addCorner(ob, 6)
                ob.MouseEnter:Connect(function() tween(ob, {BackgroundColor3 = Theme.AccentDim, BackgroundTransparency = 0}, 0.1) end)
                ob.MouseLeave:Connect(function() tween(ob, {BackgroundColor3 = Color3.fromRGB(24,24,42), BackgroundTransparency = 0.5}, 0.1) end)
                ob.MouseButton1Click:Connect(function()
                    selBtn.Text = opt .. "  ▾"
                    open = false
                    tween(dropdown, {Size = UDim2.new(1, -28, 0, 0)}, 0.18)
                    task.wait(0.2)
                    dropdown.Visible = false
                    row.Size = UDim2.new(1, 0, 0, 56)
                    if config.Callback then pcall(config.Callback, opt) end
                end)
            end
        end
        buildList()

        selBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                dropdown.Visible = true
                local h = math.min(#Options * 38 + 10, 200)
                tween(dropdown, {Size = UDim2.new(1, -28, 0, h)}, 0.2)
                row.Size = UDim2.new(1, 0, 0, 56 + h + 8)
            else
                tween(dropdown, {Size = UDim2.new(1, -28, 0, 0)}, 0.18)
                task.wait(0.2)
                dropdown.Visible = false
                row.Size = UDim2.new(1, 0, 0, 56)
            end
        end)
    end

    return tabData
end

function BomDev:Notify(config)
    local gui = self.ScreenGui
    if not gui or not gui.Parent then return end

    local container = gui:FindFirstChild("NotifContainer")
    if not container then
        container = Instance.new("Frame")
        container.Name = "NotifContainer"
        container.AnchorPoint = Vector2.new(1, 1)
        container.Position = UDim2.new(1, -14, 1, -14)
        container.Size = UDim2.new(0, 310, 1, -14)
        container.BackgroundTransparency = 1
        container.Parent = gui
        addListLayout(container, Enum.FillDirection.Vertical, 6)
        container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 70)
    notif.BackgroundColor3 = Theme.Surface
    notif.BackgroundTransparency = 0.08
    notif.BorderSizePixel = 0
    notif.Position = UDim2.new(1.2, 0, 0, 0)
    notif.Parent = container
    addCorner(notif, 10)
    addStroke(notif, Theme.BorderAccent, 1.5)

    local acBar = Instance.new("Frame")
    acBar.Size = UDim2.new(0, 3, 0.7, 0)
    acBar.Position = UDim2.new(0, 0, 0.15, 0)
    acBar.BackgroundColor3 = Theme.Accent
    acBar.BorderSizePixel = 0
    acBar.Parent = notif
    addCorner(acBar, 2)
    addGradient(acBar, Theme.Gradient1, Theme.Gradient2, 90)

    local icoLbl = Instance.new("TextLabel")
    icoLbl.Size = UDim2.new(0, 28, 0, 28)
    icoLbl.Position = UDim2.new(0, 14, 0.5, -14)
    icoLbl.BackgroundColor3 = Theme.AccentDim
    icoLbl.BackgroundTransparency = 0.3
    icoLbl.Text = getIcon(config.Image or "info")
    icoLbl.TextSize = 14
    icoLbl.Font = Enum.Font.Gotham
    icoLbl.TextColor3 = Theme.Accent
    icoLbl.BorderSizePixel = 0
    icoLbl.Parent = notif
    addCorner(icoLbl, 8)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -64, 0, 22)
    titleLbl.Position = UDim2.new(0, 50, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = config.Title or "BomDev"
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -64, 0, 30)
    contentLbl.Position = UDim2.new(0, 50, 0, 30)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text = config.Content or ""
    contentLbl.TextSize = 11
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextColor3 = Theme.TextDim
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true
    contentLbl.Parent = notif

    local pbarBg = Instance.new("Frame")
    pbarBg.Size = UDim2.new(1, -16, 0, 2)
    pbarBg.Position = UDim2.new(0, 8, 1, -4)
    pbarBg.BackgroundColor3 = Theme.Border
    pbarBg.BorderSizePixel = 0
    pbarBg.Parent = notif
    addCorner(pbarBg, 1)

    local pbar = Instance.new("Frame")
    pbar.Size = UDim2.new(1, 0, 1, 0)
    pbar.BackgroundColor3 = Theme.Accent
    pbar.BorderSizePixel = 0
    pbar.Parent = pbarBg
    addCorner(pbar, 1)

    tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local dur = config.Duration or 3
    tween(pbar, {Size = UDim2.new(0, 0, 1, 0)}, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        tween(notif, {Position = UDim2.new(1.2, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
end

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local TeleportSvc   = game:GetService("TeleportService")
local HttpService   = game:GetService("HttpService")
local GuiService    = game:GetService("GuiService")
local Lighting      = game:GetService("Lighting")
local VirtualUser   = game:GetService("VirtualUser")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

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

local function safe(fn, ...) pcall(fn, ...) end
local function char()   return LP.Character end
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

local Window = BomDev:CreateWindow({
    Name             = "⚡ BomDev Hub",
    LoadingTitle     = "BomDev Hub",
    LoadingSubtitle  = "Dev : BomDev ",
})

local function notify(title, content, duration, icon)
    BomDev:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 2,
        Image    = icon or "info",
    })
end

local tabMove = Window:CreateTab("Movement",  "plane")
local tabComb = Window:CreateTab("Combat",    "sword")
local tabVis  = Window:CreateTab("Visual",    "eye")
local tabPlay = Window:CreateTab("Player",    "user")
local tabTele = Window:CreateTab("Teleport",  "map-pin")
local tabUtil = Window:CreateTab("Utils",     "wrench")
local tabDl   = Window:CreateTab("Download",  "download")

local FlyJoyGui = nil
local joyActive = false
local joyCenter = Vector2.zero
local joyDelta  = Vector2.zero
local flyBtnUp  = false
local flyBtnDown= false
local JOY_R     = 65

local function destroyJoystick()
    if FlyJoyGui then FlyJoyGui:Destroy(); FlyJoyGui = nil end
    joyActive = false; joyDelta = Vector2.zero
    flyBtnUp = false; flyBtnDown = false
end

local function createJoystick()
    destroyJoystick()
    local sg = Instance.new("ScreenGui")
    sg.Name="BomDevFlyJoy"; sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true; sg.DisplayOrder=200
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    FlyJoyGui = sg

    local baseFrame = Instance.new("Frame")
    baseFrame.AnchorPoint = Vector2.new(0, 1)
    baseFrame.Size = UDim2.fromOffset(JOY_R*2, JOY_R*2)
    baseFrame.Position = UDim2.new(0, 20, 1, -100)
    baseFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    baseFrame.BackgroundTransparency = 0.45
    baseFrame.BorderSizePixel = 0; baseFrame.ZIndex = 200
    baseFrame.Parent = sg
    addCorner(baseFrame, JOY_R)
    addStroke(baseFrame, Color3.fromRGB(80,160,255), 2, 0.2)

    local THUMB_R = JOY_R * 0.45
    local thumb = Instance.new("Frame")
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Size = UDim2.fromOffset(THUMB_R*2, THUMB_R*2)
    thumb.Position = UDim2.new(0.5, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    thumb.BackgroundTransparency = 0.15
    thumb.BorderSizePixel = 0; thumb.ZIndex = 201
    thumb.Parent = baseFrame
    addCorner(thumb, THUMB_R)

    local lbl = Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,16); lbl.Position=UDim2.new(0,0,-0.28,0)
    lbl.BackgroundTransparency=1; lbl.Text="✈ FLY"; lbl.TextSize=11
    lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.fromRGB(80,160,255)
    lbl.ZIndex=201; lbl.Parent=baseFrame

    local function mkBtn(lbTxt, anchorY, posOffY, onPress)
        local btn = Instance.new("TextButton")
        btn.AnchorPoint=Vector2.new(0, anchorY)
        btn.Size=UDim2.fromOffset(58, 58)
        btn.Position=UDim2.new(0, 20+JOY_R*2+18, 1, posOffY)
        btn.BackgroundColor3=Color3.fromRGB(20,20,20)
        btn.BackgroundTransparency=0.45; btn.Text=lbTxt
        btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=22
        btn.Font=Enum.Font.GothamBold; btn.BorderSizePixel=0
        btn.ZIndex=200; btn.Parent=sg
        addCorner(btn, 14)
        addStroke(btn, Color3.fromRGB(80,160,255), 2, 0.2)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then onPress(true) end
        end)
        btn.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then onPress(false) end
        end)
    end

    mkBtn("⬆", 1, -170, function(v) flyBtnUp=v end)
    mkBtn("⬇", 1, -102, function(v) flyBtnDown=v end)

    local ib = UIS.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if not baseFrame or not baseFrame.Parent then return end
        local abs=baseFrame.AbsolutePosition; local sz=baseFrame.AbsoluteSize
        local center=abs+sz/2
        local tp=Vector2.new(inp.Position.X, inp.Position.Y)
        if (tp-center).Magnitude <= JOY_R then
            joyActive=true; joyCenter=center
        end
    end)
    local ic = UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if not joyActive then return end
        local tp=Vector2.new(inp.Position.X, inp.Position.Y)
        local delta=tp-joyCenter
        if delta.Magnitude>JOY_R then delta=delta.Unit*JOY_R end
        joyDelta=delta/JOY_R
        if thumb and thumb.Parent then
            thumb.Position=UDim2.fromOffset(JOY_R+delta.X-THUMB_R, JOY_R+delta.Y-THUMB_R)
        end
    end)
    local ie = UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        joyActive=false; joyDelta=Vector2.zero
        if thumb and thumb.Parent then thumb.Position=UDim2.new(0.5,-THUMB_R,0.5,-THUMB_R) end
    end)
    sg.Destroying:Connect(function()
        pcall(function() ib:Disconnect() end)
        pcall(function() ic:Disconnect() end)
        pcall(function() ie:Disconnect() end)
    end)
end

local function startFly()
    local c=char(); if not c then return end
    local r=hrp(); if not r then return end
    local h=hum(); if not h then return end
    for _,n in ipairs({"BDFlyBV","BDFlyBG"}) do
        local ex=r:FindFirstChild(n); if ex then ex:Destroy() end
    end
    local bv=Instance.new("BodyVelocity")
    bv.Name="BDFlyBV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    bv.Velocity=Vector3.zero; bv.Parent=r
    local bg=Instance.new("BodyGyro")
    bg.Name="BDFlyBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
    bg.P=1e4; bg.D=600; bg.CFrame=r.CFrame; bg.Parent=r
    h.PlatformStand=false
    h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    if UIS.TouchEnabled then createJoystick() end
    killConn("fly")
    Conns.fly = RunService.RenderStepped:Connect(function()
        if not S.fly then return end
        local rNow=hrp(); if not rNow then return end
        local bvNow=rNow:FindFirstChild("BDFlyBV")
        local bgNow=rNow:FindFirstChild("BDFlyBG")
        if not bvNow or not bgNow then
            killConn("fly")
            task.defer(function() if S.fly then startFly() end end)
            return
        end
        local cf=Cam.CFrame; local look=cf.LookVector
        local right=cf.RightVector; local up=Vector3.new(0,1,0)
        local spd=S.flySpeed; local vel=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+look*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-look*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+right*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-right*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+up*spd*0.8 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-up*spd*0.8 end
        if UIS.TouchEnabled and joyActive then
            vel=vel+right*(joyDelta.X*spd)+look*(-joyDelta.Y*spd)
        end
        if flyBtnUp   then vel=vel+up*spd*0.8 end
        if flyBtnDown then vel=vel-up*spd*0.8 end
        bvNow.Velocity=vel
        local flatLook=Vector3.new(look.X,0,look.Z)
        if flatLook.Magnitude>0.01 then bgNow.CFrame=CFrame.new(rNow.Position, rNow.Position+flatLook) end
        local hh=hum()
        if hh then
            local st=hh:GetState()
            if st==Enum.HumanoidStateType.Freefall or st==Enum.HumanoidStateType.FallingDown then
                hh:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end)
end

local function stopFly()
    killConn("fly"); destroyJoystick()
    local r=hrp()
    if r then
        local bv=r:FindFirstChild("BDFlyBV"); if bv then bv:Destroy() end
        local bg=r:FindFirstChild("BDFlyBG"); if bg then bg:Destroy() end
    end
    local h=hum()
    if h then
        h.PlatformStand=false
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end

tabMove:CreateSection("✈ Flight")

tabMove:CreateToggle({
    Name="Fly Mode  [F1]", CurrentValue=false, Flag="fly",
    Callback=function(v)
        S.fly=v
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
    Name="Fly Speed", Range={5,500}, Increment=5,
    CurrentValue=60, Flag="flySpeed",
    Callback=function(v) S.flySpeed=v end,
})

tabMove:CreateButton({
    Name="🚁 Hover (Speed → 0)",
    Callback=function() S.flySpeed=0; notify("Hover","ลอยอยู่กับที่ Speed=0",2,"plane") end,
})

tabMove:CreateButton({
    Name="🔄 Reset Fly Speed",
    Callback=function() S.flySpeed=60; notify("Fly Speed","รีเซ็ตเป็น 60",2,"plane") end,
})

tabMove:CreateSection("🏃 Speed & Jump")

tabMove:CreateToggle({
    Name="Super Speed  [F2]", CurrentValue=false, Flag="speed",
    Callback=function(v)
        S.speed=v
        local h=hum(); if h then h.WalkSpeed=v and S.speedVal or 16 end
        notify("Speed", v and "เปิด 💨" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateSlider({
    Name="Walk Speed", Range={16,500}, Increment=1, CurrentValue=60, Flag="speedVal",
    Callback=function(v)
        S.speedVal=v
        if S.speed then local h=hum(); if h then h.WalkSpeed=v end end
    end,
})

tabMove:CreateToggle({
    Name="High Jump", CurrentValue=false, Flag="jump",
    Callback=function(v)
        S.jump=v
        local h=hum(); if h then h.JumpPower=v and S.jumpVal or 50 end
        notify("Jump", v and "เปิด 🦘" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateSlider({
    Name="Jump Power", Range={50,1000}, Increment=10, CurrentValue=100, Flag="jumpVal",
    Callback=function(v)
        S.jumpVal=v
        if S.jump then local h=hum(); if h then h.JumpPower=v end end
    end,
})

tabMove:CreateToggle({
    Name="Infinite Jump", CurrentValue=false, Flag="infJump",
    Callback=function(v)
        S.infJump=v; killConn("infJump")
        if v then
            Conns.infJump=UIS.JumpRequest:Connect(function()
                local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("Infinite Jump", v and "เปิด" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateToggle({
    Name="BunnyHop", CurrentValue=false, Flag="bhop",
    Callback=function(v)
        S.bhop=v; killConn("bhop")
        if v then
            Conns.bhop=RunService.Heartbeat:Connect(function()
                if not S.bhop then return end
                local h=hum()
                if h and h:GetState()==Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("BunnyHop", v and "เปิด 🐇" or "ปิด", 2, "zap")
    end,
})

tabMove:CreateSection("🧱 Physics")

tabMove:CreateToggle({
    Name="NoClip  [F4]", CurrentValue=false, Flag="noclip",
    Callback=function(v)
        S.noclip=v; killConn("noclip")
        if v then
            Conns.noclip=RunService.Stepped:Connect(function()
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
    Name="No Fall Damage", CurrentValue=false, Flag="noFall",
    Callback=function(v)
        S.noFall=v
        local h=hum()
        if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v) end
        notify("No Fall Damage", v and "เปิด" or "ปิด", 2, "shield")
    end,
})

tabMove:CreateSection("🌍 Gravity")

tabMove:CreateSlider({
    Name="Gravity", Range={0,400}, Increment=2, CurrentValue=196, Flag="gravity",
    Callback=function(v) workspace.Gravity=v end,
})

tabMove:CreateButton({Name="🌙 Low Gravity",
    Callback=function() workspace.Gravity=40; notify("Gravity","Low 🌙",2,"moon") end})
tabMove:CreateButton({Name="🌍 Normal Gravity",
    Callback=function() workspace.Gravity=196; notify("Gravity","Normal 🌍",2,"globe") end})
tabMove:CreateButton({Name="🚀 Zero Gravity",
    Callback=function() workspace.Gravity=0; notify("Gravity","Zero-G 🚀",2,"rocket") end})

tabMove:CreateSection("⚡ Quick Actions")

tabMove:CreateButton({
    Name="💨 Dash Forward 30",
    Callback=function()
        local r=hrp(); if r then r.CFrame=r.CFrame+r.CFrame.LookVector*30 end
        notify("Dash","ไปข้างหน้า 30 studs!",1,"zap")
    end,
})
tabMove:CreateButton({
    Name="🚀 Super Launch",
    Callback=function()
        local r=hrp(); if r then r.AssemblyLinearVelocity=Vector3.new(0,300,0) end
        notify("Launch","🚀!",1,"zap")
    end,
})
tabMove:CreateButton({
    Name="⚡ Speed Burst (3s)",
    Callback=function()
        local h=hum(); if not h then return end
        local orig=h.WalkSpeed; h.WalkSpeed=500
        notify("Speed Burst","3 วินาที!",2,"zap")
        task.delay(3,function() if h and h.Parent then h.WalkSpeed=orig end end)
    end,
})

tabComb:CreateSection("🎯 Aimbot")

tabComb:CreateToggle({
    Name="Aimbot", CurrentValue=false, Flag="aimbot",
    Callback=function(v)
        S.aimbot=v; killConn("aimbot")
        if v then
            Conns.aimbot=RunService.RenderStepped:Connect(function()
                if not S.aimbot then return end
                local best,bestD=nil,math.huge
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

tabComb:CreateSlider({Name="Aimbot Range", Range={50,1000}, Increment=10, Suffix=" studs", CurrentValue=200, Flag="abRange",
    Callback=function(v) S.abRange=v end})
tabComb:CreateSlider({Name="Aimbot Smooth", Range={1,100}, Increment=1, Suffix="%", CurrentValue=15, Flag="abSmooth",
    Callback=function(v) S.abSmooth=v/100 end})

tabComb:CreateSection("🛡 Whitelist")

tabComb:CreateInput({
    Name="Add to Whitelist", PlaceholderText="ชื่อผู้เล่น...", RemoveTextAfterFocusLost=true,
    Callback=function(name)
        if name=="" then return end
        for _,n in ipairs(WL) do if n==name then notify("WL",name.." มีแล้ว",2); return end end
        WL[#WL+1]=name; notify("WL","เพิ่ม: "..name,2,"shield")
    end,
})
tabComb:CreateButton({Name="Clear Whitelist",
    Callback=function() WL={}; notify("WL","ล้างแล้ว",2,"trash") end})

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
tabComb:CreateSlider({Name="Hitbox Size", Range={1,60}, Increment=1, CurrentValue=10, Flag="hitboxSz",
    Callback=function(v)
        S.hitboxSz=v
        if not S.hitbox then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character; if not c then continue end
            local r=c:FindFirstChild("HumanoidRootPart")
            if r then r.Size=Vector3.new(v,v,v) end
        end
    end})

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
                    if r and h and (myR.Position-r.Position).Magnitude<=S.kaRange then h.Health=0 end
                end
            end)
        end
        notify("Kill Aura", v and "เปิด ⚔️" or "ปิด", 2, "sword")
    end,
})
tabComb:CreateSlider({Name="Kill Aura Range", Range={5,100}, Increment=1, Suffix=" studs", CurrentValue=15, Flag="kaRange",
    Callback=function(v) S.kaRange=v end})

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
                local myR=hrp(); local rNow=c:FindFirstChild("HumanoidRootPart")
                if not(myR and rNow) then return end
                local d=math.clamp((myR.Position-rNow.Position).Magnitude/200,0,1)
                hl.FillColor=Color3.new(d,1-d,0.2); hl.OutlineColor=Color3.new(d,1-d,0.2)
            end)
            EspConns[#EspConns+1]=uc
        end
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        local conn=Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() task.wait(1); if S.esp then addESP(p) end end)
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
            f.Size=sz; f.Position=pos; f.BackgroundColor3=Color3.fromRGB(80,200,255)
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
            Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(127,127,127)
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

tabVis:CreateButton({Name="Remove Fog",
    Callback=function() Lighting.FogEnd=999999; notify("Fog","ลบแล้ว ☁️",2,"moon") end})

tabVis:CreateSlider({Name="Clock Time", Range={0,24}, Increment=1, Suffix="h", CurrentValue=14, Flag="clockTime",
    Callback=function(v) Lighting.ClockTime=v end})

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
        addCorner(box, 10)
        addStroke(box, Color3.fromRGB(80,160,255), 1.5)
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

tabPlay:CreateSection("🛡 Protection")

tabPlay:CreateToggle({
    Name="God Mode  [F3]", CurrentValue=false, Flag="god",
    Callback=function(v)
        S.god=v; killConn("god"); local h=hum()
        if v then
            if h then h.MaxHealth=math.huge; h.Health=math.huge; h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum(); if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
        else
            if h then h.MaxHealth=100; h.Health=100; h:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end
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
    Name="Character Scale", Range={10,300}, Increment=5, Suffix="%", CurrentValue=100, Flag="charScale",
    Callback=function(v)
        local h=hum(); if not h then return end
        local s=v/100
        safe(function()
            h.BodyDepthScale.Value=s; h.BodyHeightScale.Value=s
            h.BodyWidthScale.Value=s; h.HeadScale.Value=s
        end)
    end,
})

tabPlay:CreateButton({Name="Reset Character",
    Callback=function()
        local h=hum(); if h then h.Health=0 end
        notify("Reset","Reset แล้ว",1,"refresh-cw")
    end,
})

tabPlay:CreateInput({
    Name="Play Animation (ID)", PlaceholderText="ใส่ Animation ID...", RemoveTextAfterFocusLost=true,
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
            hl.OutlineColor=Color3.fromRGB(60,185,255); hl.OutlineTransparency=0
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
                    local f=Instance.new("Fire",p); f.Name="BomDevFire"; f.Heat=5; f.Size=3
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
                NumberSequenceKeypoint.new(0,0); NumberSequenceKeypoint.new(1,1)
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
        if v then Instance.new("ForceField",c).Visible=true end
        notify("Force Field", v and "เปิด 🔵" or "ปิด", 2, "shield")
    end,
})

tabTele:CreateSection("🎯 Target Player")

local selPlayer = nil

tabTele:CreateDropdown({
    Name="Target Player",
    Options=(function()
        local t={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then t[#t+1]=p.Name end end
        if #t==0 then t={"(ว่าง)"} end
        return t
    end)(),
    CurrentOption={"(ว่าง)"},
    MultipleOptions=false, Flag="targetPlayer",
    Callback=function(opts)
        local name=(type(opts)=="table") and opts[1] or opts
        if name=="(ว่าง)" then selPlayer=nil; return end
        selPlayer=Players:FindFirstChild(name)
        notify("Target", selPlayer and "เลือก: "..name or "ไม่พบ", 2, "map-pin")
    end,
})

tabTele:CreateButton({
    Name="🔄 Refresh List (เปิด Dropdown ใหม่)",
    Callback=function() notify("Refresh","รีเฟรชแล้ว — เลือกใหม่ในช่อง Dropdown",3,"refresh-cw") end,
})

tabTele:CreateSection("⚡ Player Actions")

tabTele:CreateButton({
    Name="🔀 Warp to Target",
    Callback=function()
        if not selPlayer or not selPlayer.Character then notify("Warp","ไม่มีเป้าหมาย",2,"alert-triangle"); return end
        local r=hrp(); local tr=selPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then r.CFrame=tr.CFrame+Vector3.new(0,3,0) end
        notify("Warp","ไปหา "..selPlayer.Name,2,"map-pin")
    end,
})

tabTele:CreateButton({
    Name="🧲 Pull Target Here",
    Callback=function()
        if not selPlayer or not selPlayer.Character then notify("Pull","ไม่มีเป้าหมาย",2,"alert-triangle"); return end
        local tr=selPlayer.Character:FindFirstChild("HumanoidRootPart"); local myR=hrp()
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
            if not selPlayer or not selPlayer.Character then notify("Spectate","ไม่มีเป้าหมาย",2,"alert-triangle"); return end
            local h=selPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then Cam.CameraSubject=h end
            notify("Spectate","ดู "..selPlayer.Name,2,"eye")
        else
            Cam.CameraSubject=hum(); notify("Spectate","ปิด",2,"eye")
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

tabTele:CreateButton({Name="⬆ +50 Studs Up",
    Callback=function()
        local r=hrp(); if r then r.CFrame=r.CFrame+Vector3.new(0,50,0) end
        notify("TP","+50 ⬆",1,"arrow-up")
    end,
})
tabTele:CreateButton({Name="🎯 Origin (0,0,0)",
    Callback=function()
        local r=hrp(); if r then r.CFrame=CFrame.new(0,50,0) end
        notify("TP","Origin!",1,"map-pin")
    end,
})
tabTele:CreateButton({Name="🎲 Random Position",
    Callback=function()
        local r=hrp()
        if r then r.CFrame=CFrame.new(math.random(-500,500),100,math.random(-500,500)) end
        notify("TP","Random! 🎲",1,"shuffle")
    end,
})

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
    Name="Sound ID", PlaceholderText="ใส่ Sound ID...", RemoveTextAfterFocusLost=false,
    Callback=function(txt) musicId=txt end,
})

tabUtil:CreateSlider({
    Name="Volume", Range={0,100}, Increment=1, Suffix="%", CurrentValue=50, Flag="musicVol",
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
    Name="Find & TP to Part", PlaceholderText="ชื่อ Part ที่ต้องการหา...", RemoveTextAfterFocusLost=true,
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

tabDl:CreateSection("🔥 BomDev Official Scripts")

local function dlCard(name, desc)
    tabDl:CreateButton({
        Name = name .. "  —  " .. desc,
        Callback = function()
            safe(function() setclipboard("discord.gg/4Vn8WwyV3u") end)
            safe(function() GuiService:OpenBrowserWindow("https://discord.gg/4Vn8WwyV3u") end)
            notify("Download 📥", name .. " — เปิด Discord เพื่อดาวน์โหลด!", 3, "download")
        end,
    })
end

dlCard("BomDev Hub v7",  "Latest hub — PC + Mobile")
dlCard("AutoFarm Pro",   "Multi-game auto farm")
dlCard("ESP Suite",      "Player ESP + Radar")
dlCard("Speed Kit",      "Movement bundle")

tabDl:CreateSection("🎮 Game Scripts")

dlCard("Blox Fruits",     "Auto farm + Raids + Boss")
dlCard("Pet Sim X",       "Pets & coins auto")
dlCard("Murder Mystery 2","ESP + Silent aim")
dlCard("Arsenal",         "Aimbot + ESP")
dlCard("Da Hood",         "Silent aim + Btoolz")
dlCard("Adopt Me",        "Auto bucks + pets")

tabDl:CreateSection("💬 Community")

tabDl:CreateButton({
    Name = "🔗 Join BomDev Discord",
    Callback = function()
        safe(function() setclipboard("discord.gg/4Vn8WwyV3u") end)
        safe(function() GuiService:OpenBrowserWindow("https://discord.gg/4Vn8WwyV3u") end)
        notify("Discord","discord.gg/4Vn8WwyV3u — คัดลอกแล้ว! 💬",4,"message-circle")
    end,
})

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end

    if inp.KeyCode == Enum.KeyCode.F1 then
        S.fly = not S.fly
        if S.fly then startFly(); notify("✈ Fly","F1 — เปิด",1,"plane")
        else stopFly(); notify("✈ Fly","F1 — ปิด",1,"plane") end

    elseif inp.KeyCode == Enum.KeyCode.F2 then
        S.speed = not S.speed
        local h=hum(); if h then h.WalkSpeed=S.speed and S.speedVal or 16 end
        notify("Speed","F2 — "..(S.speed and "เปิด 💨" or "ปิด"),1,"zap")

    elseif inp.KeyCode == Enum.KeyCode.F3 then
        S.god = not S.god; killConn("god"); local h=hum()
        if S.god then
            if h then h.MaxHealth=math.huge; h.Health=math.huge; h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end
            Conns.god=RunService.Heartbeat:Connect(function()
                local hh=hum(); if hh and hh.Health<1e10 then hh.Health=math.huge end
            end)
            notify("God","F3 — เปิด 🛡",1,"shield")
        else
            if h then h.MaxHealth=100; h.Health=100; h:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end
            notify("God","F3 — ปิด",1,"shield")
        end

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

LP.CharacterAdded:Connect(function(c)
    task.wait(1)
    if S.speed then local h=c:WaitForChild("Humanoid"); h.WalkSpeed=S.speedVal end
    if S.jump  then local h=c:WaitForChild("Humanoid"); h.JumpPower=S.jumpVal end
    if S.noFall then local h=c:WaitForChild("Humanoid"); h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end
    if S.god then
        local h=c:WaitForChild("Humanoid")
        h.MaxHealth=math.huge; h.Health=math.huge
        h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
        killConn("god")
        Conns.god=RunService.Heartbeat:Connect(function()
            local hh=hum(); if hh and hh.Health<1e10 then hh.Health=math.huge end
        end)
    end
    if S.glow then
        local hl=Instance.new("Highlight",c)
        hl.Name="BomDevGlow"; hl.FillTransparency=0.7
        hl.FillColor=Color3.fromRGB(130,70,255)
        hl.OutlineColor=Color3.fromRGB(60,185,255); hl.OutlineTransparency=0
    end
    if S.fly then task.wait(0.5); startFly() end
end)

notify(
    "⚡ BomDev Hub v7.0",
    "โหลดสำเร็จ! Dev: BomDev\nF1=Fly  F2=Speed  F3=God  F4=NoClip",
    6,
    "zap"
)

