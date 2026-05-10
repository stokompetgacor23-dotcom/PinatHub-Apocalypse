-- =======================================================
-- PINATHUB - AUTO FARM MODULE WITH DEBUG
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Farm = {}
Farm.ModuleName = "FARM"

-- Auto Hunt Variables
Farm.Hunting = false
Farm.HuntConn = nil
Farm.HuntFlyBV = nil
Farm.HuntFlyBG = nil
Farm.HuntingFlyActive = false
Farm.HuntLastSwing = 0

-- Auto Destroy Variables
Farm.AutoDestroyActive = false
Farm.AutoDestroyConn = nil
Farm.LastDestroyTime = 0
Farm.DestroyCooldown = 0.25

-- Auto Hunt Fuel Variables
Farm.FuelHuntActive = false
Farm.FuelHuntConn = nil
Farm.FuelFlyBV = nil
Farm.FuelFlyBG = nil
Farm.FuelFlying = false
Farm.LastPickupTime = 0
Farm.PickupCooldown = 0.5
Farm.BackpackEquipped = false
Farm.FuelHuntRange = 500

-- Noclip state
Farm.NoclipEnabled = false

local function enableNoclip()
    if Farm.NoclipEnabled then 
        print(string.format("[%s][NOCLIP] Noclip already enabled", Farm.ModuleName))
        return 
    end
    
    local ok, err = pcall(function()
        print(string.format("[%s][NOCLIP] Enabling noclip", Farm.ModuleName))
        Farm.NoclipEnabled = true
        
        local function applyNoclip()
            if not Farm.NoclipEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        local noclipLoopConn = RunService.RenderStepped:Connect(applyNoclip)
        print(string.format("[%s][NOCLIP] Noclip loop connected", Farm.ModuleName))
        if Farm.Utils then Farm.Utils:AddConnection(noclipLoopConn) end
    end)
    if not ok then
        warn(string.format("[%s][ERROR] enableNoclip failed: %s", Farm.ModuleName, err))
    end
end

local function disableNoclip()
    local ok, err = pcall(function()
        print(string.format("[%s][NOCLIP] Disabling noclip", Farm.ModuleName))
        Farm.NoclipEnabled = false
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            print(string.format("[%s][NOCLIP] Noclip disabled successfully", Farm.ModuleName))
        end
    end)
    if not ok then
        warn(string.format("[%s][ERROR] disableNoclip failed: %s", Farm.ModuleName, err))
    end
end

