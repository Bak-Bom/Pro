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
    AutoThrow = false, PerfectThrow = true, SkipCutscene = true,
    AutoCollect = false, AutoPlace = false, AutoSell = false,
    AutoTrain = false, AutoBuyFood = false, AutoUpgrade = false,
    AutoClaim = false, AntiAFK = true, ESP = false, ESPNames = true,
    ThrowDelay = 0.35, TrainDelay = 0.2,
    TargetFood = "Carrot", TargetArea = "Forest",
    MinCashKeep = 0, MaxPets = 40, WalkSpeed = 16,
    DumpOnStart = false, Webhook = "",
}

local state = {
    Running = true, Throws = 0, Catches = 0, Sold = 0, Dumped = 0,
    LastAction = "idle", Meter = nil, OriginalRun = nil,
    ControllerCache = {}, RemoteCache = {}, Connections = {},
    ESPObjects = {}, ESPHolder = nil, StartTime = os.clock(),
}

local C = {
    Base = Color3.fromRGB(10, 16, 21), Panel = Color3.fromRGB(16, 25, 32),
    Raised = Color3.fromRGB(24, 37, 46), RaisedHi = Color3.fromRGB(31, 48, 59),
    Line = Color3.fromRGB(44, 65, 77), LineDim = Color3.fromRGB(30, 45, 55),
    Accent = Color3.fromRGB(88, 222, 182), AccentD = Color3.fromRGB(38, 112, 93),
    AccentHi = Color3.fromRGB(148, 255, 218),
    Amber = Color3.fromRGB(232, 176, 96), Danger = Color3.fromRGB(230, 105, 116),
    Text = Color3.fromRGB(232, 242, 246), Muted = Color3.fromRGB(126, 151, 163),
    Black = Color3.fromRGB(3, 6, 8),
}

local G = {
    Mark = "◈", Throw = "➤", Catch = "◎", Train = "▲", Shop = "⬡",
    Map = "◇", Shield = "⬢", Close = "×", Left = "◀", Right = "▶",
    Grip = "≡", Pulse = "◆", Scan = "⌖", Search = "⌕",
}

local BASE_W, BASE_H = 704, 468
local FONT = Enum.Font.SourceSans
local FONT_B = Enum.Font.SourceSansBold
local FONT_S = Enum.Font.SourceSansSemibold

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then return nil, result end
    return result
end

local function notify(text, kind)
    state.LastAction = text
    local color = kind == "warn" and C.Amber or kind == "bad" and C.Danger or C.Accent
    if state.StatusText and state.StatusText.Parent then
        state.StatusText.Text = text
        state.StatusText.TextColor3 = color
    end
    if state.LED then state.LED.BackgroundColor3 = color end
end

local function describe(instance)
    if not instance then return "nil" end
    local ok, name = pcall(function() return instance:GetFullName() end)
    return ok and name or tostring(instance)
end

