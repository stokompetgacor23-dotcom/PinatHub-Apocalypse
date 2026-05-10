-- =======================================================
-- PINATHUB - ESP MODULE (COMPLETE WITH ITEM ESP)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

ESP.Instances = {
    mob = {},
    player = {},
    structure = {},
    crate = {},
    item = {}  -- Added for item ESP
}

ESP.Options = {
    mob = { ESP = false, Chams = false, Name = false, Distance = false },
    player = { ESP = false, Chams = false, Name = false, Distance = false, Health = false },
    structure = { ESP = false, Chams = false, Name = false, Distance = false }
}

-- ============================================
-- ITEM ESP DEFINITIONS (SAMA SEPERTI SINGLE FILE)
-- ============================================
ESP.ItemCategories = {
    Gun = {
        displayName = "Gun ESP",
        color = Color3.fromRGB(255, 30, 30),
        textColor = Color3.fromRGB(255, 120, 120),
        items = {
            "AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"
        }
    },
    Melee = {
        displayName = "Melee ESP",
        color = Color3.fromRGB(255, 140, 0),
        textColor = Color3.fromRGB(255, 200, 100),
        items = {
            "Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"
        }
    },
    Medical = {
        displayName = "Medical ESP",
        color = Color3.fromRGB(0, 255, 80),
        textColor = Color3.fromRGB(150, 255, 150),
        items = {
            "Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"
        }
    },
    Armor = {
        displayName = "Armor ESP",
        color = Color3.fromRGB(0, 100, 255),
        textColor = Color3.fromRGB(160, 200, 255),
        items = {
            "Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"
        }
    },
    Food = {
        displayName = "Food ESP",
        color = Color3.fromRGB(190, 255, 0),
        textColor = Color3.fromRGB(210, 255, 150),
        items = {
            "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"
        }
    },
    Resource = {
        displayName = "Resources ESP",
        color = Color3.fromRGB(0, 220, 255),
        textColor = Color3.fromRGB(180, 240, 255),
        items = {
            "AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart"
        }
    },
    Fuel = {
        displayName = "Fuel ESP",
        color = Color3.fromRGB(255, 220, 0),
        textColor = Color3.fromRGB(255, 240, 160),
        items = { "Nuclear Fuel", "Refined Fuel", "Fuel" }
    },
    Ability = {
        displayName = "Abilities ESP",
        color = Color3.fromRGB(180, 0, 255),
        textColor = Color3.fromRGB(220, 150, 255),
        items = {
            "Airstrike", "Attack Order", "Call of the Dead",
            "Summon Brute", "Summon Zombies", "Taunt",
            "The Future", "The Past", "The Present"
        }
    }
}

-- Item ESP state
ESP.ItemOptions = {}
ESP.ItemInstances = {}

for category, data in pairs(ESP.ItemCategories) do
    ESP.ItemOptions[category] = { ESP = false, Chams = false, Name = false, Distance = false }
    ESP.ItemInstances[category] = {}
    
    -- Create item lookup table
    local itemLookup = {}
    for _, itemName in ipairs(data.items) do
        itemLookup[itemName] = category
    end
end

