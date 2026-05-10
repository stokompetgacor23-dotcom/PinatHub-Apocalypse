-- =======================================================
-- PINATHUB - UTILITIES MODULE WITH DEBUG SYSTEM
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

-- Connection management
Utils.Connections = {}

-- =======================================================
-- DEBUG SYSTEM
-- =======================================================

local MODULE_NAME = "UTILS"

function Utils.Debug(moduleName, ...)
    local args = {...}
    local msg = table.concat(args, " ")
    print(string.format("[%s][%s] %s", string.upper(moduleName), "DEBUG", msg))
end

function Utils.Warn(moduleName, ...)
    local args = {...}
    local msg = table.concat(args, " ")
    warn(string.format("[%s][%s] %s", string.upper(moduleName), "WARN", msg))
end

function Utils.Error(moduleName, err)
    error(string.format("[%s][ERROR] %s", string.upper(moduleName), tostring(err)))
end

function Utils.SafeSpawn(threadName, func)
    task.spawn(function()
        local ok, err = pcall(func)
        if not ok then
            warn(string.format("[%s][THREAD_ERROR] Thread '%s' crashed: %s", MODULE_NAME, threadName, tostring(err)))
        else
            Utils.Debug(MODULE_NAME, "Thread '" .. threadName .. "' completed successfully")
        end
    end)
end

