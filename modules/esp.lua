-- =======================================================
-- PINATHUB - ESP MODULE (UPDATED - SPYMM STRUCTURE)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- ============================================
-- ESP CONFIGURATION (Like SPYMM)
-- ============================================
local espConfig = {
    textSize = 10,
    fillTransparency = 0.4,
    outlineTransparency = 0.0,
    maxDistance = 500
}

-- ============================================
-- STATE VARIABLES
-- ============================================
ESP.Connections = {}
ESP.MobESPInstances = {}
ESP.PlayerESPInstances = {}
ESP.StructureESPInstances = {}
ESP.CrateESPInstances = {}
ESP.Systems = {}

ESP.Options = {
    ESPMaxDistance = 500
}

ESP.MobOptions = { ESP = false, Chams = false, Name = false, Distance = false }
ESP.PlayerESPVars = { ESP = false, Chams = false, Name = false, Distance = false, Health = false }
ESP.StructureESPVars = { ESP = false, Chams = false, Name = false, Distance = false }
ESP.CrateOptions = {
    ESP = false,
    Chams = false,
    Name = false,
    Distance = false,
    MaxDistance = 500,
    ChamsColor = Color3.fromRGB(255, 200, 50),
    OutlineColor = Color3.fromRGB(255, 255, 255)
}

-- Mob names (works with both "Characters" and "Zombies_Local" folders)
-- NOTE: This is kept for backward compatibility but Mob ESP now detects ALL non-player models
ESP.MobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

ESP.StructureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower"
}

