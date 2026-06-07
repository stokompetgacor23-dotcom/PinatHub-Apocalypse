 -- =======================================================
-- PINATHUB - UI MODULE (WINDUI SWING OBBY BRAINROT STYLE)
-- =======================================================
-- ONLY UI STYLE CHANGED, ALL FEATURES REMAIN INTACT
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.GuiVisible = true
UI.Window = nil

-- Load WindUI (Latest Version / Swing Obby Brainrot Style)
local function loadWindUI()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'))()
    end)
    return success and result or nil
end

-- Create logo (Swing Obby Brainrot Style)
function UI:CreateLogo()
    local player = LocalPlayer
    local UIS = UserInputService
    
    local logoGui = Instance.new("ScreenGui")
    logoGui.Name = "PinatHubLogo"
    logoGui.ResetOnSpawn = false
    logoGui.Parent = player:WaitForChild("PlayerGui", 5)
    
    local logoButton = Instance.new("ImageButton")
    logoButton.Name = "LogoButton"
    logoButton.Size = UDim2.new(0, 50, 0, 50)
    logoButton.Position = UDim2.new(0.5, -25, 0.5, -25)
    logoButton.BackgroundTransparency = 1
    logoButton.Image = "rbxassetid://118264723961739"
    logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
    logoButton.ScaleType = Enum.ScaleType.Fit
    logoButton.Parent = logoGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = logoButton
    
    local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
    local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)})
    
    logoButton.MouseEnter:Connect(function() hoverTween:Play() end)
    logoButton.MouseLeave:Connect(function() unhoverTween:Play() end)
    
    local draggingLogo = false
    local dragInputLogo, dragStartLogo, startPosLogo
    
    logoButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingLogo = true
            dragStartLogo = input.Position
            startPosLogo = logoButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingLogo = false
                end
            end)
        end
    end)
    
    logoButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInputLogo = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInputLogo and draggingLogo then
            local delta = input.Position - dragStartLogo
            local newPos = UDim2.new(startPosLogo.X.Scale, startPosLogo.X.Offset + delta.X, startPosLogo.Y.Scale, startPosLogo.Y.Offset + delta.Y)
            logoButton.Position = newPos
        end
    end)
    
    return logoGui, logoButton
end

-- Setup proximity prompt anti-delay (SAME)
-- Setup proximity prompt anti-delay (ENHANCED)
function UI:SetupProximityPromptAntiDelay()
    local proximityPromptActive = false
    local connections = {}
    
    local function enableProximityPromptAntiDelay()
        if proximityPromptActive then return end
        proximityPromptActive = true
        
        -- Instant set for existing ones
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
        
        -- Listen for new prompts
        table.insert(connections, workspace.DescendantAdded:Connect(function(v)
            if proximityPromptActive and v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end))

        -- Listen for shown prompts (to override script-set duration like Revive)
        local ProximityPromptService = game:GetService("ProximityPromptService")
        table.insert(connections, ProximityPromptService.PromptShown:Connect(function(prompt)
            if proximityPromptActive then
                prompt.HoldDuration = 0
            end
        end))

        -- Listen for hold begin (some scripts set duration here)
        table.insert(connections, ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
            if proximityPromptActive then
                prompt.HoldDuration = 0
            end
        end))
    end
    
    local function disableProximityPromptAntiDelay()
        proximityPromptActive = false
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        connections = {}
    end
    
    return enableProximityPromptAntiDelay, disableProximityPromptAntiDelay
end

