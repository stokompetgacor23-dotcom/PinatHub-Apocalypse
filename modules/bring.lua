-- =======================================================
-- PINATHUB - BRING SYSTEM MODULE
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Bring = {}
Bring.Active = false
Bring.Thread = nil

function Bring:Stop()
    self.Active = false
    if self.Thread then
        task.cancel(self.Thread)
        self.Thread = nil
    end
end

function Bring:Start(config, network, utils)
    self:Stop()
    self.Active = true

    self.Thread = task.spawn(function()
        local MAX_TIMEOUTS = 3
        local consecutiveTimeouts = 0
        local options = config:GetOptions()
        local toggles = config:GetToggles()

        while self.Active and toggles.BringPickupItem do
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end
            
            local folders = utils:DiscoverFolders()
            local droppedItemsFolder = folders.droppedItemsFolder
            if not droppedItemsFolder then task.wait(1) continue end

            local playerPos = rootPart.Position
            local allSelected = toggles.BringAllPickup
            local pickupSet = config:GetPickupItemSet()

            local targets = {}
            for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                if not pickupSet[item.Name] then continue end
                local mp = utils:GetItemMainPart(item)
                if not mp then continue end
                local d = (mp.Position - playerPos).Magnitude
                table.insert(targets, { item = item, part = mp, dist = d })
            end

            if #targets == 0 then task.wait(0.5) continue end

            local sortOrder = options.BringPickupSortOrder
            if sortOrder == "Nearest First" then
                table.sort(targets, function(a, b) return a.dist < b.dist end)
            elseif sortOrder == "Farthest First" then
                table.sort(targets, function(a, b) return a.dist > b.dist end)
            elseif sortOrder == "Alphabetical" then
                table.sort(targets, function(a, b) return a.item.Name < b.item.Name end)
            elseif sortOrder == "Reverse Alphabetical" then
                table.sort(targets, function(a, b) return a.item.Name > b.item.Name end)
            end

            for _, target in ipairs(targets) do
                if not self.Active then break end
                if not target.item.Parent then continue end

                local itemRef = target.item
                local partRef = target.part
                local targetCF = CFrame.new(partRef.Position + Vector3.new(0, 2, 0))
                local deadline = tick() + 2.0

                while tick() < deadline and itemRef.Parent do
                    rootPart.CFrame = targetCF
                    network:FirePickupItem(itemRef)
                    task.wait(0.05)
                end

                if itemRef.Parent == nil then
                    consecutiveTimeouts = 0
                else
                    consecutiveTimeouts = consecutiveTimeouts + 1
                    if consecutiveTimeouts >= MAX_TIMEOUTS then
                        self.Active = false
                        task.defer(function()
                            toggles.BringPickupItem = false
                            if self.Notifications then
                                self.Notifications:Show("Bring Pickup Item", "Backpack full – auto disabled.", 4)
                            end
                        end)
                        return
                    end
                end
            end
        end

        self.Active = false
    end)
end

function Bring:Init(deps)
    self.Config = deps.Config
    self.Network = deps.Network
    self.Utils = deps.Utils
    self.Notifications = deps.Notifications
    return self
end

return Bring