-- ============================================
-- ITEM CATEGORIES & COLORS
-- ============================================
ESP.EspDefinitions = {
    {
        key = "Gun",
        displayName = "Gun ESP",
        items = {
            "AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"
        },
        colors = { fill = Color3.fromRGB(255, 30, 30), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 120, 120) },
    },
    {
        key = "Melee",
        displayName = "Melee ESP",
        items = {
            "Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"
        },
        colors = { fill = Color3.fromRGB(255, 140, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 200, 100) },
    },
    {
        key = "Medical",
        displayName = "Medical ESP",
        items = {
            "Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"
        },
        colors = { fill = Color3.fromRGB(0, 255, 80), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(150, 255, 150) },
    },
    {
        key = "Armor",
        displayName = "Armor ESP",
        items = {
            "Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"
        },
        colors = { fill = Color3.fromRGB(0, 100, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(160, 200, 255) },
    },
    {
        key = "Food",
        displayName = "Food ESP",
        items = {
            "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"
        },
        colors = { fill = Color3.fromRGB(190, 255, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(210, 255, 150) },
    },
    {
        key = "Resource",
        displayName = "Resources ESP",
        items = {
            "AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart"
        },
        colors = { fill = Color3.fromRGB(0, 220, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(180, 240, 255) },
    },
    {
        key = "Fuel",
        displayName = "Fuel ESP",
        items = { "Nuclear Fuel", "Refined Fuel", "Fuel" },
        colors = { fill = Color3.fromRGB(255, 220, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 240, 160) },
    },
    {
        key = "Ability",
        displayName = "Abilities ESP",
        items = {
            "Airstrike", "Attack Order", "Call of the Dead",
            "Summon Brute", "Summon Zombies", "Taunt",
            "The Future", "The Past", "The Present"
        },
        colors = { fill = Color3.fromRGB(180, 0, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(220, 150, 255) },
    },
}

-- Build ESP systems
for _, def in ipairs(ESP.EspDefinitions) do
    ESP.Systems[def.key] = {
        key = def.key,
        displayName = def.displayName,
        colors = def.colors,
        items = def.items,
        itemList = {},
        vars = { ESP = false, Chams = false, Name = false, Distance = false },
        instances = {},
        listenersSetup = false,
    }
    for _, name in ipairs(def.items) do
        ESP.Systems[def.key].itemList[name] = true
    end
end

-- Folder references
ESP.CharactersFolder = nil
ESP.DroppedItemsFolder = nil
ESP.StructuresFolder = nil

-- ============================================
-- FIX 1: IMPROVED getItemMainPart
-- Supports: Model, Tool, BasePart, MeshPart, UnionOperation, nested structures
-- ============================================
local function getItemMainPart(item)
    -- If item is itself a BasePart
    if item:IsA("BasePart") then
        return item
    end
    
    -- Check PrimaryPart (fastest)
    if item.PrimaryPart and item.PrimaryPart:IsA("BasePart") then
        return item.PrimaryPart
    end
    
    -- Recursively search for first BasePart in descendants
    local function findBasePart(instance)
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            end
            local found = findBasePart(child)
            if found then return found end
        end
        return nil
    end
    
    return findBasePart(item)
end

-- ============================================
-- FIX 2: FLEXIBLE ITEM NAME MATCHER
-- Supports: Battery(Clone), Scrap_01, Fuel (1), Watch_01, etc.
-- ============================================
local function matchesItemName(itemName, targetName)
    -- Exact match (fastest)
    if itemName == targetName then
        return true
    end
    
    -- Normalize function removes suffixes like (Clone), _01, (1), etc.
    local function normalize(name)
        local normalized = name
        -- Remove (Clone), (1), (2), (3) etc.
        normalized = normalized:gsub("%s*%([^)]+%)", "")
        -- Remove _01, _02, _03, _1, _2 etc.
        normalized = normalized:gsub("_%d+$", "")
        normalized = normalized:gsub("_%d+", "")
        -- Remove trailing numbers with space (e.g., "Fuel 1" -> "Fuel")
        normalized = normalized:gsub("%s+%d+$", "")
        -- Remove common suffixes
        normalized = normalized:gsub("Drop$", "")
        normalized = normalized:gsub("Dropped$", "")
        normalized = normalized:gsub("Clone$", "")
        -- Trim whitespace
        normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")
        return normalized:lower()
    end
    
    local normalizedItem = normalize(itemName)
    local normalizedTarget = normalize(targetName)
    
    -- Direct normalized match
    if normalizedItem == normalizedTarget then
        return true
    end
    
    -- Check if item contains target name as substring (e.g., "Large Battery" contains "Battery")
    if normalizedItem:find(normalizedTarget, 1, true) then
        return true
    end
    
    -- Check if target contains item name (e.g., "Battery" in "BatteryPack")
    if normalizedTarget:find(normalizedItem, 1, true) then
        return true
    end
    
    return false
end

-- Helper to check if an item belongs to a category using flexible matching
local function itemMatchesCategory(item, sys)
    local itemName = item.Name
    for targetName, _ in pairs(sys.itemList) do
        if matchesItemName(itemName, targetName) then
            return true
        end
    end
    return false
end

-- ============================================
-- FIX 3: RECURSIVE ITEM SCANNER
-- Supports items inside nested folders
-- ============================================
local function scanItemsRecursive(container, sys, callback, depth)
    depth = depth or 0
    if depth > 3 then return end  -- Limit recursion depth to prevent performance issues
    
    for _, child in ipairs(container:GetChildren()) do
        -- Check if this item matches our category
        if itemMatchesCategory(child, sys) then
            callback(child)
        end
        
        -- Recurse into containers (Folders and Models)
        if child:IsA("Folder") or child:IsA("Model") then
            scanItemsRecursive(child, sys, callback, depth + 1)
        end
    end
end

local function getDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

local function getHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

local function discoverFolders()
    ESP.CharactersFolder = Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("Zombies_Local")
    ESP.DroppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    ESP.StructuresFolder = Workspace:FindFirstChild("Structures")
        or Workspace:FindFirstChild("PlayerStructures")
        or Workspace:FindFirstChild("Buildings")
end
discoverFolders()

-- ============================================
-- APPLY CONFIG HELPERS (Like SPYMM)
-- ============================================
local function applyESPTextSize(size)
    espConfig.textSize = size
    local small = math.max(size - 2, 8)
    
    for _, sys in pairs(ESP.Systems) do
        for _, esp in pairs(sys.instances) do
            if esp.NameLabel then esp.NameLabel.TextSize = size end
            if esp.DistLabel then esp.DistLabel.TextSize = small end
        end
    end
    for _, esp in pairs(ESP.MobESPInstances) do
        if esp.NameLabel then esp.NameLabel.TextSize = size end
        if esp.DistLabel then esp.DistLabel.TextSize = small end
    end
    for _, esp in pairs(ESP.StructureESPInstances) do
        if esp.NameLabel then esp.NameLabel.TextSize = size end
        if esp.DistLabel then esp.DistLabel.TextSize = small end
    end
    for _, esp in pairs(ESP.PlayerESPInstances) do
        if esp.NameLabel then esp.NameLabel.TextSize = size end
        if esp.ToolLabel then esp.ToolLabel.TextSize = small end
        if esp.HealthLabel then esp.HealthLabel.TextSize = small end
        if esp.DistLabel then esp.DistLabel.TextSize = small end
    end
end

local function applyESPTransparency()
    local fillT = espConfig.fillTransparency
    local outlineT = espConfig.outlineTransparency
    
    local function updateHighlight(esp)
        if esp and esp.Highlight and esp.Highlight.Parent then
            esp.Highlight.FillTransparency = fillT
            esp.Highlight.OutlineTransparency = outlineT
        end
    end
    
    for _, sys in pairs(ESP.Systems) do
        for _, esp in pairs(sys.instances) do updateHighlight(esp) end
    end
    for _, esp in pairs(ESP.MobESPInstances) do updateHighlight(esp) end
    for _, esp in pairs(ESP.StructureESPInstances) do updateHighlight(esp) end
    for _, esp in pairs(ESP.PlayerESPInstances) do updateHighlight(esp) end
    for _, esp in pairs(ESP.CrateESPInstances) do updateHighlight(esp) end
end

-- ============================================
-- MOB ESP (Heartbeat based - Like SPYMM)
-- ============================================
function ESP:RemoveMobESP(char)
    local esp = self.MobESPInstances[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Connection then esp.Connection:Disconnect() end
        self.MobESPInstances[char] = nil
    end
end

function ESP:CreateMobESP(char)
    if not char:IsA("Model") then return end
    if self.MobESPInstances[char] then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end

    local espTable = { Root = root }
    local mobColors = { fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185) }

    if self.MobOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = mobColors.fill
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = mobColors.outline
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    local billboard, nameLabel, distLabel
    if self.MobOptions.Name or self.MobOptions.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "MobESP_Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = char.Name
        nameLabel.TextColor3 = mobColors.outline
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = self.MobOptions.Name
        nameLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = self.MobOptions.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    -- Heartbeat connection (like SPYMM)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent then
            connection:Disconnect()
            return
        end
        
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - root.Position).Magnitude
        local visible = dist <= self.Options.ESPMaxDistance
        
        -- Auto-restore highlight if destroyed
        if self.MobOptions.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = "MobESP_Highlight"
            h.Adornee = char
            h.FillColor = mobColors.fill
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = mobColors.outline
            h.OutlineTransparency = espConfig.outlineTransparency
            h.Enabled = visible
            h.Parent = char
            espTable.Highlight = h
        elseif espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = visible
        end
        
        if billboard and billboard.Parent then
            billboard.Enabled = visible
            if nameLabel and self.MobOptions.Name then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    nameLabel.Text = char.Name .. " [" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                end
            end
            if distLabel and self.MobOptions.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.Connection = connection
    table.insert(self.Connections, connection)

    self.MobESPInstances[char] = espTable
end

-- FIX 4: REMOVED HARDCODED MOB NAME FILTER
-- Now detects ALL non-player models in the mob folder
function ESP:RefreshMobESP()
    for char, _ in pairs(self.MobESPInstances) do
        self:RemoveMobESP(char)
    end
    if not self.MobOptions.ESP then return end
    if not self.CharactersFolder then return end
    
    -- Build player character set to exclude real players
    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerCharSet[p.Character] = true end
    end
    
    -- Detect EVERY non-player model (removed hardcoded name whitelist)
    for _, child in ipairs(self.CharactersFolder:GetChildren()) do
        if child:IsA("Model") and not playerCharSet[child] then
            self:CreateMobESP(child)
        end
    end
end

-- ============================================
-- PLAYER ESP (UNCHANGED)
-- ============================================
function ESP:RemovePlayerESP(player)
    local esp = self.PlayerESPInstances[player]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Connection then esp.Connection:Disconnect() end
        if esp.CharAddedConn then esp.CharAddedConn:Disconnect() end
        self.PlayerESPInstances[player] = nil
    end
end

function ESP:CreatePlayerESP(player)
    if player == LocalPlayer then return end
    if self.PlayerESPInstances[player] then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espTable = {}

    if self.PlayerESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    local billboard, nameLabel, toolLabel, healthLabel, distLabel
    if self.PlayerESPVars.Name or self.PlayerESPVars.Distance or self.PlayerESPVars.Health then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 250, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = self.PlayerESPVars.Name
        nameLabel.Parent = frame

        toolLabel = Instance.new("TextLabel")
        toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
        toolLabel.Position = UDim2.new(0, 0, 0.3, 0)
        toolLabel.BackgroundTransparency = 1
        toolLabel.Text = ""
        toolLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
        toolLabel.TextStrokeTransparency = 0.2
        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        toolLabel.Font = Enum.Font.Gotham
        toolLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        toolLabel.Visible = self.PlayerESPVars.Name
        toolLabel.Parent = frame

        healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.55, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        healthLabel.TextStrokeTransparency = 0.2
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        healthLabel.Visible = self.PlayerESPVars.Health
        healthLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.2, 0)
        distLabel.Position = UDim2.new(0, 0, 0.78, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = self.PlayerESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.ToolLabel = toolLabel
        espTable.HealthLabel = healthLabel
        espTable.DistLabel = distLabel
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player or not player.Parent then
            connection:Disconnect()
            return
        end
        local c = player.Character
        if not c or not c.Parent then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local dist = (myRoot.Position - r.Position).Magnitude
        local visible = dist <= self.Options.ESPMaxDistance

        if self.PlayerESPVars.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = "PlayerESP_Highlight"
            h.Adornee = c
            h.FillColor = Color3.fromRGB(0, 100, 255)
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = Color3.fromRGB(100, 180, 255)
            h.OutlineTransparency = espConfig.outlineTransparency
            h.Enabled = visible
            h.Parent = c
            espTable.Highlight = h
        elseif espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = visible
        end

        if billboard and billboard.Parent then
            billboard.Enabled = visible
            if toolLabel and self.PlayerESPVars.Name then
                local tool = c:FindFirstChildOfClass("Tool")
                toolLabel.Text = tool and ("[ " .. tool.Name .. " ]") or ""
            end
            if healthLabel and self.PlayerESPVars.Health then
                local humanoid = c:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    healthLabel.Text = math.floor(humanoid.Health) .. " HP"
                    healthLabel.TextColor3 = getHealthColor(humanoid.Health / humanoid.MaxHealth)
                end
            end
            if distLabel and self.PlayerESPVars.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.Connection = connection
    table.insert(self.Connections, connection)

    local charAddedConn = player.CharacterAdded:Connect(function()
        if self.PlayerESPVars.ESP then
            task.wait(1)
            self:RemovePlayerESP(player)
            self:CreatePlayerESP(player)
        end
    end)
    espTable.CharAddedConn = charAddedConn
    table.insert(self.Connections, charAddedConn)

    self.PlayerESPInstances[player] = espTable
end

function ESP:RefreshPlayerESP()
    for player, _ in pairs(self.PlayerESPInstances) do
        self:RemovePlayerESP(player)
    end
    if not self.PlayerESPVars.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                self:CreatePlayerESP(player)
            else
                local conn = player.CharacterAdded:Connect(function()
                    conn:Disconnect()
                    if self.PlayerESPVars.ESP then
                        task.wait(1)
                        self:CreatePlayerESP(player)
                    end
                end)
                table.insert(self.Connections, conn)
            end
        end
    end
end

-- ============================================
-- STRUCTURE ESP (UNCHANGED)
-- ============================================
function ESP:RemoveStructureESP(structure)
    local esp = self.StructureESPInstances[structure]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Connection then esp.Connection:Disconnect() end
        self.StructureESPInstances[structure] = nil
    end
end

function ESP:CreateStructureESP(structure)
    if not structure:IsA("Model") then return end
    if self.StructureESPInstances[structure] then return end

    local mainPart = structure.PrimaryPart or getItemMainPart(structure)
    if not mainPart then return end

    local espTable = { MainPart = mainPart }

    if self.StructureESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "StructESP_Highlight"
        highlight.Adornee = structure
        highlight.FillColor = Color3.fromRGB(0, 200, 150)
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = Color3.fromRGB(100, 255, 200)
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = structure
        espTable.Highlight = highlight
    end

    local billboard, nameLabel, distLabel
    if self.StructureESPVars.Name or self.StructureESPVars.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "StructESP_Info"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = structure

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[STRUCTURE] " .. structure.Name
        nameLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = self.StructureESPVars.Name
        nameLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = self.StructureESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not structure or not structure.Parent then
            connection:Disconnect()
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - mainPart.Position).Magnitude
        local visible = dist <= self.Options.ESPMaxDistance

        if self.StructureESPVars.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = "StructESP_Highlight"
            h.Adornee = structure
            h.FillColor = Color3.fromRGB(0, 200, 150)
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = Color3.fromRGB(100, 255, 200)
            h.OutlineTransparency = espConfig.outlineTransparency
            h.Enabled = visible
            h.Parent = structure
            espTable.Highlight = h
        elseif espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = visible
        end

        if billboard and billboard.Parent then
            billboard.Enabled = visible
            if distLabel and self.StructureESPVars.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.Connection = connection
    table.insert(self.Connections, connection)

    self.StructureESPInstances[structure] = espTable
end

function ESP:RefreshStructureESP()
    for structure, _ in pairs(self.StructureESPInstances) do
        self:RemoveStructureESP(structure)
    end
    if not self.StructureESPVars.ESP then return end
    if not self.StructuresFolder then return end
    for _, child in ipairs(self.StructuresFolder:GetChildren()) do
        if table.find(self.StructureNames, child.Name) then
            self:CreateStructureESP(child)
        end
    end
end

-- ============================================
-- FIX 5: ITEM ESP - UPDATED WITH:
-- - Support for BasePart, MeshPart, UnionOperation, Tool, Folder items
-- - Recursive scanning for nested items
-- - Flexible name matching
-- ============================================
function ESP:CreateCategoryESP(sys, item)
    -- FIX: Accept multiple instance types, not just Models
    local isValid = false
    local targetInstance = item
    
    if item:IsA("Model") then
        isValid = true
    elseif item:IsA("BasePart") or item:IsA("MeshPart") or item:IsA("UnionOperation") then
        isValid = true
        -- For single parts, we'll use the part itself
        targetInstance = item
    elseif item:IsA("Tool") then
        isValid = true
    elseif item:IsA("Folder") then
        -- Check if folder contains any BasePart (likely an item container)
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") then
                isValid = true
                targetInstance = item
                break
            end
        end
    end
    
    if not isValid then return end
    if sys.instances[targetInstance] then return end
    
    local mainPart = getItemMainPart(targetInstance)
    if not mainPart then return end

    local espTable = { MainPart = mainPart, TargetInstance = targetInstance }

    if sys.vars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = sys.key .. "_ESP"
        highlight.Adornee = targetInstance
        highlight.FillColor = sys.colors.fill
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = sys.colors.outline
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = targetInstance
        espTable.Highlight = highlight
    end

    local billboard, nameLabel, distLabel
    if sys.vars.Name or sys.vars.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = sys.key .. "_Billboard"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = targetInstance

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        -- Clean up display name (remove suffixes like (Clone))
        local displayName = targetInstance.Name:gsub("%s*%([^)]+%)", ""):gsub("_%d+$", "")
        
        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[" .. sys.key .. "] " .. displayName
        nameLabel.TextColor3 = sys.colors.text
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = sys.vars.Name
        nameLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = sys.vars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not targetInstance or not targetInstance.Parent then
            connection:Disconnect()
            return
        end
        
        -- Update mainPart reference in case it changed
        local currentMainPart = getItemMainPart(targetInstance)
        if currentMainPart then
            espTable.MainPart = currentMainPart
            if billboard and billboard.Parent then
                billboard.Adornee = currentMainPart
            end
        end
        
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot or not espTable.MainPart then return end
        
        local dist = (myRoot.Position - espTable.MainPart.Position).Magnitude
        local visible = dist <= self.Options.ESPMaxDistance

        if sys.vars.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = sys.key .. "_ESP"
            h.Adornee = targetInstance
            h.FillColor = sys.colors.fill
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = sys.colors.outline
            h.OutlineTransparency = espConfig.outlineTransparency
            h.Enabled = visible
            h.Parent = targetInstance
            espTable.Highlight = h
        elseif espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = visible
        end

        if billboard and billboard.Parent then
            billboard.Enabled = visible
            if distLabel and sys.vars.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.Connection = connection
    table.insert(self.Connections, connection)

    sys.instances[targetInstance] = espTable
end

function ESP:RemoveCategoryESP(sys, item)
    local esp = sys.instances[item]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Connection then esp.Connection:Disconnect() end
        sys.instances[item] = nil
    end
end

-- FIX: Updated to use recursive scanning and flexible matching
function ESP:RefreshCategoryESP(sys)
    for item, _ in pairs(sys.instances) do
        self:RemoveCategoryESP(sys, item)
    end
    if not sys.vars.ESP then return end
    if not self.DroppedItemsFolder then return end
    
    -- Use recursive scanner to find items in nested folders
    scanItemsRecursive(self.DroppedItemsFolder, sys, function(item)
        task.wait(0.02)
        self:CreateCategoryESP(sys, item)
    end)
end

-- FIX: Updated listener to use flexible matching and recursive scanning
function ESP:SetupCategoryListeners(sys)
    if not self.DroppedItemsFolder or sys.listenersSetup then return end
    sys.listenersSetup = true
    
    local addedConn = self.DroppedItemsFolder.ChildAdded:Connect(function(child)
        if not sys.vars.ESP then return end
        
        -- Check if the added child matches this category
        if itemMatchesCategory(child, sys) then
            task.wait(0.1)
            self:CreateCategoryESP(sys, child)
        end
        
        -- Also check children of the added child (for nested items)
        task.wait(0.05)
        scanItemsRecursive(child, sys, function(nestedItem)
            self:CreateCategoryESP(sys, nestedItem)
        end)
    end)
    table.insert(self.Connections, addedConn)
    
    local removedConn = self.DroppedItemsFolder.ChildRemoved:Connect(function(child)
        self:RemoveCategoryESP(sys, child)
        -- Also clean up any nested instances
        for item, _ in pairs(sys.instances) do
            if item:IsDescendantOf(child) then
                self:RemoveCategoryESP(sys, item)
            end
        end
    end)
    table.insert(self.Connections, removedConn)
end

-- ============================================
-- CRATES ESP (UNCHANGED)
-- ============================================
function ESP:FindAllCrates()
    local crates = {}
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return crates end
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then return crates end
    for _, child in ipairs(cratesFolder:GetChildren()) do
        if child.Name == "Default" and child:IsA("Model") then
            table.insert(crates, child)
        end
    end
    return crates
end

function ESP:GetCrateMainPart(crate)
    if crate.PrimaryPart then return crate.PrimaryPart end
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

function ESP:RemoveCrateESP(crate)
    local esp = self.CrateESPInstances[crate]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Connection then esp.Connection:Disconnect() end
        self.CrateESPInstances[crate] = nil
    end
end

function ESP:CreateCrateESP(crate)
    if not crate:IsA("Model") then return end
    if self.CrateESPInstances[crate] then return end
    
    local mainPart = self:GetCrateMainPart(crate)
    if not mainPart then return end
    
    local espTable = { MainPart = mainPart }
    
    if self.CrateOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CrateESP_Highlight"
        highlight.Adornee = crate
        highlight.FillColor = self.CrateOptions.ChamsColor
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = self.CrateOptions.OutlineColor
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = crate
        espTable.Highlight = highlight
    end
    
    local billboard, nameLabel, distLabel
    if self.CrateOptions.Name or self.CrateOptions.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "CrateESP_Info"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = crate
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard
        
        nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📦 CRATE"
        nameLabel.TextColor3 = self.CrateOptions.ChamsColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = self.CrateOptions.Name
        nameLabel.Parent = frame
        
        distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = self.CrateOptions.Distance
        distLabel.Parent = frame
        
        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not crate or not crate.Parent then
            connection:Disconnect()
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - mainPart.Position).Magnitude
        local visible = dist <= self.CrateOptions.MaxDistance

        if self.CrateOptions.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = "CrateESP_Highlight"
            h.Adornee = crate
            h.FillColor = self.CrateOptions.ChamsColor
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = self.CrateOptions.OutlineColor
            h.OutlineTransparency = espConfig.outlineTransparency
            h.Enabled = visible
            h.Parent = crate
            espTable.Highlight = h
        elseif espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = visible
        end

        if billboard and billboard.Parent then
            billboard.Enabled = visible
            if distLabel and self.CrateOptions.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.Connection = connection
    table.insert(self.Connections, connection)
    
    self.CrateESPInstances[crate] = espTable
