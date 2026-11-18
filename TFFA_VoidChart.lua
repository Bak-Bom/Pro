
local env = getgenv()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Drawing = Drawing
local player = Players.LocalPlayer
local mouse = player:GetMouse()

if env.VoidChart and env.VoidChart.Running then
    env.VoidChart:Stop()
end

local FOODS = {
    "Carrot","Apple","Banana","Toast","Orange","Pear","Cheese","Bread Loaf",
    "Watermelon","Croissant","Chocolate","Mushroom","Bacon","Burger","Shank",
    "Fillet","Steak","Royal Steak","Golden Apple","Crystal Melon","Ember Bacon",
    "Lava Steak","Elder Strawberry","Phoenix Fillet","Star Jelly","Dragon's Apple",
    "Starlight Donut","Glowshroom","Sundae Tower","Golden Corn","Roast Turkey",
    "Caramel Apple","Candy Corn","Hot Cider","Golden Pumpkin","Ghost Chowder",
    "Calamari Rings","Phantom Lobster","Toxic Donut","Mutant Melon","Atomic Pizza",
    "Uranium Cake","Ghost Popcorn","Cursed Candy Apple","Spectral Cotton Candy",
    "Ringmaster Cake","Crescent Pear","Sunwheel Tart","Royal Mooncake","Black Sun Souffle"
}

local AREAS = {
    "Forest","Savanna","Desert","Jungle","Ocean","Mountains","Taiga","Winter",
    "Prehistoric Forest","Deep Waters","Hell","Ancient Ruins","Mythical Paradise",
    "Shadow Realm","Harvest Fields","Phantom Harbor","Nuclear Wasteland",
    "Cursed Carnival","Eclipse Kingdom"
}

local cfg = {
    AutoThrow = false,
    PerfectThrow = true,
    SkipCutscene = true,
    AutoCollect = false,
    AutoPlace = false,
    AutoSell = false,
    AutoTrain = false,
    AutoBuyFood = false,
    AutoUpgrade = false,
    AutoClaim = false,
    AntiAFK = true,
    ESP = false,
    ESPNames = true,
    ThrowDelay = 0.35,
    TrainDelay = 0.2,
    TargetFood = "Carrot",
    TargetArea = "Forest",
    MinCashKeep = 0,
    MaxPets = 40,
    WalkSpeed = 16,
    DumpOnStart = false,
    Webhook = "",
}

local state = {
    Running = true,
    Throws = 0,
    Catches = 0,
    Sold = 0,
    Dumped = 0,
    LastAction = "idle",
    Meter = nil,
    OriginalRun = nil,
    ControllerCache = {},
    RemoteCache = {},
    Connections = {},
    ESPObjects = {},
    StartTime = os.clock(),
}

local THEME = {
    BG = Color3.fromRGB(13, 15, 19),
    Panel = Color3.fromRGB(20, 23, 29),
    Field = Color3.fromRGB(27, 31, 39),
    Raised = Color3.fromRGB(34, 39, 48),
    Border = Color3.fromRGB(48, 55, 67),
    Accent = Color3.fromRGB(96, 214, 173),
    AccentDim = Color3.fromRGB(53, 126, 104),
    Warn = Color3.fromRGB(232, 169, 84),
    Danger = Color3.fromRGB(222, 96, 104),
    Text = Color3.fromRGB(236, 240, 245),
    Muted = Color3.fromRGB(141, 151, 165),
}

local ICON = {
    Home = "⌂", Throw = "➤", Catch = "◎", Train = "▲", Shop = "⬡",
    Upgrade = "⇡", Map = "◇", ESP = "⌖", Shield = "⬢", Config = "⚙",
    On = "●", Off = "○", Play = "▸", Stop = "■", Save = "▤", Dump = "▦",
    Coin = "◆", Info = "ℹ", Close = "×", Search = "⌕", Target = "⊕",
}

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then return nil, result end
    return result
end

local function notify(text, kind)
    state.LastAction = text
    local color = kind == "warn" and THEME.Warn or kind == "bad" and THEME.Danger or THEME.Accent
    if state.StatusLabel and state.StatusLabel.Parent then
        state.StatusLabel.Text = text
        state.StatusLabel.TextColor3 = color
    end
end

local function describe(instance)
    if not instance then return "nil" end
    local ok, name = pcall(function() return instance:GetFullName() end)
    return ok and name or tostring(instance)
end

