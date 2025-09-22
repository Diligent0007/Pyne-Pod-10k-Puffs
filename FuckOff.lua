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

-- fly script
local flySettings = {fly = false, flyspeed = 50}
local c, h, bv, bav, cam, flying
local p = game.Players.LocalPlayer
local buttons = {W = false, S = false, A = false, D = false, Moving = false}

local function startFly()
    if not p.Character or not p.Character.Head or flying then return end
    c = p.Character
    h = c.Humanoid
    h.PlatformStand = true
    cam = workspace:WaitForChild('Camera')
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(10000,10000,10000)
    bv.P = 1000
    bav.AngularVelocity = Vector3.new(0,0,0)
    bav.MaxTorque = Vector3.new(10000,10000,10000)
    bav.P = 1000
    bv.Parent = c.Head
    bav.Parent = c.Head
    flying = true
    h.Died:Connect(function() flying = false end)
end

local function endFly()
    if not p.Character or not flying then return end
    h.PlatformStand = false
    bv:Destroy()
    bav:Destroy()
    flying = false
end

game:GetService("UserInputService").InputBegan:Connect(function(input, GPE)
    if GPE then return end
    for i, _ in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = true
            buttons.Moving = true
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, GPE)
    if GPE then return end
    local a = false
    for i, _ in pairs(buttons) do
        if i ~= "Moving" then
            if input.KeyCode == Enum.KeyCode[i] then
                buttons[i] = false
            end
            if buttons[i] then a = true end
        end
    end
    buttons.Moving = a
end)

local function setVec(vec)
    return vec * (flySettings.flyspeed / vec.Magnitude)
end

game:GetService("RunService").Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local pos = c.PrimaryPart.Position
        local cf = cam.CFrame
        local ax, ay, az = cf:ToEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.new()
            if buttons.W then t = t + setVec(cf.LookVector) end
            if buttons.S then t = t - setVec(cf.LookVector) end
            if buttons.A then t = t - setVec(cf.RightVector) end
            if buttons.D then t = t + setVec(cf.RightVector) end
            c:TranslateBy(t * step)
        end
    end
end)

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CurrentCam = Workspace.CurrentCamera
local require = require

-- Load UI library
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- 🔑 Changeable toggle key (default = Insert/Ins)
local toggleKey = Enum.KeyCode.Insert 

local win = lib:Window("Diligence | Bit Of Everything | V67 | Diligent.gbp ",
    Color3.fromRGB(44, 120, 224), toggleKey)

-- Function to update the toggle key live
local function setToggleKey(newKey)
    toggleKey = newKey
    if win and win.ChangeToggleKey then
        win:ChangeToggleKey(toggleKey)
    end
end

-- ==============================
-- Main tab
-- ==============================
local tab = win:Tab("Main")
tab:Label("> Silent Aim")

local silentAimEnabled = false
tab:Toggle("Silent Aim", false, function(state)
    silentAimEnabled = state
    
    local function getClosestEnemy()
        local closestEnemy
        local shortestDistance = math.huge
        local myTeam = Player.Team
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if myTeam then
                    local enemyTeam = myTeam.Name == "Blue" and "Red" or "Blue"
                    if plr.Team.Name == enemyTeam then
                        local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                        local distance = (rootPart.Position - CurrentCam.CFrame.Position).Magnitude
                        if distance < shortestDistance then
                            closestEnemy = plr
                            shortestDistance = distance
                        end
                    end
                else -- FFA
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                    local distance = (rootPart.Position - CurrentCam.CFrame.Position).Magnitude
                    if distance < shortestDistance then
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
        local gunModule = require(Players.PlayerGui:WaitForChild("MainGui").NewLocal.Tools.Tool.Gun)
        local oldFunc = gunModule.ConeOfFire

        gunModule.ConeOfFire = function(...)
            if silentAimEnabled then
                local closestEnemy = getClosestEnemy()
                if closestEnemy and closestEnemy.Character then
                    return closestEnemy.Character.Head.CFrame *
                        CFrame.new(math.random(0.1, 0.25), math.random(0.1, 0.25), math.random(0.1, 0.25)).p
                end
            else
                return oldFunc(...)
            end
        end
    end
    run()
    Player.CharacterAdded:Connect(run)
end)

