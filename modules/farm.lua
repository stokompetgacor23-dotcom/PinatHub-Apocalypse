-- =======================================================
-- PINATHUB - AUTO FARM MODULE (FULLY FIXED)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Farm = {}

-- Module references
Farm.Config = nil
Farm.Network = nil
Farm.Utils = nil
Farm.Notifications = nil

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

-- AdjustBackpack remote
local AdjustBackpack = nil

local function findAdjustBackpack()
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local Tools = Remotes:FindFirstChild("Tools")
        if Tools then
            AdjustBackpack = Tools:FindFirstChild("AdjustBackpack")
        end
    end
    if not AdjustBackpack then
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name == "AdjustBackpack" then
                AdjustBackpack = remote
                break
            end
        end
    end
    return AdjustBackpack
end

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

-- ==================== AUTO HUNT ZOMBIE ====================
function Farm:FindNearestZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local folders = self.Utils:DiscoverFolders()
    local mobFolder = folders.charactersFolder
    if not mobFolder then return nil end
    
    local myPos = hrp.Position
    local range = self.Config:GetOptions().HuntRange
    local mobNames = self.Config:GetMobNames()
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
        
        local mobHrp = self.Utils:GetPlayerRoot(mob)
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

function Farm:AutoEquipWeapon()
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

function Farm:AttackTarget(target)
    if not target then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        self:AutoEquipWeapon()
    end
    
    local weapon = char:FindFirstChildOfClass("Tool")
    if not weapon then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    
    local options = self.Config:GetOptions()
    local jarak = (targetHrp.Position - hrp.Position).Magnitude
    if jarak > options.HuntKillRange then return end
    
    local swingSpeed = options.HuntSwingSpeed
    local now = tick()
    if now - self.HuntLastSwing >= swingSpeed then
        local swing = weapon:FindFirstChild("Swing")
        local hit = weapon:FindFirstChild("HitTargets")
        local click = weapon:FindFirstChild("RemoteClick")
        
        if swing and hit then
            pcall(function() swing:FireServer() end)
            pcall(function() hit:FireServer({target}) end)
        elseif click then
            pcall(function() click:FireServer(target) end)
        else
            pcall(function() weapon:Activate() end)
        end
        
        self.HuntLastSwing = now
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

