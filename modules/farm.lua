-- =======================================================
-- PINATHUB - AUTO FARM MODULE
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Farm = {}

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
    if Farm.NoclipEnabled then return end
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
    if Farm.Utils then Farm.Utils:AddConnection(noclipLoopConn) end
end

local function disableNoclip()
    Farm.NoclipEnabled = false
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Farm:FindNearestZombie(utils, config)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = utils:GetPlayerRoot(char)
    if not hrp then return nil end
    
    local folders = utils:DiscoverFolders()
    local mobFolder = folders.charactersFolder
    if not mobFolder then return nil end
    
    local myPos = hrp.Position
    local range = config:GetOptions().HuntRange
    local mobNames = config:GetMobNames()
    local terdekat = nil
    local jarakTerdekat = range + 1
    
    for _, mob in ipairs(mobFolder:GetChildren()) do
        local isZombie = false
        for _, nama in ipairs(mobNames) do
            if mob.Name == nama then
                isZombie = true
                break
            end
        end
        if not isZombie then continue end
        
        local mobHrp = utils:GetPlayerRoot(mob)
        local mobHidup = mob:FindFirstChildOfClass("Humanoid")
        
        if mobHrp and mobHidup and mobHidup.Health > 0 then
            local jarak = (mobHrp.Position - myPos).Magnitude
            if jarak < jarakTerdekat then
                jarakTerdekat = jarak
                terdekat = mob
            end
        end
    end
    
    return terdekat
end

function Farm:AutoEquipWeapon(network, config)
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChildOfClass("Tool") then return true end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local priority = {"Katana", "Knife", "Crowbar", "Bat", "Spiked Bat", "Scythe", "Hatchet"}
    
    for _, namaSenjata in ipairs(priority) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, namaSenjata) then
                pcall(function() tool.Parent = char end)
                return true
            end
        end
    end
    
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool.Parent = char end)
            return true
        end
    end
    
    return false
end

function Farm:AttackTarget(target, network, config)
    if not target then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        self:AutoEquipWeapon(network, config)
    end
    
    local weapon = char:FindFirstChildOfClass("Tool")
    if not weapon then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    
    local range = config:GetOptions().HuntKillRange
    local jarak = (targetHrp.Position - hrp.Position).Magnitude
    if jarak > range then return end
    
    local swingSpeed = config:GetOptions().HuntSwingSpeed
    local now = tick()
    if now - self.HuntLastSwing >= swingSpeed then
        network:FireSwing(weapon)
        network:FireHitTargets(weapon, {target})
        network:FireRemoteClick(weapon, target)
        
        self.HuntLastSwing = now
        
        task.defer(function()
            network:FireSwing(weapon)
            network:FireHitTargets(weapon, {target})
        end)
    end
end

function Farm:StartHuntFly()
    if self.HuntingFlyActive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = true 
        hum.AutoRotate = false
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
end

function Farm:StopHuntFly()
    self.HuntingFlyActive = false
    if self.HuntFlyBV then self.HuntFlyBV:Destroy() self.HuntFlyBV = nil end
    if self.HuntFlyBG then self.HuntFlyBG:Destroy() self.HuntFlyBG = nil end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
end

function Farm:FlyToTarget(targetPos, options)
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
end

function Farm:StartAutoHunt(utils, network, config, notifications)
    if self.Hunting then return end
    self.Hunting = true
    enableNoclip()
    self:StartHuntFly()
    
    local options = config:GetOptions()
    
    self.HuntConn = RunService.RenderStepped:Connect(function()
        if not self.Hunting then return end
        
        pcall(function()
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
                end
            end
        end)
    end)
    
    if self.Utils then self.Utils:AddConnection(self.HuntConn) end
    if notifications then notifications:Show("Auto Hunt", "Enabled - Flying to zombies! (Noclip ON)", 2) end
end

function Farm:StopAutoHunt(notifications)
    self.Hunting = false
    if self.HuntConn then
        self.HuntConn:Disconnect()
        self.HuntConn = nil
    end
    self:StopHuntFly()
    disableNoclip()
    if notifications then notifications:Show("Auto Hunt", "Disabled", 2) end
end

function Farm:Init(deps)
    self.Config = deps.Config
    self.Network = deps.Network
    self.Utils = deps.Utils
    self.Notifications = deps.Notifications
    return self
end

return Farm
