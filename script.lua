-- NEXOURA HUB — Arcade Basketball + Basketball Legends + Hoopz
-- ============================================================

local _print, _warn = print, warn
print = function() end
warn = function() end

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/bernardharlem5-afk/bravehubx/refs/heads/main/script.lua"))()

-- ============================================================
-- GAME ID WHITELIST (Arcade Basketball)
-- ============================================================
local ARCADE_IDS = {
    [134558434771720] = true,
    [130736793665498] = true,
    [92216849541624]  = true,
    [95439417741900]  = true,
}

-- ============================================================
-- GAME ID WHITELIST (Basketball Legends)
-- ============================================================
local BL_IDS = {
    [14386691987]    = true,
    [71832465156084] = true,
    [17652855195]    = true,
}

local isArcade = ARCADE_IDS[game.PlaceId] == true
local isBL     = BL_IDS[game.PlaceId] == true

-- ============================================================
-- SHARED THEME
-- ============================================================
Rayfield:AddTheme({
    Name = "Fatal Labs",
    CornerRoundness = UDim.new(0, 12),
    ElementCornerRadius = UDim.new(0, 8),
    PillCornerRadius = UDim.new(1, 0),
    WindowColor = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 16)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 20)),
        ColorSequenceKeypoint.new(0.9999, Color3.fromRGB(22, 22, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 26, 28)),
    }),
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ElementGradient = Color3.fromRGB(26, 26, 28),
    ElementStroke = Color3.fromRGB(70, 60, 90),
    ElementStrokeGradient = Color3.fromRGB(90, 78, 115),
    ElementStrokeHover = Color3.fromRGB(180, 160, 220),
    ElementTransparency = 0,
    ElementStrokeTransparency = 0,
    ElementStrokeHoverTransparency = 0,
    ElementTextHoverColor = Color3.fromRGB(240, 230, 255),
    TabColor = Color3.fromRGB(215, 200, 240),
    TabBackground = Color3.fromRGB(22, 22, 24),
    TabStroke = Color3.fromRGB(150, 130, 190),
    SliderBackground = Color3.fromRGB(40, 40, 44),
    SliderBackgroundHover = Color3.fromRGB(52, 48, 60),
    SliderProgress = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 160, 230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 190, 255)),
    }),
    SliderStroke = Color3.fromRGB(140, 120, 180),
    SliderHandle = Color3.fromRGB(200, 180, 245),
    ToggleTrack = Color3.fromRGB(190, 165, 240),
    ToggleTrackTransparency = 0.15,
    ToggleKnobOff = Color3.fromRGB(110, 100, 130),
    ToggleKnobOffTransparency = 0.2,
    DarkToggleOverlay = false,
    FieldBackground = Color3.fromRGB(45, 40, 60),
    FieldTransparency = 0.35,
    FieldGlow = Color3.fromRGB(190, 165, 240),
    PlaceholderColor = Color3.fromRGB(160, 145, 190),
    SurfaceStroke = Color3.fromRGB(100, 88, 130),
    NeutralButton = Color3.fromRGB(32, 30, 40),
    NeutralButtonHover = Color3.fromRGB(48, 44, 62),
    NeutralButtonStroke = Color3.fromRGB(140, 120, 180),
    ContentColor = Color3.fromRGB(210, 200, 225),
    TitlingColor = Color3.fromRGB(245, 240, 255),
    ActionColor = Color3.fromRGB(190, 165, 240),
    AccentColor = Color3.fromRGB(205, 180, 250),
    AccentStroke = Color3.fromRGB(220, 200, 255),
    AccentGlow = 0.45,
    StatBackground = Color3.fromRGB(20, 20, 22),
    DropdownHighlight = Color3.fromRGB(140, 120, 180),
    ErrorColor = Color3.fromRGB(200, 60, 60),
    ErrorStrokeColor = Color3.fromRGB(255, 90, 90),
    Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    TitleFont = Font.new("rbxasset://fonts/families/Lobster.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    LiveAnimation = true,
})

-- ============================================================
-- SHARED SERVICES
-- ============================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local VirtualInput        = game:GetService("VirtualInputManager")
local SharedTableRegistry = game:GetService("SharedTableRegistry")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local isMobile    = UserInputService.TouchEnabled

-- ============================================================
-- BRANCH: ARCADE BASKETBALL
-- ============================================================
if isArcade then
    local Settings = {
        Shooting = {
            AutoGreen = false,
            AutoGreenKeybind = Enum.KeyCode.E,
            AutoGreenOnShootButton = true,
        },
        Player = { Walkspeed = false, WSvalue = 1.35, SpeedKeybind = Enum.KeyCode.RightShift },
        AntiContest = {
            Enabled = false,
            Keybind = Enum.KeyCode.E,
            Height = 25,
        },
        BallSize = {
            Enabled = false,
            Size = 6,
            Transparency = 0.5,
        },
    }
    local s = Settings

    local Cleanup = { conns = {} }
    local function Track(c)
        if c then table.insert(Cleanup.conns, c) end
        return c
    end

    local ShootRemote = nil
    local function resolveShootRemote()
        if ShootRemote and ShootRemote.Parent then return ShootRemote end
        pcall(function()
            local Events = ReplicatedStorage:FindFirstChild("Events")
            ShootRemote = Events and Events:FindFirstChild("Shoot")
        end)
        return ShootRemote
    end

    local function fireAutoGreen()
        local remote = resolveShootRemote()
        if not remote then return false end
        local ok = pcall(function()
            remote:FireServer(table.unpack({ true, 100, false }))
        end)
        pcall(function()
            remote:FireServer(table.unpack({ false, -1, true }))
        end)
        return ok
    end

    local greenLock = false
    local function fireAutoGreenSafe()
        if greenLock then return end
        greenLock = true
        fireAutoGreen()
        task.delay(0.15, function() greenLock = false end)
    end

    local speedConnection = nil
    local function enableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        speedConnection = RunService.Heartbeat:Connect(function()
            if not s.Player.Walkspeed then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0.05 then
                local mult = math.clamp(s.Player.WSvalue or 1.35, 1, 3)
                local targetVel = moveDir.Unit * (16 * mult)
                local y = hrp.AssemblyLinearVelocity.Y
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, y, targetVel.Z)
            end
        end)
        Track(speedConnection)
    end
    local function disableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    end

    local ballResizeConn = nil
    local trackedBalls = {}
    local origData     = {}

    local function isBallPart(inst)
        if not inst:IsA("BasePart") then return false end
        local n = string.lower(inst.Name)
        return n:find("ball", 1, true) ~= nil
    end

    local function addTrackedBall(inst)
        if not isBallPart(inst) then return end
        if trackedBalls[inst] then return end
        trackedBalls[inst] = true
        origData[inst] = {
            Size = inst.Size,
            Transparency = inst.Transparency,
        }
        if s.BallSize.Enabled then
            local size = tonumber(s.BallSize.Size) or 6
            local trans = tonumber(s.BallSize.Transparency) or 0.5
            pcall(function()
                inst.Size = Vector3.new(size, size, size)
                inst.Transparency = trans
            end)
        end
    end

    local function removeTrackedBall(inst)
        if trackedBalls[inst] then
            trackedBalls[inst] = nil
            origData[inst] = nil
        end
    end

    local function scanExistingBalls()
        for _, inst in ipairs(workspace:GetDescendants()) do
            addTrackedBall(inst)
        end
    end

    local function applyBallSize()
        local size = tonumber(s.BallSize.Size) or 6
        local trans = tonumber(s.BallSize.Transparency) or 0.5
        for part in pairs(trackedBalls) do
            if part and part.Parent then
                pcall(function()
                    part.Size = Vector3.new(size, size, size)
                    part.Transparency = trans
                end)
            else
                removeTrackedBall(part)
            end
        end
    end

    local function restoreBallSize()
        for part, data in pairs(origData) do
            if part and part.Parent then
                pcall(function()
                    part.Size = data.Size
                    part.Transparency = data.Transparency
                end)
            end
        end
        table.clear(origData)
        table.clear(trackedBalls)
    end

    local ballAddedConn, ballRemovedConn = nil, nil

    local function enableBallResizer()
        scanExistingBalls()
        ballAddedConn = workspace.DescendantAdded:Connect(function(inst)
            if isBallPart(inst) then
                task.defer(function()
                    addTrackedBall(inst)
                end)
            end
        end)
        ballRemovedConn = workspace.DescendantRemoving:Connect(function(inst)
            if isBallPart(inst) then
                removeTrackedBall(inst)
            end
        end)
        applyBallSize()

        if ballResizeConn then ballResizeConn:Disconnect() end
        ballResizeConn = RunService.Heartbeat:Connect(function()
            if not s.BallSize.Enabled then return end
            applyBallSize()
        end)
        Track(ballResizeConn)
    end

    local function disableBallResizer()
        if ballAddedConn then ballAddedConn:Disconnect(); ballAddedConn = nil end
        if ballRemovedConn then ballRemovedConn:Disconnect(); ballRemovedConn = nil end
        if ballResizeConn then ballResizeConn:Disconnect(); ballResizeConn = nil end
        restoreBallSize()
    end

    local antiContestLock = false
    local function doAntiContest()
        if antiContestLock then return end
        antiContestLock = true
        task.delay(0.1, function() antiContestLock = false end)

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local height = tonumber(s.AntiContest.Height) or 25
        hrp.CFrame = hrp.CFrame + Vector3.new(0, height, 0)
    end

    local Window = Rayfield:CreateWindow({
        name = "Nexoura Hub",
        subtitle = "Arcade Basketball suite",
        size = UDim2.fromOffset(420, 340),
        font = Enum.Font.Gotham,
        icon = 135101778515904,
        sidebarLayout = true,
        inlineDescription = true,
        theme = "Fatal Labs",
        userInfo = {
            Title = LocalPlayer.DisplayName,
            Subtitle = "@" .. LocalPlayer.Name,
            Icons = 135101778515904,
        },
        openButton = isMobile and {
            Title = "Nexoura Hub",
            Subtitle = "tap to open",
            Icons = 135101778515904,
        } or nil,
        configuration = {
            autoSave = true,
            autoLoad = false,
            fileName = "FatalLabsArcade",
        },
    })

    pcall(function()
        if Rayfield.SetTheme then Rayfield:SetTheme("Nexoura Hub") end
    end)

    local Notify = function(props)
        pcall(function() Window:Notify(props) end)
    end

    local CombatTab = Window:CreateTab({ name = "Combat", icon = "swords" })
    local BallTab = Window:CreateTab({ name = "Ball", icon = "circle" })
    local MovementTab = Window:CreateTab({ name = "Movement", icon = "move" })

    CombatTab:CreateSection({ name = "Auto Green" })
    CombatTab:CreateToggle({
        name = "Auto Green",
        description = "Fires Events.Shoot with the perfect-shot sequence.",
        flag = "ab_autogreen",
        value = s.Shooting.AutoGreen,
        callback = function(v) s.Shooting.AutoGreen = v end,
    })
    CombatTab:CreateKeybind({
        name = "Auto Green keybind",
        description = "Hold then RELEASE this key to fire a green shot.",
        flag = "ab_autogreen_key",
        value = s.Shooting.AutoGreenKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Shooting.AutoGreenKeybind = key end
        end,
    })
    CombatTab:CreateToggle({
        name = "Auto Green on Shoot button",
        description = "Fires the remote INSTANTLY when you RELEASE the in-game Shoot button.",
        flag = "ab_autogreen_btn",
        value = s.Shooting.AutoGreenOnShootButton,
        callback = function(v) s.Shooting.AutoGreenOnShootButton = v end,
    })
    CombatTab:CreateButton({
        name = "Fire Green Now",
        callback = function()
            if fireAutoGreen() then
                Notify({ title = "Auto Green", content = "Shot fired.", duration = 2 })
            else
                Notify({ title = "Auto Green", content = "Remote not found.", duration = 3 })
            end
        end,
    })

    CombatTab:CreateSection({ name = "Anti Contest" })
    CombatTab:CreateToggle({
        name = "Anti Contest",
        description = "Press E to teleport straight up (dodges contests).",
        flag = "ab_ac",
        value = s.AntiContest.Enabled,
        callback = function(v) s.AntiContest.Enabled = v end,
    })
    CombatTab:CreateKeybind({
        name = "Anti Contest keybind",
        description = "Press this key to jump straight up.",
        flag = "ab_ac_key",
        value = s.AntiContest.Keybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.AntiContest.Keybind = key end
        end,
    })
    CombatTab:CreateSlider({
        name = "Anti Contest height",
        range = { 1, 25 }, increment = 1, suffix = " studs",
        value = s.AntiContest.Height, flag = "ab_ac_h",
        callback = function(v) s.AntiContest.Height = v end,
    })

    BallTab:CreateSection({ name = "Ball Resizer" })
    BallTab:CreateToggle({
        name = "Ball Resizer",
        description = "Scales every ball part and sets its transparency to 0.5.",
        flag = "ab_ballsize",
        value = s.BallSize.Enabled,
        callback = function(v)
            s.BallSize.Enabled = v
            if v then enableBallResizer() else disableBallResizer() end
        end,
    })
    BallTab:CreateSlider({
        name = "Ball size",
        range = { 1, 12 }, increment = 1, suffix = " studs",
        value = s.BallSize.Size, flag = "ab_ballsize_val",
        callback = function(v)
            s.BallSize.Size = v
            if s.BallSize.Enabled then applyBallSize() end
        end,
    })

    MovementTab:CreateSection({ name = "Speed" })
    MovementTab:CreateToggle({
        name = "Speed boost",
        flag = "ab_ws",
        value = s.Player.Walkspeed,
        callback = function(v)
            s.Player.Walkspeed = v
            if v then enableSpeedBoost() else disableSpeedBoost() end
        end,
    })
    MovementTab:CreateKeybind({
        name = "Speed keybind",
        flag = "ab_ws_key",
        value = s.Player.SpeedKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Player.SpeedKeybind = key end
        end,
    })
    MovementTab:CreateSlider({
        name = "Speed multiplier",
        range = { 1, 3 }, increment = 0.05,
        value = s.Player.WSvalue, flag = "ab_ws_val",
        callback = function(v) s.Player.WSvalue = v end,
    })

    do
        local hookedButtons = {}
        local pressedButtons = {}

        local function matchesShoot(inst)
            if not (inst:IsA("GuiButton") or inst:IsA("ImageButton")) then
                return false
            end
            local n = string.lower(inst.Name)
            if n == "shoot" or n:find("shoot", 1, true) then return true end
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    local t = string.lower(d.Text or "")
                    if t:find("shoot", 1, true) then return true end
                end
            end
            return false
        end

        local function onPress(inst)
            if not s.Shooting.AutoGreen then return end
            if not s.Shooting.AutoGreenOnShootButton then return end
            pressedButtons[inst] = true
        end

        local function onRelease(inst)
            if not s.Shooting.AutoGreen then return end
            if not s.Shooting.AutoGreenOnShootButton then return end
            if not pressedButtons[inst] then return end
            pressedButtons[inst] = nil
            fireAutoGreenSafe()
        end

        local function tryHook(inst)
            if hookedButtons[inst] then return end
            if not matchesShoot(inst) then return end
            hookedButtons[inst] = true

            Track(inst.MouseButton1Down:Connect(function() onPress(inst) end))
            Track(inst.MouseButton1Up:Connect(function() onRelease(inst) end))

            Track(inst.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onPress(inst)
                end
            end))
            Track(inst.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onRelease(inst)
                end
            end))

            Track(inst.MouseLeave:Connect(function()
                if pressedButtons[inst] then onRelease(inst) end
            end))
        end

        local function scanAndHook(root)
            if not root then return end
            for _, inst in ipairs(root:GetDescendants()) do
                tryHook(inst)
            end
        end

        local function watchRoot(root)
            if not root then return end
            Track(root.DescendantAdded:Connect(function(inst)
                task.wait(0.05)
                tryHook(inst)
            end))
        end

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            scanAndHook(pg)
            watchRoot(pg)
        end
        Track(LocalPlayer.ChildAdded:Connect(function(child)
            if child.Name == "PlayerGui" then
                task.wait(0.5)
                scanAndHook(child)
                watchRoot(child)
            end
        end))

        scanAndHook(workspace)
        watchRoot(workspace)

        Track(LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            scanAndHook(char)
            watchRoot(char)
        end))

        pcall(function()
            scanAndHook(CoreGui)
            watchRoot(CoreGui)
        end)
    end

    local eWasHeld = false

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        local greenBind = s.Shooting.AutoGreenKeybind
        local greenKey = (type(greenBind) == "string") and Enum.KeyCode[greenBind] or greenBind
        if input.KeyCode == greenKey then
            if s.Shooting.AutoGreen then
                eWasHeld = true
            end
            if s.AntiContest.Enabled then
                local acBind = s.AntiContest.Keybind
                local acKey = (type(acBind) == "string") and Enum.KeyCode[acBind] or acBind
                if input.KeyCode == acKey then
                    doAntiContest()
                end
            end
            return
        end

        local acBind = s.AntiContest.Keybind
        local acKey = (type(acBind) == "string") and Enum.KeyCode[acBind] or acBind
        if input.KeyCode == acKey and s.AntiContest.Enabled then
            doAntiContest()
            return
        end

        local speedBind = s.Player.SpeedKeybind
        local speedKey = (type(speedBind) == "string") and Enum.KeyCode[speedBind] or speedBind
        if input.KeyCode == speedKey then
            s.Player.Walkspeed = not s.Player.Walkspeed
            if s.Player.Walkspeed then enableSpeedBoost() else disableSpeedBoost() end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end

        local greenBind = s.Shooting.AutoGreenKeybind
        local greenKey = (type(greenBind) == "string") and Enum.KeyCode[greenBind] or greenBind
        if input.KeyCode == greenKey and eWasHeld then
            eWasHeld = false
            if not s.Shooting.AutoGreen then return end
            fireAutoGreenSafe()
        end
    end)

    local function cleanup()
        pcall(disableSpeedBoost)
        pcall(disableBallResizer)
        for _, c in Cleanup.conns do pcall(function() c:Disconnect() end) end
    end
    Track(LocalPlayer.AncestryChanged:Connect(function()
        if not LocalPlayer.Parent then cleanup() end
    end))

