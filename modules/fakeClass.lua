-- =======================================================
-- PINATHUB - FAKE CLASS & GAME BYPASSES MODULE
-- Directly leverages game internal structures from gamemodule.lua:
-- ReplicatedStorage.GameInfo.Classes
-- ReplicatedStorage.GameInfo.Perks
-- RemoteArsenalClient (BulletPreserveChance)
-- HitboxService (Untouchable & Untargetable)
-- WalkSpeedClient (UsingMedical & u40 slow bypass)
-- DragSystem (DragRange telekinesis)
-- Inventory & BackpackLocked bypass
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local FakeClass = {
    Active = false,
    CurrentClass = "GOD HYBRID",
    CurrentClassLevel = 3,
    FakeClassActive = false,
    
    CurrentPerk = "Specialist",
    PerkBypassActive = false,
    AllPerksActive = false,
    ForceMaxLevelActive = false,
    
    -- Bypasses
    InfiniteAmmoActive = false,
    BackpackUnlockActive = false,
    AntiSlowActive = false,
    UntouchableActive = false,
    UntargetableActive = false,
    SuperDragActive = false,
    SuperDragRange = 500,
    InstantBreakScrapActive = false,
    
    -- Internals
    Connections = {},
    AppliedStats = {},
    OriginalWalkSpeedFunc = nil,
    Utils = nil,
    Notifications = nil,
    Config = nil,
    Network = nil,
}

-- =======================================================
-- GAME CLASSES DUMP DEFINITIONS (All 24 Classes)
-- =======================================================
FakeClass.ClassList = {
    "GOD HYBRID",
    "Survivor",
    "Policeman",
    "Scavenger",
    "Fighter",
    "Engineer",
    "Assassin",
    "Soldier",
    "Guardian",
    "Medic",
    "Necromancer",
    "Clockmaster",
    "Hunter",
    "Commander",
    "Fragger",
    "Farmer",
    "Psychic",
    "Berserker",
    "Explorer",
    "Stalker",
    "Operator",
    "Alchemist",
    "Outlaw",
    "Vanguard",
    "Hacker",
}

