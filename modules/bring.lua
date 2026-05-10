-- =======================================================
-- PINATHUB - BRING SYSTEM MODULE WITH DEBUG
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Bring = {}
Bring.Active = false
Bring.Thread = nil
Bring.ModuleName = "BRING"

local Utils = nil  -- Will be set in Init

function Bring:Stop()
    local ok, err = pcall(function()
        print(string.format("[%s][STOP] Stopping bring system", Bring.ModuleName))
        self.Active = false
        if self.Thread then
            task.cancel(self.Thread)
            self.Thread = nil
            print(string.format("[%s][STOP] Thread cancelled successfully", Bring.ModuleName))
        end
        print(string.format("[%s][STOP] Stop completed - Active:", self.Active, "Thread:", self.Thread ~= nil, "Thread exists"))
    end)
    if not ok then
        warn(string.format("[%s][ERROR] Stop() failed: %s", Bring.ModuleName, err))
    end
end

function Bring:Start(config, network, utils)
    local ok, err = pcall(function()
        print(string.format("[%s][START] Starting bring system", Bring.ModuleName))
        
        -- Check dependencies
        if not config then
            warn(string.format("[%s] Config missing", Bring.ModuleName))
            return
        end
        if not network then
            warn(string.format("[%s] Network missing", Bring.ModuleName))
            return
        end
        if not utils then
            warn(string.format("[%s] Utils missing", Bring.ModuleName))
            return
        end
        
        Utils = utils
        
        self:Stop()
        self.Active = true
        print(string.format("[%s][START] Active state set to true", Bring.ModuleName))

        self.Thread = task.spawn(function()
            local ok, err = pcall(function()
                print(string.format("[%s][THREAD] Bring thread started", Bring.ModuleName))
                local MAX_TIMEOUTS = 3
                local consecutiveTimeouts = 0
                local options = config:GetOptions()
                local toggles = config:GetToggles()
                
                print(string.format("[%s][LOOP] Entering main while loop", Bring.ModuleName))

                while self.Active and toggles.BringPickupItem do
                    print(string.format("[%s][LOOP] Loop iteration - Active:", self.Active, "Toggle:", toggles.BringPickupItem))
                    
                    -- Character check with nil safety
                    local char = LocalPlayer.Character
                    if not char then
                        print(string.format("[%s][CHAR] No character found, waiting...", Bring.ModuleName))
                        task.wait(0.5) 
                        continue 
                    end
                    
                    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                    if not rootPart then 
                        print(string.format("[%s][CHAR] No HumanoidRootPart found", Bring.ModuleName))
                        task.wait(0.5) 
                        continue 
                    end
                    print(string.format("[%s][CHAR] Character and RootPart verified", Bring.ModuleName))
                    
                    local folders = utils:DiscoverFolders()
                    local droppedItemsFolder = folders.droppedItemsFolder
                    if not droppedItemsFolder then 
                        print(string.format("[%s][FOLDER] DroppedItems folder not found", Bring.ModuleName))
                        task.wait(1) 
                        continue 
                    end
                    print(string.format("[%s][FOLDER] DroppedItems folder found", Bring.ModuleName))

                    local playerPos = rootPart.Position
                    local allSelected = toggles.BringAllPickup
                    local pickupSet = config:GetPickupItemSet()
                    print(string.format("[%s][STATE] Player position:", playerPos, "AllSelected:", allSelected))

                    local targets = {}
                    local itemsCount = 0
                    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                        itemsCount = itemsCount + 1
                        if not pickupSet[item.Name] then 
                            print(string.format("[%s][FILTER] Skipping item not in pickup set: %s", Bring.ModuleName, item.Name))
                            continue 
                        end
                        local mp = utils:GetItemMainPart(item)
                        if not mp then 
                            print(string.format("[%s][FILTER] No main part for item: %s", Bring.ModuleName, item.Name))
                            continue 
                        end
                        local d = (mp.Position - playerPos).Magnitude
                        table.insert(targets, { item = item, part = mp, dist = d })
                        print(string.format("[%s][TARGET] Found target: %s at distance %.2f", Bring.ModuleName, item.Name, d))
                    end
                    print(string.format("[%s][SCAN] Scanned %d items, found %d targets", Bring.ModuleName, itemsCount, #targets))

                    if #targets == 0 then 
                        print(string.format("[%s][TARGET] No targets found, waiting...", Bring.ModuleName))
                        task.wait(0.5) 
                        continue 
                    end

                    local sortOrder = options.BringPickupSortOrder
                    print(string.format("[%s][SORT] Sorting targets by: %s", Bring.ModuleName, sortOrder))
                    
                    if sortOrder == "Nearest First" then
                        table.sort(targets, function(a, b) return a.dist < b.dist end)
                        print(string.format("[%s][SORT] Sorted by nearest first", Bring.ModuleName))
                    elseif sortOrder == "Farthest First" then
                        table.sort(targets, function(a, b) return a.dist > b.dist end)
                        print(string.format("[%s][SORT] Sorted by farthest first", Bring.ModuleName))
                    elseif sortOrder == "Alphabetical" then
                        table.sort(targets, function(a, b) return a.item.Name < b.item.Name end)
                        print(string.format("[%s][SORT] Sorted alphabetically", Bring.ModuleName))
                    elseif sortOrder == "Reverse Alphabetical" then
                        table.sort(targets, function(a, b) return a.item.Name > b.item.Name end)
                        print(string.format("[%s][SORT] Sorted reverse alphabetically", Bring.ModuleName))
                    end

                    for idx, target in ipairs(targets) do
                        print(string.format("[%s][LOOP] Processing target %d/%d: %s", Bring.ModuleName, idx, #targets, target.item.Name))
                        
                        if not self.Active then 
                            print(string.format("[%s][LOOP] System deactivated, breaking", Bring.ModuleName))
                            break 
                        end
                        if not target.item.Parent then 
                            print(string.format("[%s][LOOP] Item parent missing, skipping", Bring.ModuleName))
                            continue 
                        end

                        local itemRef = target.item
                        local partRef = target.part
                        local targetCF = CFrame.new(partRef.Position + Vector3.new(0, 2, 0))
                        local deadline = tick() + 2.0
                        print(string.format("[%s][MOVE] Moving to item at position: %s", Bring.ModuleName, tostring(partRef.Position)))

                        local moveSuccess = true
                        while tick() < deadline and itemRef.Parent do
                            local ok, err = pcall(function()
                                rootPart.CFrame = targetCF
                                network:FirePickupItem(itemRef)
                            end)
                            if not ok then
                                warn(string.format("[%s][ERROR] Error during pickup: %s", Bring.ModuleName, err))
                                moveSuccess = false
                                break
                            end
                            task.wait(0.05)
                        end

                        if itemRef.Parent == nil then
                            consecutiveTimeouts = 0
                            print(string.format("[%s][SUCCESS] Item picked up successfully: %s", Bring.ModuleName, target.item.Name))
                        else
                            consecutiveTimeouts = consecutiveTimeouts + 1
                            print(string.format("[%s][TIMEOUT] Pickup timeout %d/%d for item: %s", Bring.ModuleName, consecutiveTimeouts, MAX_TIMEOUTS, target.item.Name))
                            if consecutiveTimeouts >= MAX_TIMEOUTS then
                                print(string.format("[%s][STATE] Max timeouts reached, disabling system", Bring.ModuleName))
                                self.Active = false
                                task.defer(function()
                                    local ok, err = pcall(function()
                                        toggles.BringPickupItem = false
                                        print(string.format("[UI][BRING] BringPickupItem toggled to false due to backpack full"))
                                        if self.Notifications then
                                            self.Notifications:Show("Bring Pickup Item", "Backpack full – auto disabled.", 4)
                                        end
                                    end)
                                    if not ok then
                                        warn(string.format("[%s][ERROR] Failed to disable toggle: %s", Bring.ModuleName, err))
                                    end
                                end)
                                return
                            end
                        end
                    end
                end

                print(string.format("[%s][LOOP] Exited while loop", Bring.ModuleName))
                self.Active = false
                print(string.format("[%s][THREAD] Bring thread completed", Bring.ModuleName))
            end)
            if not ok then
                warn(string.format("[%s][THREAD_ERROR] Bring thread crashed: %s", Bring.ModuleName, err))
                self.Active = false
            end
        end)
        
        print(string.format("[%s][START] Start completed successfully", Bring.ModuleName))
    end)
    if not ok then
        warn(string.format("[%s][ERROR] Start() failed: %s", Bring.ModuleName, err))
    end
end

function Bring:Init(deps)
    local ok, err = pcall(function()
        print(string.format("[%s][INIT] Initializing bring module", Bring.ModuleName))
        
        if not deps then
            warn(string.format("[%s] Dependencies table missing", Bring.ModuleName))
            return self
        end
        
        self.Config = deps.Config
        self.Network = deps.Network
        self.Utils = deps.Utils
        self.Notifications = deps.Notifications
        
        if not self.Config then warn(string.format("[%s] Config dependency is nil", Bring.ModuleName)) end
        if not self.Network then warn(string.format("[%s] Network dependency is nil", Bring.ModuleName)) end
        if not self.Utils then warn(string.format("[%s] Utils dependency is nil", Bring.ModuleName)) end
        if not self.Notifications then warn(string.format("[%s] Notifications dependency is nil", Bring.ModuleName)) end
        
        print(string.format("[%s][INIT] Module initialized successfully", Bring.ModuleName))
    end)
    if not ok then
        warn(string.format("[%s][ERROR] Init() failed: %s", Bring.ModuleName, err))
    end
    return self
end

print(string.format("[%s][LOAD] Bring module loaded", "BRING"))

return Bring
