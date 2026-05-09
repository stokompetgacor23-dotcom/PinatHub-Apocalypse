-- =======================================================
-- PINATHUB 
-- Survive the Apocalypse
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ============================================
-- REMOTES
-- ============================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local pickUpItemRemote = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")
local placeStructureRemote = Remotes and Remotes:FindFirstChild("Building") and Remotes.Building:FindFirstChild("PlaceStructure")
local buyItemRemote = Remotes and Remotes:FindFirstChild("Merchant") and Remotes.Merchant:FindFirstChild("BuyItem")
local addSuppressorRemote = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AddSuppressor")
local resetRemote = Remotes and Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("Reset")

-- ============================================
-- AUTO PICKUP REMOTE (AdjustBackpack)
-- ============================================
local AdjustBackpack = nil

if Remotes then
    local Tools = Remotes:FindFirstChild("Tools")
    if Tools then
        AdjustBackpack = Tools:FindFirstChild("AdjustBackpack")
    end
end

-- Fallback: cari di seluruh ReplicatedStorage
if not AdjustBackpack then
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name == "AdjustBackpack" then
            AdjustBackpack = remote
            break
        end
    end
end

-- ============================================
-- LOGO LAUNCHER
-- ============================================
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

-- Animasi kecil
local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})

logoButton.MouseEnter:Connect(function()
    hoverTween:Play()
end)

logoButton.MouseLeave:Connect(function()
    unhoverTween:Play()
end)

-- Fitur drag
local dragging = false
local dragInput, dragStart, startPos

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

logoButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        logoButton.Position = newPos
    end
end)

-- ============================================
-- WIND UI SETUP
-- ============================================
local WindUI = (function()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
    end)
    return success and result or nil
end)()

if not WindUI then 
    print("Failed to load WindUI Library")
    return 
end

local Window = WindUI:CreateWindow({
    Title = "PinatHub",
    Author = "Survive the Apocalypse",
    Folder = "pinathub",
    NewElements = true,
    OpenButton = {
        Enabled = false,
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})

Window:Tag({ Title = "@viunze on tiktok", Icon = "star", Color = Color3.fromHex("#BA00FF"), Border = true })

-- Fungsi untuk buka/tutup via logo
local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if Window then
        pcall(function()
            if guiVisible then
                Window:Open()
            else
                Window:Minimize()
            end
        end)
    end
end)

-- Create Tabs
local InfoTab = Window:Tab({ Title = "Info", Icon = "info", IconColor = Color3.fromHex("#00FFFF"), Border = true })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye", IconColor = Color3.fromHex("#00FFFF"), Border = true })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user", IconColor = Color3.fromHex("#30FF6A"), Border = true })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords", IconColor = Color3.fromHex("#FF305D"), Border = true })
local ExploitsTab = Window:Tab({ Title = "Exploits", Icon = "zap", IconColor = Color3.fromHex("#FFD700"), Border = true })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings", IconColor = Color3.fromHex("#9B59B6"), Border = true })
local CommunityTab = Window:Tab({ Title = "Community", Icon = "message-circle", IconColor = Color3.fromHex("#9B59B6"), Border = true })

-- ============================================
-- INFO TAB - SUPPORTED MAPS
-- ============================================
local supportedMaps = {
    { name = "Survive The Apocalypse" },
    { name = "Blade Ball" },
    { name = "Be a Lucky Block" },
    { name = "Bite By Night" },
    { name = "Reel a Brainrot" },
    { name = "Jump Color Block Steal Brainrots" },
    { name = "Skateboard For Brainrots" },
    { name = "Sailor Piece" },
    { name = "Mutate the Brainrot" },
    { name = "Blox Fruits" },
    { name = "Become Invisible For Brainrots" },
    { name = "The Forge" },
    { name = "Swing Obby For Brainrots" },
    { name = "Attack on Titan Revolution" },
}

local infoHeader = InfoTab:Section({ Title = "PinatHub Information" })

infoHeader:Paragraph({
    Title = "Welcome to PinatHub!",
    Desc = "Created by: @viunze on TikTok"
})

infoHeader:Divider()