local function findController(names)
    for _, wanted in ipairs(names) do
        local found = state.ControllerCache[wanted]
        if found then return found end
    end
    local roots = {
        player:FindFirstChild("PlayerScripts"),
        player:FindFirstChild("PlayerGui"),
        game:GetService("ReplicatedStorage"),
    }
    for _, root in ipairs(roots) do
        if root then
            pcall(function()
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
        end
    end
    for _, wanted in ipairs(names) do
        if state.ControllerCache[wanted] then return state.ControllerCache[wanted] end
    end
    return nil
end

local function requireModule(mod)
    if not mod then return nil end
    return safe(require, mod)
end

local function findRemote(patterns)
    for _, pattern in ipairs(patterns) do
        if state.RemoteCache[pattern] then return state.RemoteCache[pattern] end
    end
    local roots = { game:GetService("ReplicatedStorage"), game:GetService("ReplicatedFirst") }
    for _, root in ipairs(roots) do
        if root then
            pcall(function()
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                        local low = obj.Name:lower()
                        for _, pattern in ipairs(patterns) do
                            if low:find(pattern, 1, true) then
                                state.RemoteCache[pattern] = obj
                                return
                            end
                        end
                    end
                end
            end)
        end
    end
    for _, pattern in ipairs(patterns) do
        if state.RemoteCache[pattern] then return state.RemoteCache[pattern] end
    end
    return nil
end

local function fireRemote(remote, ...)
    if not remote then return false end
    local args = table.pack(...)
    local ok = pcall(function()
        if remote:IsA("BindableEvent") then
            remote:Fire(table.unpack(args, 1, args.n))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(table.unpack(args, 1, args.n))
        else
            remote:FireServer(table.unpack(args, 1, args.n))
        end
    end)
    return ok
end

local Bypass = { Disabled = {}, Originals = {} }

function Bypass.Init()
    local modules = findController({"anticheat","validation","sanity","security","antiexploit","checks","ratelimit"})
    if not modules then
        notify("bypass: no client validator exposed", "warn")
        return 0
    end
    local tbl = requireModule(modules)
    if type(tbl) ~= "table" then
        notify("bypass: module not a table", "warn")
        return 0
    end
    local killed = 0
    for key, value in pairs(tbl) do
        if type(value) == "function" then
            local low = tostring(key):lower()
            if low:find("valid") or low:find("check") or low:find("verify") or
               low:find("sanity") or low:find("limit") or low:find("detect") or
               low:find("allowed") then
                if not Bypass.Originals[key] then
                    Bypass.Originals[key] = {module = modules, fn = value}
                end
                tbl[key] = function() return true end
                killed += 1
            end
        elseif type(value) == "boolean" and value == false then
            Bypass.Disabled[key] = true
        end
    end
    notify("bypass: " .. killed .. " validators neutralized")
    return killed
end

function Bypass.Restore()
    for key, record in pairs(Bypass.Originals) do
        local tbl = requireModule(record.module)
        if type(tbl) == "table" then tbl[key] = record.fn end
    end
    table.clear(Bypass.Originals)
end

function Bypass.PacedFire(remote, ...)
    if not remote then return false end
    local args = table.pack(...)
    local pause = 0.03 + math.random() * 0.05
    task.spawn(function()
        task.wait(pause)
        fireRemote(remote, table.unpack(args, 1, args.n))
    end)
    return true
end

local throwRemote, collectRemote, buyRemote, trainRemote
local upgradeRemote, claimRemote, sellRemote, placeRemote

local function refreshRemotes()
    throwRemote = findRemote({"throw","throwfood","throwitem","launch"})
    collectRemote = findRemote({"collect","catch","take","claimpet","pickup"})
    buyRemote = findRemote({"buy","purchase","buyfood","shop"})
    trainRemote = findRemote({"train","workout","pullup","exercise"})
    upgradeRemote = findRemote({"upgrade","strength","fence"})
    claimRemote = findRemote({"claim","offline","collectcash"})
    sellRemote = findRemote({"sell","sellpet","dismiss"})
    placeRemote = findRemote({"place","deploy","equippet","base"})
    return {
        throw = throwRemote, collect = collectRemote, buy = buyRemote,
        train = trainRemote, upgrade = upgradeRemote, claim = claimRemote,
        sell = sellRemote, place = placeRemote,
    }
end

local function getMeter()
    if state.Meter then return state.Meter end
    local mod = findController({"throwmeter","throwmeterclient","meter"})
    local tbl = requireModule(mod)
    if type(tbl) == "table" and (type(tbl.Run) == "function" or type(tbl.Throw) == "function") then
        state.Meter = tbl
        if type(tbl.Run) == "function" then
            state.OriginalRun = tbl.Run
            if cfg.PerfectThrow then installMeterHook(tbl) end
        end
        return tbl
    end
    return nil
end

function installMeterHook(meter)
    if type(meter.Run) ~= "function" or meter.__VoidHooked then return false end
    state.OriginalRun = meter.Run
    local original = meter.Run
    meter.__VoidHooked = true
    meter.Run = function(instance, ...)
        meter.TestAutoTap = 0.6
        pcall(function() if instance and instance.SetLocked then instance:SetLocked(true) end end)
        local result = table.pack(pcall(original, instance, ...))
        if not result[1] then
            notify("meter error: " .. tostring(result[2]), "warn")
            return
        end
        state.Throws += 1
        return table.unpack(result, 2, result.n)
    end
    notify("meter hooked")
    return true
end

function restoreMeterHook()
    if state.Meter and state.OriginalRun and state.Meter.Run ~= state.OriginalRun then
        state.Meter.Run = state.OriginalRun
    end
    if state.Meter then state.Meter.__VoidHooked = nil end
end

local function doThrow(meter)
    meter = meter or getMeter()
    if not meter then return false end
    if cfg.SkipCutscene then
        pcall(function() if meter.SkipCutscene ~= nil then meter.SkipCutscene = true end end)
    end
    meter.TestAutoTap = 0.6
    local counted = meter.__VoidHooked and meter.Run ~= state.OriginalRun
    local ok = pcall(function()
        if type(meter.Run) == "function" then
            meter.Run(meter.Instance or meter.Controller or meter)
        elseif type(meter.Throw) == "function" then
            meter.Throw()
        end
    end)
    if ok and not counted then state.Throws += 1 end
    if throwRemote then Bypass.PacedFire(throwRemote, cfg.TargetArea, cfg.TargetFood) end
    return ok
end

local function doCollect()
    if not collectRemote then return false end
    local ok = Bypass.PacedFire(collectRemote, "all")
    if ok then state.Catches += 1 end
    return ok
end

local function doPlace()
    if not placeRemote then return false end
    return Bypass.PacedFire(placeRemote, "best")
end

local function doSell()
    if not sellRemote then return false end
    local ok = Bypass.PacedFire(sellRemote, "extras", cfg.MinCashKeep)
    if ok then state.Sold += 1 end
    return ok
end

local function doBuyFood()
    if not buyRemote then return false end
    local ok = Bypass.PacedFire(buyRemote, cfg.TargetFood)
    notify("buy: " .. cfg.TargetFood)
    return ok
end

local function doClaim()
    if not claimRemote then return false end
    local ok = Bypass.PacedFire(claimRemote, "offline")
    notify("offline claim sent")
    return ok
end

local function doTrain()
    local tbl = requireModule(findController({"traincontroller","training","pullup","train"}))
    if tbl and type(tbl.Press) == "function" then
        local ok = pcall(function() tbl.Press(true) end)
        if ok then return true end
    end
    if trainRemote then return Bypass.PacedFire(trainRemote, "press", 2) end
    return false
end

local function doUpgrade()
    if not upgradeRemote then return false end
    local targets = {"strength","food","fence"}
    return Bypass.PacedFire(upgradeRemote, targets[(state.Throws % #targets) + 1])
end

local function getCash()
    local leader = player:FindFirstChild("leaderstats")
    if not leader then return 0 end
    for _, obj in ipairs(leader:GetChildren()) do
        local low = obj.Name:lower()
        if low:find("cash") or low:find("money") or low:find("coin") then
            local ok, value = pcall(function() return obj.Value end)
            if ok and type(value) == "number" then return value end
        end
    end
    return 0
end

local function getPetCount()
    local folder = player:FindFirstChild("Pets") or player:FindFirstChild("Animals")
        or workspace:FindFirstChild("Pets") or workspace:FindFirstChild("Animals")
    if not folder then return 0 end
    return #folder:GetChildren()
end

local function dumpMap(withPost)
    local productName = "Throw Food For Animals"
    pcall(function()
        productName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or productName
    end)
    local data = {
        meta = {placeId = game.PlaceId, gameName = productName,
            dumpedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), by = player.Name},
        areas = {}, parts = {}, animals = {}, remotes = {}, controllers = {},
    }
    for _, name in ipairs(AREAS) do table.insert(data.areas, {name = name}) end
    local partCount = 0
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if partCount >= 12000 then break end
            if obj:IsA("BasePart") then
                partCount += 1
                local ok, pos, size, anchored, transparency = pcall(function()
                    return obj.Position, obj.Size, obj.Anchored, obj.Transparency
                end)
                if ok and pos and size then
                    data.parts[partCount] = {
                        n = obj.Name, c = obj.ClassName,
                        p = {math.floor(pos.X*100)/100, math.floor(pos.Y*100)/100, math.floor(pos.Z*100)/100},
                        s = {math.floor(size.X*100)/100, math.floor(size.Y*100)/100, math.floor(size.Z*100)/100},
                        a = anchored and 1 or 0, t = transparency or 0,
                    }
                end
            elseif obj:IsA("Model") then
                local low = obj.Name:lower()
                for _, name in ipairs(AREAS) do
                    if low:find(name:lower(), 1, true) then
                        local ok, pivot = pcall(function() return obj:GetPivot() end)
                        if ok and pivot then
                            table.insert(data.animals, {n = obj.Name,
                                p = {math.floor(pivot.X*100)/100, math.floor(pivot.Y*100)/100, math.floor(pivot.Z*100)/100},
                                tag = name})
                        end
                        break
                    end
                end
            end
        end
    end)
    pcall(function()
        for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                table.insert(data.remotes, {n = obj.Name, c = obj.ClassName, p = describe(obj)})
            end
        end
    end)
    for key, obj in pairs(state.ControllerCache) do
        table.insert(data.controllers, {key = key, p = describe(obj)})
    end
    local json = HttpService:JSONEncode(data)
    local wrote = false
    if writefile then wrote = safe(writefile, "TFFA_map.json", json) ~= nil end
    state.Dumped = partCount + #data.animals
    notify("dump: " .. state.Dumped .. " records" .. (wrote and " -> file" or ""), wrote and "ok" or "warn")
    if withPost and cfg.Webhook ~= "" then
        local send = (type(syn) == "table" and syn.request) or
                     (type(request) == "function" and request) or
                     (type(http_request) == "function" and http_request)
        if send then
            task.spawn(function()
                safe(send, {Url = cfg.Webhook, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({content = "map dump",
                        files = {{filename = "TFFA_map.json", content = json}}})})
            end)
        else
            notify("webhook: no request function", "warn")
        end
    end
    return data
end

local function espRelease(entry)
    if not entry then return end
    if entry.kind == "drawing" then
        safe(function() entry.circle.Visible = false entry.circle:Remove() end)
        safe(function() entry.text.Visible = false entry.text:Remove() end)
    else
        safe(function() if entry.gui then entry.gui:Destroy() end end)
    end
end

function clearESP()
    for _, entry in ipairs(state.ESPObjects) do espRelease(entry) end
    table.clear(state.ESPObjects)
end

local function espCreate(part)
    if type(Drawing) == "table" and type(Drawing.new) == "function" then
        local okC, circle = pcall(Drawing.new, "Circle")
        local okT, text = pcall(Drawing.new, "Text")
        if okC and okT and circle and text then
            circle.Radius, circle.Thickness = 16, 1.4
            circle.Color, circle.Filled, circle.Visible = C.Accent, false, false
            text.Size, text.Center, text.Outline = 12, true, true
            text.Color, text.Visible = C.Text, false
            return {kind = "drawing", circle = circle, text = text}
        end
    end
    local holder = state.ESPHolder
    if not holder or not holder.Parent then
        local gui = player:FindFirstChild("PlayerGui")
        holder = Instance.new("Folder")
        holder.Name = "VoidChartESP"
        if gui then holder.Parent = gui end
        state.ESPHolder = holder
    end
    local bill = Instance.new("BillboardGui")
    bill.Name = "VoidESP"
    bill.Size = UDim2.new(0, 44, 0, 44)
    bill.AlwaysOnTop = true
    bill.MaxDistance = math.huge
    bill.Enabled = false
    bill.Parent = holder
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0.5, -6, 0.5, -6)
    dot.BackgroundColor3 = C.Accent
    dot.BackgroundTransparency = 0.15
    dot.BorderSizePixel = 0
    dot.Parent = bill
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 130, 0, 16)
    label.Position = UDim2.new(0.5, -65, 0, -18)
    label.BackgroundTransparency = 1
    label.Font = FONT_B
    label.TextSize = 10
    label.TextColor3 = C.Text
    label.TextStrokeTransparency = 0.3
    label.Parent = bill
    return {kind = "gui", gui = bill, dot = dot, label = label}
