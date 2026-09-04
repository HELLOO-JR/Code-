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
local TweenService = game:GetService("TweenService")

local Settings = {
    Aimbot = {
        Enabled = false,
        Rage = true,
        Legit = false,
        Silent = false,
        AimBone = "Head",
        SmoothAim = false,
        Smoothness = 8,
        FOVRadius = 150,
        HitboxExpansion = 1.0,
    },
    ESP = {
        Enabled = false,
        Skeleton = true,
        TracerMode = 1,
        Glow = true,
        VisibilityCheck = true,
    },
    World = {
        Enabled = false
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
local Tabs = {}
local ContentFrames = {}
local FOVCircle = nil
local Dragging = false
local DragStart = nil
local DragOffset = nil
local OpenButton = nil
local ESPDrawings = {}
local GlowObjects = {}
local CurrentTarget = nil

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 22, 26),
    Surface = Color3.fromRGB(30, 33, 38),
    SurfaceHover = Color3.fromRGB(40, 43, 48),
    Accent = Color3.fromRGB(0, 120, 255),
    AccentDark = Color3.fromRGB(0, 80, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 155, 165),
    Border = Color3.fromRGB(45, 48, 53),
    Success = Color3.fromRGB(0, 230, 118),
    Danger = Color3.fromRGB(255, 70, 70),
}

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
    local menuWidth = math.min(420, viewportX * 0.85)
    local menuHeight = math.min(520, viewportY * 0.85)

    -- Main Frame with shadow
    MainFrame = Instance.new("Frame")
    MainFrame.Parent = GUI
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    MainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 2

    local Shadow = Instance.new("Frame")
    Shadow.Parent = MainFrame
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.5
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.new(0, 5, 0, 5)
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.ZIndex = 0

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Colors.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 56)
    TitleBar.Active = true
    TitleBar.ZIndex = 3

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar

    local TitleLine = Instance.new("Frame")
    TitleLine.Parent = TitleBar
    TitleLine.BackgroundColor3 = Colors.Accent
    TitleLine.BorderSizePixel = 0
    TitleLine.Position = UDim2.new(0, 0, 1, -3)
    TitleLine.Size = UDim2.new(1, 0, 0, 3)
    TitleLine.ZIndex = 4

    -- Logo/Icon
    local Logo = Instance.new("TextLabel")
    Logo.Parent = TitleBar
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0, 16, 0, 10)
    Logo.Size = UDim2.new(0, 32, 0, 32)
    Logo.Font = Enum.Font.GothamBold
    Logo.Text = "⚡"
    Logo.TextColor3 = Colors.Accent
    Logo.TextSize = 24
    Logo.TextXAlignment = Enum.TextXAlignment.Center
    Logo.TextYAlignment = Enum.TextYAlignment.Center

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 56, 0, 10)
    TitleText.Size = UDim2.new(0, 200, 0, 32)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "Superhero Team"
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.TextYAlignment = Enum.TextYAlignment.Center

    local VersionText = Instance.new("TextLabel")
    VersionText.Parent = TitleBar
    VersionText.BackgroundTransparency = 1
    VersionText.Position = UDim2.new(0, 56, 0, 32)
    VersionText.Size = UDim2.new(0, 100, 0, 16)
    VersionText.Font = Enum.Font.Gotham
    VersionText.Text = "v3.0 • PRO"
    VersionText.TextColor3 = Colors.TextSecondary
    VersionText.TextSize = 11
    VersionText.TextXAlignment = Enum.TextXAlignment.Left
    VersionText.TextYAlignment = Enum.TextYAlignment.Top

    -- Close/Minimize Buttons
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseButton.BackgroundTransparency = 0.8
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -44, 0, 10)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Text = "✕"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Colors.Text
    CloseButton.TextSize = 14
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 4
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        MainFrame.Visible = false
        if OpenButton then OpenButton.Visible = true end
    end)

    local MinButton = Instance.new("TextButton")
    MinButton.Parent = TitleBar
    MinButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    MinButton.BackgroundTransparency = 0.8
    MinButton.BorderSizePixel = 0
    MinButton.Position = UDim2.new(1, -80, 0, 10)
    MinButton.Size = UDim2.new(0, 30, 0, 30)
    MinButton.Text = "−"
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextColor3 = Colors.Text
    MinButton.TextSize = 18
    MinButton.AutoButtonColor = false
    MinButton.ZIndex = 4
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinButton

    MinButton.MouseEnter:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    MinButton.MouseLeave:Connect(function()
        TweenService:Create(MinButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)

    MinButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        if OpenButton then OpenButton.Visible = true end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Colors.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 56)
    Sidebar.Size = UDim2.new(0, 72, 1, -56)
    Sidebar.ClipsDescendants = true
    Sidebar.ZIndex = 2

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 16)
    SidebarCorner.Parent = Sidebar

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent = Sidebar
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 6)

    local TabNames = {"Aimbot", "ESP", "World", "Misc"}
    local TabIcons = {"🎯", "👁", "🌍", "⚙"}
    local TabColors = {
        Color3.fromRGB(0, 180, 255),
        Color3.fromRGB(0, 255, 150),
        Color3.fromRGB(255, 200, 0),
        Color3.fromRGB(200, 100, 255),
    }

    for i, tabName in ipairs(TabNames) do
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 33, 38)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, -12, 0, 56)
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.ZIndex = 3

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 10)
        TabCorner.Parent = TabButton

        local Icon = Instance.new("TextLabel")
        Icon.Parent = TabButton
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 0, 0, 6)
        Icon.Size = UDim2.new(1, 0, 0, 28)
        Icon.Font = Enum.Font.GothamBold
        Icon.Text = TabIcons[i]
        Icon.TextColor3 = Colors.TextSecondary
        Icon.TextSize = 22
        Icon.TextXAlignment = Enum.TextXAlignment.Center
        Icon.TextYAlignment = Enum.TextYAlignment.Center

        local Label = Instance.new("TextLabel")
        Label.Parent = TabButton
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 0, 0, 36)
        Label.Size = UDim2.new(1, 0, 0, 16)
        Label.Font = Enum.Font.Gotham
        Label.Text = tabName
        Label.TextColor3 = Colors.TextSecondary
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Center
        Label.TextYAlignment = Enum.TextYAlignment.Center

        local Indicator = Instance.new("Frame")
        Indicator.Parent = TabButton
        Indicator.BackgroundColor3 = TabColors[i]
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 0.5, -12)
        Indicator.Size = UDim2.new(0, 3, 0, 24)
        Indicator.Visible = false
        Indicator.ZIndex = 4

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = Indicator

        Tabs[tabName] = {
            Button = TabButton,
            Icon = Icon,
            Label = Label,
            Indicator = Indicator,
            Color = TabColors[i]
        }

        TabButton.MouseEnter:Connect(function()
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
        end)
        TabButton.MouseLeave:Connect(function()
            if not TabButton.Selected then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
            end
        end)
    end

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0, 72, 0, 56)
    ContentContainer.Size = UDim2.new(1, -72, 1, -56)
    ContentContainer.ClipsDescendants = true
    ContentContainer.ZIndex = 1

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Parent = ContentContainer
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, -8, 1, -8)
    ScrollingFrame.Position = UDim2.new(0, 4, 0, 4)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.ClipsDescendants = true

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)

    for i, tabName in ipairs(TabNames) do
        local Content = Instance.new("Frame")
        Content.Parent = ScrollingFrame
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.Size = UDim2.new(1, -8, 0, 0)
        Content.Visible = (i == 1)
        ContentFrames[tabName] = Content

        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = Content
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 6)
    end

    local function SwitchTab(tabName)
        for name, content in pairs(ContentFrames) do
            content.Visible = (name == tabName)
        end
        for name, tab in pairs(Tabs) do
            local isSelected = (name == tabName)
            tab.Indicator.Visible = isSelected
            if isSelected then
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                TweenService:Create(tab.Icon, TweenInfo.new(0.2), {TextColor3 = tab.Color}):Play()
                TweenService:Create(tab.Label, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
            else
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(tab.Icon, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
                TweenService:Create(tab.Label, TweenInfo.new(0.2), {TextColor3 = Colors.TextSecondary}):Play()
            end
        end
        local target = ContentFrames[tabName]
        if target then
            target.Size = UDim2.new(1, -8, 0, 0)
            local totalHeight = 0
            for _, child in ipairs(target:GetChildren()) do
                if child:IsA("UIListLayout") then continue end
                totalHeight += child.Size.Y.Offset + 6
            end
            target.Size = UDim2.new(1, -8, 0, totalHeight)
        end
    end

    for name, tab in pairs(Tabs) do
        tab.Button.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Aimbot")
end

local function AddSection(parent, sectionName)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = parent
    SectionLabel.BackgroundColor3 = Color3.fromRGB(30, 33, 38)
    SectionLabel.BorderSizePixel = 0
    SectionLabel.Size = UDim2.new(1, 0, 0, 32)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = sectionName
    SectionLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    SectionLabel.TextSize = 12
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.TextYAlignment = Enum.TextYAlignment.Center
    SectionLabel.Padding = UDim.new(0, 12)
    local secCorner = Instance.new("UICorner")
    secCorner.CornerRadius = UDim.new(0, 8)
    secCorner.Parent = SectionLabel
    return SectionLabel
end

local function CreateElementHolder(parent, text, description, height)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.BackgroundColor3 = Color3.fromRGB(30, 33, 38)
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, height or 48)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 4)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Parent = holder
        descLabel.BackgroundTransparency = 1
        descLabel.Position = UDim2.new(0, 12, 0, 26)
        descLabel.Size = UDim2.new(0.6, 0, 0, 16)
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = description
        descLabel.TextColor3 = Colors.TextSecondary
        descLabel.TextSize = 10
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
    end

    return holder
