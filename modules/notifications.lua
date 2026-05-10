-- =======================================================
-- PINATHUB - NOTIFICATIONS MODULE
-- =======================================================

local Notifications = {}

function Notifications:Show(title, message, duration)
    if self.Window then
        pcall(function()
            self.Window:Notify(title, message, duration or 3)
        end)
    else
        print(string.format("[%s] %s", title, message))
    end
end

function Notifications:SetWindow(window)
    self.Window = window
end

function Notifications:Init(deps)
    return self
end

return Notifications
