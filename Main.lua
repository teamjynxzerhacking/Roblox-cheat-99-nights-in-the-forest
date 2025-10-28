-- ✅ Compact Ultimate Admin Panel (Mobile + PC) - single LocalScript
-- Drop into a LocalScript (StarterPlayerScripts recommended)
-- Change the name check or remove if you want it for anyone
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = RS
local LocalPlayer = Players.LocalPlayer

-- CHANGE THIS TO YOUR USERNAME OR REMOVE THE CHECK
if LocalPlayer.Name ~= "HRAVYGAMER_STUDIO" then return end

-- ---------- State ----------
local state = {
    flying = false,
    flySpeed = 70,
    flyGyro = nil,
    flyVel = nil,
    flyConn = nil,
    infiniteJump = false,
    jumpConn = nil,
    speed = 16,
    esp = false,
    espFolder = nil,
    noclip = false,
    noclipConn = nil,
    clickTP = false,
    clickTPConn = nil,
    hugeJump = false,
    bigStep = false,
    godMode = false,
    godConn = nil,
    antiAfk = false,
    antiAfkConn = nil
}

-- helper: safe get character/humanoid/root
local function getChar()
    return LocalPlayer.Character
end
local function getHumanoid()
    local c = getChar()
    if c then return c:FindFirstChildOfClass("Humanoid") end
end
local function getRoot()
    local c = getChar()
    if c then return c:FindFirstChild("HumanoidRootPart") end
end

-- ---------- ESP folder ----------
state.espFolder = Instance.new("Folder")
state.espFolder.Name = "ESPFolder_AdminPanel"
state.espFolder.Parent = game:GetService("CoreGui")