function Utils.SafeCall(moduleName, funcName, func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        Utils.Warn(moduleName, string.format("%s() failed: %s", funcName, tostring(result)))
        return nil, result
    end
    Utils.Debug(moduleName, string.format("%s() completed successfully", funcName))
    return result, nil
end

function Utils:AddConnection(conn)
    table.insert(self.Connections, conn)
    Utils.Debug(MODULE_NAME, "Connection added, total:", #self.Connections)
    return conn
end

function Utils:DisconnectAll()
    Utils.Debug(MODULE_NAME, "Disconnecting all connections...")
    for _, conn in ipairs(self.Connections) do
        local ok, err = pcall(function() conn:Disconnect() end)
        if not ok then
            Utils.Warn(MODULE_NAME, "Failed to disconnect:", err)
        end
    end
    self.Connections = {}
    Utils.Debug(MODULE_NAME, "All connections disconnected")
end

-- Item part detection
function Utils:GetItemMainPart(item)
    Utils.Debug(MODULE_NAME, "GetItemMainPart called for:", item and item.Name or "nil")
    if not item then
        Utils.Warn(MODULE_NAME, "GetItemMainPart - item is nil")
        return nil
    end
    
    local result = nil
    if item.PrimaryPart then 
        result = item.PrimaryPart
        Utils.Debug(MODULE_NAME, "GetItemMainPart - using PrimaryPart:", result.Name)
        return result 
    end
    
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            result = child
            Utils.Debug(MODULE_NAME, "GetItemMainPart - found BasePart:", child.Name)
            return result
        end
    end
    
    Utils.Warn(MODULE_NAME, "GetItemMainPart - no BasePart found for:", item.Name)
    return nil
end

function Utils:GetItemPrimaryPart(item)
    Utils.Debug(MODULE_NAME, "GetItemPrimaryPart called for:", item and item.Name or "nil")
    if not item then
        Utils.Warn(MODULE_NAME, "GetItemPrimaryPart - item is nil")
        return nil
    end
    
    if item:IsA("Model") then
        if item.PrimaryPart then
            Utils.Debug(MODULE_NAME, "GetItemPrimaryPart - using PrimaryPart:", item.PrimaryPart.Name)
            return item.PrimaryPart
        end
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("BasePart") and child.Name ~= "Handle" then
                Utils.Debug(MODULE_NAME, "GetItemPrimaryPart - found BasePart (non-Handle):", child.Name)
                return child
            end
        end
        local handle = item:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            Utils.Debug(MODULE_NAME, "GetItemPrimaryPart - using Handle:", handle.Name)
            return handle
        end
    end
    Utils.Warn(MODULE_NAME, "GetItemPrimaryPart - no suitable part found for:", item.Name)
    return nil
end

-- Color utilities
function Utils:GetDistanceColor(dist)
    local color = nil
    if dist > 250 then color = Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then color = Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then color = Color3.fromRGB(255, 255, 80)
    else color = Color3.fromRGB(220, 220, 220) end
    Utils.Debug(MODULE_NAME, "GetDistanceColor - distance:", dist, "color assigned")
    return color
end

function Utils:GetHealthColor(pct)
    local color = nil
    if pct > 0.6 then color = Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then color = Color3.fromRGB(255, 230, 50)
    else color = Color3.fromRGB(255, 60, 60) end
    Utils.Debug(MODULE_NAME, "GetHealthColor - percentage:", pct, "color assigned")
    return color
end

-- Folder discovery
function Utils:DiscoverFolders()
    Utils.Debug(MODULE_NAME, "DiscoverFolders called")
    local Workspace = game:GetService("Workspace")
    local charactersFolder = Workspace:FindFirstChild("Characters")
    local droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    local structuresFolder = Workspace:FindFirstChild("Structures") or Workspace:FindFirstChild("PlayerStructures") or Workspace:FindFirstChild("Buildings")
    
    if not charactersFolder then Utils.Warn(MODULE_NAME, "DiscoverFolders - Characters folder not found") end
    if not droppedItemsFolder then Utils.Warn(MODULE_NAME, "DiscoverFolders - DroppedItems folder not found") end
    if not structuresFolder then Utils.Warn(MODULE_NAME, "DiscoverFolders - Structures folder not found") end
    
    Utils.Debug(MODULE_NAME, "DiscoverFolders completed - characters:", charactersFolder and "found" or "missing", 
                "droppedItems:", droppedItemsFolder and "found" or "missing",
                "structures:", structuresFolder and "found" or "missing")
    
    return {
        charactersFolder = charactersFolder,
        droppedItemsFolder = droppedItemsFolder,
        structuresFolder = structuresFolder
    }
end

-- Get player root part
function Utils:GetPlayerRoot(char)
    Utils.Debug(MODULE_NAME, "GetPlayerRoot called - char exists:", char ~= nil)
    if not char then 
        Utils.Warn(MODULE_NAME, "GetPlayerRoot - char is nil")
        return nil 
    end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then
        Utils.Warn(MODULE_NAME, "GetPlayerRoot - no root part found in character")
    else
        Utils.Debug(MODULE_NAME, "GetPlayerRoot - found:", root.Name)
    end
    return root
end

-- Get player character
function Utils:GetCharacter()
    local char = LocalPlayer.Character
    Utils.Debug(MODULE_NAME, "GetCharacter called - character exists:", char ~= nil)
    if not char then
        Utils.Warn(MODULE_NAME, "GetCharacter - LocalPlayer.Character is nil")
    end
    return char
end

-- Distance calculation
function Utils:GetDistance(pos1, pos2)
    if not pos1 or not pos2 then
        Utils.Warn(MODULE_NAME, "GetDistance - invalid positions provided")
        return 0
    end
    local dist = (pos1 - pos2).Magnitude
    Utils.Debug(MODULE_NAME, "GetDistance - distance:", dist)
    return dist
end

-- Safe pcall wrapper (legacy)
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
    Utils.Debug(MODULE_NAME, "Delay - starting delay of", seconds, "seconds")
    task.wait(seconds)
    local ok, err = pcall(func)
    if not ok then
        Utils.Warn(MODULE_NAME, "Delay callback failed:", err)
    else
        Utils.Debug(MODULE_NAME, "Delay callback completed successfully")
    end
    return func()
end

-- Create highlight
function Utils:CreateHighlight(adornee, fillColor, fillTrans, outlineColor, outlineTrans)
    Utils.Debug(MODULE_NAME, "CreateHighlight called for:", adornee and adornee.Name or "nil")
    if not adornee then
        Utils.Warn(MODULE_NAME, "CreateHighlight - adornee is nil")
        return nil
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = adornee
    highlight.FillColor = fillColor
    highlight.FillTransparency = fillTrans or 0.4
    highlight.OutlineColor = outlineColor
    highlight.OutlineTransparency = outlineTrans or 0.8
    highlight.Parent = adornee
    Utils.Debug(MODULE_NAME, "CreateHighlight - highlight created for:", adornee.Name)
    return highlight
end

-- Create billboard
function Utils:CreateBillboard(adornee, size, offset)
    Utils.Debug(MODULE_NAME, "CreateBillboard called for:", adornee and adornee.Name or "nil")
    if not adornee then
        Utils.Warn(MODULE_NAME, "CreateBillboard - adornee is nil")
        return nil
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = size or UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    Utils.Debug(MODULE_NAME, "CreateBillboard - billboard created for:", adornee.Name)
    return billboard
end

-- Find all crates
function Utils:FindAllCrates()
    Utils.Debug(MODULE_NAME, "FindAllCrates called")
    local crates = {}
    local Workspace = game:GetService("Workspace")
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then 
        Utils.Warn(MODULE_NAME, "FindAllCrates - Map folder not found")
        return crates 
    end
    local cratesFolder = mapFolder:FindFirstChild("Crates")
    if not cratesFolder then 
        Utils.Warn(MODULE_NAME, "FindAllCrates - Crates folder not found")
        return crates 
    end
    for _, child in ipairs(cratesFolder:GetChildren()) do
        if child.Name == "Default" and child:IsA("Model") then
            table.insert(crates, child)
        end
    end
    Utils.Debug(MODULE_NAME, "FindAllCrates - found", #crates, "crates")
    return crates
end

-- Get crate main part
function Utils:GetCrateMainPart(crate)
    Utils.Debug(MODULE_NAME, "GetCrateMainPart called for:", crate and crate.Name or "nil")
    if not crate then
        Utils.Warn(MODULE_NAME, "GetCrateMainPart - crate is nil")
        return nil
    end
    if crate.PrimaryPart then 
        Utils.Debug(MODULE_NAME, "GetCrateMainPart - using PrimaryPart:", crate.PrimaryPart.Name)
        return crate.PrimaryPart 
    end
    local possibleParts = {"Lid", "Handle", "Handles", "Base", "Body", "CratePart"}
    for _, partName in ipairs(possibleParts) do
        local part = crate:FindFirstChild(partName)
        if part and part:IsA("BasePart") then 
            Utils.Debug(MODULE_NAME, "GetCrateMainPart - found part:", partName)
            return part 
        end
    end
    for _, child in ipairs(crate:GetChildren()) do
        if child:IsA("BasePart") then 
            Utils.Debug(MODULE_NAME, "GetCrateMainPart - found fallback BasePart:", child.Name)
            return child 
        end
    end
    Utils.Warn(MODULE_NAME, "GetCrateMainPart - no suitable part found for crate:", crate.Name)
    return nil
end

Utils.Debug(MODULE_NAME, "Utilities module loaded successfully")

return Utils