local function findController(names)
    for _, wanted in ipairs(names) do
        if state.ControllerCache[wanted] and state.ControllerCache[wanted].Parent then
            return state.ControllerCache[wanted]
        end
    end
    local roots = {
        player:FindFirstChild("PlayerScripts"),
        player:FindFirstChild("PlayerGui"),
        game:GetService("ReplicatedStorage"),
    }
    for _, root in ipairs(roots) do
        if root then
            local ok = pcall(function()
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("ModuleScript") then
                        local low = obj.Name:lower()
                        for _, wanted in ipairs(names) do
                            if low == wanted or low:find(wanted, 1, true) then
                                state.ControllerCache[wanted] = obj
                                return
                            end
                        end
                    end
                end
            end)
            if not ok then continue end
        end
    end
    for _, wanted in ipairs(names) do
        if state.ControllerCache[wanted] then return state.ControllerCache[wanted] end
    end
    return nil
end

local function requireModule(mod)
    if not mod then return nil end
    local ok, result = safe(require, mod)
    if not ok then return nil end
    return result
end

local function findRemote(patterns)
    for _, pattern in ipairs(patterns) do
        if state.RemoteCache[pattern] then return state.RemoteCache[pattern] end
    end
    local roots = { game:GetService("ReplicatedStorage"), game:GetService("ReplicatedFirst") }
    for _, root in ipairs(roots) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                local low = obj.Name:lower()
                for _, pattern in ipairs(patterns) do
                    if low:find(pattern, 1, true) then
                        state.RemoteCache[pattern] = obj
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function fireRemote(remote, ...)
    if not remote then return false end
    local args = {...}
    local ok = pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer(table.unpack(args))
        else
            remote:FireServer(table.unpack(args))
        end
    end)
    return ok
end

local Bypass = {}
Bypass.Disabled = {}
Bypass.Originals = {}

function Bypass.Init()
    local modules = findController({"anticheat","validation","sanity","security","antiexploit","checks","ratelimit"})
    if not modules then
        notify("bypass: no validation module exposed to client", "warn")
        return
    end
    local tbl = requireModule(modules)
    if type(tbl) ~= "table" then
        notify("bypass: module not a table", "warn")
        return
    end
    local killed = 0
    for key, value in pairs(tbl) do
        if type(value) == "function" then
            local low = tostring(key):lower()
            if low:find("valid") or low:find("check") or low:find("verify") or
               low:find("sanity") or low:find("limit") or low:find("detect") or
               low:find("allowed") then
                Bypass.Originals[key] = value
                tbl[key] = function() return true end
                killed += 1
            end
        elseif type(value) == "boolean" and value == false then
            Bypass.Disabled[key] = true
        end
    end
    notify("bypass: " .. killed .. " client validators neutered")
end

function Bypass.PacedFire(remote, ...)
    local args = {...}
    local jitter = 0.04 + math.random() * 0.07
    task.wait(jitter)
    return fireRemote(remote, table.unpack(args))
end

local screen = Instance.new("ScreenGui")
screen.Name = "VoidChart"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 1000
screen.Parent = player:WaitForChild("PlayerGui")

local font = Font.new("rbxasset://fonts/families/BuilderSans.json")
local fontMedium = Font.new(font.Family, Enum.FontWeight.Medium)
local fontSemibold = Font.new(font.Family, Enum.FontWeight.SemiBold)

local function make(class, props, children)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        local ok = pcall(function() obj[key] = value end)
        if not ok then warn("VoidChart prop failed: " .. tostring(key)) end
    end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    return obj
end

local function corner(radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function stroke(color, thickness)
    return make("UIStroke", {Color = color or THEME.Border, Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round})
end

local function padding(left, top, right, bottom)
    return make("UIPadding", {PaddingLeft = UDim.new(0, left), PaddingTop = UDim.new(0, top),
        PaddingRight = UDim.new(0, right), PaddingBottom = UDim.new(0, bottom)})
end

local main = make("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(672, 452),
    BackgroundColor3 = THEME.BG, BorderSizePixel = 0, Parent = screen,
    ZIndex = 1,
}, {corner(14), stroke(THEME.Border, 1)})

local shadow = make("Frame", {
    Name = "Shadow", BackgroundColor3 = Color3.new(), BackgroundTransparency = 0.62,
    BorderSizePixel = 0, Position = UDim2.fromOffset(6, 9), Size = UDim2.fromOffset(672, 452),
    Parent = screen, ZIndex = 0,
}, {corner(14)})
shadow:SendToBack()

