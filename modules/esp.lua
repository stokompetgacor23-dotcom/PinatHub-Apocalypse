-- =======================================================
-- PINATHUB - ESP MODULE (SPYMM-COMPATIBLE VERSION)
-- Fully compatible with SPYMM v8.3 structure
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- ============================================
-- ESP CONFIGURATION (Identical to SPYMM)
-- ============================================
local espConfig = {
    textSize            = 10,
    fillTransparency    = 0.4,
    outlineTransparency = 0.0,
}

-- ============================================
-- FOLDER REFERENCES
-- ============================================
local charactersFolder = nil
local droppedItemsFolder = nil
local structuresFolder = nil

-- ============================================
-- STATE VARIABLES (SPYMM Style)
-- ============================================
ESP.Connections = {}
ESP.MobESPInstances = {}
ESP.PlayerESPInstances = {}
ESP.StructureESPInstances = {}
ESP.CrateESPInstances = {}

ESP.MobOptions = { ESP = false, Chams = true, Name = true, Distance = true }
ESP.PlayerESPVars = { ESP = false, Chams = true, Name = true, Distance = true, Health = true }
ESP.StructureESPVars = { ESP = false, Chams = true, Name = true, Distance = true }
ESP.CrateOptions = {
    ESP = false, Chams = true, Name = true, Distance = true,
    MaxDistance = 500,
    ChamsColor = Color3.fromRGB(255, 200, 50),
    OutlineColor = Color3.fromRGB(255, 255, 255)
}

-- ============================================
-- ITEM CATEGORIES & COLORS (SPYMM Colors)
-- ============================================
ESP.EspDefinitions = {
    {
        key = "Gun", displayName = "Gun ESP",
        items = {"AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"},
        colors = { fill = Color3.fromRGB(255, 30, 30), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 120, 120) },
    },
    {
        key = "Melee", displayName = "Melee ESP",
        items = {"Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat", "Power Hammer", "Scorchblade"},
        colors = { fill = Color3.fromRGB(255, 140, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 200, 100) },
    },
    {
        key = "Medical", displayName = "Medical ESP",
        items = {"Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"},
        colors = { fill = Color3.fromRGB(0, 255, 80), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(150, 255, 150) },
    },
    {
        key = "Armor", displayName = "Armor ESP",
        items = {"Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"},
        colors = { fill = Color3.fromRGB(0, 100, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(160, 200, 255) },
    },
    {
        key = "Ammo", displayName = "Ammo ESP",
        items = {"Ammo Box", "Long Ammo", "Medium Ammo", "Pistol Ammo", "Shells", "Ammo"},
        colors = { fill = Color3.fromRGB(255, 215, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 230, 100) },
    },
    {
        key = "Backpack", displayName = "Backpack ESP",
        items = {"Basic Backpack", "Good Backpack", "Great Backpack", "Military Backpack", "Backpack"},
        colors = { fill = Color3.fromRGB(0, 200, 200), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(100, 240, 240) },
    },
    {
        key = "Throwable", displayName = "Throwables ESP",
        items = {"Grenade", "Molotov", "Smoke Grenade", "Flashbang"},
        colors = { fill = Color3.fromRGB(255, 80, 20), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 140, 80) },
    },
    {
        key = "Food", displayName = "Food ESP",
        items = {"Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"},
        colors = { fill = Color3.fromRGB(190, 255, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(210, 255, 150) },
    },
    {
        key = "Resource", displayName = "Resources ESP",
        items = {"AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart", "Blood Gem", "Data Coin"},
        colors = { fill = Color3.fromRGB(0, 220, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(180, 240, 255) },
    },
    {
        key = "Fuel", displayName = "Fuel ESP",
        items = {"Nuclear Fuel", "Refined Fuel", "Fuel"},
        colors = { fill = Color3.fromRGB(255, 220, 0), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 240, 160) },
    },
    {
        key = "Ability", displayName = "Abilities ESP",
        items = {"Airstrike", "Attack Order", "Call of the Dead", "Summon Brute", "Summon Zombies", "Taunt", "The Future", "The Past", "The Present"},
        colors = { fill = Color3.fromRGB(180, 0, 255), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(220, 150, 255) },
    },
    {
        key = "Special", displayName = "Special / Keys ESP",
        items = {"Emerald", "Gas Mask", "Military Keycard", "Keycard", "Blueprint", "Suppressor", "Repair Hammer"},
        colors = { fill = Color3.fromRGB(0, 255, 180), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(150, 255, 220) },
    },
    {
        key = "Deployable", displayName = "Deployables ESP",
        items = {"Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
            "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
            "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower", "Barrel", "Scrap Pile"},
        colors = { fill = Color3.fromRGB(205, 133, 63), outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(240, 180, 130) },
    },
}