local supportSection = InfoTab:Section({ Title = "Supported Games (" .. #supportedMaps .. " Maps)" })

for _, map in ipairs(supportedMaps) do
    supportSection:Paragraph({
        Title = map.name,
        Desc = ""
    })
end

-- ============================================
-- GLOBAL STORAGE (NILAI DEFAULT)
-- ============================================
local Options = {
    ESPMaxDistance = 500,
    SpeedValue = 50,
    FlySpeed = 50,
    KillAuraRange = 6,
    KillAuraSwingRate = 0.5,
    AimbotRange = 200,
    AimbotFOV = 100,
    AimbotSmoothness = 0.3,
    AimbotPredictionAmount = 0.15,
    PickupRadius = 15,
    FPSCap = 144,
    KillAuraPriority = "Nearest",
    AimbotTarget = "Mobs",
    AimbotPart = "Head",
    AimbotPriority = "Distance",
    BringPickupSortOrder = "Nearest First",
    -- Auto Pickup Settings
    AutoPickupRange = 50,
    AutoPickupDelay = 0.1,
    AutoPickupAll = true,
    -- Auto Hunt Settings
    HuntRange = 9999,
    HuntFlySpeed = 120,
    HuntKillRange = 25,
    HuntSwingSpeed = 0.010,
    HuntFlyHeight = 7,
}

local Toggles = {
    SpeedHack = false,
    NoClip = false,
    Fly = false,
    AutoSprint = false,
    InfJump = false,
    BunnyHop = false,
    KillAura = false,
    KillAuraAutoEquip = false,
    KillAuraShowIndicator = true,
    KillAuraExtendedRange = true,
    Aimbot = false,
    AimbotPrediction = false,
    AimbotFOVCircle = false,
    AntiAFK = true,
    Fullbright = false,
    RemoveFog = false,
    FPSUnlock = false,
    AutoPickup = false,
    AllItems = false,
    BringPickupItem = false,
    BringAllPickup = false,
    AutoHunt = false,
}

-- ============================================
-- STATE VARIABLES
-- ============================================
local connections = {}
local mobESPInstances = {}
local playerESPInstances = {}
local structureESPInstances = {}
local autoPickupConnection = nil
local flyBV, flyBG = nil, nil
local flyActive = false
local antiAFKConn = nil
local autoSprintActive = false
local killAuraConn = nil
local aimbotConn = nil
local aimbotTarget = nil
local fovCircle = nil
local killAuraIndicatorLine = nil
local killAuraIndicatorCircle = nil

local originalValues = {
    walkSpeed = nil,
}

local originalLighting = { stored = false }
local originalFog = { stored = false }

local mobOptions = { ESP = false, Chams = false, Name = false, Distance = false }
local playerESPVars = { ESP = false, Chams = false, Name = false, Distance = false, Health = false }
local structureESPVars = { ESP = false, Chams = false, Name = false, Distance = false }
local bhopActive = false
local bhopConn = nil

local mobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- Weapon swing speeds
local weaponSwingSpeeds = {
    ["Knife"] = 0.25, ["Katana"] = 0.3, ["Crowbar"] = 0.35,
    ["Bat"] = 0.45, ["Spiked Bat"] = 0.45, ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4, ["Spear"] = 0.4, ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6, ["Chainsaw"] = 0.35, ["Riot Shield"] = 0.5,
}

-- ============================================
-- AUTO HUNT ZOMBIE VARIABLES
-- ============================================
local hunting = false
local huntConn = nil
local huntFlyBV = nil
local huntFlyBG = nil
local huntingFlyActive = false
local huntLastSwing = 0

-- ============================================
-- CRATES ESP VARIABLES
-- ============================================
local crateESPInstances = {}
local crateOptions = {
    ESP = false,
    Chams = false,
    Name = false,
    Distance = false,
    MaxDistance = 500,
    ChamsColor = Color3.fromRGB(255, 200, 50), -- Warna kuning keemasan
    OutlineColor = Color3.fromRGB(255, 255, 255)
}

-- ============================================
-- ITEM CATEGORIES & COLOR DEFINITIONS
-- ============================================
local espDefinitions = {
    {
        key = "Gun",
        displayName = "Gun ESP",
        items = {
            "AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"
        },
        colors = { fill = Color3.fromRGB(255, 30, 30), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 120, 120) },
    },
    {
        key = "Melee",
        displayName = "Melee ESP",
        items = {
            "Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"
        },
        colors = { fill = Color3.fromRGB(255, 140, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 200, 100) },
    },
    {
        key = "Medical",
        displayName = "Medical ESP",
        items = {
            "Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"
        },
        colors = { fill = Color3.fromRGB(0, 255, 80), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(150, 255, 150) },
    },
    {
        key = "Armor",
        displayName = "Armor ESP",
        items = {
            "Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"
        },
        colors = { fill = Color3.fromRGB(0, 100, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(160, 200, 255) },
    },
    {
        key = "Food",
        displayName = "Food ESP",
        items = {
            "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"
        },
        colors = { fill = Color3.fromRGB(190, 255, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(210, 255, 150) },
    },
    {
        key = "Resource",
        displayName = "Resources ESP",
        items = {
            "AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart"
        },
        colors = { fill = Color3.fromRGB(0, 220, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(180, 240, 255) },
    },
    {
        key = "Fuel",
        displayName = "Fuel ESP",
        items = { "Nuclear Fuel", "Refined Fuel", "Fuel" },
        colors = { fill = Color3.fromRGB(255, 220, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 240, 160) },
    },
    {
        key = "Ability",
        displayName = "Abilities ESP",
        items = {
            "Airstrike", "Attack Order", "Call of the Dead",
            "Summon Brute", "Summon Zombies", "Taunt",
            "The Future", "The Past", "The Present"
        },
        colors = { fill = Color3.fromRGB(180, 0, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(220, 150, 255) },
    },
}

local espSystems = {}

for _, def in ipairs(espDefinitions) do
    local sys = {
        key = def.key,
        displayName = def.displayName,
        colors = def.colors,
        items = def.items,
        itemList = {},
        vars = { ESP = false, Chams = false, Name = false, Distance = false },
        instances = {},
        listenersSetup = false,
    }
    for _, name in ipairs(def.items) do
        sys.itemList[name] = true
    end
    espSystems[def.key] = sys
end

-- Build flat itemNames
local itemNames = {}
for _, def in ipairs(espDefinitions) do
    for _, itemName in ipairs(def.items) do
        table.insert(itemNames, itemName)
    end
end

local extraItemCategories = {
    Ammo = { "Ammo Box", "Long Ammo", "Medium Ammo", "Pistol Ammo", "Shells" },
    Structures = {
        "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
        "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map",
        "Repair Drone", "Shelf", "Teleporter", "Time Machine", "Turret",
        "Wall", "Watchtower"
    },
    Consumables = { "Grenade", "Molotov" },
    Backpacks = { "Basic Backpack", "Good Backpack", "Great Backpack" },
    MiscItems = {
        "Emerald", "Gas Mask", "Power Armor Arm", "Power Armor Core",
        "Radio Tower Part", "Blueprint", "Military Keycard", "Repair Hammer", "Suppressor"
    },
}

for catName, catItems in pairs(extraItemCategories) do
    for _, itemName in ipairs(catItems) do
        table.insert(itemNames, itemName)
    end
end
table.sort(itemNames)

local pickupItemSet = {
    ["Ammo Box"]=true,["Long Ammo"]=true,["Medium Ammo"]=true,["Shells"]=true,["Pistol Ammo"]=true,
    ["Power Armor"]=true,["Light Armor"]=true,["Medium Armor"]=true,["Heavy Armor"]=true,
    ["Emerald"]=true,["Gas Mask"]=true,
    ["Ammo Crate"]=true,["Barbed Wire"]=true,["Bear Trap"]=true,["Boost Pad"]=true,
    ["Electric Fence"]=true,["Farm Plot"]=true,["Fence"]=true,["Floodlight"]=true,
    ["Gate"]=true,["Landmine"]=true,["Map"]=true,["Repair Drone"]=true,["Shelf"]=true,
    ["Teleporter"]=true,["Time Machine"]=true,["Turret"]=true,["Wall"]=true,["Watchtower"]=true,
    ["Basic Backpack"]=true,["Good Backpack"]=true,["Great Backpack"]=true,
    ["Grenade"]=true,["Molotov"]=true,
    ["AA-12"]=true,["AK-47"]=true,["Assault Rifle"]=true,["Desert Eagle"]=true,
    ["Double Barrel"]=true,["Flamethrower"]=true,["Grenade Launcher"]=true,["LMG"]=true,
    ["MediGun"]=true,["Pistol"]=true,["Ray Gun"]=true,["Revolver"]=true,["Rifle"]=true,
    ["Shotgun"]=true,["Sniper"]=true,["SVD"]=true,["Uzi"]=true,
    ["Bandage"]=true,["Compound H"]=true,["Compound I"]=true,["Compound R"]=true,
    ["Compound S"]=true,["Medkit"]=true,
    ["Bat"]=true,["Chainsaw"]=true,["Crowbar"]=true,["Fire Axe"]=true,["Hatchet"]=true,
    ["Katana"]=true,["Knife"]=true,["Riot Shield"]=true,["Scythe"]=true,
    ["Sledgehammer"]=true,["Spear"]=true,["Spiked Bat"]=true,
    ["Blueprint"]=true,["Military Keycard"]=true,["Repair Hammer"]=true,["Suppressor"]=true,
}

local pickupItemNames = {}
for k in pairs(pickupItemSet) do table.insert(pickupItemNames, k) end
table.sort(pickupItemNames)

local structureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower"
}

-- ============================================
-- DYNAMIC FOLDER DISCOVERY
-- ============================================
local charactersFolder = nil
local droppedItemsFolder = nil
local structuresFolder = nil
local mobListenersSetup = false
local structureListenersSetup = false

local function discoverFolders()
    charactersFolder = Workspace:FindFirstChild("Characters")
    droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    structuresFolder = Workspace:FindFirstChild("Structures")
        or Workspace:FindFirstChild("PlayerStructures")
        or Workspace:FindFirstChild("Buildings")
end
discoverFolders()

task.spawn(function()
    while true do
        task.wait(5)
        local prevChars = charactersFolder
        local prevItems = droppedItemsFolder
        local prevStructs = structuresFolder
        discoverFolders()
        if charactersFolder ~= prevChars and charactersFolder then
            refreshMobESP()
            if not mobListenersSetup then setupMobListeners() end
        end
        if droppedItemsFolder ~= prevItems and droppedItemsFolder then
            for _, sys in pairs(espSystems) do
                sys.refresh()
            end
            for _, sys in pairs(espSystems) do
                if not sys.listenersSetup then sys.setupListeners() end
            end
        end
        if structuresFolder ~= prevStructs and structuresFolder then
            refreshStructureESP()
            if not structureListenersSetup then setupStructureListeners() end
        end
    end
end)

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getItemMainPart(item)
    if item.PrimaryPart then return item.PrimaryPart end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function getItemPrimaryPart(item)
    if item:IsA("Model") then
        if item.PrimaryPart then
            return item.PrimaryPart
        end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "Handle" then
                return child
            end
        end
        local handle = item:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle
        end
    end
    return nil
end

local function getDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

local function getHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

-- ============================================
-- GENERIC ITEM ESP FACTORY
-- ============================================
local function createCategoryESP(sys, item)
    if not item:IsA("Model") then return end
    if sys.instances[item] then return end

    local mainPart = getItemMainPart(item)
    if not mainPart then return end

    local espTable = {}

    if sys.vars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = sys.key .. "ESP_Highlight"
        highlight.Adornee = item
        highlight.FillColor = sys.colors.fill
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = sys.colors.outline
        highlight.OutlineTransparency = 0.8
        highlight.Parent = item
        espTable.Highlight = highlight
    end

    if sys.vars.Name or sys.vars.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = sys.key .. "ESP_NameDistance"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = item

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[" .. sys.key .. "] " .. item.Name
        nameLabel.TextColor3 = sys.colors.text
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = sys.vars.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = sys.vars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not item or not item.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local maxDist = Options.ESPMaxDistance or 99999
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then
                        billboard.Enabled = visible
                    end
                    if espTable.Highlight then
                        espTable.Highlight.Enabled = visible
                    end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(connections, connection)
    end

    sys.instances[item] = espTable
end

local function removeCategoryESP(sys, item)
    local esp = sys.instances[item]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        sys.instances[item] = nil
    end
end

local function refreshCategoryESP(sys)
    for item, _ in pairs(sys.instances) do
        removeCategoryESP(sys, item)
    end
    if not sys.vars.ESP then return end
    if not droppedItemsFolder then return end
    for _, child in ipairs(droppedItemsFolder:GetChildren()) do
        if sys.itemList[child.Name] then
            createCategoryESP(sys, child)
        end
    end
end

local function setupCategoryListeners(sys)
    if not droppedItemsFolder or sys.listenersSetup then return end
    sys.listenersSetup = true
    local addedConn = droppedItemsFolder.ChildAdded:Connect(function(child)
        if sys.vars.ESP and sys.itemList[child.Name] then
            createCategoryESP(sys, child)
        end
    end)
    table.insert(connections, addedConn)
    local removedConn = droppedItemsFolder.ChildRemoved:Connect(function(child)
        removeCategoryESP(sys, child)
    end)
    table.insert(connections, removedConn)
end

for _, sys in pairs(espSystems) do
    sys.create = function(item) createCategoryESP(sys, item) end
    sys.remove = function(item) removeCategoryESP(sys, item) end
    sys.refresh = function() refreshCategoryESP(sys) end
    sys.setupListeners = function() setupCategoryListeners(sys) end
end

for _, sys in pairs(espSystems) do
    setupCategoryListeners(sys)
end

-- ============================================
-- CRATES ESP FUNCTIONS
-- ============================================
local function findAllCrates()
    local crates = {}
    
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then
        return crates
    end
    
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then
        return crates
    end
    
    for _, child in ipairs(cratesFolder:GetChildren()) do
        if child.Name == "Default" and child:IsA("Model") then
            table.insert(crates, child)
        end
    end
    
    return crates
end

local function getCrateMainPart(crate)
    if crate.PrimaryPart then
        return crate.PrimaryPart
    end
    
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end

local function removeCrateESP(crate)
    local esp = crateESPInstances[crate]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        crateESPInstances[crate] = nil
    end
end

local function createCrateESP(crate)
    if not crate:IsA("Model") then return end
    if crateESPInstances[crate] then return end
    
    local mainPart = getCrateMainPart(crate)
    if not mainPart then return end
    
    local espTable = {}
    
    if crateOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CrateESP_Highlight"
        highlight.Adornee = crate
        highlight.FillColor = crateOptions.ChamsColor
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = crateOptions.OutlineColor
        highlight.OutlineTransparency = 0.5
        highlight.Parent = crate
        espTable.Highlight = highlight
    end
    
    if crateOptions.Name or crateOptions.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CrateESP_Info"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = crate
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📦 CRATE"
        nameLabel.TextColor3 = crateOptions.ChamsColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = crateOptions.Name
        nameLabel.Parent = frame
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = crateOptions.Distance
        distLabel.Parent = frame
        
        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not crate or not crate.Parent then
                connection:Disconnect()
                return
            end
            
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot and mainPart and mainPart.Parent then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= crateOptions.MaxDistance
                    if billboard.Enabled ~= visible then
                        billboard.Enabled = visible
                    end
                    if espTable.Highlight then
                        espTable.Highlight.Enabled = visible
                    end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(connections, connection)
    end
    
    crateESPInstances[crate] = espTable
end

local function refreshCrateESP()
    for crate, _ in pairs(crateESPInstances) do
        removeCrateESP(crate)
    end
    
    if not crateOptions.ESP then return end
    
    local allCrates = findAllCrates()
    
    for _, crate in ipairs(allCrates) do
        createCrateESP(crate)
    end
    
    local mapFolder = Workspace:FindFirstChild("Map")
    local cratesFolder = mapFolder and mapFolder:FindFirstChild("Crates")
    
    if mapFolder and cratesFolder then
        print("[Crates ESP] Ditemukan " .. #allCrates .. " crate di Map/Crates/Default")
    else
        if not mapFolder then
            print("[Crates ESP] Folder 'Map' tidak ditemukan!")
        elseif not cratesFolder then
            print("[Crates ESP] Folder 'Crates' tidak ditemukan di dalam Map!")
        end
    end
end

local function setupCrateListeners()
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return end
    
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then return end
    
    local childAddedConn = cratesFolder.ChildAdded:Connect(function(child)
        if child.Name == "Default" and child:IsA("Model") then
            if crateOptions.ESP then
                task.wait(0.1)
                createCrateESP(child)
            end
        end
    end)
    table.insert(connections, childAddedConn)
    
    local childRemovedConn = cratesFolder.ChildRemoving:Connect(function(child)
        if child.Name == "Default" and child:IsA("Model") then
            removeCrateESP(child)
        end
    end)
    table.insert(connections, childRemovedConn)
end

-- ============================================
-- MOB ESP FUNCTIONS
-- ============================================
local function removeMobESP(char)
    local esp = mobESPInstances[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        mobESPInstances[char] = nil
    end
end

local function createMobESP(char)
    if not char:IsA("Model") then return end
    if mobESPInstances[char] then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end

    local espTable = {}
    local mobColors = {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}

    if mobOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = mobColors.fill
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = mobColors.outline
        highlight.OutlineTransparency = 0.8
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    if mobOptions.Name or mobOptions.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MobESP_NameDistance"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = char.Name
        nameLabel.TextColor3 = mobColors.outline
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = mobOptions.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = mobOptions.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.Root = root

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then
                connection:Disconnect()
                return
            end

            if nameLabel and nameLabel.Visible and nameLabel.Parent then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    nameLabel.Text = char.Name .. " [" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                end
            end

            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    local maxDist = Options.ESPMaxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(connections, connection)
    end

    mobESPInstances[char] = espTable
end

local function refreshMobESP()
    for char, _ in pairs(mobESPInstances) do
        removeMobESP(char)
    end
    if not mobOptions.ESP then return end
    if not charactersFolder then return end
    for _, child in ipairs(charactersFolder:GetChildren()) do
        if table.find(mobNames, child.Name) then
            createMobESP(child)
        end
    end
end

-- ============================================
-- STRUCTURE ESP FUNCTIONS
-- ============================================
local function removeStructureESP(structure)
    local esp = structureESPInstances[structure]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        structureESPInstances[structure] = nil
    end
end

local function createStructureESP(structure)
    if not structure:IsA("Model") then return end
    if structureESPInstances[structure] then return end

    local mainPart = structure.PrimaryPart or getItemMainPart(structure)
    if not mainPart then return end

    local espTable = {}

    if structureESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "StructESP_Highlight"
        highlight.Adornee = structure
        highlight.FillColor = Color3.fromRGB(0, 200, 150)
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = Color3.fromRGB(100, 255, 200)
        highlight.OutlineTransparency = 0.7
        highlight.Parent = structure
        espTable.Highlight = highlight
    end

    if structureESPVars.Name or structureESPVars.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "StructESP_Info"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = structure

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[STRUCTURE] " .. structure.Name
        nameLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Visible = structureESPVars.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = structureESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not structure or not structure.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local maxDist = Options.ESPMaxDistance or 99999
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then
                        billboard.Enabled = visible
                    end
                    if espTable.Highlight then
                        espTable.Highlight.Enabled = visible
                    end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(connections, connection)
    end

    structureESPInstances[structure] = espTable
end

local function refreshStructureESP()
    for structure, _ in pairs(structureESPInstances) do
        removeStructureESP(structure)
    end
    if not structureESPVars.ESP then return end
    if not structuresFolder then return end
    for _, child in ipairs(structuresFolder:GetChildren()) do
        if table.find(structureNames, child.Name) then
            createStructureESP(child)
        end
    end
end

-- ============================================
-- PLAYER ESP FUNCTIONS
-- ============================================
local function removePlayerESP(player)
    local esp = playerESPInstances[player]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        if esp.CharAddedConn then esp.CharAddedConn:Disconnect() end
        playerESPInstances[player] = nil
    end
end

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    if playerESPInstances[player] then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espTable = {}

    if playerESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
        highlight.OutlineTransparency = 0.8
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    if playerESPVars.Name or playerESPVars.Distance or playerESPVars.Health then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 70)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Visible = playerESPVars.Name
        nameLabel.Parent = frame

        local toolLabel = Instance.new("TextLabel")
        toolLabel.Name = "ToolLabel"
        toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
        toolLabel.Position = UDim2.new(0, 0, 0.3, 0)
        toolLabel.BackgroundTransparency = 1
        toolLabel.Text = ""
        toolLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
        toolLabel.TextStrokeTransparency = 0.2
        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        toolLabel.Font = Enum.Font.Gotham
        toolLabel.TextSize = 11
        toolLabel.Visible = playerESPVars.Name
        toolLabel.Parent = frame

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.55, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        healthLabel.TextStrokeTransparency = 0.2
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = 11
        healthLabel.Visible = playerESPVars.Health
        healthLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.2, 0)
        distLabel.Position = UDim2.new(0, 0, 0.78, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 11
        distLabel.Visible = playerESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.ToolLabel = toolLabel
        espTable.HealthLabel = healthLabel
        espTable.DistLabel = distLabel

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not player or not player.Parent then
                connection:Disconnect()
                return
            end
            local c = player.Character
            if not c or not c.Parent then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            if not r then return end

            if toolLabel and toolLabel.Visible and toolLabel.Parent then
                local tool = c:FindFirstChildOfClass("Tool")
                toolLabel.Text = tool and ("[ " .. tool.Name .. " ]") or ""
            end

            if healthLabel and healthLabel.Visible and healthLabel.Parent then
                local humanoid = c:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local health = math.floor(humanoid.Health)
                    healthLabel.Text = health .. " HP"
                    healthLabel.TextColor3 = getHealthColor(humanoid.Health / humanoid.MaxHealth)
                end
            end

            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - r.Position).Magnitude
                    local maxDist = Options.ESPMaxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(connections, connection)
    end

    local charAddedConn = player.CharacterAdded:Connect(function()
        if playerESPVars.ESP then
            task.wait(1)
            removePlayerESP(player)
            createPlayerESP(player)
        end
    end)
    espTable.CharAddedConn = charAddedConn
    table.insert(connections, charAddedConn)

    playerESPInstances[player] = espTable
end

local function refreshPlayerESP()
    for player, _ in pairs(playerESPInstances) do
        removePlayerESP(player)
    end
    if not playerESPVars.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                createPlayerESP(player)
            else
                local conn = player.CharacterAdded:Connect(function()
                    conn:Disconnect()
                    if playerESPVars.ESP then
                        task.wait(1)
                        createPlayerESP(player)
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end
end

-- ============================================
-- FOLDER EVENT LISTENERS
-- ============================================
local function setupMobListeners()
    if not charactersFolder or mobListenersSetup then return end
    mobListenersSetup = true
    local childAddedConn = charactersFolder.ChildAdded:Connect(function(child)
        if mobOptions.ESP and table.find(mobNames, child.Name) then
            createMobESP(child)
        end
    end)
    table.insert(connections, childAddedConn)

    local childRemovedConn = charactersFolder.ChildRemoved:Connect(function(child)
        removeMobESP(child)
    end)
    table.insert(connections, childRemovedConn)
end
setupMobListeners()

local function setupStructureListeners()
    if not structuresFolder or structureListenersSetup then return end
    structureListenersSetup = true
    local childAddedConn = structuresFolder.ChildAdded:Connect(function(child)
        if structureESPVars.ESP and table.find(structureNames, child.Name) then
            createStructureESP(child)
        end
    end)
    table.insert(connections, childAddedConn)

    local childRemovedConn = structuresFolder.ChildRemoved:Connect(function(child)
        removeStructureESP(child)
    end)
    table.insert(connections, childRemovedConn)
end
setupStructureListeners()

-- ============================================
-- SPEED HACK PERSISTENCE
-- ============================================
local speedHackConn = RunService.Stepped:Connect(function()
    if not Toggles.SpeedHack then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Options.SpeedValue
    end
end)
table.insert(connections, speedHackConn)

-- ============================================
-- NOCLIP
-- ============================================
local noclipLastCFrame = nil

local noclipConn = RunService.Heartbeat:Connect(function()
    if not Toggles.NoClip then
        noclipLastCFrame = nil
        return
    end
    local char = LocalPlayer.Character
    if not char then noclipLastCFrame = nil return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then noclipLastCFrame = nil return end

    local currentCF = root.CFrame
    if noclipLastCFrame then
        local delta = (currentCF.Position - noclipLastCFrame.Position).Magnitude
        if delta > 8 then
            root.CFrame = noclipLastCFrame
            currentCF = noclipLastCFrame
        end
    end
    noclipLastCFrame = currentCF

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)
table.insert(connections, noclipConn)

-- ============================================
-- FLY HACK
-- ============================================
local stopFly

local function startFly()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = rootPart

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 9000
    flyBG.CFrame = Workspace.CurrentCamera.CFrame
    flyBG.Parent = rootPart

    flyActive = true
end

stopFly = function()
    flyActive = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local flyMoveConn = RunService.RenderStepped:Connect(function()
    if not Toggles.Fly or not flyActive then return end

    local char = LocalPlayer.Character
    if not char or not char.Parent then
        stopFly()
        return
    end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local cam = Workspace.CurrentCamera
    local speed = Options.FlySpeed
    local dir = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

    if dir.Magnitude > 0 then dir = dir.Unit end

    if flyBV then flyBV.Velocity = dir * speed end
    if flyBG then flyBG.CFrame = cam.CFrame end
end)
table.insert(connections, flyMoveConn)

-- ============================================
-- FULLBRIGHT
-- ============================================
local function enableFullbright()
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
end

local function disableFullbright()
    if originalLighting.stored then
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

-- ============================================
-- AUTO SPRINT
-- ============================================
local function startAutoSprint()
    if autoSprintActive then return end
    autoSprintActive = true
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
    end)
end

local function stopAutoSprint()
    if not autoSprintActive then return end
    autoSprintActive = false
    pcall(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
    end)
end

-- ============================================
-- ANTI-AFK
-- ============================================
local stopAntiAFK

local function startAntiAFK()
    stopAntiAFK()
    antiAFKConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    table.insert(connections, antiAFKConn)
end

stopAntiAFK = function()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
end

-- ============================================
-- AUTO PICKUP ITEM
-- ============================================
local autoPickupActive = false

local function getItemPrimaryPartForPickup(item)
    if item:IsA("Model") then
        if item.PrimaryPart then
            return item.PrimaryPart
        end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "Handle" then
                return child
            end
        end
        local handle = item:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle
        end
    end
    return nil
end

local function pickupItemViaRemote(item)
    if AdjustBackpack then
        local success = pcall(function()
            AdjustBackpack:FireServer(item)
        end)
        return success
    end
    return false
end

local function startAutoPickup()
    if autoPickupActive then return end
    
    if not Workspace:FindFirstChild("DroppedItems") then
        return
    end
    
    if not AdjustBackpack then
        return
    end
    
    autoPickupActive = true
    
    autoPickupConnection = RunService.Heartbeat:Connect(function()
        if not autoPickupActive then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local droppedItems = Workspace:FindFirstChild("DroppedItems")
        if not droppedItems then return end
        
        local myPos = hrp.Position
        
        -- Kumpulkan semua item dalam range
        local itemsToPickup = {}
        for _, item in ipairs(droppedItems:GetChildren()) do
            if item and item.Parent then
                local part = getItemPrimaryPartForPickup(item)
                if part and part.Parent then
                    local dist = (part.Position - myPos).Magnitude
                    if dist <= Options.AutoPickupRange then
                        table.insert(itemsToPickup, {
                            item = item,
                            dist = dist
                        })
                    end
                end
            end
        end
        
        -- Urutkan dari yang terdekat
        table.sort(itemsToPickup, function(a, b) 
            return a.dist < b.dist 
        end)
        
        -- Pickup item satu per satu
        for _, target in ipairs(itemsToPickup) do
            if not target.item.Parent then continue end
            
            local success = pcall(function()
                AdjustBackpack:FireServer(target.item)
            end)
            
            if success then
                task.wait(Options.AutoPickupDelay)
            end
            
            -- Jika tidak pickup all, berhenti setelah 1 item
            if not Options.AutoPickupAll then
                break
            end
        end
    end)
end

local function stopAutoPickup()
    autoPickupActive = false
    if autoPickupConnection then
        autoPickupConnection:Disconnect()
        autoPickupConnection = nil
    end
end

-- ============================================
-- KILL AURA
-- ============================================
local killAuraLastSwing = 0
local killAuraCurrentTarget = nil
local killAuraTargetDistance = nil

local function getWeaponSwingSpeed()
    local char = LocalPlayer.Character
    if not char then return 0.5 end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 0.5 end
    
    local toolName = tool.Name
    
    if weaponSwingSpeeds[toolName] then
        return weaponSwingSpeeds[toolName]
    end
    
    for weaponName, speed in pairs(weaponSwingSpeeds) do
        if string.find(toolName:lower(), weaponName:lower()) then
            return speed
        end
    end
    
    return 0.5
end

local function findTargetsInRange(range)
    local char = LocalPlayer.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    if not charactersFolder then return {} end

    local targets = {}
    local myPos = hrp.Position

    for _, mob in ipairs(charactersFolder:GetChildren()) do
        if mob == char then continue end
        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if not mobHRP or not mobHum then continue end
        if mobHum.Health <= 0 then continue end
        local dist = (mobHRP.Position - myPos).Magnitude
        if dist <= range then
            table.insert(targets, {
                mob = mob,
                dist = dist,
                health = mobHum.Health,
                maxHealth = mobHum.MaxHealth,
            })
        end
    end

    local priority = Options.KillAuraPriority
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
    if char:FindFirstChildOfClass("Tool") then return true end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end

    local bestTool = nil
    local bestSpeed = math.huge

    for _, tool in ipairs(backpack:GetChildren()) do
        if not tool:IsA("Tool") then continue end
        if not (tool:FindFirstChild("Swing") or tool:FindFirstChild("HitTargets") or tool:FindFirstChild("RemoteClick")) then continue end
        local speed = weaponSwingSpeeds[tool.Name] or 0.5
        for wName, s in pairs(weaponSwingSpeeds) do
            if string.find(tool.Name:lower(), wName:lower()) then speed = s break end
        end
        if speed < bestSpeed then
            bestSpeed = speed
            bestTool = tool
        end
    end

    if bestTool then
        pcall(function() bestTool.Parent = char end)
        return true
    end
    return false
end

local function stopKillAura()
    if killAuraConn then
        killAuraConn:Disconnect()
        killAuraConn = nil
    end
    killAuraLastSwing = 0
    killAuraCurrentTarget = nil
    killAuraTargetDistance = nil
    if killAuraIndicatorLine then killAuraIndicatorLine.Visible = false end
    if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
end

local function startKillAura()
    stopKillAura()

    if not killAuraIndicatorLine then
        killAuraIndicatorLine = Drawing.new("Line")
        killAuraIndicatorLine.Thickness = 1.5
        killAuraIndicatorLine.Color = Color3.fromRGB(255, 55, 55)
        killAuraIndicatorLine.Transparency = 0.65
        killAuraIndicatorLine.Visible = false
    end
    if not killAuraIndicatorCircle then
        killAuraIndicatorCircle = Drawing.new("Circle")
        killAuraIndicatorCircle.Thickness = 1.5
        killAuraIndicatorCircle.Color = Color3.fromRGB(255, 55, 55)
        killAuraIndicatorCircle.Transparency = 0.55
        killAuraIndicatorCircle.Filled = false
        killAuraIndicatorCircle.Visible = false
    end

    killAuraConn = RunService.RenderStepped:Connect(function()
        if not Toggles.KillAura then
            killAuraCurrentTarget = nil
            if killAuraIndicatorLine then killAuraIndicatorLine.Visible = false end
            if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
            return
        end

        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool and Toggles.KillAuraAutoEquip then
                autoEquipWeapon()
                tool = char:FindFirstChildOfClass("Tool")
            end

            if not tool then
                killAuraCurrentTarget = nil
                if killAuraIndicatorLine then killAuraIndicatorLine.Visible = false end
                if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
                return
            end

            local swing = tool:FindFirstChild("Swing")
            local hitTargets = tool:FindFirstChild("HitTargets")
            local remoteClick = tool:FindFirstChild("RemoteClick")

            local baseRange = Options.KillAuraRange
            local useExtendedRange = Toggles.KillAuraExtendedRange
            local attackRange = useExtendedRange and (baseRange + 2) or baseRange

            local targets = findTargetsInRange(attackRange)
            killAuraCurrentTarget = targets[1] and targets[1].mob or nil
            killAuraTargetDistance = targets[1] and targets[1].dist or nil

            local showIndicator = Toggles.KillAuraShowIndicator
            if showIndicator and killAuraCurrentTarget then
                local camera = Workspace.CurrentCamera
                if camera then
                    local tHRP = killAuraCurrentTarget:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        local sp, onScreen = camera:WorldToViewportPoint(tHRP.Position)
                        if onScreen and sp.Z > 0 then
                            local vp = camera.ViewportSize
                            local center = Vector2.new(vp.X / 2, vp.Y)
                            local tgt = Vector2.new(sp.X, sp.Y)
                            killAuraIndicatorLine.From = center
                            killAuraIndicatorLine.To = tgt
                            killAuraIndicatorLine.Visible = true
                            local radius = math.clamp(1200 / math.max(killAuraTargetDistance, 1), 8, 40)
                            killAuraIndicatorCircle.Position = tgt
                            killAuraIndicatorCircle.Radius = radius
                            killAuraIndicatorCircle.Visible = true
                        else
                            killAuraIndicatorLine.Visible = false
                            killAuraIndicatorCircle.Visible = false
                        end
                    end
                end
            else
                if killAuraIndicatorLine then killAuraIndicatorLine.Visible = false end
                if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
            end

            if #targets == 0 then return end

            local weaponSpeed = getWeaponSwingSpeed()
            local userSwingRate = Options.KillAuraSwingRate
            local effectiveSwingRate = math.max(weaponSpeed, userSwingRate)
            local now = tick()
            if now - killAuraLastSwing < effectiveSwingRate then return end

            local mobModels = {}
            for _, t in ipairs(targets) do
                table.insert(mobModels, t.mob)
            end

            local attackSuccess = false

            if swing and hitTargets then
                pcall(function() swing:FireServer() end)
                pcall(function() hitTargets:FireServer(mobModels) end)
                attackSuccess = true
            elseif remoteClick then
                pcall(function() remoteClick:FireServer(targets[1].mob) end)
                attackSuccess = true
            end

            if attackSuccess then
                killAuraLastSwing = now
            end
        end)
    end)
end

-- ============================================
-- AIMBOT
-- ============================================
local function stopAimbot()
    if aimbotConn then
        aimbotConn:Disconnect()
        aimbotConn = nil
    end
    aimbotTarget = nil
    if fovCircle then fovCircle.Visible = false end
end

local function getAimbotTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local viewportSize = camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    local fov = Options.AimbotFOV
    local maxRange = Options.AimbotRange
    local targetMode = Options.AimbotTarget
    local aimPart = Options.AimbotPart

    local bestTarget = nil
    local bestScore = math.huge

    local function isValidTarget(targetChar, targetRoot)
        if not targetChar or not targetRoot then return false end
        if targetChar == char then return false end

        local dist = (targetRoot.Position - myRoot.Position).Magnitude
        if dist > maxRange then return false end

        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then return false end

        local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
        if not onScreen then return false end

        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if fovDist > fov then return false end

        return true, dist, fovDist, screenPos
    end

    if targetMode == "Mobs" or targetMode == "Both" then
        if charactersFolder then
            for _, mob in ipairs(charactersFolder:GetChildren()) do
                if table.find(mobNames, mob.Name) then
                    local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob:FindFirstChild("UpperTorso")
                    local valid, dist, fovDist = isValidTarget(mob, mobRoot)
                    if valid then
                        local score = Options.AimbotPriority == "FOV" and fovDist or dist
                        if score < bestScore then
                            bestScore = score
                            bestTarget = {character = mob, rootPart = mobRoot}
                        end
                    end
                end
            end
        end
    end

    if targetMode == "Players" or targetMode == "Both" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pChar = player.Character
                if pChar then
                    local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                    local valid, dist, fovDist = isValidTarget(pChar, pRoot)
                    if valid then
                        local score = Options.AimbotPriority == "FOV" and fovDist or dist
                        if score < bestScore then
                            bestScore = score
                            bestTarget = {character = pChar, rootPart = pRoot}
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

local function startAimbot()
    stopAimbot()
    aimbotConn = RunService.RenderStepped:Connect(function()
        if not Toggles.Aimbot then
            if fovCircle then fovCircle.Visible = false end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end

        local camera = Workspace.CurrentCamera
        if not camera then return end

        local target = getAimbotTarget()
        aimbotTarget = target

        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Filled = false
            fovCircle.NumSides = 64
            fovCircle.Thickness = 1.5
            fovCircle.Transparency = 1
        end
        if Toggles.AimbotFOVCircle then
            local vp = camera.ViewportSize
            fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
            fovCircle.Radius = Options.AimbotFOV
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end

        if not target then return end

        local aimPartName = Options.AimbotPart
        local targetPart = target.character:FindFirstChild(aimPartName)

        if not targetPart or not targetPart:IsA("BasePart") then
            targetPart = target.rootPart
        end

        if not targetPart then return end

        local targetPos = targetPart.Position
        if Toggles.AimbotPrediction then
            local velocity = targetPart.AssemblyLinearVelocity
            local predictionAmount = Options.AimbotPredictionAmount
            targetPos = targetPos + (velocity * predictionAmount)
        end

        local myHead = char:FindFirstChild("Head")
        if not myHead then return end

        if aimPartName == "Head" then
            targetPos = targetPos + Vector3.new(0, 0.5, 0)
        end

        local smoothness = Options.AimbotSmoothness
        local smoothFactor = 1 - (smoothness * 0.95)

        local targetCFrame = CFrame.lookAt(myHead.Position, targetPos)

        if smoothness > 0 then
            targetCFrame = camera.CFrame:Lerp(targetCFrame, smoothFactor)
        end

        camera.CFrame = targetCFrame
    end)
end

-- ============================================
-- REMOVE FOG
-- ============================================
local fogOriginalStates = {}
local fogObjects = {}
local fogFEConns = {}

local function makeFogObjectInvisible(obj)
    pcall(function()
        local originalState = {}
        
        if obj:IsA("BasePart") then
            originalState.Transparency = obj.Transparency
            originalState.Material = obj.Material
            obj.Transparency = 1
            obj.Material = Enum.Material.Air
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Light") or obj:IsA("Highlight") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalState.Transparency = obj.Transparency
            obj.Transparency = 1
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            for _, child in ipairs(obj:GetDescendants()) do
                makeFogObjectInvisible(child)
            end
        end
    end)
end

local function restoreFogObjectVisibility(obj)
    if fogOriginalStates[obj] then
        pcall(function()
            local state = fogOriginalStates[obj]
            if obj:IsA("BasePart") then
                obj.Transparency = state.Transparency
                obj.Material = state.Material
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Light") or obj:IsA("Highlight") then
                obj.Enabled = state.Enabled
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = state.Transparency
            end
        end)
    end
end

local function enableRemoveFog()
    if not originalFog.stored then
        originalFog.FogEnd = Lighting.FogEnd
        originalFog.FogStart = Lighting.FogStart
        originalFog.stored = true
    end
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0

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

    for _, conn in ipairs(fogFEConns) do pcall(function() conn:Disconnect() end) end
    fogFEConns = {}

    table.insert(fogFEConns, Lighting.Changed:Connect(function(prop)
        if not Toggles.RemoveFog then return end
        if prop == "FogEnd" then Lighting.FogEnd = 100000 end
        if prop == "FogStart" then Lighting.FogStart = 0 end
    end))

    local fogFolder = Workspace:FindFirstChild("Fog")
    if fogFolder then
        fogOriginalStates = {}
        fogObjects = {}

        for _, child in ipairs(fogFolder:GetChildren()) do
            table.insert(fogObjects, child)
            makeFogObjectInvisible(child)
        end

        table.insert(fogFEConns, fogFolder.ChildAdded:Connect(function(child)
            if not Toggles.RemoveFog then return end
            makeFogObjectInvisible(child)
        end))
    end
end

local function disableRemoveFog()
    for _, conn in ipairs(fogFEConns) do pcall(function() conn:Disconnect() end) end
    fogFEConns = {}

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

    for obj, _ in pairs(fogOriginalStates) do
        restoreFogObjectVisibility(obj)
    end

    fogOriginalStates = {}
    fogObjects = {}
end

-- ============================================
-- BUNNY HOP
-- ============================================
local function stopBhop()
    if bhopConn then
        bhopConn:Disconnect()
        bhopConn = nil
    end
    bhopActive = false
end

local function startBhop()
    stopBhop()
    bhopActive = true
    
    bhopConn = RunService.RenderStepped:Connect(function()
        if not Toggles.BunnyHop then return end
        
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
end

-- ============================================
-- AUTO HUNT ZOMBIE (WORM-GPT v7 LOGIC)
-- ============================================
-- Fungsi anti hit (noclip tanpa teleport)
local function huntAntiHit()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Loop anti hit untuk auto hunt
local function startHuntAntiHitLoop()
    RunService.RenderStepped:Connect(function()
        if not hunting then return end
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Cari zombie terdekat
local function cariZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local mobFolder = Workspace:FindFirstChild("Characters")
    if not mobFolder then return nil end
    
    local myPos = hrp.Position
    local terdekat = nil
    local jarakTerdekat = Options.HuntRange + 1
    
    for _, mob in ipairs(mobFolder:GetChildren()) do
        local isZombie = false
        for _, nama in ipairs(mobNames) do
            if mob.Name == nama then
                isZombie = true
                break
            end
        end
        if not isZombie then continue end
        
        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
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

-- Auto equip weapon untuk auto hunt
local function huntAutoEquipWeapon()
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

-- Serang target untuk auto hunt
local function huntSerang(target)
    if not target then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        huntAutoEquipWeapon()
    end
    
    local senjata = char:FindFirstChildOfClass("Tool")
    if not senjata then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    
    local jarak = (targetHrp.Position - hrp.Position).Magnitude
    if jarak > Options.HuntKillRange then return end
    
    local now = tick()
    if now - huntLastSwing >= Options.HuntSwingSpeed then
        local swing = senjata:FindFirstChild("Swing")
        local hit = senjata:FindFirstChild("HitTargets")
        local click = senjata:FindFirstChild("RemoteClick")
        
        if swing and hit then
            pcall(function() swing:FireServer() end)
            pcall(function() hit:FireServer({target}) end)
            huntLastSwing = now
        elseif click then
            pcall(function() click:FireServer(target) end)
            huntLastSwing = now
        else
            pcall(function() senjata:Activate() end)
            huntLastSwing = now
        end
        
        -- Double attack
        task.defer(function()
            if swing and hit then
                pcall(function() swing:FireServer() end)
                pcall(function() hit:FireServer({target}) end)
            end
        end)
    end
end

-- Mulai fly mode untuk auto hunt
local function huntMulaiFly()
    if huntingFlyActive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = true 
        hum.AutoRotate = false
    end
    
    huntFlyBV = Instance.new("BodyVelocity")
    huntFlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    huntFlyBV.Velocity = Vector3.new(0, 0, 0)
    huntFlyBV.Parent = hrp
    
    huntFlyBG = Instance.new("BodyGyro")
    huntFlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    huntFlyBG.P = 9000
    huntFlyBG.CFrame = Workspace.CurrentCamera.CFrame
    huntFlyBG.Parent = hrp
    
    huntingFlyActive = true
end

-- Terbang ke zombie (posisi di atas)
local function huntTerbangKeZombie(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetPosAtas = Vector3.new(targetPos.X, targetPos.Y + Options.HuntFlyHeight, targetPos.Z)
    local arah = (targetPosAtas - hrp.Position).Unit
    local jarak = (targetPosAtas - hrp.Position).Magnitude
    
    if huntFlyBV then
        local speed = math.min(Options.HuntFlySpeed, jarak * 2)
        huntFlyBV.Velocity = arah * speed
    end
    
    if huntFlyBG then
        local lookAt = CFrame.lookAt(hrp.Position, targetPosAtas)
        huntFlyBG.CFrame = lookAt
    end
end

-- Matikan fly mode auto hunt
local function huntMatikanFly()
    huntingFlyActive = false
    if huntFlyBV then huntFlyBV:Destroy() huntFlyBV = nil end
    if huntFlyBG then huntFlyBG:Destroy() huntFlyBG = nil end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
    end
end

-- Loop utama auto hunt
local function huntMulaiLoop()
    if huntConn then huntConn:Disconnect() end
    
    huntConn = RunService.RenderStepped:Connect(function()
        if not hunting then return end
        
        pcall(function()
            -- Anti hit (hanya collide, tanpa CFrame)
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            
            local target = cariZombie()
            
            if target then
                local targetHrp = target:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local jarak = (targetHrp.Position - hrp.Position).Magnitude
                            
                            -- Serang
                            if jarak <= Options.HuntKillRange then
                                huntSerang(target)
                                huntSerang(target) -- double attack
                            end
                            
                            -- Aktifkan fly jika belum
                            if not huntingFlyActive then
                                huntMulaiFly()
                            end
                            
                            -- Terbang ke atas zombie
                            huntTerbangKeZombie(targetHrp.Position)
                        end
                    end
                end
            else
                -- Tidak ada target, diam
                if huntFlyBV then
                    huntFlyBV.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end)
end

-- Start Auto Hunt
local function startAutoHunt()
    if hunting then return end
    hunting = true
    startHuntAntiHitLoop()
    huntMulaiFly()
    huntMulaiLoop()
    print("[AUTO HUNT] ON - FIXED!")
end

-- Stop Auto Hunt
local function stopAutoHunt()
    hunting = false
    if huntConn then
        huntConn:Disconnect()
        huntConn = nil
    end
    huntMatikanFly()
    print("[AUTO HUNT] OFF")
end

-- ============================================
-- SERVER HOP / REJOIN
-- ============================================
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local req = syn and syn.request or http_request or request or httprequest

    if req then
        local cursor = ""
        for _ = 1, 3 do
            local url = "https://games.roblox.com/v1/games/" .. placeId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if not ok or not response or not response.Body then break end

            local ok2, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            if not ok2 or not data or not data.data then break end

            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end

            local nextCursor = data.nextPageCursor
            if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
            cursor = tostring(nextCursor)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
        Window:Notify("Server Hop", "Joining new server...", 3)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
        Window:Notify("Server Hop", "No servers found, re-matchmaking...", 3)
    end
end

local function rejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId

    if not jobId or jobId == "" then
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
        Window:Notify("Rejoin", "Rejoining via matchmaking...", 3)
        return
    end

    Window:Notify("Rejoin", "Rejoining server...", 2)

    local ok1, err1 = pcall(function()
        local opts = Instance.new("TeleportOptions")
        opts.ServerInstanceId = jobId
        TeleportService:TeleportAsync(placeId, { LocalPlayer }, opts)
    end)
    if ok1 then return end

    local ok2, err2 = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
    if ok2 then return end

    pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
end

-- ============================================
-- BRING PICKUP ITEM
-- ============================================
local bringPickupActive = false
local bringPickupThread = nil

local function stopBringPickup()
    bringPickupActive = false
    if bringPickupThread then
        task.cancel(bringPickupThread)
        bringPickupThread = nil
    end
end

local function startBringPickup()
    stopBringPickup()
    bringPickupActive = true

    bringPickupThread = task.spawn(function()
        local MAX_TIMEOUTS = 3
        local consecutiveTimeouts = 0

        while bringPickupActive and Toggles.BringPickupItem do
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end
            if not droppedItemsFolder then task.wait(1) continue end

            local playerPos = rootPart.Position
            local allSelected = Toggles.BringAllPickup
            local whitelist = {}

            local targets = {}
            for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                if not pickupItemSet[item.Name] then continue end
                local mp = item.PrimaryPart or getItemMainPart(item)
                if not mp then continue end
                local d = (mp.Position - playerPos).Magnitude
                if not allSelected then
                    if not whitelist[item.Name] then continue end
                end
                table.insert(targets, { item = item, part = mp, dist = d })
            end

            if #targets == 0 then task.wait(0.5) continue end

            local sortOrder = Options.BringPickupSortOrder
            if sortOrder == "Nearest First" then
                table.sort(targets, function(a, b) return a.dist < b.dist end)
            elseif sortOrder == "Farthest First" then
                table.sort(targets, function(a, b) return a.dist > b.dist end)
            elseif sortOrder == "Alphabetical" then
                table.sort(targets, function(a, b) return a.item.Name < b.item.Name end)
            elseif sortOrder == "Reverse Alphabetical" then
                table.sort(targets, function(a, b) return a.item.Name > b.item.Name end)
            end

            for _, target in ipairs(targets) do
                if not bringPickupActive then break end
                if not target.item.Parent then continue end

                local itemRef = target.item
                local partRef = target.part
                local targetCF = CFrame.new(partRef.Position + Vector3.new(0, 2, 0))
                local deadline = tick() + 2.0

                while tick() < deadline and itemRef.Parent do
                    rootPart.CFrame = targetCF
                    pcall(function()
                        if pickUpItemRemote then pickUpItemRemote:FireServer(itemRef) end
                    end)
                    task.wait(0.05)
                end

                if itemRef.Parent == nil then
                    consecutiveTimeouts = 0
                else
                    consecutiveTimeouts = consecutiveTimeouts + 1
                    if consecutiveTimeouts >= MAX_TIMEOUTS then
                        bringPickupActive = false
                        task.defer(function()
                            Toggles.BringPickupItem = false
                            Window:Notify("Bring Pickup Item", "Backpack full – auto disabled.", 4)
                        end)
                        return
                    end
                end
            end
        end

        bringPickupActive = false
    end)
end

-- ============================================
-- PLAYER JOIN / LEAVE LISTENERS
-- ============================================
local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    if playerESPVars.ESP then
        task.wait(2)
        createPlayerESP(player)
    end
end)
table.insert(connections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)
table.insert(connections, playerRemovingConn)

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
LocalPlayer.CharacterRemoving:Connect(function()
    if flyActive then stopFly() end
    if autoSprintActive then stopAutoSprint() end
    if hunting then stopAutoHunt() end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    if Toggles.Fly then startFly() end
    if Toggles.AutoSprint then startAutoSprint() end
    if Toggles.AutoHunt then
        task.wait(1)
        startAutoHunt()
    end
end)

-- ============================================
-- INFINITE JUMP
-- ============================================
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)
table.insert(connections, jumpConn)

-- ============================================
-- UI: VISUALS TAB
-- ============================================
local espSettingsSection = VisualsTab:Section({ Title = "ESP Settings" })

espSettingsSection:Toggle({
    Title = "Show Names",
    Default = false,
    Callback = function(value)
        mobOptions.Name = value
        playerESPVars.Name = value
        structureESPVars.Name = value
        crateOptions.Name = value
        for _, sys in pairs(espSystems) do
            sys.vars.Name = value
            sys.refresh()
        end
        refreshMobESP()
        refreshPlayerESP()
        refreshStructureESP()
        refreshCrateESP()
    end
})

espSettingsSection:Toggle({
    Title = "Show Distance",
    Default = false,
    Callback = function(value)
        mobOptions.Distance = value
        playerESPVars.Distance = value
        structureESPVars.Distance = value
        crateOptions.Distance = value
        for _, sys in pairs(espSystems) do
            sys.vars.Distance = value
            sys.refresh()
        end
        refreshMobESP()
        refreshPlayerESP()
        refreshStructureESP()
        refreshCrateESP()
    end
})

-- Mob ESP Section
local mobSection = VisualsTab:Section({ Title = "Mob ESP" })

mobSection:Toggle({
    Title = "Mob ESP",
    Default = false,
    Callback = function(value)
        mobOptions.ESP = value
        refreshMobESP()
    end
})

mobSection:Toggle({
    Title = "Mob Chams",
    Default = false,
    Callback = function(value)
        mobOptions.Chams = value
        refreshMobESP()
    end
})

-- Player ESP Section
local playerSection = VisualsTab:Section({ Title = "Player ESP" })

playerSection:Toggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(value)
        playerESPVars.ESP = value
        refreshPlayerESP()
    end
})

playerSection:Toggle({
    Title = "Player Chams",
    Default = false,
    Callback = function(value)
        playerESPVars.Chams = value
        refreshPlayerESP()
    end
})

playerSection:Toggle({
    Title = "Show Health",
    Default = false,
    Callback = function(value)
        playerESPVars.Health = value
        refreshPlayerESP()
    end
})

-- Structure ESP Section
local structureSection = VisualsTab:Section({ Title = "Structure ESP" })

structureSection:Toggle({
    Title = "Structure ESP",
    Default = false,
    Callback = function(value)
        structureESPVars.ESP = value
        refreshStructureESP()
    end
})

structureSection:Toggle({
    Title = "Structure Chams",
    Default = false,
    Callback = function(value)
        structureESPVars.Chams = value
        refreshStructureESP()
    end
})

-- ============================================
-- CRATES ESP SECTION (DITAMBAHKAN)
-- ============================================
local cratesSection = VisualsTab:Section({ Title = "Crates ESP" })

cratesSection:Toggle({
    Title = "Crates ESP",
    Default = false,
    Callback = function(value)
        crateOptions.ESP = value
        refreshCrateESP()
    end
})

cratesSection:Toggle({
    Title = "Crates Chams",
    Default = false,
    Callback = function(value)
        crateOptions.Chams = value
        refreshCrateESP()
    end
})

-- Item ESP Section
local itemSection = VisualsTab:Section({ Title = "Item ESP" })

itemSection:Toggle({
    Title = "Chams (All Categories)",
    Default = false,
    Callback = function(value)
        for _, sys in pairs(espSystems) do
            sys.vars.Chams = value
            sys.refresh()
        end
    end
})

local itemESPList = {
    { key = "Gun", text = "Gun ESP" },
    { key = "Melee", text = "Melee ESP" },
    { key = "Medical", text = "Medical ESP" },
    { key = "Armor", text = "Armor ESP" },
    { key = "Food", text = "Food ESP" },
    { key = "Resource", text = "Resources ESP" },
    { key = "Fuel", text = "Fuel ESP" },
    { key = "Ability", text = "Abilities ESP" },
}

for _, d in ipairs(itemESPList) do
    itemSection:Toggle({
        Title = d.text,
        Default = false,
        Callback = function(value)
            espSystems[d.key].vars.ESP = value
            espSystems[d.key].refresh()
        end
    })
end

-- ============================================
-- UI: PLAYER TAB
-- ============================================
local movementSection = PlayerTab:Section({ Title = "Movement" })

movementSection:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(value)
        Toggles.SpeedHack = value
        if value then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    originalValues.walkSpeed = humanoid.WalkSpeed
                end
            end
            Window:Notify("Speed Hack", "Enabled", 2)
        else
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = originalValues.walkSpeed or 16
                end
            end
            Window:Notify("Speed Hack", "Disabled", 2)
        end
    end
})

movementSection:Slider({
    Title = "Speed Value",
    Description = "Custom walk speed (16-120)",
    Value = { Min = 16, Default = 50, Max = 120 },
    Callback = function(value)
        Options.SpeedValue = value
        if Toggles.SpeedHack then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end
    end
})

movementSection:Toggle({
    Title = "Inf Jump",
    Default = false,
    Callback = function(value)
        Toggles.InfJump = value
        Window:Notify("Inf Jump", value and "Enabled" or "Disabled", 2)
    end
})

movementSection:Toggle({
    Title = "NoClip",
    Default = false,
    Callback = function(value)
        Toggles.NoClip = value
        Window:Notify("NoClip", value and "Enabled" or "Disabled", 2)
    end
})

movementSection:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(value)
        Toggles.Fly = value
        if value then
            startFly()
            Window:Notify("Fly", "Enabled - WASD to move, Space/Shift for up/down", 3)
        else
            stopFly()
            Window:Notify("Fly", "Disabled", 2)
        end
    end
})

