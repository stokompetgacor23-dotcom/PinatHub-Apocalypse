-- =======================================================
-- PINATHUB - CONFIGURATION MODULE
-- =======================================================

local Config = {}

-- Default Options
Config.Options = {
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
    AutoPickupRange = 50,
    AutoPickupDelay = 0.1,
    AutoPickupAll = true,
    HuntRange = 9999,
    HuntFlySpeed = 120,
    HuntKillRange = 25,
    HuntSwingSpeed = 0.010,
    HuntFlyHeight = 7,
    FuelHuntRange = 500,
    FuelFlySpeed = 80,
    FuelPickupRange = 10,
}

-- Default Toggles
Config.Toggles = {
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
    ProximityPromptAntiDelay = false,
    AutoDestroyStructure = false,
    AutoHuntFuel = false,
}

-- Weapon swing speeds
Config.WeaponSwingSpeeds = {
    ["Knife"] = 0.25, ["Katana"] = 0.3, ["Crowbar"] = 0.35,
    ["Bat"] = 0.45, ["Spiked Bat"] = 0.45, ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4, ["Spear"] = 0.4, ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6, ["Chainsaw"] = 0.35, ["Riot Shield"] = 0.5,
}

-- Mob names
Config.MobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- Structure names
Config.StructureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower"
}

-- Pickup item set
Config.PickupItemSet = {
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

-- ESP Definitions
Config.ESPDefinitions = {
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

-- Supported maps for info tab
Config.SupportedMaps = {
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

-- Crate options
Config.CrateOptions = {
    ESP = false,
    Chams = false,
    Name = false,
    Distance = false,
    MaxDistance = 500,
    ChamsColor = Color3.fromRGB(255, 200, 50),
    OutlineColor = Color3.fromRGB(255, 255, 255)
}

-- Helper to create mutable config copy
function Config.new()
    local config = {}
    
    function config:GetOptions()
        return Config.Options
    end
    
    function config:GetToggles()
        return Config.Toggles
    end
    
    function config:GetWeaponSwingSpeeds()
        return Config.WeaponSwingSpeeds
    end
    
    function config:GetMobNames()
        return Config.MobNames
    end
    
    function config:GetStructureNames()
        return Config.StructureNames
    end
    
    function config:GetPickupItemSet()
        return Config.PickupItemSet
    end
    
    function config:GetESPDefinitions()
        return Config.ESPDefinitions
    end
    
    function config:GetSupportedMaps()
        return Config.SupportedMaps
    end
    
    function config:GetCrateOptions()
        return Config.CrateOptions
    end
    
    return config
end

return Config