end

local function espApply(entry, model, part, cam)
    if entry.kind == "drawing" then
        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
        entry.circle.Position = Vector2.new(pos.X, pos.Y)
        entry.circle.Visible = onScreen
        entry.text.Position = Vector2.new(pos.X, pos.Y - 24)
        entry.text.Text = cfg.ESPNames and model.Name or ""
        entry.text.Visible = onScreen and cfg.ESPNames
    else
        entry.gui.Adornee = part
        entry.gui.Parent = part
        entry.gui.Enabled = true
        entry.label.Text = cfg.ESPNames and model.Name or ""
        entry.label.Visible = cfg.ESPNames
    end
end

local function espHide(entry)
    if not entry then return end
    if entry.kind == "drawing" then
        entry.circle.Visible = false
        entry.text.Visible = false
    else
        entry.gui.Enabled = false
    end
end

local function updateESP()
    local cam = workspace.CurrentCamera
    if not cam then return 0 end
    local folder = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("Animals")
        or workspace:FindFirstChild("LoosePets") or workspace:FindFirstChild("DroppedPets")
    if not folder then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local low = obj.Name:lower()
            if obj:IsA("Model") and (low:find("pet") or low:find("animal") or low:find("drop")) then
                folder = obj
                break
            end
        end
    end
    if not folder then
        clearESP()
        return 0
    end
    local idx = 0
    for _, model in ipairs(folder:GetChildren()) do
        if not (model:IsA("Model") or model:IsA("BasePart")) then continue end
        local part = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart")
        if not part then continue end
        idx += 1
        local entry = state.ESPObjects[idx]
        if not entry then
            entry = espCreate(part)
            state.ESPObjects[idx] = entry
        end
        espApply(entry, model, part, cam)
    end
    for i = idx + 1, #state.ESPObjects do espHide(state.ESPObjects[i]) end
    return idx