FakeClass.ClassData = {
    Survivor = {
        Abilities = {},
        Stats = {
            [1] = {HungerDrain = -0.3},
            [2] = {HungerDrain = -0.3, Regen = 0.25},
            [3] = {HungerDrain = -0.3, Regen = 0.25, SurviveCooldown = 300},
        }
    },
    Policeman = {
        Abilities = {},
        Stats = {
            [1] = {ReloadSpeed_Pistol = 0.2},
            [2] = {ReloadSpeed_Pistol = 0.2, Accuracy_Pistol = 0.25},
            [3] = {ReloadSpeed_Pistol = 0.2, Accuracy_Pistol = 0.25, Damage_Pistol = 0.2},
        }
    },
    Scavenger = {
        Abilities = {},
        Stats = {
            [1] = {SprintSpeed_Full = 0.1},
            [2] = {SprintSpeed_Full = 0.1, AmmoScavenge = 2},
            [3] = {SprintSpeed_Full = 0.1, AmmoScavenge = 2, NearbyItemESP = true},
        }
    },
    Fighter = {
        Abilities = {},
        Stats = {
            [1] = {MeleeDamage = 0.2, Accuracy = -0.2},
            [2] = {MeleeDamage = 0.2, Accuracy = -0.2, MaxHealth = 30},
            [3] = {MeleeDamage = 0.2, Accuracy = -0.2, MaxHealth = 30, MeleeAttackSpeed = 0.2},
        }
    },
    Engineer = {
        Abilities = {},
        Stats = {
            [1] = {RepairBoost = 1},
            [2] = {RepairBoost = 1, BuildingHealth = 0.25},
            [3] = {RepairBoost = 1, BuildingHealth = 0.25, BuildingDamage = 0.2},
        }
    },
    Assassin = {
        Abilities = {},
        Stats = {
            [1] = {Aggro = -0.3, SprintSpeed = 0.1},
            [2] = {Aggro = -0.3, SprintSpeed = 0.1, MaxHealth = -20, DamageBoost = 0.1},
            [3] = {Aggro = -0.3, SprintSpeed = 0.1, MaxHealth = -20, HeadshotDamage = 0.3, DamageBoost = 0.1},
        }
    },
    Soldier = {
        Abilities = {},
        Stats = {
            [1] = {ReloadSpeed = 0.3},
            [2] = {ReloadSpeed = 0.3, Accuracy = 0.3},
            [3] = {ReloadSpeed = 0.3, Accuracy = 0.3, FireRate = 0.15},
        }
    },
    Guardian = {
        Abilities = {"Taunt"},
        Stats = {
            [1] = {DamageReduction = 0.1},
            [2] = {DamageReduction = 0.1, MaxHealth = 30, Regen = 0.25},
            [3] = {DamageReduction = 0.1, MaxHealth = 30, Regen = 0.25, Abilities = {"Taunt"}},
        }
    },
    Medic = {
        Abilities = {},
        Stats = {
            [1] = {MedicalSpeed = 1},
            [2] = {MedicalSpeed = 1, ReviveSpeed = 1},
            [3] = {MedicalSpeed = 1, ReviveSpeed = 1, MedicAdrenaline = true},
        }
    },
    Necromancer = {
        Abilities = {"Summon", "Requiem"},
        Stats = {
            [1] = {ZombieConvert = 0.1, Abilities = {"Summon"}},
            [2] = {ZombieHealth = 0.5, ZombieDamage = 0.5, ZombieConvert = 0.1, Abilities = {"Summon"}},
            [3] = {ZombieHealth = 0.5, ZombieDamage = 0.5, ZombieConvert = 0.1, Abilities = {"Summon", "Requiem"}},
        }
    },
    Clockmaster = {
        Abilities = {"The Past", "The Present", "The Future"},
        Stats = {
            [1] = {ReloadSpeed = 0.22, Abilities = {"The Past", "The Present", "The Future"}},
            [2] = {ReloadSpeed = 0.22, FireRate = 0.22, Abilities = {"The Past", "The Present", "The Future"}},
            [3] = {ReloadSpeed = 0.22, FireRate = 0.22, SprintSpeed = 0.22, Abilities = {"The Past", "The Present", "The Future"}},
        }
    },
    Hunter = {
        Abilities = {},
        Stats = {
            [1] = {BearTrapDamage = 0.5, BearTrapDuration = 0.5},
            [2] = {BearTrapDamage = 0.5, BearTrapDuration = 0.5, BearTrapRearm = 15},
            [3] = {BearTrapDamage = 0.5, BearTrapDuration = 0.5, BearTrapRearm = 15, ShootSlow = 0.3},
        }
    },
    Commander = {
        Abilities = {"Attack Order", "Airstrike"},
        Stats = {
            [1] = {Abilities = {"Attack Order"}},
            [2] = {Abilities = {"Attack Order"}},
            [3] = {Abilities = {"Attack Order", "Airstrike"}},
        }
    },
    Fragger = {
        Abilities = {},
        Stats = {
            [1] = {ThrowableSpeed = 0.25, ThrowableDamage = 0.25},
            [2] = {ThrowableSpeed = 0.25, ThrowableDamage = 0.25, ThrowablesPerNight = 1},
            [3] = {ThrowableSpeed = 0.25, ThrowableDamage = 0.25, ThrowablesPerNight = 1, ThrowableRadius = 0.3, SelfDamageImmune = true},
        }
    },
    Farmer = {
        Abilities = {},
        Stats = {
            [1] = {FarmPlotSpeed = 0.5},
            [2] = {FarmPlotSpeed = 0.5, CarrotHeal = 10, CarrotHunger = 0.5},
            [3] = {FarmPlotSpeed = 0.5, CarrotHeal = 10, CarrotHunger = 0.5, CarrotBuffDuration = 30},
        }
    },
    Psychic = {
        Abilities = {},
        Stats = {
            [1] = {RemoteArsenalMax = 3},
            [2] = {DragRange = 12, RemoteArsenalMax = 4},
            [3] = {DragRange = 12, PsychicShieldHealth = 50, RemoteArsenalMax = 4},
        }
    },
    Berserker = {
        Abilities = {},
        Stats = {
            [1] = {RageMaxAttackSpeed = 0.4, RageMaxDamageReduction = 0.4, FireRate = -0.5},
            [2] = {RageMaxAttackSpeed = 0.4, RageMaxDamageReduction = 0.4, FireRate = -0.5, RageMaxWalkSpeed = 3, MeleeDamage = 0.2},
            [3] = {RageMaxAttackSpeed = 0.4, RageMaxDamageReduction = 0.4, FireRate = -0.5, RageMaxWalkSpeed = 3, MeleeDamage = 0.2},
        }
    },
    Explorer = {
        Abilities = {},
        Stats = {
            [1] = {InteractableUseSpeed = 2},
            [2] = {InteractableUseSpeed = 2, RevealSize = 2},
            [3] = {InteractableUseSpeed = 2, RevealSize = 2, ScrapDamageBoost = 1},
        }
    },
    Stalker = {
        Abilities = {"Stalk"},
        Stats = {
            [1] = {Aggro = -0.2},
            [2] = {Aggro = -0.2},
            [3] = {Aggro = -0.2, Abilities = {"Stalk"}},
        }
    },
    Operator = {
        Abilities = {},
        Stats = {
            [1] = {},
            [2] = {},
            [3] = {DroneTargeting = true},
        }
    },
    Alchemist = {
        Abilities = {},
        Stats = {
            [1] = {},
            [2] = {DrinkSpeed = 1},
            [3] = {DrinkSpeed = 1, PotionRadius = 0.25, CompoundDuration = 0.25, PotionDuration = 0.25, DoublePotionChance = 0.25},
        }
    },
    Outlaw = {
        Abilities = {"Quickdraw"},
        Stats = {
            [1] = {},
            [2] = {RicochetChance = 1, RicochetMax = 3},
            [3] = {RicochetChance = 1, RicochetMax = 3, Abilities = {"Quickdraw"}},
        }
    },
    Vanguard = {
        Abilities = {"Counter", "Charge"},
        Stats = {
            [1] = {MaxHealth = 50, Regen = 0.25},
            [2] = {MaxHealth = 50, Regen = 0.25, NegativeStatusResistance = 0.4, Abilities = {"Charge"}},
            [3] = {MaxHealth = 50, Regen = 0.25, NegativeStatusResistance = 0.4, Abilities = {"Counter", "Charge"}},
        }
    },
    Hacker = {
        Abilities = {"Infiltrate", "System Override"},
        Stats = {
            [1] = {Abilities = {"Infiltrate"}},
            [2] = {Abilities = {"Infiltrate"}},
            [3] = {Abilities = {"Infiltrate", "System Override"}},
        }
    },
}

