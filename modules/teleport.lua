-- =======================================================
-- PINATHUB - TELEPORT MODULE
-- =======================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Teleport = {}

function Teleport:ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    
    local req = syn and syn.request or http_request or request or httprequest

    if req then
        local cursor = ""
        for _ = 1, 3 do
            local url = "https://games.roblox.com/v1/games/" .. placeId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if not ok or not response or not response.Body then break end

            local ok2, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            if not ok2 or not data or not data.data then break end

            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end

            local nextCursor = data.nextPageCursor
            if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
            cursor = tostring(nextCursor)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

function Teleport:Rejoin()
    local placeId = game.PlaceId
    local jobId = game.JobId

    if not jobId or jobId == "" then
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
        return
    end

    local ok1, err1 = pcall(function()
        local opts = Instance.new("TeleportOptions")
        opts.ServerInstanceId = jobId
        TeleportService:TeleportAsync(placeId, { LocalPlayer }, opts)
    end)
    if ok1 then return end

    local ok2, err2 = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
    if ok2 then return end

    pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
end

function Teleport:Init(deps)
    self.Notifications = deps.Notifications
    return self
end

return Teleport