end

local api = {}

local screen = Instance.new("ScreenGui")
screen.Name = "VoidChart"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 1000
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player:WaitForChild("PlayerGui")

local function make(class, props, children)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        pcall(function() obj[key] = value end)
    end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    return obj
end

local function tint(color, factor)
    return Color3.new(math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1), math.clamp(color.B * factor, 0, 1))
end

local function seq(a, b)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b),
    })
end

local function fade(a, b)
    return NumberSequence.new({
        NumberSequenceKeypoint.new(0, a),
        NumberSequenceKeypoint.new(b ~= nil and 0.55 or 1, b or a),
        NumberSequenceKeypoint.new(1, b or a),
    })
end

local function gradient(parent, from, to, rotation, transparency)
    local props = {Rotation = rotation or 0, Parent = parent}
    if from then props.Color = seq(from, to or from) end
    if transparency then props.Transparency = transparency end
    return make("UIGradient", props)
end

local function rect(parent, x, y, w, h, color, z, radius)
    local props = {
        Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = z or 1, Parent = parent,
    }
    local children = {}
    if radius then table.insert(children, make("UICorner", {CornerRadius = UDim.new(0, radius)})) end
    return make("Frame", props, children)
end

local function label(parent, text, x, y, w, h, size, color, bold, align, z)
    return make("TextLabel", {
        Text = text, Font = bold and FONT_B or FONT, TextSize = size,
        TextColor3 = color or C.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.72, ZIndex = z or 3, Parent = parent,
    })
end

local function panel(parent, x, y, w, h, base, z, radius)
    local z0 = z or 1
    local shadow = rect(parent, x + 4, y + 5, w, h, C.Black, z0)
    shadow.BackgroundTransparency = 0.58
    local extrude = rect(parent, x, y + 3, w, h, tint(base, 0.62), z0 + 1, radius)
    local face = make("Frame", {
        Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
        BackgroundColor3 = base, BorderSizePixel = 0, ZIndex = z0 + 2, Parent = parent,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, radius or 5)}),
        make("UIStroke", {Color = tint(base, 1.5), Thickness = 1, Transparency = 0.42,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border}),
    })
    gradient(face, tint(base, 1.22), base, 90)
    local highlight = rect(face, 1, 1, w - 2, 1, tint(base, 2.1), z0 + 3)
    rect(face, 1, h - 2, w - 2, 1, tint(base, 0.55), z0 + 3)
    face.Extrude = extrude
    face.Highlight = highlight
    return face
end

local function inset(parent, x, y, w, h, z, radius)
    local well = rect(parent, x, y, w, h, C.Black, z or 2, radius or 3)
    well.BackgroundTransparency = 0.35
    local face = rect(parent, x + 1, y + 1, w - 2, h - 2, tint(C.Base, 0.55), (z or 2) + 1, radius or 3)
    gradient(face, tint(C.Base, 0.4), tint(C.Panel, 0.9), 90)
    rect(face, 0, 0, w - 2, 1, C.Black, (z or 2) + 2)
    return face
end

local function glowDot(parent, x, y, size, color, z)
    local halo = rect(parent, x - 3, y - 3, size + 6, size + 6, color, z or 3, 8)
    halo.BackgroundTransparency = 0.78
    local core = rect(parent, x, y, size, size, color, (z or 3) + 1, 8)
    gradient(core, tint(color, 1.6), color, 90)
    return halo, core
end

local function bevelButton(parent, x, y, w, h, text, glyphSize, onClick, z)
    local base = panel(parent, x, y, w, h, C.Raised, z or 3, 4)
    local face = make("TextButton", {
        Text = text, Font = FONT_B, TextSize = glyphSize or 12, TextColor3 = C.Muted,
        BackgroundTransparency = 1, Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, w, 0, h), ZIndex = (z or 3) + 4, Parent = parent,
    })
    face.MouseButton1Click:Connect(onClick)
    return face, base
end

local mainShadow = make("Frame", {
    Name = "VoidShadow", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(BASE_W, BASE_H),
    BackgroundColor3 = C.Black, BackgroundTransparency = 0.62,
    BorderSizePixel = 0, ZIndex = 0, Parent = screen,
}, {make("UICorner", {CornerRadius = UDim.new(0, 12)})})

local main = make("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(BASE_W, BASE_H),
    BackgroundColor3 = C.Base, BorderSizePixel = 0, ZIndex = 1, Parent = screen,
}, {
    make("UICorner", {CornerRadius = UDim.new(0, 10)}),
    make("UIStroke", {Color = C.Line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}),
})
gradient(main, tint(C.Panel, 1.12), C.Base, 90)