movementSection:Toggle({
    Title = "Auto Sprint",
    Default = false,
    Callback = function(value)
        Toggles.AutoSprint = value
        if value then
            startAutoSprint()
            Window:Notify("Auto Sprint", "Enabled", 2)
        else
            stopAutoSprint()
            Window:Notify("Auto Sprint", "Disabled", 2)
        end
    end
})

movementSection:Toggle({
    Title = "Bunny Hop",
    Default = false,
    Callback = function(value)
        Toggles.BunnyHop = value
        if value then
            startBhop()
            Window:Notify("Bunny Hop", "Enabled", 2)
        else
            stopBhop()
            Window:Notify("Bunny Hop", "Disabled", 2)
        end
    end
})

-- ============================================
-- UI: COMBAT TAB
-- ============================================
local killAuraSection = CombatTab:Section({ Title = "Kill Aura" })

killAuraSection:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(value)
        Toggles.KillAura = value
        if value then
            startKillAura()
            Window:Notify("Kill Aura", "Enabled", 2)
        else
            stopKillAura()
            Window:Notify("Kill Aura", "Disabled", 2)
        end
    end
})

-- SLIDER AURA RANGE - DITAMBAHKAN SESUAI PERMINTAAN
killAuraSection:Slider({
    Title = "Aura Range",
    Description = "Jarak serangan Kill Aura (3-25 studs)",
    Value = { Min = 3, Default = 6, Max = 25 },
    Callback = function(value)
        Options.KillAuraRange = value
    end
})

