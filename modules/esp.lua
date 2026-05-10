-- =======================================================
-- PINATHUB - ESP MODULE (COMPLETE - SAMA SEPERTI SINGLE CODE)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

-- ============================================
-- STATE VARIABLES (Sama seperti single code)
-- ============================================
ESP.Connections = {}
ESP.MobESPInstances = {}
ESP.PlayerESPInstances = {}
ESP.StructureESPInstances = {}
ESP.CrateESPInstances = {}
ESP.Systems = {}  -- Untuk item ESP systems

-- Options (Sama seperti single code)
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

-- Mob names (Sama seperti single code)
ESP.MobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- Structure names (Sama seperti single code)
ESP.StructureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower"
}

-- ============================================
-- ITEM CATEGORIES & COLOR DEFINITIONS (Sama seperti single code)
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

-- Initialize ESP systems
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
-- UTILITY FUNCTIONS (Sama seperti single code)
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

local function getHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

local function discoverFolders()
    ESP.CharactersFolder = Workspace:FindFirstChild("Characters")
    ESP.DroppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    ESP.StructuresFolder = Workspace:FindFirstChild("Structures")
        or Workspace:FindFirstChild("PlayerStructures")
        or Workspace:FindFirstChild("Buildings")
end

-- ============================================
-- MOB ESP FUNCTIONS (Sama seperti single code)
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

    local espTable = {}
    local mobColors = {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}

    if self.MobOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = mobColors.fill
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = mobColors.outline
        highlight.OutlineTransparency = 0.8
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    if self.MobOptions.Name or self.MobOptions.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MobESP_NameDistance"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
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
        nameLabel.Visible = self.MobOptions.Name
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
        distLabel.Visible = self.MobOptions.Distance
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
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    local maxDist = self.Options.ESPMaxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(self.Connections, connection)
    end

    self.MobESPInstances[char] = espTable
end

function ESP:RefreshMobESP()
    for char, _ in pairs(self.MobESPInstances) do
        self:RemoveMobESP(char)
    end
    if not self.MobOptions.ESP then return end
    if not self.CharactersFolder then return end
    for _, child in ipairs(self.CharactersFolder:GetChildren()) do
        if table.find(self.MobNames, child.Name) then
            self:CreateMobESP(child)
        end
    end
end

-- ============================================
-- PLAYER ESP FUNCTIONS (Sama seperti single code)
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

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espTable = {}

    if self.PlayerESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
        highlight.OutlineTransparency = 0.8
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    if self.PlayerESPVars.Name or self.PlayerESPVars.Distance or self.PlayerESPVars.Health then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 70)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
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
        nameLabel.Visible = self.PlayerESPVars.Name
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
        toolLabel.Visible = self.PlayerESPVars.Name
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
        healthLabel.Visible = self.PlayerESPVars.Health
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
        distLabel.Visible = self.PlayerESPVars.Distance
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
            local r = c:FindFirstChild("HumanoidRootPart")
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
                    healthLabel.TextColor3 = getHealthColor(humanoid.Health / humanoid.MaxHealth)
                end
            end

            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - r.Position).Magnitude
                    local maxDist = self.Options.ESPMaxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
        table.insert(self.Connections, connection)
    end

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
-- STRUCTURE ESP FUNCTIONS (Sama seperti single code)
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
    if not structure:IsA("Model") then return end
    if self.StructureESPInstances[structure] then return end

    local mainPart = structure.PrimaryPart or getItemMainPart(structure)
    if not mainPart then return end

    local espTable = {}

    if self.StructureESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "StructESP_Highlight"
        highlight.Adornee = structure
        highlight.FillColor = Color3.fromRGB(0, 200, 150)
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = Color3.fromRGB(100, 255, 200)
        highlight.OutlineTransparency = 0.7
        highlight.Parent = structure
        espTable.Highlight = highlight
    end

    if self.StructureESPVars.Name or self.StructureESPVars.Distance then
        local billboard = Instance.new("BillboardGui")
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
        nameLabel.Visible = self.StructureESPVars.Name
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
        distLabel.Visible = self.StructureESPVars.Distance
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
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    local maxDist = self.Options.ESPMaxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
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
        table.insert(self.Connections, connection)
    end

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
-- GENERIC ITEM ESP FACTORY (Sama seperti single code)
-- ============================================
function ESP:CreateCategoryESP(sys, item)
    if not item:IsA("Model") then return end
    if sys.instances[item] then return end

    local mainPart = getItemMainPart(item)
    if not mainPart then return end

    local espTable = {}

    if sys.vars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = sys.key .. "ESP_Highlight"
        highlight.Adornee = item
        highlight.FillColor = sys.colors.fill
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = sys.colors.outline
        highlight.OutlineTransparency = 0.8
        highlight.Parent = item
        espTable.Highlight = highlight
    end

    if sys.vars.Name or sys.vars.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = sys.key .. "ESP_NameDistance"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
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
        nameLabel.Text = "[" .. sys.key .. "] " .. item.Name
        nameLabel.TextColor3 = sys.colors.text
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = sys.vars.Name
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
        distLabel.Visible = sys.vars.Distance
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
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local maxDist = self.Options.ESPMaxDistance or 99999
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
        table.insert(self.Connections, connection)
    end

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
    if not sys.vars.ESP then return end
    if not self.DroppedItemsFolder then return end
    for _, child in ipairs(self.DroppedItemsFolder:GetChildren()) do
        if sys.itemList[child.Name] then
            self:CreateCategoryESP(sys, child)
        end
    end
