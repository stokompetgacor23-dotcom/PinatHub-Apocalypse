-- =======================================================
-- PINATHUB - BRING MODULE (REMOVED PER USER INSTRUCTION)
-- Note: Dropped items have server-side network ownership;
-- client-side bring teleports cause desync / rubberbanding.
-- Please use Auto Pickup with DragRange bypass instead.
-- =======================================================

local Bring = {}

function Bring:Start()
    print("[BRING] Deprecated - Use Auto Pickup with DragRange bypass instead.")
end

function Bring:Stop()
end

function Bring:Init()
    return self
end

return Bring
