-- ✅ Only for you
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
if player.Name ~= "HRAVYGAMER_STUDIO" then return end -- tvoje jméno

-- Variables
local flying = false
local flySpeed = 70
local flyGyro, flyVel, flyConn
local infiniteJumpEnabled = false
local jumpConn
local speedValue = 16

-- 🛫 FLY SYSTEM
local function startFly()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	flying = true
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end

	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyGyro.P = 9e4
	flyGyro.CFrame = root.CFrame
	flyGyro.Parent = root

	flyVel = Instance.new("BodyVelocity")
	flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
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
		if move.Magnitude > 0 then
			flyVel.Velocity = move.Unit * flySpeed
		else
			flyVel.Velocity = Vector3.zero
		end
		flyGyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flying = false
	if flyConn then flyConn:Disconnect() end
	if flyGyro then flyGyro:Destroy() end
	if flyVel then flyVel:Destroy() end
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

-- 🦘 INFINITE JUMP
local function toggleInfiniteJump()
	infiniteJumpEnabled = not infiniteJumpEnabled
	if infiniteJumpEnabled then
		if not jumpConn then
			jumpConn = UIS.JumpRequest:Connect(function()
				if infiniteJumpEnabled then
					local char = player.Character
					if char and char:FindFirstChildOfClass("Humanoid") then
						char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		end
		StarterGui:SetCore("SendNotification", {Title="Infinite Jump", Text="Enabled ✅", Duration=2})
	else
		StarterGui:SetCore("SendNotification", {Title="Infinite Jump", Text="Disabled ❌", Duration=2})
	end
end

-- 🚀 SPEED SYSTEM
local function setSpeed(amount)
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = amount
	end
end

-- 🖥️ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ControlGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 420)
frame.Position = UDim2.new(0, 30, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function makeBtn(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 35)
	btn.Position = UDim2.new(0, 30, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Text = text
	btn.Parent = frame
	return btn
end

-- Buttons
local flyBtn = makeBtn("Fly: OFF", 30)
local jumpBtn = makeBtn("Infinite Jump: OFF", 80)
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0,200,0,25)
speedLabel.Position = UDim2.new(0,30,0,130)
speedLabel.Text = "Speed: "..speedValue
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextScaled = true
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame

local plusBtn = makeBtn("+ Speed", 170)
local minusBtn = makeBtn("- Speed", 220)

-- 🔘 BUTTON LOGIC
flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyBtn.Text = "Fly: OFF"
		flyBtn.TextColor3 = Color3.fromRGB(255,0,0)
	else
		startFly()
		flyBtn.Text = "Fly: ON"
		flyBtn.TextColor3 = Color3.fromRGB(0,255,0)
	end
end)

jumpBtn.MouseButton1Click:Connect(function()
	toggleInfiniteJump()
	if infiniteJumpEnabled then
		jumpBtn.Text = "Infinite Jump: ON"
		jumpBtn.TextColor3 = Color3.fromRGB(0,255,0)
	else
		jumpBtn.Text = "Infinite Jump: OFF"
		jumpBtn.TextColor3 = Color3.fromRGB(255,0,0)
	end
end)

plusBtn.MouseButton1Click:Connect(function()
	speedValue += 5
	speedLabel.Text = "Speed: "..speedValue
	setSpeed(speedValue)
end)

minusBtn.MouseButton1Click:Connect(function()
	if speedValue > 5 then
		speedValue -= 5
		speedLabel.Text = "Speed: "..speedValue
		setSpeed(speedValue)
	end
end)
