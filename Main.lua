-- Compact Animated Ultimate Admin Panel (Mobile + PC)
-- LocalScript -> StarterPlayerScripts
-- Change OWNER to your username or remove check
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local OWNER = "HRAVYGAMER_STUDIO" -- <- change this or remove the name check

if OWNER and OWNER ~= "" then
    if LocalPlayer.Name ~= OWNER then return end
end

-- ========= STATE =========
local S = {
    flying = false, flySpeed = 70, flyGyro = nil, flyVel = nil, flyConn = nil,
    infiniteJump = false, jumpConn = nil,
    speed = 16,
    esp = false, espFolder = nil,
    noclip = false, noclipConn = nil,
    clickTP = false, clickTPConn = nil,
    hugeJump = false, bigStep = false,
    godMode = false, godConn = nil,
    antiAfk = false, antiAfkConn = nil,
    serverTPLoop = false, serverTPConn = nil,
    uiOpen = true
}

-- helper getters
local function getChar() return LocalPlayer.Character end
local function getHumanoid() local c = getChar(); if c then return c:FindFirstChildOfClass("Humanoid") end end
local function getRoot() local c = getChar(); if c then return c:FindFirstChild("HumanoidRootPart") end end

-- ========= ESP folder =========
S.espFolder = Instance.new("Folder")
S.espFolder.Name = "AdminESPFolder"
S.espFolder.Parent = game:GetService("CoreGui")