end

function ESP:SetupCategoryListeners(sys)
    if not self.DroppedItemsFolder or sys.listenersSetup then return end
    sys.listenersSetup = true
    local addedConn = self.DroppedItemsFolder.ChildAdded:Connect(function(child)
        if sys.vars.ESP and sys.itemList[child.Name] then
            self:CreateCategoryESP(sys, child)
        end
    end)
    table.insert(self.Connections, addedConn)
    local removedConn = self.DroppedItemsFolder.ChildRemoved:Connect(function(child)
        self:RemoveCategoryESP(sys, child)
    end)
    table.insert(self.Connections, removedConn)
end

-- ============================================
-- CRATES ESP FUNCTIONS (Sama seperti single code)
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
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then return part end
    end
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
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        self.CrateESPInstances[crate] = nil
    end
end

function ESP:CreateCrateESP(crate)
    if not crate:IsA("Model") then return end
    if self.CrateESPInstances[crate] then return end
    
    local mainPart = self:GetCrateMainPart(crate)
    if not mainPart then return end
    
    local espTable = {}
    
    if self.CrateOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CrateESP_Highlight"
        highlight.Adornee = crate
        highlight.FillColor = self.CrateOptions.ChamsColor
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = self.CrateOptions.OutlineColor
        highlight.OutlineTransparency = 0.5
        highlight.Parent = crate
        espTable.Highlight = highlight
    end
    
    if self.CrateOptions.Name or self.CrateOptions.Distance then
        local billboard = Instance.new("BillboardGui")
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
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📦 CRATE"
        nameLabel.TextColor3 = self.CrateOptions.ChamsColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Visible = self.CrateOptions.Name
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
        distLabel.Visible = self.CrateOptions.Distance
        distLabel.Parent = frame
        
        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
        espTable.MainPart = mainPart
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not crate or not crate.Parent then
                connection:Disconnect()
                return
            end
            if distLabel and distLabel.Visible and distLabel.Parent then
                local myChar = LocalPlayer.Character
                local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
                if myRoot and mainPart and mainPart.Parent then
                    local dist = (myRoot.Position - mainPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = getDistanceColor(dist)
                    local visible = dist <= self.CrateOptions.MaxDistance
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
        table.insert(self.Connections, connection)
    end
    
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
    local childRemovedConn = cratesFolder.ChildRemoving:Connect(function(child)
        if child.Name == "Default" and child:IsA("Model") then
            self:RemoveCrateESP(child)
        end
    end)
    table.insert(self.Connections, childRemovedConn)
end

-- ============================================
-- FOLDER EVENT LISTENERS
-- ============================================
function ESP:SetupMobListeners()
    if not self.CharactersFolder or self.MobListenersSetup then return end
    self.MobListenersSetup = true
    local childAddedConn = self.CharactersFolder.ChildAdded:Connect(function(child)
        if self.MobOptions.ESP and table.find(self.MobNames, child.Name) then
            self:CreateMobESP(child)
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
-- REFRESH ALL (Sama seperti single code)
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
-- SETTER METHODS (Untuk UI)
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

function ESP:SetAllItemChams(value)
    for _, sys in pairs(self.Systems) do
        sys.vars.Chams = value
        self:RefreshCategoryESP(sys)
    end
end

function ESP:SetItemCategoryESP(category, enabled)
    if self.Systems[category] then
        self.Systems[category].vars.ESP = enabled
        self:RefreshCategoryESP(self.Systems[category])
    end
end

-- ============================================
-- INIT (Sama seperti single code)
-- ============================================
function ESP:Init(deps)
    self.Utils = deps.utils or deps.Utils
    self.Config = deps.config or deps.Config
    self.Notifications = deps.notifications or deps.Notifications
    
    -- Discover folders
    discoverFolders()
    
    -- Setup all ESP systems
    for _, sys in pairs(self.Systems) do
        self:SetupCategoryListeners(sys)
    end
    
    -- Setup crate listeners
    self:SetupCrateListeners()
    
    -- Start folder watcher
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
    
    -- Setup mob and structure listeners
    self:SetupMobListeners()
    self:SetupStructureListeners()
    
    print("[ESP MODULE] Initialized - Same as single code version")
    return self
end

return ESP
