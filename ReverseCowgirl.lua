-- Diligent made it you fucking bum
--[[ 
 ▄▄▄▄▄▄  ▄▄▄ ▄▄▄     ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄    ▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ 
█      ██   █   █   █   █       █       █  █  █ █       █       █
█  ▄    █   █   █   █   █   ▄▄▄▄█    ▄▄▄█   █▄█ █       █    ▄▄▄█
█ █ █   █   █   █   █   █  █  ▄▄█   █▄▄▄█       █     ▄▄█   █▄▄▄ 
█ █▄█   █   █   █▄▄▄█   █  █ █  █    ▄▄▄█  ▄    █    █  █    ▄▄▄█
█       █   █       █   █  █▄▄█ █   █▄▄▄█ █ █   █    █▄▄█   █▄▄▄ 
█▄▄▄▄▄▄██▄▄▄█▄▄▄▄▄▄▄█▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄█  █▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█                                                                                                                
]]--

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local CurrentCam = Workspace.CurrentCamera

--// UI Lib
local require = require
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("Diligence | Universal | V67 | Diligent.gbp", Color3.fromRGB(44,120,224), Enum.KeyCode.RightShift)

-- ============================================================
-- Fly Script
-- ============================================================
local flySettings={fly=false,flyspeed=50}
local c local h local bv local bav local cam local flying
local buttons={W=false,S=false,A=false,D=false,Moving=false}

local startFly=function()
    if not Player.Character or not Player.Character.Head or flying then return end
    c=Player.Character
    h=c.Humanoid
    h.PlatformStand=true
    cam=workspace:WaitForChild('Camera')
    bv=Instance.new("BodyVelocity")
    bav=Instance.new("BodyAngularVelocity")
    bv.Velocity,bv.MaxForce,bv.P=Vector3.new(0,0,0),Vector3.new(10000,10000,10000),1000
    bav.AngularVelocity,bav.MaxTorque,bav.P=Vector3.new(0,0,0),Vector3.new(10000,10000,10000),1000
    bv.Parent=c.Head
    bav.Parent=c.Head
    flying=true
    h.Died:connect(function()flying=false end)
end

local endFly=function()
    if not Player.Character or not flying then return end
    h.PlatformStand=false
    bv:Destroy()
    bav:Destroy()
    flying=false
end

UserInputService.InputBegan:connect(function(input,GPE)
    if GPE then return end
    for i,_ in pairs(buttons)do
        if i~="Moving" and input.KeyCode==Enum.KeyCode[i]then
            buttons[i]=true
            buttons.Moving=true
        end
    end
end)

UserInputService.InputEnded:connect(function(input,GPE)
    if GPE then return end
    local a=false
    for i,_ in pairs(buttons)do
        if i~="Moving"then
            if input.KeyCode==Enum.KeyCode[i]then buttons[i]=false end
            if buttons[i]then a=true end
        end
    end
    buttons.Moving=a
end)

local setVec=function(vec)return vec*(flySettings.flyspeed/vec.Magnitude)end
RunService.Heartbeat:connect(function(step)
    if flying and c and c.PrimaryPart then
        local p=c.PrimaryPart.Position
        local cf=cam.CFrame
        local ax,ay,az=cf:toEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(p.x,p.y,p.z)*CFrame.Angles(ax,ay,az))
        if buttons.Moving then
            local t=Vector3.new()
            if buttons.W then t=t+(setVec(cf.lookVector))end
            if buttons.S then t=t-(setVec(cf.lookVector))end
            if buttons.A then t=t-(setVec(cf.rightVector))end
            if buttons.D then t=t+(setVec(cf.rightVector))end
            c:TranslateBy(t*step)
        end
    end
end)

-- ============================================================
-- Universal Features Tabs
-- ============================================================
local tab = win:Tab("Main")