-- Build ESP systems (SPYMM pattern)
ESP.Systems = {}
for _, def in ipairs(ESP.EspDefinitions) do
    ESP.Systems[def.key] = {
        key = def.key, displayName = def.displayName, colors = def.colors,
        items = def.items, itemList = {},
        vars = { ESP = false, Chams = true, Name = true, Distance = true },
        instances = {}, listenersSetup = false,
    }
    for _, name in ipairs(def.items) do
        ESP.Systems[def.key].itemList[name] = true
    end
end

-- Structure names
ESP.StructureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower",
    "Barrel", "Scrap Pile", "Workbench", "Crafting Station", "Barricade"
}

-- ============================================
-- UTILITY FUNCTIONS (SPYMM Style)
-- ============================================
local function getItemMainPart(item)
    if not item then return nil end
    if item:IsA("BasePart") then return item end
    if item.PrimaryPart then return item.PrimaryPart end
    local handle = item:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return item:FindFirstChildWhichIsA("BasePart", true)
end

local function matchesItemName(itemName, targetName)
    if itemName == targetName then return true end
    local function normalize(name)
        local n = name:gsub("%s*%([^)]+%)", ""):gsub("_%d+$", ""):gsub("_%d+", ""):gsub("%s+%d+$", ""):gsub("Drop$", ""):gsub("Dropped$", ""):gsub("Clone$", "")
        return n:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    end
    local normItem = normalize(itemName)
    local normTarget = normalize(targetName)
    if normItem == normTarget then return true end
    if normItem:find(normTarget, 1, true) then return true end
    if normTarget:find(normItem, 1, true) then return true end
    return false
end

local function scanItemsRecursive(container, sys, callback, depth)
    depth = depth or 0
    if depth > 3 then return end
    for _, child in ipairs(container:GetChildren()) do
        local matched = false
        if matchesItemName(child.Name, sys.key) or sys.itemList[child.Name] then
            matched = true
        else
            for targetName in pairs(sys.itemList) do
                if matchesItemName(child.Name, targetName) then
                    matched = true
                    break
                end
            end
        end

        if matched then
            callback(child)
        elseif child:IsA("Folder") or child:IsA("Model") then
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
    charactersFolder = Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("Zombies_Local") or charactersFolder
    droppedItemsFolder = Workspace:FindFirstChild("DroppedItems") or droppedItemsFolder
    structuresFolder = Workspace:FindFirstChild("Structures") or Workspace:FindFirstChild("PlayerStructures") or Workspace:FindFirstChild("Buildings") or structuresFolder
end

-- ============================================
-- APPLY CONFIG HELPERS (SPYMM Style)
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
    local function updateH(esp)
        if esp and esp.Highlight and esp.Highlight.Parent then
            esp.Highlight.FillTransparency = fillT
            esp.Highlight.OutlineTransparency = outlineT
        end
    end
    for _, sys in pairs(ESP.Systems) do
        for _, esp in pairs(sys.instances) do updateH(esp) end
    end
    for _, esp in pairs(ESP.MobESPInstances) do updateH(esp) end
    for _, esp in pairs(ESP.StructureESPInstances) do updateH(esp) end
    for _, esp in pairs(ESP.PlayerESPInstances) do updateH(esp) end
    for _, esp in pairs(ESP.CrateESPInstances) do updateH(esp) end
end