killAuraSection:Dropdown({
    Title = "Target Priority",
    Values = { "Nearest", "Lowest HP", "Highest HP" },
    Default = 1,
    Callback = function(value)
        Options.KillAuraPriority = value
    end
})

killAuraSection:Toggle({
    Title = "Auto-Equip Weapon",
    Default = false,
    Callback = function(value)
        Toggles.KillAuraAutoEquip = value
    end
})

killAuraSection:Toggle({
    Title = "Show Target Indicator",
    Default = true,
    Callback = function(value)
        Toggles.KillAuraShowIndicator = value
    end
})

killAuraSection:Toggle({
    Title = "Extended Range (+2 studs)",
    Default = true,
    Callback = function(value)
        Toggles.KillAuraExtendedRange = value
    end
})

-- Aimbot Section
local aimbotSection = CombatTab:Section({ Title = "Aimbot" })

aimbotSection:Toggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(value)
        Toggles.Aimbot = value
        if value then
            startAimbot()
            Window:Notify("Aimbot", "Enabled", 2)
        else
            stopAimbot()
            Window:Notify("Aimbot", "Disabled", 2)
        end
    end
})

aimbotSection:Dropdown({
    Title = "Target Mode",
    Values = { "Mobs", "Players", "Both" },
    Default = 1,
    Callback = function(value)
        Options.AimbotTarget = value
    end
})

