-- ✅ Ultimate Admin Panel (Mobile + PC)
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
local flyIndicator

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

local guiVisible = true

-- ===================== FLY =====================
local function createFlyIndicator()
	if flyIndicator then flyIndicator:Destroy() end
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	flyIndicator = Instance.new("BillboardGui")
	flyIndicator.Name = "FlyIndicator"
	flyIndicator.Adornee = root
	flyIndicator.Size = UDim2.new(0,100,0,50)
	flyIndicator.StudsOffset = Vector3.new(0,3,0)
	flyIndicator.AlwaysOnTop = true
	flyIndicator.Parent = game:GetService("CoreGui")

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.new(1,1,0)
	label.Text = "Fly: ON"
	label.Parent = flyIndicator
end

local function removeFlyIndicator()
	if flyIndicator then
		flyIndicator:Destroy()
		flyIndicator = nil
	end
end

local function startFly()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end
	flying = true
	createFlyIndicator()

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
	removeFlyIndicator()
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
		StarterGui:SetCore("SendNotification",{Title="No-Clip",Text="Enabled ✅",Duration=2})
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
		StarterGui:SetCore("SendNotification",{Title="No-Clip",Text="Disabled ❌",Duration=2})
	end
end

-- ===================== CLICK TELEPORT =====================
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
		StarterGui:SetCore("SendNotification",{Title="Click TP",Text="Enabled ✅",Duration=2})
	else
		if clickTPConn then clickTPConn:Disconnect() end
		StarterGui:SetCore("SendNotification",{Title="Click TP",Text="Disabled ❌",Duration=2})
	end
end

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,500)
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

-- CLOSE -> minimalizace do kolečka
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-45,0,5)
closeBtn.Text = "–"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeBtn.Parent = frame

-- malé kolečko pro zobrazení GUI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,50,0,50)
toggleBtn.Text = "⚡"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextScaled = true
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.Visible = false
toggleBtn.Parent = gui
toggleBtn.ZIndex = 10
toggleBtn.AutoButtonColor = true

-- Dragable toggleBtn
local dragging = false
local dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = toggleBtn.Position
	end
end)

toggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	toggleBtn.Visible = false
	guiVisible = true
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	toggleBtn.Visible = true
	guiVisible = false
end)

-- HELPER to make buttons
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

-- BUTTONS
local flyBtn = makeBtn("Fly: OFF",60,function()
	if flying then stopFly() flyBtn.Text = "Fly: OFF" else startFly() flyBtn.Text = "Fly: ON" end
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

local noclipBtn = makeBtn("No-Clip: OFF",350,function()
	toggleNoclip()
	noclipBtn.Text = noclipEnabled and "No-Clip: ON" or "No-Clip: OFF"
end)

local clickTPBtn = makeBtn("Click TP: OFF",400,function()
	toggleClickTP()
	clickTPBtn.Text = clickTPEnabled and "Click TP: ON" or "Click TP: OFF"
end)
