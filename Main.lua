-- HRAVYGAMER_STUDIO Admin Script s Fly a Random Functions
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

if localPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end

-- Fly
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity

local function startFly()
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	flying = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
	bodyGyro.P = 9e4
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not flying then
			conn:Disconnect()
			return
		end
		local cam = workspace.CurrentCamera
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

		bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
		bodyGyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flying = false
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

-- Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 200, 0, 30)
flyBtn.Position = UDim2.new(0, 25, 0, 50)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.new(1,0,0)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true
flyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
flyBtn.Parent = frame

flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyBtn.Text = "Fly: OFF"
		flyBtn.TextColor3 = Color3.fromRGB(1,0,0)
	else
		startFly()
		flyBtn.Text = "Fly: ON"
		flyBtn.TextColor3 = Color3.fromRGB(0,1,0)
	end
end)

-- Random Functions Section
local randomTitle = Instance.new("TextLabel")
randomTitle.Size = UDim2.new(0,200,0,25)
randomTitle.Position = UDim2.new(0,25,0,100)
randomTitle.Text = "Random Functions"
randomTitle.TextColor3 = Color3.new(1,1,1)
randomTitle.TextScaled = true
randomTitle.Font = Enum.Font.SourceSansBold
randomTitle.BackgroundTransparency = 1
randomTitle.Parent = frame

-- Function buttons
local functions = {
	{Text="Function 1", Code="print('Function 1')"},
	{Text="Function 2", Code="print('Function 2')"},
	{Text="Function 3", Code="print('Function 3')"}
}

for i, f in ipairs(functions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,200,0,30)
	btn.Position = UDim2.new(0,25,0,100 + i*40)
	btn.Text = f.Text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(f.Code)()
		end)
	end)
end