-- ============================================
-- MOB ESP (SPYMM Style - NO WHITELIST)
-- ============================================
function ESP:RemoveMobESP(char)
    local esp = self.MobESPInstances[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.MobESPInstances[char] = nil
    end
end

function ESP:CreateMobESP(char)
    if not char:IsA("Model") then return end
    if self.MobESPInstances[char] then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end

    local isBandit = char:GetAttribute("Bandit") or char.Name:lower():find("bandit")
    local isBoss = char:GetAttribute("Boss") or table.find({"Experiment", "Harbinger", "Juggernaut", "Butcher", "Phaser"}, char.Name)
    local mobFillColor = isBoss and Color3.fromRGB(255, 0, 200) or (isBandit and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(220, 0, 0))
    local mobOutlineColor = isBoss and Color3.fromRGB(255, 200, 255) or (isBandit and Color3.fromRGB(255, 220, 150) or Color3.fromRGB(255, 185, 185))
    local mobPrefix = isBoss and "👑 [BOSS] " or (isBandit and "🔫 [BANDIT] " or "")

    local espTable = { Root = root }

    if self.MobOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = mobFillColor
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = mobOutlineColor
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
        nameLabel.Text = mobPrefix .. char.Name
        nameLabel.TextColor3 = mobOutlineColor
        nameLabel.TextStrokeTransparency = 0.2
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
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = self.MobOptions.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    -- SPYMM-style always-on connection
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent then
            connection:Disconnect()
            return
        end
        local isDead = char:GetAttribute("Dead") or (self.Utils and self.Utils.IsDead and self.Utils:IsDead(char))
        if isDead then
            if espTable.Highlight then espTable.Highlight.Enabled = false end
            if billboard then billboard.Enabled = false end
            return
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - root.Position).Magnitude
        local maxDist = self.Options and self.Options.ESPMaxDistance or 500
        local visible = dist <= maxDist

        if self.MobOptions.Chams and (not espTable.Highlight or not espTable.Highlight.Parent) then
            local h = Instance.new("Highlight")
            h.Name = "MobESP_Highlight"
            h.Adornee = char
            h.FillColor = mobFillColor
            h.FillTransparency = espConfig.fillTransparency
            h.OutlineColor = mobOutlineColor
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
                    nameLabel.Text = mobPrefix .. char.Name .. " [" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                end
            end
            if distLabel and self.MobOptions.Distance then
                distLabel.Text = math.floor(dist) .. "m"
                distLabel.TextColor3 = getDistanceColor(dist)
            end
        end
    end)
    espTable.DistanceConnection = connection
    table.insert(self.Connections, connection)

    self.MobESPInstances[char] = espTable
end

-- FIX: Detect mobs and bandits with game attribute support
function ESP:RefreshMobESP()
    for char, _ in pairs(self.MobESPInstances) do
        self:RemoveMobESP(char)
    end
    if not self.MobOptions.ESP then return end
    if not charactersFolder then return end
    
    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerCharSet[p.Character] = true end
    end
    
    for _, child in ipairs(charactersFolder:GetChildren()) do
        if child:IsA("Model") and not playerCharSet[child] then
            local isMob = true
            if self.Utils and self.Utils.IsZombieOrBandit then
                isMob = self.Utils:IsZombieOrBandit(child)
            end
            local isDead = child:GetAttribute("Dead") or (self.Utils and self.Utils.IsDead and self.Utils:IsDead(child))
            if isMob and not isDead then
                self:CreateMobESP(child)
            end
        end
    end
end

-- ============================================
-- PLAYER ESP (SPYMM Style)
-- ============================================
function ESP:RemovePlayerESP(player)
    local esp = self.PlayerESPInstances[player]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        if esp.CharAddedConn then esp.CharAddedConn:Disconnect() end
        self.PlayerESPInstances[player] = nil
    end
end

