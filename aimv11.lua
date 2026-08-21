local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/0x1f1e/uwu/main/drawing.lua"))()
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Settings = {
    Aimbot = {
        Enabled = false,
        Rage = true,
        Legit = false,
        Silent = false,
        Triggerbot = false,
        TargetMode = "Closest",
        AimBone = "Head",
        AimKey = "RightMouse",
        SmoothAim = false,
        Smoothness = 8,
        FOVRadius = 150,
        MaxDistance = 300,
        WallCheck = false,
        Prediction = true,
        PredictionAmount = 0.15,
        NoRecoil = false,
        AutoWall = false,
        TargetSwitch = false,
        HitboxExpansion = true,
        HitboxMultiplier = 1.5,
        Randomization = false,
        AimAssist = false,
        AimAssistStrength = 50,
        AntiAim = false,
        SpinBot = false,
        AutoShoot = true,
        AutoShootDelay = 0,
        VisibilityCheckFOV = false,
        PriorityTarget = "Khoảng cách",
        FastReload = true,
        RapidFire = true,
        FireDelay = 0.05,
        ReloadDelay = 0.1,
        AimLock = true,
        AutoReloadCancel = true,
        CrosshairTarget = true,
        MagicBullet = true,
        AimOnlyInFOV = true,
        ShootOnlyInFOV = true,
        TriggerbotOnlyInFOV = true,
        SilentAimOnlyInFOV = true,
        AutoShootOnlyInFOV = true,
        SmartAim = {
            Enabled = false,
            AutoAdaptFOV = false,
            LearnMovement = false,
            PriorityIntelligence = false,
            AutoSwitchSmart = false,
            AIPrediction = false,
            AccuracyBoost = false,
            SmartFOVAdjust = false,
            AntiFlicker = false,
            SmartSmoothness = 10,
            ShowAIPrediction = false,
            AutoLearnProfile = false
        },
        SmartDodge = {
            Enabled = false,
            AutoDodge = false,
            PredictiveDodge = false,
            DodgeWhileShooting = false,
            RandomDodge = false,
            DodgeToCover = false,
            SlideDodge = false,
            JumpDodge = false,
            CrouchDodge = false,
            AntiAimDodge = false,
            ShowDodgeNotification = false,
            DodgeSensitivity = 5,
            DodgeDistance = 5,
            DodgeSpeed = 1,
            DodgeOnlyWhenShotAt = false
        },
        FOVCustom = {
            ShowCircle = true,
            FOVColor = {R=0,G=255,B=0},
            Thickness = 3,
            Transparency = 0.5,
            AutoZoom = false
        },
        Crosshair = {
            Enabled = false,
            ShowOnEnemy = false,
            Color = {R=79,G=140,B=255},
            EnemyColor = {R=255,G=0,B=0},
            Size = 20,
            Thickness = 2,
            Gap = 5,
            Style = "Plus",
            ShowAlways = false
        },
        AimDraw = {
            Enabled = false,
            LineToEnemy = false,
            GlowOnEnemy = false,
            ArrowToEnemy = false,
            CrosshairOnEnemy = false,
            SkeletonOnEnemy = false,
            DistanceIndicator = false,
            HealthBar = false,
            LineColor = {R=255,G=255,B=255},
            GlowColor = {R=0,G=255,B=0},
            ArrowColor = {R=255,G=0,B=0},
            LineThickness = 2,
            GlowIntensity = 0.5,
            AutoAimToDraw = false
        },
        HitAnywhere = {
            Enabled = false,
            AutoAimOnShoot = false,
            HitChance = 80
        },
        SmartDetection = {
            SmartTeamCheck = true,
            SelfDetection = true,
            FriendDetection = false,
            AutoWhitelist = false,
            ShowTeamIndicator = false,
            Whitelist = {}
        },
        SelfDetection = {
            Enabled = true,
            ShowSelfESP = false,
            SelfColor = {R=255,G=255,B=0}
        }
    },
    ESP = {
        Enabled = false,
        Box2D = true,
        Box3D = false,
        Skeleton = false,
        Tracers = false,
        HealthBar = true,
        HealthPercent = true,
        Distance = true,
        Name = true,
        Weapon = true,
        HeadDot = false,
        TeamCheck = true,
        VisibilityCheck = false,
        MaxDistance = 200,
        Glow = false,
        Chams = false,
        RainbowChams = false,
        Fullbright = false,
        FadeOut = true,
        EnemyColor = {R=255,G=0,B=0},
        TeamColor = {R=0,G=255,B=0},
        VisibleColor = {R=255,G=255,B=255},
        OccludedColor = {R=255,G=165,B=0},
        HitboxViewer = false,
        DistanceMarker = true,
        ViewDirectionLine = false
    },
    World = {
        Enabled = false,
        ItemESP = false,
        VehicleESP = false,
        GrenadeESP = false,
        Radar = false,
        RadarSize = 100,
        RadarRange = 50,
        EnemyDotColor = {R=255,G=0,B=0},
        TeamDotColor = {R=0,G=255,B=0},
        SafeZoneESP = false,
        ContainerESP = false,
        TeleportToItem = false,
        TeleportToVehicle = false
    },
    Misc = {
        FixLag = false,
        RemoveDecals = false,
        RemoveParticles = false,
        RemoveTextures = false,
        RemoveClothing = false,
        CleanWorkspace = false,
        WalkSpeed = 16,
        JumpPower = 50,
        Fly = false,
        Noclip = false,
        InfiniteJump = false,
        AutoSave = true,
        ChatCommands = true,
        SpeedHack = false,
        Invisibility = false,
        GodMode = false,
        TeleportToPlayer = false,
        TeleportToWaypoint = false
    },
    UI = {
        Watermark = true,
        Notifications = true
    }
}

local GUI = nil
local MainFrame = nil
local Tabs = {}
local ContentFrames = {}
local FOVCircle = nil
local CrosshairDrawings = {}
local AimDrawObjects = {}
local Dragging = false
local DragStart = nil
local DragOffset = nil
local OpenButton = nil
local ESPDrawings = {}
local RadarDrawings = {}
local CurrentTarget = nil
local lastFireTime = 0
local lastReloadTime = 0
local DistanceMarkers = {}
local ESPObjects = {}
local VelocityCache = {}
local LastPosition = {}
local LastUpdateTime = {}

local function SaveSettings()
    if Settings.Misc.AutoSave then
        pcall(function()
            writefile("superhero_team_settings.json", HttpService:JSONEncode(Settings))
        end)
    end
end

local function LoadSettings()
    pcall(function()
        if isfile("superhero_team_settings.json") then
            local data = readfile("superhero_team_settings.json")
            local decoded = HttpService:JSONDecode(data)
            for k, v in pairs(decoded) do
                if type(v) == "table" and Settings[k] then
                    for k2, v2 in pairs(v) do
                        if Settings[k][k2] ~= nil then
                            Settings[k][k2] = v2
                        end
                    end
                end
            end
        end
    end)
end

LoadSettings()

local function SendNotification(title, text, duration)
    if not Settings.UI.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
end

local function CreateUI()
    GUI = Instance.new("ScreenGui")
    GUI.Name = "SuperheroTeam"
    GUI.Parent = game:GetService("CoreGui")
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false

    local viewportX = Camera.ViewportSize.X
    local viewportY = Camera.ViewportSize.Y
    local menuWidth = math.min(380, viewportX * 0.85)
    local menuHeight = math.min(460, viewportY * 0.85)

    MainFrame = Instance.new("Frame")
    MainFrame.Parent = GUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    MainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.9
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BackgroundTransparency = 0.2
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Active = true

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 10, 0, 5)
    TitleText.Size = UDim2.new(0, 140, 0, 30)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "Superhero Team"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Text = "✕"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.AutoButtonColor = false
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        if OpenButton then OpenButton.Visible = true end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BackgroundTransparency = 0.3
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 70, 1, -40)
    Sidebar.ClipsDescendants = true

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent = Sidebar
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 5)

    local TabNames = {"Aimbot", "ESP", "World", "Misc"}
    local TabIcons = {"🎯", "👁", "🌍", "⚙"}
    for i, tabName in ipairs(TabNames) do
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, -10, 0, 50)
        TabButton.Text = TabIcons[i] .. "\n" .. tabName
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 12
        TabButton.AutoButtonColor = false
        TabButton.TextWrapped = true
        TabButton.TextXAlignment = Enum.TextXAlignment.Center
        TabButton.TextYAlignment = Enum.TextYAlignment.Center
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        Tabs[tabName] = TabButton
    end

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.BackgroundTransparency = 0.15
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0, 70, 0, 40)
    ContentContainer.Size = UDim2.new(1, -70, 1, -40)

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Parent = ContentContainer
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.ClipsDescendants = true

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)

    for i, tabName in ipairs(TabNames) do
        local Content = Instance.new("Frame")
        Content.Parent = ScrollingFrame
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.Size = UDim2.new(1, -12, 0, 0)
        Content.Visible = (i == 1)
        ContentFrames[tabName] = Content

        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = Content
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 8)
    end

    local function SwitchTab(tabName)
        for name, content in pairs(ContentFrames) do
            content.Visible = (name == tabName)
        end
        for name, btn in pairs(Tabs) do
            if name == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        local target = ContentFrames[tabName]
        if target then
            target.Size = UDim2.new(1, -12, 0, 0)
            local totalHeight = 0
            for _, child in ipairs(target:GetChildren()) do
                if child:IsA("UIListLayout") then continue end
                totalHeight += child.Size.Y.Offset + 8
            end
            target.Size = UDim2.new(1, -12, 0, totalHeight)
        end
    end

    for name, btn in pairs(Tabs) do
        btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    end
    SwitchTab("Aimbot")
end

local function AddSection(parent, sectionName)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = parent
    SectionLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SectionLabel.BackgroundTransparency = 0.1
    SectionLabel.BorderSizePixel = 0
    SectionLabel.Size = UDim2.new(1, 0, 0, 25)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = sectionName
    SectionLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    SectionLabel.TextSize = 13
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    local secCorner = Instance.new("UICorner")
    secCorner.CornerRadius = UDim.new(0, 6)
    secCorner.Parent = SectionLabel
    return SectionLabel
end

local function CreateElementHolder(parent, text, description, height)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    holder.BackgroundTransparency = 0.1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, height or 45)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = holder

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 8, 0, 4)
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Parent = holder
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 8, 0, 22)
        descLabel.Size = UDim2.new(1, -16, 0, 18)
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        descLabel.TextSize = 11
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    return holder
end