-- Silent Aim (wrapped in pcall for universality)
tab:Label("> Silent Aim")
local silentAimEnabled = false
tab:Toggle("Silent Aim", false, function(state)
    silentAimEnabled = state
    pcall(function()
        local function getClosestEnemy()
            local closestEnemy
            local shortestDistance = math.huge
            local myTeam = Player.Team
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = plr.Character.HumanoidRootPart
                    local distance = (rootPart.Position - CurrentCam.CFrame.Position).Magnitude
                    if distance < shortestDistance then
                        if not myTeam or (myTeam and plr.Team ~= myTeam) then
                            closestEnemy = plr
                            shortestDistance = distance
                        end
                    end
                end
            end
            return closestEnemy
        end

        local function run()
            task.wait()
            local gunModule = require(Player:WaitForChild("PlayerGui"):WaitForChild("MainGui").NewLocal.Tools.Tool.Gun)
            local oldFunc = gunModule.ConeOfFire
            gunModule.ConeOfFire = function(...)
                if silentAimEnabled then
                    local closestEnemy = getClosestEnemy()
                    if closestEnemy and closestEnemy.Character then
                        return closestEnemy.Character.Head.Position
                    end
                end
                return oldFunc(...)
            end
        end
        run()
        Player.CharacterAdded:Connect(run)
    end)
end)

-- Hitbox
tab:Label("> Hitbox")
local hitboxEnabled = false
local hitboxTransparency = 0
local originalHitboxSize = Vector3.new(1,1,1)
local hitboxSize = 20
local connection

local function hitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CanCollide = hitboxEnabled
                root.Transparency = hitboxEnabled and hitboxTransparency or 0
                root.Size = hitboxEnabled and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or originalHitboxSize
            end
        end
    end
end

tab:Toggle("Hitbox", false, function(state)
    hitboxEnabled = state
    if state then
        connection = RunService.Stepped:Connect(hitboxes)
    else
        if connection then connection:Disconnect() end
        hitboxes()
    end
end)

tab:Slider("Hitbox Size", 1, 50, hitboxSize, function(value)
    hitboxSize = value
    hitboxes()
end)

tab:Slider("Hitbox Transparency", 0, 1, hitboxTransparency, function(value)
    hitboxTransparency = value
    hitboxes()
end)

-- ESP Tab
local Visual = win:Tab("Visuals")
Visual:Label("> ESP")
local aj
pcall(function()
    aj = loadstring(game:HttpGet("https://raw.githubusercontent.com/StevenK-293/Loadstrings/main/esp.lua"))()
end)

if aj then
    Visual:Toggle("Enable ESP", false, function(K) aj:Toggle(K) aj.Players = K end)
    Visual:Toggle("Tracers", false, function(K) aj.Tracers = K end)
    Visual:Toggle("Names", false, function(K) aj.Names = K end)
    Visual:Toggle("Boxes", false, function(K) aj.Boxes = K end)
    Visual:Toggle("TeamColor", false, function(K) aj.TeamColor = K end)
    Visual:Toggle("TeamMates", false, function(K) aj.TeamMates = K end)
    Visual:Colorpicker("ESP Color", Color3.fromRGB(0,0,255), function(P) aj.Color = P end)
end

-- Player Tab
local tab3 = win:Tab("Player")
tab3:Label("> Fly")
tab3:Toggle("Fly", false, function(state) if state then startFly() else endFly() end end)
tab3:Slider("Fly Speed", 1, 500, 1, function(s) flySettings.flyspeed = s end)

tab3:Label("> WalkSpeed")
local settings = {WalkSpeed = 16, JumpPower = 50}
local function setWalkSpeed(value)
    settings.WalkSpeed = value
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.WalkSpeed = settings.WalkSpeed end
end
tab3:Slider("Walkspeed", 16, 500, 16, function(v) setWalkSpeed(v) end)

tab3:Label("> JumpPower")
local function setJumpPower(value)
    settings.JumpPower = value
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.JumpPower = settings.JumpPower end
end
tab3:Slider("JumpPower", 50, 500, 50, function(v) setJumpPower(v) end)

local IJ=false
tab3:Toggle("Inf Jump", false, function(state)
    IJ=state
    UserInputService.JumpRequest:Connect(function()
        if IJ and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

-- Settings Tab
local changeclr = win:Tab("Settings")
local toggle=false
local function runToggleableScript()
    if toggle then
        local success,err = pcall(function()
            local voteKick = Player.PlayerGui.MenuUI.VoteKick
            if voteKick and voteKick.Title.Text:find(Player.Name) then
                TeleportService:Teleport(game.PlaceId)
            end
        end)
        if not success then warn("[Universal Script] VoteKick check skipped:",err) end
    end
end
RunService.Heartbeat:Connect(runToggleableScript)
changeclr:Toggle("Rejoin when VoteKick", toggle, function(state) toggle=state end)
changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44,120,224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R*255,t.G*255,t.B*255))
end)

print("[Universal Script] Loaded successfully!")
