--// ✅ Fly & Admin Panel Script (vylepšená verze)
-- Autor: HRAVYGAMER_STUDIO

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if localPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end -- Změň na své jméno

--// === FLY SYSTEM ===
local flying = false
local flySpeed = 60
local bodyGyro, bodyVelocity, conn

local function startFly()
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	
	flying = true
	hum.PlatformStand = true
	
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bodyGyro.P = 9e4
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
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
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

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
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").PlatformStand = false
	end
end

--// === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 430)
frame.Position = UDim2.new(0, 25, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Styl (rohy + layout)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 15)
padding.Parent = frame

-- Nadpis
local title = Instance.new("TextLabel")
title.Text = "🛠️ Admin Panel"
title.Size = UDim2.new(1, -20, 0, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

-- Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 220, 0, 35)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextScaled = true
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyBtn.Parent = frame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyBtn

flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyBtn.Text = "Fly: OFF"
		flyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		startFly()
		flyBtn.Text = "Fly: ON"
		flyBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
	end
end)

-- Oddělovač
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.85, 0, 0, 2)
divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
divider.BorderSizePixel = 0
divider.Parent = frame

-- Random Functions
local randomTitle = Instance.new("TextLabel")
randomTitle.Text = "⚙️ Random Functions"
randomTitle.Size = UDim2.new(1, -20, 0, 30)
randomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
randomTitle.Font = Enum.Font.SourceSansBold
randomTitle.TextScaled = true
randomTitle.BackgroundTransparency = 1
randomTitle.Parent = frame

-- Funkce
local functions = {
	{Text="Function 1", Code="loadstring(game:HttpGet('https://pastebin.com/raw/2wgbZ6Xd'))()"},
	{Text="Function 2", Code="print('Function 2')"},
	{Text="Function 3", Code="print('Function 3')"}
}

for _, f in ipairs(functions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 220, 0, 35)
	btn.Text = f.Text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		pcall(function()
			loadstring(f.Code)()
		end)
	end)
end