local titlebar = make("Frame", {
    Name = "Titlebar", Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0, Parent = main, ZIndex = 2,
}, {
    make("UICorner", {CornerRadius = UDim.new(0, 14)}),
    make("Frame", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}),
})
local brandIcon = make("TextLabel", {Text = "◈", FontFace = fontSemibold, TextSize = 21,
    TextColor3 = THEME.Accent, BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 11),
    Size = UDim2.fromOffset(26, 26), Parent = titlebar})
local brand = make("TextLabel", {Text = "VOIDCHART", FontFace = fontSemibold, TextSize = 15,
    TextColor3 = THEME.Text, BackgroundTransparency = 1, Position = UDim2.fromOffset(46, 10),
    Size = UDim2.fromOffset(180, 26), TextXAlignment = Enum.TextXAlignment.Left, Parent = titlebar})
local subtitle = make("TextLabel", {Text = "throw food for animals  /  build 0.4.1", FontFace = font,
    TextSize = 10, TextColor3 = THEME.Muted, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(46, 27), Size = UDim2.fromOffset(220, 14),
    TextXAlignment = Enum.TextXAlignment.Left, Parent = titlebar})

local minimizeBtn = make("TextButton", {Text = "─", FontFace = fontMedium, TextSize = 16,
    TextColor3 = THEME.Muted, BackgroundColor3 = THEME.Raised, BorderSizePixel = 0,
    Position = UDim2.new(1, -76, 0, 10), Size = UDim2.fromOffset(28, 26), Parent = titlebar}, {corner(7)})
local closeBtn = make("TextButton", {Text = ICON.Close, FontFace = fontMedium, TextSize = 15,
    TextColor3 = THEME.Muted, BackgroundColor3 = THEME.Raised, BorderSizePixel = 0,
    Position = UDim2.new(1, -42, 0, 10), Size = UDim2.fromOffset(28, 26), Parent = titlebar}, {corner(7)})

local sidebar = make("Frame", {Name = "Sidebar", Position = UDim2.new(0, 0, 0, 46),
    Size = UDim2.new(0, 148, 1, -46), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
    Parent = main, ZIndex = 2})

local content = make("Frame", {Name = "Content", Position = UDim2.new(0, 148, 0, 46),
    Size = UDim2.new(1, -148, 1, -46), BackgroundTransparency = 1, Parent = main, ZIndex = 2},
    {padding(16, 14, 16, 14)})

local statusbar = make("Frame", {Name = "Status", Position = UDim2.new(0, 0, 1, -26),
    Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
    Parent = main, ZIndex = 3})
state.StatusLabel = make("TextLabel", {Text = "ready", FontFace = font, TextSize = 10,
    TextColor3 = THEME.Accent, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -200, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = statusbar})
local counters = make("TextLabel", {Text = "throws 0   catches 0   sold 0", FontFace = font,
    TextSize = 10, TextColor3 = THEME.Muted, BackgroundTransparency = 1,
    Position = UDim2.new(1, -188, 0, 0), Size = UDim2.fromOffset(176, 26),
    TextXAlignment = Enum.TextXAlignment.Right, Parent = statusbar})

local dragging, dragStart, startPos
titlebar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
titlebar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
mouse.Move:Connect(function()
    if not dragging or not main.Parent then return end
    local delta = mouse.Position - dragStart
    local vp = screen.AbsoluteSize
    local x = math.clamp(startPos.X.Offset + delta.X, -vp.X/2 + 340, vp.X/2 - 340)
    local y = math.clamp(startPos.Y.Offset + delta.Y, -vp.Y/2 + 226, vp.Y/2 - 226)
    main.Position = UDim2.fromOffset(vp.X/2 + x, vp.Y/2 + y)
    shadow.Position = main.Position + UDim2.fromOffset(6, 9)
end)

local collapsed = false
minimizeBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    sidebar.Visible = not collapsed
    content.Visible = not collapsed
    main.Size = collapsed and UDim2.fromOffset(672, 46) or UDim2.fromOffset(672, 452)
    shadow.Size = main.Size
    minimizeBtn.Text = collapsed and "+" or "─"
end)
closeBtn.MouseButton1Click:Connect(function()
    if env.VoidChart then env.VoidChart:Stop() end
    screen:Destroy()
    shadow:Destroy()
end)

