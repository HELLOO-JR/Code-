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

local Settings = {
    Aimbot = {
        Enabled = false,
        Rage = true,
        Legit = false,
        Silent = false,
        Triggerbot = false,
        TargetMode = "Closest",
        AimBone = "Head",
        SmoothAim = false,
        Smoothness = 8,
        FOVRadius = 120,
        WallCheck = false,
        Prediction = true,
        PredictionAmount = 0.15,
        NoRecoil = false,
        AutoWall = false,
        TargetSwitch = false,
        HitboxExpansion = false,
        HitboxMultiplier = 1.5,
        Randomization = false,
        AimAssist = false,
        AntiAim = false,
        SpinBot = false,
        AutoShoot = true,
        AutoShootDelay = 0,
        VisibilityCheckFOV = false,
        PriorityTarget = "Khoảng cách"
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
        OccludedColor = {R=255,G=165,B=0}
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
        TeamDotColor = {R=0,G=255,B=0}
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
        InfiniteJump = false
    },
    UI = {
        Watermark = true,
        Notifications = true
    }
}

local GUI = nil
local MainFrame = nil
local Sidebar = nil
local ContentContainer = nil
local Tabs = {}
local ContentFrames = {}
local FOVCircle = nil
local Dragging = false
local DragStart = nil
local DragOffset = nil
local OpenButton = nil
local ESPDrawings = {}
local RadarDrawings = {}

local function SaveSettings()
    pcall(function()
        writefile("superhero_team_settings.json", HttpService:JSONEncode(Settings))
    end)
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
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
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
    local menuWidth = math.min(360, viewportX * 0.8)
    local menuHeight = math.min(420, viewportY * 0.8)

    MainFrame = Instance.new("Frame")
    MainFrame.Parent = GUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    MainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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

    Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
        TabButton.Position = UDim2.new(0, 5, 0, 0)
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

    ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Aimbot")
end

local function AddSection(parent, sectionName)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = parent
    SectionLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, height or 45)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
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
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
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
        local featureName = settingPath[#settingPath]
        SendNotification("Cài đặt", text .. " đã " .. (GetValue() and "bật" or "tắt"))
    end)

    return holder
end

