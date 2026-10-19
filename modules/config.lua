-- =======================================================
-- PINATHUB - CONFIGURATION MODULE (ENHANCED FOR LATEST GAME DUMP)
-- Contains complete mob lists, item sets, tiers, and options
-- =======================================================

local Config = {}

-- Default Options
Config.Options = {
    ESPMaxDistance = 500,
    SpeedValue = 50,
    FlySpeed = 50,
    KillAuraRange = 8,
    KillAuraSwingRate = 0.5,
    KillAuraTargetMode = "Mobs", -- "Mobs", "Players", "Both"
    AimbotRange = 250,
    AimbotFOV = 120,
    AimbotSmoothness = 0.2,
    AimbotPredictionAmount = 0.15,
    PickupRadius = 25,
    FPSCap = 144,
    KillAuraPriority = "Nearest",
    AimbotTarget = "Mobs",
    AimbotPart = "Head",
    AimbotPriority = "Distance",
    BringPickupSortOrder = "Nearest First",
    AutoPickupRange = 50,
    AutoPickupDelay = 0.08,
    AutoPickupAll = true,
    HuntRange = 9999,
    HuntFlySpeed = 120,
    HuntKillRange = 25,
    HuntSwingSpeed = 0.010,
    HuntFlyHeight = 7,
    FuelHuntRange = 500,
    FuelFlySpeed = 80,
    AutoOpenCrateRange = 18,
    FuelPickupRange = 10,
    FireRateMultiplier = 2.0,
    ReloadSpeedMultiplier = 2.0,
    SelectedClass = "GOD HYBRID",
    ClassLevel = 3,
    SelectedPerk = "Specialist",
    SuperDragRange = 500,
    AutoHealThreshold = 50,
    InstantHealThreshold = 40,
    DamageReductionPercent = 75,
    SuperRegenRate = 15,
    MegaMapRevealSize = 10,
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
    KillAuraAutoEquip = true,
    KillAuraShowIndicator = true,
    KillAuraExtendedRange = true,
    Aimbot = false,
    AimbotPrediction = false,
    AimbotFOVCircle = false,
    SilentAim = false,
    NoRecoil = false,
    NoSpread = false,
    FastReload = false,
    RapidFire = false,
    AntiAFK = true,
    Fullbright = false,
    RemoveFog = false,
    FPSUnlock = false,
    AutoPickup = false,
    AllItems = false,
    AutoHunt = false,
    InstantProximityPrompt = false,
    AutoHuntFuel = false,
    AutoOpenCrate = false,
    NativeItemESP = false,
    AntiHungerDrain = false,
    ItemTierColors = true,
    FakeClass = false,
    ForceMaxClassLevel = false,
    PerkBypass = false,
    AllPerksActive = false,
    InfiniteAmmo = false,
    AntiSlowdown = false,
    BackpackUnlocker = false,
    Untouchable = false,
    Untargetable = false,
    SuperDrag = false,
    AutoHeal = false,
    InstantHeal = false,
    SuperRegen = false,
    DamageReduction = false,
    PsychicShield = false,
    StatusImmunity = false,
    InstantRevive = false,
    MegaMapReveal = false,
}

-- Game Classes List (24 Classes + God Hybrid)
Config.Classes = {
    "GOD HYBRID", "Survivor", "Policeman", "Scavenger", "Fighter",
    "Engineer", "Assassin", "Soldier", "Guardian", "Medic",
    "Necromancer", "Clockmaster", "Hunter", "Commander", "Fragger",
    "Farmer", "Psychic", "Berserker", "Explorer", "Stalker",
    "Operator", "Alchemist", "Outlaw", "Vanguard", "Hacker"
}

-- Game Perks List (21 Perks)
Config.Perks = {
    "Specialist", "Acrobat", "Shadowshot", "Agile", "Marksman",
    "Overclock", "Determined", "Immune", "Healthy", "Nimble",
    "Recovery", "Double Tap", "Quick Hands", "Strong", "Accurate",
    "Endurance", "Tough", "Stealthy", "Builder", "Lucky", "Adaptable"
}