end

local function CreateToggle(parent, text, description, settingPath)
    local holder = CreateElementHolder(parent, text, description, 48)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
        return value
    end

    local toggle = Instance.new("TextButton")
    toggle.Parent = holder
    toggle.BackgroundColor3 = GetValue() and Colors.Accent or Color3.fromRGB(60, 65, 70)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(0.75, 0, 0, 12)
    toggle.Size = UDim2.new(0, 44, 0, 24)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.ZIndex = 2
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle

    local toggleDot = Instance.new("Frame")
    toggleDot.Parent = toggle
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Position = GetValue() and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    toggleDot.Size = UDim2.new(0, 16, 0, 16)
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 8)
    dotCorner.Parent = toggleDot

    local function UpdateToggle()
        local enabled = GetValue()
        toggle.BackgroundColor3 = enabled and Colors.Accent or Color3.fromRGB(60, 65, 70)
        local targetPos = enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(toggleDot, TweenInfo.new(0.25), {Position = targetPos}):Play()
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

    -- Hover effect
    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)
    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)

    return holder
end

local function CreateSlider(parent, text, description, settingPath, min, max, step)
    local holder = CreateElementHolder(parent, text, description, 58)
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
    label.Position = UDim2.new(0.75, 0, 0, 4)
    label.Size = UDim2.new(0.2, 0, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(GetValue())
    label.TextColor3 = Colors.Accent
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.TextYAlignment = Enum.TextYAlignment.Center

    local slider = Instance.new("TextButton")
    slider.Parent = holder
    slider.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
    slider.BorderSizePixel = 0
    slider.Position = UDim2.new(0.75, 0, 0, 26)
    slider.Size = UDim2.new(0.2, 0, 0, 18)
    slider.Text = ""
    slider.AutoButtonColor = false
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 9)
    sliderCorner.Parent = slider

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((GetValue() - min) / (max - min), 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 9)
    fillCorner.Parent = fill

    local function UpdateSlider(input)
        local relative = input.Position.X - slider.AbsolutePosition.X
        local ratio = math.clamp(relative / slider.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * ratio
        if step ~= 0 then
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
    local holder = CreateElementHolder(parent, text, description, 52)
    local function GetValue()
        local value = Settings
        for _, key in ipairs(settingPath) do
            value = value[key]
        end
        return value
    end

    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.75, 0, 0, 12)
    button.Size = UDim2.new(0.2, 0, 0, 28)
    button.Font = Enum.Font.Gotham
    button.Text = GetValue()
    button.TextColor3 = Colors.Text
    button.TextSize = 12
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    local arrow = Instance.new("TextLabel")
    arrow.Parent = button
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -20, 0.5, -8)
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Font = Enum.Font.Gotham
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextSecondary
    arrow.TextSize = 10
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center

    local dropdown = Instance.new("Frame")
    dropdown.Parent = holder
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    dropdown.BorderSizePixel = 0
    dropdown.Position = UDim2.new(0.75, 0, 0, 44)
    dropdown.Size = UDim2.new(0.2, 0, 0, 0)
    dropdown.Visible = false
    dropdown.ZIndex = 5
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdown
    local dropList = Instance.new("UIListLayout")
    dropList.Parent = dropdown
    dropList.SortOrder = Enum.SortOrder.LayoutOrder
    dropList.Padding = UDim.new(0, 2)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = dropdown
        optBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
        optBtn.BorderSizePixel = 0
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextColor3 = Colors.Text
        optBtn.TextSize = 12
        optBtn.AutoButtonColor = false
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn
        
        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 65, 70)}):Play()
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 55, 60)}):Play()
        end)
        
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
            dropdown.Size = UDim2.new(0.2, 0, 0, 0)
            SaveSettings()
            SendNotification("Cài đặt", text .. " đã chọn " .. opt)
        end)
    end

    button.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
        dropdown.Size = UDim2.new(0.2, 0, 0, #options * 28)
    end)

    return holder
