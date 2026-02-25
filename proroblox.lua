local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then
    warn("Rayfield failed to load")
    Rayfield = {
        CreateWindow = function() return { CreateTab=function() return { CreateToggle=function() end, CreateButton=function() end, CreateSlider=function() end, CreateInput=function() end, CreateDropdown=function() return {Set=function()end} end, CreateLabel=function()end } end } end,
        Notify = function() end
    }
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.AimbotEnabled = false
_G.Wallbang = false
_G.FOV = 180
_G.Smooth = 0.08
_G.AimPart = "HumanoidRootPart"
_G.ESPEnabled = false
_G.ShowDistance = true
_G.ESPColor = Color3.fromRGB(0, 200, 255)

local flyEnabled = false
local flySpeed = 60
local speedEnabled = false
local speedValue = 60
local jumpEnabled = false
local jumpValue = 100
local noclipEnabled = false
local invisible = false
local espEnabled = false
local selectedPlayer = nil
local viewing = false
local currentViewed = nil
local godModeEnabled = false
local originalMaterials = {}
local fpsBoostEnabled = false
local cinematic = false
local realisticEnabled = false
local pcModeEnabled = false
local weatherEnabled = false
local weatherState = "Clear"
local weatherTask = nil

local Window = Rayfield:CreateWindow({
    Name = "🌌 BomDev X Pro | Ultimate Hub",
    LoadingTitle = "⚙️ Loading Advanced System...",
    LoadingSubtitle = "Design by BomDev Studios",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BomDevPro"
    },
    KeySystem = false
})

Rayfield:Notify({
    Title = "🌈 BomDev Pro UI Loaded",
    Content = "ระบบทั้งหมดพร้อมใช้งานแล้ว 💫",
    Duration = 4
})

local function toggleFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    flyEnabled = not flyEnabled
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    if flyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        Rayfield:Notify({
            Title = "✈️ Flight Mode Activated",
            Content = "คุณสามารถบินได้แล้ว!",
            Duration = 3
        })

        task.spawn(function()
            while flyEnabled and task.wait() do
                if not hrp or not hrp.Parent then break end
                bg.CFrame = CFrame.new(hrp.Position, hrp.Position + Camera.CFrame.LookVector)

                local camCF = Camera.CFrame
                local forward = camCF.LookVector
                local right = camCF.RightVector
                local up = Vector3.new(0, 1, 0)

                local w = UIS:IsKeyDown(Enum.KeyCode.W)
                local s = UIS:IsKeyDown(Enum.KeyCode.S)
                local a = UIS:IsKeyDown(Enum.KeyCode.A)
                local d = UIS:IsKeyDown(Enum.KeyCode.D)
                local space = UIS:IsKeyDown(Enum.KeyCode.Space)
                local shift = UIS:IsKeyDown(Enum.KeyCode.LeftShift)

                local dir = Vector3.zero

                if w then dir = dir + Vector3.new(forward.X, forward.Y, forward.Z) end
                if s then dir = dir - Vector3.new(forward.X, forward.Y, forward.Z) end
                if d then dir = dir + Vector3.new(right.X, right.Y, right.Z) end
                if a then dir = dir - Vector3.new(right.X, right.Y, right.Z) end
                if space then dir = dir + up end
                if shift then dir = dir - up end

                if dir.Magnitude > 0 then
                    bv.Velocity = dir.Unit * flySpeed
                else
                    local md = hum and hum.MoveDirection or Vector3.zero
                    if md.Magnitude > 0 then
                        local flatForward = Vector3.new(forward.X, 0, forward.Z)
                        local flatRight = Vector3.new(right.X, 0, right.Z)
                        local moveDir = flatForward.Unit * -md.Z + flatRight.Unit * md.X
                        bv.Velocity = moveDir.Unit * flySpeed
                    else
                        bv.Velocity = Vector3.zero
                    end
                end
            end
        end)
    else
        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
        Rayfield:Notify({
            Title = "🪂 Flight Disabled",
            Content = "โหมดบินถูกปิดแล้ว",
            Duration = 3
        })
    end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and speedValue or 16
        Rayfield:Notify({
            Title = "⚡ Speed Mode",
            Content = speedEnabled and "เปิดความเร็วสูงแล้ว" or "ปิดความเร็วแล้ว",
            Duration = 2
        })
    end