aimbotSection:Dropdown({
    Title = "Aim Part",
    Values = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
    Default = 1,
    Callback = function(value)
        Options.AimbotPart = value
    end
})

aimbotSection:Dropdown({
    Title = "Target Priority",
    Values = { "Distance", "FOV" },
    Default = 1,
    Callback = function(value)
        Options.AimbotPriority = value
    end
})

aimbotSection:Toggle({
    Title = "Velocity Prediction",
    Default = false,
    Callback = function(value)
        Toggles.AimbotPrediction = value
    end
})

aimbotSection:Toggle({
    Title = "FOV Circle",
    Default = false,
    Callback = function(value)
        Toggles.AimbotFOVCircle = value
    end
})

-- Auto Hunt Section
local autoHuntSection = CombatTab:Section({ Title = "Auto Hunt Zombie" })

autoHuntSection:Toggle({
    Title = "Auto Hunt",
    Default = false,
    Callback = function(value)
        Toggles.AutoHunt = value
        if value then
            startAutoHunt()
            Window:Notify("Auto Hunt", "Enabled - Flying to zombies!", 2)
        else
            stopAutoHunt()
            Window:Notify("Auto Hunt", "Disabled", 2)
        end
    end
})

autoHuntSection:Slider({
    Title = "Hunt Range",
    Description = "Detection range (500-9999)",
    Value = { Min = 500, Default = 9999, Max = 9999 },
    Callback = function(value)
        Options.HuntRange = value
    end
})