local function CreateToggle(parent, text, description, settingPath)
    local holder = CreateElementHolder(parent, text, description, 45)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do value = value[key] end
        return value
    end

    local toggle = Instance.new("TextButton")
    toggle.Parent = holder
    toggle.BackgroundColor3 = GetValue() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(0.65, 0, 0, 10)
    toggle.Size = UDim2.new(0, 45, 0, 22)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 11)
    toggleCorner.Parent = toggle

    local function UpdateToggle()
        toggle.BackgroundColor3 = GetValue() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    end

    toggle.MouseButton1Click:Connect(function()
        local value = Settings
        for i, key in ipairs(settingPath) do
            if i == #settingPath then
                value[key] = not value[key]
            else
                value = value[key]
            end
        end
        UpdateToggle()
        SaveSettings()
        SendNotification("Cài đặt", text .. " đã " .. (GetValue() and "bật" or "tắt"))
    end)

    return holder
end

local function CreateSlider(parent, text, description, settingPath, min, max, step)
    local holder = CreateElementHolder(parent, text, description, 55)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do value = value[key] end
        return value
    end

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0.65, 0, 0, 5)
    label.Size = UDim2.new(0.25, 0, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(GetValue())
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center

    local slider = Instance.new("TextButton")
    slider.Parent = holder
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.BorderSizePixel = 0
    slider.Position = UDim2.new(0.65, 0, 0, 25)
    slider.Size = UDim2.new(0.25, 0, 0, 18)
    slider.Text = ""
    slider.AutoButtonColor = false
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 9)
    sliderCorner.Parent = slider

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((GetValue() - min) / (max - min), 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 9)
    fillCorner.Parent = fill

    local function UpdateSlider(input)
        local relative = input.Position.X - slider.AbsolutePosition.X
        local ratio = math.clamp(relative / slider.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * ratio
        if step == 1 then val = math.floor(val) else val = math.floor(val / step) * step end
        local value = Settings
        for i, key in ipairs(settingPath) do
            if i == #settingPath then value[key] = val else value = value[key] end
        end
        label.Text = tostring(val)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        SaveSettings()
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input)
            local connection
            connection = UserInputService.InputChanged:Connect(function(change)
                if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(change)
                end
            end)
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(change)
                if change.UserInputType == Enum.UserInputType.MouseButton1 or change.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)

    return holder
end

local function CreateDropdown(parent, text, description, settingPath, options)
    local holder = CreateElementHolder(parent, text, description, 50)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do value = value[key] end
        return value
    end

    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.65, 0, 0, 15)
    button.Size = UDim2.new(0.25, 0, 0, 22)
    button.Font = Enum.Font.Gotham
    button.Text = GetValue()
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    local dropdown = Instance.new("Frame")
    dropdown.Parent = holder
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.BorderSizePixel = 0
    dropdown.Position = UDim2.new(0.65, 0, 0, 42)
    dropdown.Size = UDim2.new(0.25, 0, 0, 0)
    dropdown.Visible = false
    dropdown.ZIndex = 5
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdown
    local dropList = Instance.new("UIListLayout")
    dropList.Parent = dropdown
    dropList.SortOrder = Enum.SortOrder.LayoutOrder
    dropList.Padding = UDim.new(0, 4)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = dropdown
        optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        optBtn.BorderSizePixel = 0
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        optBtn.TextSize = 12
        optBtn.AutoButtonColor = false
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn
        optBtn.MouseButton1Click:Connect(function()
            local value = Settings
            for i, key in ipairs(settingPath) do
                if i == #settingPath then value[key] = opt else value = value[key] end
            end
            button.Text = opt
            dropdown.Visible = false
            SaveSettings()
            SendNotification("Cài đặt", text .. " đã chọn " .. opt)
        end)
    end

    button.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
        dropdown.Size = UDim2.new(0.25, 0, 0, #options * 29)
    end)

    return holder
end

local function CreateColorPicker(parent, text, description, settingPath)
    local holder = CreateElementHolder(parent, text, description, 70)
    local function GetColor()
        local value = Settings
        for _, key in ipairs(settingPath) do value = value[key] end
        return value
    end

    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Color3.fromRGB(GetColor().R, GetColor().G, GetColor().B)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.65, 0, 0, 8)
    button.Size = UDim2.new(0.25, 0, 0, 22)
    button.Text = ""
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = button

    local RSlider = Instance.new("TextButton")
    RSlider.Parent = holder
    RSlider.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    RSlider.BorderSizePixel = 0
    RSlider.Position = UDim2.new(0.65, 0, 0, 35)
    RSlider.Size = UDim2.new(0.25, 0, 0, 8)
    RSlider.Text = ""
    RSlider.AutoButtonColor = false
    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 4)
    RCorner.Parent = RSlider

    local GSlider = Instance.new("TextButton")
    GSlider.Parent = holder
    GSlider.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    GSlider.BorderSizePixel = 0
    GSlider.Position = UDim2.new(0.65, 0, 0, 47)
    GSlider.Size = UDim2.new(0.25, 0, 0, 8)
    GSlider.Text = ""
    GSlider.AutoButtonColor = false
    local GCorner = Instance.new("UICorner")
    GCorner.CornerRadius = UDim.new(0, 4)
    GCorner.Parent = GSlider

    local BSlider = Instance.new("TextButton")
    BSlider.Parent = holder
    BSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    BSlider.BorderSizePixel = 0
    BSlider.Position = UDim2.new(0.65, 0, 0, 59)
    BSlider.Size = UDim2.new(0.25, 0, 0, 8)
    BSlider.Text = ""
    BSlider.AutoButtonColor = false
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = BSlider

    local function UpdateColor()
        button.BackgroundColor3 = Color3.fromRGB(GetColor().R, GetColor().G, GetColor().B)
    end

    local function SetupSlider(slider, component)
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local function Update(inputPos)
                    local relative = inputPos.X - slider.AbsolutePosition.X
                    local ratio = math.clamp(relative / slider.AbsoluteSize.X, 0, 1)
                    local val = math.floor(ratio * 255)
                    local color = GetColor()
                    color[component] = val
                    UpdateColor()
                    SaveSettings()
                end
                Update(input.Position)
                local connection
                connection = UserInputService.InputChanged:Connect(function(change)
                    if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                        Update(change.Position)
                    end
                end)
                local endConn
                endConn = UserInputService.InputEnded:Connect(function(change)
                    if change.UserInputType == Enum.UserInputType.MouseButton1 or change.UserInputType == Enum.UserInputType.Touch then
                        connection:Disconnect()
                        endConn:Disconnect()
                    end
                end)
            end
        end)
    end
    SetupSlider(RSlider, "R")
    SetupSlider(GSlider, "G")
    SetupSlider(BSlider, "B")
    UpdateColor()
    return holder
end

local function CreateButton(parent, text, description, callback)
    local holder = CreateElementHolder(parent, text, description, 45)
    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.65, 0, 0, 10)
    button.Size = UDim2.new(0.25, 0, 0, 22)
    button.Text = "Go"
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    button.MouseButton1Click:Connect(function()
        callback()
        SendNotification("Cài đặt", text .. " đã thực hiện")
    end)
    return holder
end

