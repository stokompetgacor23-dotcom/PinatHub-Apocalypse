-- =======================================================
-- PINATHUB - UI MODULE
-- =======================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.GuiVisible = true
UI.Window = nil

-- Load WindUI
local function loadWindUI()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
    end)
    return success and result or nil
end

-- Create logo
function UI:CreateLogo()
    local player = LocalPlayer
    local UIS = UserInputService
    
    local logoGui = Instance.new("ScreenGui")
    logoGui.Name = "PinatHubLogo"
    logoGui.ResetOnSpawn = false
    logoGui.Parent = player:WaitForChild("PlayerGui", 5)
    
    local logoButton = Instance.new("ImageButton")
    logoButton.Name = "LogoButton"
    logoButton.Size = UDim2.new(0, 60, 0, 60)
    logoButton.Position = UDim2.new(0.5, -30, 0.5, -30)
    logoButton.BackgroundTransparency = 1
    logoButton.Image = "rbxassetid://118264723961739"
    logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
    logoButton.ScaleType = Enum.ScaleType.Fit
    logoButton.Parent = logoGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = logoButton
    
    local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)})
    local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
    
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
function UI:SetupProximityPromptAntiDelay(utils)
    local proximityPromptActive = false
    local proximityPromptAddedConn = nil
    
    local function enableProximityPromptAntiDelay()
        if proximityPromptActive then return end
        proximityPromptActive = true
        
        local workspace = game:GetService("Workspace")
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
        
        proximityPromptAddedConn = workspace.DescendantAdded:Connect(function(v)
            if proximityPromptActive and v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end)
        
        if utils then utils:AddConnection(proximityPromptAddedConn) end
    end
    
    local function disableProximityPromptAntiDelay()
        proximityPromptActive = false
        if proximityPromptAddedConn then
            proximityPromptAddedConn:Disconnect()
            proximityPromptAddedConn = nil
        end
    end
    
    return enableProximityPromptAntiDelay, disableProximityPromptAntiDelay
end

function UI:Init(deps)
    local WindUI = loadWindUI()
    if not WindUI then 
        print("Failed to load WindUI Library")
        return nil
    end
    
    self.Config = deps.Config
    self.Utils = deps.Utils
    self.ESP = deps.ESP
    self.Farm = deps.Farm
    self.Bring = deps.Bring
    self.Teleport = deps.Teleport
    self.Network = deps.Network
    self.Notifications = deps.Notifications
    
    -- Setup notifications
    self.Notifications:SetWindow(self.Window)
    self.Bring.Notifications = self.Notifications
    self.Farm.Notifications = self.Notifications
    
    -- Create logo
    local logoGui, logoButton = self:CreateLogo()
    
    -- Create main window
    self.Window = WindUI:CreateWindow({
        Title = "PinatHub",
        Author = "Survive the Apocalypse",
        Folder = "pinathub",
        NewElements = true,
        OpenButton = { Enabled = false },
        Topbar = { Height = 44, ButtonsType = "Default" }
    })
    
    self.Window:Tag({ Title = "@viunze on tiktok", Icon = "star", Color = Color3.fromHex("#BA00FF"), Border = true })
    
    -- Logo click handler
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
    
    -- Create tabs
    local InfoTab = self.Window:Tab({ Title = "Info", Icon = "info", IconColor = Color3.fromHex("#00FFFF"), Border = true })
    local VisualsTab = self.Window:Tab({ Title = "Visuals", Icon = "eye", IconColor = Color3.fromHex("#00FFFF"), Border = true })
    local PlayerTab = self.Window:Tab({ Title = "Player", Icon = "user", IconColor = Color3.fromHex("#30FF6A"), Border = true })
    local CombatTab = self.Window:Tab({ Title = "Combat", Icon = "swords", IconColor = Color3.fromHex("#FF305D"), Border = true })
    local ExploitsTab = self.Window:Tab({ Title = "Exploits", Icon = "zap", IconColor = Color3.fromHex("#FFD700"), Border = true })
    local MiscTab = self.Window:Tab({ Title = "Misc", Icon = "settings", IconColor = Color3.fromHex("#9B59B6"), Border = true })
    local CommunityTab = self.Window:Tab({ Title = "Community", Icon = "message-circle", IconColor = Color3.fromHex("#9B59B6"), Border = true })
    
    -- Build UI sections
    self:BuildInfoTab(InfoTab)
    self:BuildVisualsTab(VisualsTab)
    self:BuildPlayerTab(PlayerTab)
    self:BuildCombatTab(CombatTab)
    self:BuildExploitsTab(ExploitsTab)
    self:BuildMiscTab(MiscTab)
    self:BuildCommunityTab(CommunityTab)
    
    self.Window:Open()
    
    return self