end

function ESP:RefreshCrateESP()
    for crate, _ in pairs(self.CrateESPInstances) do
        self:RemoveCrateESP(crate)
    end
    if not self.CrateOptions.ESP then return end
    local allCrates = self:FindAllCrates()
    for _, crate in ipairs(allCrates) do
        self:CreateCrateESP(crate)
    end
end

function ESP:SetupCrateListeners()
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then return end
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then return end
    local childAddedConn = cratesFolder.ChildAdded:Connect(function(child)
        if child.Name == "Default" and child:IsA("Model") then
            if self.CrateOptions.ESP then
                task.wait(0.1)
                self:CreateCrateESP(child)
            end
        end
    end)
    table.insert(self.Connections, childAddedConn)
    local childRemovedConn = cratesFolder.ChildRemoved:Connect(function(child)
        if child.Name == "Default" and child:IsA("Model") then
            self:RemoveCrateESP(child)
        end
    end)
    table.insert(self.Connections, childRemovedConn)
end

-- ============================================
-- LISTENERS (UPDATED FOR FLEXIBLE MOB DETECTION)
-- ============================================
function ESP:SetupMobListeners()
    if not self.CharactersFolder or self.MobListenersSetup then return end
    self.MobListenersSetup = true
    
    local childAddedConn = self.CharactersFolder.ChildAdded:Connect(function(child)
        if self.MobOptions.ESP and child:IsA("Model") then
            -- Exclude player characters
            local isPlayer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character == child then
                    isPlayer = true
                    break
                end
            end
            if not isPlayer then
                task.wait(0.2)
                self:CreateMobESP(child)
            end
        end
    end)
    table.insert(self.Connections, childAddedConn)

    local childRemovedConn = self.CharactersFolder.ChildRemoved:Connect(function(child)
        self:RemoveMobESP(child)
    end)
    table.insert(self.Connections, childRemovedConn)