function Farm:FindNearestZombie(utils, config)
    local ok, result = pcall(function()
        local char = LocalPlayer.Character
        if not char then 
            print(string.format("[%s][FIND] No character found", Farm.ModuleName))
            return nil 
        end
        
        local hrp = utils:GetPlayerRoot(char)
        if not hrp then 
            print(string.format("[%s][FIND] No HumanoidRootPart found", Farm.ModuleName))
            return nil 
        end
        
        local folders = utils:DiscoverFolders()
        local mobFolder = folders.charactersFolder
        if not mobFolder then 
            print(string.format("[%s][FIND] Characters folder not found", Farm.ModuleName))
            return nil 
        end
        
        local myPos = hrp.Position
        local range = config:GetOptions().HuntRange
        local mobNames = config:GetMobNames()
        print(string.format("[%s][FIND] Searching for mobs within range: %.2f", Farm.ModuleName, range))
        
        local terdekat = nil
        local jarakTerdekat = range + 1
        local mobCount = 0
        
        for _, mob in ipairs(mobFolder:GetChildren()) do
            local isZombie = false
            for _, nama in ipairs(mobNames) do
                if mob.Name == nama then
                    isZombie = true
                    break
                end
            end
            if not isZombie then continue end
            
            mobCount = mobCount + 1
            local mobHrp = utils:GetPlayerRoot(mob)
            local mobHidup = mob:FindFirstChildOfClass("Humanoid")
            
            if mobHrp and mobHidup and mobHidup.Health > 0 then
                local jarak = (mobHrp.Position - myPos).Magnitude
                if jarak < jarakTerdekat then
                    jarakTerdekat = jarak
                    terdekat = mob
                    print(string.format("[%s][FIND] Found mob %s at distance %.2f", Farm.ModuleName, mob.Name, jarak))
                end
            end
        end
        
        print(string.format("[%s][FIND] Scanned %d mobs, nearest distance: %.2f", Farm.ModuleName, mobCount, jarakTerdekat))
        return terdekat
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FindNearestZombie failed: %s", Farm.ModuleName, result))
        return nil
    end
    return result
end

function Farm:AutoEquipWeapon(network, config)
    local ok, result = pcall(function()
        print(string.format("[%s][WEAPON] Attempting to auto-equip weapon", Farm.ModuleName))
        
        local char = LocalPlayer.Character
        if not char then 
            print(string.format("[%s][WEAPON] No character found", Farm.ModuleName))
            return false 
        end
        
        if char:FindFirstChildOfClass("Tool") then 
            print(string.format("[%s][WEAPON] Weapon already equipped", Farm.ModuleName))
            return true 
        end
        
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then 
            print(string.format("[%s][WEAPON] No backpack found", Farm.ModuleName))
            return false 
        end
        
        local priority = {"Katana", "Knife", "Crowbar", "Bat", "Spiked Bat", "Scythe", "Hatchet"}
        
        for _, namaSenjata in ipairs(priority) do
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name, namaSenjata) then
                    tool.Parent = char
                    print(string.format("[%s][WEAPON] Equipped priority weapon: %s", Farm.ModuleName, tool.Name))
                    return true
                end
            end
        end
        
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = char
                print(string.format("[%s][WEAPON] Equipped fallback weapon: %s", Farm.ModuleName, tool.Name))
                return true
            end
        end
        
        print(string.format("[%s][WEAPON] No weapons found to equip", Farm.ModuleName))
        return false
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] AutoEquipWeapon failed: %s", Farm.ModuleName, result))
        return false
    end
    return result
end

function Farm:AttackTarget(target, network, config)
    local ok, err = pcall(function()
        if not target then 
            print(string.format("[%s][ATTACK] No target provided", Farm.ModuleName))
            return 
        end
        
        print(string.format("[%s][ATTACK] Attacking target: %s", Farm.ModuleName, target.Name))
        
        local char = LocalPlayer.Character
        if not char then 
            print(string.format("[%s][ATTACK] No character found", Farm.ModuleName))
            return 
        end
        
        if not char:FindFirstChildOfClass("Tool") then
            self:AutoEquipWeapon(network, config)
        end
        
        local weapon = char:FindFirstChildOfClass("Tool")
        if not weapon then 
            print(string.format("[%s][ATTACK] No weapon available", Farm.ModuleName))
            return 
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local targetHrp = target:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetHrp then 
            print(string.format("[%s][ATTACK] Missing root parts", Farm.ModuleName))
            return 
        end
        
        local range = config:GetOptions().HuntKillRange
        local jarak = (targetHrp.Position - hrp.Position).Magnitude
        if jarak > range then 
            print(string.format("[%s][ATTACK] Target out of range: %.2f > %.2f", Farm.ModuleName, jarak, range))
            return 
        end
        
        local swingSpeed = config:GetOptions().HuntSwingSpeed
        local now = tick()
        if now - self.HuntLastSwing >= swingSpeed then
            print(string.format("[%s][ATTACK] Executing attack with weapon: %s", Farm.ModuleName, weapon.Name))
            
            network:FireSwing(weapon)
            network:FireHitTargets(weapon, {target})
            network:FireRemoteClick(weapon, target)
            
            self.HuntLastSwing = now
            print(string.format("[%s][ATTACK] Attack completed", Farm.ModuleName))
            
            task.defer(function()
                network:FireSwing(weapon)
                network:FireHitTargets(weapon, {target})
            end)
        else
            print(string.format("[%s][ATTACK] Swing on cooldown: %.2f/%.2f", Farm.ModuleName, now - self.HuntLastSwing, swingSpeed))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] AttackTarget failed: %s", Farm.ModuleName, err))
    end