local uiScale = make("UIScale", {Scale = 1, Parent = main})
local shadowScale = make("UIScale", {Scale = 1, Parent = mainShadow})
local function fitToViewport()
    local vp = screen.AbsoluteSize
    if not vp or vp.X < 1 or vp.Y < 1 then return end
    local height = collapsed and 53 or BASE_H
    local scale = math.min(1, (vp.X - 14) / BASE_W, (vp.Y - 52) / height)
    uiScale.Scale = math.max(0.3, scale)
    shadowScale.Scale = uiScale.Scale
end

local header = make("Frame", {
    Name = "Header", Size = UDim2.new(1, 0, 0, 53),
    BackgroundColor3 = C.Panel, BorderSizePixel = 0, ZIndex = 2, Parent = main,
})
gradient(header, tint(C.RaisedHi, 1.05), C.Panel, 90)
rect(header, 0, 52, BASE_W, 2, C.Black, 3)
rect(header, 0, 51, BASE_W, 1, tint(C.Line, 1.5), 3)

local logo = panel(header, 16, 13, 25, 25, C.AccentD, 3, 4)
label(header, G.Mark, 20, 14, 18, 22, 15, C.AccentHi, true, nil, 5)
label(header, "V O I D C H A R T", 52, 10, 260, 22, 14, C.Text, true, nil, 4)
label(header, "T F F A   /   L O C A L   C O N T R O L   /   0 5", 53, 30, 310, 14, 9, C.Muted, false, nil, 4)
for i = 0, 2 do rect(header, BASE_W - 122, 19 + i * 6, 22, 1, tint(C.Muted, 0.7), 4) end

local suppressDrag = false
local function headerButton(x, glyph, onClick)
    local face = bevelButton(header, x, 15, 24, 23, glyph, 13, onClick, 4)
    face.InputBegan:Connect(function() suppressDrag = true end)
    face.InputEnded:Connect(function() suppressDrag = false end)
    return face
end

local rail = make("Frame", {
    Name = "Rail", Position = UDim2.new(0, 0, 0, 54),
    Size = UDim2.new(0, 137, 1, -83), BackgroundColor3 = C.Panel,
    BorderSizePixel = 0, ZIndex = 2, Parent = main,
})
gradient(rail, tint(C.Panel, 1.1), tint(C.Base, 0.9), 90)
rect(rail, 136, 0, 1, BASE_H, C.Black, 3)
rect(rail, 135, 0, 1, BASE_H, tint(C.Line, 1.2), 3)