-- ==============================
-- Hitbox Tab
-- ==============================
local hitboxEnabled = false
local hitboxTransparency = 0
local originalHitboxSize = Vector3.new(1,1,1)
local hitboxSize = 20

local function hitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local rootPart = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CanCollide = hitboxEnabled
                rootPart.Transparency = hitboxEnabled and hitboxTransparency or 0
                rootPart.Size = hitboxEnabled and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or originalHitboxSize
            end
        end
    end
end

tab:Toggle("Hitbox", false, function(state)
    hitboxEnabled = state
    if state then
        connection = game:GetService("RunService").Stepped:Connect(hitboxes)
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

-- ==============================
-- Visuals Tab (ESP)
-- ==============================
local Visual = win:Tab("Visuals")
Visual:Label("> ESP")
local aj = loadstring(game:HttpGet("https://raw.githubusercontent.com/StevenK-293/Loadstrings/main/esp.lua"))()

Visual:Toggle("Enable Esp (Won't Work For FFA)", false, function(K)
    aj:Toggle(K)
    aj.Players = K
end)
Visual:Toggle("Tracers Esp", false, function(K) aj.Tracers = K end)
Visual:Toggle("Name Esp", false, function(K) aj.Names = K end)
Visual:Toggle("Boxes Esp", false, function(K) aj.Boxes = K end)
Visual:Toggle("TeamColor", false, function(L) aj.TeamColor = L end)
Visual:Toggle("TeamMates", false, function(L) aj.TeamMates = L end)
Visual:Colorpicker("ESP Color", Color3.fromRGB(0,0,255), function(P) aj.Color = P end)

-- ==============================
-- Player Tab (Fly / Speed / Jump / Inf Jump)
-- ==============================
local tab3 = win:Tab("Player")
tab3:Label("> Fly")
tab3:Toggle("Fly", false, function(state)
    if state then startFly() else endFly() end
end)
tab3:Slider("Fly Speed", 1, 500, 50, function(s) flySettings.flyspeed = s end)

local settings = {WalkSpeed = 16, JumpPower = 50}
tab3:Label("> WalkSpeed")
tab3:Slider("Walkspeed", 16, 500, 16, function(value)
    settings.WalkSpeed = value
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.WalkSpeed = value end
end)

tab3:Label("> JumpPower")
tab3:Slider("JumpPower", 50, 500, 50, function(value)
    settings.JumpPower = value
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.JumpPower = value end
end)

local IJ = false
tab3:Toggle("Inf Jump", false, function(state)
    IJ = state
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if IJ then
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass('Humanoid')
            if humanoid then humanoid:ChangeState("Jumping") end
        end
    end)
end)

-- ==============================
-- Settings Tab
-- ==============================
local changeclr = win:Tab("Settings")
local toggle = false

changeclr:Toggle("Rejoin when VoteKick", toggle, function(state)
    toggle = state
    if not toggle then
        local voteKick = Player.PlayerGui:FindFirstChild("MenuUI") and Player.PlayerGui.MenuUI:FindFirstChild("VoteKick")
        if voteKick then voteKick.Title.Text = "" end
    end
end)

changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44,120,224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R*255, t.G*255, t.B*255))
end)

-- Live Toggle Key Settings
changeclr:Label("> Toggle Key")
changeclr:Dropdown("Choose Toggle Key", {"Insert","RightShift","P","M","F4"}, function(choice)
    local keys = {
        ["Insert"] = Enum.KeyCode.Insert,
        ["RightShift"] = Enum.KeyCode.RightShift,
        ["P"] = Enum.KeyCode.P,
        ["M"] = Enum.KeyCode.M,
        ["F4"] = Enum.KeyCode.F4
    }
    if keys[choice] then
        setToggleKey(keys[choice])
        print("✅ GUI toggle key changed to:", choice)
    end
end)

-- ==============================
-- END OF SCRIPT
-- ==============================