end

local function CreateButton(parent, text, description, callback)
    local holder = CreateElementHolder(parent, text, description, 48)
    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Colors.Accent
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0.75, 0, 0, 10)
    button.Size = UDim2.new(0.2, 0, 0, 28)
    button.Text = "▶"
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Colors.Text
    button.TextSize = 14
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentDark}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
        SendNotification("Cài đặt", text .. " đã thực hiện")
    end)
    return holder
end

local function BuildUI()
    local aimbotContent = ContentFrames["Aimbot"]
    AddSection(aimbotContent, "🎯 CỔ ĐIỂN - Classic")
    CreateToggle(aimbotContent, "Enable Aimbot", "Bật/tắt toàn bộ hệ thống ngắm tự động", {"Aimbot", "Enabled"})
    CreateToggle(aimbotContent, "Rage Mode", "Ngắm và bắn cực nhanh, không cần giữ phím", {"Aimbot", "Rage"})
    CreateToggle(aimbotContent, "Legit Mode", "Ngắm tự nhiên, chỉ kích hoạt khi chạm màn hình", {"Aimbot", "Legit"})
    CreateToggle(aimbotContent, "Silent Aim", "Ngắm và bắn mà không xoay camera", {"Aimbot", "Silent"})
    CreateDropdown(aimbotContent, "Aim Bone", "Chọn bộ phận cơ thể sẽ ngắm vào", {"Aimbot", "AimBone"}, {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Random"})
    CreateSlider(aimbotContent, "Hitbox Expansion", "Tăng hitbox đầu (1.0 - 5.5)", {"Aimbot", "HitboxExpansion"}, 1.0, 5.5, 0.1)

    AddSection(aimbotContent, "⚡ HIỆN ĐẠI - Modern")
    CreateToggle(aimbotContent, "Smooth Aim", "Di chuyển ngắm mượt mà, tránh giật cục", {"Aimbot", "SmoothAim"})
    CreateSlider(aimbotContent, "Smoothness", "Độ mượt khi di chuyển ngắm (1-20)", {"Aimbot", "Smoothness"}, 1, 20, 1)
    CreateSlider(aimbotContent, "FOV Radius", "Bán kính vòng tròn phạm vi ngắm", {"Aimbot", "FOVRadius"}, 10, 360, 1)

    local espContent = ContentFrames["ESP"]
    AddSection(espContent, "👁 CỔ ĐIỂN - Classic")
    CreateToggle(espContent, "Enable ESP", "Bật/tắt toàn bộ hệ thống ESP", {"ESP", "Enabled"})
    CreateToggle(espContent, "ESP Skeleton", "Hiển thị khung xương nhân vật (R6/R15)", {"ESP", "Skeleton"})
    CreateDropdown(espContent, "ESP 2D Line", "Kiểu đường thẳng nối đến kẻ địch", {"ESP", "TracerMode"}, {"1: Center", "2: Bottom", "3: Top"})

    AddSection(espContent, "✨ HIỆU ỨNG - Effects")
    CreateToggle(espContent, "ESP Glow", "Làm phát sáng nhân vật kẻ địch", {"ESP", "Glow"})
    CreateToggle(espContent, "Visibility Check", "Xanh = bị che, Đỏ = không bị che", {"ESP", "VisibilityCheck"})

    local worldContent = ContentFrames["World"]
    AddSection(worldContent, "🌍 WORLD ESP")
    CreateToggle(worldContent, "Enable World ESP", "Bật/tắt toàn bộ hệ thống World ESP", {"World", "Enabled"})

    local miscContent = ContentFrames["Misc"]
    AddSection(miscContent, "⚙ HIỆU SUẤT - Performance")
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

    AddSection(miscContent, "👤 NGƯỜI CHƠI - Player")
    CreateSlider(miscContent, "WalkSpeed", "Tốc độ di chuyển", {"Misc", "WalkSpeed"}, 16, 100, 1)
    CreateSlider(miscContent, "JumpPower", "Độ cao khi nhảy", {"Misc", "JumpPower"}, 50, 200, 1)
    CreateToggle(miscContent, "Fly", "Cho phép nhân vật bay tự do", {"Misc", "Fly"})
    CreateToggle(miscContent, "Noclip", "Đi xuyên tường và vật cản", {"Misc", "Noclip"})
    CreateToggle(miscContent, "Infinite Jump", "Nhảy liên tục không giới hạn", {"Misc", "InfiniteJump"})
end

CreateUI()
BuildUI()

local function IsTeamMate(player)
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
    if not Settings.ESP.VisibilityCheck then return true end
    local character = target.Character
    if not character then return true end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return true end
    
    local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 500)
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
        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local boneName = Settings.Aimbot.AimBone
        if boneName == "Random" then
            local bones = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
            boneName = bones[math.random(#bones)]
        end
        local bonePos = GetBonePos(character, boneName)
        if not bonePos then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(bonePos)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        local hitboxMultiplier = Settings.Aimbot.HitboxExpansion
        if boneName == "Head" then
            dist = dist / hitboxMultiplier
        end
        
        if dist <= maxFOV then
            if dist < bestValue then
                bestValue = dist
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
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

local function IsAimKeyPressed()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end

    local shouldAim = false
    if Settings.Aimbot.Rage then shouldAim = true end
    if Settings.Aimbot.Legit then shouldAim = IsAimKeyPressed() or (UserInputService.TouchEnabled and UserInputService.TouchCount > 0) end
    if Settings.Aimbot.Silent then 
        shouldAim = false
        if Settings.Aimbot.Rage then
            local target = GetAimbotTarget()
            if target then
                ActivateTool()
            end
        end
        return
    end

    if shouldAim then
        local target = GetAimbotTarget()
        if target then
            CurrentTarget = target
            local character = target.Character
            local boneName = Settings.Aimbot.AimBone
            if boneName == "Random" then boneName = "Head" end
            local bonePos = GetBonePos(character, boneName)
            if bonePos then
                local targetCF = CFrame.new(Camera.CFrame.Position, bonePos)
                if Settings.Aimbot.SmoothAim then
                    local smooth = 1 / (Settings.Aimbot.Smoothness + 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
                else
                    Camera.CFrame = targetCF
                end
                if Settings.Aimbot.Rage then
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
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromRGB(0, 150, 255)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.7
    end
    FOVCircle.Visible = Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOVRadius / 2
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function CleanupESP()
    for _, d in pairs(ESPDrawings) do
        pcall(function() d:Remove() end)
    end
    ESPDrawings = {}
    for _, glow in pairs(GlowObjects) do
        pcall(function() glow:Destroy() end)
    end
    GlowObjects = {}
end

local function UpdateGlow()
    for _, glow in pairs(GlowObjects) do
        pcall(function() glow:Destroy() end)
    end
    GlowObjects = {}
    
    if not Settings.ESP.Glow then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local isVis = IsVisible(player)
        local glowColor = isVis and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 255, 70)
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                local glow = Instance.new("Highlight")
                glow.FillColor = glowColor
                glow.OutlineColor = glowColor
                glow.FillTransparency = 0.4
                glow.Enabled = true
                glow.Parent = part
                GlowObjects[#GlowObjects + 1] = glow
            end
        end
    end
end

local function UpdateESP()
    CleanupESP()
    if not Settings.ESP.Enabled then return end

    local tracerMode = Settings.ESP.TracerMode
    local origin
    if tracerMode == 1 then
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    elseif tracerMode == 2 then
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    elseif tracerMode == 3 then
        origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local isVis = IsVisible(player)
        local tracerColor = isVis and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 255, 70)
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Tracer Line
            local tracer = Drawing.new("Line")
            tracer.Color = tracerColor
            tracer.Thickness = 2
            tracer.Visible = true
            tracer.Transparency = 0.8
            tracer.From = origin
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            ESPDrawings[#ESPDrawings + 1] = tracer

            -- Skeleton
            if Settings.ESP.Skeleton then
                local skeletonBones = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}
                local bonePositions = {}
                for _, boneName in ipairs(skeletonBones) do
                    local bone = character:FindFirstChild(boneName)
                    if bone then
                        local pos, visible = Camera:WorldToViewportPoint(bone.Position)
                        if visible then
                            bonePositions[boneName] = Vector2.new(pos.X, pos.Y)
                        end
                    end
                end
                local connections = {
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
                for _, pair in ipairs(connections) do
                    local p1 = bonePositions[pair[1]]
                    local p2 = bonePositions[pair[2]]
                    if p1 and p2 then
                        local line = Drawing.new("Line")
                        line.Color = tracerColor
                        line.Thickness = 2
                        line.Visible = true
                        line.Transparency = 0.7
                        line.From = p1
                        line.To = p2
                        ESPDrawings[#ESPDrawings + 1] = line
                    end
                end
            end
        end
    end
    
    UpdateGlow()
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
    watermark.Text = "⚡ Superhero Team | FPS: " .. FPS .. " | Ping: " .. Ping .. "ms"
    watermark.Color = Color3.fromRGB(255, 255, 255)
    watermark.Size = 14
    watermark.Position = Vector2.new(12, Camera.ViewportSize.Y - 28)
    watermark.Visible = true
    watermark.Transparency = 0.6
    task.delay(1, function()
        watermark:Remove()
    end)
end

RunService.RenderStepped:Connect(function()
    DrawFOVCircle()
    AimbotLoop()
    ApplyPlayerMods()
    WatermarkUpdate()
    UpdateESP()
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
        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        end
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
    OpenButton.BackgroundColor3 = Colors.Accent
    OpenButton.BorderSizePixel = 0
    OpenButton.Position = UDim2.new(0, 14, 0, 14)
    OpenButton.Size = UDim2.new(0, 48, 0, 48)
    OpenButton.Text = "⚡"
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.TextColor3 = Colors.Text
    OpenButton.TextSize = 24
    OpenButton.AutoButtonColor = false
    OpenButton.Visible = false
    OpenButton.ZIndex = 10
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = OpenButton
    
    local shadow = Instance.new("Frame")
    shadow.Parent = OpenButton
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.4
    shadow.BorderSizePixel = 0
    shadow.Position = UDim2.new(0, 4, 0, 4)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.ZIndex = -1
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 14)
    shadowCorner.Parent = shadow
    
    OpenButton.MouseEnter:Connect(function()
        TweenService:Create(OpenButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 52, 0, 52)}):Play()
    end)
    OpenButton.MouseLeave:Connect(function()
        TweenService:Create(OpenButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 48, 0, 48)}):Play()
    end)
    
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
    Text = "Script loaded! Press RightShift to toggle menu.",
    Duration = 5
})