local function BuildUI()
    local aimbotContent = ContentFrames["Aimbot"]
    AddSection(aimbotContent, "CỔ ĐIỂN - Classic")
    CreateToggle(aimbotContent, "Enable Aimbot", "Bật/tắt toàn bộ hệ thống ngắm tự động", {"Aimbot", "Enabled"})
    CreateToggle(aimbotContent, "Rage Mode", "Ngắm và bắn cực nhanh, không cần giữ phím", {"Aimbot", "Rage"})
    CreateToggle(aimbotContent, "Legit Mode", "Ngắm tự nhiên, chỉ kích hoạt khi chạm màn hình", {"Aimbot", "Legit"})
    CreateToggle(aimbotContent, "Silent Aim", "Ngắm và bắn mà không xoay camera", {"Aimbot", "Silent"})
    CreateToggle(aimbotContent, "Triggerbot", "Tự động bắn ngay khi crosshair trùng vào kẻ địch", {"Aimbot", "Triggerbot"})
    CreateDropdown(aimbotContent, "Target Mode", "Chọn mục tiêu gần nhất, máu thấp nhất hoặc đe dọa cao nhất", {"Aimbot", "TargetMode"}, {"Closest", "LowestHealth", "HighestThreat"})
    CreateDropdown(aimbotContent, "Aim Bone", "Chọn bộ phận cơ thể sẽ ngắm vào, Random để khó đoán", {"Aimbot", "AimBone"}, {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Random"})

    AddSection(aimbotContent, "AIM THÔNG MINH - Smart Aim")
    CreateToggle(aimbotContent, "Enable Smart Aim", "Kích hoạt cơ chế học hỏi", {"Aimbot", "SmartAim", "Enabled"})
    CreateToggle(aimbotContent, "Auto Adapt FOV", "Tự động điều chỉnh FOV theo khoảng cách", {"Aimbot", "SmartAim", "AutoAdaptFOV"})
    CreateToggle(aimbotContent, "Learn Enemy Movement", "Học hành vi di chuyển của kẻ địch", {"Aimbot", "SmartAim", "LearnMovement"})
    CreateToggle(aimbotContent, "Priority Intelligence", "Ưu tiên mục tiêu nguy hiểm", {"Aimbot", "SmartAim", "PriorityIntelligence"})
    CreateToggle(aimbotContent, "Auto Switch Smart", "Tự chuyển mục tiêu nguy hiểm hơn", {"Aimbot", "SmartAim", "AutoSwitchSmart"})
    CreateToggle(aimbotContent, "Aim Prediction AI", "Dùng AI dự đoán vị trí", {"Aimbot", "SmartAim", "AIPrediction"})
    CreateToggle(aimbotContent, "Accuracy Boost", "Tăng độ chính xác khi xa", {"Aimbot", "SmartAim", "AccuracyBoost"})
    CreateToggle(aimbotContent, "Smart FOV Adjust", "Tự thu nhỏ FOV khi nhiều mục tiêu", {"Aimbot", "SmartAim", "SmartFOVAdjust"})
    CreateToggle(aimbotContent, "Anti-Flicker", "Chống giật khi chuyển mục tiêu", {"Aimbot", "SmartAim", "AntiFlicker"})
    CreateSlider(aimbotContent, "Smart Smoothness", "Độ mượt của Smart Aim", {"Aimbot", "SmartAim", "SmartSmoothness"}, 1, 20, 1)
    CreateToggle(aimbotContent, "Show AI Prediction", "Hiển thị chấm đỏ dự đoán", {"Aimbot", "SmartAim", "ShowAIPrediction"})
    CreateToggle(aimbotContent, "Auto Learn Profile", "Tạo hồ sơ cho từng kẻ địch", {"Aimbot", "SmartAim", "AutoLearnProfile"})

    AddSection(aimbotContent, "LÉ ĐẠN THÔNG MINH - Smart Dodge")
    CreateToggle(aimbotContent, "Enable Smart Dodge", "Bật hệ thống né đạn thông minh", {"Aimbot", "SmartDodge", "Enabled"})
    CreateToggle(aimbotContent, "Auto Dodge", "Tự động né", {"Aimbot", "SmartDodge", "AutoDodge"})
    CreateToggle(aimbotContent, "Predictive Dodge", "Né dự đoán", {"Aimbot", "SmartDodge", "PredictiveDodge"})
    CreateToggle(aimbotContent, "Dodge While Shooting", "Né trong khi bắn", {"Aimbot", "SmartDodge", "DodgeWhileShooting"})
    CreateToggle(aimbotContent, "Random Dodge", "Né ngẫu nhiên", {"Aimbot", "SmartDodge", "RandomDodge"})
    CreateToggle(aimbotContent, "Dodge to Cover", "Né vào chỗ nấp", {"Aimbot", "SmartDodge", "DodgeToCover"})
    CreateToggle(aimbotContent, "Slide Dodge", "Né trượt", {"Aimbot", "SmartDodge", "SlideDodge"})
    CreateToggle(aimbotContent, "Jump Dodge", "Né nhảy", {"Aimbot", "SmartDodge", "JumpDodge"})
    CreateToggle(aimbotContent, "Crouch Dodge", "Né cúi người", {"Aimbot", "SmartDodge", "CrouchDodge"})
    CreateToggle(aimbotContent, "Anti-Aim Dodge", "Kết hợp Anti-Aim khi né", {"Aimbot", "SmartDodge", "AntiAimDodge"})
    CreateToggle(aimbotContent, "Show Dodge Notification", "Hiện thông báo khi né", {"Aimbot", "SmartDodge", "ShowDodgeNotification"})
    CreateSlider(aimbotContent, "Dodge Sensitivity", "Độ nhạy né", {"Aimbot", "SmartDodge", "DodgeSensitivity"}, 1, 10, 1)
    CreateSlider(aimbotContent, "Dodge Distance", "Khoảng cách né (m)", {"Aimbot", "SmartDodge", "DodgeDistance"}, 1, 10, 1)
    CreateSlider(aimbotContent, "Dodge Speed", "Tốc độ né", {"Aimbot", "SmartDodge", "DodgeSpeed"}, 1, 3, 0.1)
    CreateToggle(aimbotContent, "Dodge Only When Shot At", "Chỉ né khi bị bắn", {"Aimbot", "SmartDodge", "DodgeOnlyWhenShotAt"})

    AddSection(aimbotContent, "FOV VÒNG TRÒN - FOV Circle")
    CreateToggle(aimbotContent, "Show FOV Circle", "Hiển thị vòng tròn FOV", {"Aimbot", "FOVCustom", "ShowCircle"})
    CreateColorPicker(aimbotContent, "FOV Color", "Màu vòng FOV", {"Aimbot", "FOVCustom", "FOVColor"})
    CreateSlider(aimbotContent, "FOV Thickness", "Độ dày vòng FOV", {"Aimbot", "FOVCustom", "Thickness"}, 1, 5, 1)
    CreateSlider(aimbotContent, "FOV Transparency", "Độ trong suốt vòng FOV", {"Aimbot", "FOVCustom", "Transparency"}, 0, 1, 0.05)
    CreateToggle(aimbotContent, "Auto Zoom FOV", "Tự động zoom FOV", {"Aimbot", "FOVCustom", "AutoZoom"})
    CreateSlider(aimbotContent, "FOV Radius", "Bán kính FOV", {"Aimbot", "FOVRadius"}, 10, 360, 1)

    AddSection(aimbotContent, "HIỆN ĐẠI - Modern")
    CreateToggle(aimbotContent, "Smooth Aim", "Làm mượt chuyển động ngắm", {"Aimbot", "SmoothAim"})
    CreateSlider(aimbotContent, "Smoothness", "Độ mượt khi ngắm", {"Aimbot", "Smoothness"}, 1, 20, 1)
    CreateToggle(aimbotContent, "Wall Check", "Không ngắm xuyên tường", {"Aimbot", "WallCheck"})
    CreateToggle(aimbotContent, "Prediction", "Dự đoán vị trí di chuyển", {"Aimbot", "Prediction"})
    CreateToggle(aimbotContent, "No Recoil", "Giảm giật khi bắn", {"Aimbot", "NoRecoil"})
    CreateToggle(aimbotContent, "Auto Wall", "Bắn xuyên tường", {"Aimbot", "AutoWall"})
    CreateToggle(aimbotContent, "Target Switch", "Tự chuyển mục tiêu", {"Aimbot", "TargetSwitch"})
    CreateToggle(aimbotContent, "Hitbox Expansion", "Mở rộng hitbox", {"Aimbot", "HitboxExpansion"})
    CreateSlider(aimbotContent, "Hitbox Size", "Kích thước hitbox", {"Aimbot", "HitboxMultiplier"}, 1, 10, 0.5)
    CreateToggle(aimbotContent, "Randomization", "Ngẫu nhiên hóa", {"Aimbot", "Randomization"})
    CreateToggle(aimbotContent, "Aim Assist", "Hỗ trợ ngắm nhẹ", {"Aimbot", "AimAssist"})
    CreateSlider(aimbotContent, "Aim Assist Strength", "Độ mạnh hỗ trợ ngắm", {"Aimbot", "AimAssistStrength"}, 0, 100, 1)

    AddSection(aimbotContent, "CROSSHAIR TÙY CHỈNH")
    CreateToggle(aimbotContent, "Enable Custom Crosshair", "Bật/tắt crosshair tùy chỉnh", {"Aimbot", "Crosshair", "Enabled"})
    CreateToggle(aimbotContent, "Show Crosshair on Enemy", "Đổi màu khi trỏ vào kẻ địch", {"Aimbot", "Crosshair", "ShowOnEnemy"})
    CreateColorPicker(aimbotContent, "Crosshair Color", "Màu crosshair", {"Aimbot", "Crosshair", "Color"})
    CreateColorPicker(aimbotContent, "Crosshair Color on Enemy", "Màu crosshair khi trỏ địch", {"Aimbot", "Crosshair", "EnemyColor"})
    CreateSlider(aimbotContent, "Crosshair Size", "Kích thước crosshair", {"Aimbot", "Crosshair", "Size"}, 10, 50, 1)
    CreateSlider(aimbotContent, "Crosshair Thickness", "Độ dày crosshair", {"Aimbot", "Crosshair", "Thickness"}, 1, 5, 1)
    CreateSlider(aimbotContent, "Crosshair Gap", "Khoảng cách giữa các nét", {"Aimbot", "Crosshair", "Gap"}, 0, 20, 1)
    CreateDropdown(aimbotContent, "Crosshair Style", "Kiểu crosshair", {"Aimbot", "Crosshair", "Style"}, {"Dot", "Plus", "Circle", "Cross", "Diamond", "Triangle"})
    CreateToggle(aimbotContent, "Show Crosshair Always", "Luôn hiển thị crosshair", {"Aimbot", "Crosshair", "ShowAlways"})

    AddSection(aimbotContent, "AIM DRAW ENEMY")
    CreateToggle(aimbotContent, "Enable Aim Draw", "Bật vẽ mục tiêu", {"Aimbot", "AimDraw", "Enabled"})
    CreateToggle(aimbotContent, "Draw Line to Enemy", "Vẽ đường đến mục tiêu", {"Aimbot", "AimDraw", "LineToEnemy"})
    CreateToggle(aimbotContent, "Draw Glow on Enemy", "Phát sáng mục tiêu", {"Aimbot", "AimDraw", "GlowOnEnemy"})
    CreateToggle(aimbotContent, "Draw Arrow to Enemy", "Vẽ mũi tên đến mục tiêu", {"Aimbot", "AimDraw", "ArrowToEnemy"})
    CreateToggle(aimbotContent, "Draw Crosshair on Enemy", "Vẽ chấm chéo trên mục tiêu", {"Aimbot", "AimDraw", "CrosshairOnEnemy"})
    CreateToggle(aimbotContent, "Draw Skeleton on Enemy", "Vẽ khung xương mục tiêu", {"Aimbot", "AimDraw", "SkeletonOnEnemy"})
    CreateToggle(aimbotContent, "Draw Distance Indicator", "Hiển thị khoảng cách", {"Aimbot", "AimDraw", "DistanceIndicator"})
    CreateToggle(aimbotContent, "Draw Health Bar", "Hiển thị thanh máu", {"Aimbot", "AimDraw", "HealthBar"})
    CreateColorPicker(aimbotContent, "Draw Line Color", "Màu đường vẽ", {"Aimbot", "AimDraw", "LineColor"})
    CreateColorPicker(aimbotContent, "Draw Glow Color", "Màu phát sáng", {"Aimbot", "AimDraw", "GlowColor"})
    CreateColorPicker(aimbotContent, "Draw Arrow Color", "Màu mũi tên", {"Aimbot", "AimDraw", "ArrowColor"})
    CreateSlider(aimbotContent, "Line Thickness", "Độ dày đường vẽ", {"Aimbot", "AimDraw", "LineThickness"}, 1, 5, 1)
    CreateSlider(aimbotContent, "Glow Intensity", "Độ mạnh phát sáng", {"Aimbot", "AimDraw", "GlowIntensity"}, 0, 1, 0.05)
    CreateToggle(aimbotContent, "Auto Aim to Draw Target", "Tự động ngắm mục tiêu được vẽ", {"Aimbot", "AimDraw", "AutoAimToDraw"})

    AddSection(aimbotContent, "QUY TẮC FOV")
    CreateToggle(aimbotContent, "Aim Only in FOV", "Chỉ ngắm trong FOV", {"Aimbot", "AimOnlyInFOV"})
    CreateToggle(aimbotContent, "Shoot Only in FOV", "Chỉ bắn trong FOV", {"Aimbot", "ShootOnlyInFOV"})
    CreateToggle(aimbotContent, "Triggerbot Only in FOV", "Triggerbot chỉ trong FOV", {"Aimbot", "TriggerbotOnlyInFOV"})
    CreateToggle(aimbotContent, "Silent Aim Only in FOV", "Silent Aim chỉ trong FOV", {"Aimbot", "SilentAimOnlyInFOV"})
    CreateToggle(aimbotContent, "Auto Shoot Only in FOV", "Auto Shoot chỉ trong FOV", {"Aimbot", "AutoShootOnlyInFOV"})

    AddSection(aimbotContent, "BẮN ĐÂU CŨNG TRÚNG - Hit Anywhere")
    CreateToggle(aimbotContent, "Enable Hit Anywhere", "Bật chế độ bắn trúng mọi nơi", {"Aimbot", "HitAnywhere", "Enabled"})
    CreateToggle(aimbotContent, "Auto Aim on Shoot", "Tự động ngắm khi bắn", {"Aimbot", "HitAnywhere", "AutoAimOnShoot"})
    CreateSlider(aimbotContent, "Hit Chance", "Tỉ lệ trúng (%)", {"Aimbot", "HitAnywhere", "HitChance"}, 50, 100, 1)

    AddSection(aimbotContent, "NHẬN DIỆN THÔNG MINH - Smart Detection")
    CreateToggle(aimbotContent, "Smart Team Check", "Không ngắm đồng đội", {"Aimbot", "SmartDetection", "SmartTeamCheck"})
    CreateToggle(aimbotContent, "Self Detection", "Không ngắm chính mình", {"Aimbot", "SmartDetection", "SelfDetection"})
    CreateToggle(aimbotContent, "Friend Detection", "Không ngắm bạn bè (whitelist)", {"Aimbot", "SmartDetection", "FriendDetection"})
    CreateToggle(aimbotContent, "Auto Whitelist", "Tự động thêm bạn vào whitelist", {"Aimbot", "SmartDetection", "AutoWhitelist"})
    CreateButton(aimbotContent, "Add Friend to Whitelist", "Thêm bạn vào whitelist", function()
        local target = CurrentTarget
        if target then
            table.insert(Settings.Aimbot.SmartDetection.Whitelist, target.UserId)
            SaveSettings()
            SendNotification("Smart Detection", "Đã thêm " .. target.Name .. " vào whitelist")
        end
    end)
    CreateButton(aimbotContent, "Remove Friend from Whitelist", "Xóa bạn khỏi whitelist", function()
        local target = CurrentTarget
        if target then
            for i, v in ipairs(Settings.Aimbot.SmartDetection.Whitelist) do
                if v == target.UserId then
                    table.remove(Settings.Aimbot.SmartDetection.Whitelist, i)
                    break
                end
            end
            SaveSettings()
            SendNotification("Smart Detection", "Đã xóa " .. target.Name .. " khỏi whitelist")
        end
    end)
    CreateToggle(aimbotContent, "Show Team Indicator", "Hiển thị chỉ báo đồng đội", {"Aimbot", "SmartDetection", "ShowTeamIndicator"})

    AddSection(aimbotContent, "TỰ NHẬN DIỆN BẢN THÂN - Self Detection")
    CreateToggle(aimbotContent, "Self Detection", "Tự nhận diện bản thân", {"Aimbot", "SelfDetection", "Enabled"})
    CreateToggle(aimbotContent, "Show Self ESP", "Hiển thị ESP cho bản thân", {"Aimbot", "SelfDetection", "ShowSelfESP"})
    CreateColorPicker(aimbotContent, "Self Color", "Màu cho bản thân", {"Aimbot", "SelfDetection", "SelfColor"})

    AddSection(aimbotContent, "NÂNG CAO - Advanced")
    CreateToggle(aimbotContent, "Anti-Aim", "Tự động xoay nhân vật để né đạn", {"Aimbot", "AntiAim"})
    CreateToggle(aimbotContent, "Spin Bot", "Xoay nhân vật liên tục", {"Aimbot", "SpinBot"})
    CreateToggle(aimbotContent, "Auto Shoot", "Tự động bắn khi mục tiêu trong FOV", {"Aimbot", "AutoShoot"})
    CreateSlider(aimbotContent, "Auto Shoot Delay", "Thời gian trễ trước khi bắn (ms)", {"Aimbot", "AutoShootDelay"}, 0, 500, 10)
    CreateToggle(aimbotContent, "Visibility Check for FOV", "Chỉ hiển thị FOV khi có mục tiêu", {"Aimbot", "VisibilityCheckFOV"})
    CreateDropdown(aimbotContent, "Priority Target", "Ưu tiên mục tiêu theo tiêu chí", {"Aimbot", "PriorityTarget"}, {"Distance", "Health", "Damage"})

    local espContent = ContentFrames["ESP"]
    AddSection(espContent, "CỔ ĐIỂN - Classic")
    CreateToggle(espContent, "Enable ESP", "Bật/tắt toàn bộ hệ thống hiển thị thông tin", {"ESP", "Enabled"})
    CreateToggle(espContent, "Box 2D", "Hiển thị khung hình chữ nhật 2D bao quanh người chơi", {"ESP", "Box2D"})
    CreateToggle(espContent, "Box 3D", "Hiển thị khung hình 3D bao quanh người chơi", {"ESP", "Box3D"})
    CreateToggle(espContent, "Skeleton", "Hiển thị khung xương cơ thể, hỗ trợ R6 và R15", {"ESP", "Skeleton"})
    CreateToggle(espContent, "Tracers", "Vẽ đường thẳng từ tâm màn hình đến mục tiêu", {"ESP", "Tracers"})
    CreateToggle(espContent, "Health Bar", "Hiển thị thanh máu bên cạnh người chơi", {"ESP", "HealthBar"})
    CreateToggle(espContent, "Health Percent", "Hiển thị phần trăm máu còn lại", {"ESP", "HealthPercent"})
    CreateToggle(espContent, "Distance", "Hiển thị khoảng cách từ bạn đến mục tiêu", {"ESP", "Distance"})
    CreateToggle(espContent, "Name", "Hiển thị tên người chơi phía trên", {"ESP", "Name"})
    CreateToggle(espContent, "Weapon", "Hiển thị tên vũ khí mà mục tiêu đang sử dụng", {"ESP", "Weapon"})
    CreateToggle(espContent, "Head Dot", "Hiển thị chấm tròn trên đầu mục tiêu", {"ESP", "HeadDot"})

    AddSection(espContent, "HIỆN ĐẠI - Modern")
    CreateToggle(espContent, "Team Check", "Tự động nhận diện đồng đội và kẻ địch", {"ESP", "TeamCheck"})
    CreateToggle(espContent, "Visibility Check", "Kiểm tra mục tiêu có bị che khuất không", {"ESP", "VisibilityCheck"})
    CreateSlider(espContent, "Max Distance", "Giới hạn khoảng cách tối đa để ESP hiển thị (m)", {"ESP", "MaxDistance"}, 5, 500, 5)
    CreateToggle(espContent, "Glow", "Làm phát sáng nhân vật, dễ nhìn xuyên tường", {"ESP", "Glow"})
    CreateToggle(espContent, "Chams", "Đổi màu nhân vật để nổi bật", {"ESP", "Chams"})
    CreateToggle(espContent, "Rainbow Chams", "Hiệu ứng cầu vồng đổi màu liên tục cho Chams", {"ESP", "RainbowChams"})
    CreateToggle(espContent, "Fullbright", "Sáng toàn bộ bản đồ", {"ESP", "Fullbright"})
    CreateToggle(espContent, "Fade Out", "ESP mờ dần khi mục tiêu ra xa", {"ESP", "FadeOut"})
    CreateColorPicker(espContent, "Enemy Color", "Màu sắc hiển thị cho kẻ địch", {"ESP", "EnemyColor"})
    CreateColorPicker(espContent, "Team Color", "Màu sắc hiển thị cho đồng đội", {"ESP", "TeamColor"})
    CreateColorPicker(espContent, "Visible Color", "Màu sắc khi mục tiêu hiện rõ", {"ESP", "VisibleColor"})
    CreateColorPicker(espContent, "Occluded Color", "Màu sắc khi mục tiêu bị che", {"ESP", "OccludedColor"})

    local worldContent = ContentFrames["World"]
    AddSection(worldContent, "WORLD ESP")
    CreateToggle(worldContent, "Item/Loot ESP", "Hiển thị vật phẩm và đồ rơi", {"World", "ItemESP"})
    CreateToggle(worldContent, "Vehicle ESP", "Hiển thị xe cộ xung quanh", {"World", "VehicleESP"})
    CreateToggle(worldContent, "Grenade ESP", "Hiển thị vị trí lựu đạn", {"World", "GrenadeESP"})
    CreateToggle(worldContent, "Radar", "Bản đồ radar thu nhỏ góc dưới màn hình", {"World", "Radar"})
    CreateSlider(worldContent, "Radar Size", "Điều chỉnh kích thước bản đồ radar", {"World", "RadarSize"}, 50, 200, 1)
    CreateSlider(worldContent, "Radar Range", "Phạm vi hiển thị của radar (m)", {"World", "RadarRange"}, 10, 100, 1)

    AddSection(worldContent, "WORLD NÂNG CAO")
    CreateToggle(worldContent, "Safe Zone ESP", "Hiển thị khu vực an toàn", {"World", "SafeZoneESP"})
    CreateToggle(worldContent, "Container ESP", "Hiển thị thùng đồ, hòm", {"World", "ContainerESP"})
    CreateToggle(worldContent, "Teleport to Item", "Dịch chuyển đến vật phẩm gần nhất", {"World", "TeleportToItem"})
    CreateToggle(worldContent, "Teleport to Vehicle", "Dịch chuyển đến xe gần nhất", {"World", "TeleportToVehicle"})

    CreateColorPicker(worldContent, "Enemy Dot", "Màu chấm của kẻ địch trên radar", {"World", "EnemyDotColor"})
    CreateColorPicker(worldContent, "Team Dot", "Màu chấm của đồng đội trên radar", {"World", "TeamDotColor"})

    local miscContent = ContentFrames["Misc"]
    AddSection(miscContent, "HIỆU SUẤT")
    CreateToggle(miscContent, "Fix Lag", "Tối ưu toàn bộ đồ họa và hiệu ứng", {"Misc", "FixLag"})
    CreateToggle(miscContent, "Remove Decals", "Xóa tất cả ảnh dán, nhãn dán", {"Misc", "RemoveDecals"})
    CreateToggle(miscContent, "Remove Particles", "Tắt tất cả hiệu ứng hạt, bụi, khói, lửa", {"Misc", "RemoveParticles"})
    CreateToggle(miscContent, "Remove Textures", "Xóa kết cấu bề mặt", {"Misc", "RemoveTextures"})
    CreateToggle(miscContent, "Remove Clothing", "Xóa quần áo, mặt mũi, tóc", {"Misc", "RemoveClothing"})
    CreateButton(miscContent, "Clean Workspace", "Dọn dẹp toàn bộ đối tượng rác", function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and v.Anchored and v.Size.Magnitude < 1 then v:Destroy() end
        end
        SendNotification("Misc", "Đã dọn dẹp workspace")
    end)

    AddSection(miscContent, "NGƯỜI CHƠI")
    CreateSlider(miscContent, "WalkSpeed", "Tốc độ di chuyển", {"Misc", "WalkSpeed"}, 16, 100, 1)
    CreateSlider(miscContent, "JumpPower", "Độ cao khi nhảy", {"Misc", "JumpPower"}, 50, 200, 1)
    CreateToggle(miscContent, "Fly", "Cho phép nhân vật bay tự do", {"Misc", "Fly"})
    CreateToggle(miscContent, "Noclip", "Đi xuyên tường và vật cản", {"Misc", "Noclip"})
    CreateToggle(miscContent, "Infinite Jump", "Nhảy liên tục không giới hạn", {"Misc", "InfiniteJump"})

    AddSection(miscContent, "TIỆN ÍCH")
    CreateToggle(miscContent, "Auto Save", "Tự động lưu cài đặt", {"Misc", "AutoSave"})
    CreateToggle(miscContent, "Chat Commands", "Cho phép lệnh chat để bật/tắt", {"Misc", "ChatCommands"})
    CreateToggle(miscContent, "Speed Hack", "Tăng tốc độ game", {"Misc", "SpeedHack"})
    CreateToggle(miscContent, "Invisibility", "Tàng hình nhân vật", {"Misc", "Invisibility"})
    CreateToggle(miscContent, "God Mode", "Bất tử", {"Misc", "GodMode"})
    CreateButton(miscContent, "Teleport to Player", "Dịch chuyển đến người chơi gần nhất", function()
        local nearest = nil
        local nearestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = p end
            end
        end
        if nearest then
            LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            SendNotification("Misc", "Đã teleport đến " .. nearest.Name)
        else
            SendNotification("Misc", "Không tìm thấy người chơi")
        end
    end)
    CreateButton(miscContent, "Teleport to Waypoint", "Dịch chuyển đến điểm đánh dấu", function()
        local wp = Instance.new("Part")
        wp.Size = Vector3.new(1,1,1)
        wp.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,0,-100)
        wp.Anchored = true
        wp.Transparency = 1
        wp.CanCollide = false
        wp.Parent = workspace
        task.wait(0.5)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(wp.Position)
        wp:Destroy()
        SendNotification("Misc", "Đã teleport đến waypoint")
    end)
end

CreateUI()
BuildUI()

local function IsTeamMate(player)
    if Settings.Aimbot.SmartDetection.SmartTeamCheck and player.Team == LocalPlayer.Team then return true end
    if Settings.Aimbot.SmartDetection.SelfDetection and player == LocalPlayer then return true end
    if Settings.Aimbot.SmartDetection.FriendDetection and table.find(Settings.Aimbot.SmartDetection.Whitelist, player.UserId) then return true end
    return false
end

local function GetBonePos(character, boneName)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    local part = character:FindFirstChild(boneName)
    if not part then return nil end
    return part.Position
end

local function GetVelocity(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return Vector3.zero end
    local now = tick()
    local lastPos = LastPosition[character]
    local lastTime = LastUpdateTime[character]
    if lastPos and lastTime then
        local dt = now - lastTime
        if dt > 0 and dt < 0.2 then
            local vel = (root.Position - lastPos) / dt
            VelocityCache[character] = vel
        end
    end
    LastPosition[character] = root.Position
    LastUpdateTime[character] = now
    return VelocityCache[character] or root.Velocity
end

local function IsVisible(target)
    if not Settings.Aimbot.WallCheck and not Settings.ESP.VisibilityCheck then return true end
    local character = target.Character
    if not character then return true end
    local head = character:FindFirstChild("Head")
    if not head then return true end
    local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
    local hit = workspace:Raycast(ray.Origin, ray.Direction)
    if hit and hit.Instance and not hit.Instance:IsDescendantOf(character) then
        return false
    end
    return true
end

local function GetAimbotTarget()
    if Settings.Aimbot.AimLock and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChildOfClass("Humanoid") and CurrentTarget.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
        local char = CurrentTarget.Character
        local bone = char:FindFirstChild(Settings.Aimbot.AimBone == "Random" and "Head" or Settings.Aimbot.AimBone)
        if bone then
            local dist = (Camera.CFrame.Position - bone.Position).Magnitude
            local screenPos, onScreen = Camera:WorldToViewportPoint(bone.Position)
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude <= Settings.Aimbot.FOVRadius / 2 and dist <= Settings.Aimbot.MaxDistance then
                return CurrentTarget
            end
        end
    end

    local target = nil
    local bestValue = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local maxFOV = Settings.Aimbot.FOVRadius / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeamMate(player) then continue end
        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if Settings.Aimbot.WallCheck and not IsVisible(player) then continue end

        local boneName = Settings.Aimbot.AimBone
        if boneName == "Random" then
            local bones = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
            boneName = bones[math.random(#bones)]
        end
        local bonePos = GetBonePos(character, boneName)
        if not bonePos then continue end

        local dist = (Camera.CFrame.Position - bonePos).Magnitude
        if dist > Settings.Aimbot.MaxDistance then continue end

        local predictedPos = bonePos
        if Settings.Aimbot.Prediction then
            predictedPos = bonePos + GetVelocity(character) * Settings.Aimbot.PredictionAmount
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if Settings.Aimbot.HitboxExpansion then
            screenDist = screenDist / Settings.Aimbot.HitboxMultiplier
        end

        if screenDist <= maxFOV then
            local value
            if Settings.Aimbot.PriorityTarget == "Health" then
                value = humanoid.Health
            elseif Settings.Aimbot.PriorityTarget == "Damage" then
                value = -math.huge
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then value = 0 end
            else
                value = screenDist
            end
            if value < bestValue then
                bestValue = value
                target = player
            end
        end
    end
    if target then CurrentTarget = target end
    return target or CurrentTarget
end

local function ActivateTool()
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Remotes")
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            else
                local fire = remote:FindFirstChild("FireServer") or remote:FindFirstChild("Shoot")
                if fire and fire:IsA("RemoteEvent") then
                    fire:FireServer()
                end
            end
        else
            tool:Activate()
        end
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

local function IsAimKeyPressed()
    local key = Settings.Aimbot.AimKey
    if key == "RightMouse" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "LeftMouse" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "LeftShift" then return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif key == "Q" then return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif key == "E" then return UserInputService:IsKeyDown(Enum.KeyCode.E)
    end
    return false
end

local function GetMouseTarget()
    local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player and player ~= LocalPlayer then
                return player
            end
        end
    end
    return nil
end

local lastFireTime = 0
local lastReloadTime = 0

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end

    local shouldAim = false
    if Settings.Aimbot.Rage then shouldAim = true end
    if Settings.Aimbot.Legit then shouldAim = IsAimKeyPressed() or (UserInputService.TouchEnabled and UserInputService.TouchCount > 0) end
    if Settings.Aimbot.Silent then shouldAim = false end

    if Settings.Aimbot.Triggerbot and (not Settings.Aimbot.TriggerbotOnlyInFOV or GetAimbotTarget() ~= nil) then
        local mouseTarget = GetMouseTarget()
        if mouseTarget then ActivateTool() end
    end

    if Settings.Aimbot.Silent and Settings.Aimbot.AutoShoot and (not Settings.Aimbot.SilentAimOnlyInFOV or GetAimbotTarget() ~= nil) then
        local target = GetAimbotTarget()
        if target then ActivateTool() end
    end

    if shouldAim or (Settings.Aimbot.AutoShoot and Settings.Aimbot.Rage and (not Settings.Aimbot.AutoShootOnlyInFOV or GetAimbotTarget() ~= nil)) then
        local target = GetAimbotTarget()
        if target then
            local character = target.Character
            local boneName = Settings.Aimbot.AimBone
            if boneName == "Random" then boneName = "Head" end
            local bonePos = GetBonePos(character, boneName)
            if bonePos then
                local predictedPos = bonePos
                if Settings.Aimbot.Prediction then predictedPos = bonePos + GetVelocity(character) * Settings.Aimbot.PredictionAmount end

                local dist = (Camera.CFrame.Position - predictedPos).Magnitude
                local smoothness = Settings.Aimbot.SmoothAim and math.clamp(Settings.Aimbot.Smoothness / (1 + dist / 200), 1, 20) or 1
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, predictedPos)

                if Settings.Aimbot.SmoothAim then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / smoothness)
                else
                    Camera.CFrame = targetCF
                end

                if Settings.Aimbot.AutoShoot and (Settings.Aimbot.Rage or Settings.Aimbot.Legit) then
                    local now = tick()
                    if now - lastFireTime >= Settings.Aimbot.FireDelay then
                        ActivateTool()
                        lastFireTime = now
                    end
                end
            end
        end
    end
end

local function RapidFireSystem()
    if not Settings.Aimbot.RapidFire or not Settings.Aimbot.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local now = tick()
    if now - lastFireTime >= Settings.Aimbot.FireDelay then
        ActivateTool()
        lastFireTime = now
    end
end

local function FastReloadSystem()
    if not Settings.Aimbot.FastReload or not Settings.Aimbot.Enabled then return end
    if Settings.Aimbot.AutoReloadCancel then
        local target = GetAimbotTarget()
        if target then
            ActivateTool()
            return
        end
    end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local remote = tool:FindFirstChild("Reload") or tool:FindFirstChild("ReloadRemote")
    if remote and remote:IsA("RemoteEvent") then
        local now = tick()
        if now - lastReloadTime >= Settings.Aimbot.ReloadDelay then
            remote:FireServer()
            lastReloadTime = now
        end
    else
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local anim = humanoid:LoadAnimation(tool)
            if anim then anim:Play() end
        end
    end
end

local function MagicBulletSystem()
    if not Settings.Aimbot.MagicBullet or not Settings.Aimbot.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local target = GetAimbotTarget()
    if target and target.Character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Remotes")
            if remote then
                local fire = remote:IsA("RemoteEvent") and remote or (remote:FindFirstChild("FireServer") or remote:FindFirstChild("Shoot"))
                if fire and fire:IsA("RemoteEvent") then
                    fire:FireServer(target.Character)
                end
            end
        end
    end
end

local function DrawFOVCircle()
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
    end
    if Settings.Aimbot.FOVCustom.ShowCircle and Settings.Aimbot.Enabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.Aimbot.FOVRadius / 2
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Thickness = Settings.Aimbot.FOVCustom.Thickness
        FOVCircle.Color = Color3.fromRGB(Settings.Aimbot.FOVCustom.FOVColor.R, Settings.Aimbot.FOVCustom.FOVColor.G, Settings.Aimbot.FOVCustom.FOVColor.B)
        FOVCircle.Transparency = 1 - Settings.Aimbot.FOVCustom.Transparency
        FOVCircle.Filled = false
    else
        FOVCircle.Visible = false
    end
end

local function DrawCustomCrosshair()
    for _, d in pairs(CrosshairDrawings) do d:Remove() end
    CrosshairDrawings = {}
    if not (Settings.Aimbot.Crosshair.Enabled or Settings.Aimbot.Crosshair.ShowAlways) then return end
    local style = Settings.Aimbot.Crosshair.Style
    local size = Settings.Aimbot.Crosshair.Size
    local thickness = Settings.Aimbot.Crosshair.Thickness
    local gap = Settings.Aimbot.Crosshair.Gap
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local color = Settings.Aimbot.Crosshair.Color
    local function addLine(from, to)
        local l = Drawing.new("Line")
        l.Color = Color3.fromRGB(color.R, color.G, color.B)
        l.Thickness = thickness
        l.From = from
        l.To = to
        l.Visible = true
        table.insert(CrosshairDrawings, l)
    end
    if style == "Plus" or style == "Cross" then
        addLine(center - Vector2.new(gap, 0), center - Vector2.new(gap + size, 0))
        addLine(center + Vector2.new(gap, 0), center + Vector2.new(gap + size, 0))
        addLine(center - Vector2.new(0, gap), center - Vector2.new(0, gap + size))
        addLine(center + Vector2.new(0, gap), center + Vector2.new(0, gap + size))
    elseif style == "Dot" then
        local c = Drawing.new("Circle")
        c.Color = Color3.fromRGB(color.R, color.G, color.B)
        c.Thickness = 0
        c.Filled = true
        c.Radius = size / 4
        c.Position = center
        c.Visible = true
        table.insert(CrosshairDrawings, c)
    elseif style == "Circle" then
        local c = Drawing.new("Circle")
        c.Color = Color3.fromRGB(color.R, color.G, color.B)
        c.Thickness = thickness
        c.Filled = false
        c.Radius = size
        c.Position = center
        c.Visible = true
        table.insert(CrosshairDrawings, c)
    end
end

local function UpdateAimDraw()
    for _, d in pairs(AimDrawObjects) do d:Remove() end
    AimDrawObjects = {}
    if not Settings.Aimbot.AimDraw.Enabled or not Settings.Aimbot.Enabled then return end
    local target = CurrentTarget or GetAimbotTarget()
    if target and target.Character then
        local character = target.Character
        local head = character:FindFirstChild("Head")
        local root = character:FindFirstChild("HumanoidRootPart")
        if head and root then
            local screenHead, onHead = Camera:WorldToViewportPoint(head.Position)
            local screenRoot, onRoot = Camera:WorldToViewportPoint(root.Position)
            if onHead and onRoot then
                if Settings.Aimbot.AimDraw.LineToEnemy then
                    local line = Drawing.new("Line")
                    line.Color = Color3.fromRGB(Settings.Aimbot.AimDraw.LineColor.R, Settings.Aimbot.AimDraw.LineColor.G, Settings.Aimbot.AimDraw.LineColor.B)
                    line.Thickness = Settings.Aimbot.AimDraw.LineThickness
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    line.To = Vector2.new(screenHead.X, screenHead.Y)
                    line.Visible = true
                    table.insert(AimDrawObjects, line)
                end
                if Settings.Aimbot.AimDraw.CrosshairOnEnemy then
                    local l1 = Drawing.new("Line")
                    l1.Color = Color3.fromRGB(Settings.Aimbot.AimDraw.ArrowColor.R, Settings.Aimbot.AimDraw.ArrowColor.G, Settings.Aimbot.AimDraw.ArrowColor.B)
                    l1.Thickness = 2
                    l1.From = Vector2.new(screenHead.X - 10, screenHead.Y)
                    l1.To = Vector2.new(screenHead.X + 10, screenHead.Y)
                    l1.Visible = true
                    table.insert(AimDrawObjects, l1)
                    local l2 = Drawing.new("Line")
                    l2.Color = Color3.fromRGB(Settings.Aimbot.AimDraw.ArrowColor.R, Settings.Aimbot.AimDraw.ArrowColor.G, Settings.Aimbot.AimDraw.ArrowColor.B)
                    l2.Thickness = 2
                    l2.From = Vector2.new(screenHead.X, screenHead.Y - 10)
                    l2.To = Vector2.new(screenHead.X, screenHead.Y + 10)
                    l2.Visible = true
                    table.insert(AimDrawObjects, l2)
                end
                if Settings.Aimbot.AimDraw.HealthBar then
                    local hb = Drawing.new("Square")
                    hb.Color = Color3.fromRGB(0, 255, 0)
                    hb.Thickness = 2
                    hb.Filled = true
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local health = humanoid.Health / humanoid.MaxHealth
                        hb.Position = Vector2.new(screenRoot.X - 20, screenRoot.Y - 50)
                        hb.Size = Vector2.new(40 * health, 5)
                        hb.Visible = true
                    end
                    table.insert(AimDrawObjects, hb)
                end
            end
        end
    end
end

local function HitAnywhereSystem()
    if not Settings.Aimbot.HitAnywhere.Enabled or not Settings.Aimbot.Enabled then return end
    local target = GetAimbotTarget()
    if target and target.Character then
        local chance = Settings.Aimbot.HitAnywhere.HitChance
        if math.random(100) <= chance then
            ActivateTool()
        end
    end
end

local function SmartDodgeSystem()
    if not Settings.Aimbot.SmartDodge.Enabled or not Settings.Aimbot.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if Settings.Aimbot.SmartDodge.DodgeOnlyWhenShotAt then
        local danger = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Bullet" or v.Name == "Projectile" then
                local dist = (root.Position - v.Position).Magnitude
                if dist < Settings.Aimbot.SmartDodge.DodgeDistance * 10 then
                    danger = true
                    break
                end
            end
        end
        if not danger then return end
    end
    if Settings.Aimbot.SmartDodge.RandomDodge then
        local directions = {Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)}
        local dir = directions[math.random(4)]
        root.Velocity = dir * Settings.Aimbot.SmartDodge.DodgeSpeed * 10
    elseif Settings.Aimbot.SmartDodge.JumpDodge then
        root.Velocity = Vector3.new(0, Settings.Aimbot.SmartDodge.DodgeSpeed * 10, 0)
    elseif Settings.Aimbot.SmartDodge.CrouchDodge then
        root.CFrame = root.CFrame * CFrame.new(0, -0.5, 0)
    end
end

local function CreateESPObject(player)
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local obj = { Player = player, Drawings = {} }

    local function newDrawing(type)
        local d = Drawing.new(type)
        d.Visible = false
        table.insert(obj.Drawings, d)
        return d
    end

    if Settings.ESP.Box2D then obj.Box2D = newDrawing("Square") end
    if Settings.ESP.Box3D then obj.Box3D = newDrawing("Square") end
    if Settings.ESP.Skeleton then
        obj.SkeletonLines = {}
        local bonePairs = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"}
        }
        for _ = 1, #bonePairs do
            local line = newDrawing("Line")
            table.insert(obj.SkeletonLines, line)
        end
    end
    if Settings.ESP.Tracers then obj.Tracer = newDrawing("Line") end
    if Settings.ESP.HealthBar then obj.HealthBar = newDrawing("Square") end
    if Settings.ESP.HealthPercent then obj.HealthText = newDrawing("Text") end
    if Settings.ESP.Distance then obj.DistanceText = newDrawing("Text") end
    if Settings.ESP.Name then obj.NameText = newDrawing("Text") end
    if Settings.ESP.Weapon then obj.WeaponText = newDrawing("Text") end
    if Settings.ESP.HeadDot then obj.HeadDot = newDrawing("Circle") end
    if Settings.ESP.HitboxViewer then
        obj.Hitboxes = {}
        local hitboxParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
        for _, partName in ipairs(hitboxParts) do
            local hb = newDrawing("Square")
            obj.Hitboxes[partName] = hb
        end
    end
    if Settings.ESP.ViewDirectionLine then obj.ViewLine = newDrawing("Line") end

    return obj