-- =======================================================
-- GAME PERKS DUMP DEFINITIONS (All 21 Perks)
-- =======================================================
FakeClass.PerkList = {
    "Specialist",    -- Torso shots count as Headshots!
    "Acrobat",       -- Q Dash with iframes
    "Shadowshot",    -- 30% Bullet Preserve Chance
    "Agile",         -- 25% Dodge Chance
    "Marksman",      -- +20% Headshot Damage
    "Overclock",     -- -15% Cooldowns
    "Determined",    -- +25% Defense, +15% Damage <50% HP
    "Immune",        -- -50% Negative Status Effects
    "Healthy",       -- +0.25 HP Regen
    "Nimble",        -- +0.5 WalkSpeed
    "Recovery",      -- +35% Incoming Healing
    "Double Tap",    -- +10% Fire Rate
    "Quick Hands",   -- +25% Reload Speed
    "Strong",        -- +10% Melee Damage
    "Accurate",      -- +25% Accuracy
    "Endurance",     -- -35% Hunger Drain
    "Tough",         -- +10 Max HP
    "Stealthy",      -- -20% Aggro Range
    "Builder",       -- +50% Repair Speed
    "Lucky",         -- Survive lethal hit every 3 min
    "Adaptable",     -- Melee damage increases gun damage 25%
}

