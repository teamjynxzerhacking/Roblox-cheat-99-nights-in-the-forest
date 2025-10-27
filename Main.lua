-- ✅ Only for the owner
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

if localPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end --enter your username

-- ✈️ Fly system
local flying = false
local flySpeed = 50
local bodyGyro, bodyVelocity, conn

local function startFly()
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end

	flying = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
	bodyGyro.P = 9e4
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

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
	if conn then conn:Disconnect() end
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

-- 🖥️ GUI
local gui = Instance.new("ScreenGui")
gui.Parent = localPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 430)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- 🟢 Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 200, 0, 35)
flyBtn.Position = UDim2.new(0, 30, 0, 30)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(255,0,0)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true
flyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
flyBtn.Parent = frame

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

-- ⚙️ Fly Speed Controls
local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(0,200,0,25)
speedTitle.Position = UDim2.new(0,30,0,80)
speedTitle.Text = "Fly Speed: "..flySpeed
speedTitle.TextColor3 = Color3.new(1,1,1)
speedTitle.TextScaled = true
speedTitle.Font = Enum.Font.SourceSansBold
speedTitle.BackgroundTransparency = 1
speedTitle.Parent = frame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 40, 0, 30)
minusBtn.Position = UDim2.new(0, 30, 0, 110)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextScaled = true
minusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
minusBtn.Parent = frame

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 40, 0, 30)
plusBtn.Position = UDim2.new(0, 190, 0, 110)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.TextScaled = true
plusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
plusBtn.Parent = frame

plusBtn.MouseButton1Click:Connect(function()
	flySpeed += 5
	speedTitle.Text = "Fly Speed: "..flySpeed
end)

minusBtn.MouseButton1Click:Connect(function()
	if flySpeed > 5 then
		flySpeed -= 5
		speedTitle.Text = "Fly Speed: "..flySpeed
	end
end)

-- 🔮 Random Functions
local randomTitle = Instance.new("TextLabel")
randomTitle.Size = UDim2.new(0,200,0,25)
randomTitle.Position = UDim2.new(0,30,0,160)
randomTitle.Text = "Random Functions"
randomTitle.TextColor3 = Color3.new(1,1,1)
randomTitle.TextScaled = true
randomTitle.Font = Enum.Font.SourceSansBold
randomTitle.BackgroundTransparency = 1
randomTitle.Parent = frame

-- 📜 Function List
local functions = {
	{
		Text = "Function 1",
		Code = "loadstring(game:HttpGet('https://pastebin.com/raw/2wgbZ6Xd'))()"
	},
	{
		Text = "Function 2",
		Code = [[
			local ScreenGui = Instance.new("ScreenGui")
			local Frame = Instance.new("Frame")
			local Num = Instance.new("TextBox")
			local Plus = Instance.new("TextButton")
			local Minus = Instance.new("TextButton")

			ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			ScreenGui.ResetOnSpawn = false

			Frame.Size = UDim2.new(0, 200, 0, 100)
			Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
			Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			Frame.Parent = ScreenGui
			Frame.Active = true
			Frame.Draggable = true

			Num.Size = UDim2.new(0.6, 0, 0.6, 0)
			Num.Position = UDim2.new(0.2, 0, 0.3, 0)
			Num.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			Num.TextColor3 = Color3.new(1, 1, 1)
			Num.TextScaled = true
			Num.Font = Enum.Font.SourceSans
			Num.ClearTextOnFocus = true
			Num.Parent = Frame

			Plus.Size = UDim2.new(0.2, 0, 0.6, 0)
			Plus.Position = UDim2.new(0.8, 0, 0.3, 0)
			Plus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			Plus.TextColor3 = Color3.new(1, 1, 1)
			Plus.TextScaled = true
			Plus.Font = Enum.Font.SourceSans
			Plus.Text = "+"
			Plus.Parent = Frame

			Minus.Size = UDim2.new(0.2, 0, 0.6, 0)
			Minus.Position = UDim2.new(0, 0, 0.3, 0)
			Minus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			Minus.TextColor3 = Color3.new(1, 1, 1)
			Minus.TextScaled = true
			Minus.Font = Enum.Font.SourceSans
			Minus.Text = "-"
			Minus.Parent = Frame

			local player = game.Players.LocalPlayer
			local number
			local humanoid

			local function UpdateNum()
				Num.Text = tostring(number)
				if humanoid then
					humanoid.WalkSpeed = number
				end
			end

			local function onCharacterAdded(character)
				humanoid = character:WaitForChild("Humanoid")
				number = humanoid.WalkSpeed
				humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if humanoid.WalkSpeed ~= number then
						humanoid.WalkSpeed = number
					end
				end)
				UpdateNum()
			end

			player.CharacterAdded:Connect(onCharacterAdded)
			if player.Character then onCharacterAdded(player.Character) end

			Plus.MouseButton1Click:Connect(function()
				number = number + 1
				UpdateNum()
			end)

			Minus.MouseButton1Click:Connect(function()
				if number > 0 then
					number = number - 1
					UpdateNum()
				end
			end)

			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "[Bypass] WalkSpeed Gui",
				Text = "Made By the_king.78",
				Duration = 10
			})

			UpdateNum()
		]]
	},
	{
		Text = "Function 3",
		Code = "print('Function 3 executed successfully!')"
	}
}

-- 🔘 Create buttons
for i, f in ipairs(functions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,200,0,30)
	btn.Position = UDim2.new(0,30,0,180 + i*40)
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