local content = make("Frame", {
    Name = "Content", Position = UDim2.new(0, 138, 0, 54),
    Size = UDim2.new(1, -138, 1, -83), BackgroundTransparency = 1,
    ZIndex = 2, Parent = main,
}, {make("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingTop = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0, 12)})})

local statusbar = make("Frame", {
    Name = "Status", Position = UDim2.new(0, 0, 1, -28), Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = C.Panel, BorderSizePixel = 0, ZIndex = 2, Parent = main,
})
gradient(statusbar, tint(C.Panel, 1.15), tint(C.Base, 0.8), 90)
rect(statusbar, 0, 0, BASE_W, 1, C.Black, 3)
local ledHalo, ledCore = glowDot(statusbar, 14, 11, 6, C.Accent, 3)
state.LED = ledCore
state.StatusText = label(statusbar, "system ready", 31, 6, 340, 16, 10, C.Accent, false, nil, 4)
state.CounterText = label(statusbar, "T 000  C 000  S 000", BASE_W - 216, 6, 200, 16, 10,
    C.Muted, false, Enum.TextXAlignment.Right, 4)

local collapsed = false
local minBtn
minBtn = headerButton(BASE_W - 84, "─", function()
    collapsed = not collapsed
    rail.Visible = not collapsed
    content.Visible = not collapsed
    statusbar.Visible = not collapsed
    main.Size = collapsed and UDim2.fromOffset(BASE_W, 53) or UDim2.fromOffset(BASE_W, BASE_H)
    mainShadow.Size = main.Size
    minBtn.Text = collapsed and "+" or "─"
    fitToViewport()
end)
headerButton(BASE_W - 54, G.Close, function()
    if env.VoidChart then env.VoidChart:Stop() end
end)

fitToViewport()
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToViewport)
task.defer(fitToViewport)

local dragInput, dragStart, dragOrigin
local function beginDrag(input)
    if suppressDrag then return end
    local t = input.UserInputType
    if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
    dragInput = input
    dragStart = Vector2.new(input.Position.X, input.Position.Y)
    dragOrigin = Vector2.new(main.Position.X.Offset, main.Position.Y.Offset)
end
header.InputBegan:Connect(beginDrag)
header.InputChanged:Connect(function(input)
    if input ~= dragInput or not dragStart then return end
    local t = input.UserInputType
    if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
    local vp = screen.AbsoluteSize
    local dx = input.Position.X - dragStart.X
    local dy = input.Position.Y - dragStart.Y
    local halfW = BASE_W * uiScale.Scale / 2
    local halfH = (collapsed and 53 or BASE_H) * uiScale.Scale / 2
    local x = math.clamp(dragOrigin.X + dx, -vp.X/2 + halfW, vp.X/2 - halfW)
    local y = math.clamp(dragOrigin.Y + dy, -vp.Y/2 + halfH, vp.Y/2 - halfH)
    local pos = UDim2.fromOffset(vp.X/2 + x, vp.Y/2 + y)
    main.Position = pos
    mainShadow.Position = pos + UDim2.fromOffset(4 * uiScale.Scale, 5 * uiScale.Scale)
end)
header.InputEnded:Connect(function(input)
    if input == dragInput then dragInput, dragStart = nil, nil end
end)

local tabs, activeTab = {}, nil

local function section(parent, num, title, order)
    local holder = make("Frame", {Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1, LayoutOrder = order or 0, ZIndex = 2, Parent = parent})
    local badge = rect(holder, 0, 3, 22, 17, C.AccentD, 3, 3)
    gradient(badge, tint(C.AccentD, 1.4), C.AccentD, 90)
    label(holder, num, 0, 3, 22, 17, 9, C.AccentHi, true, Enum.TextXAlignment.Center, 4)
    label(holder, title:upper(), 29, 3, 200, 17, 9, C.Muted, true, nil, 4)
    rect(holder, 150, 11, 384, 1, C.LineDim, 3)
    rect(holder, 150, 12, 384, 1, C.Black, 3)
    return holder
end

local function addTab(num, name, glyph, builder)
    local index = #tabs + 1
    local btn = make("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, (index - 1) * 47),
        Size = UDim2.new(1, 0, 0, 47), ZIndex = 3, Parent = rail,
    })
    local face = panel(btn, 2, 2, 132, 43, C.Panel, 3, 4)
    local edge = rect(btn, 0, 5, 2, 33, C.LineDim, 6)
    label(btn, num, 13, 7, 20, 14, 9, C.Muted, true, nil, 7)
    label(btn, glyph, 36, 12, 22, 22, 15, C.Muted, false, nil, 7)
    label(btn, name:upper(), 66, 14, 62, 18, 11, C.Muted, true, nil, 7)
    local page = make("Frame", {Name = name .. "Page", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Visible = false, ZIndex = 2, Parent = content},
        {make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
    local entry = {Name = name, Button = btn, Face = face, Edge = edge, Page = page,
        Builder = builder, Built = false}
    tabs[index] = entry
    btn.MouseButton1Click:Connect(function() entry:Select() end)
    function entry:Select()
        if activeTab == self then return end
        if activeTab then
            activeTab.Page.Visible = false
            activeTab.Face.BackgroundColor3 = C.Panel
            activeTab.Edge.BackgroundColor3 = C.LineDim
            for _, obj in ipairs(activeTab.Button:GetChildren()) do
                if obj:IsA("TextLabel") then obj.TextColor3 = C.Muted end
            end
        end
        activeTab = self
        self.Page.Visible = true
        self.Face.BackgroundColor3 = C.RaisedHi
        self.Edge.BackgroundColor3 = C.Accent
        for i, obj in ipairs(self.Button:GetChildren()) do
            if obj:IsA("TextLabel") then
                obj.TextColor3 = (i % 3 == 0) and C.AccentHi or C.Text
            end
        end
        if not self.Built then
            self.Built = true
            self.Builder(self.Page)
        end
    end
    return entry
end

local function stepKnob(knob, on)
    local target = on and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 3, 0, 3)
    TweenService:Create(knob, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = target}):Play()
end

local function switchRow(parent, text, key, order, onChange)
    local row = panel(parent, 0, 0, 534, 38, C.Raised, 2, 5)
    row.LayoutOrder = order or 0
    rect(row, 0, 0, 2, 38, C.Line, 5)
    label(row, text:upper(), 12, 10, 290, 17, 10, C.Text, true, nil, 6)
    local status = label(row, cfg[key] and "ON" or "OFF", 424, 11, 38, 16, 9,
        cfg[key] and C.Accent or C.Muted, true, Enum.TextXAlignment.Right, 6)
    local trough = inset(row, 470, 8, 52, 22, 5, 4)
    local track = rect(trough, 1, 1, 50, 20, cfg[key] and C.AccentD or C.Line, 6, 3)
    local knob = panel(track, cfg[key] and 30 or 2, 2, 18, 16,
        cfg[key] and C.Accent or C.Muted, 7, 3)
    local pip = rect(knob, 7, 6, 4, 4, C.Black, 10, 2)
    pip.BackgroundTransparency = 0.35
    local hit = make("TextButton", {Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 12, Parent = row})
    hit.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        status.Text = cfg[key] and "ON" or "OFF"
        status.TextColor3 = cfg[key] and C.Accent or C.Muted
        track.BackgroundColor3 = cfg[key] and C.AccentD or C.Line
        knob.Extrude.BackgroundColor3 = cfg[key] and tint(C.Accent, 0.55) or tint(C.Muted, 0.55)
        knob.Highlight.BackgroundColor3 = cfg[key] and C.AccentHi or tint(C.Muted, 2)
        stepKnob(knob, cfg[key])
        notify(text .. " " .. (cfg[key] and "on" or "off"))
        if onChange then onChange(cfg[key]) end
    end)
    return row
end

local function actionSwitch(parent, text, glyph, order, onClick)
    local row = panel(parent, 0, 0, 534, 38, C.Raised, 2, 5)
    row.LayoutOrder = order or 0
    rect(row, 0, 0, 2, 38, tint(C.Amber, 0.75), 5)
    label(row, glyph .. "   " .. text:upper(), 12, 10, 330, 17, 10, C.Text, true, nil, 6)
    local status = label(row, "IDLE", 418, 11, 44, 16, 9, C.Muted, true, Enum.TextXAlignment.Right, 6)
    local trough = inset(row, 470, 8, 52, 22, 5, 4)
    local track = rect(trough, 1, 1, 50, 20, C.Line, 6, 3)
    local knob = panel(track, 2, 2, 18, 16, C.Muted, 7, 3)
    local firing = false
    local hit = make("TextButton", {Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 12, Parent = row})
    hit.MouseButton1Click:Connect(function()
        if firing then return end
        firing = true
        status.Text, status.TextColor3 = "FIRE", C.Amber
        track.BackgroundColor3 = C.AccentD
        knob.Extrude.BackgroundColor3 = tint(C.Amber, 0.55)
        knob.Highlight.BackgroundColor3 = tint(C.Amber, 1.6)
        stepKnob(knob, true)
        local ok, err = pcall(onClick)
        if not ok then notify(tostring(err), "bad") end
        task.delay(0.45, function()
            status.Text, status.TextColor3 = "IDLE", C.Muted
            track.BackgroundColor3 = C.Line
            knob.Extrude.BackgroundColor3 = tint(C.Muted, 0.55)
            knob.Highlight.BackgroundColor3 = tint(C.Muted, 2)
            stepKnob(knob, false)
            firing = false
        end)
    end)
    return row
