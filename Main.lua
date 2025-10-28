-- Clean Admin Panel with Tabs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== STATE =====
local S = {flying=false, flySpeed=70, speed=16, infiniteJump=false, esp=false, noclip=false,
           hugeJump=false, bigStep=false, godMode=false, serverTPLoop=false, superSpeed=false,
           superJump=false, fastAttack=false, invisible=false, flyThroughWalls=false,
           walkOnAir=false, lowGravity=false, maxHealth=true, instantReload=false,
           infiniteAmmo=false, superPunch=false}

-- ===== HELPERS =====
local function getChar() return LocalPlayer.Character end
local function getHumanoid() local c=getChar() if c then return c:FindFirstChildOfClass("Humanoid") end end
local function getRoot() local c=getChar() if c then return c:FindFirstChild("HumanoidRootPart") end end

-- ===== GUI =====
local gui = Instance.new("ScreenGui",game:GetService("CoreGui"))
gui.Name="AdminPanel"

local frame = Instance.new("Frame",gui)
frame.Size=UDim2.new(0,350,0,450)
frame.Position=UDim2.new(0.05,0,0.1,0)
frame.BackgroundColor3=Color3.fromRGB(25,25,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true

-- Title
local title = Instance.new("TextLabel",frame)
title.Size=UDim2.new(1,0,0,40)
title.Position=UDim2.new(0,0,0,0)
title.BackgroundTransparency=1
title.TextColor3=Color3.new(1,1,1)
title.TextScaled=true
title.Font=Enum.Font.SourceSansBold
title.Text="⚡ Admin Panel"

-- Close Button
local closeBtn = Instance.new("TextButton",frame)
closeBtn.Size=UDim2.new(0,40,0,40)
closeBtn.Position=UDim2.new(1,-45,0,5)
closeBtn.Text="X"
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextScaled=true
closeBtn.TextColor3=Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
closeBtn.MouseButton1Click:Connect(function() frame.Visible=false end)

-- Tabs
local tabNames = {"Main","Fun","Teleport"}
local tabs = {}
local contents = {}

for i,name in ipairs(tabNames) do
    local btn = Instance.new("TextButton",frame)
    btn.Size=UDim2.new(0,100,0,30)
    btn.Position=UDim2.new(0,(i-1)*110,0,45)
    btn.Text=name
    btn.Font=Enum.Font.SourceSansBold
    btn.TextScaled=true
    btn.BackgroundColor3=Color3.fromRGB(50,50,50)
    btn.TextColor3=Color3.new(1,1,1)
    tabs[name] = btn

    local content = Instance.new("Frame",frame)
    content.Size=UDim2.new(1,-20,1,-80)
    content.Position=UDim2.new(0,10,0,80)
    content.BackgroundTransparency=1
    content.Visible=(i==1)
    contents[name] = content

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(contents) do v.Visible=false end
        content.Visible=true
    end)
end

-- Button Helper
local function makeBtn(parent,text,y,callback)
    local btn = Instance.new("TextButton",parent)
    btn.Size=UDim2.new(0,320,0,35)
    btn.Position=UDim2.new(0,10,0,y)
    btn.BackgroundColor3=Color3.fromRGB(55,55,55)
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.SourceSansBold
    btn.TextScaled=true
    btn.Text=text
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== MAIN TAB =====
local mainY=0
makeBtn(contents["Main"],"Fly",mainY,function() S.flying=not S.flying end); mainY=mainY+40
makeBtn(contents["Main"],"Infinite Jump",mainY,function() S.infiniteJump=not S.infiniteJump end); mainY=mainY+40
makeBtn(contents["Main"],"+ Speed",mainY,function() S.speed=S.speed+5 end); mainY=mainY+40
makeBtn(contents["Main"],"- Speed",mainY,function() if S.speed>5 then S.speed=S.speed-5 end end); mainY=mainY+40
makeBtn(contents["Main"],"ESP",mainY,function() S.esp=not S.esp end); mainY=mainY+40
makeBtn(contents["Main"],"No-Clip",mainY,function() S.noclip=not S.noclip end); mainY=mainY+40
makeBtn(contents["Main"],"Server TP Loop",mainY,function() S.serverTPLoop=not S.serverTPLoop end)

-- ===== FUN TAB =====
local funList={"Huge Jump","Big Step","GodMode","Super Speed","Super Jump","Fast Attack","Invisible",
    "Fly Through Walls","Walk On Air","Low Gravity","Max Health","Instant Reload","Infinite Ammo","Super Punch"}
local funY=0
for _,f in ipairs(funList) do
    makeBtn(contents["Fun"],f,funY,function() S[f:gsub(" ","")] = not S[f:gsub(" ","")] end)
    funY = funY + 40
end

-- ===== TELEPORT TAB =====
local tpFrame = Instance.new("ScrollingFrame",contents["Teleport"])
tpFrame.Size=UDim2.new(1,-20,1,-20)
tpFrame.Position=UDim2.new(0,10,0,10)
tpFrame.BackgroundColor3=Color3.fromRGB(40,40,40)
tpFrame.CanvasSize = UDim2.new(0,0,0,500)
tpFrame.ScrollBarThickness=6

local function refreshPlayerList()
    tpFrame:ClearAllChildren()
    local y=0
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer then
            local btn=Instance.new("TextButton",tpFrame)
            btn.Size=UDim2.new(0,320,0,30)
            btn.Position=UDim2.new(0,0,0,y)
            btn.BackgroundColor3=Color3.fromRGB(50,50,50)
            btn.TextColor3=Color3.new(1,1,1)
            btn.Text=p.Name
            btn.Font=Enum.Font.SourceSansBold
            btn.TextScaled=true
            btn.MouseButton1Click:Connect(function()
                local root=getRoot()
                if root and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                end
            end)
            y = y + 35
        end
    end
end
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