-- ============================================
-- MOB ESP FUNCTIONS
-- ============================================
function ESP:RemoveMobESP(char)
    local esp = self.Instances.mob[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.Instances.mob[char] = nil
    end
end

function ESP:CreateMobESP(char, mobNames, maxDistance)
    if not char:IsA("Model") then return end
    if self.Instances.mob[char] then return end

    local root = self.Utils:GetPlayerRoot(char)
    if not root then return end

    local espTable = {}
    local mobColors = {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}
    local opts = self.Options.mob

    if opts.Chams then
        local highlight = self.Utils:CreateHighlight(char, mobColors.fill, 0.3, mobColors.outline, 0.8)
        espTable.Highlight = highlight
    end

    if opts.Name or opts.Distance then
        local billboard = self.Utils:CreateBillboard(root, UDim2.new(0, 220, 0, 50), Vector3.new(0, 3, 0))
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = char.Name
        nameLabel.TextColor3 = mobColors.outline
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = opts.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = opts.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.Root = root

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then
                connection:Disconnect()
                return
            end
            if nameLabel and nameLabel.Visible and nameLabel.Parent then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    nameLabel.Text = char.Name .. " [" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                end
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = self.Utils:GetPlayerRoot(myChar)
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    local maxDist = maxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = self.Utils:GetDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        if self.Utils then self.Utils:AddConnection(connection) end
    end

    self.Instances.mob[char] = espTable
end

function ESP:RefreshMobESP(mobNames, maxDistance)
    for char, _ in pairs(self.Instances.mob) do
        self:RemoveMobESP(char)
    end
    if not self.Options.mob.ESP then return end
    local folders = self.Utils:DiscoverFolders()
    if not folders.charactersFolder then return end
    for _, child in ipairs(folders.charactersFolder:GetChildren()) do
        local found = false
        for _, name in ipairs(mobNames) do
            if child.Name == name then found = true break end
        end
        if found then
            self:CreateMobESP(child, mobNames, maxDistance)
        end
    end
end

-- ============================================
-- PLAYER ESP FUNCTIONS
-- ============================================
function ESP:RemovePlayerESP(player)
    local esp = self.Instances.player[player]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        if esp.CharAddedConn then esp.CharAddedConn:Disconnect() end
        self.Instances.player[player] = nil
    end
end

function ESP:CreatePlayerESP(player, maxDistance)
    if player == LocalPlayer then return end
    if self.Instances.player[player] then return end

    local char = player.Character
    if not char then return end

    local root = self.Utils:GetPlayerRoot(char)
    if not root then return end

    local espTable = {}
    local opts = self.Options.player

    if opts.Chams then
        local highlight = self.Utils:CreateHighlight(char, Color3.fromRGB(0, 100, 255), 0.3, Color3.fromRGB(100, 180, 255), 0.8)
        espTable.Highlight = highlight
    end

    if opts.Name or opts.Distance or opts.Health then
        local billboard = self.Utils:CreateBillboard(root, UDim2.new(0, 220, 0, 70), Vector3.new(0, 3, 0))
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Visible = opts.Name
        nameLabel.Parent = frame

        local toolLabel = Instance.new("TextLabel")
        toolLabel.Name = "ToolLabel"
        toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
        toolLabel.Position = UDim2.new(0, 0, 0.3, 0)
        toolLabel.BackgroundTransparency = 1
        toolLabel.Text = ""
        toolLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
        toolLabel.TextStrokeTransparency = 0.2
        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        toolLabel.Font = Enum.Font.Gotham
        toolLabel.TextSize = 11
        toolLabel.Visible = opts.Name
        toolLabel.Parent = frame

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.55, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        healthLabel.TextStrokeTransparency = 0.2
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = 11
        healthLabel.Visible = opts.Health
        healthLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.2, 0)
        distLabel.Position = UDim2.new(0, 0, 0.78, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 11
        distLabel.Visible = opts.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.ToolLabel = toolLabel
        espTable.HealthLabel = healthLabel
        espTable.DistLabel = distLabel

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not player or not player.Parent then
                connection:Disconnect()
                return
            end
            local c = player.Character
            if not c or not c.Parent then return end
            local r = self.Utils:GetPlayerRoot(c)
            if not r then return end

            if toolLabel and toolLabel.Visible and toolLabel.Parent then
                local tool = c:FindFirstChildOfClass("Tool")
                toolLabel.Text = tool and ("[ " .. tool.Name .. " ]") or ""
            end

            if healthLabel and healthLabel.Visible and healthLabel.Parent then
                local humanoid = c:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local health = math.floor(humanoid.Health)
                    healthLabel.Text = health .. " HP"
                    healthLabel.TextColor3 = self.Utils:GetHealthColor(humanoid.Health / humanoid.MaxHealth)
                end
            end

            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = self.Utils:GetPlayerRoot(myChar)
                if myRoot then
                    local dist = (myRoot.Position - r.Position).Magnitude
                    local maxDist = maxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = self.Utils:GetDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        if self.Utils then self.Utils:AddConnection(connection) end
    end

    local charAddedConn = player.CharacterAdded:Connect(function()
        if self.Options.player.ESP then
            task.wait(1)
            self:RemovePlayerESP(player)
            self:CreatePlayerESP(player, maxDistance)
        end
    end)
    espTable.CharAddedConn = charAddedConn
    if self.Utils then self.Utils:AddConnection(charAddedConn) end

    self.Instances.player[player] = espTable
end

function ESP:RefreshPlayerESP(maxDistance)
    for player, _ in pairs(self.Instances.player) do
        self:RemovePlayerESP(player)
    end
    if not self.Options.player.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                self:CreatePlayerESP(player, maxDistance)
            else
                local conn = player.CharacterAdded:Connect(function()
                    conn:Disconnect()
                    if self.Options.player.ESP then
                        task.wait(1)
                        self:CreatePlayerESP(player, maxDistance)
                    end
                end)
                if self.Utils then self.Utils:AddConnection(conn) end
            end
        end
    end
end

-- ============================================
-- STRUCTURE ESP FUNCTIONS
-- ============================================
function ESP:RemoveStructureESP(structure)
    local esp = self.Instances.structure[structure]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.Instances.structure[structure] = nil
    end
end

function ESP:CreateStructureESP(structure, structureNames, maxDistance)
    if not structure:IsA("Model") then return end
    if self.Instances.structure[structure] then return end

    local mainPart = structure.PrimaryPart or self.Utils:GetItemMainPart(structure)
    if not mainPart then return end

    local espTable = {}
    local opts = self.Options.structure

    if opts.Chams then
        local highlight = self.Utils:CreateHighlight(structure, Color3.fromRGB(0, 200, 150), 0.3, Color3.fromRGB(100, 255, 200), 0.7)
        espTable.Highlight = highlight
    end

    if opts.Name or opts.Distance then
        local billboard = self.Utils:CreateBillboard(mainPart, UDim2.new(0, 250, 0, 50), Vector3.new(0, 3, 0))
        billboard.Parent = structure

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[STRUCTURE] " .. structure.Name
        nameLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Visible = opts.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = opts.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not structure or not structure.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = self.Utils:GetPlayerRoot(myChar)
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    local maxDist = maxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = self.Utils:GetDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        if self.Utils then self.Utils:AddConnection(connection) end
    end

    self.Instances.structure[structure] = espTable
end

function ESP:RefreshStructureESP(structureNames, maxDistance)
    for structure, _ in pairs(self.Instances.structure) do
        self:RemoveStructureESP(structure)
    end
    if not self.Options.structure.ESP then return end
    local folders = self.Utils:DiscoverFolders()
    if not folders.structuresFolder then return end
    for _, child in ipairs(folders.structuresFolder:GetChildren()) do
        local found = false
        for _, name in ipairs(structureNames) do
            if child.Name == name then found = true break end
        end
        if found then
            self:CreateStructureESP(child, structureNames, maxDistance)
        end
    end
end

-- ============================================
-- ITEM ESP FUNCTIONS (NEW - SEPERTI SINGLE FILE)
-- ============================================
function ESP:RemoveItemESP(category, item)
    local instances = self.ItemInstances[category]
    if not instances then return end
    
    local esp = instances[item]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        instances[item] = nil
    end
end

function ESP:CreateItemESP(category, item, maxDistance)
    local itemData = self.ItemCategories[category]
    if not itemData then return end
    
    if not item:IsA("Model") then return end
    
    local instances = self.ItemInstances[category]
    if instances[item] then return end

    local mainPart = self.Utils:GetItemMainPart(item)
    if not mainPart then return end

    local opts = self.ItemOptions[category]
    local espTable = {}

    if opts.Chams then
        local highlight = self.Utils:CreateHighlight(item, itemData.color, 0.4, Color3.fromRGB(255, 255, 255), 0.8)
        espTable.Highlight = highlight
    end

    if opts.Name or opts.Distance then
        local billboard = self.Utils:CreateBillboard(mainPart, UDim2.new(0, 220, 0, 50), Vector3.new(0, 2, 0))
        billboard.Parent = item

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[" .. category .. "] " .. item.Name
        nameLabel.TextColor3 = itemData.textColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = opts.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        distLabel.Visible = opts.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not item or not item.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = self.Utils:GetPlayerRoot(myChar)
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = self.Utils:GetDistanceColor(dist)
                    local maxDist = maxDistance or 99999
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then
                        billboard.Enabled = visible
                    end
                    if espTable.Highlight then
                        espTable.Highlight.Enabled = visible
                    end
                end
            end
        end)
        espTable.DistanceConnection = connection
        if self.Utils then self.Utils:AddConnection(connection) end
    end

    instances[item] = espTable
