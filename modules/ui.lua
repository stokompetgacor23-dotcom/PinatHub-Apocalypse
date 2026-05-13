-- =======================================================
-- PINATHUB - UI MODULE (WINDUI JUMANTARA STYLE - GRAY THEME)
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.GuiVisible = true
UI.Window = nil

-- Load WindUI (Latest Version)
local function loadWindUI()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'))()
    end)
    return success and result or nil
end

-- Gray Theme (Jumantara Style)
local GrayTheme = {
    Name = "JumantaraGray",
    
    -- Primary Colors
    Accent = Color3.fromRGB(100, 100, 100),
    Dialog = Color3.fromRGB(45, 45, 45),
    Outline = Color3.fromRGB(80, 80, 80),
    
    -- Text Colors
    Text = Color3.fromRGB(220, 220, 220),
    Placeholder = Color3.fromRGB(120, 120, 120),
    
    -- Backgrounds
    Background = Color3.fromRGB(25, 25, 25),
    Button = Color3.fromRGB(70, 70, 70),
    Icon = Color3.fromRGB(150, 150, 150),
    
    -- Interactive Elements
    Toggle = Color3.fromRGB(100, 100, 100),
    Slider = Color3.fromRGB(90, 90, 90),
    Checkbox = Color3.fromRGB(100, 100, 100),
    
    -- Panel Elements
    PanelBackground = Color3.fromRGB(35, 35, 35),
    PanelBackgroundTransparency = 0.95,
    
    -- Window Elements
    WindowBackground = Color3.fromRGB(28, 28, 28),
    WindowShadow = Color3.fromRGB(0, 0, 0),
    
    -- Tab Elements
    TabBackground = Color3.fromRGB(40, 40, 40),
    TabBackgroundHover = Color3.fromRGB(55, 55, 55),
    TabBackgroundActive = Color3.fromRGB(60, 60, 60),
    TabText = Color3.fromRGB(200, 200, 200),
    TabIcon = Color3.fromRGB(170, 170, 170),
    TabBorder = Color3.fromRGB(90, 90, 90),
    
    -- Element Background
    ElementBackground = Color3.fromRGB(50, 50, 50),
    ElementBackgroundTransparency = 0,
    
    -- Labels
    LabelBackground = Color3.fromRGB(30, 30, 30),
    LabelBackgroundTransparency = 0.83,
    
    -- Slider Icon
    SliderIcon = Color3.fromRGB(120, 120, 120),
    
    -- Primary Action
    Primary = Color3.fromRGB(100, 100, 100),
    
    -- Checkbox
    CheckboxBorder = Color3.fromRGB(100, 100, 100),
    CheckboxBorderTransparency = 0.75,
    
    -- Toggle Bar
    ToggleBar = Color3.fromRGB(60, 60, 60),
    
    -- Section Box
    SectionBoxBorder = Color3.fromRGB(70, 70, 70),
    SectionBoxBorderTransparency = 0.75,
    SectionBoxBackground = Color3.fromRGB(35, 35, 35),
    SectionBoxBackgroundTransparency = 0.95,
    
    -- Notification
    Notification = Color3.fromRGB(35, 35, 35),
    NotificationTitle = Color3.fromRGB(220, 220, 220),
    NotificationContent = Color3.fromRGB(180, 180, 180),
    NotificationBorder = Color3.fromRGB(80, 80, 80),
    NotificationBorderTransparency = 0.75,
    
    -- Tooltip
    Tooltip = Color3.fromRGB(50, 50, 50),
    TooltipText = Color3.fromRGB(220, 220, 220),
    
    -- Search Bar
    SearchBarBorder = Color3.fromRGB(80, 80, 80),
    SearchBarBorderTransparency = 0.75,
    
    -- Dropdown
    DropdownTabBorder = Color3.fromRGB(80, 80, 80),
}

-- Create logo (Jumantara Style)
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
    -- Menggunakan icon ID yang diminta (7370685224242273706852242422)
    logoButton.Image = "rbxassetid://118264723961739"
    logoButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
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