-- ============================================================
-- BRANCH: BASKETBALL LEGENDS
-- ============================================================
elseif isBL then
    local Settings = {
        Shooting = {
            AutoGreen = false,
            AutoGreenKeybind = Enum.KeyCode.E,
            AutoGreenOnJump = false,
            AutoGreenOnShootButton = true,
        },
        Player = { Walkspeed = false, WSvalue = 1.35, SpeedKeybind = Enum.KeyCode.RightShift },
        Mag = {
            Enabled = false,
            BallName = "Ball",
            Reach = 20,
            Keybind = Enum.KeyCode.L,
        },
    }
    local s = Settings

    local Cleanup = { conns = {} }
    local function Track(c)
        if c then table.insert(Cleanup.conns, c) end
        return c
    end

    local ShootRemote = nil
    local function resolveShootRemote()
        if ShootRemote and ShootRemote.Parent then return ShootRemote end
        pcall(function()
            local Packages = ReplicatedStorage:FindFirstChild("Packages")
            local Knit = Packages and Packages:FindFirstChild("Knit")
            local Services = Knit and Knit:FindFirstChild("Services")
            local ControlService = Services and Services:FindFirstChild("ControlService")
            local RE = ControlService and ControlService:FindFirstChild("RE")
            ShootRemote = RE and RE:FindFirstChild("Shoot")
        end)
        return ShootRemote
    end

    local function fireAutoGreen()
        local remote = resolveShootRemote()
        if remote then
            local ok = pcall(function() remote:FireServer(1) end)
            return ok
        end
        return false
    end

    local greenLock = false
    local function fireAutoGreenSafe()
        if greenLock then return end
        greenLock = true
        fireAutoGreen()
        task.delay(0.15, function() greenLock = false end)
    end

    local speedConnection = nil
    local function enableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        speedConnection = RunService.Heartbeat:Connect(function()
            if not s.Player.Walkspeed then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0.05 then
                local mult = math.clamp(s.Player.WSvalue or 1.35, 1, 3)
                local targetVel = moveDir.Unit * (16 * mult)
                local y = hrp.AssemblyLinearVelocity.Y
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, y, targetVel.Z)
            end
        end)
        Track(speedConnection)
    end
    local function disableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    end

    -- FAST MAG (cached, rebuilt every 0.5s, cheap per-frame)
    local magConnection = nil
    local magRefreshThread = nil
    local magCache = {}

    local function rebuildMagCache()
        table.clear(magCache)
        local targetName = s.Mag.BallName
        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("BasePart") and inst.Name == targetName then
                local hasTouch = inst:FindFirstChildWhichIsA("TouchTransmitter")
                    or inst:FindFirstChild("TouchInterest")
                if hasTouch then
                    magCache[#magCache + 1] = inst
                end
            end
        end
    end

    local function magTick()
        if not s.Mag.Enabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        if character:FindFirstChild("Basketball") then return end

        local touchPart = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("RightFoot")
            or character:FindFirstChild("Head")
        if not touchPart then return end

        local reach = tonumber(s.Mag.Reach) or 20
        local reachSq = reach * reach
        local origin = touchPart.Position

        for i = #magCache, 1, -1 do
            local part = magCache[i]
            if not part or not part.Parent then
                table.remove(magCache, i)
            else
                local d = origin - part.Position
                if (d.X*d.X + d.Y*d.Y + d.Z*d.Z) <= reachSq then
                    pcall(function()
                        firetouchinterest(touchPart, part, 0)
                        firetouchinterest(touchPart, part, 1)
                    end)
                    if part.Anchored == false then
                        part.AssemblyLinearVelocity = (touchPart.Position - part.Position) * 30
                    end
                end
            end
        end
    end

    local function enableMag()
        if magConnection then magConnection:Disconnect(); magConnection = nil end
        if magRefreshThread then task.cancel(magRefreshThread); magRefreshThread = nil end

        rebuildMagCache()

        magRefreshThread = task.spawn(function()
            while s.Mag.Enabled do
                task.wait(0.5)
                if s.Mag.Enabled then
                    rebuildMagCache()
                end
            end
        end)

        magConnection = RunService.Heartbeat:Connect(function()
            pcall(magTick)
        end)
        Track(magConnection)
    end

    local function disableMag()
        if magConnection then magConnection:Disconnect(); magConnection = nil end
        if magRefreshThread then task.cancel(magRefreshThread); magRefreshThread = nil end
        table.clear(magCache)
    end

    local Window = Rayfield:CreateWindow({
        name = "Nexoura Hub",
        subtitle = "BL suite",
        size = UDim2.fromOffset(420, 320),
        font = Enum.Font.Gotham,
        icon = 135101778515904,
        sidebarLayout = true,
        inlineDescription = true,
        theme = "Nexoura Hub",
        userInfo = {
            Title = LocalPlayer.DisplayName,
            Subtitle = "@" .. LocalPlayer.Name,
            Icons = 135101778515904,
        },
        openButton = isMobile and {
            Title = "Nexoura Hub",
            Subtitle = "tap to open",
            Icons = 135101778515904,
        } or nil,
        configuration = {
            autoSave = true,
            autoLoad = false,
            fileName = "FatalLabsBL",
        },
    })

    pcall(function()
        if Rayfield.SetTheme then Rayfield:SetTheme("Fatal Labs") end
    end)

    local Notify = function(props)
        pcall(function() Window:Notify(props) end)
    end

    local CombatTab = Window:CreateTab({ name = "Combat", icon = "swords" })
    local BallTab = Window:CreateTab({ name = "Ball", icon = "circle" })
    local MovementTab = Window:CreateTab({ name = "Movement", icon = "move" })

    CombatTab:CreateSection({ name = "Auto Green" })
    CombatTab:CreateToggle({
        name = "Auto Green",
        description = "Fires ControlService.RE.Shoot with argument 1 (perfect shot).",
        flag = "bl_autogreen",
        value = s.Shooting.AutoGreen,
        callback = function(v)
            s.Shooting.AutoGreen = v
        end,
    })
    CombatTab:CreateKeybind({
        name = "Auto Green keybind",
        description = "Hold then RELEASE this key to fire a green shot.",
        flag = "bl_autogreen_key",
        value = s.Shooting.AutoGreenKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Shooting.AutoGreenKeybind = key end
        end,
    })
    CombatTab:CreateToggle({
        name = "Auto Green on Jump",
        description = "Fires the remote automatically after you jump-shot.",
        flag = "bl_autogreen_jump",
        value = s.Shooting.AutoGreenOnJump,
        callback = function(v) s.Shooting.AutoGreenOnJump = v end,
    })
    CombatTab:CreateToggle({
        name = "Auto Green on Shoot button",
        description = "Fires the remote INSTANTLY when you RELEASE the in-game Shoot button.",
        flag = "bl_autogreen_btn",
        value = s.Shooting.AutoGreenOnShootButton,
        callback = function(v) s.Shooting.AutoGreenOnShootButton = v end,
    })
    CombatTab:CreateButton({
        name = "Fire Green Now",
        callback = function()
            if fireAutoGreen() then
                Notify({ title = "Auto Green", content = "Shot fired.", duration = 2 })
            else
                Notify({ title = "Auto Green", content = "Remote not found.", duration = 3 })
            end
        end,
    })

    BallTab:CreateSection({ name = "Mag" })
    BallTab:CreateToggle({
        name = "Mag",
        description = "Fast cached magnet. Auto firetouchinterest on nearby balls.",
        flag = "bl_mag",
        value = s.Mag.Enabled,
        callback = function(v)
            s.Mag.Enabled = v
            if v then enableMag() else disableMag() end
        end,
    })
    BallTab:CreateKeybind({
        name = "Mag keybind",
        description = "Press this key to toggle Mag on/off.",
        flag = "bl_mag_key",
        value = s.Mag.Keybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Mag.Keybind = key end
        end,
    })
    BallTab:CreateInput({
        name = "Ball name",
        description = "Name of the part to magnet (default: Ball).",
        placeholder = "Ball",
        value = s.Mag.BallName,
        flag = "bl_mag_name",
        callback = function(text)
            if text ~= "" then
                s.Mag.BallName = text
                if s.Mag.Enabled then rebuildMagCache() end
            end
        end,
    })
    BallTab:CreateSlider({
        name = "Reach (studs)",
        range = { 1, 100 }, increment = 1,
        value = s.Mag.Reach, flag = "bl_mag_reach",
        callback = function(v) s.Mag.Reach = v end,
    })

    MovementTab:CreateSection({ name = "Speed" })
    MovementTab:CreateToggle({
        name = "Speed boost",
        flag = "bl_ws",
        value = s.Player.Walkspeed,
        callback = function(v)
            s.Player.Walkspeed = v
            if v then enableSpeedBoost() else disableSpeedBoost() end
        end,
    })
    MovementTab:CreateKeybind({
        name = "Speed keybind",
        flag = "bl_ws_key",
        value = s.Player.SpeedKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Player.SpeedKeybind = key end
        end,
    })
    MovementTab:CreateSlider({
        name = "Speed multiplier",
        range = { 1, 3 }, increment = 0.05,
        value = s.Player.WSvalue, flag = "bl_ws_val",
        callback = function(v) s.Player.WSvalue = v end,
    })

    local function setupAutoGreenChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end        Track(hum.Jumping:Connect(function(active)
            if not active then return end
            if not s.Shooting.AutoGreen then return end
            if not s.Shooting.AutoGreenOnJump then return end
            if not char:FindFirstChild("Basketball") then return end
            fireAutoGreenSafe()
        end))
    end
    if LocalPlayer.Character then setupAutoGreenChar(LocalPlayer.Character) end
    Track(LocalPlayer.CharacterAdded:Connect(setupAutoGreenChar))

    do
        local hookedButtons = {}
        local pressedButtons = {}

        local function matchesShoot(inst)
            if not (inst:IsA("GuiButton") or inst:IsA("ImageButton")) then
                return false
            end
            local n = string.lower(inst.Name)
            if n == "shoot" or n:find("shoot", 1, true) then return true end
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    local t = string.lower(d.Text or "")
                    if t:find("shoot", 1, true) then return true end
                end
            end
            return false
        end

        local function onPress(inst)
            if not s.Shooting.AutoGreen then return end
            if not s.Shooting.AutoGreenOnShootButton then return end
            pressedButtons[inst] = true
        end

        local function onRelease(inst)
            if not s.Shooting.AutoGreen then return end
            if not s.Shooting.AutoGreenOnShootButton then return end
            if not pressedButtons[inst] then return end
            pressedButtons[inst] = nil
            fireAutoGreenSafe()
        end

        local function tryHook(inst)
            if hookedButtons[inst] then return end
            if not matchesShoot(inst) then return end
            hookedButtons[inst] = true

            Track(inst.MouseButton1Down:Connect(function() onPress(inst) end))
            Track(inst.MouseButton1Up:Connect(function() onRelease(inst) end))

            Track(inst.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onPress(inst)
                end
            end))
            Track(inst.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onRelease(inst)
                end
            end))

            Track(inst.MouseLeave:Connect(function()
                if pressedButtons[inst] then onRelease(inst) end
            end))
        end

        local function scanAndHook(root)
            if not root then return end
            for _, inst in ipairs(root:GetDescendants()) do
                tryHook(inst)
            end
        end

        local function watchRoot(root)
            if not root then return end
            Track(root.DescendantAdded:Connect(function(inst)
                task.wait(0.05)
                tryHook(inst)
            end))
        end

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            scanAndHook(pg)
            watchRoot(pg)
        end
        Track(LocalPlayer.ChildAdded:Connect(function(child)
            if child.Name == "PlayerGui" then
                task.wait(0.5)
                scanAndHook(child)
                watchRoot(child)
            end
        end))

        scanAndHook(workspace)
        watchRoot(workspace)

        Track(LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            scanAndHook(char)
            watchRoot(char)
        end))

        pcall(function()
            scanAndHook(CoreGui)
            watchRoot(CoreGui)
        end)
    end

    local eWasHeld = false

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        local greenBind = s.Shooting.AutoGreenKeybind
        local greenKey = (type(greenBind) == "string") and Enum.KeyCode[greenBind] or greenBind
        if input.KeyCode == greenKey then
            if not s.Shooting.AutoGreen then return end
            eWasHeld = true
            return
        end

        local magBind = s.Mag.Keybind
        local magKey = (type(magBind) == "string") and Enum.KeyCode[magBind] or magBind
        if input.KeyCode == magKey then
            s.Mag.Enabled = not s.Mag.Enabled
            if s.Mag.Enabled then enableMag() else disableMag() end
            return
        end

        local speedBind = s.Player.SpeedKeybind
        local speedKey = (type(speedBind) == "string") and Enum.KeyCode[speedBind] or speedBind
        if input.KeyCode == speedKey then
            s.Player.Walkspeed = not s.Player.Walkspeed
            if s.Player.Walkspeed then enableSpeedBoost() else disableSpeedBoost() end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end

        local greenBind = s.Shooting.AutoGreenKeybind
        local greenKey = (type(greenBind) == "string") and Enum.KeyCode[greenBind] or greenBind
        if input.KeyCode == greenKey and eWasHeld then
            eWasHeld = false
            if not s.Shooting.AutoGreen then return end
            fireAutoGreenSafe()
        end
    end)

    local function cleanup()
        pcall(disableSpeedBoost)
        pcall(disableMag)
        for _, c in Cleanup.conns do pcall(function() c:Disconnect() end) end
    end
    Track(LocalPlayer.AncestryChanged:Connect(function()
        if not LocalPlayer.Parent then cleanup() end
    end))

