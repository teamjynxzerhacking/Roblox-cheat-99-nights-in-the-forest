-- ✅ Ultimate Admin Panel (Executor)
-- Autor: HRAVYGAMER_STUDIO

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- VARIABLES
if LocalPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end -- změň na svoje jméno

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

-- ===================== FLY =====================
local function startFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end

	flying = true

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
		if not flying then
			flyConn:Disconnect()
			return
		end
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
		StarterGui:SetCore("SendNotification",{Title="Infinite Jump",Text="Enabled ✅",Duration=2})
	else
		StarterGui:SetCore("SendNotification",{Title="Infinite Jump",Text="Disabled ❌",Duration=2})
	end
end

-- ===================== SPEED =====================
local function setSpeed(amount)
	local char = LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = amount
	end
end

-- ===================== ESP =====================
local function createESP(player)
	if espFolder:FindFirstChild(player.Name) then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = player.Name
	highlight.Parent = espFolder
	highlight.Adornee = player.Character
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.OutlineColor = Color3.fromRGB(255,0,0)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = espEnabled

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPBillboard"
	billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
	billboard.Size = UDim2.new(0,150,0,50)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = espFolder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1,0,0.5,0)
	nameLabel.Position = UDim2.new(0,0,0,0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1,1,1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Text = player.Name
	nameLabel.Parent = billboard

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Size = UDim2.new(1,0,0.5,0)
	hpLabel.Position = UDim2.new(0,0,0.5,0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.TextColor3 = Color3.new(0,1,0)
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.SourceSansBold
	hpLabel.Text = "100"
	hpLabel.Parent = billboard

	RS.Heartbeat:Connect(function()
		if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
			local hp = math.floor(player.Character:FindFirstChildOfClass("Humanoid").Health)
			hpLabel.Text = "HP: "..hp
			if highlight then highlight.Enabled = espEnabled end
		end
	end)
end

local function toggleESP()
	espEnabled = not espEnabled
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			createESP(p)
		end
	end
	StarterGui:SetCore("SendNotification",{Title="ESP",Text=espEnabled and "Enabled ✅" or "Disabled ❌",Duration=2})
end

Players.PlayerAdded:Connect(function(p)
	if espEnabled then
		createESP(p)
	end
end)

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,400)
frame.Position = UDim2.new(0,50,0,50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.Text = "⚡ Admin Panel"
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-45,0,5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local function makeBtn(text,posY,callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,240,0,35)
	btn.Position = UDim2.new(0,30,0,posY)
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Text = text
	btn.Parent = frame
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local flyBtn = makeBtn("Fly: OFF",60,function()
	if flying then
		stopFly()
		flyBtn.Text = "Fly: OFF"
	else
		startFly()
		flyBtn.Text = "Fly: ON"
	end
end)

local jumpBtn = makeBtn("Infinite Jump: OFF",110,function()
	toggleInfiniteJump()
	jumpBtn.Text = infiniteJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0,240,0,25)
speedLabel.Position = UDim2.new(0,30,0,160)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextScaled = true
speedLabel.Text = "Speed: "..speedValue
speedLabel.Parent = frame

local plusBtn = makeBtn("+ Speed",200,function()
	speedValue += 5
	speedLabel.Text = "Speed: "..speedValue
	setSpeed(speedValue)
end)

local minusBtn = makeBtn("- Speed",250,function()
	if speedValue > 5 then
		speedValue -= 5
		speedLabel.Text = "Speed: "..speedValue
		setSpeed(speedValue)
	end
end)

local espBtn = makeBtn("ESP: OFF",300,function()
	toggleESP()
	espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
end)