end

local function RemoveESPObject(player)
    local obj = ESPObjects[player]
    if obj then
        for _, d in ipairs(obj.Drawings) do
            d:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESPObject(obj)
    local player = obj.Player
    local character = player.Character
    if not character then
        RemoveESPObject(player)
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, d in ipairs(obj.Drawings) do d.Visible = false end
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        for _, d in ipairs(obj.Drawings) do d.Visible = false end
        return
    end

    local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
    local isVisible = IsVisible(player)
    local isTeam = IsTeamMate(player)

    if Settings.ESP.TeamCheck and isTeam then
        for _, d in ipairs(obj.Drawings) do d.Visible = false end
        return
    end

    if dist > Settings.ESP.MaxDistance then
        for _, d in ipairs(obj.Drawings) do d.Visible = false end
        return
    end

    local color
    if Settings.ESP.VisibilityCheck then
        if isVisible then
            color = Color3.fromRGB(Settings.ESP.VisibleColor.R, Settings.ESP.VisibleColor.G, Settings.ESP.VisibleColor.B)
        else
            color = Color3.fromRGB(Settings.ESP.OccludedColor.R, Settings.ESP.OccludedColor.G, Settings.ESP.OccludedColor.B)
        end
    else
        if isTeam then
            color = Color3.fromRGB(Settings.ESP.TeamColor.R, Settings.ESP.TeamColor.G, Settings.ESP.TeamColor.B)
        else
            color = Color3.fromRGB(Settings.ESP.EnemyColor.R, Settings.ESP.EnemyColor.G, Settings.ESP.EnemyColor.B)
        end
    end

    local alpha = 1
    if Settings.ESP.FadeOut then
        alpha = math.clamp(1 - (dist / Settings.ESP.MaxDistance), 0.2, 1)
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        for _, d in ipairs(obj.Drawings) do d.Visible = false end
        return
    end

    local size = math.clamp(2000 / dist, 10, 200)

    if obj.Box2D then
        obj.Box2D.Visible = true
        obj.Box2D.Color = color
        obj.Box2D.Transparency = 1 - alpha
        obj.Box2D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size)
        obj.Box2D.Size = Vector2.new(size, size)
    end

    if obj.Box3D then
        obj.Box3D.Visible = true
        obj.Box3D.Color = color
        obj.Box3D.Transparency = 1 - alpha
        obj.Box3D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size*2)
        obj.Box3D.Size = Vector2.new(size, size*2)
    end

    if obj.SkeletonLines then
        local bonePairs = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"}
        }
        for i, pair in ipairs(bonePairs) do
            local line = obj.SkeletonLines[i]
            local partA = character:FindFirstChild(pair[1])
            local partB = character:FindFirstChild(pair[2])
            if partA and partB then
                local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                local posB, onB = Camera:WorldToViewportPoint(partB.Position)
                if onA and onB then
                    line.Visible = true
                    line.Color = color
                    line.Transparency = 1 - alpha
                    line.From = Vector2.new(posA.X, posA.Y)
                    line.To = Vector2.new(posB.X, posB.Y)
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end

    if obj.Tracer then
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        obj.Tracer.Visible = true
        obj.Tracer.Color = color
        obj.Tracer.Transparency = 1 - alpha
        obj.Tracer.From = center
        obj.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    end

    if obj.HealthBar then
        local health = humanoid.Health / humanoid.MaxHealth
        obj.HealthBar.Visible = true
        obj.HealthBar.Color = color
        obj.HealthBar.Transparency = 1 - alpha
        obj.HealthBar.Position = Vector2.new(screenPos.X - size/2 - 5, screenPos.Y - size)
        obj.HealthBar.Size = Vector2.new(4, size * health)
    end

    if obj.HealthText then
        obj.HealthText.Visible = true
        obj.HealthText.Color = Color3.fromRGB(255, 255, 255)
        obj.HealthText.Transparency = 1 - alpha
        obj.HealthText.Text = tostring(math.floor(humanoid.Health / humanoid.MaxHealth * 100)) .. "%"
        obj.HealthText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 5)
        obj.HealthText.Size = 14
        obj.HealthText.Center = true
    end

    if obj.DistanceText then
        obj.DistanceText.Visible = true
        obj.DistanceText.Color = Color3.fromRGB(255, 255, 255)
        obj.DistanceText.Transparency = 1 - alpha
        obj.DistanceText.Text = string.format("%.0f m", dist)
        obj.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 5)
        obj.DistanceText.Size = 14
        obj.DistanceText.Center = true
    end

    if obj.NameText then
        obj.NameText.Visible = true
        obj.NameText.Color = color
        obj.NameText.Transparency = 1 - alpha
        obj.NameText.Text = player.Name
        obj.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 20)
        obj.NameText.Size = 14
        obj.NameText.Center = true
    end

    if obj.WeaponText then
        local tool = character:FindFirstChildOfClass("Tool")
        local weaponName = tool and tool.Name or "Tay không"
        obj.WeaponText.Visible = true
        obj.WeaponText.Color = color
        obj.WeaponText.Transparency = 1 - alpha
        obj.WeaponText.Text = weaponName
        obj.WeaponText.Position = Vector2.new(screenPos.X, screenPos.Y + size + 5)
        obj.WeaponText.Size = 14
        obj.WeaponText.Center = true
    end

    if obj.HeadDot then
        local head = character:FindFirstChild("Head")
        if head then
            local headScreen, headOn = Camera:WorldToViewportPoint(head.Position)
            if headOn then
                obj.HeadDot.Visible = true
                obj.HeadDot.Color = color
                obj.HeadDot.Transparency = 1 - alpha
                obj.HeadDot.Radius = 5
                obj.HeadDot.Position = Vector2.new(headScreen.X, headScreen.Y)
            else
                obj.HeadDot.Visible = false
            end
        else
            obj.HeadDot.Visible = false
        end
    end

    if obj.Hitboxes then
        for partName, hb in pairs(obj.Hitboxes) do
            local part = character:FindFirstChild(partName)
            if part then
                local partScreen, partOn = Camera:WorldToViewportPoint(part.Position)
                if partOn then
                    local partSize = math.clamp(100 / dist, 2, 20)
                    hb.Visible = true
                    hb.Color = color
                    hb.Transparency = 1 - alpha
                    hb.Position = Vector2.new(partScreen.X - partSize/2, partScreen.Y - partSize/2)
                    hb.Size = Vector2.new(partSize, partSize)
                else
                    hb.Visible = false
                end
            else
                hb.Visible = false
            end
        end
    end

    if obj.ViewLine then
        local head = character:FindFirstChild("Head")
        if head then
            local direction = head.CFrame.LookVector * 10
            local endPos = head.Position + direction
            local startScreen, startOn = Camera:WorldToViewportPoint(head.Position)
            local endScreen, endOn = Camera:WorldToViewportPoint(endPos)
            if startOn and endOn then
                obj.ViewLine.Visible = true
                obj.ViewLine.Color = Color3.fromRGB(255, 255, 0)
                obj.ViewLine.Transparency = 1 - alpha
                obj.ViewLine.From = Vector2.new(startScreen.X, startScreen.Y)
                obj.ViewLine.To = Vector2.new(endScreen.X, endScreen.Y)
            else
                obj.ViewLine.Visible = false
            end
        else
            obj.ViewLine.Visible = false
        end
    end
