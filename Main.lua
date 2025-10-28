-- Ultimate Admin Panel (PC + Mobile) | >20 funkcí
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local OWNER = "HRAVYGAMER_STUDIO" -- change to your name
if OWNER ~= "" and LocalPlayer.Name ~= OWNER then return end

-- ===== STATE =====
local S = {
    flying=false, flySpeed=70, flyGyro=nil, flyVel=nil, flyConn=nil,
    infiniteJump=false, jumpConn=nil,
    speed=16,
    esp=false, espFolder=nil,
    noclip=false, noclipConn=nil,
    hugeJump=false, bigStep=false,
    godMode=false, godConn=nil,
    antiAfk=false, antiAfkConn=nil,
    serverTPLoop=false, serverTPConn=nil,
    clickTP=false,
    uiOpen=true, serverTPDelay=1.5,
    superSpeed=false, superJump=false, fastAttack=false,
    invisible=false, flyThroughWalls=false, walkOnAir=false,
    lowGravity=false, maxHealth=true, instantReload=false,
    infiniteAmmo=false, superPunch=false, teleportLock=false
}

-- ===== HELPERS =====
local function getChar() return LocalPlayer.Character end
local function getHumanoid() local c=getChar(); if c then return c:FindFirstChildOfClass("Humanoid") end end
local function getRoot() local c=getChar(); if c then return c:FindFirstChild("HumanoidRootPart") end end