function ESP:CreatePlayerESP(player)
    if player == LocalPlayer then return end
    if self.PlayerESPInstances[player] then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end

    local espTable = { Root = root }

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(0, 100, 255)
    highlight.FillTransparency = espConfig.fillTransparency
    highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
    highlight.OutlineTransparency = espConfig.outlineTransparency
    highlight.Enabled = self.PlayerESPVars.Chams == true
    highlight.Parent = char
    espTable.Highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP_Info"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 250, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = (self.PlayerESPVars.Name or self.PlayerESPVars.Distance or self.PlayerESPVars.Health) == true
    billboard.Parent = char

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = espConfig.textSize
    nameLabel.Visible = self.PlayerESPVars.Name == true
    nameLabel.Parent = frame

    local toolLabel = Instance.new("TextLabel")
    toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
    toolLabel.Position = UDim2.new(0, 0, 0.3, 0)
    toolLabel.BackgroundTransparency = 1
    toolLabel.Text = ""
    toolLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
    toolLabel.Font = Enum.Font.Gotham
    toolLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    toolLabel.Visible = self.PlayerESPVars.Name == true
    toolLabel.Parent = frame

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.55, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "100 HP"
    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    healthLabel.Visible = self.PlayerESPVars.Health == true
    healthLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.2, 0)
    distLabel.Position = UDim2.new(0, 0, 0.78, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    distLabel.Visible = self.PlayerESPVars.Distance == true
    distLabel.Parent = frame

    espTable.Billboard = billboard
    espTable.NameLabel = nameLabel
    espTable.ToolLabel = toolLabel
    espTable.HealthLabel = healthLabel
    espTable.DistLabel = distLabel

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player or not player.Parent then
            self:RemovePlayerESP(player)
            connection:Disconnect()
            return
        end
        local c = player.Character
        if not c or not c.Parent then return end
        local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        if not r then return end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - r.Position).Magnitude
        local maxDist = self.Options and self.Options.ESPMaxDistance or 500
        local inRange = dist <= maxDist

        if espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = inRange and (self.PlayerESPVars.Chams == true)
        end

        if billboard and billboard.Parent then
            billboard.Enabled = inRange and ((self.PlayerESPVars.Name == true) or (self.PlayerESPVars.Distance == true) or (self.PlayerESPVars.Health == true))
            if nameLabel then
                nameLabel.Visible = self.PlayerESPVars.Name == true
            end
            if toolLabel then
                toolLabel.Visible = self.PlayerESPVars.Name == true
                if self.PlayerESPVars.Name then
                    local tool = c:FindFirstChildOfClass("Tool")
                    toolLabel.Text = tool and ("[ " .. tool.Name .. " ]") or ""
                end
            end
            if healthLabel then
                healthLabel.Visible = self.PlayerESPVars.Health == true
                if self.PlayerESPVars.Health then
                    local humanoid = c:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.MaxHealth > 0 then
                        healthLabel.Text = math.floor(humanoid.Health) .. " HP"
                        healthLabel.TextColor3 = getHealthColor(humanoid.Health / humanoid.MaxHealth)
                    end
                end
            end
            if distLabel then
                distLabel.Visible = self.PlayerESPVars.Distance == true
                if self.PlayerESPVars.Distance then
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                end
            end
        end
    end)
    espTable.DistanceConnection = connection
    table.insert(self.Connections, connection)

    local charAddedConn = player.CharacterAdded:Connect(function()
        if self.PlayerESPVars.ESP then
            task.wait(0.5)
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
                        task.wait(0.5)
                        self:CreatePlayerESP(player)
                    end
                end)
                table.insert(self.Connections, conn)
            end
        end
    end
end

-- ============================================
-- STRUCTURE ESP (SPYMM Style with DescendantAdded)
-- ============================================
function ESP:RemoveStructureESP(structure)
    local esp = self.StructureESPInstances[structure]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.StructureESPInstances[structure] = nil
    end
end

function ESP:CreateStructureESP(structure)
    if not structure:IsA("Model") and not structure:IsA("BasePart") then return end
    if self.StructureESPInstances[structure] then return end

    local mainPart = getItemMainPart(structure)
    if not mainPart then return end

    local espTable = { MainPart = mainPart }

    local highlight = Instance.new("Highlight")
    highlight.Name = "StructESP_Highlight"
    highlight.Adornee = structure
    highlight.FillColor = Color3.fromRGB(0, 200, 150)
    highlight.FillTransparency = espConfig.fillTransparency
    highlight.OutlineColor = Color3.fromRGB(100, 255, 200)
    highlight.OutlineTransparency = espConfig.outlineTransparency
    highlight.Enabled = self.StructureESPVars.Chams == true
    highlight.Parent = structure
    espTable.Highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "StructESP_Info"
    billboard.Adornee = mainPart
    billboard.Size = UDim2.new(0, 250, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = (self.StructureESPVars.Name or self.StructureESPVars.Distance) == true
    billboard.Parent = structure

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "[STRUCTURE] " .. structure.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = espConfig.textSize
    nameLabel.Visible = self.StructureESPVars.Name == true
    nameLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    distLabel.Visible = self.StructureESPVars.Distance == true
    distLabel.Parent = frame

    espTable.Billboard = billboard
    espTable.NameLabel = nameLabel
    espTable.DistLabel = distLabel

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not structure or not structure.Parent then
            self:RemoveStructureESP(structure)
            connection:Disconnect()
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - mainPart.Position).Magnitude
        local maxDist = self.Options and self.Options.ESPMaxDistance or 500
        local inRange = dist <= maxDist

        if espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = inRange and (self.StructureESPVars.Chams == true)
        end

        if billboard and billboard.Parent then
            billboard.Enabled = inRange and ((self.StructureESPVars.Name == true) or (self.StructureESPVars.Distance == true))
            if nameLabel then
                nameLabel.Visible = self.StructureESPVars.Name == true
            end
            if distLabel then
                distLabel.Visible = self.StructureESPVars.Distance == true
                if self.StructureESPVars.Distance then
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                end
            end
        end
    end)
    espTable.DistanceConnection = connection
    table.insert(self.Connections, connection)

    self.StructureESPInstances[structure] = espTable