-- ============================================================
-- BRANCH: HOOPZ
-- ============================================================
else
    local TweenService = game:GetService("TweenService")
    local HttpService  = game:GetService("HttpService")
    local DeviceEvent  = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("deviceEvent")

    local Settings = {
        Shooting = {
            AuralEnabled = false, AuralKeybind = Enum.KeyCode.X,
            ShotYAxis = 0, ShotDelay = 0.32, EBLHop = false,
            HumanizeAim = false, HumanizeStrength = 1.2, MissChance = 0,
            RandomizeShotDelay = false, ShotDelayMin = 0.25, ShotDelayMax = 0.38,
        },
        Defending = {
            AutoGuard = false, AutoGuardButton = false, AutoGuardNearest = false,
            AutoGuardMode = "Balanced", AutoGuardRange = 33, GuardPrediction = 0.58,
            GuardKeybind = Enum.KeyCode.K,
        },
        Ball = {
            BallMags = false, BallMagRange = 15, BallMagVisualizer = false, MagnetKeybind = "M",
            BallReach = false, BallReachRange = 10, BallReachVisualizer = false, ReachKeybind = "N",
        },
        MagV2 = {
            Enabled = false, BallName = "Ball", Reach = 20, Keybind = Enum.KeyCode.U,
        },
        Player = { Walkspeed = false, WSvalue = 1.35, SpeedKeybind = Enum.KeyCode.RightShift },
        TPWalk = { Enabled = false, Speed = 0.01, Keybind = Enum.KeyCode.P },
        Misc = { AntiModerator = false, DeviceSpoofer = false, Device = "PC", MobilePanel = true },
        Visuals = {
            ShotIndicator = false, IndicatorColor = "Blue",
            CustomName = false, CustomNameText = "",
            CustomRecord = false, CustomRecordText = "",
            CustomTitle = false, CustomTitleText = "",
            HideOwnNameplate = false,
        },
        Goal = { Enabled = false, SelectedEffect = "LightRay", CurrentEffect = "LightRay" },
        BallChanger = { Enabled = false, SelectedBall = "ForceField", CurrentBall = "ForceField" },
    }
    local s = Settings

    local Cleanup = { conns = {}, fns = {} }
    local function Track(c) table.insert(Cleanup.conns, c); return c end
    local function OnCleanup(fn) table.insert(Cleanup.fns, fn) end

    local setAural, setGuard, setMagnet, setReach, setSpeed, setTPWalk, setMagV2
    local MobileRefresh = function() end

    local IndicatorColors = {
        Blue = Color3.fromRGB(60, 150, 255),
        Purple = Color3.fromRGB(190, 165, 240),
        Green = Color3.fromRGB(0, 255, 128),
        Red = Color3.fromRGB(255, 60, 60),
        Yellow = Color3.fromRGB(255, 220, 0),
    }

    local function hasball(char) return char and char:FindFirstChild("Basketball") ~= nil end

    local fieldGoals = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst.Name == "FieldGoal" and inst:IsA("BasePart") then
            table.insert(fieldGoals, inst)
        end
    end

    local function getclosestdunkfunc()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local pos = hrp.Position
        for i = #fieldGoals, 1, -1 do
            local v = fieldGoals[i]
            if not v.Parent then
                table.remove(fieldGoals, i)
            elseif (pos - v.Position).Magnitude <= 13 then
                return v:FindFirstChild("dunkFunction")
            end
        end
        return nil
    end

    local goals = {}
    local goalsDirty = true

    local function validgoal(o)
        if not o:IsA("BasePart") then return false end
        local n = string.lower(o.Name)
        if n ~= "goal" and n ~= "goalhome" and n ~= "goalaway" then return false end
        local p = o.Parent
        for _ = 1, 5 do
            if not p then break end
            local pn = string.lower(p.Name)
            if string.find(pn, "hitbox", 1, true) or string.find(pn, "fieldgoal", 1, true) then return true end
            p = p.Parent
        end
        return false
    end

    local function rebuildGoals()
        table.clear(goals)
        for _, o in workspace:GetDescendants() do
            if validgoal(o) then table.insert(goals, o) end
        end
        goalsDirty = false
    end
    rebuildGoals()

    Track(workspace.DescendantAdded:Connect(function(o)
        if validgoal(o) then
            table.insert(goals, o)
        elseif o:IsA("BasePart") and string.find(string.lower(o.Name), "goal", 1, true) then
            goalsDirty = true
        end
    end))

    local courtPlayerCache = {}
    local function rebuildCourtCache()
        table.clear(courtPlayerCache)
        for _, inst in next, workspace:GetChildren() do
            if inst.Name == "Courts" then
                for _, court in next, inst:GetChildren() do
                    local cp = court:FindFirstChild("_CourtPlayers")
                    if cp then table.insert(courtPlayerCache, cp) end
                end
            end
        end
    end
    rebuildCourtCache()

    Track(workspace.DescendantAdded:Connect(function(o)
        if o.Name == "_CourtPlayers" then
            table.insert(courtPlayerCache, o)
        end
    end))

    local function nearestgoal(root)
        if goalsDirty then rebuildGoals() end
        local rootPos = root.Position
        local best, bestDist = nil, math.huge
        for i = #goals, 1, -1 do
            local goal = goals[i]
            if not goal or not goal.Parent then table.remove(goals, i); continue end
            local delta = goal.Position - rootPos
            local flat = delta.X * delta.X + delta.Z * delta.Z
            if flat < bestDist then best, bestDist = goal, flat end
        end
        if best then
            return best, math.sqrt(bestDist)
        end
        return nil, math.huge
    end

    local function teamOf(nm)
        if nm:find("^Home") then return "Home" end
        if nm:find("^Away") then return "Away" end
        return nil
    end

    local function getTeammates()
        local tms = {}
        for _, cp in next, courtPlayerCache do
            if not cp.Parent then continue end
            local myTeam = nil
            for _, v in next, cp:GetChildren() do
                if v:IsA("ObjectValue") and v.Value == LocalPlayer then
                    myTeam = teamOf(v.Name)
                    break
                end
            end
            if not myTeam then continue end
            for _, tm in next, cp:GetChildren() do
                if tm:IsA("ObjectValue") and typeof(tm.Value) == "Instance"
                    and tm.Value:IsA("Player") and tm.Value ~= LocalPlayer
                    and teamOf(tm.Name) == myTeam then
                    table.insert(tms, tm.Value)
                end
            end
            break
        end
        return tms
    end

    local teammatesCache = { list = nil }
    local lastTeammateRefresh = 0

    local function isTeammatePlayer(player)
        local now = os.clock()
        if now - lastTeammateRefresh > 0.5 or not teammatesCache.list then
            teammatesCache.list = getTeammates()
            lastTeammateRefresh = now
        end
        for _, tm in ipairs(teammatesCache.list) do
            if tm == player then return true end
        end
        return false
    end

    local function getClosestDribbler()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closestPlayer, closestDistance = nil, math.huge
        for _, part in workspace:GetPartBoundsInRadius(root.Position, s.Defending.AutoGuardRange) do
            if part:IsA("BasePart") and part.Name == "Ball" and part.Parent:IsA("Folder") then
                local holder = part.Parent.Parent
                local holderRoot = holder and holder:FindFirstChild("HumanoidRootPart")
                if holderRoot then
                    local distance = (holderRoot.Position - root.Position).Magnitude
                    if distance < closestDistance then
                        local holderPlayer = Players:GetPlayerFromCharacter(holder)
                        if holderPlayer and not isTeammatePlayer(holderPlayer) then
                            closestDistance = distance
                            closestPlayer = holderPlayer
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    local function getClosestPlayer()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closestPlayer, closestDistance = nil, math.huge
        local rootPos = root.Position
        local range = s.Defending.AutoGuardRange
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local c = player.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - rootPos).Magnitude
                if dist < range and dist < closestDistance and not isTeammatePlayer(player) then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
        return closestPlayer
    end

    local function getGuardMode()
        local lowered = tostring(s.Defending.AutoGuardMode or "Balanced"):lower()
        if lowered == "reactive" then return "legit" end
        if lowered == "aggressive" then return "blatant" end
        return "prediction"
    end

    local function getGuardPosition(target)
        if not target then return nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Basketball") then return nil end
        local targetChar = target.Character
        if not targetChar then return nil end
        local targetBall = targetChar:FindFirstChild("Basketball") and targetChar.Basketball:FindFirstChild("Ball")
        if not targetBall then return nil end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar:FindFirstChild("Humanoid")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if not targetHrp or not targetHum or not myHrp or not myHum then return nil end
        local mode = getGuardMode()
        local ballPos = targetBall.Position
        local vel = targetHrp.AssemblyLinearVelocity
        local speed = targetHum.WalkSpeed
        local moveDir = targetHum.MoveDirection
        local myPos = myHrp.Position
        local mySpeed = myHum.WalkSpeed
        local distance = (ballPos - myPos).Magnitude
        local timeToReach = distance / (mySpeed + 10)
        local predictionScale = s.Defending.GuardPrediction or 0.58
        if mode == "legit" then
            predictionScale = predictionScale * 0.7
            timeToReach = distance / (mySpeed + 12)
        elseif mode == "blatant" then
            predictionScale = predictionScale * 1.75
            timeToReach = distance / (mySpeed + 18)
        end
        local predictedMove = moveDir * speed * predictionScale + Vector3.new(vel.X, 0, vel.Z) * 0.5
        local interceptPos = targetHrp.Position + predictedMove * timeToReach
        local offsetDir = (moveDir.Magnitude > 0 and moveDir.Unit or Vector3.new(0, 0, 1)) * ((mode == "blatant") and 4 or 2)
        return Vector3.new(interceptPos.X + offsetDir.X, ballPos.Y, interceptPos.Z + offsetDir.Z)
    end

    local function getNearestGuardPosition(target)
        if not target then return nil end
        local targetChar = target.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp or not targetHum or not myHrp then return nil end
        local moveDir = targetHum.MoveDirection
        local vel = Vector3.new(targetHrp.AssemblyLinearVelocity.X, 0, targetHrp.AssemblyLinearVelocity.Z)
        local dist = (targetHrp.Position - myHrp.Position).Magnitude
        local timeToReach = dist / (targetHum.WalkSpeed + 10)
        local predictionScale = (getGuardMode() == "blatant") and (s.Defending.GuardPrediction * 1.5) or s.Defending.GuardPrediction
        local predicted = targetHrp.Position + (moveDir * targetHum.WalkSpeed * predictionScale + vel * 0.5) * timeToReach
        local facing = (moveDir.Magnitude > 0) and moveDir.Unit or (targetHrp.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        local offset = facing * ((getGuardMode() == "blatant") and 4 or 2)
        return Vector3.new(predicted.X + offset.X, targetHrp.Position.Y, predicted.Z + offset.Z)
    end

    local guardConnection = nil

    local function enableAutoGuard()
        if guardConnection then guardConnection:Disconnect(); guardConnection = nil end
        local frameSkip = 0
        guardConnection = RunService.Stepped:Connect(function()
            if not s.Defending.AutoGuard then return end
            frameSkip += 1
            if frameSkip < 3 then return end
            frameSkip = 0
            local char = LocalPlayer.Character
            local myHum = char and char:FindFirstChild("Humanoid")
            if not myHum or hasball(char) then return end
            local mode = getGuardMode()
            local closestDribbler = getClosestDribbler()
            if closestDribbler then
                local guardPos
                if mode == "legit" then
                    guardPos = getNearestGuardPosition(closestDribbler)
                elseif mode == "blatant" then
                    guardPos = getGuardPosition(closestDribbler)
                    if guardPos and closestDribbler.Character and closestDribbler.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = closestDribbler.Character.HumanoidRootPart
                        local myRoot = char:FindFirstChild("HumanoidRootPart")
                        if myRoot and (targetRoot.Position - myRoot.Position).Magnitude < 18 then
                            guardPos = targetRoot.Position + (targetRoot.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit * 3
                        end
                    end
                else
                    guardPos = getGuardPosition(closestDribbler)
                end
                if guardPos then myHum:MoveTo(guardPos) end
                return
            end
            if s.Defending.AutoGuardNearest then
                local nearest = getClosestPlayer()
                if nearest then
                    local guardPos
                    if mode == "legit" then
                        guardPos = getNearestGuardPosition(nearest)
                    elseif mode == "blatant" then
                        guardPos = getNearestGuardPosition(nearest)
                        if guardPos then
                            local myRoot = char:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                local targetRoot = nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot and (targetRoot.Position - myRoot.Position).Magnitude < 20 then
                                    guardPos = targetRoot.Position + targetRoot.CFrame.LookVector * 4
                                end
                            end
                        end
                    else
                        guardPos = getNearestGuardPosition(nearest)
                    end
                end
            end
        end)
    end

    Track(guardConnection)

    local function disableAutoGuard()
        if guardConnection then guardConnection:Disconnect(); guardConnection = nil end
    end

    local magnetHitbox, magnetConnection = nil, nil

    local function createMagnetHitbox(character)
        if magnetHitbox then magnetHitbox:Destroy(); magnetHitbox = nil end
        if character:FindFirstChild("FatalMagnet") then character.FatalMagnet:Destroy() end
        local head = character:FindFirstChild("Head")
        if not head then return end
        magnetHitbox = Instance.new("Part")
        magnetHitbox.Name = "NexouraMagnet"
        magnetHitbox.Shape = Enum.PartType.Ball
        magnetHitbox.Size = Vector3.new(s.Ball.BallMagRange, s.Ball.BallMagRange, s.Ball.BallMagRange)
        magnetHitbox.Transparency = 1
        magnetHitbox.CanCollide = false
        magnetHitbox.CanQuery = false
        magnetHitbox.Massless = true
        magnetHitbox.Parent = character
        local weld = Instance.new("Weld")
        weld.Part0 = head
        weld.Part1 = magnetHitbox
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = magnetHitbox
        local magnetBox = Instance.new("SelectionSphere")
        magnetBox.Name = "NexouraMagnetBox"
        magnetBox.Adornee = magnetHitbox
        magnetBox.Color3 = Color3.fromRGB(190, 165, 240)
        magnetBox.Transparency = s.Ball.BallMagVisualizer and 0.2 or 1
        magnetBox.SurfaceTransparency = 1
        magnetBox.Parent = magnetHitbox
        magnetHitbox.Touched:Connect(function(part)
            if not s.Ball.BallMags or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Basketball")) then return end
            if part.Name == "Ball" or (part.Parent and part.Parent.Name == "Basketball") then
                firetouchinterest(head, part, 0)
                task.wait()
                firetouchinterest(head, part, 1)
            end
        end)
    end

    local function enableMagnet()
        local char = LocalPlayer.Character
        if not char then return end
        createMagnetHitbox(char)
        if magnetConnection then magnetConnection:Disconnect(); magnetConnection = nil end
        magnetConnection = RunService.Heartbeat:Connect(function()
            if not s.Ball.BallMags then return end
            local character = LocalPlayer.Character
            if character and not character:FindFirstChild("NexouraMagnet") then
                createMagnetHitbox(character)
            end
        end)
        Track(magnetConnection)
    end

    local function disableMagnet()
        if magnetConnection then magnetConnection:Disconnect(); magnetConnection = nil end
        if magnetHitbox then magnetHitbox:Destroy(); magnetHitbox = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("NexouraMagnet") then
            LocalPlayer.Character.FatalMagnet:Destroy()
        end
    end

    local reachHitbox, reachVisualizer, reachConnection = nil, nil, nil

    local function removeReachVisualizer()
        if reachVisualizer then reachVisualizer:Destroy(); reachVisualizer = nil end
    end

    local function removeReachHitbox()
        if reachHitbox then reachHitbox:Destroy(); reachHitbox = nil end
        removeReachVisualizer()
    end

    local function createReachHitbox(character)
        if reachHitbox then reachHitbox:Destroy(); reachHitbox = nil end
        if character:FindFirstChild("FatalReach") then character.FatalReach:Destroy() end
    end

    local function performReachSteal()
        if not s.Ball.BallReach then return end
        local char = LocalPlayer.Character
        if not char or char:FindFirstChild("Basketball") then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local range = s.Ball.BallReachRange or 10
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local pChar = player.Character
            if pChar then
                local basketball = pChar:FindFirstChild("Basketball")
                if basketball then
                    local ballPart = basketball:FindFirstChild("Ball") or basketball:FindFirstChildOfClass("BasePart")
                    if ballPart and (head.Position - ballPart.Position).Magnitude <= range then
                        firetouchinterest(head, ballPart, 0)
                        task.wait()
                        firetouchinterest(head, ballPart, 1)
                        return
                    end
                end
            end
        end
    end

    local function updateReachVisualizer()
        if not s.Ball.BallReachVisualizer then removeReachVisualizer(); return end
        local closest, closestDist = nil, math.huge
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local c = p.Character
                local b = c and c:FindFirstChild("Basketball")
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if b and r then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < closestDist then closestDist = d; closest = p end
                end
            end
        end
        local ballPart = nil
        if closest and closest.Character then
            local oppBall = closest.Character:FindFirstChild("Basketball")
            if oppBall then ballPart = oppBall:FindFirstChild("Ball") end
        end
        if not ballPart then removeReachVisualizer(); return end
        local range = s.Ball.BallReachRange or 10
        if not reachVisualizer or not reachVisualizer.Parent then
            reachVisualizer = Instance.new("Part")
            reachVisualizer.Name = "ReachBallVisualizer"
            reachVisualizer.Shape = Enum.PartType.Ball
            reachVisualizer.Size = Vector3.new(range, range, range)
            reachVisualizer.Transparency = 1
            reachVisualizer.CanCollide = false
            reachVisualizer.CanTouch = false
            reachVisualizer.CanQuery = false
            reachVisualizer.CastShadow = false
            reachVisualizer.Massless = true
            reachVisualizer.Anchored = true
            reachVisualizer.Color = Color3.fromRGB(190, 165, 240)
            reachVisualizer.Parent = workspace
            local sphereBox = Instance.new("SelectionSphere")
            sphereBox.Name = "NexouraReachSphere"
            sphereBox.Adornee = reachVisualizer
            sphereBox.Transparency = 0.75
            sphereBox.SurfaceTransparency = 1
            sphereBox.Color3 = Color3.fromRGB(190, 165, 240)
            sphereBox.Parent = reachVisualizer
        end
        reachVisualizer.Size = Vector3.new(range, range, range)
        reachVisualizer.CFrame = ballPart.CFrame
    end

    local function enableReach()
        local char = LocalPlayer.Character
        if not char then return end
        createReachHitbox(char)
        if reachConnection then reachConnection:Disconnect(); reachConnection = nil end
        reachConnection = RunService.Heartbeat:Connect(function()
            if not s.Ball.BallReach and not s.Ball.BallReachVisualizer then removeReachHitbox(); return end
            if s.Ball.BallReach then performReachSteal() end
            if s.Ball.BallReachVisualizer then updateReachVisualizer() else removeReachVisualizer() end
        end)
        Track(reachConnection)
    end

    local function disableReach()
        if not s.Ball.BallReachVisualizer then
            if reachConnection then reachConnection:Disconnect(); reachConnection = nil end
            removeReachHitbox()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("NexouraReach") then
                LocalPlayer.Character.FatalReach:Destroy()
            end
        end
    end

    local speedConnection = nil

    local function enableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        speedConnection = RunService.Heartbeat:Connect(function()
            if not s.Player.Walkspeed then return end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0.05 then
                local multiplier = math.clamp(s.Player.WSvalue or 1.35, 1, 2.2)
                local targetSpeed = 16 * multiplier
                local currentY = hrp.AssemblyLinearVelocity.Y
                local targetVel = moveDir.Unit * targetSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentY, targetVel.Z)
            end
        end)
        Track(speedConnection)
    end

    local function disableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    end

    local tpWalkConnection = nil

    local function enableTPWalk()
        if tpWalkConnection then tpWalkConnection:Disconnect(); tpWalkConnection = nil end
        tpWalkConnection = RunService.Heartbeat:Connect(function()
            if not s.TPWalk.Enabled then return end
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                local moveVector = humanoid.MoveDirection * s.TPWalk.Speed
                rootPart.CFrame = rootPart.CFrame + moveVector
            end
        end)
        Track(tpWalkConnection)
    end

    local function disableTPWalk()
        if tpWalkConnection then tpWalkConnection:Disconnect(); tpWalkConnection = nil end
    end

    local magV2Connection = nil

    local function magV2Tick()
        if not s.MagV2.Enabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local touchPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("RightFoot")
        if not touchPart then return end
        local ballName = s.MagV2.BallName
        local reach = tonumber(s.MagV2.Reach) or 20
        for _, object in pairs(workspace:GetDescendants()) do
            if object.Name == ballName and object:IsA("BasePart") then
                local touchInterest = object:FindFirstChildWhichIsA("TouchTransmitter") or object:FindFirstChild("TouchInterest")
                if touchInterest then
                    local distance = (touchPart.Position - object.Position).Magnitude
                    if distance <= reach then
                        firetouchinterest(touchPart, object, 0)
                        task.wait()
                        firetouchinterest(touchPart, object, 1)
                    end
                end
            end
        end
    end

    local function enableMagV2()
        if magV2Connection then magV2Connection:Disconnect(); magV2Connection = nil end
        magV2Connection = RunService.Heartbeat:Connect(function()
            pcall(magV2Tick)
        end)
        Track(magV2Connection)
    end

    local function disableMagV2()
        if magV2Connection then magV2Connection:Disconnect(); magV2Connection = nil end
    end

    local Effects = {}
    local function loadEffects()
        pcall(function()
            local folder = ReplicatedStorage.ShopItems.Effect
            for _, eff in folder:GetChildren() do
                Effects[eff.Name:gsub("Effect_", "")] = eff
            end
        end)
    end
    loadEffects()

    local goalEventHook = nil

    local function applyGoalEffect()
        if not Effects[s.Goal.CurrentEffect] then return end
        pcall(function()
            local PlayerData = require(ReplicatedStorage.Util.PlayerData)
            PlayerData.storedData["Equipping"]["Effect"] = Effects[s.Goal.CurrentEffect].Name
            PlayerData.storedData["Inventory"][Effects[s.Goal.CurrentEffect].Name] = 1
        end)
        if goalEventHook then return end
        pcall(function()
            local connections = getconnections(ReplicatedStorage.Remotes.goalEvent.OnClientEvent)
            if connections and connections[1] then
                local old
                old = hookfunction(connections[1].Function, function(Player, Court, Goal, XYZ, GoalEffect, Unknown)
                    if Player == LocalPlayer and s.Goal.Enabled then
                        GoalEffect = Effects[s.Goal.CurrentEffect].Value
                    end
                    return old(Player, Court, Goal, XYZ, GoalEffect, Unknown)
                end)
                goalEventHook = old
            end
        end)
    end

    local function resetGoalEffect()
        pcall(function()
            local PlayerData = require(ReplicatedStorage.Util.PlayerData)
            PlayerData.storedData["Equipping"]["Effect"] = Effects["LightRay"].Name
            PlayerData.storedData["Inventory"][Effects["LightRay"].Name] = 1
        end)
    end

    local function SpoofDevice()
        if not s.Misc.DeviceSpoofer then return end
        local device = s.Misc.Device
        if device == "PC" then DeviceEvent:FireServer("Desktop")
        elseif device == "Mobile" then DeviceEvent:FireServer("Mobile")
        elseif device == "Gamepad" then DeviceEvent:FireServer("Gamepad") end
    end

    local Moderators = {
        "izzran", "wistfulmikk", "Bibliogical", "aepione", "kyraizo",
        "ar1sxm", "westline60s", "Iukejdjd", "Ninja215215"
    }
    local antiModTask = nil
    local Notify

    local function startAntiMod()
        if antiModTask then return end
        antiModTask = task.spawn(function()
            local detected = {}
            while s.Misc.AntiModerator do
                task.wait(1)
                for _, moderator in next, Players:GetPlayers() do
                    if table.find(Moderators, moderator.Name) and not detected[moderator.UserId] then
                        detected[moderator.UserId] = true
                        if Notify then
                            Notify({
                                title = "Moderator Detected",
                                content = moderator.Name .. " is in the server.",
                                duration = 5,
                            })
                        end
                    end
                end
            end
        end)
    end

    local function stopAntiMod()
        s.Misc.AntiModerator = false
        if antiModTask then task.cancel(antiModTask); antiModTask = nil end
    end

    local Balls, BallNames = {}, {}
    local OriginalReplicateBall, Replicator = nil, nil
    pcall(function()
        Replicator = require(ReplicatedStorage.Util.Replicator)
        OriginalReplicateBall = Replicator["ReplicateBall"]
        for _, ballItem in ReplicatedStorage.ShopItems.Ball:GetChildren() do
            local name = ballItem.Name:gsub("Ball_", "")
            Balls[name] = ballItem.Name
            table.insert(BallNames, name)
        end
        table.sort(BallNames)
    end)

    -- ============================================================
    -- BALL CHANGER (only spoofs YOUR ball)
    -- ============================================================
    local function ownerOfParent(parent)
        -- Walk up from the ball container to find the character model it lives under.
        local node = parent
        for _ = 1, 6 do
            if not node then break end
            if node:IsA("Model") then
                local plr = Players:GetPlayerFromCharacter(node)
                if plr then return plr end
            end
            node = node.Parent
        end
        return nil
    end

    local function applyBallChanger()
        if not Replicator or not OriginalReplicateBall then return end
        Replicator["ReplicateBall"] = function(Parent, Name)
            -- Only rewrite the ball when the container belongs to the LocalPlayer.
            local owner = ownerOfParent(Parent)
            if owner == LocalPlayer then
                local spoofed = Balls[s.BallChanger.CurrentBall]
                if spoofed then
                    Name = spoofed
                end
            end
            return OriginalReplicateBall(Parent, Name)
        end
    end

    local function resetBallChanger()
        if not Replicator or not OriginalReplicateBall then return end
        Replicator["ReplicateBall"] = OriginalReplicateBall
    end

    local indicator = Instance.new("BillboardGui")
    indicator.Name = "RangeIndicator"
    indicator.Size = UDim2.fromOffset(90, 90)
    indicator.AlwaysOnTop = true
    indicator.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
    indicator.Parent = nil

    local indicatorRing = Instance.new("ImageLabel")
    indicatorRing.Name = "Ring"
    indicatorRing.Size = UDim2.fromScale(1, 1)
    indicatorRing.BackgroundTransparency = 1
    indicatorRing.Image = "rbxassetid://3570695787"
    indicatorRing.ImageColor3 = Color3.fromRGB(190, 165, 240)
    indicatorRing.ImageTransparency = 0.15
    indicatorRing.ScaleType = Enum.ScaleType.Fit
    indicatorRing.Parent = indicator

    local indicatorDot = Instance.new("Frame")
    indicatorDot.Name = "Dot"
    indicatorDot.Size = UDim2.fromOffset(6, 6)
    indicatorDot.AnchorPoint = Vector2.new(0.5, 0.5)
    indicatorDot.Position = UDim2.fromScale(0.5, 0.5)
    indicatorDot.BackgroundColor3 = Color3.fromRGB(190, 165, 240)
    indicatorDot.BorderSizePixel = 0
    indicatorDot.Parent = indicator

    local indicatorDotCorner = Instance.new("UICorner")
    indicatorDotCorner.CornerRadius = UDim.new(1, 0)
    indicatorDotCorner.Parent = indicatorDot

    local rangeConnection = nil

    local function applyIndicatorColor()
        local col = IndicatorColors[s.Visuals.IndicatorColor] or Color3.fromRGB(190, 165, 240)
        indicatorRing.ImageColor3 = col
        indicatorDot.BackgroundColor3 = col
    end

    local function setShotIndicator(value)
        s.Visuals.ShotIndicator = value
        if rangeConnection then rangeConnection:Disconnect(); rangeConnection = nil end
        indicator.Parent = nil
        if not value then return end
        local throttle = 0
        rangeConnection = RunService.Heartbeat:Connect(function(dt)
            throttle += dt
            if throttle < 0.05 then return end
            throttle = 0
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root or not hasball(character) then indicator.Parent = nil; return end
            local goal, distance = nearestgoal(root)
            if goal and distance >= 12 and distance <= 73 then
                applyIndicatorColor()
                if indicator.Parent ~= character then
                    indicator.Adornee = character
                    indicator.Parent = character
                end
            else
                indicator.Parent = nil
            end
        end)
        Track(rangeConnection)
    end

    local AURAL_MIN_DIST = 12
    local AURAL_MAX_DIST = 73

    local shot_data = {
        [59]=83,[60]=81,[61]=82,[62]=79,[63]=78.8,[64]=75,[65]=74.8,[66]=71,
        [67]=70.8,[68]=66,[69]=62,[70]=59,[71]=51,[72]=51,[73]=51
    }

    local inner_arc_data = {
        [7]=123,[8]=122,[9]=121,[10]=120,[11]=119,[12]=118,[13]=117,[14]=116,[15]=115,[16]=114,
        [17]=113,[18]=112,[19]=111,[20]=110,[21]=109,[22]=108,[23]=107,[24]=106,[25]=105,
        [26]=105,
        [27]=106,[28]=106,[29]=107,[30]=107,[31]=106,[32]=105,[33]=105,[34]=104,[35]=103,
        [36]=103,
        [37]=102,[38]=102,[39]=101,[40]=101,[41]=100,[42]=99,[43]=99,[44]=98,[45]=97,[46]=96,
        [47]=95,[48]=95,[49]=94,[50]=93,[51]=91,[52]=90,[53]=88,[54]=87,[55]=85,[56]=84,[57]=82,
        [58]=81
    }

    local mobileArcs = {
        [30]=38,[31]=38,[32]=38,[33]=38,[34]=38,[35]=38,[36]=38,[37]=38,[38]=38,[39]=38,
        [40]=39,[41]=38,[42]=38,[43]=38,[44]=38,[45]=38,[46]=38,[47]=38,[48]=38,[49]=38,
        [50]=38,[51]=37,[52]=37,[53]=37,[54]=36,[55]=34,[56]=34,[57]=34,[58]=34,[59]=31,
        [60]=31,[61]=31,[62]=31,[63]=29,[64]=29,[65]=29,[66]=26,[67]=26,[68]=24,[69]=24,
        [70]=21,[71]=21,[72]=19,[73]=19
    }

    local function getArcOffset(dist)
        local isMobile = UserInputService.TouchEnabled
        if isMobile then
            local d = math.floor(dist + 0.5)
            if d < 30 then d = 30 end
            if d > 73 then d = 73 end
            return mobileArcs[d] or 37
        end
        if inner_arc_data[dist] then return inner_arc_data[dist] end
        if shot_data[dist] then return shot_data[dist] end
        if dist < 7 then return 122 end
        if dist > 73 then return math.max(20, 50 - (dist - 73) * 1.5) end
        local lower, upper = nil, nil
        for d in pairs(inner_arc_data) do
            if d <= dist and (not lower or d > lower) then lower = d end
            if d >= dist and (not upper or d < upper) then upper = d end
        end
        for d in pairs(shot_data) do
            if d <= dist and (not lower or d > lower) then lower = d end
            if d >= dist and (not upper or d < upper) then upper = d end
        end
        if lower and upper and lower ~= upper then
            local lowerVal = inner_arc_data[lower] or shot_data[lower] or 0
            local upperVal = inner_arc_data[upper] or shot_data[upper] or 0
            local t = (dist - lower) / (upper - lower)
            return lowerVal + (upperVal - lowerVal) * t
        elseif lower then
            return inner_arc_data[lower] or shot_data[lower] or 0
        elseif upper then
            return inner_arc_data[upper] or shot_data[upper] or 0
        end
        return 100
    end

    local function setpower(p)
        LocalPlayer:SetAttribute("Power", p)
        pcall(function() SharedTableRegistry:GetSharedTable("PowerData").Power = p end)
    end

    local function restoreMouseBehavior()
        pcall(function()
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end)
    end

    local Icon = nil
    local IconCenter = nil
    do
        pcall(function()
            local PowerUI = LocalPlayer.PlayerGui:WaitForChild("PowerUI")
            Icon = PowerUI:WaitForChild("CursorIcon")
            local CursorIcon2 = PowerUI:WaitForChild("CursorIcon2")
            task.delay(5, function()
                if Icon then
                    IconCenter = Vector2.new(Icon.AbsolutePosition.X + Icon.AbsoluteSize.X / 2, Icon.AbsolutePosition.Y + Icon.AbsoluteSize.Y / 2)
                    Icon:Destroy()
                end
                if CursorIcon2 then CursorIcon2.Visible = false end
            end)
        end)
    end

    local state = {
        target = nil, connections = {}, actorst = nil, actorname = nil,
        actors = {}, oldnewindex = nil, active = true, clicking = false
    }

    local function addconnection(c) table.insert(state.connections, c); return c end

    local function settarget(target)
        state.target = target
        if state.actorst then pcall(function() state.actorst.t = target end) end
    end

    local function doClick()
        if state.clicking then return end
        state.clicking = true
        getgenv().__fatal_aiming = true
        if isMobile then
            if Icon then
                local pos = Vector2.new(Icon.AbsolutePosition.X + Icon.AbsoluteSize.X / 2, Icon.AbsolutePosition.Y + Icon.AbsoluteSize.Y / 2)
                VirtualInput:SendTouchEvent(1, 0, pos.X, pos.Y)
                VirtualInput:SendTouchEvent(1, 2, pos.X, pos.Y)
            elseif IconCenter then
                VirtualInput:SendTouchEvent(1, 0, IconCenter.X, IconCenter.Y)
                VirtualInput:SendTouchEvent(1, 2, IconCenter.X, IconCenter.Y)
            end
        else
            local vp = Camera.ViewportSize
            VirtualInput:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
            VirtualInput:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
        end
        task.delay(0.35, function()
            state.clicking = false
            getgenv().__fatal_aiming = false
        end)
    end

    local function velocify(target, dist)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return target end
        local velocity = hrp.AssemblyLinearVelocity
        local travelTime = dist / 50
        local prediction = travelTime * 0.06
        return target + Vector3.new(velocity.X * prediction, 0, velocity.Z * prediction)
    end

    local auralTick = 0

    local function updateAuralTarget(dt)
        if not state.active or not s.Shooting.AuralEnabled then
            if state.target ~= nil then settarget(nil) end
            return
        end
        auralTick += dt
        if auralTick < 0.05 then return end
        auralTick = 0
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or not hasball(char) then
            if state.target ~= nil then settarget(nil) end
            return
        end
        if hum.FloorMaterial ~= Enum.Material.Air and not hum.Jump then
            if state.target ~= nil then settarget(nil) end
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then settarget(nil); return end
        local goal, distance = nearestgoal(root)
        if not goal or distance < AURAL_MIN_DIST or distance > AURAL_MAX_DIST then
            if state.target ~= nil then settarget(nil) end
            return
        end
        local offset = getArcOffset(distance) + s.Shooting.ShotYAxis
        if s.Shooting.HumanizeAim then
            local strength = s.Shooting.HumanizeStrength or 1.2
            local missChance = (s.Shooting.MissChance or 12) / 100
            if math.random() < missChance then
                if math.random() < 0.5 then
                    offset += strength * 3 + math.random() * strength * 2
                else
                    offset -= strength * 3 + math.random() * strength * 2
                end
            else
                offset += (math.random() * 2 - 1) * strength
            end
        end
        settarget(velocify(goal.Position + Vector3.new(0, offset, 0), distance))
    end

    local actorcode = [==[
local registry = game:GetService("SharedTableRegistry")
local players = game:GetService("Players")
local st = registry:GetSharedTable(__fatalaimtable)
local camera = workspace.CurrentCamera
local function target() local v = st.t return typeof(v) == "Vector3" and v or nil end
local function aimcframe()
    local v = target()
    local char = players.LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if v and head then return CFrame.new(head.Position, v) end
end
pcall(function()
    local oldrender
    oldrender = hookfunction(camera.GetRenderCFrame, function(self, ...) return aimcframe() or oldrender(self, ...) end)
    local oldscreen
    oldscreen = hookfunction(camera.ScreenPointToRay, function(self, ...)
        local v = aimcframe()
        if v then return Ray.new(v.Position, v.LookVector) end
        return oldscreen(self, ...)
    end)
    local oldviewport
    oldviewport = hookfunction(camera.ViewportPointToRay, function(self, ...)
        local v = aimcframe()
        if v then return Ray.new(v.Position, v.LookVector) end
        return oldviewport(self, ...)
    end)
    local cameradata = registry:GetSharedTable("CameraData")
    local history = cameradata.CameraHistory
    local meta = getrawmetatable(cameradata)
    local oldnewindex
    oldnewindex = hookfunction(meta.__newindex, newcclosure(function(tab, key, value)
        local current = tab == cameradata and key == "CameraCFrame"
        local previous = history ~= nil and tab == history and type(key) == "number"
        local aimed = aimcframe()
        if aimed and (current or previous) then return oldnewindex(tab, key, aimed) end
        return oldnewindex(tab, key, value)
    end))
end)
]==]

    local function hookmain()
        pcall(function()
            state.actorname = "sa" .. tostring(math.floor(os.clock() * 100000)) .. tostring(math.random(10000, 99999))
            state.actorst = SharedTableRegistry:GetSharedTable(state.actorname)
            state.actorst.t = nil
            local cameradata = SharedTableRegistry:GetSharedTable("CameraData")
            local history = cameradata.CameraHistory
            local meta = getrawmetatable(cameradata)
            state.oldnewindex = hookfunction(meta.__newindex, newcclosure(function(tab, key, value)
                local current = tab == cameradata and key == "CameraCFrame"
                local previous = history ~= nil and tab == history and type(key) == "number"
                local tgt = state.target
                if tgt and (current or previous) and typeof(value) == "CFrame" then
                    local char = LocalPlayer.Character
                    local head = char and char:FindFirstChild("Head")
                    if head then
                        return state.oldnewindex(tab, key, CFrame.new(head.Position, tgt))
                    end
                end
                return state.oldnewindex(tab, key, value)
            end))
        end)
    end

    local function hookactors()
        if type(getactors) ~= "function" or type(run_on_actor) ~= "function" or not state.actorname then return end
        local ok, actors = pcall(getactors)
        if not ok or type(actors) ~= "table" then return end
        local code = "local __fatalaimtable = " .. string.format("%q", state.actorname) .. " " .. actorcode
        for _, actor in actors do
            if not state.actors[actor] then
                if pcall(run_on_actor, actor, code) then
                    state.actors[actor] = true
                end
            end
        end
    end

    hookmain()
    hookactors()

    addconnection(Players.PlayerAdded:Connect(function() task.defer(hookactors) end))
    addconnection(RunService.Heartbeat:Connect(updateAuralTarget))

    local function setupCharacterAural(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local jumps = 0
        local airborne = false
        addconnection(hum.Jumping:Connect(function(active)
            if not active then return end
            airborne = true
            if not s.Shooting.AuralEnabled then return end
            if not hasball(char) then return end
            if s.Shooting.EBLHop then
                jumps += 1
                if jumps < 2 then return end
                jumps = 0
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local goal, distance = nearestgoal(root)
            local minDist = isMobile and 30 or AURAL_MIN_DIST
            if not goal or distance < minDist or distance > AURAL_MAX_DIST then return end
            local arc = getArcOffset(distance) + s.Shooting.ShotYAxis
            local targetPos = nil
            if s.Shooting.HumanizeAim then
                local strength = s.Shooting.HumanizeStrength or 1.2
                local missChance = (s.Shooting.MissChance or 12) / 100
                if math.random() < missChance then
                    local mode = math.random(1, 3)
                    if mode == 1 then
                        arc += strength * 3 + math.random() * strength * 2
                    elseif mode == 2 then
                        arc -= strength * 3 + math.random() * strength * 2
                    else
                        local side = (math.random() < 0.5) and -1 or 1
                        targetPos = goal.Position
                            + Vector3.new(0, getArcOffset(distance) + s.Shooting.ShotYAxis, 0)
                            + Camera.CFrame.RightVector * (side * (strength * 2 + math.random() * 2))
                    end
                else
                    arc += (math.random() * 2 - 1) * strength
                end
            end
            targetPos = targetPos or goal.Position + Vector3.new(0, arc, 0)
            settarget(targetPos)
            task.wait(0.05)
            LocalPlayer:SetAttribute("Power", 85)
            local shotdelay = s.Shooting.ShotDelay or 0.25
            if s.Shooting.RandomizeShotDelay then
                local mn = s.Shooting.ShotDelayMin or 0.15
                local mx = s.Shooting.ShotDelayMax or 0.35
                if mx < mn then mx = mn end
                shotdelay = mn + math.random() * (mx - mn)
            end
            task.wait(shotdelay)
            doClick()
            task.wait(0.1)
            updateAuralTarget(0.1)
        end))
        addconnection(hum.StateChanged:Connect(function(_, st2)
            if st2 == Enum.HumanoidStateType.Landed
                or st2 == Enum.HumanoidStateType.Running then
                airborne = false
            end
        end))
    end

    if LocalPlayer.Character then setupCharacterAural(LocalPlayer.Character) end
    addconnection(LocalPlayer.CharacterAdded:Connect(setupCharacterAural))

    local textListeners = {}
    local originalNameTexts, originalRecordTexts, originalTitleTexts = {}, {}, {}

    local function formatStrokeText(orig, custom)
        if not custom or custom == "" then return orig end
        if orig and orig:match("^<stroke>") and orig:match("</stroke>$") then
            return "<stroke>" .. custom .. "</stroke>"
        end
        return custom
    end

    local function applyOwnNameplate()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local nameTag = hrp:FindFirstChild("NameTag")
        if not nameTag or not nameTag:IsA("BillboardGui") then return end
        for _, tagName in ipairs({"NameTag", "CreatorTag", "TeamSpot"}) do
            local tag = hrp:FindFirstChild(tagName)
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = not s.Visuals.HideOwnNameplate
            end
        end
        local mainFrame = nameTag:FindFirstChild("MainFrame")
        local gameFrame = nameTag:FindFirstChild("GameFrame")
        local subFrame = mainFrame and mainFrame:FindFirstChild("Frame")
        local nameLabels = {}
        if mainFrame and mainFrame:FindFirstChild("NameLabel") then table.insert(nameLabels, mainFrame.NameLabel) end
        if gameFrame and gameFrame:FindFirstChild("NameLabel") then table.insert(nameLabels, gameFrame.NameLabel) end
        for _, obj in ipairs(nameTag:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Name == "NameLabel" and not table.find(nameLabels, obj) then
                table.insert(nameLabels, obj)
            end
        end
        for _, obj in ipairs(nameLabels) do
            if not originalNameTexts[obj] then originalNameTexts[obj] = obj.Text end
            local target = (s.Visuals.CustomNameText ~= "") and s.Visuals.CustomNameText or originalNameTexts[obj]
            if obj.Text ~= target then obj.Text = target end
            if not textListeners[obj] then
                textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if s.Visuals.CustomNameText ~= "" and obj.Text ~= s.Visuals.CustomNameText then
                        obj.Text = s.Visuals.CustomNameText
                    end
                end)
            end
        end
        local recordLabels = {}
        if subFrame and subFrame:FindFirstChild("RecordLabel") then table.insert(recordLabels, subFrame.RecordLabel) end
        for _, obj in ipairs(nameTag:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Name == "RecordLabel" and not table.find(recordLabels, obj) then
                table.insert(recordLabels, obj)
            end
        end
        for _, obj in ipairs(recordLabels) do
            if not originalRecordTexts[obj] then originalRecordTexts[obj] = obj.Text end
            local target = formatStrokeText(originalRecordTexts[obj], s.Visuals.CustomRecordText)
            if obj.Text ~= target then obj.Text = target end
            if not textListeners[obj] then
                textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if s.Visuals.CustomRecordText ~= "" then
                        local expected = formatStrokeText(originalRecordTexts[obj], s.Visuals.CustomRecordText)
                        if obj.Text ~= expected then obj.Text = expected end
                    end
                end)
            end
        end
        local titleLabels = {}
        if subFrame and subFrame:FindFirstChild("AchievementName") then table.insert(titleLabels, subFrame.AchievementName) end
        for _, obj in ipairs(nameTag:GetDescendants()) do
            if obj:IsA("TextLabel") and (obj.Name == "AchievementName" or obj.Name == "TitleLabel") and not table.find(titleLabels, obj) then
                table.insert(titleLabels, obj)
            end
        end
        for _, obj in ipairs(titleLabels) do
            if not originalTitleTexts[obj] then originalTitleTexts[obj] = obj.Text end
            local target = formatStrokeText(originalTitleTexts[obj], s.Visuals.CustomTitleText)
            if obj.Text ~= target then obj.Text = target end
            if not textListeners[obj] then
                textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if s.Visuals.CustomTitleText ~= "" then
                        local expected = formatStrokeText(originalTitleTexts[obj], s.Visuals.CustomTitleText)
                        if obj.Text ~= expected then obj.Text = expected end
                    end
                end)
            end
        end
    end

    local ownNameplateConnection = nil

    local function setupOwnNameplateListener()
        if ownNameplateConnection then return end
        local function onChar(char)
            task.wait(0.2)
            applyOwnNameplate()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                hrp.ChildAdded:Connect(function(child)
                    if child:IsA("BillboardGui") then
                        task.wait(0.05)
                        applyOwnNameplate()
                    end
                end)
                local nameTag = hrp:WaitForChild("NameTag", 5)
                if nameTag then
                    nameTag.DescendantAdded:Connect(function()
                        task.wait(0.05)
                        applyOwnNameplate()
                    end)
                end
            end
        end
        if LocalPlayer.Character then task.spawn(onChar, LocalPlayer.Character) end
        ownNameplateConnection = LocalPlayer.CharacterAdded:Connect(onChar)
        Track(ownNameplateConnection)
    end
    setupOwnNameplateListener()

    local Window = Rayfield:CreateWindow({
        name = "Nexoura Hub",
        subtitle = "basketball suite",
        size = UDim2.fromOffset(620, 480),
        font = Enum.Font.Gotham,
        icon = 135101778515904,
        sidebarLayout = true,
        inlineDescription = true,
        theme = "Nexoura hub",
        userInfo = {
            Title = LocalPlayer.DisplayName,
            Subtitle = "@" .. LocalPlayer.Name,
            Icons = 135101778515904,
        },
        openButton = isMobile and {
            Title = "Nexoura Hub",
            Subtitle = "tap to open",
            Icons = 135101778515904,
        } or nil,
        configuration = {
            autoSave = true,
            autoLoad = false,
            fileName = "FatalLabs",
        },
    })

    pcall(function()
        if Rayfield.SetTheme then Rayfield:SetTheme("Nexoura hub") end
    end)

    Notify = function(props) Window:Notify(props) end

    local CombatTab = Window:CreateTab({ name = "Combat", icon = "swords" })
    local BallTab = Window:CreateTab({ name = "Ball", icon = "circle" })
    local VisualsTab = Window:CreateTab({ name = "Visuals", icon = "eye" })
    local PrivacyTab = Window:CreateTab({ name = "Privacy", icon = "user" })
    local UtilityTab = Window:CreateTab({ name = "Utility", icon = "list" })

    CombatTab:CreateSection({ name = "Silent Aim" })
    CombatTab:CreateToggle({
        name = "Enable Silent Aim",
        description = "Automatically Shoots when you Jump",
        flag = "nexoura_aural",
        value = s.Shooting.AuralEnabled,
        callback = function(v) setAural(v) end,
    })
    CombatTab:CreateKeybind({
        name = "Aimbot keybind",
        flag = "nexoura_aural_key",
        value = s.Shooting.AuralKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then
                s.Shooting.AuralKeybind = key
            end
        end,
    })
    CombatTab:CreateSlider({
        name = "Shot delay",
        range = { 0.15, 0.42 }, increment = 0.01, suffix = "s",
        value = s.Shooting.ShotDelay, flag = "fatal_delay",
        callback = function(v) s.Shooting.ShotDelay = v end,
    })
    CombatTab:CreateToggle({
        name = "Randomize shot delay",
        flag = "nexoura_randdelay",
        value = s.Shooting.RandomizeShotDelay,
        callback = function(v) s.Shooting.RandomizeShotDelay = v end,
    })
    CombatTab:CreateSlider({
        name = "Min delay",
        range = { 0, 1 }, increment = 0.05, suffix = "s",
        value = s.Shooting.ShotDelayMin, flag = "fatal_mindelay",
        callback = function(v) s.Shooting.ShotDelayMin = v end,
    })
    CombatTab:CreateSlider({
        name = "Max delay",
        range = { 0, 1 }, increment = 0.05, suffix = "s",
        value = s.Shooting.ShotDelayMax, flag = "fatal_maxdelay",
        callback = function(v) s.Shooting.ShotDelayMax = v end,
    })
    CombatTab:CreateToggle({
        name = "EBL Hop",
        description = "Require second jump before firing.",
        flag = "nexoura_ebl", value = s.Shooting.EBLHop,
        callback = function(v) s.Shooting.EBLHop = v end,
    })
    CombatTab:CreateToggle({
        name = "Humanize aim",
        flag = "nexoura_human", value = s.Shooting.HumanizeAim,
        callback = function(v) s.Shooting.HumanizeAim = v end,
    })
    CombatTab:CreateSlider({
        name = "Humanize strength",
        range = { 0.2, 5 }, increment = 0.1,
        value = s.Shooting.HumanizeStrength, flag = "fatal_hstr",
        callback = function(v) s.Shooting.HumanizeStrength = v end,
    })
    CombatTab:CreateSlider({
        name = "Miss chance",
        range = { 0, 80 }, increment = 1, suffix = "%",
        value = s.Shooting.MissChance, flag = "fatal_miss",
        callback = function(v) s.Shooting.MissChance = v end,
    })
    CombatTab:CreateSection({ name = "Auto Guard" })
    CombatTab:CreateToggle({
        name = "Auto guard", flag = "fatal_guard", value = s.Defending.AutoGuard,
        callback = function(v) setGuard(v) end,
    })
    CombatTab:CreateKeybind({
        name = "Auto guard keybind",
        flag = "fatal_guard_key",
        value = s.Defending.GuardKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then
                s.Defending.GuardKeybind = key
            end
        end,
    })
    CombatTab:CreateDropdown({
        name = "Guard mode",
        options = { "Reactive", "Balanced", "Aggressive" },
        value = s.Defending.AutoGuardMode, flag = "fatal_guard_mode",
        callback = function(v) s.Defending.AutoGuardMode = v end,
    })
    CombatTab:CreateToggle({
        name = "Guard nearest if no dribbler",
        flag = "fatal_guard_near", value = s.Defending.AutoGuardNearest,
        callback = function(v) s.Defending.AutoGuardNearest = v end,
    })
    CombatTab:CreateSlider({
        name = "Guard range",
        range = { 10, 60 }, increment = 1,
        value = s.Defending.AutoGuardRange, flag = "fatal_guard_range",
        callback = function(v) s.Defending.AutoGuardRange = v end,
    })
    CombatTab:CreateSlider({
        name = "Prediction strength",
        range = { 0.1, 1 }, increment = 0.05,
        value = s.Defending.GuardPrediction, flag = "fatal_guard_pred",
        callback = function(v) s.Defending.GuardPrediction = v end,
    })

    BallTab:CreateSection({ name = "Ball Magnet" })
    BallTab:CreateToggle({
        name = "Ball magnet", flag = "fatal_mag", value = s.Ball.BallMags,
        callback = function(v) setMagnet(v) end,
    })
    BallTab:CreateKeybind({
        name = "Magnet keybind", flag = "fatal_mag_key", value = Enum.KeyCode.M,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Ball.MagnetKeybind = key.Name end
        end,
    })
    BallTab:CreateSlider({
        name = "Magnet size",
        range = { 1, 50 }, increment = 1,
        value = s.Ball.BallMagRange, flag = "fatal_mag_size",
        callback = function(v)
            s.Ball.BallMagRange = v
            if magnetHitbox then magnetHitbox.Size = Vector3.new(v, v, v) end
        end,
    })
    BallTab:CreateToggle({
        name = "Show magnet visualizer",
        flag = "fatal_mag_vis", value = s.Ball.BallMagVisualizer,
        callback = function(v)
            s.Ball.BallMagVisualizer = v
            if magnetHitbox then
                local box = magnetHitbox:FindFirstChild("FatalMagnetBox")
                if box then box.Transparency = v and 0.2 or 1 end
            end
        end,
    })

    BallTab:CreateSection({ name = "Mag V2" })
    BallTab:CreateToggle({
        name = "Mag V2",
        description = "Standalone touch-magnet. Uses its own ball name & reach.",
        flag = "Nexoura_magv2", value = s.MagV2.Enabled,
        callback = function(v) setMagV2(v) end,
    })
    BallTab:CreateKeybind({
        name = "Mag V2 keybind",
        description = "Default U. Toggle Mag V2 on/off.",
        flag = "fatal_magv2_key", value = s.MagV2.Keybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.MagV2.Keybind = key end
        end,
    })
    BallTab:CreateInput({
        name = "Mag V2 ball name",
        description = "Name of the part to magnet.",
        placeholder = "Ball",
        value = s.MagV2.BallName, flag = "nexoura_magv2_name",
        callback = function(text)
            if text ~= "" then s.MagV2.BallName = text end
        end,
    })
    BallTab:CreateSlider({
        name = "Mag V2 reach",
        range = { 1, 100 }, increment = 1,
        value = s.MagV2.Reach, flag = "nexoura_magv2_reach",
        callback = function(v) s.MagV2.Reach = v end,
    })

    BallTab:CreateSection({ name = "Ball Reach" })
    BallTab:CreateToggle({
        name = "Ball reach", flag = "nexoura_reach", value = s.Ball.BallReach,
        callback = function(v) setReach(v) end,
    })
    BallTab:CreateKeybind({
        name = "Reach keybind", flag = "fatal_reach_key", value = Enum.KeyCode.N,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.Ball.ReachKeybind = key.Name end
        end,
    })
    BallTab:CreateSlider({
        name = "Reach size",
        range = { 1, 30 }, increment = 1,
        value = s.Ball.BallReachRange, flag = "fatal_reach_size",
        callback = function(v) s.Ball.BallReachRange = v end,
    })
    BallTab:CreateToggle({
        name = "Show reach visualizer",
        flag = "fatal_reach_vis", value = s.Ball.BallReachVisualizer,
        callback = function(v)
            s.Ball.BallReachVisualizer = v
            if v then
                enableReach()
            else
                removeReachHitbox()
                if not s.Ball.BallReach then disableReach() end
            end
        end,
    })

    BallTab:CreateSection({ name = "Speed" })
    BallTab:CreateToggle({
        name = "Speed boost", flag = "fatal_ws", value = s.Player.Walkspeed,
        callback = function(v) setSpeed(v) end,
    })
    BallTab:CreateKeybind({
        name = "Speed keybind",
        flag = "fatal_ws_key",
        value = s.Player.SpeedKeybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then
                s.Player.SpeedKeybind = key
            end
        end,
    })
    BallTab:CreateSlider({
        name = "Speed multiplier",
        range = { 1, 2.2 }, increment = 0.05,
        value = s.Player.WSvalue, flag = "fatal_ws_val",
        callback = function(v) s.Player.WSvalue = v end,
    })
    BallTab:CreateToggle({
        name = "tpwalk",
        description = "Teleport-walk; nudges your root part each frame for a smooth glide.",
        flag = "fatal_tpwalk", value = s.TPWalk.Enabled,
        callback = function(v) setTPWalk(v) end,
    })
    BallTab:CreateKeybind({
        name = "tpwalk keybind",
        flag = "fatal_tpwalk_key",
        value = s.TPWalk.Keybind,
        callback = function(key)
            if typeof(key) == "EnumItem" then s.TPWalk.Keybind = key end
        end,
    })
    BallTab:CreateSlider({
        name = "tpwalk speed",
        description = "Step distance per frame (0.001 – 0.06).",
        range = { 0.001, 0.06 }, increment = 0.001,
        value = s.TPWalk.Speed, flag = "fatal_tpwalk_speed",
        callback = function(v) s.TPWalk.Speed = v end,
    })

    VisualsTab:CreateSection({ name = "Aimbot Range Indicator" })
    VisualsTab:CreateToggle({
        name = "Aimbot range indicator",
        flag = "fatal_ind", value = s.Visuals.ShotIndicator,
        callback = setShotIndicator,
    })
    VisualsTab:CreateDropdown({
        name = "Indicator color",
        options = { "Blue", "Purple", "Green", "Red", "Yellow" },
        value = s.Visuals.IndicatorColor, flag = "fatal_ind_col",
        callback = function(v)
            s.Visuals.IndicatorColor = v
            applyIndicatorColor()
        end,
    })

    VisualsTab:CreateSection({ name = "Goal Effect" })
    local function getEffectNames()
        local names = {}
        for k in pairs(Effects) do table.insert(names, k) end
        table.sort(names)
        return names
    end
    VisualsTab:CreateDropdown({
        name = "Select effect",
        options = getEffectNames(), value = s.Goal.SelectedEffect,
        flag = "fatal_goal_sel",
        callback = function(v)
            s.Goal.SelectedEffect = v
            s.Goal.CurrentEffect = v
            if s.Goal.Enabled then pcall(applyGoalEffect) end
        end,
    })
    VisualsTab:CreateToggle({
        name = "Enable goal effect changer",
        flag = "fatal_goal", value = s.Goal.Enabled,
        callback = function(v)
            s.Goal.Enabled = v
            if v then pcall(applyGoalEffect) else pcall(resetGoalEffect) end
        end,
    })
    VisualsTab:CreateButton({
        name = "Reset goal effect",
        callback = function()
            s.Goal.Enabled = false
            s.Goal.SelectedEffect = "LightRay"
            s.Goal.CurrentEffect = "LightRay"
            pcall(resetGoalEffect)
        end,
    })

    VisualsTab:CreateSection({ name = "Nameplate & Title" })
    VisualsTab:CreateToggle({
        name = "Hide my nameplate & tags",
        flag = "fatal_np_hide", value = s.Visuals.HideOwnNameplate,
        callback = function(v)
            s.Visuals.HideOwnNameplate = v
            applyOwnNameplate()
        end,
    })
    VisualsTab:CreateInput({
        name = "Custom username", placeholder = "e.g. Nexoura",
        value = s.Visuals.CustomNameText, flag = "nexoura_np_name",
        callback = function(text)
            s.Visuals.CustomNameText = text
            s.Visuals.CustomName = (text ~= "")
            applyOwnNameplate()
        end,
    })
    VisualsTab:CreateInput({
        name = "Custom record", placeholder = "e.g. 99-0",
        value = s.Visuals.CustomRecordText, flag = "nexoura_np_rec",
        callback = function(text)
            s.Visuals.CustomRecordText = text
            s.Visuals.CustomRecord = (text ~= "")
            applyOwnNameplate()
        end,
    })
    VisualsTab:CreateInput({
        name = "Custom title", placeholder = "e.g. nexoura Elite",
        value = s.Visuals.CustomTitleText, flag = "nexoura_np_title",
        callback = function(text)
            s.Visuals.CustomTitleText = text
            s.Visuals.CustomTitle = (text ~= "")
            applyOwnNameplate()
        end,
    })

    PrivacyTab:CreateSection({ name = "Device Spoofer" })
    PrivacyTab:CreateToggle({
        name = "Device spoofer", flag = "nexoura_dev", value = s.Misc.DeviceSpoofer,
        callback = function(v)
            s.Misc.DeviceSpoofer = v
            SpoofDevice()
        end,
    })
    PrivacyTab:CreateDropdown({
        name = "Device",
        options = { "PC", "Mobile", "Gamepad" },
        value = s.Misc.Device, flag = "fatal_dev_sel",
        callback = function(v)
            s.Misc.Device = v
            SpoofDevice()
        end,
    })

    PrivacyTab:CreateSection({ name = "Ball Changer" })
    PrivacyTab:CreateDropdown({
        name = "Select ball",
        options = #BallNames > 0 and BallNames or { "None" },
        value = s.BallChanger.SelectedBall, flag = "fatal_ball_sel",
        callback = function(v)
            s.BallChanger.SelectedBall = v
            s.BallChanger.CurrentBall = v
            if s.BallChanger.Enabled then pcall(applyBallChanger) end
        end,
    })
    PrivacyTab:CreateToggle({
        name = "Enable ball changer",
        flag = "fatal_ball", value = s.BallChanger.Enabled,
        callback = function(v)
            s.BallChanger.Enabled = v
            if v then pcall(applyBallChanger) else pcall(resetBallChanger) end
        end,
    })
    PrivacyTab:CreateButton({
        name = "Reset ball",
        callback = function()
            s.BallChanger.Enabled = false
            s.BallChanger.SelectedBall = "ForceField"
            s.BallChanger.CurrentBall = "ForceField"
            pcall(resetBallChanger)
        end,
    })

    UtilityTab:CreateSection({ name = "Anti Moderator" })
    UtilityTab:CreateToggle({
        name = "Anti moderator",
        description = "Notifies when a moderator is in the server.",
        flag = "fatal_mod", value = s.Misc.AntiModerator,
        callback = function(v)
            s.Misc.AntiModerator = v
            if v then startAntiMod() else stopAntiMod() end
        end,
    })

    setAural = function(on)
        s.Shooting.AuralEnabled = (on == nil) and (not s.Shooting.AuralEnabled) or on
        MobileRefresh()
    end
    setGuard = function(on)
        s.Defending.AutoGuard = (on == nil) and (not s.Defending.AutoGuard) or on
        if s.Defending.AutoGuard then enableAutoGuard() else disableAutoGuard() end
        MobileRefresh()
    end
    setMagnet = function(on)
        s.Ball.BallMags = (on == nil) and (not s.Ball.BallMags) or on
        if s.Ball.BallMags then enableMagnet() else disableMagnet() end
        MobileRefresh()
    end
    setReach = function(on)
        s.Ball.BallReach = (on == nil) and (not s.Ball.BallReach) or on
        if s.Ball.BallReach then enableReach() else disableReach() end
        MobileRefresh()
    end
    setSpeed = function(on)
        s.Player.Walkspeed = (on == nil) and (not s.Player.Walkspeed) or on
        if s.Player.Walkspeed then enableSpeedBoost() else disableSpeedBoost() end
        MobileRefresh()
    end
    setTPWalk = function(on)
        s.TPWalk.Enabled = (on == nil) and (not s.TPWalk.Enabled) or on
        if s.TPWalk.Enabled then enableTPWalk() else disableTPWalk() end
        MobileRefresh()
    end
    setMagV2 = function(on)
        s.MagV2.Enabled = (on == nil) and (not s.MagV2.Enabled) or on
        if s.MagV2.Enabled then enableMagV2() else disableMagV2() end
        MobileRefresh()
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local magKey = s.Ball.MagnetKeybind
        if magKey and input.KeyCode == Enum.KeyCode[magKey] then
            setMagnet()
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local bind = s.Shooting.AuralKeybind
        local targetKey = (type(bind) == "string") and Enum.KeyCode[bind] or bind
        if input.KeyCode ~= targetKey then return end
        setAural()
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local bind = s.Defending.GuardKeybind
        local targetKey = (type(bind) == "string") and Enum.KeyCode[bind] or bind
        if input.KeyCode ~= targetKey then return end
        setGuard()
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local bind = s.Player.SpeedKeybind
        local targetKey = (type(bind) == "string") and Enum.KeyCode[bind] or bind
        if input.KeyCode ~= targetKey then return end
        setSpeed()
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local tpKey = s.TPWalk.Keybind
        if input.KeyCode ~= tpKey then return end
        setTPWalk()
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local magV2Key = s.MagV2.Keybind
        if input.KeyCode ~= magV2Key then return end
        setMagV2()
    end)

    if isMobile then
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NexuoraHubMobile"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 200
        pcall(function()
            if gethui then ScreenGui.Parent = gethui()
            else ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
        end)

        local Panel = Instance.new("Frame")
        Panel.Name = "Panel"
        Panel.Size = UDim2.fromOffset(52, 320)
        Panel.Position = UDim2.new(1, -64, 0.5, -160)
        Panel.BackgroundTransparency = 1
        Panel.Parent = ScreenGui

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Panel

        local function makeButton(label, order, onClick, isOn)
            local Button = Instance.new("TextButton")
            Button.Name = label
            Button.Size = UDim2.fromOffset(52, 40)
            Button.BackgroundColor3 = isOn and Color3.fromRGB(190, 165, 240) or Color3.fromRGB(26, 26, 28)
            Button.BackgroundTransparency = 0.05
            Button.Text = label
            Button.TextColor3 = isOn and Color3.fromRGB(20, 15, 30) or Color3.fromRGB(235, 230, 255)
            Button.TextSize = 12
            Button.Font = Enum.Font.GothamBold
            Button.AutoButtonColor = false
            Button.LayoutOrder = order
            Button.Parent = Panel
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(1, 0)
            Corner.Parent = Button
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = isOn and Color3.fromRGB(220, 200, 255) or Color3.fromRGB(100, 88, 130)
            Stroke.Thickness = 1.2
            Stroke.Transparency = 0.15
            Stroke.Parent = Button
            Button.MouseButton1Click:Connect(onClick)
            return Button, Stroke
        end

        local Aim, AimS = makeButton("Aim", 1, function() setAural() end, s.Shooting.AuralEnabled)
        local Guard, GuardS = makeButton("Guard", 2, function() setGuard() end, s.Defending.AutoGuard)
        local Mag, MagS = makeButton("Mag", 3, function() setMagnet() end, s.Ball.BallMags)
        local MagV2, MagV2S = makeButton("MagV2", 4, function() setMagV2() end, s.MagV2.Enabled)
        local Reach, ReachS = makeButton("Reach", 5, function() setReach() end, s.Ball.BallReach)
        local Speed, SpeedS = makeButton("Speed", 6, function() setSpeed() end, s.Player.Walkspeed)
        local TPW, TPWS = makeButton("TPWalk", 7, function() setTPWalk() end, s.TPWalk.Enabled)

        local function paint(btn, stroke, on)
            btn.BackgroundColor3 = on and Color3.fromRGB(190, 165, 240) or Color3.fromRGB(26, 26, 28)
            btn.TextColor3 = on and Color3.fromRGB(20, 15, 30) or Color3.fromRGB(235, 230, 255)
            stroke.Color = on and Color3.fromRGB(220, 200, 255) or Color3.fromRGB(100, 88, 130)
        end

        MobileRefresh = function()
            paint(Aim, AimS, s.Shooting.AuralEnabled)
            paint(Guard, GuardS, s.Defending.AutoGuard)
            paint(Mag, MagS, s.Ball.BallMags)
            paint(MagV2, MagV2S, s.MagV2.Enabled)
            paint(Reach, ReachS, s.Ball.BallReach)
            paint(Speed, SpeedS, s.Player.Walkspeed)
            paint(TPW, TPWS, s.TPWalk.Enabled)
        end

        local dragging = false
        local dragStart, startPos
        Panel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Panel.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        OnCleanup(function()
            pcall(function() ScreenGui:Destroy() end)
        end)
    end

    OnCleanup(function()
        pcall(disableAutoGuard)
        pcall(disableMagnet)
        pcall(disableMagV2)
        pcall(disableReach)
        pcall(disableSpeedBoost)
        pcall(disableTPWalk)
        pcall(resetBallChanger)
        pcall(resetGoalEffect)
        pcall(stopAntiMod)
        pcall(function() setShotIndicator(false) end)
        for _, c in Cleanup.conns do pcall(function() c:Disconnect() end) end
    end)
end
