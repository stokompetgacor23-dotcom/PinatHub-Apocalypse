local BASE = "https://raw.githubusercontent.com/stokompetgacor23-dotcom/PinatHub-Apocalypse/main/modules/"

local Modules = {}

-- =======================================================
-- SAFE LOAD MODULE
-- =======================================================

local function Load(name)
    local url = BASE .. name .. ".lua"
    
    local ok, result = pcall(function()
        local src
        -- Try with cache-buster timestamp to prevent stale GitHub Raw CDN caching
        local getOk = pcall(function()
            src = game:HttpGet(url .. "?v=" .. tostring(os.time()))
        end)
        
        if not getOk or not src or #src == 0 then
            src = game:HttpGet(url)
        end
        
        if not src or #src == 0 then
            error("Empty response received for: " .. name)
        end
        
        if src:sub(1, 14) == "404: Not Found" then
            error("404 Not Found on GitHub for: " .. name)
        end
        
        local fn, compileErr = loadstring(src, name)
        if not fn then
            fn, compileErr = loadstring(src)
        end
        
        if not fn then
            error("Syntax/Compile error in [" .. name .. "]: " .. tostring(compileErr))
        end
        
        local modResult = fn()
        if modResult == nil then
            error("Module [" .. name .. "] executed but returned nil")
        end
        return modResult
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
Load("teleport")
Load("player")
Load("autoPickup")
Load("killaura")
Load("weaponMods")
Load("fakeClass")

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
InitModule("teleport")
InitModule("player")
InitModule("autoPickup")
InitModule("killaura")
InitModule("weaponMods")
InitModule("fakeClass")

-- UI init terakhir (karena butuh semua module)
InitModule("ui")

-- =======================================================
-- STATUS REPORT
-- =======================================================

print("PinatHub Loaded!")