end

function ESP:RefreshStructureESP()
    for structure, _ in pairs(self.StructureESPInstances) do
        self:RemoveStructureESP(structure)
    end
    if not self.StructureESPVars.ESP then return end
    structuresFolder = Workspace:FindFirstChild("Structures") or Workspace:FindFirstChild("PlayerStructures") or Workspace:FindFirstChild("Buildings") or structuresFolder
    if not structuresFolder then return end
    
    for _, child in ipairs(structuresFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            self:CreateStructureESP(child)
        end
    end
    for _, child in ipairs(structuresFolder:GetDescendants()) do
        if (child:IsA("Model") or child:IsA("BasePart")) and not self.StructureESPInstances[child] then
            if table.find(self.StructureNames, child.Name) or child:GetAttribute("Structure") then
                self:CreateStructureESP(child)
            end
        end
    end
end

-- ============================================
-- ITEM ESP - Category Factory (SPYMM Pattern)
-- ============================================
function ESP:CreateCategoryESP(sys, item)
    if not sys.itemList[item.Name] and not sys.vars.AllItems and not self.AllItemsEnabled then
        local found = false
        for targetName in pairs(sys.itemList) do
            if matchesItemName(item.Name, targetName) then
                found = true
                break
            end
        end
        if not found then return end
    end
    
    if sys.instances[item] then return end
    
    local mainPart = getItemMainPart(item)
    if not mainPart then return end

    local tier = (self.Utils and self.Utils.GetItemTier) and self.Utils:GetItemTier(item.Name)
    local tierColor = (tier and self.Utils and self.Utils.ItemTierColors) and self.Utils.ItemTierColors[tier]
    local useTier = (self.Config and self.Config.GetToggle and self.Config:GetToggle("ItemTierColors")) and tierColor
    local fillColor = useTier and tierColor or sys.colors.fill
    local outlineColor = useTier and Color3.fromRGB(255, 255, 255) or sys.colors.outline
    local textColor = useTier and tierColor or sys.colors.text
    local tierTag = (tier and tier > 0) and string.format("[T%d] ", tier) or ""

    local espTable = { MainPart = mainPart }

    local highlight = Instance.new("Highlight")
    highlight.Name = sys.key .. "_ESP"
    highlight.Adornee = item
    highlight.FillColor = fillColor
    highlight.FillTransparency = espConfig.fillTransparency
    highlight.OutlineColor = outlineColor
    highlight.OutlineTransparency = espConfig.outlineTransparency
    highlight.Enabled = sys.vars.Chams == true
    highlight.Parent = item
    espTable.Highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = sys.key .. "_Billboard"
    billboard.Adornee = mainPart
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = (sys.vars.Name or sys.vars.Distance) == true
    billboard.Parent = item

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local displayName = item.Name:gsub("%s*%([^)]+%)", ""):gsub("_%d+$", "")
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = tierTag .. "[" .. sys.key .. "] " .. displayName
    nameLabel.TextColor3 = textColor
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = espConfig.textSize
    nameLabel.Visible = sys.vars.Name == true
    nameLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    distLabel.Visible = sys.vars.Distance == true
    distLabel.Parent = frame

    espTable.Billboard = billboard
    espTable.NameLabel = nameLabel
    espTable.DistLabel = distLabel

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not item or not item.Parent then
            self:RemoveCategoryESP(sys, item)
            connection:Disconnect()
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot or not espTable.MainPart then return end
        
        local dist = (myRoot.Position - espTable.MainPart.Position).Magnitude
        local maxDist = self.Options and self.Options.ESPMaxDistance or 500
        local inRange = dist <= maxDist

        if espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = inRange and (sys.vars.Chams == true)
        end

        if billboard and billboard.Parent then
            billboard.Enabled = inRange and ((sys.vars.Name == true) or (sys.vars.Distance == true))
            if nameLabel then
                nameLabel.Visible = sys.vars.Name == true
            end
            if distLabel then
                distLabel.Visible = sys.vars.Distance == true
                if sys.vars.Distance then
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                end
            end
        end
    end)
    espTable.DistanceConnection = connection
    table.insert(self.Connections, connection)

    sys.instances[item] = espTable
end

function ESP:RemoveCategoryESP(sys, item)
    local esp = sys.instances[item]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        sys.instances[item] = nil
    end
end

