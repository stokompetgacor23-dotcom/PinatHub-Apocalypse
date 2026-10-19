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
    self.Teleport = modules.teleport or modules.Teleport
    self.Network = modules.network or modules.Network
    self.Notifications = modules.notifications or modules.Notifications
    self.Player = modules.player or modules.Player
    self.AutoPickup = modules.autoPickup or modules.AutoPickup
    self.KillAura = modules.killaura or modules.KillAura
    self.WeaponMods = modules.weaponMods or modules.WeaponMods
    self.FakeClass = modules.fakeClass or modules.FakeClass
    
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
    local crateOptions = (config.GetCrateOptions and config:GetCrateOptions()) or (esp and esp.CrateOptions)
    
    -- Global ESP Settings
    local globalSection = tab:Section({ Title = "Global ESP Settings" })
    
    globalSection:Toggle({ 
        Title = "Show Names (All)", 
        Value = true, 
        Callback = function(value)
            if esp then
                esp.MobOptions.Name = value
                esp.PlayerESPVars.Name = value
                esp.StructureESPVars.Name = value
                esp.CrateOptions.Name = value
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
        Value = true, 
        Callback = function(value)
            if esp then
                esp.MobOptions.Distance = value
                esp.PlayerESPVars.Distance = value
                esp.StructureESPVars.Distance = value
                esp.CrateOptions.Distance = value
                if crateOptions then crateOptions.Distance = value end
                if esp.SetAllItemDistances then
                    esp:SetAllItemDistances(value)
                end
                esp:RefreshAll()
                print("[UI] Show Distance (All):", value)
            end
        end 
    })

    globalSection:Toggle({ 
        Title = "Show Chams (All)", 
        Value = true, 
        Callback = function(value)
            if esp then
                esp.MobOptions.Chams = value
                esp.PlayerESPVars.Chams = value
                esp.StructureESPVars.Chams = value
                esp.CrateOptions.Chams = value
                if crateOptions then crateOptions.Chams = value end
                if esp.SetAllItemChams then
                    esp:SetAllItemChams(value)
                end
                esp:RefreshAll()
                print("[UI] Show Chams (All):", value)
            end
        end 
    })
    
    -- Mob ESP
    local mobSection = tab:Section({ Title = "Mob ESP" })
    mobSection:Toggle({ Title = "Mob ESP", Value = false, Callback = function(value)
        if esp then
            esp.MobOptions.ESP = value
            if value then
                esp.MobOptions.Name = true
                esp.MobOptions.Distance = true
                esp.MobOptions.Chams = true
            end
            esp:RefreshMobESP()
            if self.Notifications then 
                self.Notifications:Show("Mob ESP", value and "Enabled" or "Disabled", 1)
            end
        end
    end })
    mobSection:Toggle({ Title = "Mob Chams", Value = true, Callback = function(value)
        if esp then esp.MobOptions.Chams = value; esp:RefreshMobESP() end
    end })
    mobSection:Toggle({ Title = "Mob Names", Value = true, Callback = function(value)
        if esp then esp.MobOptions.Name = value; esp:RefreshMobESP() end
    end })
    mobSection:Toggle({ Title = "Mob Distance", Value = true, Callback = function(value)
        if esp then esp.MobOptions.Distance = value; esp:RefreshMobESP() end
    end })
    
    -- Player ESP
    local playerSection = tab:Section({ Title = "Player ESP" })
    playerSection:Toggle({ Title = "Player ESP", Value = false, Callback = function(value)
        if esp then
            esp.PlayerESPVars.ESP = value
            if value then
                esp.PlayerESPVars.Name = true
                esp.PlayerESPVars.Distance = true
                esp.PlayerESPVars.Health = true
                esp.PlayerESPVars.Chams = true
            end
            esp:RefreshPlayerESP()
            if self.Notifications then
                self.Notifications:Show("Player ESP", value and "Enabled" or "Disabled", 1)
            end
        end
    end })
    playerSection:Toggle({ Title = "Player Chams", Value = true, Callback = function(value)
        if esp then esp.PlayerESPVars.Chams = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Player Names", Value = true, Callback = function(value)
        if esp then esp.PlayerESPVars.Name = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Player Distance", Value = true, Callback = function(value)
        if esp then esp.PlayerESPVars.Distance = value; esp:RefreshPlayerESP() end
    end })
    playerSection:Toggle({ Title = "Show Health", Value = true, Callback = function(value)
        if esp then esp.PlayerESPVars.Health = value; esp:RefreshPlayerESP() end
    end })
    
    -- Structure ESP
    local structureSection = tab:Section({ Title = "Structure ESP" })
    structureSection:Toggle({ Title = "Structure ESP", Value = false, Callback = function(value)
        if esp then
            esp.StructureESPVars.ESP = value
            if value then
                esp.StructureESPVars.Name = true
                esp.StructureESPVars.Distance = true
                esp.StructureESPVars.Chams = true
            end
            esp:RefreshStructureESP()
            if self.Notifications then
                self.Notifications:Show("Structure ESP", value and "Enabled" or "Disabled", 1)
            end
        end
    end })
    structureSection:Toggle({ Title = "Structure Chams", Value = true, Callback = function(value)
        if esp then esp.StructureESPVars.Chams = value; esp:RefreshStructureESP() end
    end })
    structureSection:Toggle({ Title = "Structure Names", Value = true, Callback = function(value)
        if esp then esp.StructureESPVars.Name = value; esp:RefreshStructureESP() end
    end })
    structureSection:Toggle({ Title = "Structure Distance", Value = true, Callback = function(value)
        if esp then esp.StructureESPVars.Distance = value; esp:RefreshStructureESP() end
    end })
    
    -- Crates ESP
    local cratesSection = tab:Section({ Title = "Crates ESP" })
    cratesSection:Toggle({ Title = "Crates ESP", Value = false, Callback = function(value)
        if esp then
            esp.CrateOptions.ESP = value
            if value then
                esp.CrateOptions.Name = true
                esp.CrateOptions.Distance = true
                esp.CrateOptions.Chams = true
            end
        end
        if crateOptions then
            crateOptions.ESP = value
            if value then
                crateOptions.Name = true
                crateOptions.Distance = true
                crateOptions.Chams = true
            end
        end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
        if self.Notifications then
            self.Notifications:Show("Crates ESP", value and "Enabled" or "Disabled", 1)
        end
    end })
    cratesSection:Toggle({ Title = "Crates Chams", Value = true, Callback = function(value)
        if esp then esp.CrateOptions.Chams = value end
        if crateOptions then crateOptions.Chams = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    cratesSection:Toggle({ Title = "Crates Names", Value = true, Callback = function(value)
        if esp then esp.CrateOptions.Name = value end
        if crateOptions then crateOptions.Name = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    cratesSection:Toggle({ Title = "Crates Distance", Value = true, Callback = function(value)
        if esp then esp.CrateOptions.Distance = value end
        if crateOptions then crateOptions.Distance = value end
        if esp and esp.RefreshCrateESP then esp:RefreshCrateESP() end
    end })
    
    -- Item ESP
    local itemSection = tab:Section({ Title = "Item ESP (Dropped Items)" })
    itemSection:Paragraph({ Title = "Item ESP Settings", Desc = "Enable ESP for items dropped on the ground" })
    itemSection:Divider()
    itemSection:Toggle({ Title = "All Items ESP (Master)", Value = false, Callback = function(value)
        if esp and esp.SetAllItemsEnabled then esp:SetAllItemsEnabled(value) end
        if self.Notifications then self.Notifications:Show("All Items ESP", value and "Enabled - All Ground Items ON" or "Disabled", 2) end
    end })
    itemSection:Toggle({ Title = "All Items Chams", Value = true, Callback = function(value)
        if esp and esp.SetAllItemChams then esp:SetAllItemChams(value) end
    end })
    itemSection:Toggle({ Title = "All Items Names", Value = true, Callback = function(value)
        if esp and esp.SetAllItemNames then esp:SetAllItemNames(value) end
    end })
    itemSection:Toggle({ Title = "All Items Distance", Value = true, Callback = function(value)
        if esp and esp.SetAllItemDistances then esp:SetAllItemDistances(value) end
    end })
    itemSection:Toggle({ Title = "Item Tier Colors (Game Rarity)", Value = false, Callback = function(value)
        if config.SetToggle then config:SetToggle("ItemTierColors", value) end
        if esp and esp.RefreshAll then esp:RefreshAll() end
        if self.Notifications then self.Notifications:Show("Item Tier Colors", value and "Enabled - Rarity Colors ON" or "Disabled", 2) end
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
                    if self.Notifications then
                        self.Notifications:Show(def.displayName, value and "Enabled" or "Disabled", 1)
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

    local survivalSection = tab:Section({ Title = "Survival & Game Modifiers" })
    
    survivalSection:Toggle({ Title = "Anti-Hunger Drain", Value = false, Callback = function(v)
        toggles.AntiHungerDrain = v
        if v then
            if playerModule and playerModule.StartAntiHungerDrain then playerModule:StartAntiHungerDrain() end
            if self.Notifications then self.Notifications:Show("Anti Hunger", "Enabled - Hunger drain frozen!", 2) end
        else
            if playerModule and playerModule.StopAntiHungerDrain then playerModule:StopAntiHungerDrain() end
            if self.Notifications then self.Notifications:Show("Anti Hunger", "Disabled", 2) end
        end
    end })
    
    survivalSection:Toggle({ Title = "Instant Proximity Prompts (Fast Use)", Value = false, Callback = function(v)
        toggles.InstantProximityPrompt = v
        if v then
            if playerModule and playerModule.StartInstantProximityPrompt then playerModule:StartInstantProximityPrompt() end
            if self.Notifications then self.Notifications:Show("Proximity Speed", "Enabled (1000x speed)", 2) end
        else
            if playerModule and playerModule.StopInstantProximityPrompt then playerModule:StopInstantProximityPrompt() end
            if self.Notifications then self.Notifications:Show("Proximity Speed", "Disabled", 2) end
        end
    end })

    -- ============================================
    -- AUTO HEALING & DEFENSE SUITE (GAME DUMP ATTRIBUTES)
    -- ============================================
    local healingSection = tab:Section({ Title = "Auto Healing & Defense (Game Dump Structure)" })
    healingSection:Paragraph({
        Title = "Game Engine Health & Shield Suite",
        Desc = "Uses native game attributes (MedicalSpeed, IncomingHealing, Regen, DamageReduction, PsychicShieldHealth, NegativeStatusResistance, ReviveSpeed) for automatic survival."
    })
    
    healingSection:Toggle({
        Title = "Auto Heal Self (Medical Items)",
        Value = false,
        Callback = function(v)
            toggles.AutoHeal = v
            if v then
                if playerModule and playerModule.StartAutoHeal then
                    playerModule:StartAutoHeal(options.AutoHealThreshold or 50)
                end
            else
                if playerModule and playerModule.StopAutoHeal then
                    playerModule:StopAutoHeal()
                end
            end
        end
    })
    
    healingSection:Slider({
        Title = "Auto Heal Threshold (%)",
        Value = { Min = 10, Max = 90, Default = options.AutoHealThreshold or 50 },
        Callback = function(v)
            options.AutoHealThreshold = v
            if toggles.AutoHeal and playerModule and playerModule.StartAutoHeal then
                playerModule:StartAutoHeal(v)
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Instant Health Snap (< Threshold)",
        Value = false,
        Callback = function(v)
            toggles.InstantHeal = v
            if v then
                if playerModule and playerModule.StartInstantHeal then
                    playerModule:StartInstantHeal(options.InstantHealThreshold or 40)
                end
            else
                if playerModule and playerModule.StopInstantHeal then
                    playerModule:StopInstantHeal()
                end
            end
        end
    })
    
    healingSection:Slider({
        Title = "Instant Heal Threshold (%)",
        Value = { Min = 10, Max = 90, Default = options.InstantHealThreshold or 40 },
        Callback = function(v)
            options.InstantHealThreshold = v
            if toggles.InstantHeal and playerModule and playerModule.StartInstantHeal then
                playerModule:StartInstantHeal(v)
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Super Health Regen (60x Regen Rate)",
        Value = false,
        Callback = function(v)
            toggles.SuperRegen = v
            if v then
                if playerModule and playerModule.StartSuperRegen then
                    playerModule:StartSuperRegen(options.SuperRegenRate or 15)
                end
            else
                if playerModule and playerModule.StopSuperRegen then
                    playerModule:StopSuperRegen()
                end
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Iron Skin (-75% Damage Taken)",
        Value = false,
        Callback = function(v)
            toggles.DamageReduction = v
            if v then
                if playerModule and playerModule.StartDamageReduction then
                    playerModule:StartDamageReduction(options.DamageReductionPercent or 75)
                end
            else
                if playerModule and playerModule.StopDamageReduction then
                    playerModule:StopDamageReduction()
                end
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Psychic Forcefield Shield",
        Value = false,
        Callback = function(v)
            toggles.PsychicShield = v
            if v then
                if playerModule and playerModule.StartPsychicShield then
                    playerModule:StartPsychicShield(100)
                end
            else
                if playerModule and playerModule.StopPsychicShield then
                    playerModule:StopPsychicShield()
                end
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Negative Status Immunity (Fire/Bleed/Poison)",
        Value = false,
        Callback = function(v)
            toggles.StatusImmunity = v
            if v then
                if playerModule and playerModule.StartStatusImmunity then
                    playerModule:StartStatusImmunity()
                end
            else
                if playerModule and playerModule.StopStatusImmunity then
                    playerModule:StopStatusImmunity()
                end
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Instant Teammate Revive (0s Cooldown)",
        Value = false,
        Callback = function(v)
            toggles.InstantRevive = v
            if v then
                if playerModule and playerModule.StartInstantRevive then
                    playerModule:StartInstantRevive()
                end
            else
                if playerModule and playerModule.StopInstantRevive then
                    playerModule:StopInstantRevive()
                end
            end
        end
    })
    
    healingSection:Toggle({
        Title = "Mega Fog Map Reveal (10x Area)",
        Value = false,
        Callback = function(v)
            toggles.MegaMapReveal = v
            if v then
                if playerModule and playerModule.StartMegaMapReveal then
                    playerModule:StartMegaMapReveal(options.MegaMapRevealSize or 10)
                end
            else
                if playerModule and playerModule.StopMegaMapReveal then
                    playerModule:StopMegaMapReveal()
                end
            end
        end
    })

    -- ============================================
    -- FAKE CLASS & PERKS SIMULATOR (GAME ENGINE STRUCTURE)
    -- ============================================
    local fakeClass = self.FakeClass
    local classSection = tab:Section({ Title = "Fake Class & Perks (Game Dump Structure)" })
    classSection:Paragraph({
        Title = "Game Class & Perk Simulator",
        Desc = "Applies real-time stats, abilities, and perks of all 24 classes directly from ReplicatedStorage.GameInfo.Classes & Perks, or activate the GOD HYBRID (all classes combined)."
    })
    
    local classList = (config and config.Classes) or (fakeClass and fakeClass.ClassList) or {"GOD HYBRID"}
    local perkList = (config and config.Perks) or (fakeClass and fakeClass.PerkList) or {"Specialist"}
    
    classSection:Dropdown({
        Title = "Select Class",
        Values = classList,
        Default = 1,
        Callback = function(v)
            options.SelectedClass = v
            if toggles.FakeClass and fakeClass then
                fakeClass:ApplyClass(v, options.ClassLevel)
            end
        end
    })
    
    classSection:Slider({
        Title = "Class Level",
        Value = { Min = 1, Max = 3, Default = options.ClassLevel or 3 },
        Callback = function(v)
            options.ClassLevel = v
            if toggles.FakeClass and fakeClass then
                fakeClass:ApplyClass(options.SelectedClass, v)
            end
        end
    })
    
    classSection:Toggle({
        Title = "Apply Fake Class & Stats",
        Value = false,
        Callback = function(v)
            toggles.FakeClass = v
            if v then
                if fakeClass then
                    fakeClass:ApplyClass(options.SelectedClass, options.ClassLevel)
                end
                if self.Notifications then
                    self.Notifications:Show("Fake Class", "Applied: " .. (options.SelectedClass or "GOD HYBRID") .. " (Lvl " .. (options.ClassLevel or 3) .. ")", 2)
                end
            else
                if fakeClass then
                    fakeClass:RemoveClass()
                end
                if self.Notifications then
                    self.Notifications:Show("Fake Class", "Removed", 2)
                end
            end
        end
    })
    
    classSection:Toggle({
        Title = "Force Max Class Level 3",
        Value = false,
        Callback = function(v)
            toggles.ForceMaxClassLevel = v
            if fakeClass then
                fakeClass.ForceMaxLevelActive = v
                if v then
                    LocalPlayer:SetAttribute("ClassLevel", 3)
                end
            end
            if self.Notifications then
                self.Notifications:Show("Max Level 3", v and "Enabled - Drone Self-Revive & Crafting Tier 3 Unlocked" or "Disabled", 2)
            end
        end
    })
    
    classSection:Divider()
    
    classSection:Dropdown({
        Title = "Select Perk",
        Values = perkList,
        Default = 1,
        Callback = function(v)
            options.SelectedPerk = v
            if toggles.PerkBypass and fakeClass then
                fakeClass:ApplyPerk(v)
            end
        end
    })
    
    classSection:Toggle({
        Title = "Apply Perk Bypass",
        Value = false,
        Callback = function(v)
            toggles.PerkBypass = v
            if v then
                if fakeClass then
                    fakeClass:ApplyPerk(options.SelectedPerk)
                end
                if self.Notifications then
                    self.Notifications:Show("Perk Bypass", "Applied: " .. (options.SelectedPerk or "Specialist"), 2)
                end
            else
                if fakeClass then
                    fakeClass:RemovePerk()
                end
                if self.Notifications then
                    self.Notifications:Show("Perk Bypass", "Removed", 2)
                end
            end
        end
    })
    
    classSection:Toggle({
        Title = "All Perks Active (God Perks)",
        Value = false,
        Callback = function(v)
            toggles.AllPerksActive = v
            if v then
                if fakeClass then
                    fakeClass:ApplyAllPerks()
                end
                if self.Notifications then
                    self.Notifications:Show("All Perks Active", "Enabled - All 21 Perk Passives Applied!", 2)
                end
            else
                if fakeClass then
                    fakeClass:RemoveAllPerks()
                end
                if self.Notifications then
                    self.Notifications:Show("All Perks Active", "Disabled", 2)
                end
            end
        end
    })
    
    -- ============================================
    -- GAME MECHANICS BYPASSES (INTERNAL ENGINE BYPASSES)
    -- ============================================
    local bypassSection = tab:Section({ Title = "Game Mechanics Bypasses" })
    bypassSection:Paragraph({
        Title = "Internal Engine Bypasses",
        Desc = "Overrides game attributes to bypass cooldowns, mob slowdowns, hitbox hit registers, and action lockouts."
    })
    
    bypassSection:Toggle({
        Title = "Infinite Ammo (Bullet Preservation)",
        Value = false,
        Callback = function(v)
            toggles.InfiniteAmmo = v
            if v then
                if fakeClass then fakeClass:StartInfiniteAmmo() end
                if self.Notifications then self.Notifications:Show("Infinite Ammo", "Enabled - BulletPreserveChance = 1.0", 2) end
            else
                if fakeClass then fakeClass:StopInfiniteAmmo() end
                if self.Notifications then self.Notifications:Show("Infinite Ammo", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Toggle({
        Title = "Backpack Unlocker (No Action Lock)",
        Value = false,
        Callback = function(v)
            toggles.BackpackUnlocker = v
            if v then
                if fakeClass then fakeClass:StartBackpackUnlocker() end
                if self.Notifications then self.Notifications:Show("Backpack Unlock", "Enabled - Swap weapons & items freely!", 2) end
            else
                if fakeClass then fakeClass:StopBackpackUnlocker() end
                if self.Notifications then self.Notifications:Show("Backpack Unlock", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Toggle({
        Title = "Anti-Slowdown (Run While Healing & No Mob Drag)",
        Value = false,
        Callback = function(v)
            toggles.AntiSlowdown = v
            if v then
                if fakeClass then fakeClass:StartAntiSlowdown() end
                if self.Notifications then self.Notifications:Show("Anti-Slowdown", "Enabled - No zombie claw drag & heal sprint", 2) end
            else
                if fakeClass then fakeClass:StopAntiSlowdown() end
                if self.Notifications then self.Notifications:Show("Anti-Slowdown", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Toggle({
        Title = "Untouchable (Godmode Melee Iframes)",
        Value = false,
        Callback = function(v)
            toggles.Untouchable = v
            if v then
                if fakeClass then fakeClass:StartUntouchable() end
                if self.Notifications then self.Notifications:Show("Untouchable", "Enabled - HitboxService attacks pass through!", 2) end
            else
                if fakeClass then fakeClass:StopUntouchable() end
                if self.Notifications then self.Notifications:Show("Untouchable", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Toggle({
        Title = "Untargetable (Mob Blindness)",
        Value = false,
        Callback = function(v)
            toggles.Untargetable = v
            if v then
                if fakeClass then fakeClass:StartUntargetable() end
                if self.Notifications then self.Notifications:Show("Untargetable", "Enabled - Zombies & Turrets ignore you", 2) end
            else
                if fakeClass then fakeClass:StopUntargetable() end
                if self.Notifications then self.Notifications:Show("Untargetable", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Toggle({
        Title = "Super Telekinesis Drag Range",
        Value = false,
        Callback = function(v)
            toggles.SuperDrag = v
            if v then
                if fakeClass then fakeClass:StartSuperDrag(options.SuperDragRange) end
                if self.Notifications then self.Notifications:Show("Super Drag", "Enabled - Drag objects across the map!", 2) end
            else
                if fakeClass then fakeClass:StopSuperDrag() end
                if self.Notifications then self.Notifications:Show("Super Drag", "Disabled", 2) end
            end
        end
    })
    
    bypassSection:Slider({
        Title = "Drag Range (Studs)",
        Value = { Min = 50, Max = 1000, Default = options.SuperDragRange or 500 },
        Callback = function(v)
            options.SuperDragRange = v
            if toggles.SuperDrag and fakeClass then
                fakeClass:StartSuperDrag(v)
            end
        end
    })
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

    killAuraSection:Dropdown({ 
        Title = "Target Mode", 
        Values = { "Mobs", "Players", "Both" }, 
        Default = 1, 
        Callback = function(v) 
            options.KillAuraTargetMode = v
            if killAura and killAura.SetTargetMode then killAura:SetTargetMode(v) end
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

    -- Weapon Mods Section (Game Stats Engine)
    local weaponMods = self.WeaponMods
    local gunModSection = tab:Section({ Title = "Gun Modifications (Stats & Engine)" })
    gunModSection:Paragraph({
        Title = "Game Stat Modifiers",
        Desc = "Applies real-time modifiers to current equipped and inventory firearms using game Stats configuration."
    })
    
    gunModSection:Toggle({ Title = "No Recoil", Value = false, Callback = function(v)
        toggles.NoRecoil = v
        if v then
            if weaponMods and weaponMods.StartNoRecoil then weaponMods:StartNoRecoil() end
            if notifications then notifications:Show("No Recoil", "Enabled", 2) end
        else
            if weaponMods and weaponMods.StopNoRecoil then weaponMods:StopNoRecoil() end
            if notifications then notifications:Show("No Recoil", "Disabled", 2) end
        end
    end })
    
    gunModSection:Toggle({ Title = "No Spread", Value = false, Callback = function(v)
        toggles.NoSpread = v
        if v then
            if weaponMods and weaponMods.StartNoSpread then weaponMods:StartNoSpread() end
            if notifications then notifications:Show("No Spread", "Enabled - Laser accuracy!", 2) end
        else
            if weaponMods and weaponMods.StopNoSpread then weaponMods:StopNoSpread() end
            if notifications then notifications:Show("No Spread", "Disabled", 2) end
        end
    end })
    
    gunModSection:Toggle({ Title = "Rapid Fire", Value = false, Callback = function(v)
        toggles.RapidFire = v
        if v then
            if weaponMods and weaponMods.StartRapidFire then weaponMods:StartRapidFire() end
            if notifications then notifications:Show("Rapid Fire", "Enabled - Max firerate!", 2) end
        else
            if weaponMods and weaponMods.StopRapidFire then weaponMods:StopRapidFire() end
            if notifications then notifications:Show("Rapid Fire", "Disabled", 2) end
        end
    end })
    
    gunModSection:Toggle({ Title = "Fast Reload", Value = false, Callback = function(v)
        toggles.FastReload = v
        if v then
            if weaponMods and weaponMods.StartFastReload then weaponMods:StartFastReload() end
            if notifications then notifications:Show("Fast Reload", "Enabled - Instant reload!", 2) end
        else
            if weaponMods and weaponMods.StopFastReload then weaponMods:StopFastReload() end
            if notifications then notifications:Show("Fast Reload", "Disabled", 2) end
        end
    end })
    
    gunModSection:Divider()
    
    -- Silent Aim Section
    local silentAimSection = tab:Section({ Title = "Silent Aim (Game Aim Hook)" })
    silentAimSection:Paragraph({
        Title = "Native Silent Aim",
        Desc = "Hooks _G.getCurrentAutoTargetPosition to redirect bullet trajectories to target heads/bodies silently without snapping your camera."
    })
    
    silentAimSection:Toggle({ Title = "Silent Aim", Value = false, Callback = function(v)
        toggles.SilentAim = v
        if v then
            if weaponMods and weaponMods.StartSilentAim then weaponMods:StartSilentAim() end
            if notifications then notifications:Show("Silent Aim", "Enabled", 2) end
        else
            if weaponMods and weaponMods.StopSilentAim then weaponMods:StopSilentAim() end
            if notifications then notifications:Show("Silent Aim", "Disabled", 2) end
        end
    end })
    
    silentAimSection:Dropdown({ Title = "Target Mode", Values = { "Mobs", "Players", "Both" }, Default = 1, Callback = function(v)
        options.SilentAimTargetMode = v
    end })
    
    silentAimSection:Dropdown({ Title = "Hit Part", Values = { "Head", "HumanoidRootPart", "Torso" }, Default = 1, Callback = function(v)
        options.SilentAimPart = v
    end })
    
    silentAimSection:Slider({ Title = "Silent Aim FOV", Value = { Min = 50, Max = 800, Default = options.SilentAimFOV or 250 }, Callback = function(v)
        options.SilentAimFOV = v
    end })
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
    local network = self.Network
    local notifications = self.Notifications
    local fakeClass = self.FakeClass
    
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

    -- Map Exploration & Fog Clear (Game Remote Exploit)
    local mapSection = tab:Section({ Title = "Map & Fog Exploits" })
    mapSection:Paragraph({
        Title = "Full Map Fog Unlock",
        Desc = "Fires FogTouched remotes for all map sectors, revealing the entire minimap and clearing fog barriers across the world."
    })
    mapSection:Button({
        Title = "Unlock Entire Map & Clear Fog",
        Callback = function()
            local playerModule = self.Player
            if playerModule and playerModule.UnlockEntireMap then
                local count = playerModule:UnlockEntireMap()
                if notifications then
                    notifications:Show("Map Explored", "Unlocked " .. count .. " fog sectors successfully!", 3)
                end
            elseif self.Utils and self.Utils.UnlockEntireMap then
                local count = self.Utils:UnlockEntireMap()
                if notifications then
                    notifications:Show("Map Explored", "Unlocked " .. count .. " fog sectors successfully!", 3)
                end
            end
        end
    })

    -- Content Creator / Troll Toolkit
    local trollSection = tab:Section({ Title = "Content Creator / Troll Toolkit" })
    local isAllowed = network and network.IsTrollAllowed and network:IsTrollAllowed()
    if isAllowed then
        trollSection:Paragraph({ Title = "Status: ALLOWED", Desc = "Server validated your creator/admin status for Troll remotes." })
        trollSection:Button({ Title = "Spawn Zombie", Callback = function()
            network:TrollSpawnZombie("Regular", 1)
        end })
        trollSection:Button({ Title = "Spawn Brute", Callback = function()
            network:TrollSpawnZombie("Brute", 1)
        end })
        trollSection:Button({ Title = "Spawn AA-12 Gun", Callback = function()
            network:TrollSpawnItem("AA-12", 1)
        end })
        trollSection:Button({ Title = "Toggle Creator Fly", Callback = function()
            network:TrollToggleFly()
        end })
    else
        trollSection:Paragraph({
            Title = "Status: Whitelist Only",
            Desc = "Troll Remotes require Creator/Admin whitelist permissions on the server."
        })
    end
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