end

function ESP:RefreshItemESP(category, maxDistance)
    local instances = self.ItemInstances[category]
    if not instances then return end
    
    -- Remove all existing
    for item, _ in pairs(instances) do
        self:RemoveItemESP(category, item)
    end
    
    -- If ESP disabled, just return
    if not self.ItemOptions[category].ESP then return end
    
    -- Find all items in DroppedItems folder
    local folders = self.Utils:DiscoverFolders()
    if not folders.droppedItemsFolder then return end
    
    local itemData = self.ItemCategories[category]
    if not itemData then return end
    
    -- Create item lookup for this category
    local itemLookup = {}
    for _, itemName in ipairs(itemData.items) do
        itemLookup[itemName] = true
    end
    
    for _, child in ipairs(folders.droppedItemsFolder:GetChildren()) do
        if itemLookup[child.Name] then
            self:CreateItemESP(category, child, maxDistance)
        end
    end
end

function ESP:RefreshAllItemESP(maxDistance)
    for category, _ in pairs(self.ItemCategories) do
        self:RefreshItemESP(category, maxDistance)
    end
end

function ESP:SetItemCategoryESP(category, enabled)
    if not self.ItemOptions[category] then return end
    self.ItemOptions[category].ESP = enabled
    local maxDistance = self.Config:GetOptions().ESPMaxDistance
    self:RefreshItemESP(category, maxDistance)