function ESP:RefreshCategoryESP(sys)
    for item, _ in pairs(sys.instances) do
        self:RemoveCategoryESP(sys, item)
    end
    if not sys.vars.ESP and not self.AllItemsEnabled then return end
    droppedItemsFolder = Workspace:FindFirstChild("DroppedItems") or droppedItemsFolder
    if not droppedItemsFolder then return end
    
    scanItemsRecursive(droppedItemsFolder, sys, function(item)
        self:CreateCategoryESP(sys, item)
    end)
end

function ESP:SetupCategoryListeners(sys)
    droppedItemsFolder = Workspace:FindFirstChild("DroppedItems") or droppedItemsFolder
    if not droppedItemsFolder or sys.listenersSetup then return end
    sys.listenersSetup = true
    
    local addedConn = droppedItemsFolder.ChildAdded:Connect(function(child)
        if not sys.vars.ESP and not self.AllItemsEnabled then return end
        task.wait(0.1)
        if matchesItemName(child.Name, sys.key) or sys.itemList[child.Name] then
            self:CreateCategoryESP(sys, child)
        else
            for targetName in pairs(sys.itemList) do
                if matchesItemName(child.Name, targetName) then
                    self:CreateCategoryESP(sys, child)
                    break
                end
            end
        end
        scanItemsRecursive(child, sys, function(nestedItem)
            self:CreateCategoryESP(sys, nestedItem)
        end)
    end)
    table.insert(self.Connections, addedConn)
    
    local removedConn = droppedItemsFolder.ChildRemoved:Connect(function(child)
        self:RemoveCategoryESP(sys, child)
        for item, _ in pairs(sys.instances) do
            if item == child or item:IsDescendantOf(child) then
                self:RemoveCategoryESP(sys, item)
            end
        end
    end)
    table.insert(self.Connections, removedConn)
end