end

local function toggleJump()
    jumpEnabled = not jumpEnabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = jumpEnabled and jumpValue or 50
        Rayfield:Notify({
            Title = "🦘 Jump Boost",
            Content = jumpEnabled and "กระโดดสูงเปิดแล้ว" or "กระโดดสูงปิดแล้ว",
            Duration = 2
        })
    end
end

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

local function toggleInvis(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({
            Title = "⚠️ ไม่พบตัวละคร",
            Content = "ระบบล่องหนไม่สามารถทำงานได้ เพราะไม่พบ HumanoidRootPart",
            Duration = 3
        })
        return
    end

    invisible = state

    if invisible then
        local ok = pcall(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 1
                    v.Material = Enum.Material.ForceField
                    v.CanCollide = false
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end)
        Rayfield:Notify({
            Title = ok and "🌀 Invisibility Activated" or "❌ ล่องหนล้มเหลว",
            Content = ok and "คุณหายไปจากสายตาคนอื่นแล้ว 💨" or "เกิดข้อผิดพลาดระหว่างทำงาน",
            Duration = 3
        })
    else
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0
                v.Material = Enum.Material.Plastic
                v.CanCollide = true
            elseif v:IsA("Decal") then
                v.Transparency = 0
            end
        end
        Rayfield:Notify({
            Title = "🌀 Invisibility Disabled",
            Content = "กลับมาเป็นปกติแล้ว ✅",
            Duration = 3
        })
    end
end

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
end)

local function toggleESP(state)
    espEnabled = state
    Rayfield:Notify({
        Title = "👁 Player ESP",
        Content = state and "เปิด ESP แล้ว" or "ปิด ESP แล้ว",
        Duration = 2
    })
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if state then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                    highlight.Parent = player.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

local function toggleFullbright()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").FogEnd = 100000
    game:GetService("Lighting").GlobalShadows = false
    Rayfield:Notify({
        Title = "🌞 Fullbright",
        Content = "เปิดโหมดกลางวันถาวรแล้ว!",
        Duration = 3
    })
end

local function setGodMode(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        Rayfield:Notify({ Title = "⚠️ God Mode", Content = "ไม่พบ Humanoid ในตัวละคร", Duration = 2 })
        return
    end
    if state then
        if not godModeEnabled then
            hum.Name = "1"
            local newHum = hum:Clone()
            newHum.Parent = char
            task.wait()
            hum:Destroy()
            newHum.Name = "Humanoid"
            Rayfield:Notify({ Title = "💎 God Mode", Content = "เปิดโหมดอมตะแล้ว (อาจไม่ใช้ได้ทุกเกม)", Duration = 3 })
            godModeEnabled = true
        end
    else
        if godModeEnabled then
            local currentHum = char:FindFirstChildOfClass("Humanoid")
            if currentHum then
                currentHum.Health = currentHum.MaxHealth
                currentHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
            Rayfield:Notify({ Title = "💀 God Mode", Content = "ปิดโหมดอมตะแล้ว", Duration = 3 })
            godModeEnabled = false
        end
    end
end

local function toggleAntiAFK(state)
    if state then
        Rayfield:Notify({ Title = "🛡 Anti-AFK", Content = "เปิดระบบป้องกันหลุดแล้ว!", Duration = 3 })
        LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        Rayfield:Notify({ Title = "🛡 Anti-AFK", Content = "ปิดระบบป้องกันหลุดแล้ว!", Duration = 3 })
    end
end

local function toggleRealisticGraphics(state)
    realisticEnabled = state
    local lighting = game:GetService("Lighting")
    if state then
        lighting.Brightness = 3
        lighting.GlobalShadows = true
        lighting.EnvironmentDiffuseScale = 0.5
        lighting.EnvironmentSpecularScale = 1
        lighting.ClockTime = 16
        lighting.FogEnd = 1000
        lighting.FogColor = Color3.fromRGB(200, 200, 255)
        lighting.Ambient = Color3.fromRGB(255, 240, 220)
        lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)
        local sunRays = Instance.new("SunRaysEffect", lighting)
        sunRays.Intensity = 0.25
        local bloom = Instance.new("BloomEffect", lighting)
        bloom.Intensity = 0.4
        bloom.Size = 24
        local cc = Instance.new("ColorCorrectionEffect", lighting)
        cc.Saturation = 0.2
        cc.Contrast = 0.3
        cc.Brightness = 0.05
        local dof = Instance.new("DepthOfFieldEffect", lighting)
        dof.FarIntensity = 0.4
        dof.FocusDistance = 15
        dof.InFocusRadius = 25
        Rayfield:Notify({ Title = "🌅 Realistic Graphics", Content = "เปิดภาพสมจริงแล้ว!", Duration = 3 })
    else
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                v:Destroy()
            end
        end
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Rayfield:Notify({ Title = "🌅 Realistic Graphics", Content = "ปิดโหมดภาพสมจริงแล้ว", Duration = 3 })
    end