-- ========= INDICATORS =========
local indicators = {}
local indicatorOrder = {"Fly","Infinite Jump","No-Clip","Huge Jump","Big Step","GodMode","ServerTP"}
local function createIndicator(name, idx)
    if indicators[name] and indicators[name].Billboard and indicators[name].Billboard.Parent then return end
    local char = getChar()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Ind_"..name
    billboard.Adornee = root
    billboard.Size = UDim2.new(0,130,0,26)
    billboard.StudsOffset = Vector3.new(0, 3 + (idx or 0)*0.9, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game:GetService("CoreGui")
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 0.6
    label.BackgroundColor3 = Color3.fromRGB(20,20,20)
    label.TextColor3 = Color3.fromRGB(255,230,0)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextScaled = true
    label.Text = name
    indicators[name] = {Billboard = billboard, Label = label}
    billboard.Enabled = false
end

local function updateIndicator(name, active)
    if not indicators[name] then
        local idx = table.find(indicatorOrder, name) or 6
        createIndicator(name, idx-1)
    end
    if indicators[name] and indicators[name].Billboard then
        indicators[name].Billboard.Enabled = active
    end
end

local function recreateIndicators()
    for k,v in pairs(indicators) do
        pcall(function() if v.Billboard then v.Billboard:Destroy() end end)
    end
    indicators = {}
    for i,name in ipairs(indicatorOrder) do createIndicator(name, i-1) end
    updateIndicator("Fly", S.flying)
    updateIndicator("Infinite Jump", S.infiniteJump)
    updateIndicator("No-Clip", S.noclip)
    updateIndicator("Huge Jump", S.hugeJump)
    updateIndicator("Big Step", S.bigStep)
    updateIndicator("GodMode", S.godMode)
    updateIndicator("ServerTP", S.serverTPLoop)
end

LocalPlayer.CharacterAdded:Connect(function()
    wait(0.4)
    recreateIndicators()
end)
if LocalPlayer.Character then
    wait(0.2)
    recreateIndicators()
end

-- ========= FLY =========
local function startFly()
    local char = getChar(); local root = getRoot(); if not char or not root then return end
    local hum = getHumanoid(); if hum then hum.PlatformStand = true end
    S.flying = true; updateIndicator("Fly", true)
    S.flyGyro = Instance.new("BodyGyro"); S.flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9); S.flyGyro.P = 9e4; S.flyGyro.CFrame = root.CFrame; S.flyGyro.Parent = root
    S.flyVel = Instance.new("BodyVelocity"); S.flyVel.MaxForce = Vector3.new(9e9,9e9,9e9); S.flyVel.Velocity = Vector3.zero; S.flyVel.Parent = root
    S.flyConn = RunService.Heartbeat:Connect(function()
        if not S.flying then
            if S.flyConn then S.flyConn:Disconnect() S.flyConn = nil end
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
        S.flyVel.Velocity = (move.Magnitude > 0) and (move.Unit * S.flySpeed) or Vector3.zero
        S.flyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    S.flying = false
    if S.flyConn then S.flyConn:Disconnect() S.flyConn = nil end
    if S.flyGyro then pcall(function() S.flyGyro:Destroy() end) S.flyGyro = nil end
    if S.flyVel then pcall(function() S.flyVel:Destroy() end) S.flyVel = nil end
    local hum = getHumanoid(); if hum then pcall(function() hum.PlatformStand = false end) end
    updateIndicator("Fly", false)
end

-- ========= INFINITE JUMP =========
local function toggleInfiniteJump()
    S.infiniteJump = not S.infiniteJump
    if S.infiniteJump then
        if not S.jumpConn then
            S.jumpConn = UIS.JumpRequest:Connect(function()
                if S.infiniteJump then
                    local hum = getHumanoid()
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    else
        if S.jumpConn then S.jumpConn:Disconnect(); S.jumpConn = nil end
    end
    updateIndicator("Infinite Jump", S.infiniteJump)
end

-- ========= SPEED =========
local function setSpeed(v)
    S.speed = v
    local hum = getHumanoid()
    if hum then pcall(function() hum.WalkSpeed = S.speed end) end
end

-- ========= ESP =========
local function createESPForPlayer(p)
    if not p.Character then return end
    if S.espFolder:FindFirstChild(p.Name) then return end
    local f = Instance.new("Folder", S.espFolder); f.Name = p.Name
    local hl = Instance.new("Highlight", f); hl.Adornee = p.Character; hl.FillColor = Color3.fromRGB(255,0,0); hl.OutlineColor = Color3.fromRGB(255,0,0); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = S.esp
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bill = Instance.new("BillboardGui", f); bill.Adornee = hrp; bill.Size = UDim2.new(0,120,0,40); bill.StudsOffset = Vector3.new(0,2.8,0); bill.AlwaysOnTop = true
        local nameL = Instance.new("TextLabel", bill); nameL.Size = UDim2.new(1,0,0.5,0); nameL.Position = UDim2.new(0,0,0,0); nameL.BackgroundTransparency = 1; nameL.Text = p.Name; nameL.TextScaled = true; nameL.Font = Enum.Font.SourceSansBold; nameL.TextColor3 = Color3.new(1,1,1)
        local hpL = Instance.new("TextLabel", bill); hpL.Size = UDim2.new(1,0,0.5,0); hpL.Position = UDim2.new(0,0,0.5,0); hpL.BackgroundTransparency = 1; hpL.Text = "HP: ?"; hpL.TextScaled = true; hpL.Font = Enum.Font.SourceSansSemibold; hpL.TextColor3 = Color3.new(0,1,0)
        spawn(function()
            while f.Parent do
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    local hp = math.floor(p.Character:FindFirstChildOfClass("Humanoid").Health)
                    pcall(function() hpL.Text = "HP: "..hp end)
                    pcall(function() hl.Enabled = S.esp end)
                else
                    pcall(function() hpL.Text = "HP: -" end)
                end
                wait(0.6)
            end
        end)
    end
end

local function toggleESP()
    S.esp = not S.esp
    if S.esp then
        for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESPForPlayer(p) end end
        StarterGui:SetCore("SendNotification",{Title="ESP",Text="Enabled ✅",Duration=2})
    else
        for _,v in pairs(S.espFolder:GetChildren()) do pcall(function() v:Destroy() end) end
        StarterGui:SetCore("SendNotification",{Title="ESP",Text="Disabled ❌",Duration=2})
    end
end

Players.PlayerAdded:Connect(function(p) if S.esp then p.CharacterAdded:Wait(); createESPForPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p) if S.esp then pcall(function() local f = S.espFolder:FindFirstChild(p.Name); if f then f:Destroy() end end) end end)

-- ========= NOCLIP =========
local function toggleNoClip()
    S.noclip = not S.noclip
    if S.noclip then
        S.noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if char then
                for _,part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
                end
            end
        end)
    else
        if S.noclipConn then S.noclipConn:Disconnect(); S.noclipConn = nil end
        local char = getChar()
        if char then
            for _,part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
            end
        end
    end
    updateIndicator("No-Clip", S.noclip)
end

-- ========= CLICK TP =========
local function toggleClickTP()
    S.clickTP = not S.clickTP
    if S.clickTP then
        S.clickTPConn = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local mouse = LocalPlayer:GetMouse()
                local hit = mouse and mouse.Hit
                if hit then
                    local root = getRoot()
                    if root then root.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0)) end
                end
            end
        end)
    else
        if S.clickTPConn then S.clickTPConn:Disconnect(); S.clickTPConn = nil end
    end
end

