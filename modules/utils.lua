-- =======================================================
-- PINATHUB - UTILITIES MODULE (UPDATED WITH GAME DUMP INTEGRATION)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Connection management
Utils.Connections = {}

-- Cached DroppedItemSwarm module from game
local DroppedItemSwarm = nil
pcall(function()
    local swarmMod = ReplicatedStorage:FindFirstChild("Modules") 
        and ReplicatedStorage.Modules:FindFirstChild("Utility") 
        and ReplicatedStorage.Modules.Utility:FindFirstChild("DroppedItemSwarm")
    if swarmMod then
        DroppedItemSwarm = require(swarmMod)
    end
end)

-- Official game colors for item tiers
Utils.ItemTierColors = {
    [1] = Color3.fromRGB(255, 255, 255), -- Common (White)
    [2] = Color3.fromRGB(161, 230, 97),  -- Uncommon (Green)
    [3] = Color3.fromRGB(111, 157, 255), -- Rare (Blue)
    [4] = Color3.fromRGB(148, 99, 255),  -- Epic (Purple)
    [5] = Color3.fromRGB(255, 222, 56),  -- Legendary (Gold)
    [6] = Color3.fromRGB(255, 0, 0),    -- Mythic (Red)
}

Utils.ItemTierNames = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic"
}

-- =======================================================
-- CONNECTION & THREAD UTILITIES
-- =======================================================

function Utils:AddConnection(conn)
    if conn then
        table.insert(self.Connections, conn)
    end
    return conn
end

function Utils:DisconnectAll()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

function Utils:SafeSpawn(threadName, func)
    task.spawn(function()
        local ok, err = pcall(func)
        if not ok then
            warn(string.format("[UTILS][THREAD_ERROR] %s: %s", tostring(threadName), tostring(err)))
        end
    end)
end

function Utils:SafeCall(func, ...)
    local ok, res = pcall(func, ...)
    if not ok then
        warn("[UTILS][SAFECALL] " .. tostring(res))
        return nil, res
    end
    return res, nil
end

-- =======================================================
-- GAME STRUCTURE CHECKS (ATTRIBUTES FROM GAMEMODULE)
-- =======================================================

function Utils:IsZombieOrBandit(mob)
    if not mob or not mob.Parent then return false end
    
    -- Check native game attributes first
    if mob:GetAttribute("Zombie") or mob:GetAttribute("Bandit") then
        return true
    end
    
    -- Check name list
    local mobNames = (self.Config and self.Config.GetMobNames and self.Config:GetMobNames()) or {
        "Zombie", "Crawler", "Brute", "Phaser", "Spitter", "Experiment", "Harbinger",
        "Elemental", "Exterminator", "Night Hunter", "Cyborg", "Heavy Rebel", "Rebel",
        "Gunner", "Sniper", "Bandit", "Merchant", "Juggernaut", "Butcher", "Riot", "Runner", "Boss"
    }
    
    for _, name in ipairs(mobNames) do
        if mob.Name == name or string.find(mob.Name, name) then
            return true
        end
    end
    
    return false
end

function Utils:IsDead(model)
    if not model or not model.Parent then return true end
    if model:GetAttribute("Dead") then return true end
    
    local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("MockHumanoid")
    if hum and hum.Health <= 0 then
        return true
    end
    return false
end

function Utils:IsUntouchable(model)
    if not model then return true end
    return model:GetAttribute("Untouchable") == true or model:GetAttribute("Untargetable") == true
end

function Utils:IsEnemyPlayer(playerChar)
    if not playerChar or not playerChar.Parent then return false end
    local myChar = LocalPlayer.Character
    if playerChar == myChar then return false end
    
    local isPlayer = playerChar:GetAttribute("Player") or Players:GetPlayerFromCharacter(playerChar) ~= nil
    if not isPlayer then return false end
    
    -- Check PvP attribute
    local isPvP = Workspace:GetAttribute("PvP") == true
    return isPvP or not (playerChar:IsDescendantOf(myChar) or myChar:IsDescendantOf(playerChar))
end

-- =======================================================
-- ITEM PART DETECTION
-- =======================================================

function Utils:GetItemMainPart(item)
    if not item then return nil end
    if item.PrimaryPart then return item.PrimaryPart end
    
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Handle" then
            return child
        end
    end
    
    local handle = item:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle
    end
    
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    
    return nil
end

function Utils:GetItemPrimaryPart(item)
    return self:GetItemMainPart(item)