end

local function togglePCMode(state)
    pcModeEnabled = state
    local UIS2 = game:GetService("UserInputService")
    if state then
        UIS2.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS2.MouseIconEnabled = true
        for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "TouchGui" or gui.Name == "MobileControls") then
                gui.Enabled = false
            end
        end
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = LocalPlayer.Character:WaitForChild("Humanoid")
        Camera.FieldOfView = 80
        UIS2.MouseDeltaSensitivity = 0.2
        Rayfield:Notify({ Title = "💻 PC Mode", Content = "เปิดโหมดพีซีในมือถือแล้ว! 🔥", Duration = 3 })
    else
        UIS2.MouseBehavior = Enum.MouseBehavior.Default
        UIS2.MouseIconEnabled = false
        UIS2.MouseDeltaSensitivity = 1
        for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "TouchGui" or gui.Name == "MobileControls") then
                gui.Enabled = true
            end
        end
        Rayfield:Notify({ Title = "📱 Mobile Mode", Content = "กลับสู่โหมดมือถือแล้ว", Duration = 3 })
    end
end

local function refreshPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local function clearWeatherEffects()
    local Lighting = game:GetService("Lighting")
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name:match("^BDW_") then v:Destroy() end
    end
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(127,127,127)
end

local function applyRain(intensity)
    local Lighting = game:GetService("Lighting")
    local rain = Instance.new("ParticleEmitter")
    rain.Name = "BDW_Rain"
    rain.Rate = 500 * (intensity or 1)
    rain.Lifetime = NumberRange.new(1,1.5)
    rain.Speed = NumberRange.new(60,80)
    rain.VelocitySpread = 10
    rain.Size = NumberSequence.new(0.2)
    rain.Texture = "rbxassetid://241594314"
    rain.Parent = workspace.Terrain
    Lighting.FogEnd = 2500
    Lighting.FogColor = Color3.fromRGB(150,160,170)
    Lighting.Brightness = 1.2
    Lighting.GlobalShadows = true
    task.spawn(function()
        while weatherEnabled and weatherState == "Rain" do
            task.wait(8 + math.random()*12)
            local s = Instance.new("Sound", workspace)
            s.SoundId = "rbxassetid://911882087"
            s.Volume = 0.5
            s:Play()
            game:GetService("Debris"):AddItem(s, 6)
        end
    end)
end

local function applyStorm()
    local Lighting = game:GetService("Lighting")
    applyRain(2)
    Lighting.Brightness = 0.8
    Lighting.FogEnd = 1200
    Lighting.ClockTime = 20
    task.spawn(function()
        while weatherEnabled and weatherState == "Storm" do
            task.wait(5 + math.random()*8)
            local s = Instance.new("Sound", workspace)
            s.SoundId = "rbxassetid://130768899"
            s.Volume = 1
            s:Play()
            local flash = Instance.new("PointLight", workspace)
            flash.Name = "BDW_Flash"
            flash.Range = 60
            flash.Brightness = 5
            flash.Color = Color3.fromRGB(255,255,255)
            game:GetService("Debris"):AddItem(flash, 0.15)
            game:GetService("Debris"):AddItem(s, 6)
        end
    end)