FakeClass.PerkData = {
    Specialist = {StatBoosts = {}},
    Acrobat = {StatBoosts = {}},
    Shadowshot = {StatBoosts = {BulletPreserveChance = 0.3}},
    Agile = {StatBoosts = {DodgeChance = 0.25}},
    Marksman = {StatBoosts = {HeadshotDamage = 0.2}},
    Overclock = {StatBoosts = {CooldownDuration = -0.15}},
    Determined = {StatBoosts = {}},
    Immune = {StatBoosts = {NegativeStatusResistance = 0.5}},
    Healthy = {StatBoosts = {Regen = 0.25}},
    Nimble = {StatBoosts = {WalkSpeed = 0.5}},
    Recovery = {StatBoosts = {IncomingHealing = 0.35}},
    ["Double Tap"] = {StatBoosts = {FireRate = 0.1}},
    ["Quick Hands"] = {StatBoosts = {ReloadSpeed = 0.25}},
    Strong = {StatBoosts = {MeleeDamage = 0.1}},
    Accurate = {StatBoosts = {Accuracy = 0.25}},
    Endurance = {StatBoosts = {HungerDrain = -0.35}},
    Tough = {StatBoosts = {MaxHealth = 10}},
    Stealthy = {StatBoosts = {Aggro = -0.2}},
    Builder = {StatBoosts = {RepairBoost = 0.5}},
    Lucky = {StatBoosts = {}},
    Adaptable = {StatBoosts = {}},
}

-- =======================================================
-- FAKE CLASS INJECTION & HYBRID GOD CLASS
-- =======================================================
function FakeClass:ApplyClass(className, level)
    self.CurrentClass = className or self.CurrentClass or "GOD HYBRID"
    self.CurrentClassLevel = level or self.CurrentClassLevel or 3
    self.FakeClassActive = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    pcall(function()
        -- Always unlock level 3 abilities & crafting
        LocalPlayer:SetAttribute("ClassLevel", self.CurrentClassLevel)
        
        if self.CurrentClass == "GOD HYBRID" then
            LocalPlayer:SetAttribute("Class", "Vanguard")
            
            -- Combine all best attributes from all 24 classes
            local godStats = {
                MaxHealth = 100,
                Regen = 0.75,
                DamageReduction = 0.4,
                MeleeDamage = 0.5,
                MeleeAttackSpeed = 0.3,
                ReloadSpeed = 0.5,
                FireRate = 0.35,
                Accuracy = 0.5,
                SprintSpeed = 0.35,
                SprintSpeed_Full = 0.25,
                MedicalSpeed = 2,
                ReviveSpeed = 2,
                MedicAdrenaline = true,
                RepairBoost = 3,
                BuildingHealth = 0.5,
                BuildingDamage = 0.5,
                HungerDrain = -0.8,
                Aggro = -0.5,
                HeadshotDamage = 0.5,
                DamageBoost = 0.25,
                ZombieConvert = 0.5,
                ZombieHealth = 1.0,
                ZombieDamage = 1.0,
                SelfDamageImmune = true,
                ThrowableSpeed = 0.5,
                ThrowableDamage = 0.5,
                ThrowableRadius = 0.5,
                FarmPlotSpeed = 1.0,
                CarrotHeal = 25,
                CarrotHunger = 1.0,
                CarrotBuffDuration = 60,
                PsychicShieldHealth = 100,
                RemoteArsenalMax = 5,
                InteractableUseSpeed = 5,
                RevealSize = 5,
                ScrapDamageBoost = 5,
                DrinkSpeed = 2,
                PotionRadius = 0.5,
                PotionDuration = 0.5,
                DoublePotionChance = 0.5,
                RicochetChance = 1,
                RicochetMax = 5,
                NegativeStatusResistance = 0.6,
                NearbyItemESP = true,
                DroneTargeting = true,
            }
            
            for stat, val in pairs(godStats) do
                char:SetAttribute(stat, val)
                self.AppliedStats[stat] = val
            end
            
            LocalPlayer:SetAttribute("Ability1", "Counter")
            LocalPlayer:SetAttribute("Ability2", "System Override")
            
        else
            LocalPlayer:SetAttribute("Class", self.CurrentClass)
            local classInfo = self.ClassData[self.CurrentClass]
            if classInfo then
                local tierStats = classInfo.Stats[self.CurrentClassLevel] or classInfo.Stats[3] or {}
                for stat, val in pairs(tierStats) do
                    if stat ~= "Abilities" then
                        char:SetAttribute(stat, val)
                        self.AppliedStats[stat] = val
                    end
                end
                
                if classInfo.Abilities and #classInfo.Abilities > 0 then
                    LocalPlayer:SetAttribute("Ability1", classInfo.Abilities[1])
                    if classInfo.Abilities[2] then
                        LocalPlayer:SetAttribute("Ability2", classInfo.Abilities[2])
                    end
                end
            end
        end
    end)
    
    print("[FAKE CLASS] Applied:", self.CurrentClass, "Level:", self.CurrentClassLevel)