-- ========= HUGE JUMP & BIG STEP =========
local function toggleHugeJump()
    local hum = getHumanoid(); if not hum then return end
    S.hugeJump = not S.hugeJump
    if S.hugeJump then pcall(function() hum.JumpHeight = 50 end) else pcall(function() hum.JumpHeight = 7.2 end) end
    updateIndicator("Huge Jump", S.hugeJump)
end
local function toggleBigStep()
    local hum = getHumanoid(); if not hum then return end
    S.bigStep = not S.bigStep
    if S.bigStep then pcall(function() hum.StepHeight = 10 end) else pcall(function() hum.StepHeight = 1 end) end
    updateIndicator("Big Step", S.bigStep)
end

-- ========= GOD MODE =========
local function toggleGodMode()
    S.godMode = not S.godMode
    updateIndicator("GodMode", S.godMode)
    local hum = getHumanoid()
    if S.godMode then
        if hum then pcall(function() hum.MaxHealth = 1e6 hum.Health = hum.MaxHealth end) end
        if hum then
            S.godConn = hum.HealthChanged:Connect(function()
                if S.godMode and hum and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
            end)
        end
    else
        if S.godConn then S.godConn:Disconnect(); S.godConn = nil end
        local hum2 = getHumanoid(); if hum2 then pcall(function() hum2.MaxHealth = 100 hum2.Health = hum2.MaxHealth end) end
    end
end

-- ========= ANTI AFK =========
local function toggleAntiAFK()
    S.antiAfk = not S.antiAfk
    if S.antiAfk then
        local vu = game:GetService("VirtualUser")
        S.antiAfkConn = LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0)); wait(0.1); vu:Button2Up(Vector2.new(0,0))
        end)
    else
        if S.antiAfkConn then S.antiAfkConn:Disconnect(); S.antiAfkConn = nil end
    end
end

-- ========= RESET =========
local function resetCharacter()
    local hum = getHumanoid(); if hum then pcall(function() hum.Health = 0 end) end
end

-- ========= TELEPORT TO PLAYER =========
local function teleportToPlayer(target)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = getRoot()
    if hrp and myRoot then myRoot.CFrame = hrp.CFrame + Vector3.new(0,3,0) end
end

-- ========= SERVER TP LOOP =========
local function serverTPLoopStart()
    if S.serverTPLoop then return end
    S.serverTPLoop = true; updateIndicator("ServerTP", true)
    S.serverTPConn = coroutine.create(function()
        while S.serverTPLoop do
            local players = {}
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(players, p)
                end
            end
            if #players > 0 then
                local target = players[math.random(1, #players)]
                teleportToPlayer(target)
            end
            wait(1.5) -- how often teleport happens
        end
    end)
    coroutine.resume(S.serverTPConn)
end

local function serverTPLoopStop()
    S.serverTPLoop = false; updateIndicator("ServerTP", false)
    S.serverTPConn = nil
end

local function toggleServerTPLoop()
    if S.serverTPLoop then serverTPLoopStop() else serverTPLoopStart() end
end

-- ========= UI: compact animated draggable GUI =========
local gui = Instance.new("ScreenGui")
gui.Name = "AnimatedAdminPanel"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0,340,0,240)
frame.Position = UDim2.new(0, 20, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.AnchorPoint = Vector2.new(0,0)

-- rounded look
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,8)

-- title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1,0,0,44)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "⚡ Admin Panel"
title.TextColor3 = Color3.new(1,1,1)

-- animated underline
local underline = Instance.new("Frame", titleBar)
underline.Size = UDim2.new(0, 120, 0, 3)
underline.Position = UDim2.new(0,12,1,-8)
underline.BackgroundColor3 = Color3.fromRGB(90,90,255)
local uc2 = Instance.new("UICorner", underline); uc2.CornerRadius = UDim.new(0,4)
underline.ClipsDescendants = true