-- Weapon swing speeds
Config.WeaponSwingSpeeds = {
    ["Knife"] = 0.25, ["Katana"] = 0.3, ["Crowbar"] = 0.35,
    ["Bat"] = 0.45, ["Spiked Bat"] = 0.45, ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4, ["Spear"] = 0.4, ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6, ["Chainsaw"] = 0.35, ["Riot Shield"] = 0.5,
    ["Power Hammer"] = 0.45, ["Scorchblade"] = 0.35,
}

-- Full Mob Names from game dump (StarterPlayerScripts / TrollGUI & Combat modules)
Config.MobNames = {
    "Zombie", "Crawler", "Brute", "Phaser", "Spitter",
    "Experiment", "Harbinger", "Elemental", "Exterminator", "Night Hunter",
    "Cyborg", "Heavy Rebel", "Rebel", "Gunner", "Sniper",
    "Bandit", "Merchant", "Juggernaut", "Butcher", "Riot",
    "Runner", "Boss"
}

-- Structure names
Config.StructureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower",
    "Barrel", "Scrap Pile"
}

-- Comprehensive Pickup item set from game dump
Config.PickupItemSet = {
    -- Ammo
    ["Ammo Box"] = true, ["Long Ammo"] = true, ["Medium Ammo"] = true,
    ["Shells"] = true, ["Pistol Ammo"] = true,
    
    -- Armor
    ["Power Armor"] = true, ["Light Armor"] = true, ["Medium Armor"] = true, ["Heavy Armor"] = true,
    
    -- Items & Currency
    ["Emerald"] = true, ["Gas Mask"] = true, ["Blood Gem"] = true, ["Data Coin"] = true,
    
    -- Structures & Breakables
    ["Ammo Crate"] = true, ["Barbed Wire"] = true, ["Bear Trap"] = true, ["Boost Pad"] = true,
    ["Electric Fence"] = true, ["Farm Plot"] = true, ["Fence"] = true, ["Floodlight"] = true,
    ["Gate"] = true, ["Landmine"] = true, ["Map"] = true, ["Repair Drone"] = true, ["Shelf"] = true,
    ["Teleporter"] = true, ["Time Machine"] = true, ["Turret"] = true, ["Wall"] = true, ["Watchtower"] = true,
    ["Barrel"] = true, ["Scrap Pile"] = true,
    
    -- Backpacks
    ["Basic Backpack"] = true, ["Good Backpack"] = true, ["Great Backpack"] = true,
    
    -- Consumables & Throwables
    ["Grenade"] = true, ["Molotov"] = true,
    
    -- Guns
    ["AA-12"] = true, ["AK-47"] = true, ["Assault Rifle"] = true, ["Desert Eagle"] = true,
    ["Double Barrel"] = true, ["Flamethrower"] = true, ["Grenade Launcher"] = true, ["LMG"] = true,
    ["MediGun"] = true, ["Pistol"] = true, ["Ray Gun"] = true, ["Revolver"] = true, ["Rifle"] = true,
    ["Shotgun"] = true, ["Sniper"] = true, ["SVD"] = true, ["Uzi"] = true,
    
    -- Medical
    ["Bandage"] = true, ["Compound H"] = true, ["Compound I"] = true, ["Compound R"] = true,
    ["Compound S"] = true, ["Medkit"] = true,
    
    -- Melee
    ["Bat"] = true, ["Chainsaw"] = true, ["Crowbar"] = true, ["Fire Axe"] = true, ["Hatchet"] = true,
    ["Katana"] = true, ["Knife"] = true, ["Riot Shield"] = true, ["Scythe"] = true,
    ["Sledgehammer"] = true, ["Spear"] = true, ["Spiked Bat"] = true, ["Power Hammer"] = true,
    ["Scorchblade"] = true,
    
    -- Misc & Tools
    ["Blueprint"] = true, ["Military Keycard"] = true, ["Repair Hammer"] = true, ["Suppressor"] = true,
    
    -- Fuel
    ["Fuel"] = true, ["Nuclear Fuel"] = true, ["Refined Fuel"] = true,
    
    -- Resources
    ["AC"] = true, ["Battery"] = true, ["Battery Pack"] = true, ["Bucket"] = true,
    ["Dumbell"] = true, ["Exhaust Pipe"] = true, ["Reactor Component"] = true,
    ["Refined Metal"] = true, ["Satellite Dish"] = true, ["Scrap"] = true,
    ["Screws"] = true, ["Spatula"] = true, ["Tray"] = true, ["TV"] = true,
    ["Watch"] = true, ["Zombie Heart"] = true,
    
    -- Food
    ["Chips"] = true, ["Carrot"] = true, ["Bloxiade"] = true, ["Beans"] = true,
    ["MRE"] = true, ["Bloxy Cola"] = true,
    
    -- Abilities
    ["Airstrike"] = true, ["Attack Order"] = true, ["Call of the Dead"] = true,
    ["Summon Brute"] = true, ["Summon Zombies"] = true, ["Taunt"] = true,
    ["The Future"] = true, ["The Past"] = true, ["The Present"] = true,
    ["Quickdraw"] = true, ["Charge"] = true, ["Counter"] = true,
    ["Infiltrate"] = true, ["System Override"] = true, ["Stalk"] = true,
    ["Brewing Stand"] = true, ["Control Pad"] = true, ["Remote Arsenal"] = true,
    
    -- Car Attachments
    ["Self-Repair Device"] = true, ["Vehicle Storage"] = true, ["Plow"] = true,
    ["Steel Plating"] = true, ["Basic Turret"] = true, ["Heavy Turret"] = true,
    ["Minigun Turret"] = true,
}

