-- ✅ Ultimate Admin Panel with Tabs and Status Indicators
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

if LocalPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end -- změň na svoje jméno

-- VARIABLES
local flying = false
local flySpeed = 70
local flyGyro, flyVel, flyConn
local infiniteJumpEnabled = false
local jumpConn
local speedValue = 16
local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = game:GetService("CoreGui")
local noclipEnabled = false
local noclipConn
local clickTPEnabled = false
local clickTPConn
local hugeJumpEnabled = false
local bigStepEnabled = false

local statusIndicators = {}

-- ===================== STATUS INDICATORS =====================
local function updateIndicator(name, active)
	if not statusIndicators[name] then
		local char = LocalPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = name.."Indicator"
		billboard.Adornee = root
		billboard.Size = UDim2.new(0,120,0,30)
		billboard.StudsOffset = Vector3.new(0,3 + (#statusIndicators)*0.8,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = game:GetService("CoreGui")

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.TextColor3 = Color3.new(1,1,0)
		label.Text = name
		label.Parent = billboard

		statusIndicators[name] = {Billboard=billboard, Label=label}
	end
	statusIndicators[name].Billboard.Enabled = active
end

-- ===================== FLY =====================
local function startFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end
	flying = true
	updateIndicator("Fly", true)

	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	flyGyro.P = 9e4
	flyGyro.CFrame = root.CFrame
	flyGyro.Parent = root

	flyVel = Instance.new("BodyVelocity")
	flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
	flyVel.Velocity = Vector3.zero
	flyVel.Parent = root

	flyConn = RS.Heartbeat:Connect(function()
		if not flying then flyConn:Disconnect() return end
		local cam = workspace.CurrentCamera
		local move = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
		flyVel.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
		flyGyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flying = false
	if flyConn then flyConn:Disconnect() end
	if flyGyro then flyGyro:Destroy() end
	if flyVel then flyVel:Destroy() end
	updateIndicator("Fly", false)
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

-- ===================== INFINITE JUMP =====================
local function toggleInfiniteJump()
	infiniteJumpEnabled = not infiniteJumpEnabled
	if infiniteJumpEnabled then
		if not jumpConn then
			jumpConn = UIS.JumpRequest:Connect(function()
				if infiniteJumpEnabled then
					local char = LocalPlayer.Character
					if char and char:FindFirstChildOfClass("Humanoid") then
						char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		end
		updateIndicator("Infinite Jump", true)
	else
		updateIndicator("Infinite Jump", false)
	end
end

-- ===================== SPEED =====================
local function setSpeed(amount)
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = amount
	end
end

-- ===================== NOCLIP =====================
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		noclipConn = RS.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, part in pairs(char:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
		updateIndicator("No-Clip", true)
	else
		if noclipConn then noclipConn:Disconnect() end
		local char = LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
		updateIndicator("No-Clip", false)
	end
end

-- ===================== CLICK TP =====================
local function toggleClickTP()
	clickTPEnabled = not clickTPEnabled
	if clickTPEnabled then
		clickTPConn = UIS.InputBegan:Connect(function(input, processed)
			if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mouse = LocalPlayer:GetMouse()
				local targetPos = mouse.Hit.Position
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					root.CFrame = CFrame.new(targetPos + Vector3.new(0,3,0))
				end
			end
		end)
	else
		if clickTPConn then clickTPConn:Disconnect() end
	end
end

-- ===================== FUN FEATURES =====================
local function toggleHugeJump()
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hugeJumpEnabled then
			hum.JumpHeight = 7.2
			hugeJumpEnabled = false
		else
			hum.JumpHeight = 50
			hugeJumpEnabled = true
		end
		updateIndicator("Huge Jump", hugeJumpEnabled)
	end
end

local function toggleBigStep()
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if bigStepEnabled then
			hum.StepHeight = 1
			bigStepEnabled = false
		else
			hum.StepHeight = 10
			bigStepEnabled = true
		end
		updateIndicator("Big Step", bigStepEnabled)
	end
end

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,340,0,400)
frame.Position = UDim2.new(0,50,0,50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.Text = "⚡ Admin Panel"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

-- TAB BUTTONS
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1,0,0,30)
tabsFrame.Position = UDim2.new(0,0,0,40)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local tabNames = {"Main","Teleport","Fun","Player","Misc"}
local tabButtons = {}
local pages = {}

for i,name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,60,1,0)
	btn.Position = UDim2.new(0,60*(i-1),0,0)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = tabsFrame
	tabButtons[i] = btn

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1,0,1,-70)
	page.Position = UDim2.new(0,0,0,70)
	page.BackgroundTransparency = 1
	page.Visible = (i==1)
	page.Parent = frame
	pages[i] = page

	btn.MouseButton1Click:Connect(function()
		for j,p in ipairs(pages) do
			p.Visible = false
		end
		page.Visible = true
	end)
end

-- Helper to create buttons
local function makeBtn(text,posY,parent,callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,240,0,35)
	btn.Position = UDim2.new(0,50,0,posY)
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Text = text
	btn.Parent = parent
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- MAIN TAB
makeBtn("Fly",10,pages[1],function()
	if flying then stopFly() else startFly() end
end)
makeBtn("Infinite Jump",60,pages[1],toggleInfiniteJump)
makeBtn("+ Speed",110,pages[1],function()
	speedValue += 5
	setSpeed(speedValue)
end)
makeBtn("- Speed",160,pages[1],function()
	if speedValue>5 then speedValue-=5 setSpeed(speedValue) end
end)
makeBtn("ESP",210,pages[1],toggleESP)

-- TELEPORT TAB
makeBtn("Click TP",10,pages[2],toggleClickTP)

-- FUN TAB
makeBtn("Huge Jump",10,pages[3],toggleHugeJump)
makeBtn("Big Step",60,pages[3],toggleBigStep)

-- PLAYER TAB
makeBtn("No-Clip",10,pages[4],toggleNoclip)

-- Misc tab reserved
