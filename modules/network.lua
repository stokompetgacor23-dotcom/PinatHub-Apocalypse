-- =======================================================
-- PINATHUB - NETWORK MODULE (ENHANCED FOR LATEST GAME DUMP)
-- Fully aligned with ReplicatedStorage structure & remotes
-- =======================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Network = {}
Network.ModuleName = "NETWORK"

-- Remote cache
Network.Remotes = {}

-- Find adjustable backpack remote (legacy fallback)
local function findAdjustBackpack()
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local Tools = Remotes:FindFirstChild("Tools")
        if Tools then
            local remote = Tools:FindFirstChild("AdjustBackpack")
            if remote then return remote end
        end
    end
    
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name == "AdjustBackpack" then
            return remote
        end
    end
    return nil
end

function Network:Init()
    local ok, err = pcall(function()
        print(string.format("[%s][INIT] Initializing network module with latest game structure", Network.ModuleName))
        
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not Remotes then
            warn(string.format("[%s][WARN] Remotes folder not found in ReplicatedStorage", Network.ModuleName))
        end
        
        -- Official Game Remotes from ReplicatedStorage.Remotes
        local interaction = Remotes and Remotes:FindFirstChild("Interaction")
        self.Remotes.pickUpItem = interaction and interaction:FindFirstChild("PickUpItem")
        self.Remotes.dropTool = interaction and interaction:FindFirstChild("DropTool")
        
        local building = Remotes and Remotes:FindFirstChild("Building")
        self.Remotes.placeStructure = building and building:FindFirstChild("PlaceStructure")
        
        local merchant = Remotes and Remotes:FindFirstChild("Merchant")
        self.Remotes.buyItem = merchant and merchant:FindFirstChild("BuyItem")
        
        local misc = Remotes and Remotes:FindFirstChild("Misc")
        self.Remotes.reset = misc and misc:FindFirstChild("Reset")
        self.Remotes.fogTouched = misc and misc:FindFirstChild("FogTouched")
        
        local tools = Remotes and Remotes:FindFirstChild("Tools")
        self.Remotes.addSuppressor = tools and tools:FindFirstChild("AddSuppressor")
        self.Remotes.adjustBackpack = findAdjustBackpack()
        
        local replication = Remotes and Remotes:FindFirstChild("Replication")
        self.Remotes.mobKilled = replication and replication:FindFirstChild("MobKilled")
        self.Remotes.ping = replication and replication:FindFirstChild("Ping")
        
        -- Troll / Content Creator Remotes (from game dump: ReplicatedStorage.TrollRemotes)
        local trollRemotes = ReplicatedStorage:FindFirstChild("TrollRemotes")
        if trollRemotes then
            self.Remotes.troll = {
                Folder = trollRemotes,
                IsAllowed = trollRemotes:FindFirstChild("IsAllowed"),
                SpawnZombie = trollRemotes:FindFirstChild("SpawnZombie"),
                SpawnItem = trollRemotes:FindFirstChild("SpawnItem"),
                ServerMessage = trollRemotes:FindFirstChild("ServerMessage"),
                ToggleFly = trollRemotes:FindFirstChild("ToggleFly"),
                ToggleInvisible = trollRemotes:FindFirstChild("ToggleInvisible"),
                BecomeGiant = trollRemotes:FindFirstChild("BecomeGiant"),
                TeleportToServer = trollRemotes:FindFirstChild("TeleportToServer"),
            }
            print(string.format("[%s][INIT] TrollRemotes detected in ReplicatedStorage", Network.ModuleName))
        end
        
        -- Log remote status
        print(string.format("[%s][INIT] Remote status:", Network.ModuleName))
        print(string.format("  - PickUpItem (Interaction): %s", self.Remotes.pickUpItem and "found" or "missing"))
        print(string.format("  - DropTool (Interaction): %s", self.Remotes.dropTool and "found" or "missing"))
        print(string.format("  - FogTouched (Misc): %s", self.Remotes.fogTouched and "found" or "missing"))
        print(string.format("  - Reset (Misc): %s", self.Remotes.reset and "found" or "missing"))
        print(string.format("  - AdjustBackpack: %s", self.Remotes.adjustBackpack and "found" or "missing"))
        print(string.format("  - TrollRemotes: %s", self.Remotes.troll and "found" or "missing"))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] Init() failed: %s", Network.ModuleName, err))
    end
    
    return self.Remotes
end

function Network:GetRemote(name)
    return self.Remotes[name]
end

-- =======================================================
-- PICKUP ITEM (Priority: PickUpItem RemoteEvent -> AdjustBackpack)
-- =======================================================
function Network:FirePickupItem(item)
    if not item or not item.Parent then return false end
    
    local success = false
    -- Official game pickup method: game.ReplicatedStorage.Remotes.Interaction.PickUpItem
    if self.Remotes.pickUpItem then
        local ok, err = pcall(function()
            self.Remotes.pickUpItem:FireServer(item)
        end)
        if ok then success = true end
    end
    
    -- Fallback to AdjustBackpack if PickUpItem didn't work or not found
    if not success and self.Remotes.adjustBackpack then
        local ok, err = pcall(function()
            self.Remotes.adjustBackpack:FireServer(item)
        end)
        if ok then success = true end
    end
    
    return success
end