-- ============================================
-- INIT FUNCTION (WITH BRAINROT UI STYLE)
-- ============================================
function UI:Init(modules)
    local WindUI = loadWindUI()
    if not WindUI then 
        print("Failed to load WindUI Library")
        return nil
    end
    
    -- Store dependencies (support multiple naming conventions)
    self.Config = modules.config or modules.Config
    self.Utils = modules.utils or modules.Utils
    self.ESP = modules.esp or modules.ESP
    self.Farm = modules.farm or modules.Farm
    self.Bring = modules.bring or modules.Bring
    self.Teleport = modules.teleport or modules.Teleport
    self.Network = modules.network or modules.Network
    self.Notifications = modules.notifications or modules.Notifications
    self.Player = modules.player or modules.Player
    self.AutoPickup = modules.autoPickup or modules.AutoPickup
    self.KillAura = modules.killaura or modules.KillAura
    
    if not self.Config then
        print("ERROR: Config module not found!")
        return nil
    end
    
    if not self.ESP then
        print("WARNING: ESP module not found! ESP features disabled.")
    end
    
    if not self.KillAura then
        print("WARNING: KillAura module not found! Kill Aura features disabled.")
    end
    
    -- Create Window (SWING OBBY BRAINROT STYLE - Only UI style changed)
    self.Window = WindUI:CreateWindow({
        Title = "PinatHub",
        Author = "@viunze on tiktok",
        Folder = "pinathub",
        Size = UDim2.fromOffset(500, 400),     -- More compact brainrot size
        Transparent = true,                     -- Brainrot transparent style
        Theme = "Dark",
        IsOpenButtonEnabled = false,
        User = {Enabled = true, Anonymous = true},
        UserEnabled = true,                     -- Brainrot user style
        HasOutline = true,                      -- Brainrot outline effect
        SideBarWidth = 150,
    })
    
    -- Optional: Window greeting / tag (if supported)
    if self.Window.SetGreeting then
        self.Window:SetGreeting("PinatHub", "Survive the Apocalypse")
    end
    
    if self.Notifications and self.Notifications.SetWindow then
        self.Notifications:SetWindow(self.Window)
    end
    
    -- Create Logo
    local logoGui, logoButton = self:CreateLogo()
    
    -- Setup Proximity Prompt Anti-Delay
    self.EnableProximityPrompt, self.DisableProximityPrompt = self:SetupProximityPromptAntiDelay()

    self.GuiVisible = true
    logoButton.MouseButton1Click:Connect(function()
        self.GuiVisible = not self.GuiVisible
        if self.Window then
            pcall(function()
                if self.GuiVisible then
                    self.Window:Open()
                else
                    self.Window:Minimize()
                end
            end)
        end
    end)
    
    -- Create Tabs (Keep all original tabs - NOTHING REMOVED)
    local InfoTab = self.Window:Tab({Title = "Info", Icon = "info"})
    local VisualsTab = self.Window:Tab({Title = "Visuals", Icon = "eye"})
    local PlayerTab = self.Window:Tab({Title = "Player", Icon = "user"})
    local CombatTab = self.Window:Tab({Title = "Combat", Icon = "swords"})
    local ExploitsTab = self.Window:Tab({Title = "Exploits", Icon = "zap"})
    local MiscTab = self.Window:Tab({Title = "Misc", Icon = "settings"})
    local CommunityTab = self.Window:Tab({Title = "Community", Icon = "users"})
    
    -- Build all sections (COMPLETELY UNCHANGED - All features preserved)
    self:BuildInfoTab(InfoTab)
    self:BuildVisualsTab(VisualsTab)
    self:BuildPlayerTab(PlayerTab)
    self:BuildCombatTab(CombatTab)
    self:BuildExploitsTab(ExploitsTab)
    self:BuildMiscTab(MiscTab)
    self:BuildCommunityTab(CommunityTab)
    
    self.Window:Open()
    print("UI initialized successfully with WindUI Swing Obby Brainrot Style!")
    
    if self.KillAura then
        print("[UI] KillAura module loaded successfully!")
    end
    
    -- Auto refresh ESP after UI loads
    task.spawn(function()
        task.wait(2)
        if self.ESP and self.ESP.RefreshAll then
            self.ESP:RefreshAll()
            print("[UI] ESP auto-refresh completed")
        end
    end)
    
    return self
end

