-- =======================================================
-- PINATHUB - NETWORK MODULE
-- =======================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}

-- Remote cache
Network.Remotes = {}

-- Find adjustable backpack remote
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
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    
    self.Remotes.pickUpItem = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")
    self.Remotes.placeStructure = Remotes and Remotes:FindFirstChild("Building") and Remotes.Building:FindFirstChild("PlaceStructure")
    self.Remotes.buyItem = Remotes and Remotes:FindFirstChild("Merchant") and Remotes.Merchant:FindFirstChild("BuyItem")
    self.Remotes.addSuppressor = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AddSuppressor")
    self.Remotes.reset = Remotes and Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("Reset")
    self.Remotes.adjustBackpack = findAdjustBackpack()
    
    return self.Remotes
end

function Network:GetRemote(name)
    return self.Remotes[name]
end

function Network:FirePickupItem(item)
    if self.Remotes.pickUpItem then
        pcall(function() self.Remotes.pickUpItem:FireServer(item) end)
    end
end

function Network:FireAdjustBackpack(item)
    if self.Remotes.adjustBackpack then
        pcall(function() self.Remotes.adjustBackpack:FireServer(item) end)
    end
end

function Network:FireSwing(tool)
    local swing = tool:FindFirstChild("Swing")
    if swing then
        pcall(function() swing:FireServer() end)
    end
end

function Network:FireHitTargets(tool, targets)
    local hitTargets = tool:FindFirstChild("HitTargets")
    if hitTargets then
        pcall(function() hitTargets:FireServer(targets) end)
    end
end

function Network:FireRemoteClick(tool, target)
    local remoteClick = tool:FindFirstChild("RemoteClick")
    if remoteClick then
        pcall(function() remoteClick:FireServer(target) end)
    end
end

function Network:HasAdjustBackpack()
    return self.Remotes.adjustBackpack ~= nil
end

return Network