-- ---------- Status indicators (small billboards) ----------
local indicators = {}
local function createIndicator(name, order)
    if indicators[name] and indicators[name].Billboard and indicators[name].Billboard.Parent then return end
    local char = getChar()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Indicator_" .. name
    billboard.Adornee = root
    billboard.Size = UDim2.new(0,120,0,26)
    billboard.StudsOffset = Vector3.new(0, 3 + (order or 0) * 0.9, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game:GetService("CoreGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 0.6
    label.BackgroundColor3 = Color3.fromRGB(30,30,30)
    label.TextColor3 = Color3.new(1,1,0)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansSemibold
    label.Text = name
    label.Parent = billboard

    indicators[name] = {Billboard = billboard, Label = label}
    billboard.Enabled = false
end

local function updateIndicator(name, active)
    -- ensure indicator exists (order based on fixed list)
    local orderMap = {["Fly"]=0, ["Infinite Jump"]=1, ["No-Clip"]=2, ["Huge Jump"]=3, ["Big Step"]=4, ["GodMode"]=5}
    if not indicators[name] then createIndicator(name, orderMap[name] or 6) end
    if indicators[name] and indicators[name].Billboard then
        indicators[name].Billboard.Enabled = active
    end
end

-- Recreate indicators on character spawn
local function recreateIndicators()
    -- destroy existing
    for _, v in pairs(indicators) do
        if v.Billboard then pcall(function() v.Billboard:Destroy() end) end
    end
    indicators = {}
    -- create ones we might use (but keep disabled until used)
    local names = {"Fly","Infinite Jump","No-Clip","Huge Jump","Big Step","GodMode"}
    for i,name in ipairs(names) do createIndicator(name, i-1) end
    -- set according to state
    updateIndicator("Fly", state.flying)
    updateIndicator("Infinite Jump", state.infiniteJump)
    updateIndicator("No-Clip", state.noclip)
    updateIndicator("Huge Jump", state.hugeJump)
    updateIndicator("Big Step", state.bigStep)
    updateIndicator("GodMode", state.godMode)
end

LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    recreateIndicators()
end)
-- create initially if character present
if LocalPlayer.Character then
    wait(0.2)
    recreateIndicators()
end

-- ---------- FLY ----------
local function startFly()
    local char = getChar()
    local root = getRoot()
    if not char or not root then return end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end
    state.flying = true
    updateIndicator("Fly", true)

    state.flyGyro = Instance.new("BodyGyro")
    state.flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    state.flyGyro.P = 9e4
    state.flyGyro.CFrame = root.CFrame
    state.flyGyro.Parent = root

    state.flyVel = Instance.new("BodyVelocity")
    state.flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    state.flyVel.Velocity = Vector3.zero
    state.flyVel.Parent = root

    state.flyConn = RunService.Heartbeat:Connect(function()
        if not state.flying then
            if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
            return
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        -- PC input
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        -- mobile: use thumbstick emulation with touching screen center (simple)
        -- (player can move with normal controls on mobile; main fallback is key-based)
        state.flyVel.Velocity = (move.Magnitude > 0) and (move.Unit * state.flySpeed) or Vector3.zero
        state.flyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    state.flying = false
    if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
    if state.flyGyro then pcall(function() state.flyGyro:Destroy() end) state.flyGyro = nil end
    if state.flyVel then pcall(function() state.flyVel:Destroy() end) state.flyVel = nil end
    local hum = getHumanoid()
    if hum then pcall(function() hum.PlatformStand = false end) end
    updateIndicator("Fly", false)
end

-- ---------- INFINITE JUMP ----------
local function toggleInfiniteJump()
    state.infiniteJump = not state.infiniteJump
    if state.infiniteJump then
        if not state.jumpConn then
            state.jumpConn = UIS.JumpRequest:Connect(function()
                if state.infiniteJump then
                    local hum = getHumanoid()
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    else
        if state.jumpConn then state.jumpConn:Disconnect() state.jumpConn = nil end
    end
    updateIndicator("Infinite Jump", state.infiniteJump)
end

-- ---------- SPEED ----------
local function setSpeed(v)
    state.speed = v
    local hum = getHumanoid()
    if hum then pcall(function() hum.WalkSpeed = state.speed end) end
end

-- ---------- ESP ----------
local function createESPForPlayer(p)
    if not p.Character then return end
    if state.espFolder:FindFirstChild(p.Name) then return end
    local container = Instance.new("Folder", state.espFolder)
    container.Name = p.Name

    local highlight = Instance.new("Highlight", container)
    highlight.Adornee = p.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.OutlineColor = Color3.fromRGB(255,0,0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = state.esp

    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local billboard = Instance.new("BillboardGui", container)
        billboard.Name = "ESPBillboard"
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0,120,0,40)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size = UDim2.new(1,0,0.5,0)
        nameLabel.Position = UDim2.new(0,0,0,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = p.Name
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextColor3 = Color3.new(1,1,1)

        local hpLabel = Instance.new("TextLabel", billboard)
        hpLabel.Size = UDim2.new(1,0,0.5,0)
        hpLabel.Position = UDim2.new(0,0,0.5,0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.Text = "HP: ?"
        hpLabel.TextScaled = true
        hpLabel.Font = Enum.Font.SourceSansSemibold
        hpLabel.TextColor3 = Color3.new(0,1,0)

        -- update hp
        spawn(function()
            while container.Parent do
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    local hp = math.floor(p.Character:FindFirstChildOfClass("Humanoid").Health)
                    pcall(function() hpLabel.Text = "HP: "..hp end)
                    highlight.Enabled = state.esp
                else
                    pcall(function() hpLabel.Text = "HP: -" end)
                end
                wait(0.6)
            end
        end)
    end
end

local function removeESPForPlayer(p)
    local f = state.espFolder:FindFirstChild(p.Name)
    if f then pcall(function() f:Destroy() end) end
end

local function toggleESP()
    state.esp = not state.esp
    if state.esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then createESPForPlayer(p) end
        end
        StarterGui:SetCore("SendNotification", {Title="ESP", Text="Enabled ✅", Duration=2})
    else
        for _, v in pairs(state.espFolder:GetChildren()) do pcall(function() v:Destroy() end) end
        StarterGui:SetCore("SendNotification", {Title="ESP", Text="Disabled ❌", Duration=2})
    end
end

Players.PlayerAdded:Connect(function(p)
    if state.esp then
        p.CharacterAdded:Wait()
        createESPForPlayer(p)
    end
end)
Players.PlayerRemoving:Connect(function(p) removeESPForPlayer(p) end)

-- ---------- NOCLIP ----------
local function toggleNoClip()
    state.noclip = not state.noclip
    if state.noclip then
        state.noclipConn = RunService.Stepped:Connect(function()
            local char = getChar()
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end)
    else
        if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
        local char = getChar()
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = true end)
                end
            end
        end
    end
    updateIndicator("No-Clip", state.noclip)
end

-- ---------- CLICK TP ----------
local function toggleClickTP()
    state.clickTP = not state.clickTP
    if state.clickTP then
        state.clickTPConn = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            -- allow touch or mouse button
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local mouse = LocalPlayer:GetMouse()
                local hit = mouse and mouse.Hit
                if hit then
                    local root = getRoot()
                    if root then
                        root.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
                    end
                end
            end
        end)
    else
        if state.clickTPConn then state.clickTPConn:Disconnect() state.clickTPConn = nil end
    end
end

-- ---------- HUGE JUMP & BIG STEP ----------
local function toggleHugeJump()
    local hum = getHumanoid()
    if not hum then return end
    state.hugeJump = not state.hugeJump
    if state.hugeJump then
        pcall(function() hum.JumpHeight = 50 end)
    else
        pcall(function() hum.JumpHeight = 7.2 end) -- default-like
    end
    updateIndicator("Huge Jump", state.hugeJump)
end

local function toggleBigStep()
    local hum = getHumanoid()
    if not hum then return end
    state.bigStep = not state.bigStep
    if state.bigStep then
        pcall(function() hum.StepHeight = 10 end)
    else
        pcall(function() hum.StepHeight = 1 end)
    end
    updateIndicator("Big Step", state.bigStep)
end

-- ---------- GOD MODE ----------
local function toggleGodMode()
    state.godMode = not state.godMode
    updateIndicator("GodMode", state.godMode)
    local hum = getHumanoid()
    if state.godMode then
        if hum then
            pcall(function()
                hum.MaxHealth = 1e6
                hum.Health = hum.MaxHealth
            end)
        end
        -- listen for health drops and restore
        state.godConn = hum and hum.HealthChanged:Connect(function(h)
            if state.godMode and hum and hum.Health < hum.MaxHealth then
                pcall(function() hum.Health = hum.MaxHealth end)
            end
        end)
    else
        if state.godConn then state.godConn:Disconnect() state.godConn = nil end
        local hum2 = getHumanoid()
        if hum2 then
            pcall(function() hum2.MaxHealth = 100 hum2.Health = hum2.MaxHealth end)
        end
    end
end

-- ---------- ANTI AFK ----------
local function toggleAntiAFK()
    state.antiAfk = not state.antiAfk
    if state.antiAfk then
        local vu = game:GetService("VirtualUser")
        state.antiAfkConn = LocalPlayer.Idled:Connect(function()
            -- emulate input
            vu:Button2Down(Vector2.new(0,0))
            wait(0.2)
            vu:Button2Up(Vector2.new(0,0))
        end)
    else
        if state.antiAfkConn then state.antiAfkConn:Disconnect() state.antiAfkConn = nil end
    end
end

-- ---------- RESET CHARACTER ----------
local function resetCharacter()
    local hum = getHumanoid()
    if hum then pcall(function() hum.Health = 0 end) end
end

-- ---------- TELEPORT TO PLAYER ----------
local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = getRoot()
    if hrp and myRoot then
        myRoot.CFrame = hrp.CFrame + Vector3.new(0,3,0)
    end
end

-- ---------- UI: compact top-tab GUI ----------
local gui = Instance.new("ScreenGui")
gui.Name = "CompactAdminPanel"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0,320,0,230) -- compact
frame.Position = UDim2.new(0,20,0,60)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
-- draggable for PC (touch still works)
local dragToggle = false
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
    end
end)
frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)
local startPos, startMouse
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
        local mouse = UIS:GetMouseLocation()
        frame.Position = UDim2.new(0, mouse.X - 160, 0, mouse.Y - 40)
    end