-- close button (animated)
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,84,0,32)
closeBtn.Position = UDim2.new(1, -96, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansSemibold
closeBtn.TextScaled = true
closeBtn.Text = "Close"
local cbCorner = Instance.new("UICorner", closeBtn); cbCorner.CornerRadius = UDim.new(0,6)

-- open button (small) - created when closed
local openBtn

-- hint/ subtitle
local subtitle = Instance.new("TextLabel", frame)
subtitle.Size = UDim2.new(1,-24,0,18)
subtitle.Position = UDim2.new(0,12,0,50)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Tabs: Main | Teleport | Fun | Player | Misc"
subtitle.Font = Enum.Font.SourceSans
subtitle.TextColor3 = Color3.fromRGB(200,200,200)
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- tabs row
local tabsRow = Instance.new("Frame", frame)
tabsRow.Size = UDim2.new(1,-24,0,36)
tabsRow.Position = UDim2.new(0,12,0,74)
tabsRow.BackgroundTransparency = 1

local tabNames = {"Main","Teleport","Fun","Player","Misc"}
local pages = {}
local tabButtons = {}

for i,name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabsRow)
    btn.Size = UDim2.new(0, (296/#tabNames) - 6, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*((296/#tabNames)), 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.Text = name
    local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0,6)
    tabButtons[name] = btn

    local page = Instance.new("Frame", frame)
    page.Size = UDim2.new(1, -24, 0, 108)
    page.Position = UDim2.new(0,12,0,116)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for k,p in pairs(pages) do p.Visible = false end
        page.Visible = true
        -- animate tab colors
        for tn, b in pairs(tabButtons) do
            TweenService:Create(b, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(80,80,120)}):Play()
        -- move underline
        TweenService:Create(underline, TweenInfo.new(0.24, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 12 + (i-1)*((296/#tabNames)), 1, -8)}):Play()
    end)
end

-- helper to create buttons
local function makeButton(text, x, y, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 150, 0, 38)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
        -- small feedback
        local orig = btn.BackgroundColor3
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(80,80,80)}):Play()
        delay(0.09, function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = orig}):Play() end)
    end)
    return btn
end

-- Build Main page
do
    local p = pages["Main"]
    makeButton("Fly ON/OFF", 6, 6, p, function() if S.flying then stopFly() else startFly() end end)
    makeButton("Infinite Jump", 176, 6, p, function() toggleInfiniteJump() end)
    makeButton("+ Speed", 6, 52, p, function() setSpeed(S.speed + 5) end)
    makeButton("- Speed", 176, 52, p, function() if S.speed > 5 then setSpeed(S.speed - 5) end end)
    makeButton("ESP", 6, 98-38, p, function() toggleESP() end)
    makeButton("GodMode", 176, 98-38, p, function() toggleGodMode() end)
end

-- Teleport page
do
    local p = pages["Teleport"]
    makeButton("Click TP", 6, 6, p, function() toggleClickTP() end)
    makeButton("Server TP Loop", 176, 6, p, function() toggleServerTPLoop() end)
    makeButton("Reset Char", 6, 52, p, function() resetCharacter() end)
    -- dynamic players row
    local lbl = Instance.new("TextLabel", p)
    lbl.Size = UDim2.new(1,-24,0,18); lbl.Position = UDim2.new(0,12,0,86); lbl.BackgroundTransparency = 1
    lbl.Text = "Teleport to player:"; lbl.Font = Enum.Font.SourceSans; lbl.TextColor3 = Color3.fromRGB(200,200,200); lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextSize = 14

    local listFrame = Instance.new("Frame", p)
    listFrame.Size = UDim2.new(1,-24,0,28); listFrame.Position = UDim2.new(0,12,0,106); listFrame.BackgroundTransparency = 1
    local function refreshPlayers()
        for _,c in pairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local x = 0
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton", listFrame)
                b.Size = UDim2.new(0, 90, 0, 26)
                b.Position = UDim2.new(0, x, 0, 0)
                b.Font = Enum.Font.SourceSans
                b.TextScaled = true
                b.Text = pl.Name
                b.BackgroundColor3 = Color3.fromRGB(65,65,65); b.TextColor3 = Color3.new(1,1,1)
                local cr = Instance.new("UICorner", b); cr.CornerRadius = UDim.new(0,6)
                b.MouseButton1Click:Connect(function() teleportToPlayer(pl) end)
                x = x + 96
            end
        end
    end
    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
end

-- Fun page
do
    local p = pages["Fun"]
    makeButton("Huge Jump", 6, 6, p, function() toggleHugeJump() end)
    makeButton("Big Step", 176, 6, p, function() toggleBigStep() end)
    makeButton("Super Speed", 6, 52, p, function() setSpeed(60) end)
    makeButton("Normal Speed", 176, 52, p, function() setSpeed(16) end)
    makeButton("Spin", 6, 98-38, p, function()
        local root = getRoot()
        if root then spawn(function() for i=1,90 do root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(4), 0); wait(0.02); end end) end
    end)
    makeButton("Particles", 176, 98-38, p, function()
        local root = getRoot()
        if root then
            local pe = Instance.new("ParticleEmitter", root)
            pe.Rate = 120; pe.Lifetime = NumberRange.new(0.4); pe.Speed = NumberRange.new(2)
            delay(2, function() pe.Enabled = false; wait(1); pcall(function() pe:Destroy() end) end)
        end
    end)
