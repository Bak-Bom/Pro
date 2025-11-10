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
local LocalPlayer = Players.LocalPlayer 
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera


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
local viewing = false
local currentViewed = nil
local godModeEnabled = false
local originalMaterials = {}
local fpsBoostEnabled = false

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
local function setGodMode(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hum then
        Rayfield:Notify({
            Title = "⚠️ God Mode",
            Content = "ไม่พบ Humanoid ในตัวละคร",
            Duration = 2
        })
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

            Rayfield:Notify({
                Title = "💎 God Mode",
                Content = "เปิดโหมดอมตะแล้ว (อาจไม่ใช้ได้ทุกเกม)",
                Duration = 3
            })

            godModeEnabled = true
        end
    else
        if godModeEnabled then
            local currentHum = char:FindFirstChildOfClass("Humanoid")
            if currentHum then
                currentHum.Health = currentHum.MaxHealth
                currentHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
            Rayfield:Notify({
                Title = "💀 God Mode",
                Content = "ปิดโหมดอมตะแล้ว",
                Duration = 3
            })
            godModeEnabled = false
        end
    end
end

local function toggleAntiAFK(state)
    if state then
        Rayfield:Notify({
            Title = "🛡 Anti-AFK",
            Content = "เปิดระบบป้องกันหลุดแล้ว!",
            Duration = 3
        })
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    else
        Rayfield:Notify({
            Title = "🛡 Anti-AFK",
            Content = "ปิดระบบป้องกันหลุดแล้ว!",
            Duration = 3
        })
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
    Name = "👥 เลือกผู้เล่นในเซิร์ฟ",
    Options = refreshPlayerList(),
    CurrentOption = nil,
    Flag = "PlayerList",
    Callback = function(option)
        local playerName = typeof(option) == "table" and option[1] or option
        local plr = Players:FindFirstChild(playerName)
        if plr then
            selectedPlayer = plr
            Rayfield:Notify({
                Title = "✅ เลือกผู้เล่นแล้ว",
                Content = "คุณเลือก: " .. playerName,
                Duration = 2
            })
        else
            selectedPlayer = nil
            Rayfield:Notify({
                Title = "⚠️ ไม่พบผู้เล่น",
                Content = "ผู้เล่นนี้อาจออกจากเกมแล้ว",
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
            Title = "🔁 รายชื่ออัปเดตแล้ว",
            Content = "รีเฟรชผู้เล่นในเซิร์ฟเวอร์สำเร็จ ✅",
            Duration = 2
        })
    end
})

TeleportTab:CreateButton({
    Name = "⚡ วาร์ปไปหาผู้เล่นที่เลือก",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char:MoveTo(selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                Rayfield:Notify({
                    Title = "⚡ วาร์ปสำเร็จ",
                    Content = "คุณถูกวาร์ปไปหา " .. selectedPlayer.Name,
                    Duration = 2
                })
            end
        else
            Rayfield:Notify({
                Title = "❌ วาร์ปล้มเหลว",
                Content = "กรุณาเลือกผู้เล่นก่อน หรือผู้เล่นไม่มีตัวในเกม",
                Duration = 2
            })
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

                Rayfield:Notify({
                    Title = "👁‍🗨 View Enabled",
                    Content = "กำลังส่อง " .. currentViewed.Name,
                    Duration = 3
                })

                task.spawn(function()
                    while viewing do
                        task.wait(0.5)
                        if not currentViewed or not currentViewed.Character or not currentViewed.Character:FindFirstChild("Humanoid") then
                            viewing = false
                            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                            Rayfield:Notify({
                                Title = "⚠️ ผู้เล่นหายไป",
                                Content = "ออกจากโหมดส่องอัตโนมัติ",
                                Duration = 2
                            })
                            break
                        end
                    end
                end)
            else
                Rayfield:Notify({
                    Title = "⚠️ ไม่สามารถส่องได้",
                    Content = "กรุณาเลือกผู้เล่นก่อน หรือผู้เล่นไม่มีตัวอยู่ในเกม",
                    Duration = 3
                })
            end
        else
            viewing = false
            currentViewed = nil
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            Rayfield:Notify({
                Title = "👁‍🗨 View Disabled",
                Content = "ออกจากโหมดส่องผู้เล่นแล้ว",
                Duration = 2
            })
        end
    end
})

local ExtraTab = Window:CreateTab("⚙️ Extra Features", 4483362458)

ExtraTab:CreateToggle({
    Name = "🛡 ป้องกันหลุดออก (Anti-AFK)",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = toggleAntiAFK
})

ExtraTab:CreateToggle({
    Name = "🔁 รีเข้าอัตโนมัติ (Auto Rejoin)",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(state)
        if state then
            Rayfield:Notify({
                Title = "🔁 Auto Rejoin",
                Content = "จะกลับเข้าทันทีถ้าหลุดจากเซิร์ฟ!",
                Duration = 3
            })
            game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
                if obj.Name == "ErrorPrompt" then
                    task.wait(2)
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end
            end)
        else
            Rayfield:Notify({
                Title = "🔁 Auto Rejoin",
                Content = "ปิดระบบรีเข้าอัตโนมัติแล้ว",
                Duration = 3
            })
        end
    end
})