end)

-- Title bar
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -80, 0, 36)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "⚡ Admin Panel"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,60,0,28)
closeBtn.Position = UDim2.new(1, -70, 0, 6)
closeBtn.Text = "Close"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
local openBtn -- will create later

-- small hint
local hint = Instance.new("TextLabel", frame)
hint.Size = UDim2.new(1,-20,0,18)
hint.Position = UDim2.new(0,10,0,44)
hint.BackgroundTransparency = 1
hint.Text = "Tabs: Main | Teleport | Fun | Player | Misc"
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.Font = Enum.Font.SourceSans
hint.TextSize = 14
hint.TextXAlignment = Enum.TextXAlignment.Left

-- Tabs row
local tabsRow = Instance.new("Frame", frame)
tabsRow.Size = UDim2.new(1, -20, 0, 34)
tabsRow.Position = UDim2.new(0,10,0,66)
tabsRow.BackgroundTransparency = 1

local tabNames = {"Main","Teleport","Fun","Player","Misc"}
local pages = {}
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabsRow)
    btn.Size = UDim2.new(0, (300/#tabNames) - 6, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*((300/#tabNames)), 0, 0)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Name = "Tab_"..name

    local page = Instance.new("Frame", frame)
    page.Size = UDim2.new(1, -20, 0, 110)
    page.Position = UDim2.new(0,10,0,106)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    pages[name] = page
    tabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        page.Visible = true
        -- visual highlight
        for _,b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(50,50,50) end
        btn.BackgroundColor3 = Color3.fromRGB(85,85,85)
    end)
end

-- Helper factory for buttons inside pages (touch-friendly)
local function makeButton(text, posX, posY, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 130, 0, 38)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(1,1,1)
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

-- MAIN PAGE (first)
do
    local p = pages["Main"]
    makeButton("Fly ON/OFF", 10, 6, p, function()
        if state.flying then stopFly() else startFly() end
    end)
    makeButton("Infinite Jump", 160, 6, p, function() toggleInfiniteJump() end)

    makeButton("+ Speed", 10, 52, p, function()
        setSpeed(state.speed + 5)
    end)
    makeButton("- Speed", 160, 52, p, function()
        if state.speed > 5 then setSpeed(state.speed - 5) end
    end)

    makeButton("ESP", 10, 98-38, p, function() toggleESP() end)
    makeButton("GodMode", 160, 98-38, p, function() toggleGodMode() end)
end

-- TELEPORT PAGE
do
    local p = pages["Teleport"]
    makeButton("Click TP", 10, 6, p, function() toggleClickTP() end)
    makeButton("Reset Char", 160, 6, p, function() resetCharacter() end)

    -- teleport to specific players: dynamic list (buttons generated here)
    local lbl = Instance.new("TextLabel", p)
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0,10,0,52)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Text = "Teleport to player (tap):"

    local playersContainer = Instance.new("Frame", p)
    playersContainer.Size = UDim2.new(1, -20, 0, 38)
    playersContainer.Position = UDim2.new(0,10,0,72)
    playersContainer.BackgroundTransparency = 1

    local function refreshPlayerList()
        for _,child in pairs(playersContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local x = 0
        for _,pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local btn = Instance.new("TextButton", playersContainer)
                btn.Size = UDim2.new(0, 90, 0, 28)
                btn.Position = UDim2.new(0, x, 0, 0)
                btn.Text = pl.Name
                btn.Font = Enum.Font.SourceSans
                btn.TextScaled = true
                btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.MouseButton1Click:Connect(function()
                    teleportToPlayer(pl)
                end)
                x = x + 95
            end
        end
    end

    refreshPlayerList()
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)
end

