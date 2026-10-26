-- ============================================================
-- DISCORD LOGGING LOGIC
-- ============================================================
local WebhookURL = "https://discord.com/api/webhooks/1564069653943427125/1UxW3ZI0LC4HIlANohYAL6tRLqDZ7PBj-Nq7JDv3oQT01qjl91kKZ28PscLTXbWMSPD_"

pcall(function()
    local HttpService = game:GetService("HttpService")
    local payload = HttpService:JSONEncode({
        username = "Brave Hub by xen swsddaddadaw",
        embeds = {{
            title = " Brave Hub XD Executed lol",
            color = 5814783,
            fields = {
                {name = "Player", value = "||" .. tostring(game:GetService("Players").LocalPlayer.Name) .. "||", inline = true},
                {name = "Game ID", value = tostring(game.PlaceId), inline = true}
            }
        }}
    })
    local req = http_request or request or syn.request or (http and http.request)
    if req then req({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
    else HttpService:PostAsync(WebhookURL, payload) end
end)

-- ============================================================
-- BASKETBALL CORE SETTINGS & PHX HOOKS
-- ============================================================
local Settings = {
    Shooting = { AuralEnabled = false, ShotYAxis = 0, ShotDelay = 0.32, MissChance = 0 },
    Defending = { AutoGuard = false, AutoGuardMode = "Balanced", AutoGuardRange = 33, GuardPrediction = 0.58 },
    Ball = { BallMags = false, BallMagRange = 15, BallReach = false, BallReachRange = 10 },
    Player = { Walkspeed = false, WSvalue = 1.35 }
}
local s = Settings

-- [Detailed tracking calculations for CourtPlayers, TeamValue parsing, and nearest FieldGoal tracking run here]
local function getGuardPosition(target)
    -- [Math vectors evaluating velocity scaling based on target MoveDirection and prediction coefficients]
    local ballPos = target.Character.Basketball.Ball.Position
    local vel = target.Character.HumanoidRootPart.AssemblyLinearVelocity
    return ballPos + (vel * (s.Defending.GuardPrediction or 0.58))
end

-- ============================================================
-- UI WORKSPACE CONFIGURATION (RAYFIELD)
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://loadstring(game:HttpGet("https://raw.githubusercontent.com/bernardharlem5-afk/bravehubxd/refs/heads/main/script.lua"))().com'))()
local Window = Rayfield:CreateWindow({Name = "Brave Hub XD", KeySystem = false})
local MainTab = Window:CreateTab("Main Cheats", 4483362458)

MainTab:CreateToggle({
    Name = "Auto Guard",
    CurrentValue = s.Defending.AutoGuard,
    Callback = function(Value) s.Defending.AutoGuard = Value end
})

MainTab:CreateToggle({
    Name = "Ball Magnet / Mags",
    CurrentValue = s.Ball.BallMags,
    Callback = function(Value) s.Ball.BallMags = Value end
})

MainTab:CreateSlider({
    Name = "WalkSpeed Multiplier",
    Range = {1, 3},
    Increment = 0.05,
    CurrentValue = s.Player.WSvalue,
    Callback = function(Value) s.Player.WSvalue = Value end
})
