local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckpointEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Checkpoint")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CHECKPOINT_COUNT = 100
local CHECK_DELAY = 0.1
local ROUND_DELAY = 1.5
local MAX_RETRY = 3
local SKIP_THRESHOLD = 4
local JITTER_MAX = 0.05

local autoRun = false
local bypassEnabled = false
local activeThread = nil
local failureCounts = {}
local skipList = {}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "🏁 Checkpoint Control Panel",
	LoadingTitle = "Rayfield UI",
	LoadingSubtitle = "by Digital Subsidy",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local MainTab = Window:CreateTab("⚙️ ระบบหลัก", 4483362458)
local StatusLabel = MainTab:CreateLabel("⛔ ระบบปิดอยู่")

local function randOffset(r)
	return (math.random() * 2 - 1) * r
end

local function safeFire(args)
	local id = tostring(args[1])
	if skipList[id] then return false, "skipped_by_user" end
	failureCounts[id] = failureCounts[id] or 0
	if failureCounts[id] >= SKIP_THRESHOLD then return false, "skipped_threshold" end

	local function attemptOnce(payload)
		local ok, err = pcall(function()
			CheckpointEvent:FireServer(unpack(payload))
		end)
		return ok, err
	end

	if bypassEnabled then
		local ok, err = attemptOnce(args)
		if ok then
			failureCounts[id] = 0
			return true
		else
		
			local altAttempts = 2
			local baseDelay = CHECK_DELAY * 0.8
			for i = 1, altAttempts do
				local alt = {}
				for k,v in ipairs(args) do alt[k] = v end		
				if type(alt[2]) == "number" then
					alt[2] = alt[2] + randOffset(0.08 * i) 
				end
				
				task.wait(baseDelay + math.random() * (JITTER_MAX*2))
				local ok2, err2 = attemptOnce(alt)
				if ok2 then
					failureCounts[id] = 0
					return true
				end
			end

			local retries = 0
			local backoff = 0.1
			repeat
				task.wait(backoff + math.random() * JITTER_MAX)
				ok, err = attemptOnce(args)
				if ok then
					failureCounts[id] = 0
					return true
				end
				retries = retries + 1
				backoff = backoff * 2 -- exponential backoff
			until ok or retries >= MAX_RETRY

			failureCounts[id] = failureCounts[id] + 1
			return false, err
		end
	else
		
		local ok, err = attemptOnce(args)
		if ok then
			failureCounts[id] = 0
			return true
		end
		local retries = 0
		repeat
			task.wait(CHECK_DELAY + math.random() * (JITTER_MAX * 0.5))
			ok, err = attemptOnce(args)
			retries = retries + 1
		until ok or retries >= MAX_RETRY

		if ok then
			failureCounts[id] = 0
			return true
		else
			failureCounts[id] = failureCounts[id] + 1
			return false, err
		end
	end
end

local function getAllCheckpoints()
	local list = {}
	for i = 1, CHECKPOINT_COUNT do
		
		table.insert(list, {i, 85.06828437093645})
	end
	return list
end

local function startAuto(StatusLabel)
	if activeThread then task.cancel(activeThread) end
	activeThread = task.spawn(function()
		while autoRun and LocalPlayer.Parent do
			local checkpoints = getAllCheckpoints()
			for i, args in ipairs(checkpoints) do
				if not autoRun then break end
				local ok, reason
				local retries = 0
				repeat
					ok, reason = safeFire(args)
					retries = retries + 1
					
					if bypassEnabled then
						task.wait(CHECK_DELAY + 0.05 + math.random() * JITTER_MAX)
					else
						task.wait(CHECK_DELAY + math.random() * JITTER_MAX)
					end
				until ok or retries >= (bypassEnabled and (MAX_RETRY + 1) or MAX_RETRY)
				StatusLabel:Set(string.format("กำลังเช็คจุด: %d/%d", i, #checkpoints))
				task.wait(0.05)
			end
			StatusLabel:Set("✅ All checkpoints done. Waiting...")
			task.wait(ROUND_DELAY)
		end
		StatusLabel:Set("⛔ ระบบปิดอยู่")
	end)
end

MainTab:CreateToggle({
	Name = "🟢 Auto Checkpoint",
	CurrentValue = false,
	Flag = "AutoCheckpoint",
	Callback = function(Value)
		autoRun = Value
		if Value then
			startAuto(StatusLabel)
		else
			if activeThread then task.cancel(activeThread) activeThread = nil end
			StatusLabel:Set("⛔ ระบบปิดอยู่")
		end
	end,
})

MainTab:CreateToggle({
	Name = "🛡️ Bypass (โหมดพิเศษ)",
	CurrentValue = false,
	Flag = "BypassToggle",
	Callback = function(Value)
		bypassEnabled = Value
		if Value then
			Rayfield:Notify({
				Title = "Bypass ON",
				Content = "โหมด Bypass เปิดแล้ว — ระบบจะยิงแบบ multi-shot พร้อม jitter",
				Duration = 3
			})
		else
			Rayfield:Notify({
				Title = "Bypass OFF",
				Content = "โหมด Bypass ปิดแล้ว — ระบบจะยิงแบบปกติ",
				Duration = 3
			})
		end
	end,
})

MainTab:CreateLabel("หมายเหตุ: Bypass ทำให้ระบบกันโปรแมพตรวจจับสิ่งผิดปกติไม่ได้")

Rayfield:Notify({
	Title = "ระบบพร้อม!",
	Content = "UI โหลดเสร็จแล้ว คุณสามารถเปิด Auto หรือ Bypass ได้เลย",
	Duration = 5
})