end

function ESP:SetupStructureListeners()
    if not self.StructuresFolder or self.StructureListenersSetup then return end
    self.StructureListenersSetup = true
    
    local childAddedConn = self.StructuresFolder.ChildAdded:Connect(function(child)
        if self.StructureESPVars.ESP and table.find(self.StructureNames, child.Name) then
            task.wait(0.2)
            self:CreateStructureESP(child)
        end
    end)
    table.insert(self.Connections, childAddedConn)

    local childRemovedConn = self.StructuresFolder.ChildRemoved:Connect(function(child)
        self:RemoveStructureESP(child)
    end)
    table.insert(self.Connections, childRemovedConn)
end

-- ============================================
-- REFRESH ALL
-- ============================================
function ESP:RefreshAll()
    self:RefreshMobESP()
    self:RefreshPlayerESP()
    self:RefreshStructureESP()
    self:RefreshCrateESP()
    for _, sys in pairs(self.Systems) do
        self:RefreshCategoryESP(sys)
    end
end

-- ============================================
-- SETTER METHODS
-- ============================================
function ESP:SetMobOptions(opts)
    self.MobOptions = opts
    self:RefreshMobESP()
    return self
end

function ESP:SetPlayerOptions(opts)
    self.PlayerESPVars = opts
    self:RefreshPlayerESP()
    return self