end

function Farm:StartHuntFly()
    local ok, err = pcall(function()
        if self.HuntingFlyActive then 
            print(string.format("[%s][FLY] Hunt fly already active", Farm.ModuleName))
            return 
        end
        
        print(string.format("[%s][FLY] Starting hunt fly mode", Farm.ModuleName))
        
        local char = LocalPlayer.Character
        if not char then 
            print(string.format("[%s][FLY] No character found", Farm.ModuleName))
            return 
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            print(string.format("[%s][FLY] No HumanoidRootPart found", Farm.ModuleName))
            return 
        end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = true 
            hum.AutoRotate = false
            print(string.format("[%s][FLY] Humanoid configured for flying", Farm.ModuleName))
        end
        
        self.HuntFlyBV = Instance.new("BodyVelocity")
        self.HuntFlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        self.HuntFlyBV.Velocity = Vector3.new(0, 0, 0)
        self.HuntFlyBV.Parent = hrp
        
        self.HuntFlyBG = Instance.new("BodyGyro")
        self.HuntFlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        self.HuntFlyBG.P = 9000
        self.HuntFlyBG.CFrame = workspace.CurrentCamera.CFrame
        self.HuntFlyBG.Parent = hrp
        
        self.HuntingFlyActive = true
        print(string.format("[%s][FLY] Hunt fly mode started successfully", Farm.ModuleName))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] StartHuntFly failed: %s", Farm.ModuleName, err))
    end
end

function Farm:StopHuntFly()
    local ok, err = pcall(function()
        print(string.format("[%s][FLY] Stopping hunt fly mode", Farm.ModuleName))
        
        self.HuntingFlyActive = false
        if self.HuntFlyBV then 
            self.HuntFlyBV:Destroy() 
            self.HuntFlyBV = nil 
        end
        if self.HuntFlyBG then 
            self.HuntFlyBG:Destroy() 
            self.HuntFlyBG = nil 
        end
        
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.PlatformStand = false
                hum.AutoRotate = true
                print(string.format("[%s][FLY] Humanoid reset to normal", Farm.ModuleName))
            end
        end
        
        print(string.format("[%s][FLY] Hunt fly mode stopped", Farm.ModuleName))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] StopHuntFly failed: %s", Farm.ModuleName, err))
    end
end

function Farm:FlyToTarget(targetPos, options)
    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPosAtas = Vector3.new(targetPos.X, targetPos.Y + options.HuntFlyHeight, targetPos.Z)
        local arah = (targetPosAtas - hrp.Position).Unit
        local jarak = (targetPosAtas - hrp.Position).Magnitude
        
        if self.HuntFlyBV then
            local speed = math.min(options.HuntFlySpeed, jarak * 2)
            self.HuntFlyBV.Velocity = arah * speed
        end
        
        if self.HuntFlyBG then
            local lookAt = CFrame.lookAt(hrp.Position, targetPosAtas)
            self.HuntFlyBG.CFrame = lookAt
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FlyToTarget failed: %s", Farm.ModuleName, err))
    end
end