end

function FakeClass:RemoveClass()
    self.FakeClassActive = false
    local char = LocalPlayer.Character
    if char then
        for stat, _ in pairs(self.AppliedStats) do
            char:SetAttribute(stat, nil)
        end
    end
    self.AppliedStats = {}
    print("[FAKE CLASS] Removed")
end

-- =======================================================
-- PERK SIMULATOR & BYPASS
-- =======================================================
function FakeClass:ApplyPerk(perkName)
    self.CurrentPerk = perkName or self.CurrentPerk or "Specialist"
    self.PerkBypassActive = true
    
    local char = LocalPlayer.Character
    
    pcall(function()
        LocalPlayer:SetAttribute("Perk", self.CurrentPerk)
        if char then
            char:SetAttribute("Perk", self.CurrentPerk)
        end
        
        local pData = self.PerkData[self.CurrentPerk]
        if pData and pData.StatBoosts and char then
            for stat, val in pairs(pData.StatBoosts) do
                char:SetAttribute(stat, val)
            end
        end
    end)
    
    print("[PERK BYPASS] Applied Perk:", self.CurrentPerk)
end

function FakeClass:RemovePerk()
    self.PerkBypassActive = false
    pcall(function()
        LocalPlayer:SetAttribute("Perk", nil)
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("Perk", nil)
            local pData = self.PerkData[self.CurrentPerk]
            if pData and pData.StatBoosts then
                for stat, _ in pairs(pData.StatBoosts) do
                    char:SetAttribute(stat, nil)
                end
            end
        end
    end)
    print("[PERK BYPASS] Removed Perk")
end

function FakeClass:ApplyAllPerks()
    self.AllPerksActive = true
    local char = LocalPlayer.Character
    if not char then return end
    
    pcall(function()
        LocalPlayer:SetAttribute("Perk", "Specialist") -- Specialist for Torso Headshots!
        char:SetAttribute("Perk", "Specialist")
        
        -- Apply all passive stats from all 21 perks
        for pName, pData in pairs(self.PerkData) do
            if pData.StatBoosts then
                for stat, val in pairs(pData.StatBoosts) do
                    local current = char:GetAttribute(stat) or 0
                    if type(current) == "number" and type(val) == "number" then
                        char:SetAttribute(stat, current + val)
                    else
                        char:SetAttribute(stat, val)
                    end
                end
            end
        end
    end)
    print("[PERK BYPASS] All Perks Active!")
end

function FakeClass:RemoveAllPerks()
    self.AllPerksActive = false
    print("[PERK BYPASS] All Perks Disabled")
end