-- ESP Definitions with Game-Accurate Categorization
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
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat",
            "Power Hammer", "Scorchblade"
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
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart",
            "Blood Gem", "Data Coin", "Emerald"
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
            "The Future", "The Past", "The Present",
            "Quickdraw", "Charge", "Counter", "Infiltrate",
            "System Override", "Stalk", "Brewing Stand", "Control Pad", "Remote Arsenal"
        },
        colors = { fill = Color3.fromRGB(180, 0, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(220, 150, 255) },
    },
}

-- Supported maps
Config.SupportedMaps = {
    { name = "Survive The Apocalypse" },
    { name = "Apocalypse Rising" },
    { name = "Survive Zombie Arena" },
    { name = "99 Night Forest" },
    { name = "100 Days At Sea" },
}

-- Crate options
Config.CrateOptions = {
    ESP = false,
    Chams = false,
    Name = false,
    Distance = false,
    MaxDistance = 500,
    HideOpened = true,
    ChamsColor = Color3.fromRGB(255, 200, 50),
    OutlineColor = Color3.fromRGB(255, 255, 255)
}

-- ============================================
-- GETTER METHODS
-- ============================================

function Config:GetOptions()
    return Config.Options
end

function Config:GetToggles()
    return Config.Toggles
end

function Config:GetWeaponSwingSpeeds()
    return Config.WeaponSwingSpeeds
end

function Config:GetMobNames()
    return Config.MobNames
end

function Config:GetStructureNames()
    return Config.StructureNames
end

function Config:GetPickupItemSet()
    return Config.PickupItemSet
end

function Config:GetESPDefinitions()
    return Config.ESPDefinitions
end

function Config:GetSupportedMaps()
    return Config.SupportedMaps
end

function Config:GetCrateOptions()
    return Config.CrateOptions
end

-- ============================================
-- INIT + GLOBAL BRIDGE
-- ============================================

function Config:Init(modules)
    _G.Options = Config.Options
    _G.Toggles = Config.Toggles
    _G.Config = Config
    _G.Modules = modules or {}
    _G.Modules.Config = Config
    
    print("Config module initialized with updated game database & toggles")
    return self
end

return Config