end

local function levelRow(parent, text, key, min, max, step, order)
    local row = panel(parent, 0, 0, 534, 54, C.Raised, 2, 5)
    row.LayoutOrder = order or 0
    rect(row, 0, 0, 2, 54, C.Line, 5)
    label(row, text:upper(), 12, 6, 260, 16, 10, C.Text, true, nil, 6)
    local display = inset(row, 436, 5, 84, 20, 5, 3)
    local value = label(display, string.format("%.2f", cfg[key]), 2, 2, 80, 16, 10,
        C.AccentHi, true, Enum.TextXAlignment.Center, 7)
    local trough = inset(row, 12, 34, 508, 10, 5, 3)
    local track = rect(trough, 1, 4, 506, 2, C.LineDim, 6)
    local fill = rect(track, 0, 0, (cfg[key] - min) / (max - min) * 506, 2, C.Accent, 7)
    gradient(fill, C.AccentD, C.AccentHi, 0)
    for i = 1, 8 do
        local tick = rect(trough, i * 56, 1, 1, 8, C.Line, 7)
        tick.BackgroundTransparency = 0.25
    end
    local thumb = rect(trough, (cfg[key] - min) / (max - min) * 506 - 3, 0, 7, 10, C.AccentHi, 8, 2)
    local hit = make("TextButton", {Text = "", BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 29), Size = UDim2.new(1, -16, 0, 22),
        ZIndex = 12, Parent = row})
    local active = false
    local function applyPosition(x)
        local width = trough.AbsoluteSize.X > 0 and trough.AbsoluteSize.X or 506
        local rel = math.clamp((x - trough.AbsolutePosition.X) / width, 0, 1)
        local v = math.floor((min + rel * (max - min)) / step + 0.5) * step
        v = math.clamp(math.floor(v * 100) / 100, min, max)
        cfg[key] = v
        value.Text = string.format("%.2f", v)
        fill.Size = UDim2.new(0, (v - min) / (max - min) * 506, 0, 2)
        thumb.Position = UDim2.new(0, (v - min) / (max - min) * 506 - 3, 0, 0)
        return v
    end
    hit.MouseButton1Down:Connect(function() active = true end)
    hit.MouseButton1Up:Connect(function() active = false end)
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            active = true
            applyPosition(input.Position.X)
        end
    end)
    hit.InputChanged:Connect(function(input)
        if not active then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            applyPosition(input.Position.X)
        end
    end)
    hit.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
    mouse.Move:Connect(function()
        if active then applyPosition(mouse.X) end
    end)
    return row
end

local function stepperRow(parent, text, options, key, order)
    local row = panel(parent, 0, 0, 534, 52, C.Raised, 2, 5)
    row.LayoutOrder = order or 0
    rect(row, 0, 0, 2, 52, C.Line, 5)
    label(row, text:upper(), 12, 6, 260, 16, 10, C.Text, true, nil, 6)
    local current = 1
    for i, v in ipairs(options) do if v == cfg[key] then current = i end end
    local display = inset(row, 72, 27, 390, 20, 5, 3)
    local value = label(display, options[current], 2, 1, 386, 18, 10, C.AccentHi,
        true, Enum.TextXAlignment.Center, 7)
    local function shift(d)
        current = ((current - 1 + d) % #options) + 1
        cfg[key] = options[current]
        value.Text = options[current]
        notify(text .. ": " .. options[current])
    end
    bevelButton(row, 12, 26, 52, 22, G.Left, 11, function() shift(-1) end, 5)
    bevelButton(row, 470, 26, 52, 22, G.Right, 11, function() shift(1) end, 5)
    return row
end

local function note(parent, text, order)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
        LayoutOrder = order or 0, ZIndex = 2, Parent = parent})
    label(row, "// " .. text, 2, 2, 528, 20, 9, C.Muted, false, nil, 4)
    return row
end

addTab("01", "Farm", G.Throw, function(page)
    section(page, "01", "throw control", 1)
    switchRow(page, "Auto Throw", "AutoThrow", 2)
    switchRow(page, "Perfect Throw", "PerfectThrow", 3)
    switchRow(page, "Skip Cutscene", "SkipCutscene", 4)
    levelRow(page, "Throw Interval", "ThrowDelay", 0.12, 1.2, 0.01, 5)
    section(page, "02", "collection", 6)
    switchRow(page, "Auto Collect", "AutoCollect", 7)
    switchRow(page, "Auto Place Best", "AutoPlace", 8)
    switchRow(page, "Auto Sell Extras", "AutoSell", 9)
    stepperRow(page, "Target Food", FOODS, "TargetFood", 10)
    stepperRow(page, "Target Area", AREAS, "TargetArea", 11)
    actionSwitch(page, "Throw Once", G.Throw, 12, function()
        if getMeter() then doThrow() else notify("meter not linked", "warn") end
    end)
    note(page, "meter forced to 0.6 before release; cutscene wait bypassed", 13)
end)