-- =======================================================
-- BYPASS: INFINITE AMMO (BULLET PRESERVE CHANCE 1.0)
-- RemoteArsenalClient line 12216:
-- if BulletPreserveChance < v2 then ammo is subtracted
-- =======================================================
function FakeClass:StartInfiniteAmmo()
    self.InfiniteAmmoActive = true
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.InfiniteAmmoActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("BulletPreserveChance", 1.0)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                local stats = tool:FindFirstChild("Stats")
                if stats then
                    stats:SetAttribute("BulletPreserveChance", 1.0)
                end
            end
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Infinite Ammo (BulletPreserveChance = 1.0) Enabled")
end

function FakeClass:StopInfiniteAmmo()
    self.InfiniteAmmoActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("BulletPreserveChance", nil)
    end
    print("[BYPASS] Infinite Ammo Disabled")
end

-- =======================================================
-- BYPASS: BACKPACK UNLOCKER (NO ACTION LOCK)
-- Prevents the game from locking your inventory/hotbar
-- during actions, abilities, rolls, or medkit use.
-- =======================================================
function FakeClass:StartBackpackUnlocker()
    self.BackpackUnlockActive = true
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.BackpackUnlockActive then return end
        pcall(function()
            if LocalPlayer:GetAttribute("BackpackLocked") then
                LocalPlayer:SetAttribute("BackpackLocked", nil)
            end
            local char = LocalPlayer.Character
            if char and char:GetAttribute("BackpackLocked") then
                char:SetAttribute("BackpackLocked", nil)
            end
        end)
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Backpack Unlocker Enabled (Free Inventory Actions)")
end

function FakeClass:StopBackpackUnlocker()
    self.BackpackUnlockActive = false
    print("[BYPASS] Backpack Unlocker Disabled")
end

-- =======================================================
-- BYPASS: ANTI-SLOWDOWN (NO MOB DRAG & HEAL WHILE SPRINTING)
-- WalkSpeedClient line 37135:
-- if UsingMedical then WalkSpeed = (16+v2)/2
-- u40 multiplies by (1 - u40/20) up to 90% slow
-- _G.inBlizzard multiplies by 0.9
-- =======================================================
function FakeClass:StartAntiSlowdown()
    self.AntiSlowActive = true
    
    -- Override _G.inBlizzard
    _G.inBlizzard = false
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.AntiSlowActive then return end
        _G.inBlizzard = false
        
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Bypass UsingMedical slowdown by ensuring speed calculation does not cut speed in half
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local bonusSpeed = char:GetAttribute("WalkSpeed") or 0
            local baseTargetSpeed = 16 + bonusSpeed
            if char:GetAttribute("SprintingClient") then
                baseTargetSpeed = baseTargetSpeed + 10
            end
            
            -- If game cut walkspeed due to UsingMedical or zombie clawing u40
            if hum.WalkSpeed < baseTargetSpeed then
                hum.WalkSpeed = baseTargetSpeed
            end
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Anti-Slowdown Enabled (Sprint while Healing & No Zombie Drag)")
end

function FakeClass:StopAntiSlowdown()
    self.AntiSlowActive = false
    print("[BYPASS] Anti-Slowdown Disabled")
end

-- =======================================================
-- BYPASS: UNTOUCHABLE (GODMODE MELEE IFRAME)
-- HitboxService line 54, 97, 124:
-- if not Parent:GetAttribute("Untouchable") then hit registered
-- =======================================================
function FakeClass:StartUntouchable()
    self.UntouchableActive = true
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.UntouchableActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("Untouchable", true)
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Untouchable (Godmode Iframe) Enabled")
end

function FakeClass:StopUntouchable()
    self.UntouchableActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Untouchable", nil)
    end
    print("[BYPASS] Untouchable Disabled")
end

-- =======================================================
-- BYPASS: UNTARGETABLE (MOB INVISIBILITY / BLINDNESS)
-- Line 38240 & 40552:
-- if not i:GetAttribute("Untargetable") then zombie targets player
-- =======================================================
function FakeClass:StartUntargetable()
    self.UntargetableActive = true
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.UntargetableActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("Untargetable", true)
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Untargetable (Mob Blindness) Enabled")
end