end

function ESP:SetStructureOptions(opts)
    self.StructureESPVars = opts
    self:RefreshStructureESP()
    return self
end

function ESP:SetCrateOptions(opts)
    self.CrateOptions = opts
    self:RefreshCrateESP()
    return self
end

function ESP:SetAllItemChams(value)
    for _, sys in pairs(self.Systems) do
        sys.vars.Chams = value
        self:RefreshCategoryESP(sys)
    end
end

function ESP:SetAllItemNames(value)
    for _, sys in pairs(self.Systems) do
        sys.vars.Name = value
        self:RefreshCategoryESP(sys)
    end
end

function ESP:SetAllItemDistances(value)
    for _, sys in pairs(self.Systems) do
        sys.vars.Distance = value
        self:RefreshCategoryESP(sys)
    end
end

function ESP:SetItemCategoryESP(category, enabled)
    if self.Systems[category] then
        self.Systems[category].vars.ESP = enabled
        if enabled then
            self.Systems[category].vars.Chams = enabled
            self.Systems[category].vars.Name = enabled
            self.Systems[category].vars.Distance = enabled
        end
        self:RefreshCategoryESP(self.Systems[category])
    end
end

function ESP:SetItemCategoryChams(category, enabled)
    if self.Systems[category] then
        self.Systems[category].vars.Chams = enabled
        self:RefreshCategoryESP(self.Systems[category])
    end
