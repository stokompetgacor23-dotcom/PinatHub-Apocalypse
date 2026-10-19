-- =======================================================
-- PINATHUB - WEAPON MODS & SILENT AIM MODULE (NEW FEATURE)
-- Directly leverages gun Stats attributes & _G.getCurrentAutoTargetPosition
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local WeaponMods = {
    Active = false,
    NoRecoil = false,
    NoSpread = false,
    FastReload = false,
    RapidFire = false,
    SilentAim = false,
    AutoReload = false,
    
    FireRateMultiplier = 2.0,
    SilentAimFOV = 150,
    SilentAimPart = "Head", -- "Head", "Torso", "HumanoidRootPart"
    SilentAimTarget = "Mobs", -- "Mobs", "Players", "Both"
    
    OriginalStats = {},
    CurrentTarget = nil,
    FOVCircle = nil,
    Connections = {},
}

-- ============================================
-- FOV CIRCLE FOR SILENT AIM
-- ============================================
local function setupFOVCircle()
    pcall(function()
        if not Drawing then return end
        if not WeaponMods.FOVCircle then
            WeaponMods.FOVCircle = Drawing.new("Circle")
            WeaponMods.FOVCircle.Thickness = 1.5
            WeaponMods.FOVCircle.Color = Color3.fromRGB(0, 200, 255)
            WeaponMods.FOVCircle.Transparency = 0.6
            WeaponMods.FOVCircle.Filled = false
            WeaponMods.FOVCircle.Visible = false
        end
    end)
end

