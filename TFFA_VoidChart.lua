local env = getgenv()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
    StatusText = { Text = "idle" },
}

local C = {
    Accent = Color3.fromRGB(88, 222, 182),
    Amber = Color3.fromRGB(232, 176, 96),
    Danger = Color3.fromRGB(230, 105, 116),
    Text = Color3.fromRGB(232, 242, 246),
}

local FONT_B = Enum.Font.SourceSansBold

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then return nil, result end
    return result
end

local function notify(text, kind)
    state.LastAction = text
    state.StatusText.Text = text
    if state.NotifyHook then pcall(state.NotifyHook, text, kind) end
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
local Rayfield
local uiReady = false

local okRay = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not okRay or type(Rayfield) ~= "table" or type(Rayfield.CreateWindow) ~= "function" then
    Rayfield = nil
end

if Rayfield then
    local okUi, uiErr = pcall(function()
        local window = Rayfield:CreateWindow({
            Name = "VOIDCHART  /  THROW FOOD FOR ANIMALS",
            LoadingTitle = "VOIDCHART",
            LoadingSubtitle = "Throw Food For Animals",
            ConfigurationSaving = {
                Enabled = false,
                FolderName = "VoidChart",
                FileName = "TFFA_VoidChart",
            },
            Discord = { Enabled = false },
            KeySystem = false,
            DisableRayfieldPrompts = true,
            DisableBuildWarnings = true,
        })

        local function addToggle(tab, name, key, onChange)
            return tab:CreateToggle({
                Name = name,
                CurrentValue = cfg[key],
                Flag = "VC_" .. key,
                Callback = function(value)
                    cfg[key] = value
                    notify(name .. " " .. (value and "on" or "off"))
                    if onChange then onChange(value) end
                end,
            })
        end

        local function addSlider(tab, name, key, min, max, increment, suffix)
            return tab:CreateSlider({
                Name = name,
                Range = {min, max},
                Increment = increment,
                Suffix = suffix or "",
                CurrentValue = cfg[key],
                Flag = "VC_" .. key,
                Callback = function(value)
                    cfg[key] = value
                end,
            })
        end

        local function addButton(tab, name, onClick)
            return tab:CreateButton({
                Name = name,
                Callback = function()
                    local ok, err = pcall(onClick)
                    if not ok then notify(tostring(err), "bad") end
                end,
            })
        end

        local function addDropdown(tab, name, options, key)
            return tab:CreateDropdown({
                Name = name,
                Options = options,
                CurrentOption = {cfg[key]},
                MultipleOptions = false,
                Flag = "VC_" .. key,
                Callback = function(option)
                    local value = type(option) == "table" and option[1] or option
                    if value then
                        cfg[key] = value
                        notify(name .. ": " .. tostring(value))
                    end
                end,
            })
        end

        local farm = window:CreateTab("Farm")
        farm:CreateSection("01  /  THROW CONTROL")
        addToggle(farm, "Auto Throw", "AutoThrow")
        addToggle(farm, "Perfect Throw", "PerfectThrow")
        addToggle(farm, "Skip Cutscene", "SkipCutscene")
        addSlider(farm, "Throw Interval", "ThrowDelay", 0.12, 1.2, 0.01, "s")
        farm:CreateSection("02  /  COLLECTION")
        addToggle(farm, "Auto Collect", "AutoCollect")
        addToggle(farm, "Auto Place Best", "AutoPlace")
        addToggle(farm, "Auto Sell Extras", "AutoSell")
        addDropdown(farm, "Target Food", FOODS, "TargetFood")
        addDropdown(farm, "Target Area", AREAS, "TargetArea")
        addButton(farm, "Throw Once", function()
            if getMeter() then doThrow() else notify("meter not linked", "warn") end
        end)
        farm:CreateParagraph({Title = "NOTE", Content = "meter forced to 0.6 before release; cutscene wait bypassed"})

        local train = window:CreateTab("Train")
        train:CreateSection("01  /  TRAINING")
        addToggle(train, "Auto Train", "AutoTrain")
        addSlider(train, "Train Interval", "TrainDelay", 0.08, 1.0, 0.01, "s")
        train:CreateSection("02  /  ECONOMY")
        addToggle(train, "Auto Buy Food", "AutoBuyFood")
        addToggle(train, "Auto Upgrade", "AutoUpgrade")
        addToggle(train, "Auto Claim Cash", "AutoClaim")
        addButton(train, "Claim Offline Cash", doClaim)
        addButton(train, "Buy Next Food", doBuyFood)
        train:CreateParagraph({Title = "NOTE", Content = "2x press path used when exposed; maxed upgrades skipped"})

        local mapTab = window:CreateTab("Map")
        mapTab:CreateSection("01  /  SURVEY")
        addButton(mapTab, "Dump Map To File", function() dumpMap(false) end)
        addButton(mapTab, "Dump And POST", function() dumpMap(true) end)
        addToggle(mapTab, "Dump On Start", "DumpOnStart")
        mapTab:CreateSection("02  /  OVERLAY")
        addToggle(mapTab, "Animal ESP", "ESP")
        addToggle(mapTab, "Show Names", "ESPNames", function(on) if not on then clearESP() end end)
        mapTab:CreateInput({
            Name = "Webhook URL",
            CurrentValue = cfg.Webhook,
            PlaceholderText = "https://example.test/hook",
            RemoveTextAfterFocusLost = false,
            Flag = "VC_Webhook",
            Callback = function(text) cfg.Webhook = text end,
        })
        mapTab:CreateParagraph({Title = "NOTE", Content = "output: TFFA_map.json in executor files"})

        local system = window:CreateTab("System")
        system:CreateSection("01  /  DEFENSES")
        addButton(system, "Neuter Validators", function() api:Bypass() end)
        addButton(system, "Rescan Controllers", function()
            state.ControllerCache, state.RemoteCache = {}, {}
            local found = refreshRemotes()
            local meter = getMeter()
            local count = 0
            for _ in pairs(found) do count += 1 end
            notify("rescan: meter " .. (meter and "linked" or "pending") .. ", " .. count .. " channels",
                meter and "ok" or "warn")
        end)
        addToggle(system, "Anti AFK", "AntiAFK")
        addSlider(system, "Walk Speed", "WalkSpeed", 16, 220, 1, "")
        system:CreateSection("02  /  RUNTIME")
        addButton(system, "Save Config", function()
            if writefile then
                safe(writefile, "TFFA_VoidChart_config.json", HttpService:JSONEncode(cfg))
                notify("config saved")
            else
                notify("writefile unavailable", "warn")
            end
        end)
        addButton(system, "Stop Script", function()
            if env.VoidChart then env.VoidChart:Stop() end
        end)
        state.StatusLabel = system:CreateLabel("system ready")
        state.CounterLabel = system:CreateLabel("T 000  C 000  S 000")
        system:CreateParagraph({Title = "NOTE", Content = "remotes and validators resolved by name pattern on boot"})

        state.NotifyHook = function(text, kind)
            local title = kind == "bad" and "ERROR" or kind == "warn" and "WARN" or "VOIDCHART"
            pcall(function()
                Rayfield:Notify({Title = title, Content = text, Duration = kind and 3 or 1.5})
            end)
        end

        uiReady = true
    end)
    if not okUi then
        notify("ui error: " .. tostring(uiErr), "bad")
        Rayfield = nil
        uiReady = false
    end
end

local lastThrow, lastTrain, lastBuy, lastUpgrade, lastClaim = 0, 0, 0, 0, 0

local function refreshStatus()
    local text = "last: " .. state.LastAction
    if state.StatusLabel and text ~= state.LastStatus then
        state.LastStatus = text
        pcall(function() state.StatusLabel:Set(text) end)
    end
    local counter = string.format("T %03d  C %03d  S %03d", state.Throws, state.Catches, state.Sold)
    if state.CounterLabel and counter ~= state.LastCounter then
        state.LastCounter = counter
        pcall(function() state.CounterLabel:Set(counter) end)
    end
end

local loopConnection = RunService.Heartbeat:Connect(function()
    if not state.Running then return end
    local now = os.clock()
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
    refreshStatus()
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
    if uiReady and Rayfield then pcall(function() Rayfield:Destroy() end) end
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
function api:UI() return Rayfield end

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