end

function ESP:SetItemCategoryName(category, enabled)
    if self.Systems[category] then
        self.Systems[category].vars.Name = enabled
        self:RefreshCategoryESP(self.Systems[category])
    end
end

function ESP:SetItemCategoryDistance(category, enabled)
    if self.Systems[category] then
        self.Systems[category].vars.Distance = enabled
        self:RefreshCategoryESP(self.Systems[category])
    end
end

function ESP:SetESPMaxDistance(distance)
    self.Options.ESPMaxDistance = distance
    self.CrateOptions.MaxDistance = distance
    self:RefreshAll()
end

function ESP:SetESPTextSize(size)
    espConfig.textSize = size
    applyESPTextSize(size)
end

function ESP:SetESPTransparency(fill, outline)
    espConfig.fillTransparency = fill / 100
    espConfig.outlineTransparency = outline / 100
    applyESPTransparency()
end

-- ============================================
-- INIT
-- ============================================
function ESP:Init(deps)
    self.Utils = deps and deps.utils
    self.Config = deps and deps.config
    self.Notifications = deps and deps.notifications
    
    discoverFolders()
    
    -- Setup category listeners
    for _, sys in pairs(self.Systems) do
        self:SetupCategoryListeners(sys)
    end
    
    self:SetupCrateListeners()
    
    -- Periodic folder refresh
    task.spawn(function()
        while true do
            task.wait(5)
            local prevChars = self.CharactersFolder
            local prevItems = self.DroppedItemsFolder
            local prevStructs = self.StructuresFolder
            discoverFolders()
            
            if self.CharactersFolder ~= prevChars and self.CharactersFolder then
                self:RefreshMobESP()
                self:SetupMobListeners()
            end
            if self.DroppedItemsFolder ~= prevItems and self.DroppedItemsFolder then
                for _, sys in pairs(self.Systems) do
                    self:RefreshCategoryESP(sys)
                end
            end
            if self.StructuresFolder ~= prevStructs and self.StructuresFolder then
                self:RefreshStructureESP()
                self:SetupStructureListeners()
            end
        end
    end)
    
    self:SetupMobListeners()
    self:SetupStructureListeners()
    
    print("[ESP] Initialized - " .. #self.EspDefinitions .. " item categories ready")
    return self
end

return ESP
