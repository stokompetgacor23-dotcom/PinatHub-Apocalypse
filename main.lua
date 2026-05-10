local BASE = "https://raw.githubusercontent.com/stokompetgacor23-dotcom/PinatHub-Apocalypse/main/modules/"

local Modules = {}
local initialized = {}

-- =======================================================
-- SAFE LOAD MODULE
-- =======================================================

local function Load(name)
    local url = BASE .. name .. ".lua"

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if ok and result then
        Modules[name] = result
        Modules[name:sub(1,1):upper() .. name:sub(2)] = result
    else
        warn("[PinatHub] Failed loading:", name)
    end
end

-- =======================================================
-- SAFE INIT MODULE
-- =======================================================

local function InitModule(name)
    local mod = Modules[name]

    if not mod or initialized[name] then
        return
    end

    initialized[name] = true

    if type(mod) == "table" and type(mod.Init) == "function" then
        local ok, err = pcall(function()
            mod:Init(Modules)
        end)

        if not ok then
            warn("[PinatHub] Init failed:", name)
            warn(err)
        end
    end
end

-- =======================================================
-- LOAD ORDER
-- =======================================================

-- Core
Load("config")
Load("utils")
Load("network")
Load("notifications")

-- UI
Load("ui")

-- Features
Load("esp")
Load("farm")
Load("bring")
Load("teleport")
Load("player")
Load("autoPickup")

-- =======================================================
-- INIT ORDER
-- =======================================================

-- Core
InitModule("config")
InitModule("utils")
InitModule("network")
InitModule("notifications")

-- Features
InitModule("esp")
InitModule("farm")
InitModule("bring")
InitModule("teleport")
InitModule("player")
InitModule("autoPickup")

-- UI terakhir
InitModule("ui")

-- =======================================================
-- FINAL STATUS
-- =======================================================

local total = 0

for _ in pairs(initialized) do
    total += 1
end

print(string.format("[PinatHub] Loaded successfully (%d modules)", total))
