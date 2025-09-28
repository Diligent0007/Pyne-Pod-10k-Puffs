-- Diligent made it you bum
--[[
 ▄▄▄▄▄▄  ▄▄▄ ▄▄▄     ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄    ▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ 
█      ██   █   █   █   █       █       █  █  █ █       █       █
█  ▄    █   █   █   █   █   ▄▄▄▄█    ▄▄▄█   █▄█ █       █    ▄▄▄█
█ █ █   █   █   █   █   █  █  ▄▄█   █▄▄▄█       █     ▄▄█   █▄▄▄ 
█ █▄█   █   █   █▄▄▄█   █  █ █  █    ▄▄▄█  ▄    █    █  █    ▄▄▄█
█       █   █       █   █  █▄▄█ █   █▄▄▄█ █ █   █    █▄▄█   █▄▄▄ 
█▄▄▄▄▄▄██▄▄▄█▄▄▄▄▄▄▄█▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄█  █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█                                                                                                                
]]--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local CurrentCam = Workspace.CurrentCamera

-- =========================
-- GUI Library
-- =========================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("Diligence | Universal | V67 | Diligent.gbp", Color3.fromRGB(44,120,224), Enum.KeyCode.RightShift)

-- =========================
-- Universal Features
-- =========================
local flySettings={fly=false,flyspeed=50}
local c,h,bv,bav,cam,flying
local buttons={W=false,S=false,A=false,D=false,Moving=false}

local function startFly()
    if not Player.Character or not Player.Character.Head or flying then return end
    c=Player.Character
    h=c:FindFirstChild("Humanoid")
    if not h then return end
    h.PlatformStand=true
    cam=workspace:WaitForChild("Camera")
    bv=Instance.new("BodyVelocity")
    bav=Instance.new("BodyAngularVelocity")
    bv.Velocity,bv.MaxForce,bv.P=Vector3.new(0,0,0),Vector3.new(10000,10000,10000),1000
    bav.AngularVelocity,bav.MaxTorque,bav.P=Vector3.new(0,0,0),Vector3.new(10000,10000,10000),1000
    bv.Parent=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
    bav.Parent=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
    flying=true
    h.Died:Connect(function() flying=false end)
end

local function endFly()
    if not Player.Character or not flying then return end
    if h then h.PlatformStand=false end
    if bv then bv:Destroy() end
    if bav then bav:Destroy() end
    flying=false
end

UserInputService.InputBegan:Connect(function(input,GPE)
    if GPE then return end
    for i,_ in pairs(buttons) do
        if i~="Moving" and input.KeyCode==Enum.KeyCode[i] then
            buttons[i]=true
            buttons.Moving=true
        end
    end
end)
UserInputService.InputEnded:Connect(function(input,GPE)
    if GPE then return end
    local a=false
    for i,_ in pairs(buttons) do
        if i~="Moving" then
            if input.KeyCode==Enum.KeyCode[i] then buttons[i]=false end
            if buttons[i] then a=true end
        end
    end
    buttons.Moving=a
end)

local function setVec(vec) return vec*(flySettings.flyspeed/vec.Magnitude) end
RunService.Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local p=c.PrimaryPart.Position
        local cf=cam.CFrame
        local ax,ay,az=cf:ToEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(p) * CFrame.Angles(ax,ay,az))
        if buttons.Moving then
            local t=Vector3.new()
            if buttons.W then t=t+(setVec(cf.LookVector)) end
            if buttons.S then t=t-(setVec(cf.LookVector)) end
            if buttons.A then t=t-(setVec(cf.RightVector)) end
            if buttons.D then t=t+(setVec(cf.RightVector)) end
            c:TranslateBy(t*step)
        end
    end
end)

-- Player Tab
local tab3=win:Tab("Player")
tab3:Label("> Fly")
tab3:Toggle("Fly",false,function(state) if state then startFly() else endFly() end end)
tab3:Slider("Fly Speed",1,500,50,function(v) flySettings.flyspeed=v end)

tab3:Label("> WalkSpeed")
local settings={WalkSpeed=16,JumpPower=50}
local function setWalkSpeed(v)
    settings.WalkSpeed=v
    local h=Player.Character and Player.Character:FindFirstChild("Humanoid")
    if h then h.WalkSpeed=v end
end
tab3:Slider("WalkSpeed",16,500,16,setWalkSpeed)

tab3:Label("> JumpPower")
local function setJumpPower(v)
    settings.JumpPower=v
    local h=Player.Character and Player.Character:FindFirstChild("Humanoid")
    if h then h.JumpPower=v end