end

local function applySunset()
    local Lighting = game:GetService("Lighting")
    clearWeatherEffects()
    Lighting.ClockTime = 18
    Lighting.Brightness = 2.2
    Lighting.Ambient = Color3.fromRGB(255,200,170)
    Lighting.OutdoorAmbient = Color3.fromRGB(180,140,120)
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
    weatherTask = nil
    if weatherState == "Rain" then
        applyRain(1)
    elseif weatherState == "Storm" then
        applyStorm()
    elseif weatherState == "Sunset" then
        applySunset()
    elseif weatherState == "Night" then
        local Lighting = game:GetService("Lighting")
        Lighting.ClockTime = 22
        Lighting.Brightness = 0.6
        Lighting.FogEnd = 2000
        Lighting.Ambient = Color3.fromRGB(80, 90, 120)
    else
        clearWeatherEffects()
    end
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = _G.ESPColor
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = true

local ESPObjects = {}
local Holding = false
local LockTarget = nil

local function AimVisible(part)
    if _G.Wallbang then return true end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ray = workspace:Raycast(origin, dir, params)
    return ray and ray.Instance:IsDescendantOf(part.Parent)
end

local function GetAimTarget()
    local best, dist = nil, _G.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local part = p.Character:FindFirstChild(_G.AimPart)
            if hum and hum.Health > 0 and part and AimVisible(part) then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        dist = mag
                        best = part
                    end
                end
            end
        end
    end
    return best
end

local function CreateESPDrawing(player)
    if player == LocalPlayer then return end
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = _G.ESPColor
    text.Visible = false
    ESPObjects[player] = text
end

for _, p in pairs(Players:GetPlayers()) do
    CreateESPDrawing(p)
end
Players.PlayerAdded:Connect(CreateESPDrawing)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player]:Remove()
        ESPObjects[player] = nil
    end
end)

UIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.Touch then
        Holding = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.Touch then
        Holding = false
        LockTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = _G.FOV
    FOVCircle.Visible = _G.AimbotEnabled

    if Holding and _G.AimbotEnabled then
        LockTarget = GetAimTarget()
        if LockTarget then
            local cf = CFrame.new(Camera.CFrame.Position, LockTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - _G.Smooth)
        end
    else
        LockTarget = nil
    end

    for player, esp in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if _G.ESPEnabled and hrp and hum and hum.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2, 0))
            if on then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                esp.Text = _G.ShowDistance
                    and string.format("%s [%.0fm]", player.Name, dist)
                    or player.Name
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Visible = true
            else
                esp.Visible = false
            end
        else
            esp.Visible = false
        end
    end
end)

local MovementTab = Window:CreateTab("🚀 Movement Control", 4483362458)

MovementTab:CreateToggle({
    Name = "✈️ เปิด/ปิดบิน (Fly Mode)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = toggleFly
})

MovementTab:CreateSlider({
    Name = "🌪 ความเร็วบิน (Fly Speed)",
    Range = {10, 300},
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
    Callback = toggleSpeed
})