autoHuntSection:Slider({
    Title = "Fly Speed",
    Description = "Movement speed (50-300)",
    Value = { Min = 50, Default = 120, Max = 300 },
    Callback = function(value)
        Options.HuntFlySpeed = value
    end
})

autoHuntSection:Slider({
    Title = "Kill Range",
    Description = "Attack distance (10-50)",
    Value = { Min = 10, Default = 25, Max = 50 },
    Callback = function(value)
        Options.HuntKillRange = value
    end
})

autoHuntSection:Slider({
    Title = "Swing Speed",
    Description = "Attack speed (0.001-0.05)",
    Value = { Min = 0.001, Default = 0.010, Max = 0.05, Decimal = true },
    Callback = function(value)
        Options.HuntSwingSpeed = value
    end
})

autoHuntSection:Slider({
    Title = "Fly Height",
    Description = "Height above zombie (3-15)",
    Value = { Min = 3, Default = 7, Max = 15 },
    Callback = function(value)
        Options.HuntFlyHeight = value
    end
})

-- ============================================
-- UI: EXPLOITS TAB
-- ============================================
-- Auto Pickup Section
local autoPickupSection = ExploitsTab:Section({ Title = "Auto Pickup Item" })

autoPickupSection:Toggle({
    Title = "Auto Pickup",
    Default = false,
    Callback = function(value)
        if value then
            startAutoPickup()
            Window:Notify("Auto Pickup", "Enabled - Using AdjustBackpack", 2)
        else
            stopAutoPickup()
            Window:Notify("Auto Pickup", "Disabled", 2)
        end
    end
})

