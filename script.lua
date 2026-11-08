-- FATAL LABS — Arcade Basketball + Basketball Legends + Hoopz
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
        name = "Fatal Labs",
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
            Title = "Fatal Labs",
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
        name = "Fatal Labs",
        subtitle = "BL suite",
        size = UDim2.fromOffset(420, 320),
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
            Title = "Fatal Labs",
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