-- =======================================================
-- ADJUST BACKPACK (DIRECT TO BAG PICKUP)
-- =======================================================
function Network:FireAdjustBackpack(item)
    if not item or not item.Parent then return false end
    
    local success = false
    if self.Remotes.adjustBackpack then
        local ok = pcall(function()
            self.Remotes.adjustBackpack:FireServer(item)
        end)
        if ok then success = true end
    end
    
    if not success and self.Remotes.pickUpItem then
        local ok = pcall(function()
            self.Remotes.pickUpItem:FireServer(item)
        end)
        if ok then success = true end
    end
    
    return success
end

-- =======================================================
-- DROP TOOL
-- =======================================================
function Network:FireDropTool(tool, pivot)
    if not tool then return nil end
    if self.Remotes.dropTool then
        local ok, res = pcall(function()
            return self.Remotes.dropTool:InvokeServer(tool, pivot or tool:GetPivot())
        end)
        if ok then return res end
    end
    return nil
end

-- =======================================================
-- FOG TOUCHED (Map Exploration Unlocker)
-- =======================================================
function Network:FireFogTouched(x, y)
    if self.Remotes.fogTouched and x and y then
        local ok, err = pcall(function()
            self.Remotes.fogTouched:FireServer(x, y)
        end)
        return ok
    end
    return false
end

-- =======================================================
-- RESET CHARACTER
-- =======================================================
function Network:FireReset()
    if self.Remotes.reset then
        pcall(function()
            self.Remotes.reset:FireServer()
        end)
    end
end

-- =======================================================
-- WEAPON / TOOL ATTACK DISPATCHER
-- Supports all weapon types from gamemodule (Melee, Hammer, Scorchblade, Guns)
-- =======================================================
function Network:FireToolAttack(tool, targets, hitPos)
    if not tool or not tool.Parent then return false end
    
    local targetList = type(targets) == "table" and targets or {targets}
    local primaryTarget = targetList[1]
    local attackSuccess = false
    
    -- 1. Special Melee: Power Hammer
    local powerSwing = tool:FindFirstChild("PowerSwingRemote")
    if powerSwing and primaryTarget then
        pcall(function()
            local mults = {}
            for _ in ipairs(targetList) do table.insert(mults, 1) end
            local cf = primaryTarget:GetPivot()
            powerSwing:FireServer(targetList, mults, cf)
        end)
        attackSuccess = true
    end
    
    -- 2. Special Melee: StrikeRemote (Scorchblade)
    local strikeRemote = tool:FindFirstChild("StrikeRemote")
    if strikeRemote and primaryTarget then
        pcall(function()
            strikeRemote:FireServer(primaryTarget:GetPivot())
        end)
        attackSuccess = true
    end
    
    -- 3. Standard Melee: Swing + Hit / HitTargets
    local swing = tool:FindFirstChild("Swing")
    local hit = tool:FindFirstChild("Hit") or tool:FindFirstChild("HitTargets")
    if swing and hit then
        pcall(function()
            swing:FireServer()
            hit:FireServer(targetList)
        end)
        attackSuccess = true
    elseif hit then
        pcall(function() hit:FireServer(targetList) end)
        attackSuccess = true
    elseif swing then
        pcall(function() swing:FireServer() end)
        attackSuccess = true
    end
    
    -- 4. RemoteClick
    local remoteClick = tool:FindFirstChild("RemoteClick")
    if remoteClick and primaryTarget then
        pcall(function()
            remoteClick:FireServer(primaryTarget)
        end)
        attackSuccess = true
    end
    
    -- 5. Fallback tool:Activate() with burst for instant break
    pcall(function()
        for _ = 1, 3 do
            tool:Activate()
        end
    end)
    attackSuccess = true
    
    return attackSuccess
end

-- =======================================================
-- WEAPON SHOOT & RELOAD
-- =======================================================
function Network:FireShoot(tool, origin, targetPos, ...)
    if not tool then return false end
    local shootRemote = tool:FindFirstChild("Shoot")
    if shootRemote then
        local ok, err = pcall(function()
            shootRemote:FireServer(origin, targetPos, ...)
        end)
        return ok
    end
    return false
end

function Network:FireReload(tool)
    if not tool then return false end
    local reloadRemote = tool:FindFirstChild("Reload")
    if reloadRemote then
        local ok, res = pcall(function()
            if reloadRemote:IsA("RemoteFunction") then
                return reloadRemote:InvokeServer()
            else
                reloadRemote:FireServer()
                return true
            end
        end)
        return ok and res
    end
    return false
end

-- =======================================================
-- TROLL / CREATOR TOOLKIT HELPERS
-- =======================================================
function Network:IsTrollAllowed()
    if not self.Remotes.troll or not self.Remotes.troll.IsAllowed then
        return false
    end
    local ok, res = pcall(function()
        return self.Remotes.troll.IsAllowed:InvokeServer()
    end)
    return ok and res == true
end

function Network:SpawnZombie(mobName, targetPlayer)
    if self.Remotes.troll and self.Remotes.troll.SpawnZombie then
        pcall(function()
            self.Remotes.troll.SpawnZombie:FireServer(mobName, targetPlayer)
        end)
        return true
    end
    return false
end

function Network:SpawnItem(itemName, targetPlayer)
    if self.Remotes.troll and self.Remotes.troll.SpawnItem then
        pcall(function()
            self.Remotes.troll.SpawnItem:FireServer(itemName, targetPlayer)
        end)
        return true
    end
    return false
end

function Network:SendServerBroadcast(message)
    if self.Remotes.troll and self.Remotes.troll.ServerMessage then
        pcall(function()
            self.Remotes.troll.ServerMessage:FireServer(message)
        end)
        return true
    end
    return false
end

print(string.format("[%s][LOAD] Enhanced network module loaded", "NETWORK"))

return Network