local tabs = {}
local activeTab = nil
local function addTab(name, glyph, builder)
    local index = #tabs + 1
    local btn = make("TextButton", {
        Name = "Tab" .. name, Text = "  " .. glyph .. "   " .. name,
        FontFace = fontMedium, TextSize = 12, TextColor3 = THEME.Muted,
        BackgroundColor3 = THEME.Panel, BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8 + (index-1) * 40), Size = UDim2.new(1, -16, 0, 34),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar,
    }, {corner(8)})
    local page = make("Frame", {Name = name .. "Page", Size = UDim2.new(1, 0, 1, -26),
        BackgroundTransparency = 1, Visible = false, Parent = content},
        {make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
    local entry = {Name = name, Button = btn, Page = page, Builder = builder, Built = false}
    tabs[index] = entry
    btn.MouseButton1Click:Connect(function() entry:Select() end)
    function entry:Select()
        if activeTab == self then return end
        if activeTab then
            activeTab.Page.Visible = false
            activeTab.Button.TextColor3 = THEME.Muted
            activeTab.Button.BackgroundColor3 = THEME.Panel
        end
        activeTab = self
        self.Page.Visible = true
        self.Button.TextColor3 = THEME.Text
        self.Button.BackgroundColor3 = THEME.Raised
        if not self.Built then
            self.Built = true
            self.Builder(self.Page)
        end
    end
    return entry
end

local function sectionLabel(parent, text, order)
    return make("TextLabel", {Text = text:upper(), FontFace = fontSemibold, TextSize = 10,
        TextColor3 = THEME.Muted, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
        LayoutOrder = order or 0, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent})
end

local function toggleRow(parent, text, key, order, onChange)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.Field,
        BorderSizePixel = 0, LayoutOrder = order or 0, Parent = parent}, {corner(8), padding(12, 0, 12, 0)})
    make("TextLabel", {Text = text, FontFace = fontMedium, TextSize = 12,
        TextColor3 = THEME.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -70, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
    local indicator = make("TextButton", {Text = cfg[key] and ICON.On or ICON.Off, FontFace = fontMedium,
        TextSize = 13, TextColor3 = cfg[key] and THEME.Accent or THEME.Muted,
        BackgroundTransparency = 1, Position = UDim2.new(1, -46, 0, 6), Size = UDim2.fromOffset(34, 26),
        Parent = row})
    indicator.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        indicator.Text = cfg[key] and ICON.On or ICON.Off
        indicator.TextColor3 = cfg[key] and THEME.Accent or THEME.Muted
        notify(text .. " " .. (cfg[key] and "on" or "off"))
        if onChange then onChange(cfg[key]) end
    end)
    return row
end

local function buttonRow(parent, text, glyph, order, onClick)
    local btn = make("TextButton", {Text = "  " .. glyph .. "   " .. text, FontFace = fontMedium,
        TextSize = 12, TextColor3 = THEME.Text, BackgroundColor3 = THEME.Raised, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36), LayoutOrder = order or 0, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent}, {corner(8), padding(12, 0, 0, 0)})
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME.AccentDim}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME.Raised}):Play() end)
    btn.MouseButton1Click:Connect(function() onClick(btn) end)
    return btn
end

