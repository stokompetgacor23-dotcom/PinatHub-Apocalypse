-- =======================================================
-- PINATHUB - KILL AURA MODULE (COMPLETE)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local KillAura = {}

-- ============================================
-- VARIABLES
-- ============================================
KillAura.Connections = {}
KillAura.Active = false
KillAura.CurrentTarget = nil
KillAura.TargetDistance = nil
KillAura.LastSwing = 0

-- Drawing objects untuk indicator
KillAura.IndicatorLine = nil
KillAura.IndicatorCircle = nil

-- Weapon swing speeds database
KillAura.WeaponSwingSpeeds = {
    ["Knife"] = 0.25, ["Katana"] = 0.3, ["Crowbar"] = 0.35,
    ["Bat"] = 0.45, ["Spiked Bat"] = 0.45, ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4, ["Spear"] = 0.4, ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6, ["Chainsaw"] = 0.35, ["Riot Shield"] = 0.5,
}

-- Mob names
KillAura.MobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- Options (akan di-set dari config)
KillAura.Options = {
    Range = 6,
    Priority = "Nearest",
    SwingRate = 0.5,
    AutoEquip = false,
    ShowIndicator = true,
    ExtendedRange = true,
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getCharactersFolder()
    return Workspace:FindFirstChild("Characters")
end

local function getWeaponSwingSpeed()
    local char = LocalPlayer.Character
    if not char then return 0.5 end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 0.5 end
    local toolName = tool.Name
    
    if KillAura.WeaponSwingSpeeds[toolName] then 
        return KillAura.WeaponSwingSpeeds[toolName] 
    end
    
    for weaponName, speed in pairs(KillAura.WeaponSwingSpeeds) do
        if string.find(toolName:lower(), weaponName:lower()) then 
            return speed 
        end
    end
    return 0.5
end

local function findTargetsInRange()
    local char = LocalPlayer.Character
    if not char then return {} end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local charactersFolder = getCharactersFolder()
    if not charactersFolder then return {} end

    local targets = {}
    local myPos = hrp.Position
    
    local baseRange = KillAura.Options.Range
    local useExtendedRange = KillAura.Options.ExtendedRange
    local attackRange = useExtendedRange and (baseRange + 2) or baseRange

    for _, mob in ipairs(charactersFolder:GetChildren()) do
        if mob == char then continue end
        
        -- Check if it's a mob
        local isMob = false
        for _, name in ipairs(KillAura.MobNames) do
            if mob.Name == name then
                isMob = true
                break
            end
        end
        if not isMob then continue end
        
        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        
        if not mobHRP or not mobHum then continue end
        if mobHum.Health <= 0 then continue end
        
        local dist = (mobHRP.Position - myPos).Magnitude
        if dist <= attackRange then
            table.insert(targets, {
                mob = mob,
                dist = dist,
                health = mobHum.Health,
                maxHealth = mobHum.MaxHealth,
            })
        end
    end

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

local function autoEquipWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Already have a weapon equipped
    if char:FindFirstChildOfClass("Tool") then 
        return true 
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    -- Priority weapons (melee weapons first)
    local priority = {"Katana", "Knife", "Crowbar", "Bat", "Spiked Bat", "Scythe", "Hatchet", "Fire Axe", "Sledgehammer", "Chainsaw"}
    
    -- Try priority weapons
    for _, weaponName in ipairs(priority) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, weaponName) then
                pcall(function() tool.Parent = char end)
                return true
            end
        end
    end
    
    -- Any weapon as fallback
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool.Parent = char end)
            return true
        end
    end
    
    return false
end

local function attackTarget(target)
    if not target then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Auto equip if needed
    if KillAura.Options.AutoEquip and not char:FindFirstChildOfClass("Tool") then
        autoEquipWeapon()
    end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end

    local swing = tool:FindFirstChild("Swing")
    local hitTargets = tool:FindFirstChild("HitTargets")
    local remoteClick = tool:FindFirstChild("RemoteClick")
    
    local attackSuccess = false
    
    -- Try different attack methods
    if swing and hitTargets then
        pcall(function() 
            swing:FireServer() 
            hitTargets:FireServer({target})
        end)
        attackSuccess = true
    elseif remoteClick then
        pcall(function() remoteClick:FireServer(target) end)
        attackSuccess = true
    elseif tool:FindFirstChild("Activate") then
        pcall(function() tool:Activate() end)
        attackSuccess = true
    end
    
    return attackSuccess
end

-- ============================================
-- INDICATOR FUNCTIONS
-- ============================================
local function setupIndicators()
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
end