-- ============================================
-- FIND SILENT AIM TARGET
-- ============================================
function WeaponMods:GetSilentAimTarget()
    local char = LocalPlayer.Character
    if not char or (char:GetAttribute("Dead") == true) then return nil end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    
    local characters = Workspace:FindFirstChild("Characters")
    if not characters then return nil end
    
    local viewportCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local shortestDist = self.SilentAimFOV or 150
    local myPos = hrp.Position
    local utils = self.Utils
    
    for _, entity in ipairs(characters:GetChildren()) do
        if entity == char then continue end
        
        -- Filter dead or untouchable
        if utils then
            if utils:IsDead(entity) or utils:IsUntouchable(entity) then continue end
        else
            if entity:GetAttribute("Dead") or entity:GetAttribute("Untouchable") then continue end
        end
        
        -- Target mode filter
        local isValid = false
        if self.SilentAimTarget == "Mobs" or self.SilentAimTarget == "Both" then
            if utils and utils:IsZombieOrBandit(entity) then
                isValid = true
            elseif entity:GetAttribute("Zombie") or entity:GetAttribute("Bandit") then
                isValid = true
            end
        end
        
        if not isValid and (self.SilentAimTarget == "Players" or self.SilentAimTarget == "Both") then
            if utils and utils:IsEnemyPlayer(entity) then
                isValid = true
            elseif entity:GetAttribute("Player") then
                isValid = true
            end
        end
        
        if not isValid then continue end
        
        local hum = entity:FindFirstChildOfClass("Humanoid") or entity:FindFirstChild("MockHumanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local targetPart = entity:FindFirstChild(self.SilentAimPart) 
            or entity:FindFirstChild("Head") 
            or entity:FindFirstChild("Torso") 
            or entity.PrimaryPart
            
        if targetPart then
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            if onScreen and screenPos.Z > 0 then
                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                if dist2D <= shortestDist then
                    shortestDist = dist2D
                    bestTarget = {
                        Model = entity,
                        Part = targetPart,
                        Position = targetPart.Position,
                        Distance = (targetPart.Position - myPos).Magnitude
                    }
                end
            end
        end
    end
    
    return bestTarget
end

-- ============================================
-- STAT MODIFIER ENGINE (TOOL.STATS ATTRIBUTES)
-- ============================================
function WeaponMods:ApplyToolMods(tool)
    if not tool or not tool:IsA("Tool") then return end
    
    local stats = tool:FindFirstChild("Stats")
    if not stats then return end
    
    local toolId = tool:GetDebugId()
    if not self.OriginalStats[toolId] then
        self.OriginalStats[toolId] = {
            Recoil = stats:GetAttribute("Recoil"),
            Inaccuracy = stats:GetAttribute("Inaccuracy"),
            FireRate = stats:GetAttribute("FireRate"),
            ReloadTime = stats:GetAttribute("ReloadTime"),
            ReloadEndTime = stats:GetAttribute("ReloadEndTime"),
            ReloadIndividualTime = stats:GetAttribute("ReloadIndividualTime"),
            ReloadAnimSpeed = stats:GetAttribute("ReloadAnimSpeed"),
        }
    end
    
    -- 1. No Recoil
    if self.NoRecoil then
        stats:SetAttribute("Recoil", 0)
    end
    
    -- 2. No Spread / Max Accuracy
    if self.NoSpread then
        stats:SetAttribute("Inaccuracy", 0)
        stats:SetAttribute("Accuracy", 100)
    end
    
    -- 3. Fast Reload
    if self.FastReload then
        stats:SetAttribute("ReloadTime", 0.05)
        stats:SetAttribute("ReloadEndTime", 0.05)
        stats:SetAttribute("ReloadIndividualTime", 0.05)
        stats:SetAttribute("ReloadAnimSpeed", 5)
    end
    
    -- 4. Rapid Fire
    if self.RapidFire then
        local origRate = self.OriginalStats[toolId].FireRate or 300
        stats:SetAttribute("FireRate", origRate * (self.FireRateMultiplier or 2.0))
    end
end

function WeaponMods:RestoreToolMods(tool)
    if not tool then return end
    local stats = tool:FindFirstChild("Stats")
    if not stats then return end
    
    local toolId = tool:GetDebugId()
    local orig = self.OriginalStats[toolId]
    if orig then
        if orig.Recoil ~= nil then stats:SetAttribute("Recoil", orig.Recoil) end
        if orig.Inaccuracy ~= nil then stats:SetAttribute("Inaccuracy", orig.Inaccuracy) end
        if orig.FireRate ~= nil then stats:SetAttribute("FireRate", orig.FireRate) end
        if orig.ReloadTime ~= nil then stats:SetAttribute("ReloadTime", orig.ReloadTime) end
        if orig.ReloadEndTime ~= nil then stats:SetAttribute("ReloadEndTime", orig.ReloadEndTime) end
        if orig.ReloadIndividualTime ~= nil then stats:SetAttribute("ReloadIndividualTime", orig.ReloadIndividualTime) end
        if orig.ReloadAnimSpeed ~= nil then stats:SetAttribute("ReloadAnimSpeed", orig.ReloadAnimSpeed) end
    end
end

-- ============================================
-- HOOK _G.getCurrentAutoTargetPosition FOR GAME'S AIM ENGINE
-- ============================================
function WeaponMods:SetupAutoTargetHook()
    local originalFunc = _G.getCurrentAutoTargetPosition
    
    _G.getCurrentAutoTargetPosition = function(a1, a2, a3)
        if WeaponMods.SilentAim then
            local target = WeaponMods:GetSilentAimTarget()
            if target and target.Position then
                return target.Position
            end
        end
        
        if originalFunc then
            return originalFunc(a1, a2, a3)
        end
        return nil
    end
    
    print("[WEAPON MODS] Hooked _G.getCurrentAutoTargetPosition for Silent Aim")
end

-- ============================================
-- MAIN LOOP
-- ============================================
function WeaponMods:Start()
    if self.Active then return end
    self.Active = true
    
    setupFOVCircle()
    self:SetupAutoTargetHook()
    
    local loopConn = RunService.RenderStepped:Connect(function()
        if not self.Active then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Check and mod equipped tool
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            self:ApplyToolMods(tool)
        end
        
        -- FOV Circle update
        if self.FOVCircle then
            if self.SilentAim and self.FOVCircle then
                local camera = Workspace.CurrentCamera
                if camera then
                    self.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    self.FOVCircle.Radius = self.SilentAimFOV or 150
                    self.FOVCircle.Visible = true
                end
            else
                self.FOVCircle.Visible = false
            end
        end
    end)
    
    table.insert(self.Connections, loopConn)
    print("[WEAPON MODS] Started")
end

function WeaponMods:Stop()
    self.Active = false
    
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    
    if self.FOVCircle then
        self.FOVCircle.Visible = false
    end
    
    -- Restore all modified tools
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then self:RestoreToolMods(tool) end
    end
    
    print("[WEAPON MODS] Stopped")
end

-- Setters
function WeaponMods:SetNoRecoil(val) self.NoRecoil = val end
function WeaponMods:SetNoSpread(val) self.NoSpread = val end
function WeaponMods:SetFastReload(val) self.FastReload = val end
function WeaponMods:SetRapidFire(val) self.RapidFire = val end
function WeaponMods:SetSilentAim(val) self.SilentAim = val end
function WeaponMods:SetSilentAimFOV(val) self.SilentAimFOV = val end
function WeaponMods:SetSilentAimPart(val) self.SilentAimPart = val end
function WeaponMods:SetSilentAimTarget(val) self.SilentAimTarget = val end
function WeaponMods:SetFireRateMultiplier(val) self.FireRateMultiplier = val end

function WeaponMods:Init(deps)
    self.Config = deps.config or deps.Config
    self.Utils = deps.utils or deps.Utils
    self.Notifications = deps.notifications or deps.Notifications
    self.Network = deps.network or deps.Network
    
    self:Start()
    print("[WEAPON MODS] Initialized")
    return self
end

return WeaponMods