-- ============================================
-- INFO TAB (COMPLETELY UNCHANGED)
-- ============================================
function UI:BuildInfoTab(tab)
    local config = self.Config
    if not config then
        local errorSection = tab:Section({ Title = "Error" })
        errorSection:Paragraph({ Title = "Configuration Error", Desc = "Config module not loaded properly!" })
        return
    end
    
    local supportedMaps = {}
    if config.GetSupportedMaps then
        supportedMaps = config:GetSupportedMaps()
    else
        supportedMaps = { { name = "Survive The Apocalypse" } }
    end
    
    local infoHeader = tab:Section({ Title = "PinatHub Information" })
    infoHeader:Paragraph({ Title = "Welcome to PinatHub!", Desc = "Created by: @viunze on TikTok" })
    infoHeader:Divider()
    
    local supportSection = tab:Section({ Title = "Supported Games (" .. #supportedMaps .. " Maps)" })
    for _, map in ipairs(supportedMaps) do
        supportSection:Paragraph({ Title = map.name, Desc = "" })
    end
end

-- ============================================
-- VISUALS TAB (FIXED - ADDED ALL CATEGORY TOGGLES)
-- ============================================
function UI:BuildVisualsTab(tab)
    local config = self.Config
    local esp = self.ESP
    
    if not config then return end
    
    local options = config:GetOptions()
    local crateOptions = config:GetCrateOptions()
    
    -- Global ESP Settings
    local globalSection = tab:Section({ Title = "Global ESP Settings" })
    
    globalSection:Toggle({ 
        Title = "Show Names (All)", 
        Value = false, 
        Callback = function(value)
            if esp then
                esp.MobOptions.Name = value
                esp.PlayerESPVars.Name = value
                esp.StructureESPVars.Name = value
                if crateOptions then crateOptions.Name = value end
                if esp.SetAllItemNames then
                    esp:SetAllItemNames(value)
                end
                esp:RefreshAll()
                print("[UI] Show Names (All):", value)
            end
        end 
    })
    
    globalSection:Toggle({ 
        Title = "Show Distance (All)", 
        Value = false, 
        Callback = function(value)
            if esp then
                esp.MobOptions.Distance = value
                esp.PlayerESPVars.Distance = value
                esp.StructureESPVars.Distance = value
                if crateOptions then crateOptions.Distance = value end
                if esp.SetAllItemDistances then
                    esp:SetAllItemDistances(value)
                end
                esp:RefreshAll()
                print("[UI] Show Distance (All):", value)
            end
        end 
    })
    
    -- Mob ESP
    local mobSection = tab:Section({ Title = "Mob ESP" })
    mobSection:Toggle({ Title = "Mob ESP", Value = false, Callback = function(value)
        if esp then
            esp.MobOptions.ESP = value
            esp:RefreshMobESP()
            if self.Notifications then 
                self.Notifications:Show("Mob ESP", value and "Enabled" or "Disabled", 1)
            end
        end
    end })
    mobSection:Toggle({ Title = "Mob Chams", Value = false, Callback = function(value)
        if esp then esp.MobOptions.Chams = value; esp:RefreshMobESP() end
    end })
    mobSection:Toggle({ Title = "Mob Names", Value = false, Callback = function(value)
        if esp then esp.MobOptions.Name = value; esp:RefreshMobESP() end
    end })
    mobSection:Toggle({ Title = "Mob Distance", Value = false, Callback = function(value)
        if esp then esp.MobOptions.Distance = value; esp:RefreshMobESP() end
    end })
    
    -- Player ESP
    local playerSection = tab:Section({ Title = "Player ESP" })
    playerSection:Toggle({ Title = "Player ESP", Value = false, Callback = function(value)
        if esp then esp.PlayerESPVars.ESP = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Player Chams", Value = false, Callback = function(value)
        if esp then esp.PlayerESPVars.Chams = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Player Names", Value = false, Callback = function(value)
        if esp then esp.PlayerESPVars.Name = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Player Distance", Value = false, Callback = function(value)
        if esp then esp.PlayerESPVars.Distance = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Show Health", Value = false, Callback = function(value)
        if esp then esp.PlayerESPVars.Health = value; esp:RefreshPlayerESP() end
    end })
    
    -- Structure ESP
    local structureSection = tab:Section({ Title = "Structure ESP" })
    structureSection:Toggle({ Title = "Structure ESP", Value = false, Callback = function(value)
        if esp then esp.StructureESPVars.ESP = value; esp:RefreshStructureESP() end
    end })
    structureSection:Toggle({ Title = "Structure Chams", Value = false, Callback = function(value)
        if esp then esp.StructureESPVars.Chams = value; esp:RefreshStructureESP() end
    end })
    structureSection:Toggle({ Title = "Structure Names", Value = false, Callback = function(value)
        if esp then esp.StructureESPVars.Name = value; esp:RefreshStructureESP() end
    end })
    structureSection:Toggle({ Title = "Structure Distance", Value = false, Callback = function(value)
        if esp then esp.StructureESPVars.Distance = value; esp:RefreshStructureESP() end
    end })
    
    -- Crates ESP
    local cratesSection = tab:Section({ Title = "Crates ESP" })
    cratesSection:Toggle({ Title = "Crates ESP", Value = false, Callback = function(value)
        if crateOptions then crateOptions.ESP = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    cratesSection:Toggle({ Title = "Crates Chams", Value = false, Callback = function(value)
        if crateOptions then crateOptions.Chams = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    cratesSection:Toggle({ Title = "Crates Names", Value = false, Callback = function(value)
        if crateOptions then crateOptions.Name = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    cratesSection:Toggle({ Title = "Crates Distance", Value = false, Callback = function(value)
        if crateOptions then crateOptions.Distance = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    
    -- Item ESP
    local itemSection = tab:Section({ Title = "Item ESP (Dropped Items)" })
    itemSection:Paragraph({ Title = "Item ESP Settings", Desc = "Enable ESP for items dropped on the ground" })
    itemSection:Divider()
    itemSection:Toggle({ Title = "All Items Chams", Value = false, Callback = function(value)
        if esp and esp.SetAllItemChams then esp:SetAllItemChams(value) end
    end })
    itemSection:Toggle({ Title = "All Items Names", Value = false, Callback = function(value)
        if esp and esp.SetAllItemNames then esp:SetAllItemNames(value) end
    end })
    itemSection:Toggle({ Title = "All Items Distance", Value = false, Callback = function(value)
        if esp and esp.SetAllItemDistances then esp:SetAllItemDistances(value) end
    end })
    itemSection:Divider()

    -- Category Specific Toggles
    if esp and esp.EspDefinitions then
        for _, def in ipairs(esp.EspDefinitions) do
            itemSection:Toggle({
                Title = def.displayName,
                Value = false,
                Callback = function(value)
                    if esp.SetItemCategoryEnabled then
                        esp:SetItemCategoryEnabled(def.key, value)
                    end
                end
            })
        end
    end
    
    -- ESP Max Distance
    local distanceSection = tab:Section({ Title = "ESP Distance Settings" })
    distanceSection:Slider({
        Title = "Max Distance",
        Value = { Min = 100, Max = 2000, Default = 500 },
        Callback = function(value)
            options.ESPMaxDistance = value
            if esp then esp.Options.ESPMaxDistance = value end
            if crateOptions then crateOptions.MaxDistance = value end
            if esp and esp.RefreshAll then esp:RefreshAll() end
        end
    })
    
    task.spawn(function()
        task.wait(1)
        if esp then esp:RefreshAll() end
    end)
end

-- ============================================
-- PLAYER TAB (COMPLETELY UNCHANGED)
-- ============================================
function UI:BuildPlayerTab(tab)
    local config = self.Config
    local playerModule = self.Player
    
    if not config then return end
    
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    
    local movementSection = tab:Section({ Title = "Movement" })
    
    movementSection:Toggle({ Title = "Speed Hack", Value = false, Callback = function(v) 
        toggles.SpeedHack = v
        if v then 
            if playerModule and playerModule.StartSpeedHack then 
                playerModule:StartSpeedHack(options.SpeedValue)
                if self.Notifications then self.Notifications:Show("Speed Hack", "Enabled - " .. options.SpeedValue .. " speed", 2) end
            end
        else 
            if playerModule and playerModule.StopSpeedHack then 
                playerModule:StopSpeedHack()
                if self.Notifications then self.Notifications:Show("Speed Hack", "Disabled", 2) end
            end
        end
    end })
    
    movementSection:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 120, Default = 50 }, Callback = function(v) 
        options.SpeedValue = v
        if toggles.SpeedHack and playerModule then
            playerModule:StartSpeedHack(v)
        end
    end })
    
    movementSection:Toggle({ Title = "Inf Jump", Value = false, Callback = function(v) 
        toggles.InfJump = v
        if v then 
            if playerModule then playerModule:StartInfJump() end
            if self.Notifications then self.Notifications:Show("Inf Jump", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopInfJump() end
            if self.Notifications then self.Notifications:Show("Inf Jump", "Disabled", 2) end
        end
    end })
    
    movementSection:Toggle({ Title = "NoClip", Value = false, Callback = function(v) 
        toggles.NoClip = v
        if v then 
            if playerModule then playerModule:StartNoclip() end
            if self.Notifications then self.Notifications:Show("NoClip", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopNoclip() end
            if self.Notifications then self.Notifications:Show("NoClip", "Disabled", 2) end
        end
    end })
    
    movementSection:Toggle({ Title = "Fly", Value = false, Callback = function(v) 
        toggles.Fly = v
        if v then 
            if playerModule then playerModule:StartFly(options.FlySpeed) end
            if self.Notifications then self.Notifications:Show("Fly", "Enabled - WASD to move, Space/Shift for up/down", 3) end
        else 
            if playerModule then playerModule:StopFly() end
            if self.Notifications then self.Notifications:Show("Fly", "Disabled", 2) end
        end
    end })
    
    movementSection:Slider({ Title = "Fly Speed", Value = { Min = 20, Max = 200, Default = 50 }, Callback = function(v) 
        options.FlySpeed = v
        if toggles.Fly and playerModule then
            playerModule:SetFlySpeed(v)
        end
    end })
    
    movementSection:Toggle({ Title = "Auto Sprint", Value = false, Callback = function(v) 
        toggles.AutoSprint = v
        if v then 
            if playerModule then playerModule:StartAutoSprint() end
            if self.Notifications then self.Notifications:Show("Auto Sprint", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopAutoSprint() end
            if self.Notifications then self.Notifications:Show("Auto Sprint", "Disabled", 2) end
        end
    end })
    
    movementSection:Toggle({ Title = "Bunny Hop", Value = false, Callback = function(v) 
        toggles.BunnyHop = v
        if v then 
            if playerModule then playerModule:StartBunnyHop() end
            if self.Notifications then self.Notifications:Show("Bunny Hop", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopBunnyHop() end
            if self.Notifications then self.Notifications:Show("Bunny Hop", "Disabled", 2) end
        end
    end })
end

-- ============================================
-- COMBAT TAB (COMPLETELY UNCHANGED - ALL FEATURES)
-- ============================================
function UI:BuildCombatTab(tab)
    local config = self.Config
    local killAura = self.KillAura
    local farm = self.Farm
    local notifications = self.Notifications
    
    if not config then return end
    
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    
    -- Kill Aura Section
    local killAuraSection = tab:Section({ Title = "Kill Aura" })
    
    killAuraSection:Toggle({ 
        Title = "Kill Aura", 
        Value = false, 
        Callback = function(v) 
            toggles.KillAura = v
            if v then 
                if killAura and killAura.Start then 
                    killAura:Start()
                    if notifications then 
                        notifications:Show("Kill Aura", "Enabled - Range: " .. (options.KillAuraRange or 6), 2) 
                    end
                elseif not killAura then
                    if notifications then notifications:Show("Kill Aura", "Module not loaded!", 2) end
                    print("[ERROR] KillAura module not available!")
                end
            else 
                if killAura and killAura.Stop then 
                    killAura:Stop()
                    if notifications then notifications:Show("Kill Aura", "Disabled", 2) end
                end
            end
        end 
    })
    
    killAuraSection:Slider({ 
        Title = "Aura Range", 
        Value = { Min = 3, Max = 25, Default = options.KillAuraRange or 6 }, 
        Callback = function(v) 
            options.KillAuraRange = v
            if killAura and killAura.SetRange then killAura:SetRange(v) end
            if notifications and toggles.KillAura then
                notifications:Show("Kill Aura Range", v .. " studs", 1)
            end
        end 
    })
    
    killAuraSection:Slider({ 
        Title = "Swing Rate", 
        Value = { Min = 0.1, Max = 2, Default = options.KillAuraSwingRate or 0.5, Decimals = 1 }, 
        Callback = function(v) 
            options.KillAuraSwingRate = v
            if killAura and killAura.SetSwingRate then killAura:SetSwingRate(v) end
        end 
    })
    
    killAuraSection:Dropdown({ 
        Title = "Target Priority", 
        Values = { "Nearest", "Lowest HP", "Highest HP" }, 
        Default = 1, 
        Callback = function(v) 
            options.KillAuraPriority = v
            if killAura and killAura.SetPriority then killAura:SetPriority(v) end
        end 
    })
    
    killAuraSection:Toggle({ 
        Title = "Auto-Equip Weapon", 
        Value = options.KillAuraAutoEquip or false, 
        Callback = function(v) 
            options.KillAuraAutoEquip = v
            if killAura and killAura.SetAutoEquip then killAura:SetAutoEquip(v) end
        end 
    })
    
    killAuraSection:Toggle({ 
        Title = "Show Target Indicator", 
        Value = options.KillAuraShowIndicator or true, 
        Callback = function(v) 
            options.KillAuraShowIndicator = v
            if killAura and killAura.SetShowIndicator then killAura:SetShowIndicator(v) end
        end 
    })
    
    killAuraSection:Toggle({ 
        Title = "Extended Range (+2 studs)", 
        Value = options.KillAuraExtendedRange or true, 
        Callback = function(v) 
            options.KillAuraExtendedRange = v
            if killAura and killAura.SetExtendedRange then killAura:SetExtendedRange(v) end
        end 
    })
    
    killAuraSection:Paragraph({ 
        Title = "Kill Aura Info", 
        Desc = "Kill Aura will automatically attack nearby zombies. A red line indicator will appear pointing to the target being attacked." 
    })
    
    killAuraSection:Divider()
    
    -- Auto Hunt Zombie Section
    local autoHuntSection = tab:Section({ Title = "Auto Hunt Zombie" })
    
    autoHuntSection:Toggle({ Title = "Auto Hunt", Value = false, Callback = function(v) 
        toggles.AutoHunt = v
        if v then 
            if farm and farm.StartAutoHunt then 
                farm:StartAutoHunt()
                if notifications then notifications:Show("Auto Hunt", "Enabled - Flying to zombies!", 2) end
            end
        else 
            if farm and farm.StopAutoHunt then 
                farm:StopAutoHunt()
                if notifications then notifications:Show("Auto Hunt", "Disabled", 2) end
            end
        end
    end })
    
    autoHuntSection:Slider({ Title = "Hunt Range", Value = { Min = 500, Max = 9999, Default = options.HuntRange or 9999 }, Callback = function(v) 
        options.HuntRange = v
        if farm then farm.HuntRange = v end
    end })
    
    autoHuntSection:Slider({ Title = "Fly Speed", Value = { Min = 50, Max = 300, Default = options.HuntFlySpeed or 120 }, Callback = function(v) 
        options.HuntFlySpeed = v
        if farm then farm.HuntFlySpeed = v end
    end })
    
    autoHuntSection:Slider({ Title = "Kill Range", Value = { Min = 10, Max = 50, Default = options.HuntKillRange or 25 }, Callback = function(v) 
        options.HuntKillRange = v
        if farm then farm.HuntKillRange = v end
    end })
    
    autoHuntSection:Slider({ Title = "Swing Speed", Value = { Min = 0.001, Max = 0.05, Default = options.HuntSwingSpeed or 0.010, Decimals = 3 }, Callback = function(v) 
        options.HuntSwingSpeed = v
        if farm then farm.HuntSwingSpeed = v end
    end })
    
    autoHuntSection:Slider({ Title = "Fly Height", Value = { Min = 3, Max = 15, Default = options.HuntFlyHeight or 7 }, Callback = function(v) 
        options.HuntFlyHeight = v
        if farm then farm.HuntFlyHeight = v end
    end })
    
    -- Aimbot Section
    local aimbotSection = tab:Section({ Title = "Aimbot" })
    
    aimbotSection:Toggle({ Title = "Aimbot", Value = false, Callback = function(v) 
        toggles.Aimbot = v
        if notifications then notifications:Show("Aimbot", v and "Enabled" or "Disabled", 2) end
    end })
    
    aimbotSection:Dropdown({ Title = "Target Mode", Values = { "Mobs", "Players", "Both" }, Default = 1, Callback = function(v) options.AimbotTarget = v end })
    aimbotSection:Dropdown({ Title = "Aim Part", Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }, Default = 1, Callback = function(v) options.AimbotPart = v end })
    aimbotSection:Dropdown({ Title = "Target Priority", Values = { "Distance", "FOV" }, Default = 1, Callback = function(v) options.AimbotPriority = v end })
    aimbotSection:Toggle({ Title = "Velocity Prediction", Value = false, Callback = function(v) toggles.AimbotPrediction = v end })
    aimbotSection:Toggle({ Title = "FOV Circle", Value = false, Callback = function(v) toggles.AimbotFOVCircle = v end })
    aimbotSection:Slider({ Title = "Aimbot Range", Value = { Min = 50, Max = 500, Default = options.AimbotRange or 200 }, Callback = function(v) options.AimbotRange = v end })
    aimbotSection:Slider({ Title = "Aimbot FOV", Value = { Min = 30, Max = 300, Default = options.AimbotFOV or 100 }, Callback = function(v) options.AimbotFOV = v end })
    aimbotSection:Slider({ Title = "Smoothness", Value = { Min = 0, Max = 1, Default = options.AimbotSmoothness or 0.3, Decimals = 1 }, Callback = function(v) options.AimbotSmoothness = v end })
end

-- ============================================
-- EXPLOITS TAB (COMPLETELY UNCHANGED)
-- ============================================
function UI:BuildExploitsTab(tab)
    local config = self.Config
    if not config then return end
    
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    local farm = self.Farm
    local autoPickup = self.AutoPickup
    local bring = self.Bring
    local network = self.Network
    local notifications = self.Notifications
    
    -- Auto Pickup Section
    local autoPickupSection = tab:Section({ Title = "Auto Pickup Item" })
    autoPickupSection:Toggle({ Title = "Auto Pickup", Value = false, Callback = function(v) 
        toggles.AutoPickup = v
        if v then 
            if autoPickup and autoPickup.Start then 
                autoPickup:Start(options, notifications)
            end
        else 
            if autoPickup and autoPickup.Stop then 
                autoPickup:Stop(notifications)
            end
        end
    end })
    autoPickupSection:Toggle({ Title = "Pickup All Items", Value = true, Callback = function(v) options.AutoPickupAll = v end })
    autoPickupSection:Slider({ Title = "Pickup Range", Value = { Min = 12, Max = 200, Default = options.AutoPickupRange or 50 }, Callback = function(v) options.AutoPickupRange = v end })
    autoPickupSection:Slider({ Title = "Pickup Delay", Value = { Min = 0.05, Max = 1, Default = options.AutoPickupDelay or 0.1, Decimals = 2 }, Callback = function(v) options.AutoPickupDelay = v end })
    
    -- Bring Pickup Section
    local bringSection = tab:Section({ Title = "Bring Pickup Item" })
    bringSection:Toggle({ Title = "Bring Pickup Item", Value = false, Callback = function(v) 
        toggles.BringPickupItem = v
        if v then 
            if bring and bring.Start then bring:Start(config, network, self.Utils) end
        else 
            if bring and bring.Stop then bring:Stop() end
        end
    end })
    bringSection:Toggle({ Title = "All Pickup Items", Value = false, Callback = function(v) toggles.BringAllPickup = v end })
    bringSection:Dropdown({ Title = "Sort Order", Values = { "Nearest First", "Farthest First", "Alphabetical", "Reverse Alphabetical" }, Default = 1, Callback = function(v) options.BringPickupSortOrder = v end })
    
    -- Auto Destroy Structure
    local autoDestroySection = tab:Section({ Title = "Auto Destroy Structure" })
    autoDestroySection:Toggle({ Title = "Auto Destroy (Barrel & Scrap Pile)", Value = false, Callback = function(v) 
        toggles.AutoDestroyStructure = v
        if v then 
            if farm and farm.StartAutoDestroy then 
                farm:StartAutoDestroy(notifications)
            end
        else 
            if farm and farm.StopAutoDestroy then 
                farm:StopAutoDestroy(notifications)
            end
        end
    end })
    
    -- Auto Hunt Fuel
    local autoHuntFuelSection = tab:Section({ Title = "Auto Hunt Fuel" })
    autoHuntFuelSection:Toggle({ Title = "Auto Hunt Fuel", Value = false, Callback = function(v) 
        toggles.AutoHuntFuel = v
        if v then 
            if farm and farm.StartAutoHuntFuel then 
                farm:StartAutoHuntFuel(notifications, options)
            end
        else 
            if farm and farm.StopAutoHuntFuel then 
                farm:StopAutoHuntFuel(notifications)
            end
        end
    end })
    autoHuntFuelSection:Slider({ Title = "Fuel Hunt Range", Value = { Min = 100, Max = 5000, Default = options.FuelHuntRange or 500 }, Callback = function(v) 
        options.FuelHuntRange = v
        if farm then farm.FuelHuntRange = v end
    end })

    -- Auto Open Crate Section
    local autoOpenCrateSection = tab:Section({ Title = "Auto Open Crate" })
    autoOpenCrateSection:Toggle({ Title = "Auto Open Crate", Value = false, Callback = function(v)
        toggles.AutoOpenCrate = v
        if v then
            if farm and farm.StartAutoOpenCrate then
                farm:StartAutoOpenCrate()
            end
        else
            if farm and farm.StopAutoOpenCrate then
                farm:StopAutoOpenCrate()
            end
        end
    end })
    autoOpenCrateSection:Slider({ Title = "Auto Open Range", Value = { Min = 5, Max = 50, Default = options.AutoOpenCrateRange or 15 }, Callback = function(v)
        options.AutoOpenCrateRange = v
    end })
end

-- ============================================
-- MISC TAB (COMPLETELY UNCHANGED)
-- ============================================
function UI:BuildMiscTab(tab)
    local config = self.Config
    local playerModule = self.Player
    local teleport = self.Teleport
    
    if not config then return end
    
    local toggles = config:GetToggles()
    local options = config:GetOptions()
    
    local utilitySection = tab:Section({ Title = "Utilities" })
    
    utilitySection:Toggle({ Title = "Anti-AFK", Value = true, Callback = function(v) 
        toggles.AntiAFK = v
        if v then 
            if playerModule then playerModule:StartAntiAFK() end
            if self.Notifications then self.Notifications:Show("Anti-AFK", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopAntiAFK() end
            if self.Notifications then self.Notifications:Show("Anti-AFK", "Disabled", 2) end
        end
    end })
    
    utilitySection:Toggle({ Title = "Fullbright", Value = false, Callback = function(v) 
        toggles.Fullbright = v
        if v then 
            if playerModule then playerModule:StartFullbright() end
            if self.Notifications then self.Notifications:Show("Fullbright", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopFullbright() end
            if self.Notifications then self.Notifications:Show("Fullbright", "Disabled", 2) end
        end
    end })
    
    utilitySection:Toggle({ Title = "Remove Fog", Value = false, Callback = function(v) 
        toggles.RemoveFog = v
        if v then 
            if playerModule then playerModule:StartRemoveFog() end
            if self.Notifications then self.Notifications:Show("Remove Fog", "Enabled", 2) end
        else 
            if playerModule then playerModule:StopRemoveFog() end
            if self.Notifications then self.Notifications:Show("Remove Fog", "Disabled", 2) end
        end
    end })
    
    -- Proximity Prompt Section
    local proximitySection = tab:Section({ Title = "ProximityPrompt" })
    proximitySection:Toggle({ Title = "Anti Delay ProximityPrompt", Value = false, Callback = function(v) 
        toggles.ProximityPromptAntiDelay = v
        if v then
            if self.EnableProximityPrompt then self.EnableProximityPrompt() end
        else
            if self.DisableProximityPrompt then self.DisableProximityPrompt() end
        end
        if self.Notifications then self.Notifications:Show("ProximityPrompt", v and "Anti Delay Enabled" or "Anti Delay Disabled", 2) end
    end })
    
    -- FPS Unlock
    local fpsSection = tab:Section({ Title = "Performance" })
    fpsSection:Toggle({ Title = "Unlock FPS", Value = false, Callback = function(v)
        toggles.FPSUnlock = v
        if v then
            setfpscap(options.FPSCap or 144)
            if self.Notifications then self.Notifications:Show("FPS Unlock", "Enabled - " .. (options.FPSCap or 144) .. " FPS", 2) end
        else
            setfpscap(60)
            if self.Notifications then self.Notifications:Show("FPS Unlock", "Disabled - Back to 60 FPS", 2) end
        end
    end })
    fpsSection:Slider({ Title = "FPS Cap", Value = { Min = 60, Max = 240, Default = options.FPSCap or 144 }, Callback = function(v)
        options.FPSCap = v
        if toggles.FPSUnlock then setfpscap(v) end
    end })
    
    -- Server Tools
    local serverSection = tab:Section({ Title = "Server Tools" })
    serverSection:Button({ Title = "Server Hop", Callback = function() if teleport and teleport.ServerHop then teleport:ServerHop() end end })
    serverSection:Button({ Title = "Rejoin Server", Callback = function() if teleport and teleport.Rejoin then teleport:Rejoin() end end })
end

-- ============================================
-- COMMUNITY TAB (COMPLETELY UNCHANGED)
-- ============================================
function UI:BuildCommunityTab(tab)
    local notifications = self.Notifications
    
    local whatsappSection = tab:Section({ Title = "WhatsApp Group" })
    whatsappSection:Button({ Title = "Join WhatsApp Group", Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/Cxr7poqqID6Ha6C2MfFOMU")
            if notifications then notifications:Show("Success", "WhatsApp link copied to clipboard!", 3) end
        else
            if notifications then notifications:Show("Error", "Clipboard not supported!", 2) end
        end
    end })
    
    local discordSection = tab:Section({ Title = "Discord Server" })
    discordSection:Button({ Title = "Join Discord Server", Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eDbaHKEf7G")
            if notifications then notifications:Show("Success", "Discord link copied to clipboard!", 3) end
        else
            if notifications then notifications:Show("Error", "Clipboard not supported!", 2) end
        end
    end })
    
    local tiktokSection = tab:Section({ Title = "TikTok" })
    tiktokSection:Button({ Title = "Follow @viunze on TikTok", Callback = function()
        if setclipboard then
            setclipboard("https://www.tiktok.com/@viunze")
            if notifications then notifications:Show("Success", "TikTok link copied to clipboard!", 3) end
        else
            if notifications then notifications:Show("Error", "Clipboard not supported!", 2) end
        end
    end })
end

return UI
