-- =======================================================
-- PINATHUB - PLAYER MODULE (UPDATED WITH GAME DUMP INTEGRATION)
-- Integrated with WalkSpeedClient, ExplorerProximityPrompt, LightingClient
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Player = {
    FlyActive = false,
    FlyBV = nil,
    FlyBG = nil,
    FlyMoveConn = nil,
    FlySpeed = 50,
    AutoSprintActive = false,
    AntiAFKConn = nil,
    BhopActive = false,
    BhopConn = nil,
    NoclipActive = false,
    NoclipConn = nil,
    NoclipLastCFrame = nil,
    InfJumpActive = false,
    JumpConn = nil,
    SpeedHackConn = nil,
    SpeedValue = 50,
    OriginalWalkSpeed = nil,
    FullbrightActive = false,
    FullbrightConn = nil,
    RemoveFogActive = false,
    RemoveFogConn = nil,
    InstantPromptActive = false,
    InstantPromptConn = nil,
    NativeItemESPActive = false,
    AntiHungerActive = false,
    AntiHungerConn = nil,
    
    -- Healing & Defense (Game Dump Attributes)
    AutoHealActive = false,
    AutoHealThreshold = 0.5,
    AutoHealConn = nil,
    IsHealing = false,
    LastHealTick = 0,
    
    InstantHealActive = false,
    InstantHealThreshold = 0.4,
    InstantHealConn = nil,
    
    SuperRegenActive = false,
    SuperRegenConn = nil,
    
    DamageReductionActive = false,
    DamageReductionConn = nil,
    DamageReductionValue = 0.75,
    
    PsychicShieldActive = false,
    PsychicShieldConn = nil,
    
    StatusImmunityActive = false,
    StatusImmunityConn = nil,
    
    InstantReviveActive = false,
    InstantReviveConn = nil,
    
    MegaMapRevealActive = false,
    MegaMapRevealConn = nil,
    
    Utils = nil,
    Notifications = nil,
    Config = nil,
    Network = nil,
}

-- ============================================
-- SPEED HACK (USES GAME'S WALKSPEEDCLIENT ATTRIBUTES + STEPPED)
-- ============================================
function Player:StartSpeedHack(speedValue)
    self.SpeedValue = speedValue or 50
    if self.SpeedHackConn then
        self:StopSpeedHack()
    end
    
    local char = LocalPlayer.Character
    if char and not self.OriginalWalkSpeed then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalWalkSpeed = humanoid.WalkSpeed
        end
    end
    
    -- Apply game's WalkSpeed attribute (WalkSpeedClient calculates: 16 + WalkSpeed)
    local function applySpeed(targetChar)
        if not targetChar then return end
        local bonusSpeed = math.max(0, self.SpeedValue - 16)
        pcall(function()
            targetChar:SetAttribute("WalkSpeed", bonusSpeed)
            targetChar:SetAttribute("SprintSpeed", 1)
            if _G.updateWalkSpeed then
                _G.updateWalkSpeed()
            end
        end)
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = self.SpeedValue
        end
    end
    
    applySpeed(char)
    
    self.SpeedHackConn = RunService.Stepped:Connect(function()
        local c = LocalPlayer.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= self.SpeedValue then
                hum.WalkSpeed = self.SpeedValue
            end
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.SpeedHackConn) end
    print("[SPEED HACK] Enabled - Speed:", self.SpeedValue)
end

function Player:StopSpeedHack()
    if self.SpeedHackConn then
        self.SpeedHackConn:Disconnect()
        self.SpeedHackConn = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            char:SetAttribute("WalkSpeed", 0)
            char:SetAttribute("SprintSpeed", 0)
            if _G.updateWalkSpeed then
                _G.updateWalkSpeed()
            end
        end)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = self.OriginalWalkSpeed or 16
        end
    end
    print("[SPEED HACK] Disabled")
end