function Farm:FlyToTarget(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local options = self.Config:GetOptions()
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

function Farm:StartAutoHunt()
    if self.Hunting then return end
    self.Hunting = true
    enableNoclip()
    self:StartHuntFly()
    
    local options = self.Config:GetOptions()
    
    self.HuntConn = RunService.RenderStepped:Connect(function()
        if not self.Hunting then return end
        
        pcall(function()
            local target = self:FindNearestZombie()
            
            if target then
                local targetHrp = target:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local char = LocalPlayer.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local jarak = (targetHrp.Position - hrp.Position).Magnitude
                            
                            if jarak <= options.HuntKillRange then
                                self:AttackTarget(target)
                            end
                            
                            if not self.HuntingFlyActive then
                                self:StartHuntFly()
                            end
                            
                            self:FlyToTarget(targetHrp.Position)
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
    if self.Notifications then self.Notifications:Show("Auto Hunt", "Enabled - Flying to zombies! (Noclip ON)", 2) end
end

function Farm:StopAutoHunt()
    self.Hunting = false
    if self.HuntConn then
        self.HuntConn:Disconnect()
        self.HuntConn = nil
    end
    self:StopHuntFly()
    disableNoclip()
    if self.Notifications then self.Notifications:Show("Auto Hunt", "Disabled", 2) end
end

-- ==================== AUTO DESTROY STRUCTURE ====================
function Farm:FindDestroyableStructures()
    local char = LocalPlayer.Character
    if not char then return {} end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local folders = self.Utils:DiscoverFolders()
    local structuresFolder = folders.structuresFolder
    if not structuresFolder then return {} end
    
    local myPos = hrp.Position
    local targets = {}
    local destroyableNames = {"Barrel", "Scrap Pile"}
    
    for _, child in ipairs(structuresFolder:GetChildren()) do
        local isTarget = false
        for _, name in ipairs(destroyableNames) do
            if child.Name == name then
                isTarget = true
                break
            end
        end
        
        if isTarget and child:IsA("Model") then
            local mainPart = child:FindFirstChild("HumanoidRootPart") 
                or child:FindFirstChild("PrimaryPart")
                or child:FindFirstChildWhichIsA("BasePart")
            
            if mainPart and mainPart.Parent then
                local dist = (mainPart.Position - myPos).Magnitude
                if dist <= 15 then
                    table.insert(targets, {
                        structure = child,
                        part = mainPart,
                        distance = dist
                    })
                end
            end
        end
    end
    
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    return targets
end

function Farm:GetDestroyTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return currentTool end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool.Parent = char end)
                task.wait(0.05)
                return tool
            end
        end
    end
    return nil
end

function Farm:DestroyStructure(structure)
    local tool = self:GetDestroyTool()
    if not tool then return false end
    
    local swing = tool:FindFirstChild("Swing")
    local hitTargets = tool:FindFirstChild("HitTargets")
    local remoteClick = tool:FindFirstChild("RemoteClick")
    
    if swing and hitTargets then
        pcall(function() 
            swing:FireServer() 
            hitTargets:FireServer({structure})
        end)
        return true
    elseif remoteClick then
        pcall(function() remoteClick:FireServer(structure) end)
        return true
    end
    return false
end

function Farm:StartAutoDestroy()
    if self.AutoDestroyActive then return end
    self.AutoDestroyActive = true
    
    self.AutoDestroyConn = RunService.RenderStepped:Connect(function()
        if not self.AutoDestroyActive then return end
        
        pcall(function()
            local targets = self:FindDestroyableStructures()
            if #targets > 0 then
                local now = tick()
                if now - self.LastDestroyTime >= self.DestroyCooldown then
                    if self:DestroyStructure(targets[1].structure) then
                        self.LastDestroyTime = now
                    end
                end
            end
        end)
    end)
    
    if self.Notifications then self.Notifications:Show("Auto Destroy", "Enabled - Attacking Barrel & Scrap Pile", 2) end
end

function Farm:StopAutoDestroy()
    self.AutoDestroyActive = false
    if self.AutoDestroyConn then
        self.AutoDestroyConn:Disconnect()
        self.AutoDestroyConn = nil
    end
    self.LastDestroyTime = 0
    if self.Notifications then self.Notifications:Show("Auto Destroy", "Disabled", 2) end
end

-- ==================== AUTO HUNT FUEL ====================
function Farm:EquipBackpack()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name == "Backpack" then
        self.BackpackEquipped = true
        return true
    end
    
    local playerBackpack = LocalPlayer:FindFirstChild("Backpack")
    if playerBackpack then
        for _, tool in ipairs(playerBackpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Backpack" then
                pcall(function() tool.Parent = char end)
                task.wait(0.1)
                self.BackpackEquipped = true
                return true
            end
        end
    end
    
    self.BackpackEquipped = false
    return false
end

function Farm:FindNearestFuel()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local folders = self.Utils:DiscoverFolders()
    local droppedItems = folders.droppedItemsFolder
    if not droppedItems then return nil end
    
    local myPos = hrp.Position
    local nearest = nil
    local nearestDist = self.FuelHuntRange + 1
    
    for _, item in ipairs(droppedItems:GetChildren()) do
        if (item.Name == "Fuel" or item.Name == "Nuclear Fuel" or item.Name == "Refined Fuel") and item:IsA("Model") then
            local mainPart = item:FindFirstChild("HumanoidRootPart") 
                or item:FindFirstChild("PrimaryPart")
                or item:FindFirstChildWhichIsA("BasePart")
            
            if mainPart and mainPart.Parent then
                local dist = (mainPart.Position - myPos).Magnitude
                if dist < nearestDist and dist <= self.FuelHuntRange then
                    nearestDist = dist
                    nearest = {
                        item = item,
                        part = mainPart,
                        distance = dist
                    }
                end
            end
        end
    end
    
    return nearest
end

function Farm:PickupFuel(item)
    findAdjustBackpack()
    if not AdjustBackpack then return false end
    
    local success = pcall(function()
        AdjustBackpack:FireServer(item)
    end)
    return success
end

function Farm:StartFuelFly()
    if self.FuelFlying then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = true 
        hum.AutoRotate = false
    end
    
    self.FuelFlyBV = Instance.new("BodyVelocity")
    self.FuelFlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    self.FuelFlyBV.Velocity = Vector3.new(0, 0, 0)
    self.FuelFlyBV.Parent = hrp
    
    self.FuelFlyBG = Instance.new("BodyGyro")
    self.FuelFlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    self.FuelFlyBG.P = 9000
    self.FuelFlyBG.CFrame = workspace.CurrentCamera.CFrame
    self.FuelFlyBG.Parent = hrp
    
    self.FuelFlying = true
end

function Farm:StopFuelFly()
    self.FuelFlying = false
    if self.FuelFlyBV then self.FuelFlyBV:Destroy() self.FuelFlyBV = nil end
    if self.FuelFlyBG then self.FuelFlyBG:Destroy() self.FuelFlyBG = nil end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
end

function Farm:FlyToFuel(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetPosAtas = Vector3.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
    local arah = (targetPosAtas - hrp.Position).Unit
    local jarak = (targetPosAtas - hrp.Position).Magnitude
    
    if self.FuelFlyBV then
        local speed = math.min(80, jarak * 2)
        self.FuelFlyBV.Velocity = arah * speed
    end
    
    if self.FuelFlyBG then
        local lookAt = CFrame.lookAt(hrp.Position, targetPosAtas)
        self.FuelFlyBG.CFrame = lookAt
    end
end

function Farm:StartAutoHuntFuel()
    if self.FuelHuntActive then return end
    self.FuelHuntActive = true
    
    self:EquipBackpack()
    enableNoclip()
    self:StartFuelFly()
    
    self.FuelHuntConn = RunService.RenderStepped:Connect(function()
        if not self.FuelHuntActive then return end
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local currentTool = char:FindFirstChildOfClass("Tool")
            if not currentTool or currentTool.Name ~= "Backpack" then
                self:EquipBackpack()
            end
            
            local target = self:FindNearestFuel()
            
            if target then
                if self.FuelFlying then
                    self:FlyToFuel(target.part.Position)
                end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distToTarget = (target.part.Position - hrp.Position).Magnitude
                    
                    if distToTarget <= 10 then
                        local now = tick()
                        if now - self.LastPickupTime >= self.PickupCooldown then
                            if self:PickupFuel(target.item) then
                                self.LastPickupTime = now
                            end
                        end
                    end
                end
            else
                if self.FuelFlyBV then
                    self.FuelFlyBV.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end)
    
    if self.Notifications then self.Notifications:Show("Auto Hunt Fuel", "Enabled - Flying to Fuel! (Noclip ON)", 2) end
end

function Farm:StopAutoHuntFuel()
    self.FuelHuntActive = false
    if self.FuelHuntConn then
        self.FuelHuntConn:Disconnect()
        self.FuelHuntConn = nil
    end
    self:StopFuelFly()
    disableNoclip()
    self.BackpackEquipped = false
    if self.Notifications then self.Notifications:Show("Auto Hunt Fuel", "Disabled", 2) end
end

-- ==================== INIT ====================
function Farm:Init(deps)
    self.Config = deps.Config
    self.Network = deps.Network
    self.Utils = deps.Utils
    self.Notifications = deps.Notifications
    
    -- Update range from config if available
    if self.Config then
        local options = self.Config:GetOptions()
        if options.FuelHuntRange then
            self.FuelHuntRange = options.FuelHuntRange
        end
    end
    
    return self
end

return Farm