end

local function UpdateAllESP()
    if not Settings.ESP.Enabled then
        for _, obj in pairs(ESPObjects) do
            for _, d in ipairs(obj.Drawings) do d.Visible = false end
        end
        return
    end

    for player, obj in pairs(ESPObjects) do
        if not player.Parent then
            RemoveESPObject(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not ESPObjects[player] then
            local obj = CreateESPObject(player)
            if obj then
                ESPObjects[player] = obj
            end
        end
        if ESPObjects[player] then
            UpdateESPObject(ESPObjects[player])
        end
    end
end

local function UpdateDistanceMarkers()
    for _, d in pairs(DistanceMarkers) do d:Remove() end
    DistanceMarkers = {}
    if not Settings.ESP.DistanceMarker or not Settings.ESP.Enabled then return end
    local markers = {10, 25, 50, 100, 200, 300}
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y - 50
    for i, dist in ipairs(markers) do
        local text = Drawing.new("Text")
        text.Text = dist .. "m"
        text.Color = Color3.fromRGB(255, 255, 255)
        text.Size = 12
        text.Center = true
        text.Visible = true
        text.Position = Vector2.new(centerX, centerY - i * 15)
        DistanceMarkers[#DistanceMarkers + 1] = text
    end
end

local function UpdateGlowAndChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if not character then continue end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Settings.ESP.Glow then
                    local glow = part:FindFirstChildOfClass("Highlight")
                    if not glow then
                        glow = Instance.new("Highlight")
                        glow.Parent = part
                    end
                    if IsTeamMate(player) then
                        glow.FillColor = Color3.fromRGB(Settings.ESP.TeamColor.R, Settings.ESP.TeamColor.G, Settings.ESP.TeamColor.B)
                        glow.OutlineColor = glow.FillColor
                    else
                        glow.FillColor = Color3.fromRGB(Settings.ESP.EnemyColor.R, Settings.ESP.EnemyColor.G, Settings.ESP.EnemyColor.B)
                        glow.OutlineColor = glow.FillColor
                    end
                else
                    local glow = part:FindFirstChildOfClass("Highlight")
                    if glow then glow:Destroy() end
                end
                if Settings.ESP.Chams then
                    if Settings.ESP.RainbowChams then
                        local hue = tick() % 5 / 5
                        part.Color = Color3.fromHSV(hue, 1, 1)
                        part.Material = Enum.Material.ForceField
                    else
                        if IsTeamMate(player) then
                            part.Color = Color3.fromRGB(Settings.ESP.TeamColor.R, Settings.ESP.TeamColor.G, Settings.ESP.TeamColor.B)
                        else
                            part.Color = Color3.fromRGB(Settings.ESP.EnemyColor.R, Settings.ESP.EnemyColor.G, Settings.ESP.EnemyColor.B)
                        end
                        part.Material = Enum.Material.ForceField
                    end
                end
            end
        end
    end
end

local function WorldESP()
    if not Settings.World.Enabled then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if Settings.World.ItemESP and v:IsA("Tool") then
            local part = v:FindFirstChild("Handle")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    if dist < 100 then
                        local box = Drawing.new("Square")
                        box.Color = Color3.fromRGB(255, 255, 0)
                        box.Thickness = 1
                        box.Filled = false
                        box.Position = Vector2.new(screenPos.X - 10, screenPos.Y - 10)
                        box.Size = Vector2.new(20, 20)
                        box.Visible = true
                        ESPDrawings[#ESPDrawings + 1] = box
                    end
                end
            end
        end
        if Settings.World.VehicleESP and v:IsA("VehicleSeat") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Position)
            if onScreen then
                local box = Drawing.new("Square")
                box.Color = Color3.fromRGB(255, 165, 0)
                box.Thickness = 2
                box.Filled = false
                box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                box.Size = Vector2.new(40, 40)
                box.Visible = true
                ESPDrawings[#ESPDrawings + 1] = box
            end
        end
        if Settings.World.GrenadeESP and (v.Name == "Grenade" or v.Name == "Projectile") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Position)
            if onScreen then
                local circle = Drawing.new("Circle")
                circle.Color = Color3.fromRGB(255, 0, 255)
                circle.Thickness = 2
                circle.Filled = false
                circle.Radius = 8
                circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                circle.Visible = true
                ESPDrawings[#ESPDrawings + 1] = circle
            end
        end
        if Settings.World.SafeZoneESP and v:IsA("SpawnLocation") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Position)
            if onScreen then
                local circle = Drawing.new("Circle")
                circle.Color = Color3.fromRGB(0, 255, 0)
                circle.Thickness = 2
                circle.Filled = false
                circle.Radius = 10
                circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                circle.Visible = true
                ESPDrawings[#ESPDrawings + 1] = circle
            end
        end
        if Settings.World.ContainerESP and (v.Name == "Chest" or v.Name == "Container" or (v:IsA("Model") and v.Name:lower():find("crate"))) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Position)
            if onScreen then
                local box = Drawing.new("Square")
                box.Color = Color3.fromRGB(0, 255, 255)
                box.Thickness = 2
                box.Filled = false
                box.Position = Vector2.new(screenPos.X - 15, screenPos.Y - 15)
                box.Size = Vector2.new(30, 30)
                box.Visible = true
                ESPDrawings[#ESPDrawings + 1] = box
            end
        end
    end
end

local function TeleportToNearestItem()
    if not Settings.World.TeleportToItem then return end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - v.Handle.Position).Magnitude
            if d < nearestDist then nearestDist = d; nearest = v.Handle end
        end
    end
    if nearest then
        LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
        SendNotification("World", "Đã teleport đến vật phẩm")
    end
end

local function TeleportToNearestVehicle()
    if not Settings.World.TeleportToVehicle then return end
    local nearest = nil
    local nearestDist = math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
            if d < nearestDist then nearestDist = d; nearest = v end
        end
    end
    if nearest then
        LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
        SendNotification("World", "Đã teleport đến xe")
    end
end

local function UpdateRadar()
    if not Settings.World.Radar then
        for _, d in pairs(RadarDrawings) do d:Remove() end
        RadarDrawings = {}
        return
    end
    for _, d in pairs(RadarDrawings) do d:Remove() end
    RadarDrawings = {}
    local radarCenter = Vector2.new(Camera.ViewportSize.X - Settings.World.RadarSize - 20, Camera.ViewportSize.Y - Settings.World.RadarSize - 20)
    local bg = Drawing.new("Circle")
    bg.Color = Color3.fromRGB(0, 0, 0)
    bg.Thickness = 2
    bg.Filled = true
    bg.Radius = Settings.World.RadarSize
    bg.Position = radarCenter
    bg.Visible = true
    RadarDrawings[#RadarDrawings + 1] = bg

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local relative = root.Position - LocalPlayer.Character.HumanoidRootPart.Position
                if relative.Magnitude <= Settings.World.RadarRange then
                    local angle = math.atan2(relative.Z, relative.X) - math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)
                    local scaledDist = math.clamp(relative.Magnitude / Settings.World.RadarRange * Settings.World.RadarSize, 0, Settings.World.RadarSize - 5)
                    local pos = radarCenter + Vector2.new(math.cos(angle) * scaledDist, math.sin(angle) * scaledDist)
                    local dot = Drawing.new("Circle")
                    local dotColor = IsTeamMate(player) and Settings.World.TeamDotColor or Settings.World.EnemyDotColor
                    dot.Color = Color3.fromRGB(dotColor.R, dotColor.G, dotColor.B)
                    dot.Thickness = 0
                    dot.Filled = true
                    dot.Radius = 5
                    dot.Position = pos
                    dot.Visible = true
                    RadarDrawings[#RadarDrawings + 1] = dot
                end
            end
        end
    end
end

local function FixLag()
    if not Settings.Misc.FixLag then return end

    for _, light in ipairs(Lighting:GetChildren()) do
        if light:IsA("BloomEffect") or light:IsA("BlurEffect") or light:IsA("SunRaysEffect") or
           light:IsA("ColorCorrectionEffect") or light:IsA("DepthOfFieldEffect") or
           light:IsA("Atmosphere") or light:IsA("Sky") or light:IsA("PostEffect") or
           light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
            light:Destroy()
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.ExposureCompensation = 0.5
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)

    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Low
        settings().Rendering.EffectsQuality = Enum.QualityLevel.Level01
        settings().Rendering.MaterialQuality = Enum.MaterialQuality.Low
        settings().Rendering.TextureQuality = Enum.TextureQuality.Low
    end)

    pcall(function()
        workspace.StreamingEnabled = true
        workspace.StreamingMinRadius = 32
        workspace.StreamingTargetRadius = 64
    end)

    local function isCharacterPart(instance)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and instance:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or
           descendant:IsA("Beam") or descendant:IsA("Smoke") or descendant:IsA("Fire") or
           descendant:IsA("Sparkles") or descendant:IsA("Explosion") then
            descendant:Destroy()
        elseif descendant:IsA("Sound") or descendant:IsA("AudioEmitter") then
            descendant:Stop()
            descendant:Destroy()
        elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceAppearance") then
            descendant:Destroy()
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.CastShadow = false
            descendant.Reflectance = 0
            descendant.TextureID = ""
            if descendant:IsA("MeshPart") then
                descendant.TextureID = ""
            end
            if descendant.Anchored and descendant.Size.Magnitude < 0.5 and not isCharacterPart(descendant) then
                descendant:Destroy()
            else
                descendant.CanCollide = false
                descendant.CanQuery = false
                descendant.CanTouch = false
            end
        elseif descendant:IsA("SpecialMesh") or descendant:IsA("BlockMesh") or descendant:IsA("CylinderMesh") then
            descendant.TextureId = ""
            descendant.MeshId = ""
        elseif descendant:IsA("Model") then
            local lower = descendant.Name:lower()
            if lower:find("grass") or lower:find("rock") or lower:find("tree") or
               lower:find("bush") or lower:find("flower") or lower:find("plant") or
               lower:find("leaf") or lower:find("branch") or lower:find("stick") or
               lower:find("pebble") or lower:find("rubble") or lower:find("debris") or
               lower:find("trash") or lower:find("scrap") or lower:find("paper") or
               lower:find("glass") or lower:find("plastic") or lower:find("wood") or
               lower:find("metal") or lower:find("cloth") or lower:find("cardboard") then
                if not isCharacterPart(descendant) then
                    descendant:Destroy()
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("Accessory") or part:IsA("Hat") or
                   part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") then
                    part:Destroy()
                elseif part:IsA("BasePart") then
                    part.Material = Enum.Material.SmoothPlastic
                    part.CastShadow = false
                    part.Reflectance = 0
                    part.TextureID = ""
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part:Destroy()
                elseif part:IsA("Sound") then
                    part:Stop()
                    part:Destroy()
                elseif part:IsA("SpecialMesh") or part:IsA("BlockMesh") or part:IsA("CylinderMesh") then
                    part.TextureId = ""
                    part.MeshId = ""
                end
            end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Anchored and v.Size.Magnitude < 0.5 and not v:IsDescendantOf(LocalPlayer.Character) then
            v:Destroy()
        end
    end

    collectgarbage("collect")
end

local function ApplyPlayerMods()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = Settings.Misc.WalkSpeed
    humanoid.JumpPower = Settings.Misc.JumpPower

    if Settings.Misc.SpeedHack then
        humanoid.WalkSpeed = Settings.Misc.WalkSpeed * 2
    end

    if Settings.Misc.Invisibility then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end

    if Settings.Misc.GodMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end

    if Settings.Misc.Fly then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local bodyVelocity = root:FindFirstChildOfClass("BodyVelocity") or root:FindFirstChildOfClass("LinearVelocity")
            if not bodyVelocity then
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.zero
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Parent = root
            end
        end
    else
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChildOfClass("BodyVelocity") or root:FindFirstChildOfClass("LinearVelocity")
            if bv then bv:Destroy() end
        end
    end

    if Settings.Misc.Noclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    if Settings.Misc.InfiniteJump then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
    else
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
    end
end

local function WatermarkUpdate()
    if not Settings.UI.Watermark then return end
    local FPS = 0
    local Ping = 0
    pcall(function()
        FPS = math.floor(1 / RunService.RenderStepped:Wait())
    end)
    pcall(function()
        Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    local watermark = Drawing.new("Text")
    watermark.Text = "Superhero Team | FPS: " .. FPS .. " | Ping: " .. Ping .. "ms"
    watermark.Color = Color3.fromRGB(255, 255, 255)
    watermark.Size = 14
    watermark.Position = Vector2.new(10, Camera.ViewportSize.Y - 25)
    watermark.Visible = true
    watermark.Transparency = 0.5
    task.delay(1, function()
        watermark:Remove()
    end)
end

RunService.RenderStepped:Connect(function()
    DrawFOVCircle()
    DrawCustomCrosshair()
    UpdateAimDraw()
    AimbotLoop()
    RapidFireSystem()
    FastReloadSystem()
    MagicBulletSystem()
    HitAnywhereSystem()
    SmartDodgeSystem()
    UpdateAllESP()
    UpdateDistanceMarkers()
    UpdateRadar()
    UpdateGlowAndChams()
    ApplyPlayerMods()
    WatermarkUpdate()
end)

task.spawn(function()
    while true do
        WorldESP()
        if Settings.World.TeleportToItem then TeleportToNearestItem() end
        if Settings.World.TeleportToVehicle then TeleportToNearestVehicle() end
        wait(5)
    end
end)

task.spawn(function()
    while true do
        if Settings.Misc.FixLag then FixLag() end
        wait(10)
    end
end)

task.spawn(function()
    while true do
        if Settings.Misc.CleanWorkspace then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and v.Anchored and v.Size.Magnitude < 1 then v:Destroy() end
            end
        end
        wait(30)
    end
end)

if Settings.Misc.ChatCommands then
    LocalPlayer.Chatted:Connect(function(msg)
        msg = msg:lower()
        if msg == "!aim" then Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled; SaveSettings(); SendNotification("Chat", "Aimbot " .. (Settings.Aimbot.Enabled and "bật" or "tắt"))
        elseif msg == "!esp" then Settings.ESP.Enabled = not Settings.ESP.Enabled; SaveSettings(); SendNotification("Chat", "ESP " .. (Settings.ESP.Enabled and "bật" or "tắt"))
        elseif msg == "!fly" then Settings.Misc.Fly = not Settings.Misc.Fly; SaveSettings(); SendNotification("Chat", "Fly " .. (Settings.Misc.Fly and "bật" or "tắt"))
        elseif msg == "!noclip" then Settings.Misc.Noclip = not Settings.Misc.Noclip; SaveSettings(); SendNotification("Chat", "Noclip " .. (Settings.Misc.Noclip and "bật" or "tắt"))
        elseif msg == "!magic" then Settings.Aimbot.MagicBullet = not Settings.Aimbot.MagicBullet; SaveSettings(); SendNotification("Chat", "Magic Bullet " .. (Settings.Aimbot.MagicBullet and "bật" or "tắt"))
        end
    end)
end

local function ToggleUI()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
        if OpenButton then OpenButton.Visible = not MainFrame.Visible end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then ToggleUI() end
end)

local function CreateOpenButton()
    OpenButton = Instance.new("TextButton")
    OpenButton.Parent = GUI
    OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OpenButton.BackgroundTransparency = 0.2
    OpenButton.BorderSizePixel = 0
    OpenButton.Position = UDim2.new(0, 10, 0, 10)
    OpenButton.Size = UDim2.new(0, 50, 0, 50)
    OpenButton.Text = "☰"
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextSize = 24
    OpenButton.AutoButtonColor = false
    OpenButton.Visible = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = OpenButton
    OpenButton.MouseButton1Click:Connect(function() ToggleUI() end)
end

CreateOpenButton()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if MainFrame and MainFrame.Visible then
            local titleBar = MainFrame:FindFirstChild("TitleBar")
            if titleBar then
                local pos = input.Position
                local absPos = titleBar.AbsolutePosition
                local absSize = titleBar.AbsoluteSize
                if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                    Dragging = true
                    DragStart = pos
                    DragOffset = MainFrame.Position
                end
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(DragOffset.X.Scale, DragOffset.X.Offset + delta.X, DragOffset.Y.Scale, DragOffset.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Superhero Team",
    Text = "Script loaded! Press RightShift to toggle menu.",
    Duration = 5
})