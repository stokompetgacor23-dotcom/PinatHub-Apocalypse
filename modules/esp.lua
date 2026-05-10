-- =======================================================
-- PINATHUB - ESP MODULE (COMPLETE WITH ITEM NAMES)
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
    item = {}
}

ESP.Options = {
    mob = { ESP = false, Chams = false, Name = false, Distance = false },
    player = { ESP = false, Chams = false, Name = false, Distance = false, Health = false },
    structure = { ESP = false, Chams = false, Name = false, Distance = false }
}

-- Item ESP state
ESP.ItemOptions = {}
ESP.ItemInstances = {}

-- ============================================
-- ITEM ESP DEFINITIONS (Sama seperti single file)
-- ============================================
local itemDefinitions = {
    Gun = {
        displayName = "Gun ESP",
        fillColor = Color3.fromRGB(255, 30, 30),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(255, 120, 120),
        items = {
            "AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"
        }
    },
    Melee = {
        displayName = "Melee ESP",
        fillColor = Color3.fromRGB(255, 140, 0),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(255, 200, 100),
        items = {
            "Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"
        }
    },
    Medical = {
        displayName = "Medical ESP",
        fillColor = Color3.fromRGB(0, 255, 80),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(150, 255, 150),
        items = {
            "Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"
        }
    },
    Armor = {
        displayName = "Armor ESP",
        fillColor = Color3.fromRGB(0, 100, 255),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(160, 200, 255),
        items = {
            "Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"
        }
    },
    Food = {
        displayName = "Food ESP",
        fillColor = Color3.fromRGB(190, 255, 0),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(210, 255, 150),
        items = {
            "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"
        }
    },
    Resource = {
        displayName = "Resources ESP",
        fillColor = Color3.fromRGB(0, 220, 255),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(180, 240, 255),
        items = {
            "AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart"
        }
    },
    Fuel = {
        displayName = "Fuel ESP",
        fillColor = Color3.fromRGB(255, 220, 0),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(255, 240, 160),
        items = { "Nuclear Fuel", "Refined Fuel", "Fuel" }
    },
    Ability = {
        displayName = "Abilities ESP",
        fillColor = Color3.fromRGB(180, 0, 255),
        outlineColor = Color3.fromRGB(255, 255, 255),
        textColor = Color3.fromRGB(220, 150, 255),
        items = {
            "Airstrike", "Attack Order", "Call of the Dead",
            "Summon Brute", "Summon Zombies", "Taunt",
            "The Future", "The Past", "The Present"
        }
    }
}

-- Initialize item options
for category, def in pairs(itemDefinitions) do
    ESP.ItemOptions[category] = { ESP = false, Chams = false, Name = true, Distance = true }
    ESP.ItemInstances[category] = {}
    
    -- Create item lookup
    def.itemLookup = {}
    for _, itemName in ipairs(def.items) do
        def.itemLookup[itemName] = true
    end
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getItemMainPart(item)
    if item.PrimaryPart then return item.PrimaryPart end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function getDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

-- ============================================
-- ITEM ESP FUNCTIONS (Dengan Nama Item)
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
    local def = itemDefinitions[category]
    if not def then return end
    
    if not item:IsA("Model") then return end
    
    local instances = self.ItemInstances[category]
    if instances[item] then return end

    local mainPart = getItemMainPart(item)
    if not mainPart then return end

    local opts = self.ItemOptions[category]
    local espTable = {}

    -- Chams (Highlight)
    if opts.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = category .. "ESP_Highlight"
        highlight.Adornee = item
        highlight.FillColor = def.fillColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = def.outlineColor
        highlight.OutlineTransparency = 0.8
        highlight.Parent = item
        espTable.Highlight = highlight
    end

    -- Name and Distance Billboard
    if opts.Name or opts.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = category .. "ESP_NameDistance"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = item

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        -- Name Label (Menampilkan [Gun] AK-47)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[" .. category .. "] " .. item.Name
        nameLabel.TextColor3 = def.textColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = opts.Name
        nameLabel.Parent = frame

        -- Distance Label
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

        -- Update distance every frame
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not item or not item.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= (maxDistance or 500)
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
    end

    instances[item] = espTable
