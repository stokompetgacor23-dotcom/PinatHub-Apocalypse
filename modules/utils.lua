-- =======================================================
-- PINATHUB - UTILITIES MODULE WITH DEBUG SYSTEM
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Connection management
Utils.Connections = {}

-- =======================================================
-- DEBUG SYSTEM
-- =======================================================

local MODULE_NAME = "UTILS"

function Utils.Debug(moduleName, ...)
    local args = {...}
    local msg = table.concat(args, " ")
    print(string.format("[%s][%s] %s", string.upper(moduleName), "DEBUG", msg))
end

function Utils.Warn(moduleName, ...)
    local args = {...}
    local msg = table.concat(args, " ")
    warn(string.format("[%s][%s] %s", string.upper(moduleName), "WARN", msg))
end

function Utils.Error(moduleName, err)
    error(string.format("[%s][ERROR] %s", string.upper(moduleName), tostring(err)))
end

function Utils.SafeSpawn(threadName, func)
    task.spawn(function()
        local ok, err = pcall(func)
        if not ok then
            warn(string.format("[%s][THREAD_ERROR] Thread '%s' crashed: %s", MODULE_NAME, threadName, tostring(err)))
        end
    end)
end

function Utils.SafeCall(moduleName, funcName, func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        Utils.Warn(moduleName, string.format("%s() failed: %s", funcName, tostring(result)))
        return nil, result
    end
    Utils.Debug(moduleName, string.format("%s() completed successfully", funcName))
    return result, nil
end

function Utils:AddConnection(conn)
    table.insert(self.Connections, conn)
    Utils.Debug(MODULE_NAME, "Connection added, total:", #self.Connections)
    return conn
end

function Utils:DisconnectAll()
    Utils.Debug(MODULE_NAME, "Disconnecting all connections...")
    for _, conn in ipairs(self.Connections) do
        local ok, err = pcall(function() conn:Disconnect() end)
        if not ok then
            Utils.Warn(MODULE_NAME, "Failed to disconnect:", err)
        end
    end
    self.Connections = {}
    Utils.Debug(MODULE_NAME, "All connections disconnected")
end

-- Item part detection
function Utils:GetItemMainPart(item)
    if not item then return nil end
    
    if item.PrimaryPart then 
        return item.PrimaryPart 
    end
    
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end

function Utils:GetItemPrimaryPart(item)
    if not item then return nil end
    
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

-- Color utilities
function Utils:GetDistanceColor(dist)
    if dist > 250 then 
        return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then 
        return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then 
        return Color3.fromRGB(255, 255, 80)
    else 
        return Color3.fromRGB(220, 220, 220) 
    end
end

function Utils:GetHealthColor(pct)
    if pct > 0.6 then 
        return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then 
        return Color3.fromRGB(255, 230, 50)
    else 
        return Color3.fromRGB(255, 60, 60) 
    end
end

-- Folder discovery
function Utils:DiscoverFolders()
    local Workspace = game:GetService("Workspace")
    local charactersFolder = Workspace:FindFirstChild("Characters")
    local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    local structuresFolder = Workspace:FindFirstChild("Structures") or Workspace:FindFirstChild("PlayerStructures") or Workspace:FindFirstChild("Buildings")
    
    return {
        charactersFolder = charactersFolder,
        droppedItemsFolder = droppedItemsFolder,
        structuresFolder = structuresFolder
    }
end

-- Get player root part
function Utils:GetPlayerRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- Get player character
function Utils:GetCharacter()
    return LocalPlayer.Character
end

-- Distance calculation
function Utils:GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    return (pos1 - pos2).Magnitude
end

-- Safe pcall wrapper
function Utils:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall error: " .. tostring(result))
        return nil
    end
    return result
end

-- Delay with task library
function Utils:Delay(seconds, func)
    task.wait(seconds)
    return func()
end

-- Create highlight
function Utils:CreateHighlight(adornee, fillColor, fillTrans, outlineColor, outlineTrans)
    if not adornee then return nil end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = adornee
    highlight.FillColor = fillColor
    highlight.FillTransparency = fillTrans or 0.4
    highlight.OutlineColor = outlineColor
    highlight.OutlineTransparency = outlineTrans or 0.8
    highlight.Parent = adornee
    return highlight
end

-- Create billboard
function Utils:CreateBillboard(adornee, size, offset)
    if not adornee then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = size or UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    return billboard
end

-- Find all crates
function Utils:FindAllCrates()
    local crates = {}
    local Workspace = game:GetService("Workspace")
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return crates end
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then return crates end
    for _, child in ipairs(cratesFolder:GetChildren()) do
        if child.Name == "Default" and child:IsA("Model") then
            table.insert(crates, child)
        end
    end
    return crates
end

-- Get crate main part
function Utils:GetCrateMainPart(crate)
    if not crate then return nil end
    if crate.PrimaryPart then return crate.PrimaryPart end
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part end
    end
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

-- Get mob names
function Utils:GetMobNames()
    return {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}
end

-- Get structure names
function Utils:GetStructureNames()
    return {"Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
            "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
            "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower", "Barrel", "Scrap Pile"}
end

-- Get pickup item set
function Utils:GetPickupItemSet()
    return {
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
        ["Fuel"]=true, ["Nuclear Fuel"]=true, ["Refined Fuel"]=true
    }
end

Utils.Debug(MODULE_NAME, "Utilities module loaded successfully")

return Utils