end

-- Player page
do
    local p = pages["Player"]
    makeButton("No-Clip", 6, 6, p, function() toggleNoClip() end)
    makeButton("Anti-AFK", 176, 6, p, function() toggleAntiAFK() end)
    makeButton("Reset Char", 6, 52, p, function() resetCharacter() end)
    makeButton("Show Indicators", 176, 52, p, function() recreateIndicators() end)
end

-- Misc page
do
    local p = pages["Misc"]
    makeButton("Close Panel", 6, 6, p, function()
        if S.uiOpen then
            S.uiOpen = false
            -- animate close (scale down + fade)
            TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {Position = UDim2.new(0,20,0, -300)}):Play()
            wait(0.28)
            frame.Visible = false
            -- open button
            if not openBtn then
                openBtn = Instance.new("TextButton", gui)
                openBtn.Size = UDim2.new(0,52,0,52)
                openBtn.Position = UDim2.new(0, 20, 0, 60)
                openBtn.Text = "⚡"
                openBtn.Font = Enum.Font.GothamBold
                openBtn.TextScaled = true
                openBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                local oc = Instance.new("UICorner", openBtn); oc.CornerRadius = UDim.new(0,10)
                openBtn.MouseButton1Click:Connect(function()
                    frame.Visible = true
                    frame.Position = UDim2.new(0,20,0,-300)
                    TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Position = UDim2.new(0,20,0,60)}):Play()
                    openBtn:Destroy(); openBtn = nil; S.uiOpen = true
                end)
            end
        end
    end)
    makeButton("Cleanup ESP", 176, 6, p, function()
        for _,v in pairs(S.espFolder:GetChildren()) do pcall(function() v:Destroy() end) end; S.esp = false
    end)
    makeButton("Full Restore", 6, 52, p, function()
        setSpeed(16); if S.flying then stopFly() end; if S.noclip then toggleNoClip() end
        if S.clickTP then toggleClickTP() end; if S.esp then toggleESP() end; if S.infiniteJump then toggleInfiniteJump() end
        if S.hugeJump then toggleHugeJump() end; if S.bigStep then toggleBigStep() end; if S.godMode then toggleGodMode() end
        if S.antiAfk then toggleAntiAFK() end; if S.serverTPLoop then serverTPLoopStop() end
    end)
end

-- close button animation
closeBtn.MouseButton1Click:Connect(function()
    if S.uiOpen then
        S.uiOpen = false
        TweenService:Create(frame, TweenInfo.new(0.26, Enum.EasingStyle.Quad), {Position = UDim2.new(0,20,0,-300)}):Play()
        wait(0.26)
        frame.Visible = false
        if not openBtn then
            openBtn = Instance.new("TextButton", gui)
            openBtn.Size = UDim2.new(0,52,0,52)
            openBtn.Position = UDim2.new(0, 20, 0, 60)
            openBtn.Text = "⚡"
            openBtn.Font = Enum.Font.GothamBold
            openBtn.TextScaled = true
            openBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            local oc = Instance.new("UICorner", openBtn); oc.CornerRadius = UDim.new(0,10)
            openBtn.MouseButton1Click:Connect(function()
                frame.Visible = true
                frame.Position = UDim2.new(0,20,0,-300)
                TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Position = UDim2.new(0,20,0,60)}):Play()
                openBtn:Destroy(); openBtn = nil; S.uiOpen = true
            end)
        end
    end
end)

-- ========= DRAG (PC + Touch) =========
local dragging = false
local dragStart = nil
local startPos = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onInputChanged(input)
    if dragging and input.Position and dragStart and startPos then
        local delta = input.Position - dragStart
        local newX = math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X))
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y))
        frame.Position = UDim2.new(0, newX, 0, newY)
    end
end

frame.InputBegan:Connect(onInputBegan)
frame.InputChanged:Connect(onInputChanged)
UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then onInputChanged(input) end end)
UIS.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then onInputBegan(input) end end)

-- ========= CLEANUP ON CHARACTER REMOVE =========
LocalPlayer.CharacterRemoving:Connect(function()
    -- stop modes that reference character
    if S.flying then stopFly() end
    if S.noclip then toggleNoClip() end
    if S.godMode then toggleGodMode() end
    if S.serverTPLoop then serverTPLoopStop() end
    -- indicators will be recreated on CharacterAdded
end)

-- initial state
setSpeed(S.speed)
StarterGui:SetCore("SendNotification",{Title="Admin Panel", Text="Loaded (animated compact)", Duration=2})

-- safety: ensure indicators exist
recreateIndicators()
