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
local LocalPlayer = Players.LocalPlayer
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

Rayfield:Notify({
    Title = "💠 BomDev Pro Menu Ready!",
    Content = "✨ ระบบทั้งหมดพร้อมใช้งานแล้ว พร้อม UI ระดับมืออาชีพ!",
    Duration = 6
})