MovementTab:CreateSlider({
    Name = "🏃‍♂️ ความเร็วเดิน (Walk Speed)",
    Range = {16, 200},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = speedValue,
    Flag = "SpeedValue",
    Callback = function(v)
        speedValue = v
        if speedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

MovementTab:CreateToggle({
    Name = "🦘 กระโดดสูง (High Jump)",
    CurrentValue = false,
    Flag = "Jump",
    Callback = toggleJump
})

MovementTab:CreateSlider({
    Name = "⬆️ ความสูงกระโดด (Jump Power)",
    Range = {50, 500},
    Increment = 10,
    Suffix = "Jump",
    CurrentValue = jumpValue,
    Flag = "JumpPower",
    Callback = function(v)
        jumpValue = v
        if jumpEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end
})

MovementTab:CreateToggle({
    Name = "👻 เดินทะลุสิ่งของ (NoClip)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        noclipEnabled = v
        Rayfield:Notify({
            Title = "👻 NoClip Mode",
            Content = v and "ทะลุทุกสิ่งเปิดแล้ว" or "ปิดโหมดทะลุ",
            Duration = 2
        })
    end
})

MovementTab:CreateToggle({
    Name = "🌀 ล่องหน (Invisible Mode)",
    CurrentValue = false,
    Flag = "Invisible",
    Callback = function(v)
        toggleInvis(v)
    end
})

MovementTab:CreateToggle({
    Name = "💎 โหมดอมตะ (God Mode)",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(value)
        setGodMode(value)
    end
})

local CombatTab = Window:CreateTab("⚔️ Combat System", 4483362458)

CombatTab:CreateToggle({
    Name = "🎯 Aimbot (กด RMB/Touch ค้างเพื่อล็อกเป้า)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(v)
        _G.AimbotEnabled = v
        Rayfield:Notify({
            Title = "🎯 Aimbot",
            Content = v and "เปิดระบบล็อกเป้าแล้ว (กด RMB / แตะค้าง)" or "ปิดระบบล็อกเป้าแล้ว",
            Duration = 2
        })
    end
})

CombatTab:CreateToggle({
    Name = "🔫 Wallbang Mode",
    CurrentValue = false,
    Flag = "Wallbang",
    Callback = function(v)
        _G.Wallbang = v
        Rayfield:Notify({
            Title = "🔫 Wallbang",
            Content = v and "ล็อกเป้าผ่านกำแพงเปิดแล้ว" or "ปิด Wallbang แล้ว",
            Duration = 2
        })
    end
})

CombatTab:CreateSlider({
    Name = "🎯 Aimbot FOV (วงกลม)",
    Range = {50, 500},
    Increment = 5,
    Suffix = " FOV",
    CurrentValue = _G.FOV,
    Flag = "AimbotFOV",
    Callback = function(v)
        _G.FOV = v
    end
})

CombatTab:CreateSlider({
    Name = "🌊 Smoothness (ความนุ่มนวล)",
    Range = {1, 30},
    Increment = 1,
    Suffix = "",
    CurrentValue = 8,
    Flag = "AimbotSmooth",
    Callback = function(v)
        _G.Smooth = v / 100
    end
})

CombatTab:CreateDropdown({
    Name = "🎯 เลือก Aim Part",
    Options = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
    CurrentOption = "HumanoidRootPart",
    Flag = "AimPart",
    Callback = function(option)
        _G.AimPart = typeof(option) == "table" and option[1] or option
        Rayfield:Notify({
            Title = "🎯 Aim Part",
            Content = "เปลี่ยนไปยิงที่: " .. _G.AimPart,
            Duration = 2
        })
    end
})

local VisualTab = Window:CreateTab("🌈 Visual Settings", 4483362458)

VisualTab:CreateToggle({
    Name = "👁 Player ESP (Drawing)",
    CurrentValue = false,
    Flag = "ESPDrawing",
    Callback = function(v)
        _G.ESPEnabled = v
        Rayfield:Notify({
            Title = "👁 ESP",
            Content = v and "เปิด ESP แล้ว" or "ปิด ESP แล้ว",
            Duration = 2
        })
    end
})

VisualTab:CreateToggle({
    Name = "👁 Player ESP (Highlight)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = toggleESP
})

VisualTab:CreateToggle({
    Name = "📏 แสดงระยะ (Show Distance)",
    CurrentValue = true,
    Flag = "ShowDist",
    Callback = function(v)
        _G.ShowDistance = v
    end
})

VisualTab:CreateButton({
    Name = "🌞 เปิดแสงสว่าง (Fullbright)",
    Callback = toggleFullbright
})

VisualTab:CreateButton({
    Name = "🌫 ลบหมอกในเกม",
    Callback = function()
        game:GetService("Lighting").FogEnd = 999999
        Rayfield:Notify({ Title = "🌫 ลบหมอก", Content = "ลบหมอกออกหมดแล้ว!", Duration = 2 })
    end
})

VisualTab:CreateToggle({
    Name = "🎥 โหมดภาพยนตร์ (Cinematic Mode)",
    CurrentValue = false,
    Flag = "Cinematic",
    Callback = function(v)
        cinematic = v
        game:GetService("StarterGui"):SetCore("TopbarEnabled", not v)
        for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui.Enabled = not v
            end
        end
        Rayfield:Notify({
            Title = "🎬 Cinematic Mode",
            Content = v and "เปิดโหมดภาพยนตร์แล้ว" or "กลับสู่โหมดปกติ",
            Duration = 3
        })
    end
})

VisualTab:CreateToggle({
    Name = "🌅 ภาพสมจริง (Realistic Graphics)",
    CurrentValue = false,
    Callback = toggleRealisticGraphics
})

VisualTab:CreateToggle({
    Name = "⛅ Dynamic Weather",
    CurrentValue = false,
    Flag = "DynamicWeather",
    Callback = function(state)
        weatherEnabled = state
        if not state then
            clearWeatherEffects()
            Rayfield:Notify({ Title = "⛅ Weather", Content = "ปิดระบบสภาพอากาศแล้ว", Duration = 2 })
            return
        end
        setWeather("Rain")
        Rayfield:Notify({ Title = "⛅ Weather", Content = "เปิด Dynamic Weather (Rain) เรียบร้อย", Duration = 2 })
    end
})

VisualTab:CreateDropdown({
    Name = "🌦 เลือกโหมดอากาศ",
    Options = {"Clear","Rain","Storm","Sunset","Night"},
    CurrentOption = "Clear",
    Flag = "WeatherMode",
    Callback = function(option)
        if not weatherEnabled then
            Rayfield:Notify({ Title = "⚠️ Weather", Content = "เปิด Dynamic Weather ก่อน", Duration = 2 })
            return
        end
        setWeather(option)
        Rayfield:Notify({ Title = "🌦 Weather", Content = "ตั้งค่าเป็น: "..option, Duration = 2 })
    end
})

local UtilsTab = Window:CreateTab("🧰 Utilities", 4483362458)

UtilsTab:CreateButton({
    Name = "🔁 Rejoin เซิร์ฟเวอร์",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

UtilsTab:CreateButton({
    Name = "🧾 คัดลอก Place ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Rayfield:Notify({ Title = "📋 คัดลอกแล้ว", Content = "คัดลอก Place ID ไปยังคลิปบอร์ดแล้ว", Duration = 2 })
    end
})

UtilsTab:CreateToggle({
    Name = "🛡 ป้องกันหลุดออก (Anti-AFK)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = toggleAntiAFK
})

UtilsTab:CreateToggle({
    Name = "🔁 รีเข้าอัตโนมัติ (Auto Rejoin)",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(state)
        if state then
            Rayfield:Notify({ Title = "🔁 Auto Rejoin", Content = "จะกลับเข้าทันทีถ้าหลุดจากเซิร์ฟ!", Duration = 3 })
            game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
                if obj.Name == "ErrorPrompt" then
                    task.wait(2)
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end
            end)
        else
            Rayfield:Notify({ Title = "🔁 Auto Rejoin", Content = "ปิดระบบรีเข้าอัตโนมัติแล้ว", Duration = 3 })
        end
    end
})

UtilsTab:CreateToggle({
    Name = "🌈 ร่างสายรุ้ง (Rainbow Mode)",
    CurrentValue = false,
    Flag = "RainbowMode",
    Callback = function(state)
        if state then
            Rayfield:Notify({ Title = "🌈 Rainbow Mode", Content = "เปิดเอฟเฟกต์สีสายรุ้งแล้ว!", Duration = 3 })
            task.spawn(function()
                while state and task.wait(0.1) do
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                end
            end)
        else
            Rayfield:Notify({ Title = "🌈 Rainbow Mode", Content = "ปิดโหมดสายรุ้งแล้ว!", Duration = 3 })
        end
    end
})

UtilsTab:CreateToggle({
    Name = "🚀 โหมด FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(state)
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
            Rayfield:Notify({ Title = "🚀 FPS Booster", Content = "เปิดโหมดประหยัดเฟรมแล้ว เกมจะลื่นขึ้น!", Duration = 3 })
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
            Rayfield:Notify({ Title = "🚀 FPS Booster", Content = "ปิดโหมดประหยัดเฟรมแล้ว!", Duration = 3 })
        end
    end
})

UtilsTab:CreateToggle({
    Name = "🪂 ไม่ตกเสียหาย (No Fall Damage)",
    CurrentValue = false,
    Flag = "NoFallDamage",
    Callback = function(state)
        if state then
            Rayfield:Notify({ Title="🪂 No Fall Damage", Content="เปิดแล้ว!", Duration=2 })
            LocalPlayer.CharacterAdded:Connect(function(char)
                local hum = char:WaitForChild("Humanoid")
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
            end
        else
            Rayfield:Notify({ Title="🪂 No Fall Damage", Content="ปิดแล้ว!", Duration=2 })
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end
            end
        end
    end
})

UtilsTab:CreateToggle({
    Name = "🌊 เดินบนน้ำ (Walk on Water)",
    CurrentValue = false,
    Flag = "WalkOnWater",
    Callback = function(state)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        if state then
            Rayfield:Notify({ Title="🌊 Walk on Water", Content="เปิดแล้ว!", Duration=2 })
            local waterPlatform = Instance.new("Part")
            waterPlatform.Name = "WaterWalkPart"
            waterPlatform.Size = Vector3.new(1000, 1, 1000)
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Transparency = 1
            waterPlatform.Material = Enum.Material.Glass
            waterPlatform.Position = Vector3.new(hrp.Position.X, workspace.Terrain.WaterLevel, hrp.Position.Z)
            waterPlatform.Parent = workspace
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not state or not waterPlatform or not waterPlatform.Parent then
                    connection:Disconnect()
                    return
                end
                waterPlatform.Position = Vector3.new(hrp.Position.X, workspace.Terrain.WaterLevel, hrp.Position.Z)
            end)
            waterPlatform:SetAttribute("IsWalkOnWaterPart", true)
        else
            Rayfield:Notify({ Title="🌊 Walk on Water", Content="ปิดแล้ว!", Duration=2 })
            for _, part in pairs(workspace:GetChildren()) do
                if part:GetAttribute("IsWalkOnWaterPart") then part:Destroy() end
            end
        end
    end
})

UtilsTab:CreateButton({
    Name = "📍 บันทึกตำแหน่งปัจจุบัน",
    Callback = function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        _G.SavedPosition = pos
        Rayfield:Notify({ Title="📍 บันทึกแล้ว", Content="ตำแหน่งถูกบันทึก!", Duration=2 })
    end
})

UtilsTab:CreateButton({
    Name = "🚀 วาร์ปไปตำแหน่งบันทึก",
    Callback = function()
        if _G.SavedPosition then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(_G.SavedPosition + Vector3.new(0,5,0))
            Rayfield:Notify({ Title="🚀 วาร์ปแล้ว", Content="ไปยังจุดที่บันทึกไว้!", Duration=2 })
        else
            Rayfield:Notify({ Title="⚠️ ไม่มีจุดบันทึก", Content="โปรดบันทึกก่อน!", Duration=2 })
        end
    end
})

UtilsTab:CreateToggle({
    Name = "💻 โหมดพีซีในมือถือ (PC Mode)",
    CurrentValue = false,
    Callback = togglePCMode
})

local TeleportTab = Window:CreateTab("🧭 Teleport & Viewer", 4483362458)

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "👥 เลือกผู้เล่นในเซิร์ฟ",
    Options = refreshPlayerList(),
    CurrentOption = nil,
    Flag = "PlayerList",
    Callback = function(option)
        local playerName = typeof(option) == "table" and option[1] or option
        local plr = Players:FindFirstChild(playerName)
        if plr then
            selectedPlayer = plr
            Rayfield:Notify({ Title = "✅ เลือกผู้เล่นแล้ว", Content = "คุณเลือก: " .. playerName, Duration = 2 })
        else
            selectedPlayer = nil
            Rayfield:Notify({ Title = "⚠️ ไม่พบผู้เล่น", Content = "ผู้เล่นนี้อาจออกจากเกมแล้ว", Duration = 2 })
        end
    end
})

TeleportTab:CreateButton({
    Name = "🔄 รีเฟรชรายชื่อผู้เล่น",
    Callback = function()
        playerDropdown:Set(refreshPlayerList())
        Rayfield:Notify({ Title = "🔁 รายชื่ออัปเดตแล้ว", Content = "รีเฟรชผู้เล่นในเซิร์ฟเวอร์สำเร็จ ✅", Duration = 2 })
    end
})

TeleportTab:CreateButton({
    Name = "⚡ วาร์ปไปหาผู้เล่นที่เลือก",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char:MoveTo(selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                Rayfield:Notify({ Title = "⚡ วาร์ปสำเร็จ", Content = "คุณถูกวาร์ปไปหา " .. selectedPlayer.Name, Duration = 2 })
            end
        else
            Rayfield:Notify({ Title = "❌ วาร์ปล้มเหลว", Content = "กรุณาเลือกผู้เล่นก่อน หรือผู้เล่นไม่มีตัวในเกม", Duration = 2 })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "👁‍🗨 ส่องผู้เล่นที่เลือก (View Player)",
    CurrentValue = false,
    Flag = "ViewPlayer",
    Callback = function(state)
        if state then
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                viewing = true
                currentViewed = selectedPlayer
                Camera.CameraSubject = currentViewed.Character:FindFirstChild("Humanoid")
                Rayfield:Notify({ Title = "👁‍🗨 View Enabled", Content = "กำลังส่อง " .. currentViewed.Name, Duration = 3 })
                task.spawn(function()
                    while viewing do
                        task.wait(0.5)
                        if not currentViewed or not currentViewed.Character or not currentViewed.Character:FindFirstChild("Humanoid") then
                            viewing = false
                            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                            Rayfield:Notify({ Title = "⚠️ ผู้เล่นหายไป", Content = "ออกจากโหมดส่องอัตโนมัติ", Duration = 2 })
                            break
                        end
                    end
                end)
            else
                Rayfield:Notify({ Title = "⚠️ ไม่สามารถส่องได้", Content = "กรุณาเลือกผู้เล่นก่อน หรือผู้เล่นไม่มีตัวอยู่ในเกม", Duration = 3 })
            end
        else
            viewing = false
            currentViewed = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            Rayfield:Notify({ Title = "👁‍🗨 View Disabled", Content = "ออกจากโหมดส่องผู้เล่นแล้ว", Duration = 2 })
        end
    end
})

TeleportTab:CreateButton({
    Name = "🧲 ดึงผู้เล่นมาหาเรา (Realistic Pull)",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then
            Rayfield:Notify({ Title = "⚠️ ข้อผิดพลาด", Content = "กรุณาเลือกผู้เล่นก่อน", Duration = 3 })
            return
        end
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not (targetRoot and myRoot) then return end
        if targetRoot:FindFirstChild("PullForce") then
            targetRoot.PullForce:Destroy()
        end
        local bp = Instance.new("BodyPosition")
        bp.Name = "PullForce"
        bp.MaxForce = Vector3.new(500000, 500000, 500000)
        bp.P = 5000
        bp.D = 500
        bp.Position = myRoot.Position + (myRoot.CFrame.LookVector * -3)
        bp.Parent = targetRoot
        Rayfield:Notify({ Title = "🧲 กำลังดึง...", Content = "ผู้เล่นกำลังถูกดึงมาหาคุณ", Duration = 2 })
        task.wait(1.5)
        bp:Destroy()
        Rayfield:Notify({ Title = "✅ ดึงสำเร็จ", Content = "ผู้เล่นถูกดึงมาหาคุณเรียบร้อยแล้ว!", Duration = 2 })
    end
})

Rayfield:Notify({
    Title = "💠 BomDev Pro Menu Ready!",
    Content = "✨ ระบบทั้งหมดพร้อมใช้งานแล้ว พร้อม UI ระดับมืออาชีพ!",
    Duration = 6
})