addTab("02", "Train", G.Train, function(page)
    section(page, "01", "training", 1)
    switchRow(page, "Auto Train", "AutoTrain", 2)
    levelRow(page, "Train Interval", "TrainDelay", 0.08, 1.0, 0.01, 3)
    section(page, "02", "economy", 4)
    switchRow(page, "Auto Buy Food", "AutoBuyFood", 5)
    switchRow(page, "Auto Upgrade", "AutoUpgrade", 6)
    switchRow(page, "Auto Claim Cash", "AutoClaim", 7)
    actionSwitch(page, "Claim Offline Cash", G.Pulse, 8, doClaim)
    actionSwitch(page, "Buy Next Food", G.Shop, 9, doBuyFood)
    note(page, "2x press path used when exposed; maxed upgrades skipped", 10)
end)

addTab("03", "Map", G.Map, function(page)
    section(page, "01", "survey", 1)
    actionSwitch(page, "Dump Map To File", G.Map, 2, function() dumpMap(false) end)
    actionSwitch(page, "Dump And POST", G.Throw, 3, function() dumpMap(true) end)
    switchRow(page, "Dump On Start", "DumpOnStart", 4)
    section(page, "02", "overlay", 5)
    switchRow(page, "Animal ESP", "ESP", 6)
    switchRow(page, "Show Names", "ESPNames", 7, function(on) if not on then clearESP() end end)
    local boxWrap = inset(page, 2, 0, 530, 32, 5, 4)
    local box = make("TextBox", {Text = cfg.Webhook, Font = FONT, TextSize = 9,
        TextColor3 = C.Text, BackgroundTransparency = 1,
        PlaceholderColor3 = C.Muted, PlaceholderText = "webhook url",
        Position = UDim2.new(0, 8, 0, 4), Size = UDim2.new(1, -16, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
        ZIndex = 7, Parent = boxWrap})
    box.FocusLost:Connect(function() cfg.Webhook = box.Text end)
    note(page, "output: TFFA_map.json in executor files", 8)
end)

addTab("04", "System", G.Shield, function(page)
    section(page, "01", "defenses", 1)
    actionSwitch(page, "Neuter Validators", G.Shield, 2, function()
        api:Bypass()
    end)
    actionSwitch(page, "Rescan Controllers", G.Search, 3, function()
        state.ControllerCache, state.RemoteCache = {}, {}
        local found = refreshRemotes()
        local meter = getMeter()
        local count = 0
        for _ in pairs(found) do count += 1 end
        notify("rescan: meter " .. (meter and "linked" or "pending") .. ", " .. count .. " channels",
            meter and "ok" or "warn")
    end)
    switchRow(page, "Anti AFK", "AntiAFK", 4)
    levelRow(page, "Walk Speed", "WalkSpeed", 16, 220, 1, 5)
    section(page, "02", "runtime", 6)
    actionSwitch(page, "Save Config", "▤", 7, function()
        if writefile then
            safe(writefile, "TFFA_VoidChart_config.json", HttpService:JSONEncode(cfg))
            notify("config saved")
        else
            notify("writefile unavailable", "warn")
        end
    end)
    actionSwitch(page, "Stop Script", "■", 8, function()
        if env.VoidChart then env.VoidChart:Stop() end
    end)
    note(page, "remotes and validators resolved by name pattern on boot", 9)
end)

tabs[1]:Select()

local lastThrow, lastTrain, lastBuy, lastUpgrade, lastClaim = 0, 0, 0, 0, 0

local loopConnection = RunService.Heartbeat:Connect(function()
    if not state.Running then return end
    local now = os.clock()
    if ledHalo then ledHalo.BackgroundTransparency = 0.66 + 0.12 * math.sin(now * 2.6) end
    if cfg.ESP then
        local ok = pcall(updateESP)
        if not ok then clearESP() end
    elseif #state.ESPObjects > 0 then
        clearESP()
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
        if getMeter() then
            doThrow()
            if cfg.AutoCollect then task.spawn(function() task.wait(0.6) doCollect() end) end
            if cfg.AutoPlace then task.spawn(function() task.wait(1.0) doPlace() end) end
            if cfg.AutoSell and getPetCount() >= cfg.MaxPets then task.spawn(doSell) end
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
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= cfg.WalkSpeed then humanoid.WalkSpeed = cfg.WalkSpeed end
    end
    state.CounterText.Text = string.format("T %03d  C %03d  S %03d", state.Throws, state.Catches, state.Sold)
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

function api:Stop()
    if not state.Running then return false end
    state.Running = false
    for _, conn in ipairs(state.Connections) do safe(function() conn:Disconnect() end) end
    table.clear(state.Connections)
    clearESP()
    restoreMeterHook()
    Bypass.Restore()
    screen:Destroy()
    if state.ESPHolder then safe(function() state.ESPHolder:Destroy() end) end
    self.Running = false
    env.VoidChart = nil
    return true
end

function api:GetConfig() return cfg end
function api:GetState() return state end
function api:Dump(withPost) return dumpMap(withPost == true) end
function api:Bypass() return Bypass.Init() end
function api:Refresh() return refreshRemotes() end
function api:Throw(meter) return doThrow(meter) end
function api:Collect() return doCollect() end
function api:Place() return doPlace() end
function api:Sell() return doSell() end
function api:BuyFood() return doBuyFood() end
function api:Claim() return doClaim() end
function api:Train() return doTrain() end
function api:Upgrade() return doUpgrade() end
function api:ESP() return updateESP() end
function api:Notify(text, kind) notify(text, kind) end

api.Running = true
env.VoidChart = api

task.spawn(function()
    refreshRemotes()
    getMeter()
    if cfg.DumpOnStart then dumpMap(false) end
    Bypass.Init()
    notify("online  |  " .. (state.Meter and "meter linked" or "meter pending") ..
        "  |  " .. (throwRemote and "remotes found" or "remotes scanning"))
end)

return api