end

-- Item Tier lookup
function Utils:GetItemTier(item)
    local tier = (item and item:GetAttribute("Tier")) or 1
    tier = math.clamp(tier, 1, 6)
    local color = self.ItemTierColors[tier] or Color3.fromRGB(255, 255, 255)
    local name = self.ItemTierNames[tier] or "Common"
    return tier, color, name
end

-- =======================================================
-- FAST DROPPED ITEMS QUERY (DROPPED ITEM SWARM INTEGRATION)
-- =======================================================

function Utils:GetDroppedUnits(position, radius)
    -- If game has DroppedItemSwarm loaded, utilize spatial grid for 10x faster lookup
    if DroppedItemSwarm and type(DroppedItemSwarm.getPossibleUnits) == "function" then
        local units = {}
        local ok = pcall(function()
            for _, item in ipairs(DroppedItemSwarm.getPossibleUnits(position, radius)) do
                if item and item.Parent and not item:GetAttribute("InteractedByPlayer") and not item:GetAttribute("Opened") then
                    table.insert(units, item)
                end
            end
        end)
        if ok and #units > 0 then
            return units
        end
    end
    
    -- Fallback: standard Workspace.DroppedItems scan
    local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    if not droppedItemsFolder then return {} end
    
    local results = {}
    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
        local part = self:GetItemMainPart(item)
        if part then
            local dist = (part.Position - position).Magnitude
            if dist <= radius then
                table.insert(results, item)
            end
        end
    end
    return results
end

-- =======================================================
-- CRATES
-- =======================================================

function Utils:FindAllCrates(unopenedOnly)
    local crates = {}
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return crates end
    
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then return crates end
    
    for _, child in ipairs(cratesFolder:GetChildren()) do
        if child:IsA("Model") then
            if not unopenedOnly or not child:GetAttribute("Opened") then
                table.insert(crates, child)
            end
        end
    end
    return crates
end

function Utils:GetCrateMainPart(crate)
    if not crate then return nil end
    if crate.PrimaryPart then return crate.PrimaryPart end
    
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart", "MainPart"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part end
    end
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

-- =======================================================
-- FOLDERS & PLAYERS
-- =======================================================

function Utils:DiscoverFolders()
    local charactersFolder = Workspace:FindFirstChild("Characters")
    local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    local structuresFolder = Workspace:FindFirstChild("Structures") 
        or Workspace:FindFirstChild("PlayerStructures") 
        or Workspace:FindFirstChild("Buildings")
    
    return {
        charactersFolder = charactersFolder,
        droppedItemsFolder = droppedItemsFolder,
        structuresFolder = structuresFolder
    }
end

function Utils:GetPlayerRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

function Utils:GetCharacter()
    return LocalPlayer.Character
end

function Utils:GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    return (pos1 - pos2).Magnitude
end

-- =======================================================
-- HIGHLIGHT & BILLBOARD CREATION
-- =======================================================

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

function Utils:CreateBillboard(adornee, size, offset)
    if not adornee then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = size or UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    return billboard
end

function Utils:GetDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

function Utils:GetHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

-- =======================================================
-- MAP FOG UNLOCK HELPER (Directly uses game structure)
-- =======================================================

function Utils:UnlockEntireMap(network, notifications)
    local fogFolder = Workspace:FindFirstChild("Fog")
    if not fogFolder then
        if notifications then notifications:Show("Map Unlock", "Workspace.Fog not found!", 2) end
        return 0
    end
    
    local count = 0
    local children = fogFolder:GetChildren()
    for _, part in ipairs(children) do
        local split = string.split(part.Name, "_")
        local x = tonumber(split[1])
        local y = tonumber(split[2])
        if x and y then
            if network and network.FireFogTouched then
                network:FireFogTouched(x, y)
                count = count + 1
            elseif ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Misc") and ReplicatedStorage.Remotes.Misc:FindFirstChild("FogTouched") then
                ReplicatedStorage.Remotes.Misc.FogTouched:FireServer(x, y)
                count = count + 1
            end
        end
    end
    
    if notifications then
        notifications:Show("Map Unlock", string.format("Unlocked %d map regions!", count), 3)
    end
    print(string.format("[MAP] Unlocked %d map fog sectors", count))
    return count
end

function Utils:Init(deps)
    self.Config = deps.config or deps.Config
    self.Notifications = deps.notifications or deps.Notifications
    return self
end

return Utils