end
tab3:Slider("JumpPower",50,500,50,setJumpPower)

local IJ=false
tab3:Toggle("Infinite Jump",false,function(state)
    IJ=state
    Player.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid")
        UserInputService.JumpRequest:Connect(function()
            if IJ then hum:ChangeState("Jumping") end
        end)
    end)
end)

-- Universal ESP Tab
local Visual=win:Tab("Visuals")
Visual:Label("> ESP")
local esp
pcall(function()
    esp=loadstring(game:HttpGet("https://raw.githubusercontent.com/StevenK-293/Loadstrings/main/esp.lua"))()
end)
if esp then
    Visual:Toggle("Enable ESP",false,function(K) esp:Toggle(K) esp.Players=K end)
    Visual:Toggle("Tracers",false,function(K) esp.Tracers=K end)
    Visual:Toggle("Names",false,function(K) esp.Names=K end)
    Visual:Toggle("Boxes",false,function(K) esp.Boxes=K end)
    Visual:Colorpicker("ESP Color",Color3.fromRGB(0,0,255),function(c) esp.Color=c end)
end

-- =========================
-- Game-Specific Features with GUI Toggles
-- =========================
local gameId = game.PlaceId
if gameId == 3233893879 or gameId == 292439477 then
    local isBB = (gameId == 3233893879)
    local gameTab = win:Tab(isBB and "Bad Business" or "Phantom Forces")
    
    -- Settings
    local silentAimEnabled = true
    local hitboxEnabled = true
    local espEnabled = true
    local hitboxSize = 20

    -- GUI Toggles
    gameTab:Toggle("Silent Aim", silentAimEnabled, function(state) silentAimEnabled=state end)
    gameTab:Toggle("Hitboxes", hitboxEnabled, function(state) hitboxEnabled=state end)
    gameTab:Toggle("ESP", espEnabled, function(state) espEnabled=state end)
    gameTab:Slider("Hitbox Size",1,50,hitboxSize,function(v) hitboxSize=v end)

    -- Silent Aim
    local function getClosestEnemy()
        local closestEnemy
        local shortestDistance = math.huge
        local myTeam = Player.Team
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if myTeam then
                    if (isBB and plr.Team.Name ~= myTeam.Name) or (not isBB and plr.Team ~= myTeam) then
                        local dist = (plr.Character.HumanoidRootPart.Position - CurrentCam.CFrame.Position).Magnitude
                        if dist < shortestDistance then
                            closestEnemy = plr
                            shortestDistance = dist
                        end
                    end
                else
                    local dist = (plr.Character.HumanoidRootPart.Position - CurrentCam.CFrame.Position).Magnitude
                    if dist < shortestDistance then
                        closestEnemy = plr
                        shortestDistance = dist
                    end
                end
            end
        end
        return closestEnemy
    end

    -- Hook Gun
    pcall(function()
        local gunPath = isBB and "MainGui.NewLocal.Tools.Tool.Gun" or "GunModule"
        local gunModule = require(Player.PlayerGui:WaitForChild(gunPath))
        local oldFunc = gunModule.ConeOfFire
        gunModule.ConeOfFire = function(...)
            if silentAimEnabled then
                local target = getClosestEnemy()
                if target and target.Character then
                    return target.Character.Head.CFrame * CFrame.new(math.random(0.1,0.25),math.random(0.1,0.25),math.random(0.1,0.25)).p
                end
            end
            return oldFunc(...)
        end
    end)

    -- Hitboxes
    RunService.Stepped:Connect(function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if hitboxEnabled then
                        root.CanCollide = false
                        root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    else
                        root.Size = Vector3.new(1,1,1)
                        root.CanCollide = true
                    end
                end
            end
        end
    end)

    -- ESP
    local esp2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/StevenK-293/Loadstrings/main/esp.lua"))()
    RunService.Heartbeat:Connect(function()
        if espEnabled then
            esp2:Toggle(true)
            esp2.Boxes = true
            esp2.Names = true
            esp2.Tracers = true
            esp2.TeamColor = true
            esp2.Players = true
            esp2.Color = isBB and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
        else
            esp2:Toggle(false)
        end
    end)

    print("[Universal Script] Full features loaded for "..(isBB and "Bad Business" or "Phantom Forces"))
else
    print("[Universal Script] No game-specific module. Only universal features loaded.")
end

print("[Universal Script] Ready! Toggle GUI with Right Shift.")
