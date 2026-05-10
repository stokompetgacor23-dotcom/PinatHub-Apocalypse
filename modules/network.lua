-- =======================================================
-- PINATHUB - NETWORK MODULE WITH DEBUG
-- =======================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}
Network.ModuleName = "NETWORK"

-- Remote cache
Network.Remotes = {}

-- Find adjustable backpack remote
local function findAdjustBackpack()
    print(string.format("[%s][DISCOVERY] Finding AdjustBackpack remote", Network.ModuleName))
    
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    
    if Remotes then
        local Tools = Remotes:FindFirstChild("Tools")
        if Tools then
            local remote = Tools:FindFirstChild("AdjustBackpack")
            if remote then 
                print(string.format("[%s][DISCOVERY] Found AdjustBackpack in Remotes.Tools", Network.ModuleName))
                return remote 
            end
        end
    end
    
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name == "AdjustBackpack" then
            print(string.format("[%s][DISCOVERY] Found AdjustBackpack via full scan", Network.ModuleName))
            return remote
        end
    end
    
    print(string.format("[%s][WARN] AdjustBackpack remote not found", Network.ModuleName))
    return nil
end

function Network:Init()
    local ok, err = pcall(function()
        print(string.format("[%s][INIT] Initializing network module", Network.ModuleName))
        
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        
        if not Remotes then
            print(string.format("[%s][WARN] Remotes folder not found in ReplicatedStorage", Network.ModuleName))
        else
            print(string.format("[%s][INIT] Remotes folder found", Network.ModuleName))
        end
        
        self.Remotes.pickUpItem = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")
        self.Remotes.placeStructure = Remotes and Remotes:FindFirstChild("Building") and Remotes.Building:FindFirstChild("PlaceStructure")
        self.Remotes.buyItem = Remotes and Remotes:FindFirstChild("Merchant") and Remotes.Merchant:FindFirstChild("BuyItem")
        self.Remotes.addSuppressor = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AddSuppressor")
        self.Remotes.reset = Remotes and Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("Reset")
        self.Remotes.adjustBackpack = findAdjustBackpack()
        
        -- Log remote status
        print(string.format("[%s][INIT] Remote status:", Network.ModuleName))
        print(string.format("  - pickUpItem: %s", self.Remotes.pickUpItem and "found" or "missing"))
        print(string.format("  - placeStructure: %s", self.Remotes.placeStructure and "found" or "missing"))
        print(string.format("  - buyItem: %s", self.Remotes.buyItem and "found" or "missing"))
        print(string.format("  - addSuppressor: %s", self.Remotes.addSuppressor and "found" or "missing"))
        print(string.format("  - reset: %s", self.Remotes.reset and "found" or "missing"))
        print(string.format("  - adjustBackpack: %s", self.Remotes.adjustBackpack and "found" or "missing"))
        
        print(string.format("[%s][INIT] Network module initialized successfully", Network.ModuleName))
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] Init() failed: %s", Network.ModuleName, err))
    end
    
    return self.Remotes
end

function Network:GetRemote(name)
    print(string.format("[%s][GET] Getting remote: %s", Network.ModuleName, name))
    local remote = self.Remotes[name]
    if not remote then
        print(string.format("[%s][WARN] Remote '%s' not found", Network.ModuleName, name))
    end
    return remote
end

function Network:FirePickupItem(item)
    local ok, err = pcall(function()
        if not item then
            print(string.format("[%s][WARN] FirePickupItem called with nil item", Network.ModuleName))
            return
        end
        
        print(string.format("[%s][REMOTE] Firing PickUpItem for: %s", Network.ModuleName, item.Name))
        
        if self.Remotes.pickUpItem then
            self.Remotes.pickUpItem:FireServer(item)
            print(string.format("[%s][REMOTE] PickUpItem fired successfully", Network.ModuleName))
        else
            print(string.format("[%s][REMOTE] PickUpItem remote not available", Network.ModuleName))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FirePickupItem failed: %s", Network.ModuleName, err))
    end
end

function Network:FireAdjustBackpack(item)
    local ok, err = pcall(function()
        if not item then
            print(string.format("[%s][WARN] FireAdjustBackpack called with nil item", Network.ModuleName))
            return
        end
        
        print(string.format("[%s][REMOTE] Firing AdjustBackpack for: %s", Network.ModuleName, item.Name))
        
        if self.Remotes.adjustBackpack then
            self.Remotes.adjustBackpack:FireServer(item)
            print(string.format("[%s][REMOTE] AdjustBackpack fired successfully", Network.ModuleName))
        else
            print(string.format("[%s][REMOTE] AdjustBackpack remote not available", Network.ModuleName))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FireAdjustBackpack failed: %s", Network.ModuleName, err))
    end
end

function Network:FireSwing(tool)
    local ok, err = pcall(function()
        if not tool then
            print(string.format("[%s][WARN] FireSwing called with nil tool", Network.ModuleName))
            return
        end
        
        local swing = tool:FindFirstChild("Swing")
        if swing then
            swing:FireServer()
            print(string.format("[%s][REMOTE] Swing fired for tool: %s", Network.ModuleName, tool.Name))
        else
            print(string.format("[%s][REMOTE] Swing remote not found on tool: %s", Network.ModuleName, tool.Name))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FireSwing failed: %s", Network.ModuleName, err))
    end
end

function Network:FireHitTargets(tool, targets)
    local ok, err = pcall(function()
        if not tool then
            print(string.format("[%s][WARN] FireHitTargets called with nil tool", Network.ModuleName))
            return
        end
        
        local hitTargets = tool:FindFirstChild("HitTargets")
        if hitTargets then
            hitTargets:FireServer(targets)
            print(string.format("[%s][REMOTE] HitTargets fired for tool: %s with %d targets", 
                Network.ModuleName, tool.Name, targets and #targets or 0))
        else
            print(string.format("[%s][REMOTE] HitTargets remote not found on tool: %s", Network.ModuleName, tool.Name))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FireHitTargets failed: %s", Network.ModuleName, err))
    end
end

function Network:FireRemoteClick(tool, target)
    local ok, err = pcall(function()
        if not tool then
            print(string.format("[%s][WARN] FireRemoteClick called with nil tool", Network.ModuleName))
            return
        end
        
        local remoteClick = tool:FindFirstChild("RemoteClick")
        if remoteClick then
            remoteClick:FireServer(target)
            print(string.format("[%s][REMOTE] RemoteClick fired for tool: %s", Network.ModuleName, tool.Name))
        else
            print(string.format("[%s][REMOTE] RemoteClick remote not found on tool: %s", Network.ModuleName, tool.Name))
        end
    end)
    
    if not ok then
        warn(string.format("[%s][ERROR] FireRemoteClick failed: %s", Network.ModuleName, err))
    end
end

function Network:HasAdjustBackpack()
    local has = self.Remotes.adjustBackpack ~= nil
    print(string.format("[%s][CHECK] HasAdjustBackpack: %s", Network.ModuleName, has))
    return has
end

print(string.format("[%s][LOAD] Network module loaded", "NETWORK"))

return Network