ExtraTab:CreateToggle({
    Name = "🌈 ร่างสายรุ้ง (Rainbow Mode)",
    CurrentValue = false,
    Flag = "RainbowMode",
    Callback = function(state)
        if state then
            Rayfield:Notify({
                Title = "🌈 Rainbow Mode",
                Content = "เปิดเอฟเฟกต์สีสายรุ้งแล้ว!",
                Duration = 3
            })
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
            Rayfield:Notify({
                Title = "🌈 Rainbow Mode",
                Content = "ปิดโหมดสายรุ้งแล้ว!",
                Duration = 3
            })
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
            Rayfield:Notify({
                Title = "🚀 FPS Booster",
                Content = "เปิดโหมดประหยัดเฟรมแล้ว เกมจะลื่นขึ้น!",
                Duration = 3
            })
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
            Rayfield:Notify({
                Title = "🚀 FPS Booster",
                Content = "ปิดโหมดประหยัดเฟรมแล้ว!",
                Duration = 3
            })
        end
    end
})
UtilsTab:CreateToggle({
    Name = "🪂 ไม่ตกเสียหาย (No Fall Damage)",
    CurrentValue = false,
    Flag = "NoFallDamage",
    Callback = function(state)
        if state then
            Rayfield:Notify({Title="🪂 No Fall Damage", Content="เปิดแล้ว!", Duration=2})
            LocalPlayer.CharacterAdded:Connect(function(char)
                local hum = char:WaitForChild("Humanoid")
                hum.PlatformStand = false
                hum.FloorMaterial = Enum.Material.Air
            end)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
            end
        else
            Rayfield:Notify({Title="🪂 No Fall Damage", Content="ปิดแล้ว!", Duration=2})
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
        if state then
            Rayfield:Notify({Title="🌊 Walk on Water", Content="เปิดแล้ว!", Duration=2})
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterWaveSize = 0
            LocalPlayer.CharacterAdded:Connect(function(char)
                char:WaitForChild("HumanoidRootPart").CanCollide = true
            end)
        else
            Rayfield:Notify({Title="🌊 Walk on Water", Content="ปิดแล้ว!", Duration=2})
            workspace.Terrain.WaterWaveSpeed = 1
            workspace.Terrain.WaterWaveSize = 1
        end
    end
})
UtilsTab:CreateButton({
    Name = "📍 บันทึกตำแหน่งปัจจุบัน",
    Callback = function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        Rayfield:Notify({Title="📍 บันทึกแล้ว", Content="ตำแหน่งถูกบันทึก!", Duration=2})
        _G.SavedPosition = pos
    end
})
UtilsTab:CreateButton({
    Name = "🚀 วาร์ปไปตำแหน่งบันทึก",
    Callback = function()
        if _G.SavedPosition then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(_G.SavedPosition + Vector3.new(0,5,0))
            Rayfield:Notify({Title="🚀 วาร์ปแล้ว", Content="ไปยังจุดที่บันทึกไว้!", Duration=2})
        else
            Rayfield:Notify({Title="⚠️ ไม่มีจุดบันทึก", Content="โปรดบันทึกก่อน!", Duration=2})
        end
    end
})
Rayfield:Notify({
    Title = "💠 BomDev Pro Menu Ready!",
    Content = "✨ ระบบทั้งหมดพร้อมใช้งานแล้ว พร้อม UI ระดับมืออาชีพ!",
    Duration = 6
})