-- ============================================
-- CRATES ESP
-- ============================================
function ESP:FindAllCrates()
    local crates = {}
    local seen = {}
    local function addCrate(c)
        if c and not seen[c] and not c:GetAttribute("Opened") then
            seen[c] = true
            table.insert(crates, c)
        end
    end

    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        local cratesFolder = mapFolder:FindFirstChild("Crates")
        if cratesFolder then
            for _, child in ipairs(cratesFolder:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    addCrate(child)
                end
            end
        end
    end
    local directCrates = Workspace:FindFirstChild("Crates")
    if directCrates then
        for _, child in ipairs(directCrates:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                addCrate(child)
            end
        end
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:GetAttribute("Crate") then
            addCrate(child)
        end
    end
    return crates
end

function ESP:GetCrateMainPart(crate)
    if not crate then return nil end
    if crate:IsA("BasePart") then return crate end
    if crate.PrimaryPart then return crate.PrimaryPart end
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart", "Box", "Root"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part end
    end
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return crate:FindFirstChildWhichIsA("BasePart", true)
end

function ESP:RemoveCrateESP(crate)
    local esp = self.CrateESPInstances[crate]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.CrateESPInstances[crate] = nil
    end
end

function ESP:CreateCrateESP(crate)
    if not crate then return end
    if crate:GetAttribute("Opened") then return end
    if self.CrateESPInstances[crate] then return end
    
    local mainPart = self:GetCrateMainPart(crate)
    if not mainPart then return end
    
    local espTable = { MainPart = mainPart }
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "CrateESP_Highlight"
    highlight.Adornee = crate
    highlight.FillColor = self.CrateOptions.ChamsColor or Color3.fromRGB(255, 200, 50)
    highlight.FillTransparency = espConfig.fillTransparency
    highlight.OutlineColor = self.CrateOptions.OutlineColor or Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = espConfig.outlineTransparency
    highlight.Enabled = self.CrateOptions.Chams == true
    highlight.Parent = crate
    espTable.Highlight = highlight
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CrateESP_Info"
    billboard.Adornee = mainPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = (self.CrateOptions.Name or self.CrateOptions.Distance) == true
    billboard.Parent = crate
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "📦 " .. (crate.Name ~= "Model" and crate.Name or "CRATE")
    nameLabel.TextColor3 = self.CrateOptions.ChamsColor or Color3.fromRGB(255, 200, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = espConfig.textSize
    nameLabel.Visible = self.CrateOptions.Name == true
    nameLabel.Parent = frame
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
    distLabel.Visible = self.CrateOptions.Distance == true
    distLabel.Parent = frame
    
    espTable.Billboard = billboard
    espTable.NameLabel = nameLabel
    espTable.DistLabel = distLabel
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not crate or not crate.Parent or crate:GetAttribute("Opened") then
            self:RemoveCrateESP(crate)
            connection:Disconnect()
            return
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if not myRoot then return end
        
        local dist = (myRoot.Position - mainPart.Position).Magnitude
        local maxDist = self.CrateOptions.MaxDistance or (self.Options and self.Options.ESPMaxDistance) or 500
        local inRange = dist <= maxDist

        if espTable.Highlight and espTable.Highlight.Parent then
            espTable.Highlight.Enabled = inRange and (self.CrateOptions.Chams == true)
        end

        if billboard and billboard.Parent then
            billboard.Enabled = inRange and ((self.CrateOptions.Name == true) or (self.CrateOptions.Distance == true))
            if nameLabel then
                nameLabel.Visible = self.CrateOptions.Name == true
            end
            if distLabel then
                distLabel.Visible = self.CrateOptions.Distance == true
                if self.CrateOptions.Distance then
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                end
            end
        end
    end)
    espTable.DistanceConnection = connection
    table.insert(self.Connections, connection)
    
    self.CrateESPInstances[crate] = espTable
end

function ESP:RefreshCrateESP()
    for crate, _ in pairs(self.CrateESPInstances) do
        self:RemoveCrateESP(crate)
    end
    if not self.CrateOptions.ESP then return end
    local allCrates = (self.Utils and self.Utils.FindAllCrates and self.Utils:FindAllCrates()) or self:FindAllCrates()
    for _, crate in ipairs(allCrates) do
        if not crate:GetAttribute("Opened") then
            self:CreateCrateESP(crate)
        end
    end
end

function ESP:SetupCrateListeners()
    local mapFolder = Workspace:FindFirstChild("Map")
    local cratesFolder = (mapFolder and mapFolder:FindFirstChild("Crates")) or Workspace:FindFirstChild("Crates")
    if cratesFolder and not self.CratesListenerSetup then
        self.CratesListenerSetup = true
        local childAddedConn = cratesFolder.ChildAdded:Connect(function(child)
            if self.CrateOptions.ESP and (child:IsA("Model") or child:IsA("BasePart")) then
                task.wait(0.1)
                self:CreateCrateESP(child)
            end
        end)
        table.insert(self.Connections, childAddedConn)
        
        local childRemovedConn = cratesFolder.ChildRemoved:Connect(function(child)
            self:RemoveCrateESP(child)
        end)
        table.insert(self.Connections, childRemovedConn)
    end
end

-- ============================================
-- LISTENERS SETUP (SPYMM Style)
-- ============================================
function ESP:SetupMobListeners()
    charactersFolder = Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("Zombies_Local") or charactersFolder
    if not charactersFolder or self.MobListenersSetup then return end
    self.MobListenersSetup = true
    
    local childAddedConn = charactersFolder.ChildAdded:Connect(function(child)
        if self.MobOptions.ESP and child:IsA("Model") then
            local isPlayer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character == child then isPlayer = true; break end
            end
            if not isPlayer then
                task.wait(0.2)
                self:CreateMobESP(child)
            end
        end
    end)
    table.insert(self.Connections, childAddedConn)

    local childRemovedConn = charactersFolder.ChildRemoved:Connect(function(child)
        self:RemoveMobESP(child)
    end)
    table.insert(self.Connections, childRemovedConn)
end

function ESP:SetupStructureListeners()
    structuresFolder = Workspace:FindFirstChild("Structures") or Workspace:FindFirstChild("PlayerStructures") or Workspace:FindFirstChild("Buildings") or structuresFolder
    if not structuresFolder or self.StructureListenersSetup then return end
    self.StructureListenersSetup = true
    
    local descendantAddedConn = structuresFolder.DescendantAdded:Connect(function(child)
        if self.StructureESPVars.ESP and (child:IsA("Model") or child:IsA("BasePart")) then
            if table.find(self.StructureNames, child.Name) or child:GetAttribute("Structure") or child.Parent == structuresFolder then
                task.wait(0.2)
                self:CreateStructureESP(child)
            end
        end
    end)
    table.insert(self.Connections, descendantAddedConn)

    local descendantRemovingConn = structuresFolder.DescendantRemoving:Connect(function(child)
        self:RemoveStructureESP(child)
    end)
    table.insert(self.Connections, descendantRemovingConn)
end

-- ============================================
-- PUBLIC SETTER METHODS (SPYMM Style)
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

function ESP:SetESPMaxDistance(distance)
    if not self.Options then self.Options = {} end
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

function ESP:SetAllItemsEnabled(value)
    self.AllItemsEnabled = value
    for _, sys in pairs(self.Systems) do
        sys.vars.ESP = value
        if value then
            sys.vars.Chams = true
            sys.vars.Name = true
            sys.vars.Distance = true
        end
        self:RefreshCategoryESP(sys)
    end
end

function ESP:SetAllItemChams(value)
    for _, sys in pairs(self.Systems) do
        if value and not sys.vars.ESP then sys.vars.ESP = true end
        sys.vars.Chams = value
        for _, esp in pairs(sys.instances) do
            if esp.Highlight then
                esp.Highlight.Enabled = value
            end
        end
    end
end

function ESP:SetAllItemNames(value)
    for _, sys in pairs(self.Systems) do
        if value and not sys.vars.ESP then sys.vars.ESP = true end
        sys.vars.Name = value
        for _, esp in pairs(sys.instances) do
            if esp.NameLabel then
                esp.NameLabel.Visible = value
            end
            if esp.Billboard then
                esp.Billboard.Enabled = value or sys.vars.Distance == true
            end
        end
    end
end

function ESP:SetAllItemDistances(value)
    for _, sys in pairs(self.Systems) do
        if value and not sys.vars.ESP then sys.vars.ESP = true end
        sys.vars.Distance = value
        for _, esp in pairs(sys.instances) do
            if esp.DistLabel then
                esp.DistLabel.Visible = value
            end
            if esp.Billboard then
                esp.Billboard.Enabled = value or sys.vars.Name == true
            end
        end
    end
end

function ESP:SetItemCategoryEnabled(category, enabled)
    if self.Systems[category] then
        local sys = self.Systems[category]
        sys.vars.ESP = enabled
        if enabled then
            sys.vars.Chams = true
            sys.vars.Name = true
            sys.vars.Distance = true
        end
        self:RefreshCategoryESP(sys)
    end
end

-- ============================================
-- INITIALIZATION (SPYMM Style)
-- ============================================
function ESP:Init(modules)
    self.Config = modules.config or modules.Config
    self.Utils = modules.utils or modules.Utils
    if self.Config then
        self.Options = self.Config:GetOptions()

        if self.Config.GetCrateOptions then
            local cfgCrates = self.Config:GetCrateOptions()
            if cfgCrates then
                for k, v in pairs(self.CrateOptions) do
                    if cfgCrates[k] == nil then cfgCrates[k] = v end
                end
                self.CrateOptions = cfgCrates
            end
        end
    end

    discoverFolders()
    
    -- Setup category listeners
    for _, sys in pairs(self.Systems) do
        self:SetupCategoryListeners(sys)
    end
    
    self:SetupCrateListeners()
    self:SetupMobListeners()
    self:SetupStructureListeners()

    -- Listen for player joins and leaves
    local pAddedConn = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            if self.PlayerESPVars.ESP then
                task.wait(0.5)
                self:CreatePlayerESP(p)
            end
        end)
        if p.Character and self.PlayerESPVars.ESP then
            self:CreatePlayerESP(p)
        end
    end)
    table.insert(self.Connections, pAddedConn)

    local pRemovedConn = Players.PlayerRemoving:Connect(function(p)
        self:RemovePlayerESP(p)
    end)
    table.insert(self.Connections, pRemovedConn)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function(char)
                if self.PlayerESPVars.ESP then
                    task.wait(0.5)
                    self:CreatePlayerESP(p)
                end
            end)
        end
    end
    
    -- Periodic folder refresh (SPYMM style)
    task.spawn(function()
        while true do
            task.wait(5)
            local prevChars = charactersFolder
            local prevItems = droppedItemsFolder
            local prevStructs = structuresFolder
            discoverFolders()
            
            if charactersFolder ~= prevChars and charactersFolder then
                self:RefreshMobESP()
                self.MobListenersSetup = false
                self:SetupMobListeners()
            end
            if droppedItemsFolder ~= prevItems and droppedItemsFolder then
                for _, sys in pairs(self.Systems) do
                    self:RefreshCategoryESP(sys)
                    sys.listenersSetup = false
                    self:SetupCategoryListeners(sys)
                end
            end
            if structuresFolder ~= prevStructs and structuresFolder then
                self:RefreshStructureESP()
                self.StructureListenersSetup = false
                self:SetupStructureListeners()
            end
            if not self.CratesListenerSetup then
                self:SetupCrateListeners()
            end
        end
    end)
    
    print(string.format("[ESP] %d item categories ready", #self.EspDefinitions))
    return self
end

return ESP
