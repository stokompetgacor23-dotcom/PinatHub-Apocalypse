-- =======================================================
-- PINATHUB - KILL AURA MODULE (UPDATED WITH GAME DUMP INTEGRATION)
-- Detects mobs via Zombie/Bandit attributes & full game mob roster
-- Supports Power Hammer, Scorchblade, Melee, and PvP targeting
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local KillAura = {}

-- Variables
KillAura.Connections = {}
KillAura.Active = false
KillAura.CurrentTarget = nil
KillAura.TargetDistance = nil
KillAura.LastSwing = 0

-- Drawing objects for indicator
KillAura.IndicatorLine = nil
KillAura.IndicatorCircle = nil

-- Options
KillAura.Options = {
    Range = 8,
    Priority = "Nearest",
    SwingRate = 0.5,
    AutoEquip = true,
    ShowIndicator = true,
    ExtendedRange = true,
    TargetMode = "Mobs", -- "Mobs", "Players", "Both"
}

-- ============================================
-- INDICATOR FUNCTIONS
-- ============================================
local function setupIndicators()
    pcall(function()
        if not Drawing then return end
        if not KillAura.IndicatorLine then
            KillAura.IndicatorLine = Drawing.new("Line")
            KillAura.IndicatorLine.Thickness = 1.5
            KillAura.IndicatorLine.Color = Color3.fromRGB(255, 55, 55)
            KillAura.IndicatorLine.Transparency = 0.65
            KillAura.IndicatorLine.Visible = false
        end
        
        if not KillAura.IndicatorCircle then
            KillAura.IndicatorCircle = Drawing.new("Circle")
            KillAura.IndicatorCircle.Thickness = 1.5
            KillAura.IndicatorCircle.Color = Color3.fromRGB(255, 55, 55)
            KillAura.IndicatorCircle.Transparency = 0.55
            KillAura.IndicatorCircle.Filled = false
            KillAura.IndicatorCircle.Visible = false
        end
    end)
end

local function updateIndicator(target, distance)
    if not Drawing then return end
    if not KillAura.Options.ShowIndicator or not target then
        if KillAura.IndicatorLine then KillAura.IndicatorLine.Visible = false end
        if KillAura.IndicatorCircle then KillAura.IndicatorCircle.Visible = false end
        return
    end
    
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target.PrimaryPart
    if not targetRoot then return end
    
    local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
    if onScreen and screenPos.Z > 0 then
        local viewportSize = camera.ViewportSize
        local center = Vector2.new(viewportSize.X / 2, viewportSize.Y)
        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        
        KillAura.IndicatorLine.From = center
        KillAura.IndicatorLine.To = targetPos
        KillAura.IndicatorLine.Visible = true
        
        local radius = math.clamp(1200 / math.max(distance or 10, 1), 8, 40)
        KillAura.IndicatorCircle.Position = targetPos
        KillAura.IndicatorCircle.Radius = radius
        KillAura.IndicatorCircle.Visible = true
    else
        if KillAura.IndicatorLine then KillAura.IndicatorLine.Visible = false end
        if KillAura.IndicatorCircle then KillAura.IndicatorCircle.Visible = false end
    end
end

-- ============================================
-- WEAPON MANAGEMENT
-- ============================================
local function getWeaponSwingSpeed()
    local char = LocalPlayer.Character
    if not char then return 0.5 end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 0.5 end
    
    local toolName = tool.Name
    local speeds = (KillAura.Config and KillAura.Config:GetWeaponSwingSpeeds()) or {}
    
    if speeds[toolName] then return speeds[toolName] end
    
    for weaponName, speed in pairs(speeds) do
        if string.find(toolName:lower(), weaponName:lower()) then
            return speed
        end
    end
    return 0.4
end

local function autoEquipWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChildOfClass("Tool") then return true end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    -- Priority melee weapons
    local priority = {
        "Power Hammer", "Scorchblade", "Katana", "Knife", "Crowbar", 
        "Bat", "Spiked Bat", "Scythe", "Hatchet", "Fire Axe", "Sledgehammer", "Chainsaw"
    }
    
    for _, weaponName in ipairs(priority) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), weaponName:lower()) then
                pcall(function() tool.Parent = char end)
                return true
            end
        end
    end
    
    -- Any tool fallback
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool.Parent = char end)
            return true
        end
    end
    return false
end

