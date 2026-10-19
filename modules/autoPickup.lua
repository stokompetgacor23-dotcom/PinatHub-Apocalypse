-- =======================================================
-- PINATHUB - AUTO PICKUP MODULE (UPDATED WITH GAME DUMP INTEGRATION)
-- Uses official PickUpItem remote & DroppedItemSwarm fast queries
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AutoPickup = {}

AutoPickup.Active = false
AutoPickup.Connection = nil
AutoPickup.PickupCategories = {
    All = true,
    Ammo = true,
    Guns = true,
    Melee = true,
    Medical = true,
    Armor = true,
    Fuel = true,
    Resources = true,
    Food = true,
    Abilities = true,
}

-- ============================================
-- START AUTO PICKUP
-- ============================================
function AutoPickup:Start(options, notifications)
    if self.Active then return end
    
    self.Active = true
    self.Options = options or (self.Config and self.Config:GetOptions()) or {}
    local configPickupSet = (self.Config and self.Config:GetPickupItemSet()) or {}
    local utils = self.Utils
    local network = self.Network
    
    local lastPickupTick = 0
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        
        local now = tick()
        local pickupDelay = self.Options.AutoPickupDelay or 0.08
        if now - lastPickupTick < pickupDelay then return end
        
        pcall(function()
            local char = LocalPlayer.Character
            if not char or (char:GetAttribute("Dead") == true) then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local myPos = hrp.Position
            local pickupRange = self.Options.AutoPickupRange or 50
            local pickupAll = self.Options.AutoPickupAll
            if pickupAll == nil then pickupAll = true end
            
            -- Fast query using DroppedItemSwarm if available or DroppedItems folder
            local candidateItems = {}
            if utils and utils.GetDroppedUnits then
                candidateItems = utils:GetDroppedUnits(myPos, pickupRange)
            else
                local dropped = Workspace:FindFirstChild("DroppedItems")
                if dropped then candidateItems = dropped:GetChildren() end
            end
            
            local itemsToPickup = {}
            
            for _, item in ipairs(candidateItems) do
                if item and item.Parent and not item:GetAttribute("Opened") then
                    local shouldPickup = pickupAll 
                        or configPickupSet[item.Name] 
                        or item:GetAttribute("CanPickUp") 
                        or item:IsA("Tool")
                    
                    if shouldPickup then
                        local part = (utils and utils:GetItemMainPart(item)) or item.PrimaryPart or item:FindFirstChild("Handle")
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
            end
            
            if #itemsToPickup == 0 then return end
            
            -- Sort by nearest first
            table.sort(itemsToPickup, function(a, b) return a.dist < b.dist end)
            
            -- Pick up top candidate(s)
            for _, target in ipairs(itemsToPickup) do
                if not self.Active then break end
                if not target.item.Parent then continue end
                
                local success = false
                if network and network.FirePickupItem then
                    success = network:FirePickupItem(target.item)
                else
                    -- Direct remote fallback
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    local pickUpItem = remotes and remotes:FindFirstChild("Interaction") and remotes.Interaction:FindFirstChild("PickUpItem")
                    if pickUpItem then
                        pcall(function() pickUpItem:FireServer(target.item) end)
                        success = true
                    end
                end
                
                if success then
                    lastPickupTick = tick()
                end
                
                -- Process single item per step if not picking up all in one frame
                if not pickupAll then
                    break
                end
            end
        end)
    end)
    
    if notifications then
        notifications:Show("Auto Pickup", "Enabled - Range: " .. (self.Options.AutoPickupRange or 50) .. " studs", 2)
    end
    print("[AUTO PICKUP] Started - Range:", self.Options.AutoPickupRange or 50)
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
    
    print("[AUTO PICKUP MODULE] Initialized with official PickUpItem remote")
    return self
end

return AutoPickup