-- FUN PAGE
do
    local p = pages["Fun"]
    makeButton("Huge Jump", 10, 6, p, function() toggleHugeJump() end)
    makeButton("Big Step", 160, 6, p, function() toggleBigStep() end)

    makeButton("Super Speed", 10, 52, p, function()
        setSpeed(60)
    end)
    makeButton("Normal Speed", 160, 52, p, function()
        setSpeed(16)
    end)

    -- small fun: spin character
    makeButton("Spin", 10, 98-38, p, function()
        local root = getRoot()
        if root then
            spawn(function()
                for i=1,90 do
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(4), 0)
                    wait(0.02)
                end
            end)
        end
    end)
    makeButton("Emit Particles", 160, 98-38, p, function()
        local root = getRoot()
        if root then
            local p = Instance.new("ParticleEmitter", root)
            p.Rate = 100
            p.Lifetime = NumberRange.new(0.4)
            p.Speed = NumberRange.new(2)
            p.Enabled = true
            delay(2, function() p.Enabled = false wait(1) p:Destroy() end)
        end
    end)
end

-- PLAYER PAGE
do
    local p = pages["Player"]
    makeButton("No-Clip", 10, 6, p, function() toggleNoClip() end)
    makeButton("Anti-AFK", 160, 6, p, function() toggleAntiAFK() end)
    makeButton("Reset Hum", 10, 52, p, function() resetCharacter() end)
    makeButton("Show Indicators", 160, 52, p, function()
        recreateIndicators()
    end)