-- ============================================
-- NOCLIP
-- ============================================
function Player:StartNoclip()
    if self.NoclipActive then return end
    self.NoclipActive = true
    self.NoclipLastCFrame = nil
    
    self.NoclipConn = RunService.Heartbeat:Connect(function()
        if not self.NoclipActive then return end
        
        local char = LocalPlayer.Character
        if not char then 
            self.NoclipLastCFrame = nil
            return 
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then 
            self.NoclipLastCFrame = nil
            return 
        end
        
        local currentCF = root.CFrame
        if self.NoclipLastCFrame then
            local delta = (currentCF.Position - self.NoclipLastCFrame.Position).Magnitude
            if delta > 12 then
                root.CFrame = self.NoclipLastCFrame
                currentCF = self.NoclipLastCFrame
            end
        end
        self.NoclipLastCFrame = currentCF
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.NoclipConn) end
    print("[NOCLIP] Enabled")
end

function Player:StopNoclip()
    self.NoclipActive = false
    self.NoclipLastCFrame = nil
    
    if self.NoclipConn then
        self.NoclipConn:Disconnect()
        self.NoclipConn = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    print("[NOCLIP] Disabled")
end

-- ============================================
-- FLY HACK
-- ============================================
function Player:StartFly(speed)
    if self.FlyActive then return end
    self.FlySpeed = speed or 50
    self.FlyActive = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    
    self.FlyBV = Instance.new("BodyVelocity")
    self.FlyBV.Velocity = Vector3.new(0, 0, 0)
    self.FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    self.FlyBV.Parent = root
    
    self.FlyBG = Instance.new("BodyGyro")
    self.FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    self.FlyBG.CFrame = root.CFrame
    self.FlyBG.Parent = root
    
    humanoid.PlatformStand = true
    
    self.FlyMoveConn = RunService.RenderStepped:Connect(function()
        if not self.FlyActive or not self.FlyBV or not self.FlyBG then return end
        
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            self.FlyBV.Velocity = moveDir.Unit * self.FlySpeed
        else
            self.FlyBV.Velocity = Vector3.new(0, 0, 0)
        end
        
        self.FlyBG.CFrame = camera.CFrame
    end)
    
    if self.Utils then self.Utils:AddConnection(self.FlyMoveConn) end
    print("[FLY] Enabled - Speed:", self.FlySpeed)
end

function Player:StopFly()
    self.FlyActive = false
    
    if self.FlyMoveConn then
        self.FlyMoveConn:Disconnect()
        self.FlyMoveConn = nil
    end
    
    if self.FlyBV then
        self.FlyBV:Destroy()
        self.FlyBV = nil
    end
    
    if self.FlyBG then
        self.FlyBG:Destroy()
        self.FlyBG = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    print("[FLY] Disabled")
end

function Player:SetFlySpeed(speed)
    self.FlySpeed = speed
end

-- ============================================
-- AUTO SPRINT
-- ============================================
function Player:StartAutoSprint()
    if self.AutoSprintActive then return end
    self.AutoSprintActive = true
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
    end)
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("SprintingClient", true)
    end
    print("[AUTO SPRINT] Enabled")
end

function Player:StopAutoSprint()
    if not self.AutoSprintActive then return end
    self.AutoSprintActive = false
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    end)
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("SprintingClient", false)
    end
    print("[AUTO SPRINT] Disabled")
end

-- ============================================
-- INFINITE JUMP
-- ============================================
function Player:StartInfJump()
    if self.InfJumpActive then return end
    self.InfJumpActive = true
    
    self.JumpConn = UserInputService.JumpRequest:Connect(function()
        if self.InfJumpActive then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.JumpConn) end
    print("[INFINITE JUMP] Enabled")
end

function Player:StopInfJump()
    self.InfJumpActive = false
    if self.JumpConn then
        self.JumpConn:Disconnect()
        self.JumpConn = nil
    end
    print("[INFINITE JUMP] Disabled")
end