function FakeClass:StopUntargetable()
    self.UntargetableActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Untargetable", nil)
    end
    print("[BYPASS] Untargetable Disabled")
end

-- =======================================================
-- BYPASS: SUPER TELEKINESIS DRAG RANGE
-- DragSystem line 38016:
-- 12 + (Parent:GetAttribute("DragRange") or 0)
-- Setting DragRange = 500 allows dragging objects from 500+ studs away!
-- =======================================================
function FakeClass:StartSuperDrag(range)
    self.SuperDragRange = range or self.SuperDragRange or 500
    self.SuperDragActive = true
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.SuperDragActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("DragRange", self.SuperDragRange)
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Super Drag Range Enabled:", self.SuperDragRange, "studs")
end

function FakeClass:StopSuperDrag()
    self.SuperDragActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("DragRange", nil)
    end
    print("[BYPASS] Super Drag Range Disabled")
end

-- =======================================================
-- BYPASS: INSTANT BREAK SCRAP & BARRELS
-- Explorer Class line 14983:
-- ScrapDamageBoost attribute breaks barrels & scrap piles instantly
-- =======================================================
function FakeClass:StartInstantBreakScrap(boost)
    self.InstantBreakScrapActive = true
    local val = boost or 100
    
    local conn = RunService.Heartbeat:Connect(function()
        if not self.InstantBreakScrapActive then return end
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("ScrapDamageBoost", val)
            char:SetAttribute("MeleeDamage", 50)
            char:SetAttribute("MeleeAttackSpeed", 50)
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Stats") then
                pcall(function()
                    tool.Stats:SetAttribute("Damage", 9999)
                    tool.Stats:SetAttribute("ScrapDamage", 9999)
                end)
            end
        end
    end)
    
    table.insert(self.Connections, conn)
    print("[BYPASS] Instant Break Scrap & Barrels Enabled (ScrapDamageBoost =", val, ")")
end

function FakeClass:StopInstantBreakScrap()
    self.InstantBreakScrapActive = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("ScrapDamageBoost", nil)
        char:SetAttribute("MeleeDamage", nil)
        char:SetAttribute("MeleeAttackSpeed", nil)
    end
    print("[BYPASS] Instant Break Scrap Disabled")
end

-- =======================================================
-- RESPAWN HANDLER (Maintains all active class & bypass states)
-- =======================================================
function FakeClass:SetupRespawnHandler()
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        
        if self.FakeClassActive then
            self:ApplyClass(self.CurrentClass, self.CurrentClassLevel)
        end
        if self.PerkBypassActive then
            self:ApplyPerk(self.CurrentPerk)
        end
        if self.AllPerksActive then
            self:ApplyAllPerks()
        end
        if self.ForceMaxLevelActive then
            LocalPlayer:SetAttribute("ClassLevel", 3)
        end
        if self.InfiniteAmmoActive then
            char:SetAttribute("BulletPreserveChance", 1.0)
        end
        if self.UntouchableActive then
            char:SetAttribute("Untouchable", true)
        end
        if self.UntargetableActive then
            char:SetAttribute("Untargetable", true)
        end
        if self.SuperDragActive then
            char:SetAttribute("DragRange", self.SuperDragRange)
        end
        if self.InstantBreakScrapActive then
            char:SetAttribute("ScrapDamageBoost", 10)
        end
    end)
end

-- =======================================================
-- INIT
-- =======================================================
function FakeClass:Init(modules)
    self.Utils = modules.utils or modules.Utils
    self.Notifications = modules.notifications or modules.Notifications
    self.Config = modules.config or modules.Config
    self.Network = modules.network or modules.Network
    
    self:SetupRespawnHandler()
    print("[FAKE CLASS & BYPASSES] Initialized with game dump structures")
    return self
end

return FakeClass