autoPickupSection:Toggle({
    Title = "Pickup All Items",
    Default = true,
    Callback = function(value)
        Options.AutoPickupAll = value
    end
})

autoPickupSection:Slider({
    Title = "Pickup Range",
    Description = "Distance to pickup items (12-200)",
    Value = { Min = 12, Default = 50, Max = 200 },
    Callback = function(value)
        Options.AutoPickupRange = value
    end
})

autoPickupSection:Slider({
    Title = "Pickup Delay",
    Description = "Delay between pickups (0.05-1)",
    Value = { Min = 0.05, Default = 0.1, Max = 1, Decimal = true },
    Callback = function(value)
        Options.AutoPickupDelay = value
    end
})

-- Bring Pickup Section
local bringSection = ExploitsTab:Section({ Title = "Bring Pickup Item" })

bringSection:Toggle({
    Title = "Bring Pickup Item",
    Default = false,
    Callback = function(value)
        Toggles.BringPickupItem = value
        if value then
            startBringPickup()
            Window:Notify("Bring Pickup Item", "Enabled!", 2)
        else
            stopBringPickup()
            Window:Notify("Bring Pickup Item", "Disabled", 2)
        end
    end
})

bringSection:Toggle({
    Title = "All Pickup Items",
    Default = false,
    Callback = function(value)
        Toggles.BringAllPickup = value
    end
})