end

function UI:BuildInfoTab(tab)
    local config = self.Config
    local supportedMaps = config:GetSupportedMaps()
    
    local infoHeader = tab:Section({ Title = "PinatHub Information" })
    infoHeader:Paragraph({ Title = "Welcome to PinatHub!", Desc = "Created by: @viunze on TikTok" })
    infoHeader:Divider()
    
    local supportSection = tab:Section({ Title = "Supported Games (" .. #supportedMaps .. " Maps)" })
    for _, map in ipairs(supportedMaps) do
        supportSection:Paragraph({ Title = map.name, Desc = "" })
    end
end

function UI:BuildVisualsTab(tab)
    local config = self.Config
    local esp = self.ESP
    local utils = self.Utils
    local options = config:GetOptions()
    local crateOptions = config:GetCrateOptions()
    local espDefs = config:GetESPDefinitions()
    
    local espSettingsSection = tab:Section({ Title = "ESP Settings" })
    
    local function updateNames(value)
        if esp then
            esp:SetMobOptions({ ESP = esp.Options.mob.ESP, Chams = esp.Options.mob.Chams, Name = value, Distance = esp.Options.mob.Distance })
            esp:SetPlayerOptions({ ESP = esp.Options.player.ESP, Chams = esp.Options.player.Chams, Name = value, Distance = esp.Options.player.Distance, Health = esp.Options.player.Health })
            esp:SetStructureOptions({ ESP = esp.Options.structure.ESP, Chams = esp.Options.structure.Chams, Name = value, Distance = esp.Options.structure.Distance })
            esp:RefreshAll()
        end
        crateOptions.Name = value
    end
    
    local function updateDistance(value)
        if esp then
            esp:SetMobOptions({ ESP = esp.Options.mob.ESP, Chams = esp.Options.mob.Chams, Name = esp.Options.mob.Name, Distance = value })
            esp:SetPlayerOptions({ ESP = esp.Options.player.ESP, Chams = esp.Options.player.Chams, Name = esp.Options.player.Name, Distance = value, Health = esp.Options.player.Health })
            esp:SetStructureOptions({ ESP = esp.Options.structure.ESP, Chams = esp.Options.structure.Chams, Name = esp.Options.structure.Name, Distance = value })
            esp:RefreshAll()
        end
        crateOptions.Distance = value
    end
    
    espSettingsSection:Toggle({ Title = "Show Names", Default = false, Callback = updateNames })
    espSettingsSection:Toggle({ Title = "Show Distance", Default = false, Callback = updateDistance })
    
    -- Mob ESP
    local mobSection = tab:Section({ Title = "Mob ESP" })
    mobSection:Toggle({ Title = "Mob ESP", Default = false, Callback = function(v) 
        if esp then esp:SetMobOptions({ ESP = v, Chams = esp.Options.mob.Chams, Name = esp.Options.mob.Name, Distance = esp.Options.mob.Distance }); esp:RefreshAll() end 
    end })
    mobSection:Toggle({ Title = "Mob Chams", Default = false, Callback = function(v) 
        if esp then esp:SetMobOptions({ ESP = esp.Options.mob.ESP, Chams = v, Name = esp.Options.mob.Name, Distance = esp.Options.mob.Distance }); esp:RefreshAll() end 
    end })
    
    -- Player ESP
    local playerSection = tab:Section({ Title = "Player ESP" })
    playerSection:Toggle({ Title = "Player ESP", Default = false, Callback = function(v) 
        if esp then esp:SetPlayerOptions({ ESP = v, Chams = esp.Options.player.Chams, Name = esp.Options.player.Name, Distance = esp.Options.player.Distance, Health = esp.Options.player.Health }); esp:RefreshAll() end 
    end })
    playerSection:Toggle({ Title = "Player Chams", Default = false, Callback = function(v) 
        if esp then esp:SetPlayerOptions({ ESP = esp.Options.player.ESP, Chams = v, Name = esp.Options.player.Name, Distance = esp.Options.player.Distance, Health = esp.Options.player.Health }); esp:RefreshAll() end 
    end })
    playerSection:Toggle({ Title = "Show Health", Default = false, Callback = function(v) 
        if esp then esp:SetPlayerOptions({ ESP = esp.Options.player.ESP, Chams = esp.Options.player.Chams, Name = esp.Options.player.Name, Distance = esp.Options.player.Distance, Health = v }); esp:RefreshAll() end 
    end })
end

function UI:BuildPlayerTab(tab)
    local config = self.Config
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    local utils = self.Utils
    
    local movementSection = tab:Section({ Title = "Movement" })
    
    movementSection:Toggle({ Title = "Speed Hack", Default = false, Callback = function(v) 
        toggles.SpeedHack = v
        self.Notifications:Show("Speed Hack", v and "Enabled" or "Disabled", 2)
    end })
    
    movementSection:Slider({ Title = "Speed Value", Description = "Custom walk speed (16-120)", Value = { Min = 16, Default = 50, Max = 120 }, Callback = function(v) 
        options.SpeedValue = v
    end })
    
    movementSection:Toggle({ Title = "Inf Jump", Default = false, Callback = function(v) 
        toggles.InfJump = v
        self.Notifications:Show("Inf Jump", v and "Enabled" or "Disabled", 2)
    end })
    
    movementSection:Toggle({ Title = "NoClip", Default = false, Callback = function(v) 
        toggles.NoClip = v
        self.Notifications:Show("NoClip", v and "Enabled" or "Disabled", 2)
    end })
    
    movementSection:Toggle({ Title = "Fly", Default = false, Callback = function(v) 
        toggles.Fly = v
        self.Notifications:Show("Fly", v and "Enabled" or "Disabled", 2)
    end })
    
    movementSection:Toggle({ Title = "Auto Sprint", Default = false, Callback = function(v) 
        toggles.AutoSprint = v
        self.Notifications:Show("Auto Sprint", v and "Enabled" or "Disabled", 2)
    end })
    
    movementSection:Toggle({ Title = "Bunny Hop", Default = false, Callback = function(v) 
        toggles.BunnyHop = v
        self.Notifications:Show("Bunny Hop", v and "Enabled" or "Disabled", 2)
    end })
end

function UI:BuildCombatTab(tab)
    local config = self.Config
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    local farm = self.Farm
    
    -- Kill Aura Section
    local killAuraSection = tab:Section({ Title = "Kill Aura" })
    killAuraSection:Toggle({ Title = "Kill Aura", Default = false, Callback = function(v) 
        toggles.KillAura = v
        self.Notifications:Show("Kill Aura", v and "Enabled" or "Disabled", 2)
    end })
    killAuraSection:Slider({ Title = "Aura Range", Description = "Jarak serangan Kill Aura (3-25 studs)", Value = { Min = 3, Default = 6, Max = 25 }, Callback = function(v) options.KillAuraRange = v end })
    killAuraSection:Dropdown({ Title = "Target Priority", Values = { "Nearest", "Lowest HP", "Highest HP" }, Default = 1, Callback = function(v) options.KillAuraPriority = v end })
    killAuraSection:Toggle({ Title = "Auto-Equip Weapon", Default = false, Callback = function(v) toggles.KillAuraAutoEquip = v end })
    killAuraSection:Toggle({ Title = "Show Target Indicator", Default = true, Callback = function(v) toggles.KillAuraShowIndicator = v end })
    killAuraSection:Toggle({ Title = "Extended Range (+2 studs)", Default = true, Callback = function(v) toggles.KillAuraExtendedRange = v end })
    
    -- Auto Hunt Section
    local autoHuntSection = tab:Section({ Title = "Auto Hunt Zombie" })
    autoHuntSection:Toggle({ Title = "Auto Hunt", Default = false, Callback = function(v) 
        toggles.AutoHunt = v
        if v then 
            farm:StartAutoHunt(self.Utils, self.Network, self.Config, self.Notifications)
        else 
            farm:StopAutoHunt(self.Notifications)
        end
    end })
    autoHuntSection:Slider({ Title = "Hunt Range", Description = "Detection range (500-9999)", Value = { Min = 500, Default = 9999, Max = 9999 }, Callback = function(v) options.HuntRange = v end })
    autoHuntSection:Slider({ Title = "Fly Speed", Description = "Movement speed (50-300)", Value = { Min = 50, Default = 120, Max = 300 }, Callback = function(v) options.HuntFlySpeed = v end })
    autoHuntSection:Slider({ Title = "Kill Range", Description = "Attack distance (10-50)", Value = { Min = 10, Default = 25, Max = 50 }, Callback = function(v) options.HuntKillRange = v end })
    autoHuntSection:Slider({ Title = "Swing Speed", Description = "Attack speed (0.001-0.05)", Value = { Min = 0.001, Default = 0.010, Max = 0.05, Decimal = true }, Callback = function(v) options.HuntSwingSpeed = v end })
    autoHuntSection:Slider({ Title = "Fly Height", Description = "Height above zombie (3-15)", Value = { Min = 3, Default = 7, Max = 15 }, Callback = function(v) options.HuntFlyHeight = v end })
end

function UI:BuildExploitsTab(tab)
    local config = self.Config
    local options = config:GetOptions()
    local toggles = config:GetToggles()
    local bring = self.Bring
    local network = self.Network
    
    local autoPickupSection = tab:Section({ Title = "Auto Pickup Item" })
    autoPickupSection:Toggle({ Title = "Auto Pickup", Default = false, Callback = function(v) 
        toggles.AutoPickup = v
        self.Notifications:Show("Auto Pickup", v and "Enabled" or "Disabled", 2)
    end })
    autoPickupSection:Toggle({ Title = "Pickup All Items", Default = true, Callback = function(v) options.AutoPickupAll = v end })
    autoPickupSection:Slider({ Title = "Pickup Range", Description = "Distance to pickup items (12-200)", Value = { Min = 12, Default = 50, Max = 200 }, Callback = function(v) options.AutoPickupRange = v end })
    autoPickupSection:Slider({ Title = "Pickup Delay", Description = "Delay between pickups (0.05-1)", Value = { Min = 0.05, Default = 0.1, Max = 1, Decimal = true }, Callback = function(v) options.AutoPickupDelay = v end })
    
    local bringSection = tab:Section({ Title = "Bring Pickup Item" })
    bringSection:Toggle({ Title = "Bring Pickup Item", Default = false, Callback = function(v) 
        toggles.BringPickupItem = v
        if v then 
            bring:Start(self.Config, self.Network, self.Utils)
            self.Notifications:Show("Bring Pickup Item", "Enabled!", 2)
        else 
            bring:Stop()
            self.Notifications:Show("Bring Pickup Item", "Disabled", 2)
        end
    end })
    bringSection:Toggle({ Title = "All Pickup Items", Default = false, Callback = function(v) toggles.BringAllPickup = v end })
    bringSection:Dropdown({ Title = "Sort Order", Values = { "Nearest First", "Farthest First", "Alphabetical", "Reverse Alphabetical" }, Default = 1, Callback = function(v) options.BringPickupSortOrder = v end })
    
    -- Auto Destroy
    local autoDestroySection = tab:Section({ Title = "Auto Destroy Structure" })
    autoDestroySection:Toggle({ Title = "Auto Destroy (Barrel & Scrap Pile)", Default = false, Callback = function(v) 
        toggles.AutoDestroyStructure = v
        self.Notifications:Show("Auto Destroy", v and "Enabled" or "Disabled", 2)
    end })
    
    -- Auto Hunt Fuel
    local autoHuntFuelSection = tab:Section({ Title = "Auto Hunt Fuel" })
    autoHuntFuelSection:Toggle({ Title = "Auto Hunt Fuel", Default = false, Callback = function(v) 
        toggles.AutoHuntFuel = v
        self.Notifications:Show("Auto Hunt Fuel", v and "Enabled" or "Disabled", 2)
    end })
    autoHuntFuelSection:Slider({ Title = "Fuel Hunt Range", Description = "Detection range for Fuel (100-5000 studs)", Value = { Min = 100, Default = 500, Max = 5000 }, Callback = function(v) options.FuelHuntRange = v end })
end

function UI:BuildMiscTab(tab)
    local config = self.Config
    local toggles = config:GetToggles()
    local teleport = self.Teleport
    
    local utilitySection = tab:Section({ Title = "Utilities" })
    utilitySection:Toggle({ Title = "Anti-AFK", Default = true, Callback = function(v) 
        toggles.AntiAFK = v
        self.Notifications:Show("Anti-AFK", v and "Enabled" or "Disabled", 2)
    end })
    utilitySection:Toggle({ Title = "Fullbright", Default = false, Callback = function(v) 
        toggles.Fullbright = v
        self.Notifications:Show("Fullbright", v and "Enabled" or "Disabled", 2)
    end })
    utilitySection:Toggle({ Title = "Remove Fog", Default = false, Callback = function(v) 
        toggles.RemoveFog = v
        self.Notifications:Show("Remove Fog", v and "Enabled" or "Disabled", 2)
    end })
    
    -- Proximity Prompt Section
    local proximitySection = tab:Section({ Title = "ProximityPrompt" })
    proximitySection:Toggle({ Title = "Anti Delay ProximityPrompt", Default = false, Callback = function(v) 
        toggles.ProximityPromptAntiDelay = v
        self.Notifications:Show("ProximityPrompt", v and "Anti Delay Enabled" or "Anti Delay Disabled", 2)
    end })
    
    -- Server Tools
    local serverSection = tab:Section({ Title = "Server Tools" })
    serverSection:Button({ Title = "Server Hop", Callback = function() teleport:ServerHop() end })
    serverSection:Button({ Title = "Rejoin Server", Callback = function() teleport:Rejoin() end })
end

function UI:BuildCommunityTab(tab)
    local whatsappSection = tab:Section({ Title = "WhatsApp Group" })
    whatsappSection:Button({ Title = "Join WhatsApp Group", Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
            self.Notifications:Show("Success", "WhatsApp link copied to clipboard!", 3)
        else
            self.Notifications:Show("Error", "Clipboard not supported!", 2)
        end
    end })
    
    local discordSection = tab:Section({ Title = "Discord Server" })
    discordSection:Button({ Title = "Join Discord Server", Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eDbaHKEf7G")
            self.Notifications:Show("Success", "Discord link copied to clipboard!", 3)
        else
            self.Notifications:Show("Error", "Clipboard not supported!", 2)
        end
    end })
end

return UI