local function updateIndicator(target, distance)
    if not KillAura.Options.ShowIndicator then
        if KillAura.IndicatorLine then KillAura.IndicatorLine.Visible = false end
        if KillAura.IndicatorCircle then KillAura.IndicatorCircle.Visible = false end
        return
    end
    
    if not target then
        if KillAura.IndicatorLine then KillAura.IndicatorLine.Visible = false end
        if KillAura.IndicatorCircle then KillAura.IndicatorCircle.Visible = false end
        return
    end
    
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    local screenPos, onScreen = camera:WorldToViewportPoint(targetHRP.Position)
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
        KillAura.IndicatorLine.Visible = false
        KillAura.IndicatorCircle.Visible = false
    end
end

-- ============================================
-- MAIN KILL AURA LOOP
-- ============================================
local function killAuraLoop()
    if not KillAura.Active then return end
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Find targets
        local targets = findTargetsInRange()
        
        -- Set current target
        KillAura.CurrentTarget = targets[1] and targets[1].mob or nil
        KillAura.TargetDistance = targets[1] and targets[1].dist or nil
        
        -- Update indicator
        updateIndicator(KillAura.CurrentTarget, KillAura.TargetDistance)
        
        -- No target found
        if #targets == 0 then return end
        
        -- Get weapon swing speed
        local weaponSpeed = getWeaponSwingSpeed()
        local userSwingRate = KillAura.Options.SwingRate
        local effectiveSwingRate = math.max(weaponSpeed, userSwingRate)
        
        -- Rate limiting
        local now = tick()
        if now - KillAura.LastSwing < effectiveSwingRate then return end
        
        -- Attack the first target (already sorted by priority)
        local target = targets[1].mob
        if attackTarget(target) then
            KillAura.LastSwing = now
        end
    end)
end

-- ============================================
-- PUBLIC METHODS
-- ============================================
function KillAura:Start()
    if self.Active then return end
    
    self.Active = true
    self.LastSwing = 0
    self.CurrentTarget = nil
    
    setupIndicators()
    
    -- Start the kill aura loop
    local connection = RunService.RenderStepped:Connect(function()
        killAuraLoop()
    end)
    table.insert(self.Connections, connection)
    
    print("[KILL AURA] Started - Range: " .. self.Options.Range .. ", Priority: " .. self.Options.Priority)
end

function KillAura:Stop()
    self.Active = false
    self.CurrentTarget = nil
    self.TargetDistance = nil
    
    -- Clean up indicators
    if self.IndicatorLine then 
        self.IndicatorLine.Visible = false 
    end
    if self.IndicatorCircle then 
        self.IndicatorCircle.Visible = false 
    end
    
    -- Disconnect all connections
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    
    print("[KILL AURA] Stopped")
end

function KillAura:UpdateOptions(options)
    if options.Range then self.Options.Range = options.Range end
    if options.Priority then self.Options.Priority = options.Priority end
    if options.SwingRate then self.Options.SwingRate = options.SwingRate end
    if options.AutoEquip ~= nil then self.Options.AutoEquip = options.AutoEquip end
    if options.ShowIndicator ~= nil then self.Options.ShowIndicator = options.ShowIndicator end
    if options.ExtendedRange ~= nil then self.Options.ExtendedRange = options.ExtendedRange end
end

function KillAura:SetRange(range)
    self.Options.Range = range
    print("[KILL AURA] Range updated to: " .. range)
end

function KillAura:SetPriority(priority)
    self.Options.Priority = priority
    print("[KILL AURA] Priority updated to: " .. priority)
end

function KillAura:SetSwingRate(rate)
    self.Options.SwingRate = rate
end

function KillAura:SetAutoEquip(enabled)
    self.Options.AutoEquip = enabled
end

function KillAura:SetShowIndicator(enabled)
    self.Options.ShowIndicator = enabled
    if not enabled then
        if self.IndicatorLine then self.IndicatorLine.Visible = false end
        if self.IndicatorCircle then self.IndicatorCircle.Visible = false end
    end
end

function KillAura:SetExtendedRange(enabled)
    self.Options.ExtendedRange = enabled
end

function KillAura:GetCurrentTarget()
    return self.CurrentTarget, self.TargetDistance
end

function KillAura:IsActive()
    return self.Active
end

-- ============================================
-- INIT
-- ============================================
function KillAura:Init(deps)
    self.Config = deps.config or deps.Config
    self.Notifications = deps.notifications or deps.Notifications
    
    -- Load options from config if available
    if self.Config then
        local options = self.Config:GetOptions()
        if options then
            self.Options.Range = options.KillAuraRange or 6
            self.Options.Priority = options.KillAuraPriority or "Nearest"
            self.Options.SwingRate = options.KillAuraSwingRate or 0.5
            self.Options.AutoEquip = options.KillAuraAutoEquip or false
            self.Options.ShowIndicator = options.KillAuraShowIndicator or true
            self.Options.ExtendedRange = options.KillAuraExtendedRange or true
        end
    end
    
    print("[KILL AURA MODULE] Initialized")
    return self
end

return KillAura