-- ============================================
-- BUNNY HOP
-- ============================================
function Player:StartBunnyHop()
    if self.BhopActive then return end
    self.BhopActive = true
    
    self.BhopConn = RunService.RenderStepped:Connect(function()
        if not self.BhopActive then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.BhopConn) end
    print("[BUNNY HOP] Enabled")
end

function Player:StopBunnyHop()
    self.BhopActive = false
    if self.BhopConn then
        self.BhopConn:Disconnect()
        self.BhopConn = nil
    end
    print("[BUNNY HOP] Disabled")
end

-- ============================================
-- ANTI AFK
-- ============================================
function Player:StartAntiAFK()
    if self.AntiAFKConn then
        self:StopAntiAFK()
    end
    
    self.AntiAFKConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
    
    if self.Utils then self.Utils:AddConnection(self.AntiAFKConn) end
    print("[ANTI AFK] Enabled")
end

function Player:StopAntiAFK()
    if self.AntiAFKConn then
        self.AntiAFKConn:Disconnect()
        self.AntiAFKConn = nil
    end
    print("[ANTI AFK] Disabled")
end

-- ============================================
-- PERSISTENT FULLBRIGHT (OVERCOMES LIGHTINGCLIENT TWEENS)
-- ============================================
function Player:StartFullbright()
    if self.FullbrightActive then return end
    self.FullbrightActive = true
    
    self.FullbrightConn = RunService.RenderStepped:Connect(function()
        if not self.FullbrightActive then return end
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
    end)
    
    if self.Utils then self.Utils:AddConnection(self.FullbrightConn) end
    print("[FULLBRIGHT] Enabled (Persistent)")
end

function Player:StopFullbright()
    self.FullbrightActive = false
    if self.FullbrightConn then
        self.FullbrightConn:Disconnect()
        self.FullbrightConn = nil
    end
    Lighting.Brightness = 1
    Lighting.GlobalShadows = true
    print("[FULLBRIGHT] Disabled")
end

-- ============================================
-- PERSISTENT REMOVE FOG
-- ============================================
function Player:StartRemoveFog()
    if self.RemoveFogActive then return end
    self.RemoveFogActive = true
    
    self.RemoveFogConn = RunService.RenderStepped:Connect(function()
        if not self.RemoveFogActive then return end
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            atm.Density = 0
            atm.Haze = 0
            atm.Glare = 0
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.RemoveFogConn) end
    print("[REMOVE FOG] Enabled (Persistent)")
end

function Player:StopRemoveFog()
    self.RemoveFogActive = false
    if self.RemoveFogConn then
        self.RemoveFogConn:Disconnect()
        self.RemoveFogConn = nil
    end
    print("[REMOVE FOG] Disabled")
end

-- ============================================
-- INSTANT PROXIMITY PROMPT (GAME EXPLORER ATTRIBUTE HOOK)
-- ============================================
function Player:StartInstantProximityPrompt()
    if self.InstantPromptActive then return end
    self.InstantPromptActive = true
    
    local function applyToChar(char)
        if char then
            char:SetAttribute("InteractableUseSpeed", 9999)
        end
    end
    
    applyToChar(LocalPlayer.Character)
    
    self.InstantPromptConn = Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") then
            descendant.HoldDuration = 0
        end
    end)
    
    -- Also zero out all existing prompts
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
        end
    end
    
    if self.Utils then self.Utils:AddConnection(self.InstantPromptConn) end
    print("[INSTANT PROMPT] Enabled via InteractableUseSpeed attribute")
end

function Player:StopInstantProximityPrompt()
    self.InstantPromptActive = false
    if self.InstantPromptConn then
        self.InstantPromptConn:Disconnect()
        self.InstantPromptConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("InteractableUseSpeed", 1)
    end
    print("[INSTANT PROMPT] Disabled")
end