end

function ESP:SetAllItemChams(enabled)
    for category, _ in pairs(self.ItemCategories) do
        self.ItemOptions[category].Chams = enabled
        if self.ItemOptions[category].ESP then
            local maxDistance = self.Config:GetOptions().ESPMaxDistance
            self:RefreshItemESP(category, maxDistance)
        end
    end
end

function ESP:SetupItemListeners()
    local folders = self.Utils:DiscoverFolders()
    if not folders.droppedItemsFolder then return end
    
    -- Child added listener
    local addedConn = folders.droppedItemsFolder.ChildAdded:Connect(function(child)
        for category, data in pairs(self.ItemCategories) do
            if self.ItemOptions[category].ESP then
                local found = false
                for _, itemName in ipairs(data.items) do
                    if child.Name == itemName then
                        found = true
                        break
                    end
                end
                if found then
                    local maxDistance = self.Config:GetOptions().ESPMaxDistance
                    self:CreateItemESP(category, child, maxDistance)
                end
            end
        end
    end)
    if self.Utils then self.Utils:AddConnection(addedConn) end
    
    -- Child removed listener
    local removedConn = folders.droppedItemsFolder.ChildRemoved:Connect(function(child)
        for category, data in pairs(self.ItemCategories) do
            local found = false
            for _, itemName in ipairs(data.items) do
                if child.Name == itemName then
                    found = true
                    break
                end
            end
            if found then
                self:RemoveItemESP(category, child)
            end
        end
    end)
    if self.Utils then self.Utils:AddConnection(removedConn) end
end

-- ============================================
-- SETTER METHODS
-- ============================================
function ESP:SetMobOptions(opts)
    self.Options.mob = opts
    return self
end

function ESP:SetPlayerOptions(opts)
    self.Options.player = opts
    return self
end

function ESP:SetStructureOptions(opts)
    self.Options.structure = opts
    return self
end

function ESP:RefreshAll()
    local config = self.Config
    local utils = self.Utils
    if not utils then return end
    
    local maxDistance = config:GetOptions().ESPMaxDistance
    local mobNames = config:GetMobNames()
    local structureNames = config:GetStructureNames()
    
    self:RefreshMobESP(mobNames, maxDistance)
    self:RefreshPlayerESP(maxDistance)
    self:RefreshStructureESP(structureNames, maxDistance)
    self:RefreshAllItemESP(maxDistance)
end

-- ============================================
-- INIT
-- ============================================
function ESP:Init(deps)
    self.Config = deps.Config
    self.Utils = deps.Utils
    self.Network = deps.Network
    self.Notifications = deps.Notifications
    
    -- Initialize ItemOptions from config if available
    if self.Config then
        for category, _ in pairs(self.ItemCategories) do
            if not self.ItemOptions[category] then
                self.ItemOptions[category] = { ESP = false, Chams = false, Name = false, Distance = false }
            end
        end
    end
    
    -- Setup item listeners
    task.spawn(function()
        task.wait(2)
        self:SetupItemListeners()
    end)
    
    return self
end

return ESP
