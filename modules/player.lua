-- =======================================================
-- PINATHUB - PLAYER MODULE
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Player = {}

-- State variables
Player.FlyActive = false
Player.FlyBV = nil
Player.FlyBG = nil
Player.AutoSprintActive = false
Player.AntiAFKConn = nil
Player.BhopActive = false
Player.BhopConn = nil
Player.NoclipActive = false
Player.NoclipLastCFrame = nil
Player.InfJumpActive = false
Player.OriginalWalkSpeed = nil
Player.SpeedHackConn = nil

-- ============================================
-- SPEED HACK
-- ============================================
function Player:StartSpeedHack(speedValue)
    if self.SpeedHackConn then
        self:StopSpeedHack()
    end
    
    self.SpeedHackConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedValue
        end
    end)
    
    if self.Utils then self.Utils:AddConnection(self.SpeedHackConn) end
    print("[SPEED HACK] Enabled - Speed:", speedValue)
end

function Player:StopSpeedHack()
    if self.SpeedHackConn then
        self.SpeedHackConn:Disconnect()
        self.SpeedHackConn = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and self.OriginalWalkSpeed then
            humanoid.WalkSpeed = self.OriginalWalkSpeed
        elseif humanoid then
            humanoid.WalkSpeed = 16
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
        
        -- Anti-teleport protection
        local currentCF = root.CFrame
        if self.NoclipLastCFrame then
            local delta = (currentCF.Position - self.NoclipLastCFrame.Position).Magnitude
            if delta > 8 then
                root.CFrame = self.NoclipLastCFrame
                currentCF = self.NoclipLastCFrame
            end
        end
        self.NoclipLastCFrame = currentCF
        
        -- Disable collision on all character parts
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
    
    -- Re-enable collision
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
function Player:StartFly(flySpeed)
    self:StopFly()
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    self.FlyBV = Instance.new("BodyVelocity")
    self.FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    self.FlyBV.Velocity = Vector3.new(0, 0, 0)
    self.FlyBV.Parent = rootPart
    
    self.FlyBG = Instance.new("BodyGyro")
    self.FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    self.FlyBG.P = 9000
    self.FlyBG.CFrame = Workspace.CurrentCamera.CFrame
    self.FlyBG.Parent = rootPart
    
    self.FlyActive = true
    self.FlySpeed = flySpeed or 50
    
    -- Movement connection
    self.FlyMoveConn = RunService.RenderStepped:Connect(function()
        if not self.FlyActive then return end
        
        local char = LocalPlayer.Character
        if not char or not char.Parent then
            self:StopFly()
            return
        end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local cam = Workspace.CurrentCamera
        local speed = self.FlySpeed
        local dir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
            dir = dir + cam.CFrame.LookVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
            dir = dir - cam.CFrame.LookVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
            dir = dir - cam.CFrame.RightVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
            dir = dir + cam.CFrame.RightVector 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
            dir = dir + Vector3.new(0, 1, 0) 
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
            dir = dir - Vector3.new(0, 1, 0) 
        end
        
        if dir.Magnitude > 0 then 
            dir = dir.Unit 
        end
        
        if self.FlyBV then 
            self.FlyBV.Velocity = dir * speed 
        end
        if self.FlyBG then 
            self.FlyBG.CFrame = cam.CFrame 
        end
    end)
    
    if self.Utils then 
        self.Utils:AddConnection(self.FlyMoveConn) 
    end
    
    print("[FLY] Enabled - Speed:", flySpeed)
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
    if self.FlyActive then
        print("[FLY] Speed updated to:", speed)
    end
end

-- ============================================
-- AUTO SPRINT
-- ============================================
function Player:StartAutoSprint()
    if self.AutoSprintActive then return end
    self.AutoSprintActive = true
    
    -- Hold Shift key
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
    end)
    
    print("[AUTO SPRINT] Enabled")
end

function Player:StopAutoSprint()
    if not self.AutoSprintActive then return end
    self.AutoSprintActive = false
    
    -- Release Shift key
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    end)
    
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
-- FULLBRIGHT
-- ============================================
local Lighting = game:GetService("Lighting")
local originalLighting = { stored = false }

function Player:StartFullbright()
    if not originalLighting.stored then
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.Ambient = Lighting.Ambient
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLighting.ClockTime = Lighting.ClockTime
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogStart = Lighting.FogStart
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.stored = true
    end
    
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    
    print("[FULLBRIGHT] Enabled")
end

function Player:StopFullbright()
    if originalLighting.stored then
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
    print("[FULLBRIGHT] Disabled")
end

-- ============================================
-- REMOVE FOG
-- ============================================
local originalFog = { stored = false }

function Player:StartRemoveFog()
    if not originalFog.stored then
        originalFog.FogEnd = Lighting.FogEnd
        originalFog.FogStart = Lighting.FogStart
        originalFog.stored = true
    end
    
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    -- Remove atmosphere fog
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        if originalFog.AtmDensity == nil then
            originalFog.AtmDensity = atm.Density
            originalFog.AtmHaze = atm.Haze
            originalFog.AtmGlare = atm.Glare
        end
        atm.Density = 0
        atm.Haze = 0
        atm.Glare = 0
    end
    
    print("[REMOVE FOG] Enabled")
end

function Player:StopRemoveFog()
    if originalFog.stored then
        Lighting.FogEnd = originalFog.FogEnd
        Lighting.FogStart = originalFog.FogStart
    end
    
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm and originalFog.AtmDensity ~= nil then
        atm.Density = originalFog.AtmDensity
        atm.Haze = originalFog.AtmHaze
        atm.Glare = originalFog.AtmGlare
        originalFog.AtmDensity = nil
        originalFog.AtmHaze = nil
        originalFog.AtmGlare = nil
    end
    
    print("[REMOVE FOG] Disabled")
end

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
function Player:SetupRespawnHandler()
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        
        -- Re-apply active features
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
    end)
    
    LocalPlayer.CharacterRemoving:Connect(function()
        if self.FlyActive then
            self:StopFly()
        end
        if self.AutoSprintActive then
            self:StopAutoSprint()
        end
        if self.NoclipActive then
            self:StopNoclip()
        end
    end)
end

-- ============================================
-- INIT
-- ============================================
function Player:Init(deps)
    self.Utils = deps.utils or deps.Utils
    self.Notifications = deps.notifications or deps.Notifications
    self.Config = deps.config or deps.Config
    
    -- Store original walk speed
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalWalkSpeed = humanoid.WalkSpeed
        end
    end
    
    -- Setup respawn handler
    self:SetupRespawnHandler()
    
    print("[PLAYER MODULE] Initialized")
    return self
end

return Player
