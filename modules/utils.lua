-- =======================================================
-- PINATHUB - UTILITIES MODULE
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Connection management
Utils.Connections = {}

function Utils:AddConnection(conn)
    table.insert(self.Connections, conn)
    return conn
end

function Utils:DisconnectAll()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
end

-- Item part detection
function Utils:GetItemMainPart(item)
    if item.PrimaryPart then return item.PrimaryPart end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

function Utils:GetItemPrimaryPart(item)
    if item:IsA("Model") then
        if item.PrimaryPart then
            return item.PrimaryPart
        end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "Handle" then
                return child
            end
        end
        local handle = item:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle
        end
    end
    return nil
end

-- Color utilities
function Utils:GetDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

function Utils:GetHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

-- Folder discovery
function Utils:DiscoverFolders()
    local Workspace = game:GetService("Workspace")
    return {
        charactersFolder = Workspace:FindFirstChild("Characters"),
        droppedItemsFolder = Workspace:FindFirstChild("DroppedItems"),
        structuresFolder = Workspace:FindFirstChild("Structures")
            or Workspace:FindFirstChild("PlayerStructures")
            or Workspace:FindFirstChild("Buildings")
    }
end

-- Get player root part
function Utils:GetPlayerRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChild("Torso") 
        or char:FindFirstChild("UpperTorso")
end

-- Get player character
function Utils:GetCharacter()
    return LocalPlayer.Character
end

-- Distance calculation
function Utils:GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Safe pcall wrapper
function Utils:SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall error: " .. tostring(result))
        return nil
    end
    return result
end

-- Delay with task library
function Utils:Delay(seconds, func)
    task.wait(seconds)
    return func()
end

-- Create highlight
function Utils:CreateHighlight(adornee, fillColor, fillTrans, outlineColor, outlineTrans)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = adornee
    highlight.FillColor = fillColor
    highlight.FillTransparency = fillTrans or 0.4
    highlight.OutlineColor = outlineColor
    highlight.OutlineTransparency = outlineTrans or 0.8
    highlight.Parent = adornee
    return highlight
end

-- Create billboard
function Utils:CreateBillboard(adornee, size, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = size or UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    return billboard
end

-- Find all crates
function Utils:FindAllCrates()
    local crates = {}
    local Workspace = game:GetService("Workspace")
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

-- Get crate main part
function Utils:GetCrateMainPart(crate)
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

return Utils