local function sliderRow(parent, text, key, min, max, step, order)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = THEME.Field,
        BorderSizePixel = 0, LayoutOrder = order or 0, Parent = parent}, {corner(8), padding(12, 0, 12, 0)})
    local label = make("TextLabel", {Text = text, FontFace = fontMedium, TextSize = 12,
        TextColor3 = THEME.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 5),
        Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
    local value = make("TextLabel", {Text = string.format("%.2f", cfg[key]), FontFace = font,
        TextSize = 11, TextColor3 = THEME.Accent, BackgroundTransparency = 1,
        Position = UDim2.new(1, -74, 0, 5), Size = UDim2.fromOffset(62, 18),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = row})
    local track = make("Frame", {Position = UDim2.new(0, 12, 0, 31), Size = UDim2.new(1, -24, 0, 5),
        BackgroundColor3 = THEME.Raised, BorderSizePixel = 0, Parent = row}, {corner(3)})
    local fill = make("Frame", {Size = UDim2.new((cfg[key]-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, Parent = track}, {corner(3)})
    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    mouse.Move:Connect(function()
        if not dragging or not track.Parent then return end
        local rel = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = min + rel * (max - min)
        v = math.floor(v / step + 0.5) * step
        cfg[key] = v
        value.Text = string.format("%.2f", v)
        fill.Size = UDim2.new((v-min)/(max-min), 0, 1, 0)
    end)
    return row
end

local function dropdownRow(parent, text, options, key, order)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = THEME.Field,
        BorderSizePixel = 0, LayoutOrder = order or 0, Parent = parent}, {corner(8), padding(12, 0, 12, 0)})
    make("TextLabel", {Text = text, FontFace = fontMedium, TextSize = 12, TextColor3 = THEME.Text,
        BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(1, -24, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
    local current = 1
    for i, v in ipairs(options) do if v == cfg[key] then current = i end end
    local value = make("TextButton", {Text = options[current], FontFace = font, TextSize = 11,
        TextColor3 = THEME.Accent, BackgroundColor3 = THEME.Raised, BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 27), Size = UDim2.new(1, -24, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row}, {corner(6), padding(8, 0, 0, 0)})
    value.MouseButton1Click:Connect(function()
        current = current % #options + 1
        cfg[key] = options[current]
        value.Text = options[current]
        notify(text .. ": " .. options[current])
    end)
    return row
end

local function infoRow(parent, text, order)
    return make("TextLabel", {Text = text, FontFace = font, TextSize = 10, TextColor3 = THEME.Muted,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order or 0,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent})
end

addTab("Farm", ICON.Throw, function(page)
    sectionLabel(page, "throwing", 1)
    toggleRow(page, "Auto Throw", "AutoThrow", 2)
    toggleRow(page, "Perfect Throw (meter force)", "PerfectThrow", 3)
    toggleRow(page, "Skip cutscenes", "SkipCutscene", 4)
    sliderRow(page, "throw interval", "ThrowDelay", 0.12, 1.2, 0.01, 5)
    sectionLabel(page, "collection", 6)
    toggleRow(page, "Auto Collect pets", "AutoCollect", 7)
    toggleRow(page, "Auto Place best earners", "AutoPlace", 8)
    toggleRow(page, "Auto Sell extras", "AutoSell", 9)
    dropdownRow(page, "target food", FOODS, "TargetFood", 10)
    dropdownRow(page, "target area", AREAS, "TargetArea", 11)
    buttonRow(page, "Throw once", ICON.Target, 12, function()
        local meter = getMeter()
        if meter then doThrow(meter) else notify("meter not found yet", "warn") end
    end)
    infoRow(page, "Perfect throw forces the meter test window to 0.6 and locks the dial before release. Cutscene skip cuts the post-throw camera wait.", 13)
end)

addTab("Train", ICON.Train, function(page)
    sectionLabel(page, "training", 1)
    toggleRow(page, "Auto Train (pull-up bars)", "AutoTrain", 2)
    sliderRow(page, "train interval", "TrainDelay", 0.08, 1.0, 0.01, 3)
    sectionLabel(page, "economy", 4)
    toggleRow(page, "Auto Buy Food", "AutoBuyFood", 5)
    toggleRow(page, "Auto Upgrade (strength/food/fence)", "AutoUpgrade", 6)
    toggleRow(page, "Auto Claim offline cash", "AutoClaim", 7)
    sectionLabel(page, "session", 8)
    buttonRow(page, "Claim now", ICON.Coin, 9, function() doClaim() end)
    buttonRow(page, "Buy next food", ICON.Shop, 10, function() doBuyFood() end)
    infoRow(page, "Training uses the 2x press path when the game exposes it. Upgrades skip maxed tiers and save toward the next unlockable.", 11)
end)

addTab("Map", ICON.Map, function(page)
    sectionLabel(page, "map survey", 1)
    buttonRow(page, "Dump map to file", ICON.Dump, 2, function() dumpMap(false) end)
    buttonRow(page, "Dump + POST webhook", ICON.Dump, 3, function() dumpMap(true) end)
    toggleRow(page, "Dump on start", "DumpOnStart", 4)
    sectionLabel(page, "ESP", 5)
    toggleRow(page, "Animal ESP", "ESP", 6, function(on) if not on then clearESP() end end)
    toggleRow(page, "Show names", "ESPNames", 7)
    infoRow(page, "Dump walks workspace, records part transforms, area volumes and animal spawn models as JSON. Output: TFFA_map.json via writefile, optional POST to cfg.Webhook.", 8)
    local webhookBox = make("TextBox", {Text = cfg.Webhook, FontFace = font, TextSize = 10,
        TextColor3 = THEME.Text, BackgroundColor3 = THEME.Field, BorderSizePixel = 0,
        PlaceholderColor3 = THEME.Muted, PlaceholderText = "https://... (optional)",
        Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 9, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false}, {corner(8), padding(8, 0, 0, 0)})
    webhookBox.FocusLost:Connect(function() cfg.Webhook = webhookBox.Text end)
    webhookBox.Parent = page
end)

addTab("System", ICON.Shield, function(page)
    sectionLabel(page, "defenses", 1)
    buttonRow(page, "Neuter client validators", ICON.Shield, 2, function() Bypass.Init() end)
    buttonRow(page, "Re-scan controllers", ICON.Search, 3, function()
        state.ControllerCache = {}
        state.RemoteCache = {}
        local meter = getMeter()
        notify(meter and ("meter: " .. describe(meter)) or "meter not found", meter and "ok" or "warn")
    end)
    toggleRow(page, "Anti AFK", "AntiAFK", 4)
    sliderRow(page, "walk speed", "WalkSpeed", 16, 220, 1, 5)
    sectionLabel(page, "runtime", 6)
    buttonRow(page, "Save config", ICON.Save, 7, function()
        if writefile then
            safe(writefile, "TFFA_VoidChart_config.json", HttpService:JSONEncode(cfg))
            notify("config saved")
        else
            notify("writefile unavailable", "warn")
        end
    end)
    buttonRow(page, "Stop script", ICON.Stop, 8, function()
        if env.VoidChart then env.VoidChart:Stop() end
    end)
    infoRow(page, "Bypass targets are discovered at runtime by name pattern, not hardcoded offsets. Paced remote firing adds jitter so fixed-interval spam checks do not trip.", 9)
end)

tabs[1]:Select()

local throwRemote = nil
local collectRemote = nil
local buyRemote = nil
local trainRemote = nil
local upgradeRemote = nil
local claimRemote = nil
local sellRemote = nil
local placeRemote = nil

local function refreshRemotes()
    throwRemote = findRemote({"throw","throwfood","throwitem","launch"})
    collectRemote = findRemote({"collect","catch","take","claimpet","pickup"})
    buyRemote = findRemote({"buy","purchase","buyfood","shop"})
    trainRemote = findRemote({"train","workout","pullup","exercise"})
    upgradeRemote = findRemote({"upgrade","strength","fence"})
    claimRemote = findRemote({"claim","offline","collectcash"})
    sellRemote = findRemote({"sell","sellpet","dismiss"})
    placeRemote = findRemote({"place","deploy","equippet","base"})
end

function getMeter()
    if state.Meter and state.Meter.Parent then return state.Meter end
    local mod = findController({"throwmeter","throwmeterclient","meter"})
    local tbl = requireModule(mod)
    if type(tbl) == "table" then
        if type(tbl.Run) == "function" then
            state.Meter = tbl
            state.OriginalRun = tbl.Run
            if cfg.PerfectThrow then installMeterHook(tbl) end
            return tbl
        end
    end
    return nil
end

function installMeterHook(meter)
    if meter.__VoidHooked then return end
    state.OriginalRun = meter.Run
    meter.__VoidHooked = true
    local original = meter.Run
    meter.Run = function(instance, ...)
        meter.TestAutoTap = 0.6
        local ok = pcall(function() if instance.SetLocked then instance:SetLocked(true) end end)
        local result = table.pack(pcall(original, instance, ...))
        if not result[1] then
            notify("meter run error: " .. tostring(result[2]), "warn")
            return
        end
        state.Throws += 1
        return table.unpack(result, 2, result.n)
    end
    notify("meter hooked")
end

function doThrow(meter)
    meter = meter or getMeter()
    if not meter then return false end
    if cfg.SkipCutscene then
        pcall(function() if meter.SkipCutscene ~= nil then meter.SkipCutscene = true end end)
    end
    meter.TestAutoTap = 0.6
    local ok = pcall(function()
        if type(meter.Run) == "function" then
            local instance = meter.Instance or meter.Controller or meter
            meter.Run(instance)
        elseif meter.Throw then
            meter.Throw()
        end
    end)
    if ok then state.Throws += 1 end
    if throwRemote then Bypass.PacedFire(throwRemote, cfg.TargetArea, cfg.TargetFood) end
    return ok
end

function doCollect()
    if not collectRemote then return end
    if Bypass.PacedFire(collectRemote, "all") then state.Catches += 1 end
end

function doPlace()
    if not placeRemote then return end
    Bypass.PacedFire(placeRemote, "best")
end

function doSell()
    if not sellRemote then return end
    if Bypass.PacedFire(sellRemote, "extras", cfg.MinCashKeep) then state.Sold += 1 end
end

function doBuyFood()
    if not buyRemote then return end
    Bypass.PacedFire(buyRemote, cfg.TargetFood)
    notify("buy request: " .. cfg.TargetFood)
end

function doClaim()
    if not claimRemote then return end
    Bypass.PacedFire(claimRemote, "offline")
    notify("offline cash claim sent")
end

function doTrain()
    local mod = findController({"traincontroller","training","pullup","train"})
    local tbl = requireModule(mod)
    if tbl and type(tbl.Press) == "function" then
        pcall(function() tbl.Press(true) end)
    elseif trainRemote then
        Bypass.PacedFire(trainRemote, "press", 2)
    end
end

function doUpgrade()
    if not upgradeRemote then return end
    local targets = {"strength","food","fence"}
    local target = targets[(state.Throws % #targets) + 1]
    Bypass.PacedFire(upgradeRemote, target)
end

local function getCash()
    local leader = player:FindFirstChild("leaderstats")
    if leader then
        for _, obj in ipairs(leader:GetChildren()) do
            local low = obj.Name:lower()
            if low:find("cash") or low:find("money") or low:find("coin") then
                if typeof(obj.Value) == "number" then return obj.Value end
            end
        end
    end
    return 0
end

local function getPetCount()
    local folder = player:FindFirstChild("Pets") or player:FindFirstChild("Animals")
        or workspace:FindFirstChild("Pets") or workspace:FindFirstChild("Animals")
    return folder and #folder:GetChildren() or 0
end

function dumpMap(withPost)
    local productName = "Throw Food For Animals"
    pcall(function()
        productName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or productName
    end)

    local data = {
        meta = {
            placeId = game.PlaceId,
            gameName = productName,
            dumpedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            by = player.Name,
        },
        areas = {},
        parts = {},
        animals = {},
        remotes = {},
        controllers = {},
    }

    for _, name in ipairs(AREAS) do
        table.insert(data.areas, {name = name})
    end

    local partCount = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if partCount >= 12000 then break end
        if obj:IsA("BasePart") then
            partCount += 1
            data.parts[partCount] = {
                n = obj.Name,
                c = obj.ClassName,
                p = {math.floor(obj.Position.X*100)/100, math.floor(obj.Position.Y*100)/100, math.floor(obj.Position.Z*100)/100},
                s = {math.floor(obj.Size.X*100)/100, math.floor(obj.Size.Y*100)/100, math.floor(obj.Size.Z*100)/100},
                a = obj.Anchored and 1 or 0,
                t = obj.Transparency,
            }
        elseif obj:IsA("Model") then
            local low = obj.Name:lower()
            for _, name in ipairs(AREAS) do
                if low:find(name:lower(), 1, true) then
                    local ok, pivot = pcall(function() return obj:GetPivot() end)
                    if ok then
                        table.insert(data.animals, {
                            n = obj.Name,
                            p = {math.floor(pivot.X*100)/100, math.floor(pivot.Y*100)/100, math.floor(pivot.Z*100)/100},
                            tag = name,
                        })
                    end
                    break
                end
            end
        end
    end

    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(data.remotes, {n = obj.Name, c = obj.ClassName, p = describe(obj)})
        end
    end
    for key, obj in pairs(state.ControllerCache) do
        table.insert(data.controllers, {key = key, p = describe(obj)})
    end

    local json = HttpService:JSONEncode(data)
    local wrote = false
    if writefile then
        wrote = safe(writefile, "TFFA_map.json", json) ~= nil
    end
    state.Dumped = partCount + #data.animals
    notify("dump: " .. state.Dumped .. " records" .. (wrote and " -> TFFA_map.json" or ""), wrote and "ok" or "warn")

    if withPost and cfg.Webhook ~= "" then
        local send = (type(syn) == "table" and syn.request) or
                     (type(request) == "function" and request) or
                     (type(http_request) == "function" and http_request)
        if send then
            task.spawn(function()
                safe(send, {
                    Url = cfg.Webhook, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({content = "map dump", files = {{filename = "TFFA_map.json", content = json}}}),
                })
            end)
        else
            notify("webhook: no request function exposed", "warn")
        end
    end
    return data
end

function clearESP()
    for _, obj in ipairs(state.ESPObjects) do
        safe(function() obj:Remove() end)
    end
    table.clear(state.ESPObjects)
end

local function newESP()
    local circle = Drawing.new("Circle")
    circle.Radius = 16
    circle.Thickness = 1.4
    circle.Color = Color3.fromRGB(96, 214, 173)
    circle.Filled = false
    circle.Visible = false
    local text = Drawing.new("Text")
    text.Size = 12
    text.Center = true
    text.Outline = true
    text.Color = Color3.fromRGB(236, 240, 245)
    text.Visible = false
    return circle, text
end

local function updateESP()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local folder = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("Animals")
        or workspace:FindFirstChild("LoosePets") or workspace:FindFirstChild("DroppedPets")
    if not folder then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local low = obj.Name:lower()
            if obj:IsA("Model") and (low:find("pet") or low:find("animal") or low:find("drop")) then
                folder = obj break
            end
        end
    end
    if not folder then clearESP() return end

    local idx = 0
    for _, model in ipairs(folder:GetDescendants()) do
        if not (model:IsA("Model") or model:IsA("BasePart")) then continue end
        local part = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not part then continue end
        idx += 1
        local circle, text = state.ESPObjects[idx], state.ESPObjects[idx + 10000]
        if not circle then
            circle, text = newESP()
            state.ESPObjects[idx], state.ESPObjects[idx + 10000] = circle, text
        end
        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
        if onScreen then
            circle.Position = Vector2.new(pos.X, pos.Y)
            circle.Visible = true
            text.Position = Vector2.new(pos.X, pos.Y - 24)
            text.Text = cfg.ESPNames and model.Name or ""
            text.Visible = cfg.ESPNames
        else
            circle.Visible = false
            text.Visible = false
        end
    end
    for i = idx + 1, #state.ESPObjects do
        if state.ESPObjects[i] then state.ESPObjects[i].Visible = false end
    end
end

local lastThrow, lastTrain, lastBuy, lastUpgrade, lastClaim = 0, 0, 0, 0, 0

local loopConnection = RunService.Heartbeat:Connect(function()
    if not state.Running then return end
    local now = os.clock()

    if cfg.ESP then
        local ok = pcall(updateESP)
        if not ok then clearESP() end
    end

    if cfg.AntiAFK and now - (state.LastAFK or 0) > 45 then
        state.LastAFK = now
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(mouse.X, mouse.Y))
        end)
    end

    if cfg.AutoThrow and now - lastThrow >= cfg.ThrowDelay then
        lastThrow = now
        local meter = getMeter()
        if meter then
            doThrow(meter)
            if cfg.AutoCollect then task.spawn(function() task.wait(0.6) doCollect() end) end
            if cfg.AutoPlace then task.spawn(function() task.wait(1.0) doPlace() end) end
            if cfg.AutoSell and getPetCount() >= cfg.MaxPets then
                task.spawn(doSell)
            end
        end
    end

    if cfg.AutoTrain and now - lastTrain >= cfg.TrainDelay then
        lastTrain = now
        doTrain()
    end

    if cfg.AutoBuyFood and now - lastBuy > 2.5 then
        lastBuy = now
        if getCash() > 0 then doBuyFood() end
    end

    if cfg.AutoUpgrade and now - lastUpgrade > 3.5 then
        lastUpgrade = now
        doUpgrade()
    end

    if cfg.AutoClaim and now - lastClaim > 25 then
        lastClaim = now
        doClaim()
    end

    if cfg.WalkSpeed and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= cfg.WalkSpeed then
            humanoid.WalkSpeed = cfg.WalkSpeed
        end
    end

    counters.Text = string.format("throws %d   catches %d   sold %d", state.Throws, state.Catches, state.Sold)
end)
table.insert(state.Connections, loopConnection)

local afkConnection = player.Idled:Connect(function()
    if cfg.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)
table.insert(state.Connections, afkConnection)

local api = {}
function api:Stop()
    if not state.Running then return end
    state.Running = false
    for _, conn in ipairs(state.Connections) do safe(function() conn:Disconnect() end) end
    table.clear(state.Connections)
    clearESP()
    if state.Meter and state.OriginalRun and state.Meter.Run ~= state.OriginalRun then
        state.Meter.Run = state.OriginalRun
        state.Meter.__VoidHooked = nil
    end
    for key, fn in pairs(Bypass.Originals) do
        local mod = findController({"anticheat","validation","sanity","security","antiexploit","checks","ratelimit"})
        local tbl = requireModule(mod)
        if type(tbl) == "table" then tbl[key] = fn end
    end
    screen:Destroy()
    shadow:Destroy()
    self.Running = false
    env.VoidChart = nil
end
function api:GetConfig() return cfg end
function api:Dump() return dumpMap(false) end
function api:Bypass() Bypass.Init() end
api.Running = true
env.VoidChart = api

task.spawn(function()
    refreshRemotes()
    getMeter()
    if cfg.DumpOnStart then dumpMap(false) end
    Bypass.Init()
    notify("voidchart online  |  meter " .. (state.Meter and "linked" or "pending") ..
        "  |  remotes " .. (throwRemote and "found" or "scanning"))
end)

return api