-- Setup proximity prompt anti-delay
function UI:SetupProximityPromptAntiDelay()
    local proximityPromptActive = false
    local proximityPromptConn = nil
    
    local function enableProximityPromptAntiDelay()
        if proximityPromptActive then return end
        proximityPromptActive = true
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
        
        proximityPromptConn = workspace.DescendantAdded:Connect(function(v)
            if proximityPromptActive and v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end)
    end
    
    local function disableProximityPromptAntiDelay()
        proximityPromptActive = false
        if proximityPromptConn then
            proximityPromptConn:Disconnect()
            proximityPromptConn = nil
        end
    end
    
    return enableProximityPromptAntiDelay, disableProximityPromptAntiDelay
end

-- ============================================
-- INIT FUNCTION (WITH GRAY THEME)
-- ============================================
function UI:Init(modules)
    local WindUI = loadWindUI()
    if not WindUI then 
        print("Failed to load WindUI Library")
        return nil
    end
    
    -- Register Gray Theme
    pcall(function()
        WindUI:AddTheme(GrayTheme)
        WindUI:SetTheme("JumantaraGray")
    end)
    
    -- Store dependencies
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
    
    -- Create Window with Gray Theme
    self.Window = WindUI:CreateWindow({
        Title = "PinatHub",
        Author = "@viunze on tiktok",
        Folder = "pinathub",
        Size = UDim2.fromOffset(600, 600),
        Transparent = false,
        Theme = "JumantaraGray",
        IsOpenButtonEnabled = false,
        User = {Enabled = true, Anonymous = true},
        SideBarWidth = 150,
    })
    
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
    
    -- Create Tabs
    local InfoTab = self.Window:Tab({Title = "Info", Icon = "info"})
    local VisualsTab = self.Window:Tab({Title = "Visuals", Icon = "eye"})
    local PlayerTab = self.Window:Tab({Title = "Player", Icon = "user"})
    local CombatTab = self.Window:Tab({Title = "Combat", Icon = "swords"})
    local ExploitsTab = self.Window:Tab({Title = "Exploits", Icon = "zap"})
    local MiscTab = self.Window:Tab({Title = "Misc", Icon = "settings"})
    local CommunityTab = self.Window:Tab({Title = "Community", Icon = "users"})
    
    -- Build all sections
    self:BuildInfoTab(InfoTab)
    self:BuildVisualsTab(VisualsTab)
    self:BuildPlayerTab(PlayerTab)
    self:BuildCombatTab(CombatTab)
    self:BuildExploitsTab(ExploitsTab)
    self:BuildMiscTab(MiscTab)
    self:BuildCommunityTab(CommunityTab)
    
    self.Window:Open()
    print("UI initialized successfully with Jumantara Gray Theme!")
    
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
-- INFO TAB
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
-- VISUALS TAB (ESP)
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
                esp:RefreshMobESP()
                esp.PlayerESPVars.Name = value
                esp:RefreshPlayerESP()
                esp.StructureESPVars.Name = value
                esp:RefreshStructureESP()
                if crateOptions then crateOptions.Name = value end
                esp:RefreshCrateESP()
                if esp.SetAllItemNames then
                    esp:SetAllItemNames(value)
                end
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
                esp:RefreshMobESP()
                esp.PlayerESPVars.Distance = value
                esp:RefreshPlayerESP()
                esp.StructureESPVars.Distance = value
                esp:RefreshStructureESP()
                if crateOptions then crateOptions.Distance = value end
                esp:RefreshCrateESP()
                if esp.SetAllItemDistances then
                    esp:SetAllItemDistances(value)
                end
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
-- PLAYER TAB
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
-- COMBAT TAB (KILL AURA)
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
-- EXPLOITS TAB
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
end

-- ============================================
-- MISC TAB
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
-- COMMUNITY TAB
-- ============================================
function UI:BuildCommunityTab(tab)
    local notifications = self.Notifications
    
    local whatsappSection = tab:Section({ Title = "WhatsApp Group" })
    whatsappSection:Button({ Title = "Join WhatsApp Group", Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
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