function Farm:StartAutoHunt(utils, network, config, notifications)
    local ok, err = pcall(function()
        if self.Hunting then 
            print(string.format("[%s][HUNT] Auto hunt already active", Farm.ModuleName))
            return 
        end
        
        print(string.format("[%s][HUNT] Starting auto hunt", Farm.ModuleName))
        self.Hunting = true
        enableNoclip()
        self:StartHuntFly()
        
        local options = config:GetOptions()
        print(string.format("[%s][HUNT] Hunt options - Range: %.2f, KillRange: %.2f, Speed: %.2f, Height: %.2f", 
            Farm.ModuleName, options.HuntRange, options.HuntKillRange, options.HuntFlySpeed, options.HuntFlyHeight))
        
        self.HuntConn = RunService.RenderStepped:Connect(function()
            if not self.Hunting then return end
            
            local ok2, err2 = pcall(function()
                local target = self:FindNearestZombie(utils, config)
                
                if target then
                    local targetHrp = utils:GetPlayerRoot(target)
                    if targetHrp then
                        local char = LocalPlayer.Character
                        if char then
                            local hrp = utils:GetPlayerRoot(char)
                            if hrp then
                                local jarak = (targetHrp.Position - hrp.Position).Magnitude
                                
                                if jarak <= options.HuntKillRange then
                                    self:AttackTarget(target, network, config)
                                    self:AttackTarget(target, network, config)
                                end
                                
                                if not self.HuntingFlyActive then
                                    self:StartHuntFly()
                                end
                                
                                self:FlyToTarget(targetHrp.Position, options)
                            end
                        end
                    end
                else
                    if self.HuntFlyBV then
                        self.HuntFlyBV.Velocity = Vector3.new(0, 0, 0)
                        print(string.format("[%s][HUNT] No targets, hovering", Farm.ModuleName))
                    end
                end
            end)
            if not ok2 then
                warn(string.format("[%s][HUNT_LOOP_ERROR] %s", Farm.ModuleName, err2))
            end
        end)
        
        if self.Utils then self.Utils:AddConnection(self.HuntConn) end
        if notifications then 
            notifications:Show("Auto Hunt", "Enabled - Flying to zombies! (Noclip ON)", 2)
            print(string.format("[%s][HUNT] Notification shown: Auto Hunt enabled", Farm.ModuleName))
        end
        
        print(string.format("[%s][HUNT] Auto hunt started successfully", Farm.ModuleName))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] StartAutoHunt failed: %s", Farm.ModuleName, err))
    end
end

function Farm:StopAutoHunt(notifications)
    local ok, err = pcall(function()
        print(string.format("[%s][HUNT] Stopping auto hunt", Farm.ModuleName))
        
        self.Hunting = false
        if self.HuntConn then
            self.HuntConn:Disconnect()
            self.HuntConn = nil
            print(string.format("[%s][HUNT] Hunt connection disconnected", Farm.ModuleName))
        end
        self:StopHuntFly()
        disableNoclip()
        if notifications then 
            notifications:Show("Auto Hunt", "Disabled", 2)
            print(string.format("[%s][HUNT] Notification shown: Auto Hunt disabled", Farm.ModuleName))
        end
        
        print(string.format("[%s][HUNT] Auto hunt stopped successfully", Farm.ModuleName))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] StopAutoHunt failed: %s", Farm.ModuleName, err))
    end
end

function Farm:Init(deps)
    local ok, err = pcall(function()
        print(string.format("[%s][INIT] Initializing farm module", Farm.ModuleName))
        
        self.Config = deps.Config
        self.Network = deps.Network
        self.Utils = deps.Utils
        self.Notifications = deps.Notifications
        
        if not self.Config then warn(string.format("[%s] Config dependency is nil", Farm.ModuleName)) end
        if not self.Network then warn(string.format("[%s] Network dependency is nil", Farm.ModuleName)) end
        if not self.Utils then warn(string.format("[%s] Utils dependency is nil", Farm.ModuleName)) end
        if not self.Notifications then warn(string.format("[%s] Notifications dependency is nil", Farm.ModuleName)) end
        
        print(string.format("[%s][INIT] Farm module initialized successfully", Farm.ModuleName))
    end)
    if not ok then
        warn(string.format("[%s][ERROR] Init() failed: %s", Farm.ModuleName, err))
    end
    return self
end

print(string.format("[%s][LOAD] Farm module loaded", "FARM"))

return Farm
