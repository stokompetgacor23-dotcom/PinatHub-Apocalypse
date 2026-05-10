-- =======================================================
-- PINATHUB - ESP MODULE
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
    crate = {}
}
ESP.Options = {
    mob = { ESP = false, Chams = false, Name = false, Distance = false },
    player = { ESP = false, Chams = false, Name = false, Distance = false, Health = false },
    structure = { ESP = false, Chams = false, Name = false, Distance = false }
}
ESP.CategoryVars = {}
ESP.CategoryInstances = {}

-- Forward declarations
local removeMobESP, createMobESP, refreshMobESP
local removePlayerESP, createPlayerESP, refreshPlayerESP
local removeStructureESP, createStructureESP, refreshStructureESP
local removeCategoryESP, createCategoryESP, refreshCategoryESP, setupCategoryListeners

-- Mob ESP Functions
function removeMobESP(char)
    local esp = ESP.Instances.mob[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.DistanceConnection then esp.DistanceConnection:Disconnect() end
        ESP.Instances.mob[char] = nil
    end
end

function createMobESP(char, mobNames, maxDistance, utils)
    if not char:IsA("Model") then return end
    if ESP.Instances.mob[char] then return end

    local root = utils:GetPlayerRoot(char)
    if not root then return end

    local espTable = {}
    local mobColors = {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}
    local opts = ESP.Options.mob

    if opts.Chams then
        local highlight = utils:CreateHighlight(char, mobColors.fill, 0.3, mobColors.outline, 0.8)
        espTable.Highlight = highlight
    end

    if opts.Name or opts.Distance then
        local billboard = utils:CreateBillboard(root, UDim2.new(0, 220, 0, 50), Vector3.new(0, 3, 0))
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
                local myRoot = utils:GetPlayerRoot(myChar)
                if myRoot then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    local maxDist = maxDistance or 99999
                    distLabel.Text = math.floor(dist) .. "m"
                    distLabel.TextColor3 = utils:GetDistanceColor(dist)
                    local visible = dist <= maxDist
                    if billboard.Enabled ~= visible then billboard.Enabled = visible end
                    if espTable.Highlight then espTable.Highlight.Enabled = visible end
                end
            end
        end)
        espTable.DistanceConnection = connection
    end

    ESP.Instances.mob[char] = espTable
end

function refreshMobESP(mobNames, maxDistance, utils)
    for char, _ in pairs(ESP.Instances.mob) do
        removeMobESP(char)
    end
    if not ESP.Options.mob.ESP then return end
    local folders = utils:DiscoverFolders()
    if not folders.charactersFolder then return end
    for _, child in ipairs(folders.charactersFolder:GetChildren()) do
        local found = false
        for _, name in ipairs(mobNames) do
            if child.Name == name then found = true break end
        end
        if found then
            createMobESP(child, mobNames, maxDistance, utils)
        end
    end
end

function ESP:SetMobOptions(opts)
    ESP.Options.mob = opts
    return self
end

function ESP:SetPlayerOptions(opts)
    ESP.Options.player = opts
    return self
end

function ESP:SetStructureOptions(opts)
    ESP.Options.structure = opts
    return self
end

function ESP:RefreshAll()
    local utils = self.Utils
    local config = self.Config
    if not utils then return end
    
    refreshMobESP(config:GetMobNames(), config:GetOptions().ESPMaxDistance, utils)
    refreshPlayerESP(config:GetOptions().ESPMaxDistance, utils)
    refreshStructureESP(config:GetStructureNames(), config:GetOptions().ESPMaxDistance, utils)
end

function ESP:Init(deps)
    self.Config = deps.Config
    self.Utils = deps.Utils
    self.Network = deps.Network
    
    return self
end

return ESP