local function CreateSlider(parent, text, description, settingPath, min, max, step)
    local holder = CreateElementHolder(parent, text, description, 55)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
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
        if step == 1 then
            val = math.floor(val)
        else
            val = math.floor(val / step) * step
        end
        local value = Settings
        for i, key in ipairs(settingPath) do
            if i == #settingPath then
                value[key] = val
            else
                value = value[key]
            end
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
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
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
                if i == #settingPath then
                    value[key] = opt
                else
                    value = value[key]
                end
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
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
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
    RSlider.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    RSlider.BorderSizePixel = 0
    RSlider.Position = UDim2.new(0.65, 0, 0, 35)
    RSlider.Size = UDim2.new(0.25, 0, 0, 8)
    RSlider.Text = ""
    RSlider.AutoButtonColor = false
    local GSlider = Instance.new("TextButton")
    GSlider.Parent = holder
    GSlider.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    GSlider.BorderSizePixel = 0
    GSlider.Position = UDim2.new(0.65, 0, 0, 47)
    GSlider.Size = UDim2.new(0.25, 0, 0, 8)
    GSlider.Text = ""
    GSlider.AutoButtonColor = false
    local BSlider = Instance.new("TextButton")
    BSlider.Parent = holder
    BSlider.BackgroundColor3 = Color3.fromRGB(0, 0, 200)
    BSlider.BorderSizePixel = 0
    BSlider.Position = UDim2.new(0.65, 0, 0, 59)
    BSlider.Size = UDim2.new(0.25, 0, 0, 8)
    BSlider.Text = ""
    BSlider.AutoButtonColor = false

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

    AddSection(aimbotContent, "HIỆN ĐẠI - Modern")
    CreateToggle(aimbotContent, "Smooth Aim", "Di chuyển ngắm mượt mà, tránh giật cục", {"Aimbot", "SmoothAim"})
    CreateSlider(aimbotContent, "Smoothness", "Độ mượt khi di chuyển ngắm, 1 là nhanh nhất", {"Aimbot", "Smoothness"}, 1, 20, 1)
    CreateSlider(aimbotContent, "FOV Radius", "Bán kính vòng tròn phạm vi ngắm", {"Aimbot", "FOVRadius"}, 10, 360, 1)
    CreateToggle(aimbotContent, "Wall Check", "Không ngắm vào mục tiêu nếu bị tường che khuất", {"Aimbot", "WallCheck"})
    CreateToggle(aimbotContent, "Prediction", "Dự đoán vị trí di chuyển của mục tiêu", {"Aimbot", "Prediction"})
    CreateToggle(aimbotContent, "No Recoil", "Giảm hoặc loại bỏ hiệu ứng giật khi bắn", {"Aimbot", "NoRecoil"})
    CreateToggle(aimbotContent, "Auto Wall", "Tự động bắn xuyên tường nếu mục tiêu nằm sau vật cản mỏng", {"Aimbot", "AutoWall"})
    CreateToggle(aimbotContent, "Target Switch", "Tự động chuyển mục tiêu khi mục tiêu hiện tại chết", {"Aimbot", "TargetSwitch"})
    CreateToggle(aimbotContent, "Hitbox Expansion", "Mở rộng hitbox mục tiêu giúp dễ trúng hơn", {"Aimbot", "HitboxExpansion"})
    CreateToggle(aimbotContent, "Randomization", "Thêm độ ngẫu nhiên nhỏ khi ngắm", {"Aimbot", "Randomization"})
    CreateToggle(aimbotContent, "Aim Assist", "Hỗ trợ ngắm nhẹ, không khóa cứng", {"Aimbot", "AimAssist"})
    CreateToggle(aimbotContent, "Anti-Aim", "Tự động xoay nhân vật để né đạn", {"Aimbot", "AntiAim"})
    CreateToggle(aimbotContent, "Spin Bot", "Xoay nhân vật liên tục khi ngắm", {"Aimbot", "SpinBot"})
    CreateToggle(aimbotContent, "Auto Shoot", "Tự động bắn khi mục tiêu nằm trong FOV", {"Aimbot", "AutoShoot"})
    CreateSlider(aimbotContent, "Auto Shoot Delay", "Thời gian trễ trước khi tự động bắn (ms)", {"Aimbot", "AutoShootDelay"}, 0, 500, 10)
    CreateToggle(aimbotContent, "Visibility Check FOV", "Chỉ hiển thị FOV Circle khi có mục tiêu", {"Aimbot", "VisibilityCheckFOV"})
    CreateDropdown(aimbotContent, "Priority Target", "Ưu tiên chọn mục tiêu theo tiêu chí", {"Aimbot", "PriorityTarget"}, {"Khoảng cách", "Máu", "Sát thương"})

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
            if v:IsA("Part") and v.Anchored and v.Size.Magnitude < 1 then
                v:Destroy()
            end
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
    CreateButton(miscContent, "Rejoin", "Tham gia lại game nhanh chóng", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    CreateButton(miscContent, "Respawn", "Hồi sinh nhân vật", function()
        LocalPlayer:LoadCharacter()
    end)
end

CreateUI()
BuildUI()

local function IsTeamMate(player)
    if Settings.ESP.TeamCheck or Settings.Aimbot.TeamCheck then
        return player.Team == LocalPlayer.Team
    end
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
    if root then return root.Velocity end
    return Vector3.zero
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

        local predictedPos = bonePos
        if Settings.Aimbot.Prediction then
            predictedPos = bonePos + GetVelocity(character) * Settings.Aimbot.PredictionAmount
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if Settings.Aimbot.HitboxExpansion then
            dist = dist / Settings.Aimbot.HitboxMultiplier
        end

        if dist <= maxFOV then
            local value
            if Settings.Aimbot.PriorityTarget == "Máu" then
                value = humanoid.Health
            elseif Settings.Aimbot.PriorityTarget == "Sát thương" then
                value = -math.huge
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then value = 0 end
            else
                value = dist
            end
            if value < bestValue then
                bestValue = value
                target = player
            end
        end
    end
    return target
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

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end

    local shouldAim = false
    if Settings.Aimbot.Rage then shouldAim = true end
    if Settings.Aimbot.Legit then shouldAim = IsAimKeyPressed() or (UserInputService.TouchEnabled and UserInputService.TouchCount > 0) end
    if Settings.Aimbot.Silent then shouldAim = false end

    if Settings.Aimbot.Triggerbot then
        local mouseTarget = GetMouseTarget()
        if mouseTarget then ActivateTool() end
    end

    if Settings.Aimbot.Silent and Settings.Aimbot.AutoShoot then
        local target = GetAimbotTarget()
        if target then ActivateTool() end
    end

    if shouldAim or (Settings.Aimbot.AutoShoot and Settings.Aimbot.Rage) then
        local target = GetAimbotTarget()
        if target then
            local character = target.Character
            local boneName = Settings.Aimbot.AimBone
            if boneName == "Random" then boneName = "Head" end
            local bonePos = GetBonePos(character, boneName)
            if bonePos then
                local predictedPos = bonePos
                if Settings.Aimbot.Prediction then predictedPos = bonePos + GetVelocity(character) * Settings.Aimbot.PredictionAmount end
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
                if Settings.Aimbot.SmoothAim then
                    local smooth = 1 / Settings.Aimbot.Smoothness
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
                else
                    Camera.CFrame = targetCF
                end
                if Settings.Aimbot.AutoShoot and (Settings.Aimbot.Rage or Settings.Aimbot.Legit) then
                    ActivateTool()
                end
            end
        end
    end
end

local function DrawFOVCircle()
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Thickness = 3
        FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        FOVCircle.Filled = false
    end
    local visible = Settings.Aimbot.Enabled
    if Settings.Aimbot.VisibilityCheckFOV then
        visible = visible and GetAimbotTarget() ~= nil
    end
    FOVCircle.Visible = visible
    FOVCircle.Radius = Settings.Aimbot.FOVRadius / 2
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function CleanupESP()
    for _, d in pairs(ESPDrawings) do
        d:Remove()
    end
    ESPDrawings = {}
end

local function CreateESPForPlayer(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local isTeam = IsTeamMate(player)
    local enemyCol = Settings.ESP.EnemyColor
    local teamCol = Settings.ESP.TeamColor
    local visCol = Settings.ESP.VisibleColor
    local occCol = Settings.ESP.OccludedColor
    local baseColor = isTeam and Color3.fromRGB(teamCol.R, teamCol.G, teamCol.B) or Color3.fromRGB(enemyCol.R, enemyCol.G, enemyCol.B)

    local drawingContainer = {}

    if Settings.ESP.Box2D then
        local box = Drawing.new("Square")
        box.Color = baseColor
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
        drawingContainer.Box2D = box
        ESPDrawings[#ESPDrawings + 1] = box
    end

    if Settings.ESP.Box3D then
        local box3d = Drawing.new("Square")
        box3d.Color = baseColor
        box3d.Thickness = 2
        box3d.Filled = false
        box3d.Visible = false
        drawingContainer.Box3D = box3d
        ESPDrawings[#ESPDrawings + 1] = box3d
    end

    if Settings.ESP.Skeleton then
        drawingContainer.Skeleton = {}
        local bones = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}
        for _, boneName in ipairs(bones) do
            local line = Drawing.new("Line")
            line.Color = baseColor
            line.Thickness = 2
            line.Visible = false
            drawingContainer.Skeleton[boneName] = line
            ESPDrawings[#ESPDrawings + 1] = line
        end
    end

    if Settings.ESP.Tracers then
        local line = Drawing.new("Line")
        line.Color = baseColor
        line.Thickness = 2
        line.Visible = false
        drawingContainer.Tracers = line
        ESPDrawings[#ESPDrawings + 1] = line
    end

    if Settings.ESP.HealthBar then
        local healthBar = Drawing.new("Square")
        healthBar.Color = baseColor
        healthBar.Thickness = 2
        healthBar.Filled = true
        healthBar.Visible = false
        drawingContainer.HealthBar = healthBar
        ESPDrawings[#ESPDrawings + 1] = healthBar
    end

    if Settings.ESP.HealthPercent then
        local healthText = Drawing.new("Text")
        healthText.Color = Color3.fromRGB(255, 255, 255)
        healthText.Size = 14
        healthText.Center = true
        healthText.Visible = false
        drawingContainer.HealthText = healthText
        ESPDrawings[#ESPDrawings + 1] = healthText
    end

    if Settings.ESP.Distance then
        local distText = Drawing.new("Text")
        distText.Color = Color3.fromRGB(255, 255, 255)
        distText.Size = 14
        distText.Center = true
        distText.Visible = false
        drawingContainer.DistanceText = distText
        ESPDrawings[#ESPDrawings + 1] = distText
    end

    if Settings.ESP.Name then
        local nameText = Drawing.new("Text")
        nameText.Color = Color3.fromRGB(255, 255, 255)
        nameText.Size = 14
        nameText.Center = true
        nameText.Visible = false
        drawingContainer.NameText = nameText
        ESPDrawings[#ESPDrawings + 1] = nameText
    end

    if Settings.ESP.Weapon then
        local weaponText = Drawing.new("Text")
        weaponText.Color = Color3.fromRGB(255, 255, 255)
        weaponText.Size = 14
        weaponText.Center = true
        weaponText.Visible = false
        drawingContainer.WeaponText = weaponText
        ESPDrawings[#ESPDrawings + 1] = weaponText
    end

    if Settings.ESP.HeadDot then
        local dot = Drawing.new("Circle")
        dot.Color = baseColor
        dot.Thickness = 0
        dot.Filled = true
        dot.Radius = 5
        dot.Visible = false
        drawingContainer.HeadDot = dot
        ESPDrawings[#ESPDrawings + 1] = dot
    end

    return drawingContainer
end

local function UpdateESP()
    CleanupESP()
    if not Settings.ESP.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeamMate(player) and Settings.ESP.TeamCheck then continue end
        local container = CreateESPForPlayer(player)
        if container then
            task.spawn(function()
                while Settings.ESP.Enabled and player.Parent and player.Character do
                    local character = player.Character
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then break end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then break end
                    local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    if dist > Settings.ESP.MaxDistance then
                        for _, d in pairs(container) do
                            if type(d) == "table" then
                                for _, sub in pairs(d) do sub.Visible = false end
                            else
                                d.Visible = false
                            end
                        end
                        RunService.RenderStepped:Wait()
                        continue
                    end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local size = math.clamp(2000 / dist, 10, 200)
                        local isVis = IsVisible(player)
                        local color = Settings.ESP.VisibilityCheck and (isVis and Color3.fromRGB(Settings.ESP.VisibleColor.R, Settings.ESP.VisibleColor.G, Settings.ESP.VisibleColor.B) or Color3.fromRGB(Settings.ESP.OccludedColor.R, Settings.ESP.OccludedColor.G, Settings.ESP.OccludedColor.B)) or (IsTeamMate(player) and Color3.fromRGB(Settings.ESP.TeamColor.R, Settings.ESP.TeamColor.G, Settings.ESP.TeamColor.B) or Color3.fromRGB(Settings.ESP.EnemyColor.R, Settings.ESP.EnemyColor.G, Settings.ESP.EnemyColor.B))
                        local alpha = Settings.ESP.FadeOut and math.clamp(1 - (dist / Settings.ESP.MaxDistance), 0.2, 1) or 1
                        if container.Box2D then
                            container.Box2D.Visible = true
                            container.Box2D.Color = color
                            container.Box2D.Transparency = 1 - alpha
                            container.Box2D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size)
                            container.Box2D.Size = Vector2.new(size, size)
                        end
                        if container.Box3D then
                            container.Box3D.Visible = true
                            container.Box3D.Color = color
                            container.Box3D.Transparency = 1 - alpha
                            container.Box3D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size*2)
                            container.Box3D.Size = Vector2.new(size, size*2)
                        end
                        if container.Skeleton then
                            for _, boneName in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}) do
                                local bone = character:FindFirstChild(boneName)
                                if bone then
                                    local boneScreen, boneOn = Camera:WorldToViewportPoint(bone.Position)
                                    local line = container.Skeleton[boneName]
                                    if boneOn and line then
                                        line.Visible = true
                                        line.Color = color
                                        line.Transparency = 1 - alpha
                                        line.From = Vector2.new(screenPos.X, screenPos.Y)
                                        line.To = Vector2.new(boneScreen.X, boneScreen.Y)
                                    elseif line then
                                        line.Visible = false
                                    end
                                end
                            end
                        end
                        if container.Tracers then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            container.Tracers.Visible = true
                            container.Tracers.Color = color
                            container.Tracers.Transparency = 1 - alpha
                            container.Tracers.From = center
                            container.Tracers.To = Vector2.new(screenPos.X, screenPos.Y)
                        end
                        if container.HealthBar then
                            local health = humanoid.Health / humanoid.MaxHealth
                            container.HealthBar.Visible = true
                            container.HealthBar.Color = color
                            container.HealthBar.Transparency = 1 - alpha
                            container.HealthBar.Position = Vector2.new(screenPos.X - size/2 - 5, screenPos.Y - size)
                            container.HealthBar.Size = Vector2.new(4, size * health)
                        end
                        if container.HealthText then
                            container.HealthText.Visible = true
                            container.HealthText.Text = tostring(math.floor(humanoid.Health / humanoid.MaxHealth * 100)) .. "%"
                            container.HealthText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 5)
                        end
                        if container.DistanceText then
                            container.DistanceText.Visible = true
                            container.DistanceText.Text = string.format("%.0f", dist)
                            container.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 5)
                        end
                        if container.NameText then
                            container.NameText.Visible = true
                            container.NameText.Text = player.Name
                            container.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - size - 20)
                        end
                        if container.WeaponText then
                            local tool = character:FindFirstChildOfClass("Tool")
                            local weaponName = tool and tool.Name or ""
                            container.WeaponText.Visible = true
                            container.WeaponText.Text = weaponName
                            container.WeaponText.Position = Vector2.new(screenPos.X, screenPos.Y + size + 5)
                        end
                        if container.HeadDot then
                            local head = character:FindFirstChild("Head")
                            if head then
                                local headScreen, headOn = Camera:WorldToViewportPoint(head.Position)
                                if headOn then
                                    container.HeadDot.Visible = true
                                    container.HeadDot.Color = color
                                    container.HeadDot.Position = Vector2.new(headScreen.X, headScreen.Y)
                                else
                                    container.HeadDot.Visible = false
                                end
                            end
                        end
                    else
                        for _, d in pairs(container) do
                            if type(d) == "table" then
                                for _, sub in pairs(d) do sub.Visible = false end
                            else
                                d.Visible = false
                            end
                        end
                    end
                    RunService.RenderStepped:Wait()
                end
                for _, d in pairs(container) do
                    if type(d) == "table" then
                        for _, sub in pairs(d) do sub:Remove() end
                    else
                        d:Remove()
                    end
                end
            end)
        end
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

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if Settings.Misc.RemoveDecals and (descendant:IsA("Texture") or descendant:IsA("Decal")) then
            descendant:Destroy()
        elseif Settings.Misc.RemoveParticles and (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Smoke") or descendant:IsA("Fire")) then
            descendant:Destroy()
        elseif Settings.Misc.RemoveTextures and descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.CastShadow = false
            descendant.Reflectance = 0
        elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
            descendant:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if Settings.Misc.RemoveClothing and (part:IsA("Accessory") or part:IsA("Hat") or part:IsA("Shirt") or part:IsA("Pants")) then
                    part:Destroy()
                elseif Settings.Misc.RemoveTextures and part:IsA("BasePart") then
                    part.Material = Enum.Material.SmoothPlastic
                    part.CastShadow = false
                end
            end
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100
    Lighting.Brightness = 1.5
end

local function ApplyPlayerMods()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = Settings.Misc.WalkSpeed
    humanoid.JumpPower = Settings.Misc.JumpPower

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

local TouchCount = 0
local function GestureDetection()
    UserInputService.TouchStarted:Connect(function(input, processed)
        if processed then return end
        TouchCount += 1
        if TouchCount == 2 then
            Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
            SaveSettings()
            SendNotification("Aimbot", "Aimbot " .. (Settings.Aimbot.Enabled and "bật" or "tắt"))
        elseif TouchCount == 3 then
            if MainFrame then
                MainFrame.Visible = not MainFrame.Visible
                if OpenButton then OpenButton.Visible = not MainFrame.Visible end
            end
        end
    end)
    UserInputService.TouchEnded:Connect(function(input, processed)
        TouchCount = math.max(0, TouchCount - 1)
    end)
end

GestureDetection()

RunService.RenderStepped:Connect(function()
    DrawFOVCircle()
    AimbotLoop()
    UpdateRadar()
    UpdateGlowAndChams()
    ApplyPlayerMods()
    WatermarkUpdate()
end)

task.spawn(function()
    while true do
        if Settings.ESP.Enabled then
            UpdateESP()
        else
            CleanupESP()
        end
        wait(1)
    end
end)

task.spawn(function()
    while true do
        WorldESP()
        wait(5)
    end
end)

task.spawn(function()
    while true do
        if Settings.Misc.FixLag then
            FixLag()
        end
        wait(10)
    end
end)

task.spawn(function()
    while true do
        if Settings.Misc.CleanWorkspace then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and v.Anchored and v.Size.Magnitude < 1 then
                    v:Destroy()
                end
            end
        end
        wait(30)
    end
end)

local function ToggleUI()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
        if OpenButton then OpenButton.Visible = not MainFrame.Visible end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleUI()
    end
end)

local function CreateOpenButton()
    OpenButton = Instance.new("TextButton")
    OpenButton.Parent = GUI
    OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
    OpenButton.MouseButton1Click:Connect(function()
        ToggleUI()
    end)
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
    Text = "Script loaded! Chạm 3 ngón để mở menu, 2 ngón để bật/tắt aimbot.",
    Duration = 5
})