-- ===== ESP =====
S.espFolder = Instance.new("Folder")
S.espFolder.Name = "AdminESPFolder"
S.espFolder.Parent = game:GetService("CoreGui")
local function createESP(player)
    if S.espFolder:FindFirstChild(player.Name) then return end
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.Parent = S.espFolder
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)
    highlight.OutlineColor = Color3.fromRGB(255,0,0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = S.esp
end
Players.PlayerAdded:Connect(function(p) if S.esp then createESP(p) end end)

-- ===== FLY =====
local function startFly()
    local char=getChar(); local root=getRoot(); if not char or not root then return end
    local hum=getHumanoid(); if hum then hum.PlatformStand=true end
    S.flying=true
    S.flyGyro=Instance.new("BodyGyro")
    S.flyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
    S.flyGyro.P=9e4
    S.flyGyro.CFrame=root.CFrame
    S.flyGyro.Parent=root
    S.flyVel=Instance.new("BodyVelocity")
    S.flyVel.MaxForce=Vector3.new(9e9,9e9,9e9)
    S.flyVel.Velocity=Vector3.zero
    S.flyVel.Parent=root
    S.flyConn=RunService.Heartbeat:Connect(function()
        if not S.flying then if S.flyConn then S.flyConn:Disconnect() S.flyConn=nil end return end
        local cam=workspace.CurrentCamera
        local move=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move+=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move-=cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move-=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move+=cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move-=Vector3.new(0,1,0) end
        S.flyVel.Velocity=(move.Magnitude>0) and (move.Unit*S.flySpeed) or Vector3.zero
        S.flyGyro.CFrame=cam.CFrame
    end)
end
local function stopFly()
    S.flying=false
    if S.flyConn then S.flyConn:Disconnect() S.flyConn=nil end
    if S.flyGyro then pcall(function() S.flyGyro:Destroy() end) end
    if S.flyVel then pcall(function() S.flyVel:Destroy() end) end
    local hum=getHumanoid()
    if hum then hum.PlatformStand=false end
end

-- ===== INFINITE JUMP =====
local function toggleInfiniteJump()
    S.infiniteJump = not S.infiniteJump
    if S.infiniteJump then
        if not S.jumpConn then
            S.jumpConn = UIS.JumpRequest:Connect(function()
                local hum = getHumanoid()
                if hum and S.infiniteJump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
end

-- ===== SPEED =====
local function setSpeed(amount)
    local hum=getHumanoid()
    if hum then hum.WalkSpeed=amount end
end

-- ===== TELEPORT WITH VIBRATION =====
local function teleportToPlayerWithVibration(target)
    local root=getRoot()
    if not root or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0,3,0)
    local steps = 10
    local magnitude = 1
    for i=1,steps do
        local offset = Vector3.new(
            math.random(-magnitude,magnitude)/2,
            math.random(-magnitude,magnitude)/2,
            math.random(-magnitude,magnitude)/2
        )
        root.CFrame=CFrame.new(targetPos + offset)
        RunService.RenderStepped:Wait()
    end
    root.CFrame=CFrame.new(targetPos)
end

-- ===== SERVER TP LOOP =====
local function serverTPLoopStart()
    if S.serverTPLoop then return end
    S.serverTPLoop=true
    S.serverTPConn=coroutine.create(function()
        while S.serverTPLoop do
            local list={}
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(list,p)
                end
            end
            if #list>0 then
                local target=list[math.random(1,#list)]
                teleportToPlayerWithVibration(target)
            end
            wait(S.serverTPDelay)
        end
    end)
    coroutine.resume(S.serverTPConn)
end
local function serverTPLoopStop()
    S.serverTPLoop=false
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name="AdminPanel"
gui.ResetOnSpawn=false
gui.Parent=game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size=UDim2.new(0,300,0,700)
frame.Position=UDim2.new(0,50,0,50)
frame.BackgroundColor3=Color3.fromRGB(30,30,30)
frame.Active=true
frame.Draggable=true
frame.Parent=gui

-- TITLE
local title = Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.Position=UDim2.new(0,0,0,0)
title.BackgroundTransparency=1
title.TextColor3=Color3.new(1,1,1)
title.TextScaled=true
title.Font=Enum.Font.SourceSansBold
title.Text="⚡ Ultimate Admin Panel"
title.Parent=frame

-- CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,40,0,40)
closeBtn.Position=UDim2.new(1,-45,0,5)
closeBtn.Text="X"
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextScaled=true
closeBtn.TextColor3=Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
closeBtn.Parent=frame
closeBtn.MouseButton1Click:Connect(function() frame.Visible=false end)

-- ===== BUTTON HELPER =====
local function makeBtn(text,posY,callback)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,240,0,35)
    btn.Position=UDim2.new(0,30,0,posY)
    btn.BackgroundColor3=Color3.fromRGB(55,55,55)
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.SourceSansBold
    btn.TextScaled=true
    btn.Text=text
    btn.Parent=frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== MAIN TAB BUTTONS =====
local y=60
makeBtn("Fly",y,function() if S.flying then stopFly() else startFly() end end); y=y+40
makeBtn("Infinite Jump",y,function() toggleInfiniteJump() end); y=y+40
makeBtn("+ Speed",y,function() S.speed=S.speed+5; setSpeed(S.speed) end); y=y+40
makeBtn("- Speed",y,function() if S.speed>5 then S.speed=S.speed-5; setSpeed(S.speed) end end); y=y+40
makeBtn("ESP",y,function() S.esp=not S.esp; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end end); y=y+40
makeBtn("No-Clip",y,function()
    S.noclip=not S.noclip
    if S.noclip then
        if not S.noclipConn then
            S.noclipConn=RunService.Stepped:Connect(function()
                local char=getChar()
                if char then for _,part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
            end)
        end
    else
        if S.noclipConn then S.noclipConn:Disconnect() S.noclipConn=nil end
    end
end); y=y+40

-- ===== FUN TAB =====
local funY=400
makeBtn("Huge Jump",funY,function() S.hugeJump=not S.hugeJump end); funY=funY+40
makeBtn("Big Step",funY,function() S.bigStep=not S.bigStep end); funY=funY+40
makeBtn("GodMode",funY,function() S.godMode=not S.godMode end); funY=funY+40
makeBtn("Super Speed",funY,function() S.superSpeed=not S.superSpeed end); funY=funY+40
makeBtn("Super Jump",funY,function() S.superJump=not S.superJump end); funY=funY+40
makeBtn("Fast Attack",funY,function() S.fastAttack=not S.fastAttack end); funY=funY+40
makeBtn("Invisible",funY,function() S.invisible=not S.invisible end); funY=funY+40
makeBtn("Fly Through Walls",funY,function() S.flyThroughWalls=not S.flyThroughWalls end); funY=funY+40
makeBtn("Walk On Air",funY,function() S.walkOnAir=not S.walkOnAir end); funY=funY+40
makeBtn("Low Gravity",funY,function() S.lowGravity=not S.lowGravity end); funY=funY+40
makeBtn("Max Health",funY,function() S.maxHealth=not S.maxHealth end); funY=funY+40
makeBtn("Instant Reload",funY,function() S.instantReload=not S.instantReload end); funY=funY+40
makeBtn("Infinite Ammo",funY,function() S.infiniteAmmo=not S.infiniteAmmo end); funY=funY+40
makeBtn("Super Punch",funY,function() S.superPunch=not S.superPunch end); funY=funY+40

-- ===== TELEPORT TAB =====
local tpFrame=Instance.new("Frame")
tpFrame.Size=UDim2.new(0,280,0,200)
tpFrame.Position=UDim2.new(0,10,0,160)
tpFrame.BackgroundColor3=Color3.fromRGB(40,40,40)
tpFrame.Parent=frame

local function refreshPlayerList()
    for _,v in pairs(tpFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local yPos=5
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(0,260,0,25)
            btn.Position=UDim2.new(0,10,0,yPos)
            btn.BackgroundColor3=Color3.fromRGB(50,50,50)
            btn.TextColor3=Color3.new(1,1,1)
            btn.Text=p.Name
            btn.Font=Enum.Font.SourceSansBold
            btn.TextScaled=true
            btn.Parent=tpFrame
            btn.MouseButton1Click:Connect(function() teleportToPlayerWithVibration(p) end)
            yPos=yPos+30
        end
    end
end
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- Server TP Loop button
makeBtn("Server TP Loop",360,function()
    S.serverTPLoop=not S.serverTPLoop
    if S.serverTPLoop then serverTPLoopStart() else serverTPLoopStop() end
end)