-- ============================================
-- NATIVE ITEM ESP (USES GAME'S NEARBYHIGHLIGHTER ATTRIBUTE)
-- ============================================
function Player:StartNativeItemESP()
    self.NativeItemESPActive = true
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("NearbyItemESP", true)
    end
    print("[NATIVE ITEM ESP] Enabled via Character.NearbyItemESP")
end

function Player:StopNativeItemESP()
    self.NativeItemESPActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("NearbyItemESP", false)
    end
    print("[NATIVE ITEM ESP] Disabled")
end

-- ============================================
-- ANTI HUNGER DRAIN (INFINITE HUNGER)
-- ============================================
function Player:StartAntiHungerDrain()
    if self.AntiHungerActive then return end
    self.AntiHungerActive = true
    
    self.AntiHungerConn = RunService.Heartbeat:Connect(function()
        if not self.AntiHungerActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("HungerDrain", -10)
            char:SetAttribute("Hunger", 100)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.AntiHungerConn) end
    print("[ANTI HUNGER] Enabled")
end

function Player:StopAntiHungerDrain()
    self.AntiHungerActive = false
    if self.AntiHungerConn then
        self.AntiHungerConn:Disconnect()
        self.AntiHungerConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("HungerDrain", 0)
    end
    print("[ANTI HUNGER] Disabled")
end

-- ============================================
-- UNLOCK ENTIRE MAP FOG (GAME DUMP STRUCTURE)
-- ============================================
function Player:UnlockEntireMap()
    if self.Utils and self.Utils.UnlockEntireMap then
        return self.Utils:UnlockEntireMap(self.Network, self.Notifications)
    end
    return 0
end

-- ============================================
-- AUTO HEAL SELF (GAME DUMP MEDICAL ITEMS + ATTRIBUTES)
-- ============================================
local MEDICAL_ITEM_NAMES = {"Medkit", "Bandage", "Compound H", "Compound I", "Compound R", "Compound S"}

function Player:FindMedicalItem()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Check character hands first
    for _, name in ipairs(MEDICAL_ITEM_NAMES) do
        local tool = char:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end
    
    -- Check Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, name in ipairs(MEDICAL_ITEM_NAMES) do
            local tool = backpack:FindFirstChild(name)
            if tool and tool:IsA("Tool") then
                return tool
            end
        end
        -- Fallback: any tool with Medical item type or healing attributes
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if tool:GetAttribute("ItemType") == "Medical" or tool:GetAttribute("Heal") or string.find(tool.Name, "Med") or string.find(tool.Name, "Bandage") then
                    return tool
                end
            end
        end
    end
    return nil
end

function Player:StartAutoHeal(thresholdPercent)
    if thresholdPercent then
        self.AutoHealThreshold = thresholdPercent / 100
    end
    self.AutoHealActive = true
    
    if self.AutoHealConn then
        self.AutoHealConn:Disconnect()
        self.AutoHealConn = nil
    end
    
    self.AutoHealConn = RunService.Heartbeat:Connect(function()
        if not self.AutoHealActive or self.IsHealing then return end
        
        local char = LocalPlayer.Character
        if not char or (char:GetAttribute("Dead") == true) then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        
        local healthRatio = hum.Health / hum.MaxHealth
        if healthRatio <= self.AutoHealThreshold then
            local now = tick()
            if now - self.LastHealTick < 0.6 then return end
            self.IsHealing = true
            self.LastHealTick = now
            
            task.spawn(function()
                pcall(function()
                    -- Apply game MedicalSpeed (instant consume) & IncomingHealing boost
                    char:SetAttribute("MedicalSpeed", 1000)
                    char:SetAttribute("IncomingHealing", 5)
                    char:SetAttribute("UsingMedical", nil)
                    
                    local medTool = self:FindMedicalItem()
                    if medTool then
                        local previousTool = char:FindFirstChildOfClass("Tool")
                        if previousTool == medTool then previousTool = nil end
                        
                        -- Equip and activate medical item
                        hum:EquipTool(medTool)
                        task.wait(0.05)
                        medTool:Activate()
                        
                        -- Fire any remote inside the tool if present
                        for _, child in ipairs(medTool:GetChildren()) do
                            if child:IsA("RemoteEvent") then
                                pcall(function() child:FireServer() end)
                            end
                        end
                        
                        task.wait(0.15)
                        char:SetAttribute("UsingMedical", nil)
                        
                        -- Re-equip previous tool
                        if previousTool and previousTool.Parent then
                            hum:EquipTool(previousTool)
                        end
                    else
                        -- Fallback instant attribute healing if no medkit in bag
                        char:SetAttribute("Regen", 25)
                        task.wait(0.3)
                        if not self.SuperRegenActive then
                            char:SetAttribute("Regen", nil)
                        end
                    end
                end)
                self.IsHealing = false
            end)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.AutoHealConn) end
    if self.Notifications then
        self.Notifications:Show("Auto Heal", "Enabled - Threshold: " .. math.floor(self.AutoHealThreshold * 100) .. "% HP", 2)
    end
    print("[AUTO HEAL] Started - Threshold:", self.AutoHealThreshold * 100, "%")
end

function Player:StopAutoHeal()
    self.AutoHealActive = false
    if self.AutoHealConn then
        self.AutoHealConn:Disconnect()
        self.AutoHealConn = nil
    end
    self.IsHealing = false
    local char = LocalPlayer.Character
    if char and not self.SuperRegenActive then
        char:SetAttribute("MedicalSpeed", nil)
        char:SetAttribute("IncomingHealing", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Auto Heal", "Disabled", 2)
    end
    print("[AUTO HEAL] Disabled")
end

-- ============================================
-- INSTANT HEAL (RAPID HP RESTORATION WHEN BELOW THRESHOLD)
-- ============================================
function Player:StartInstantHeal(thresholdPercent)
    if thresholdPercent then
        self.InstantHealThreshold = thresholdPercent / 100
    end
    self.InstantHealActive = true
    
    if self.InstantHealConn then
        self.InstantHealConn:Disconnect()
        self.InstantHealConn = nil
    end
    
    self.InstantHealConn = RunService.Heartbeat:Connect(function()
        if not self.InstantHealActive then return end
        local char = LocalPlayer.Character
        if not char or (char:GetAttribute("Dead") == true) then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        
        if (hum.Health / hum.MaxHealth) <= self.InstantHealThreshold then
            pcall(function()
                char:SetAttribute("Regen", 100)
                char:SetAttribute("IncomingHealing", 10)
            end)
        elseif not self.SuperRegenActive then
            if char:GetAttribute("Regen") == 100 then
                char:SetAttribute("Regen", nil)
                char:SetAttribute("IncomingHealing", nil)
            end
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.InstantHealConn) end
    if self.Notifications then
        self.Notifications:Show("Instant Heal", "Enabled - Triggers at < " .. math.floor(self.InstantHealThreshold * 100) .. "% HP", 2)
    end
end

function Player:StopInstantHeal()
    self.InstantHealActive = false
    if self.InstantHealConn then
        self.InstantHealConn:Disconnect()
        self.InstantHealConn = nil
    end
    local char = LocalPlayer.Character
    if char and not self.SuperRegenActive then
        char:SetAttribute("Regen", nil)
        char:SetAttribute("IncomingHealing", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Instant Heal", "Disabled", 2)
    end
end

-- ============================================
-- SUPER HEALTH REGEN (PASSIVE REGEN ATTRIBUTE OVERRIDE)
-- ============================================
function Player:StartSuperRegen(regenRate)
    self.SuperRegenActive = true
    local rate = regenRate or 15
    
    if self.SuperRegenConn then
        self.SuperRegenConn:Disconnect()
        self.SuperRegenConn = nil
    end
    
    self.SuperRegenConn = RunService.Heartbeat:Connect(function()
        if not self.SuperRegenActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("Regen", rate)
            char:SetAttribute("IncomingHealing", 5)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.SuperRegenConn) end
    if self.Notifications then
        self.Notifications:Show("Super Regen", "Enabled - 60x Health Regeneration Rate", 2)
    end
end

function Player:StopSuperRegen()
    self.SuperRegenActive = false
    if self.SuperRegenConn then
        self.SuperRegenConn:Disconnect()
        self.SuperRegenConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Regen", nil)
        char:SetAttribute("IncomingHealing", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Super Regen", "Disabled", 2)
    end
end

-- ============================================
-- IRON SKIN / DAMAGE REDUCTION (GUARDIAN CLASS MECHANIC)
-- ============================================
function Player:StartDamageReduction(reductionPercent)
    self.DamageReductionActive = true
    self.DamageReductionValue = (reductionPercent or 75) / 100
    
    if self.DamageReductionConn then
        self.DamageReductionConn:Disconnect()
        self.DamageReductionConn = nil
    end
    
    self.DamageReductionConn = RunService.Heartbeat:Connect(function()
        if not self.DamageReductionActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("DamageReduction", self.DamageReductionValue)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.DamageReductionConn) end
    if self.Notifications then
        self.Notifications:Show("Iron Skin", "Enabled - Taking " .. math.floor((1 - self.DamageReductionValue) * 100) .. "% damage", 2)
    end
end

function Player:StopDamageReduction()
    self.DamageReductionActive = false
    if self.DamageReductionConn then
        self.DamageReductionConn:Disconnect()
        self.DamageReductionConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("DamageReduction", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Iron Skin", "Disabled", 2)
    end
end

-- ============================================
-- PSYCHIC FORCEFIELD SHIELD (PSYCHIC CLASS MECHANIC)
-- ============================================
function Player:StartPsychicShield(shieldHp)
    self.PsychicShieldActive = true
    local hp = shieldHp or 100
    
    if self.PsychicShieldConn then
        self.PsychicShieldConn:Disconnect()
        self.PsychicShieldConn = nil
    end
    
    self.PsychicShieldConn = RunService.Heartbeat:Connect(function()
        if not self.PsychicShieldActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("PsychicShieldHealth", hp)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.PsychicShieldConn) end
    if self.Notifications then
        self.Notifications:Show("Psychic Shield", "Enabled - Forcefield barrier active", 2)
    end
end

function Player:StopPsychicShield()
    self.PsychicShieldActive = false
    if self.PsychicShieldConn then
        self.PsychicShieldConn:Disconnect()
        self.PsychicShieldConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("PsychicShieldHealth", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Psychic Shield", "Disabled", 2)
    end
end

-- ============================================
-- STATUS IMMUNITY (VANGUARD CLASS MECHANIC)
-- ============================================
function Player:StartStatusImmunity()
    self.StatusImmunityActive = true
    
    if self.StatusImmunityConn then
        self.StatusImmunityConn:Disconnect()
        self.StatusImmunityConn = nil
    end
    
    self.StatusImmunityConn = RunService.Heartbeat:Connect(function()
        if not self.StatusImmunityActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("NegativeStatusResistance", 1.0)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.StatusImmunityConn) end
    if self.Notifications then
        self.Notifications:Show("Status Immunity", "Enabled - Immune to Bleed, Fire & Poison", 2)
    end
end

function Player:StopStatusImmunity()
    self.StatusImmunityActive = false
    if self.StatusImmunityConn then
        self.StatusImmunityConn:Disconnect()
        self.StatusImmunityConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("NegativeStatusResistance", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Status Immunity", "Disabled", 2)
    end
end

-- ============================================
-- INSTANT REVIVE & NO COOLDOWN (MEDIC CLASS MECHANIC)
-- ============================================
function Player:StartInstantRevive()
    self.InstantReviveActive = true
    
    if self.InstantReviveConn then
        self.InstantReviveConn:Disconnect()
        self.InstantReviveConn = nil
    end
    
    self.InstantReviveConn = RunService.Heartbeat:Connect(function()
        if not self.InstantReviveActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("ReviveSpeed", 1000)
            char:SetAttribute("ReviveCD", 0)
            char:SetAttribute("SelfReviveCD", 0)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.InstantReviveConn) end
    if self.Notifications then
        self.Notifications:Show("Instant Revive", "Enabled - Instant revive & 0s cooldown", 2)
    end
end

function Player:StopInstantRevive()
    self.InstantReviveActive = false
    if self.InstantReviveConn then
        self.InstantReviveConn:Disconnect()
        self.InstantReviveConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("ReviveSpeed", nil)
        char:SetAttribute("ReviveCD", nil)
        char:SetAttribute("SelfReviveCD", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Instant Revive", "Disabled", 2)
    end
end

-- ============================================
-- MEGA MAP REVEAL (EXPLORER CLASS MECHANIC)
-- ============================================
function Player:StartMegaMapReveal(multiplier)
    self.MegaMapRevealActive = true
    local mult = multiplier or 10
    
    if self.MegaMapRevealConn then
        self.MegaMapRevealConn:Disconnect()
        self.MegaMapRevealConn = nil
    end
    
    self.MegaMapRevealConn = RunService.Heartbeat:Connect(function()
        if not self.MegaMapRevealActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("RevealSize", mult)
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.MegaMapRevealConn) end
    if self.Notifications then
        self.Notifications:Show("Mega Reveal", "Enabled - Fog clears 10x faster", 2)
    end
end

function Player:StopMegaMapReveal()
    self.MegaMapRevealActive = false
    if self.MegaMapRevealConn then
        self.MegaMapRevealConn:Disconnect()
        self.MegaMapRevealConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("RevealSize", nil)
    end
    if self.Notifications then
        self.Notifications:Show("Mega Reveal", "Disabled", 2)
    end
end

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
function Player:SetupRespawnHandler()
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        
        if self.SpeedHackConn then
            self:StartSpeedHack(self.SpeedValue)
        end
        if self.FlyActive then
            self:StartFly(self.FlySpeed)
        end
        if self.AutoSprintActive then
            self:StartAutoSprint()
        end
        if self.NoclipActive then
            self:StartNoclip()
        end
        if self.InfJumpActive then
            self:StartInfJump()
        end
        if self.BhopActive then
            self:StartBunnyHop()
        end
        if self.NativeItemESPActive then
            self:StartNativeItemESP()
        end
        if self.InstantPromptActive then
            self:StartInstantProximityPrompt()
        end
        if self.AntiHungerActive then
            self:StartAntiHungerDrain()
        end
        if self.AutoHealActive then
            self:StartAutoHeal()
        end
        if self.InstantHealActive then
            self:StartInstantHeal()
        end
        if self.SuperRegenActive then
            self:StartSuperRegen()
        end
        if self.DamageReductionActive then
            self:StartDamageReduction(self.DamageReductionValue * 100)
        end
        if self.PsychicShieldActive then
            self:StartPsychicShield()
        end
        if self.StatusImmunityActive then
            self:StartStatusImmunity()
        end
        if self.InstantReviveActive then
            self:StartInstantRevive()
        end
        if self.MegaMapRevealActive then
            self:StartMegaMapReveal()
        end
    end)
end

-- ============================================
-- INIT
-- ============================================
function Player:Init(modules)
    self.Utils = modules.utils or modules.Utils
    self.Notifications = modules.notifications or modules.Notifications
    self.Config = modules.config or modules.Config
    self.Network = modules.network or modules.Network
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalWalkSpeed = humanoid.WalkSpeed
        end
    end
    
    self:SetupRespawnHandler()
    print("[PLAYER MODULE] Initialized with game dump integration")
    return self
end

return Player