end

-- MISC PAGE
do
    local p = pages["Misc"]
    makeButton("Close Panel", 10, 6, p, function()
        frame.Visible = false
        if not openBtn then
            openBtn = Instance.new("TextButton", gui)
            openBtn.Size = UDim2.new(0,48,0,48)
            openBtn.Position = UDim2.new(0, 20, 0, 60)
            openBtn.Text = "⚡"
            openBtn.Font = Enum.Font.SourceSansBold
            openBtn.TextScaled = true
            openBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            openBtn.TextColor3 = Color3.new(1,1,1)
            openBtn.MouseButton1Click:Connect(function()
                frame.Visible = true
                openBtn:Destroy()
                openBtn = nil
            end)
        end
    end)
    makeButton("Cleanup ESP", 160, 6, p, function()
        for _,v in pairs(state.espFolder:GetChildren()) do pcall(function() v:Destroy() end) end
        state.esp = false
    end)
    makeButton("Full Restore", 10, 52, p, function()
        -- restore defaults
        setSpeed(16)
        if state.flying then stopFly() end
        if state.noclip then toggleNoClip() end
        if state.clickTP then toggleClickTP() end
        if state.esp then toggleESP() end
        if state.infiniteJump then toggleInfiniteJump() end
        if state.hugeJump then toggleHugeJump() end
        if state.bigStep then toggleBigStep() end
        if state.godMode then toggleGodMode() end
        if state.antiAfk then toggleAntiAFK() end
    end)
end

-- Close button behavior
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    if not openBtn then
        openBtn = Instance.new("TextButton", gui)
        openBtn.Size = UDim2.new(0,48,0,48)
        openBtn.Position = UDim2.new(0, 20, 0, 60)
        openBtn.Text = "⚡"
        openBtn.Font = Enum.Font.SourceSansBold
        openBtn.TextScaled = true
        openBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        openBtn.TextColor3 = Color3.new(1,1,1)
        openBtn.MouseButton1Click:Connect(function()
            frame.Visible = true
            openBtn:Destroy()
            openBtn = nil
        end)
    end
end)

-- Ensure indicators & ESP react to existing players
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function() if state.esp then createESPForPlayer(p) end end)
        if state.esp and p.Character then createESPForPlayer(p) end
    end
end

-- On shutdown / respawn safety: cleanup connections when character resets
LocalPlayer.CharacterRemoving:Connect(function()
    -- nothing critical: indicators will be recreated on CharacterAdded
end)

-- set initial walk speed
setSpeed(state.speed)

-- small initial notification
StarterGui:SetCore("SendNotification", {Title="Admin Panel", Text="Loaded — compact mode", Duration=2})

-- done
