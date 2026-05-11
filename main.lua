local BASE = "https://raw.githubusercontent.com/stokompetgacor23-dotcom/PinatHub-Apocalypse/main/modules/"

local Modules = {}

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
        local upper = name:sub(1,1):upper() .. name:sub(2)
        Modules[upper] = result
        print("✓ loaded:", name)
    else
        warn("✗ failed to load:", name)
        warn(result)
    end
end

-- =======================================================
-- LOAD ORDER IMPORTANT
-- =======================================================

print("=========================================")
print("PinatHub - Loading Modules...")
print("=========================================")

-- Core modules (harus pertama)
Load("config")
Load("utils")
Load("network")
Load("notifications")

-- UI module (load setelah core)
Load("ui")

-- Feature modules
Load("esp")
Load("farm")
Load("bring")
Load("teleport")
Load("player")
Load("autoPickup")
Load("killaura")  -- <-- TAMBAHKAN KILLAURA MODULE

-- =======================================================
-- SAFE INIT
-- =======================================================

local initialized = {}

local function InitModule(name)
    local mod = Modules[name]
    if not mod then 
        print("⚠ Module not found:", name)
        return 
    end
    if initialized[name] then 
        return 
    end
    initialized[name] = true
    
    if type(mod) == "table" and type(mod.Init) == "function" then
        local ok, err = pcall(function()
            mod:Init(Modules)
        end)
        if ok then
            print("✓ initialized:", name)
        else
            warn("✗ init failed:", name)
            warn(err)
        end
    else
        print("⚠ module has no Init function:", name)
    end
end

-- =======================================================
-- INIT ORDER IMPORTANT
-- =======================================================

print("")
print("Initializing modules...")
print("")

-- Core modules init (harus pertama)
InitModule("config")
InitModule("utils")
InitModule("network")
InitModule("notifications")

-- Feature modules init (inisialisasi sebelum UI)
InitModule("esp")
InitModule("farm")
InitModule("bring")
InitModule("teleport")
InitModule("player")
InitModule("autoPickup")
InitModule("killaura")  -- <-- TAMBAHKAN INIT KILLAURA

-- UI init terakhir (karena butuh semua module)
InitModule("ui")

-- =======================================================
-- STATUS REPORT
-- =======================================================

print("PinatHub Loaded!")