end

function ESP:RefreshItemESP(category, maxDistance)
    local instances = self.ItemInstances[category]
    if not instances then return end
    
    -- Remove all existing ESP for this category
    for item, _ in pairs(instances) do
        self:RemoveItemESP(category, item)
    end
    
    -- If ESP disabled, just return
    if not self.ItemOptions[category].ESP then return end
    
    -- Find all items in DroppedItems folder
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then return end
    
    local def = itemDefinitions[category]
    if not def then return end
    
    -- Create ESP for matching items
    for _, child in ipairs(droppedItems:GetChildren()) do
        if def.itemLookup[child.Name] then
            self:CreateItemESP(category, child, maxDistance)
        end
    end
end

function ESP:RefreshAllItemESP(maxDistance)
    for category, _ in pairs(itemDefinitions) do
        self:RefreshItemESP(category, maxDistance)
    end
end

function ESP:SetItemCategoryESP(category, enabled)
    if not self.ItemOptions[category] then return end
    self.ItemOptions[category].ESP = enabled
    local maxDistance = self.Config:GetOptions().ESPMaxDistance or 500
    self:RefreshItemESP(category, maxDistance)
end

function ESP:SetAllItemChams(enabled)
    for category, _ in pairs(itemDefinitions) do
        self.ItemOptions[category].Chams = enabled
        if self.ItemOptions[category].ESP then
            local maxDistance = self.Config:GetOptions().ESPMaxDistance or 500
            self:RefreshItemESP(category, maxDistance)
        end
    end
end

function ESP:SetItemNameVisibility(category, enabled)
    if not self.ItemOptions[category] then return end
    self.ItemOptions[category].Name = enabled
    
    -- Update existing instances
    local instances = self.ItemInstances[category]
    if instances then
        for _, esp in pairs(instances) do
            if esp.NameLabel then
                esp.NameLabel.Visible = enabled
            end
        end
    end
end

function ESP:SetItemDistanceVisibility(category, enabled)
    if not self.ItemOptions[category] then return end
    self.ItemOptions[category].Distance = enabled
    
    -- Update existing instances
    local instances = self.ItemInstances[category]
    if instances then
        for _, esp in pairs(instances) do
            if esp.DistLabel then
                esp.DistLabel.Visible = enabled
            end
        end
    end
end

function ESP:SetupItemListeners()
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then return end
    
    -- Child added listener
    local addedConn = droppedItems.ChildAdded:Connect(function(child)
        for category, def in pairs(itemDefinitions) do
            if self.ItemOptions[category].ESP and def.itemLookup[child.Name] then
                local maxDistance = self.Config:GetOptions().ESPMaxDistance or 500
                self:CreateItemESP(category, child, maxDistance)
            end
        end
    end)
    
    -- Child removed listener
    local removedConn = droppedItems.ChildRemoved:Connect(function(child)
        for category, def in pairs(itemDefinitions) do
            if def.itemLookup[child.Name] then
                self:RemoveItemESP(category, child)
            end
        end
    end)
    
    if self.Utils then
        self.Utils:AddConnection(addedConn)
        self.Utils:AddConnection(removedConn)
    end
end

-- ============================================
-- SETTER METHODS (Untuk Mob, Player, Structure)
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
    -- This will be implemented later with full ESP
    print("[ESP] Refresh all called")
end

-- ============================================
-- INIT
-- ============================================
function ESP:Init(deps)
    self.Config = deps.config or deps.Config
    self.Utils = deps.utils or deps.Utils
    self.Network = deps.network or deps.Network
    self.Notifications = deps.notifications or deps.Notifications
    
    -- Setup item listeners after a short delay
    task.spawn(function()
        task.wait(2)
        self:SetupItemListeners()
    end)
    
    print("[ESP MODULE] Initialized with Item ESP")
    return self
end

return ESP
