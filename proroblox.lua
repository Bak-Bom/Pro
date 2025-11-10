local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then
    warn("⚠️ โหลด Rayfield ไม่ได้ ตรวจสอบลิงก์อีกครั้ง")
    Rayfield = {
        CreateWindow = function() return { CreateTab=function() return { CreateToggle=function() end, CreateButton=function() end, CreateSlider=function() end, CreateInput=function() end } end } end,
        Notify = function() end
    }
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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

local flyEnabled = false
local flySpeed = 60
local speedEnabled = false
local speedValue = 60
local jumpEnabled = false
local jumpValue = 100
local noclipEnabled = false
local invisible = false
local savedCharacter = nil
local espEnabled = false
local aimbotEnabled = false
local aimbotRange = 200
local selectedPlayer = nil
local headViewEnabled = false

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
                if not hrp or not hum then break end
                bg.CFrame = Camera.CFrame
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local cameraDir = Camera.CFrame.LookVector
                    local flatMove = Vector3.new(cameraDir.X, cameraDir.Y, cameraDir.Z)
                    bv.Velocity = flatMove.Unit * flySpeed
                else
                    bv.Velocity = Vector3.zero
                end
            end
        end)
    else
        for _,v in ipairs(hrp:GetChildren()) do
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
        local success = pcall(function()
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

        if success then
            Rayfield:Notify({
                Title = "🌀 Invisibility Activated",
                Content = "คุณหายไปจากสายตาคนอื่นแล้ว 💨",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "❌ ล่องหนล้มเหลว",
                Content = "เกิดข้อผิดพลาดระหว่างทำงาน",
                Duration = 3
            })
        end

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
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function toggleGodMode()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Name = "1"
        local newHum = hum:Clone()
        newHum.Parent = char
        task.wait()
        hum:Destroy()
        Rayfield:Notify({
            Title = "💎 God Mode",
            Content = "เปิดโหมดอมตะแล้ว (อาจไม่ใช้ได้ทุกเกม)",
            Duration = 3
        })
    end
end

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos = player.Character.Head.Position
            local magnitude = (Camera.CFrame.Position - headPos).Magnitude
            if magnitude < dist and magnitude < aimbotRange then
                dist = magnitude
                closest = player
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

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

local function refreshPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

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
    Name = "👁 มองเห็นผู้เล่น (ESP)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = toggleESP
})
MovementTab:CreateButton({
    Name = "💎 โหมดอมตะ (God Mode)",
    Callback = toggleGodMode
})

local CombatTab = Window:CreateTab("⚔️ Combat System", 4483362458)

CombatTab:CreateToggle({
    Name = "🎯 Aimbot (ล็อกเป้า)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(v)
        aimbotEnabled = v
        Rayfield:Notify({
            Title = "🎯 Aimbot",
            Content = v and "เปิดระบบล็อกเป้าแล้ว" or "ปิดระบบล็อกเป้าแล้ว",
            Duration = 2
        })
    end
})

local VisualTab = Window:CreateTab("🌈 Visual Settings", 4483362458)

VisualTab:CreateButton({
    Name = "🌞 เปิดแสงสว่าง (Fullbright)",
    Callback = toggleFullbright
})

VisualTab:CreateButton({
    Name = "🌫 ลบหมอกในเกม",
    Callback = function()
        game:GetService("Lighting").FogEnd = 999999
        Rayfield:Notify({
            Title = "🌫 ลบหมอก",
            Content = "ลบหมอกออกหมดแล้ว!",
            Duration = 2
        })
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
        Rayfield:Notify({
            Title = "📋 คัดลอกแล้ว",
            Content = "คัดลอก Place ID ไปยังคลิปบอร์ดแล้ว",
            Duration = 2
        })
    end
})

local TeleportTab = Window:CreateTab("🧭 Teleport & Viewer", 4483362458)

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "👥 รายชื่อผู้เล่นในเซิร์ฟ",
    Options = refreshPlayerList(),
    CurrentOption = nil,
    Flag = "PlayerList",
    Callback = function(option)
        
        local playerName = typeof(option) == "table" and option[1] or option
        local plr = Players:FindFirstChild(playerName)

        if plr then
            selectedPlayer = plr
            Rayfield:Notify({
                Title = "🎯 เลือกผู้เล่นแล้ว",
                Content = "คุณเลือก " .. tostring(playerName),
                Duration = 2
            })
        else
            selectedPlayer = nil
            Rayfield:Notify({
                Title = "⚠️ ไม่พบผู้เล่น",
                Content = "ไม่สามารถเลือกผู้เล่นนี้ได้ อาจออกจากเกมแล้ว",
                Duration = 2
            })
        end
    end
})

TeleportTab:CreateButton({
    Name = "🔄 รีเฟรชรายชื่อผู้เล่น",
    Callback = function()
        playerDropdown:Set(refreshPlayerList())
        Rayfield:Notify({
            Title = "🔄 อัปเดตรายชื่อแล้ว",
            Content = "รีเฟรชรายชื่อผู้เล่นในเซิร์ฟเวอร์แล้ว ✅",
            Duration = 2
        })
    end
})

TeleportTab:CreateButton({
    Name = "⚡ วาร์ปไปหาผู้เล่นที่เลือก",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = selectedPlayer.Character.HumanoidRootPart.Position
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if char and char:FindFirstChild("HumanoidRootPart") then
                char:MoveTo(targetPos + Vector3.new(0, 3, 0))
                Rayfield:Notify({
                    Title = "⚡ วาร์ปสำเร็จ",
                    Content = "คุณถูกวาร์ปไปหา " .. selectedPlayer.Name .. " แล้ว!",
                    Duration = 2
                })
            else
                Rayfield:Notify({
                    Title = "⚠️ ตัวละครไม่สมบูรณ์",
                    Content = "ไม่พบ HumanoidRootPart ของคุณ",
                    Duration = 2
                })
            end
        else
            Rayfield:Notify({
                Title = "❌ ไม่สามารถวาร์ปได้",
                Content = "กรุณาเลือกผู้เล่นก่อน หรือผู้เล่นนั้นไม่มีตัวอยู่",
                Duration = 2
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "🎥 เปิด/ปิดโหมดส่องผู้เล่น (Player Viewer)",
    CurrentValue = false,
    Flag = "PlayerView",
    Callback = function(state)
        headViewEnabled = state
        Rayfield:Notify({
            Title = "🎥 Player Viewer",
            Content = state and "เปิดโหมดส่องผู้เล่นแล้ว 🔍" or "ปิดโหมดส่องผู้เล่นแล้ว 🚫",
            Duration = 2
        })
    end
})

RunService.RenderStepped:Connect(function()
    if headViewEnabled then
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Head") then
            local targetHead = selectedPlayer.Character.Head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        else
            headViewEnabled = false
            Rayfield:Notify({
                Title = "⚠️ ผู้เล่นหายไป",
                Content = "ปิดโหมดส่องผู้เล่นอัตโนมัติ",
                Duration = 2
            })
        end
    end
end)

Players.PlayerAdded:Connect(function()
    playerDropdown:Set(refreshPlayerList())
end)

Players.PlayerRemoving:Connect(function()
    playerDropdown:Set(refreshPlayerList())
    if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
        selectedPlayer = nil
        headViewEnabled = false
    end
end)
Rayfield:Notify({
    Title = "💠 BomDev Pro Menu Ready!",
    Content = "✨ ระบบทั้งหมดพร้อมใช้งานแล้ว พร้อม UI ระดับมืออาชีพ!",
    Duration = 6
})
