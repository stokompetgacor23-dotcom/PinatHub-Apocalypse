-- =======================================================
-- PINATHUB - BRING SYSTEM MODULE (UPDATED WITH GAME DUMP INTEGRATION)
-- Uses official PickUpItem remote & supports All Items toggle
-- =======================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Bring = {}
Bring.Active = false
Bring.Thread = nil
Bring.ModuleName = "BRING"

function Bring:Stop()
    self.Active = false
    if self.Thread then
        task.cancel(self.Thread)
        self.Thread = nil
    end
    print("[BRING] System stopped")
end

function Bring:Start(config, network, utils)
    if not config or not network or not utils then
        warn("[BRING] Missing required dependencies")
        return
    end
    
    self:Stop()
    self.Active = true

    self.Thread = task.spawn(function()
        local MAX_TIMEOUTS = 4
        local consecutiveTimeouts = 0
        local options = config:GetOptions()
        local toggles = config:GetToggles()

        while self.Active and toggles.BringPickupItem do
            local char = LocalPlayer.Character
            if not char or (char:GetAttribute("Dead") == true) then
                task.wait(0.5)
                continue
            end
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                task.wait(0.5)
                continue
            end
            
            local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
            if not droppedItemsFolder then
                task.wait(1)
                continue
            end

            local playerPos = rootPart.Position
            local allSelected = toggles.BringAllPickup
            local pickupSet = config:GetPickupItemSet()

            local targets = {}
            for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                if not item or not item.Parent then continue end
                
                -- Check if item is valid
                local shouldBring = allSelected or pickupSet[item.Name] or item:GetAttribute("CanPickUp") or item:IsA("Tool")
                if not shouldBring then continue end
                
                local mp = utils:GetItemMainPart(item)
                if not mp then continue end
                
                local d = (mp.Position - playerPos).Magnitude
                table.insert(targets, { item = item, part = mp, dist = d })
            end

            if #targets == 0 then
                task.wait(0.5)
                continue
            end

            local sortOrder = options.BringPickupSortOrder or "Nearest First"
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
                if not self.Active or not toggles.BringPickupItem then break end
                if not target.item.Parent then continue end

                local itemRef = target.item
                local partRef = target.part
                local targetCF = CFrame.new(partRef.Position + Vector3.new(0, 2, 0))
                local deadline = tick() + 2.0

                while tick() < deadline and itemRef.Parent and self.Active do
                    pcall(function()
                        rootPart.CFrame = targetCF
                        network:FirePickupItem(itemRef)
                    end)
                    task.wait(0.06)
                end

                if itemRef.Parent == nil then
                    consecutiveTimeouts = 0
                else
                    consecutiveTimeouts = consecutiveTimeouts + 1
                    if consecutiveTimeouts >= MAX_TIMEOUTS then
                        self.Active = false
                        toggles.BringPickupItem = false
                        if self.Notifications then
                            self.Notifications:Show("Bring Item", "Backpack full or item unreachable – auto disabled.", 4)
                        end
                        return
                    end
                end
            end
            task.wait(0.1)
        end
        self.Active = false
    end)
    
    print("[BRING] Started successfully")
end

function Bring:Init(deps)
    self.Config = deps.config or deps.Config
    self.Network = deps.network or deps.Network
    self.Utils = deps.utils or deps.Utils
    self.Notifications = deps.notifications or deps.Notifications
    return self
end

return Bring