bringSection:Dropdown({
    Title = "Sort Order",
    Values = { "Nearest First", "Farthest First", "Alphabetical", "Reverse Alphabetical" },
    Default = 1,
    Callback = function(value)
        Options.BringPickupSortOrder = value
    end
})

-- ============================================
-- UI: MISC TAB
-- ============================================
local utilitySection = MiscTab:Section({ Title = "Utilities" })

utilitySection:Toggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(value)
        Toggles.AntiAFK = value
        if value then
            startAntiAFK()
            Window:Notify("Anti-AFK", "Enabled", 2)
        else
            stopAntiAFK()
            Window:Notify("Anti-AFK", "Disabled", 2)
        end
    end
})

utilitySection:Toggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(value)
        Toggles.Fullbright = value
        if value then
            enableFullbright()
            Window:Notify("Fullbright", "Enabled", 2)
        else
            disableFullbright()
            Window:Notify("Fullbright", "Disabled", 2)
        end
    end
})

utilitySection:Toggle({
    Title = "Remove Fog",
    Default = false,
    Callback = function(value)
        Toggles.RemoveFog = value
        if value then
            enableRemoveFog()
            Window:Notify("Remove Fog", "Enabled", 2)
        else
            disableRemoveFog()
            Window:Notify("Remove Fog", "Disabled", 2)
        end
    end
})

-- Server Tools Section
local serverSection = MiscTab:Section({ Title = "Server Tools" })

serverSection:Button({
    Title = "Server Hop",
    Callback = function()
        serverHop()
    end
})

serverSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        rejoinServer()
    end
})

-- ============================================
-- UI: COMMUNITY TAB
-- ============================================
local whatsappSection = CommunityTab:Section({ Title = "WhatsApp Group" })

whatsappSection:Button({
    Title = "Join WhatsApp Group",
    Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
            Window:Notify("Success", "WhatsApp link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

local discordSection = CommunityTab:Section({ Title = "Discord Server" })

discordSection:Button({
    Title = "Join Discord Server",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eDbaHKEf7G")
            Window:Notify("Success", "Discord link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

-- ============================================
-- INISIALISASI CRATES ESP
-- ============================================
task.wait(1)
setupCrateListeners()
refreshCrateESP()

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
Window:Open()

print("PinatHub Loaded")
