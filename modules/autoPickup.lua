-- =======================================================
-- PINATHUB - AUTO PICKUP MODULE
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AutoPickup = {}

AutoPickup.Active = false
AutoPickup.Connection = nil
AutoPickup.AdjustBackpack = nil

-- ============================================
-- FIND ADJUST BACKPACK REMOTE
-- ============================================
local function findAdjustBackpack()
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local Tools = Remotes:FindFirstChild("Tools")
        if Tools then
            local remote = Tools:FindFirstChild("AdjustBackpack")
            if remote then
                AutoPickup.AdjustBackpack = remote
                return remote
            end
        end
    end
    
    -- Search all descendants
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name == "AdjustBackpack" then
            AutoPickup.AdjustBackpack = remote
            return remote
        end
    end
    
    return nil
end

-- ============================================
-- GET ITEM PRIMARY PART FOR PICKUP
-- ============================================
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

-- ============================================
-- GET PICKUP ITEM SET (Semua item yang bisa di-pickup)
-- ============================================
function AutoPickup:GetPickupItemSet()
    return {
        -- Ammo
        ["Ammo Box"] = true, ["Long Ammo"] = true, ["Medium Ammo"] = true, 
        ["Shells"] = true, ["Pistol Ammo"] = true,
        
        -- Armor
        ["Power Armor"] = true, ["Light Armor"] = true, ["Medium Armor"] = true, 
        ["Heavy Armor"] = true,
        
        -- Items
        ["Emerald"] = true, ["Gas Mask"] = true,
        
        -- Structures
        ["Ammo Crate"] = true, ["Barbed Wire"] = true, ["Bear Trap"] = true, 
        ["Boost Pad"] = true, ["Electric Fence"] = true, ["Farm Plot"] = true, 
        ["Fence"] = true, ["Floodlight"] = true, ["Gate"] = true, ["Landmine"] = true, 
        ["Map"] = true, ["Repair Drone"] = true, ["Shelf"] = true, ["Teleporter"] = true, 
        ["Time Machine"] = true, ["Turret"] = true, ["Wall"] = true, ["Watchtower"] = true,
        
        -- Backpacks
        ["Basic Backpack"] = true, ["Good Backpack"] = true, ["Great Backpack"] = true,
        
        -- Consumables
        ["Grenade"] = true, ["Molotov"] = true,
        
        -- Guns
        ["AA-12"] = true, ["AK-47"] = true, ["Assault Rifle"] = true, ["Desert Eagle"] = true,
        ["Double Barrel"] = true, ["Flamethrower"] = true, ["Grenade Launcher"] = true, 
        ["LMG"] = true, ["MediGun"] = true, ["Pistol"] = true, ["Ray Gun"] = true, 
        ["Revolver"] = true, ["Rifle"] = true, ["Shotgun"] = true, ["Sniper"] = true, 
        ["SVD"] = true, ["Uzi"] = true,
        
        -- Medical
        ["Bandage"] = true, ["Compound H"] = true, ["Compound I"] = true, 
        ["Compound R"] = true, ["Compound S"] = true, ["Medkit"] = true,
        
        -- Melee
        ["Bat"] = true, ["Chainsaw"] = true, ["Crowbar"] = true, ["Fire Axe"] = true, 
        ["Hatchet"] = true, ["Katana"] = true, ["Knife"] = true, ["Riot Shield"] = true, 
        ["Scythe"] = true, ["Sledgehammer"] = true, ["Spear"] = true, ["Spiked Bat"] = true,
        
        -- Misc
        ["Blueprint"] = true, ["Military Keycard"] = true, ["Repair Hammer"] = true, 
        ["Suppressor"] = true,
        
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
        ["The Future"] = true, ["The Past"] = true, ["The Present"] = true
    }
end

-- ============================================
-- START AUTO PICKUP
-- ============================================
function AutoPickup:Start(options, notifications)
    if self.Active then return end
    
    -- Find AdjustBackpack remote
    findAdjustBackpack()
    
    if not self.AdjustBackpack then
        print("[AUTO PICKUP] AdjustBackpack not found!")
        if notifications then 
            notifications:Show("Auto Pickup", "Remote not found!", 2)
        end
        return
    end
    
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then
        print("[AUTO PICKUP] DroppedItems folder not found!")
        if notifications then
            notifications:Show("Auto Pickup", "DroppedItems folder not found!", 2)
        end
        return
    end
    
    self.Active = true
    self.Options = options
    local pickupItemSet = self:GetPickupItemSet()
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local droppedItems = Workspace:FindFirstChild("DroppedItems")
            if not droppedItems then return end
            
            local myPos = hrp.Position
            local pickupRange = self.Options.AutoPickupRange or 50
            local pickupAll = self.Options.AutoPickupAll
            if pickupAll == nil then pickupAll = true end
            local pickupDelay = self.Options.AutoPickupDelay or 0.1
            
            local itemsToPickup = {}
            
            for _, item in ipairs(droppedItems:GetChildren()) do
                if item and item.Parent and (pickupAll or pickupItemSet[item.Name]) then
                    local part = getItemPrimaryPartForPickup(item)
                    if part and part.Parent then
                        local dist = (part.Position - myPos).Magnitude
                        if dist <= pickupRange then
                            table.insert(itemsToPickup, {
                                item = item,
                                dist = dist,
                                name = item.Name
                            })
                        end
                    end
                end
            end
            
            -- Sort by distance (nearest first)
            table.sort(itemsToPickup, function(a, b) return a.dist < b.dist end)
            
            for _, target in ipairs(itemsToPickup) do
                if not self.Active then break end
                if not target.item.Parent then continue end
                
                local success = pcall(function()
                    if self.Network and self.Network.FireAdjustBackpack then
                        self.Network:FireAdjustBackpack(target.item)
                    else
                        self.AdjustBackpack:FireServer(target.item)
                    end
                end)
                
                if success then
                    if notifications then
                        print("[AUTO PICKUP] Picked up:", target.name, "- Distance:", math.floor(target.dist))
                    end
                    task.wait(pickupDelay)
                end
                
                if not pickupAll then
                    break
                end
            end
        end)
    end)
    
    if notifications then
        notifications:Show("Auto Pickup", "Enabled - Range: " .. (options.AutoPickupRange or 50) .. " studs", 2)
    end
    
    local initialRange = options.AutoPickupRange or 50
    local initialAll = options.AutoPickupAll
    if initialAll == nil then initialAll = true end
    print("[AUTO PICKUP] Started - Range:", initialRange, "- Pickup All:", initialAll)
end

-- ============================================
-- STOP AUTO PICKUP
-- ============================================
function AutoPickup:Stop(notifications)
    self.Active = false
    
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    if notifications then
        notifications:Show("Auto Pickup", "Disabled", 2)
    end
    
    print("[AUTO PICKUP] Stopped")
end

-- ============================================
-- INIT
-- ============================================
function AutoPickup:Init(deps)
    self.Config = deps.config or deps.Config
    self.Utils = deps.utils or deps.Utils
    self.Notifications = deps.notifications or deps.Notifications
    self.Network = deps.network or deps.Network
    
    print("[AUTO PICKUP MODULE] Initialized")
    return self
end

return AutoPickup