-- ============================================
-- TARGET ACQUISITION (USES GAME ATTRIBUTES & STRUCTURE)
-- ============================================
local function findTargetsInRange()
    local char = LocalPlayer.Character
    if not char or (char:GetAttribute("Dead") == true) then return {} end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local charactersFolder = Workspace:FindFirstChild("Characters")
    if not charactersFolder then return {} end

    local targets = {}
    local myPos = hrp.Position
    local baseRange = KillAura.Options.Range or 8
    local attackRange = KillAura.Options.ExtendedRange and (baseRange + 2.5) or baseRange
    local targetMode = KillAura.Options.TargetMode or "Mobs"
    local utils = KillAura.Utils

    for _, entity in ipairs(charactersFolder:GetChildren()) do
        if entity == char then continue end
        
        -- Filter out dead or untouchable entities
        if utils then
            if utils:IsDead(entity) or utils:IsUntouchable(entity) then continue end
        else
            if entity:GetAttribute("Dead") or entity:GetAttribute("Untouchable") then continue end
        end
        
        -- Check entity type based on TargetMode
        local isValidTarget = false
        if targetMode == "Mobs" or targetMode == "Both" then
            if utils and utils:IsZombieOrBandit(entity) then
                isValidTarget = true
            elseif entity:GetAttribute("Zombie") or entity:GetAttribute("Bandit") then
                isValidTarget = true
            end
        end
        
        if not isValidTarget and (targetMode == "Players" or targetMode == "Both") then
            if utils and utils:IsEnemyPlayer(entity) then
                isValidTarget = true
            elseif entity:GetAttribute("Player") then
                isValidTarget = true
            end
        end
        
        if not isValidTarget then continue end
        
        local root = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso") or entity.PrimaryPart
        local hum = entity:FindFirstChildOfClass("Humanoid") or entity:FindFirstChild("MockHumanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        
        local dist = (root.Position - myPos).Magnitude
        if dist <= attackRange then
            table.insert(targets, {
                entity = entity,
                dist = dist,
                health = hum.Health,
                maxHealth = hum.MaxHealth,
            })
        end
    end

    -- Sorting
    local priority = KillAura.Options.Priority
    if priority == "Nearest" then
        table.sort(targets, function(a, b) return a.dist < b.dist end)
    elseif priority == "Lowest HP" then
        table.sort(targets, function(a, b) return a.health < b.health end)
    elseif priority == "Highest HP" then
        table.sort(targets, function(a, b) return a.health > b.health end)
    end

    return targets
end

-- ============================================
-- ATTACK TARGET
-- ============================================
local function attackTarget(target)
    if not target or not target.Parent then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    if KillAura.Options.AutoEquip and not char:FindFirstChildOfClass("Tool") then
        autoEquipWeapon()
    end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end

    -- Use network dispatcher if available (handles Power Hammer, Scorchblade, Swing+HitTargets)
    if KillAura.Network and KillAura.Network.FireToolAttack then
        return KillAura.Network:FireToolAttack(tool, {target})
    end

    -- Direct fallback
    local swing = tool:FindFirstChild("Swing")
    local hitTargets = tool:FindFirstChild("HitTargets")
    if swing and hitTargets then
        pcall(function()
            swing:FireServer()
            hitTargets:FireServer({target})
        end)
        return true
    end
    
    pcall(function() tool:Activate() end)
    return true
end

-- ============================================
-- START & STOP
-- ============================================
function KillAura:Start()
    if self.Active then return end
    self.Active = true
    
    setupIndicators()
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        
        local char = LocalPlayer.Character
        if not char or (char:GetAttribute("Dead") == true) then
            updateIndicator(nil)
            return
        end
        
        local targets = findTargetsInRange()
        if #targets > 0 then
            local primary = targets[1]
            self.CurrentTarget = primary.entity
            self.TargetDistance = primary.dist
            updateIndicator(primary.entity, primary.dist)
            
            local now = tick()
            local baseSpeed = getWeaponSwingSpeed()
            local userSwingRate = self.Options.SwingRate or 0.5
            local actualCooldown = math.min(baseSpeed, userSwingRate)
            
            if now - self.LastSwing >= actualCooldown then
                self.LastSwing = now
                attackTarget(primary.entity)
            end
        else
            self.CurrentTarget = nil
            self.TargetDistance = nil
            updateIndicator(nil)
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[KILL AURA] Started")
end

function KillAura:Stop()
    self.Active = false
    self.CurrentTarget = nil
    self.TargetDistance = nil
    
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    
    updateIndicator(nil)
    print("[KILL AURA] Stopped")
end

-- Setters
function KillAura:SetRange(val) self.Options.Range = val end
function KillAura:SetSwingRate(val) self.Options.SwingRate = val end
function KillAura:SetPriority(val) self.Options.Priority = val end
function KillAura:SetAutoEquip(val) self.Options.AutoEquip = val end
function KillAura:SetShowIndicator(val) self.Options.ShowIndicator = val end
function KillAura:SetExtendedRange(val) self.Options.ExtendedRange = val end
function KillAura:SetTargetMode(val) self.Options.TargetMode = val end

function KillAura:Init(deps)
    self.Config = deps.config or deps.Config
    self.Utils = deps.utils or deps.Utils
    self.Notifications = deps.notifications or deps.Notifications
    self.Network = deps.network or deps.Network
    
    if self.Config then
        local opts = self.Config:GetOptions()
        if opts.KillAuraRange then self.Options.Range = opts.KillAuraRange end
        if opts.KillAuraSwingRate then self.Options.SwingRate = opts.KillAuraSwingRate end
        if opts.KillAuraTargetMode then self.Options.TargetMode = opts.KillAuraTargetMode end
    end
    
    print("[KILL AURA] Initialized with game dump structure")
    return self
end

return KillAura
