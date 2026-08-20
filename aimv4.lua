local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/0x1f1e/uwu/main/drawing.lua"))()
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local Settings = {
    Aimbot = {
        Enabled = false,
        Mode = "Rage",
        Silent = false,
        Smooth = false,
        Smoothness = 10,
        FOV = 100,
        Target = "Closest",
        Bone = "Head",
        Triggerbot = false,
        TeamCheck = true
    },
    ESP = {
        Enabled = false,
        Box2D = true,
        Box3D = false,
        Skeleton = false,
        Line2D = false,
        Glow = false,
        Chams = false,
        Health = true,
        Distance = true,
        Name = true,
        Weapon = true,
        BarrelLine = false,
        TeamCheck = true
    },
    World = {
        Enabled = false,
        ItemESP = false,
        VehicleESP = false,
        RadarESP = false,
        GrenadeESP = false
    },
    Misc = {
        FixLag = false,
        ESPDistanceLimit = 5,
        CleanMemory = false
    }
}

local GUI = nil
local MainFrame = nil
local Tabs = {}
local ContentFrames = {}
local UIObjects = {}
local Dragging = false
local DragStart = nil
local DragOffset = nil
local FOVCircle = nil

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
                        Settings[k][k2] = v2
                    end
                end
            end
        end
    end)
end

LoadSettings()

local function CreateGUI()
    GUI = Instance.new("ScreenGui")
    GUI.Name = "SuperheroTeam"
    GUI.Parent = game:GetService("CoreGui")
    GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Parent = GUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = false

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.Active = true

    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.Size = UDim2.new(0, 100, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "Superhero Team"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.AutoButtonColor = false
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            DragOffset = MainFrame.Position
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

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Parent = MainFrame
    TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBar.BorderSizePixel = 0
    TabBar.Position = UDim2.new(0, 0, 0, 40)
    TabBar.Size = UDim2.new(1, 0, 0, 40)

    local TabNames = {"Aimbot", "ESP", "World", "Misc"}
    for i, tabName in ipairs(TabNames) do
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabBar
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.BorderSizePixel = 0
        TabButton.Position = UDim2.new((i - 1) / #TabNames, 0, 0, 0)
        TabButton.Size = UDim2.new(1 / #TabNames, -2, 1, 0)
        TabButton.Text = tabName
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 16
        TabButton.AutoButtonColor = false
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton

        Tabs[tabName] = TabButton
    end

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0, 0, 0, 80)
    ContentContainer.Size = UDim2.new(1, 0, 1, -80)

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Parent = ContentContainer
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 10
    ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.ClipsDescendants = true

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)

    for i, tabName in ipairs(TabNames) do
        local Content = Instance.new("Frame")
        Content.Name = tabName
        Content.Parent = ScrollingFrame
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.Size = UDim2.new(1, -16, 0, 0)
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
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
        end
        local target = ContentFrames[tabName]
        if target then
            target.Size = UDim2.new(1, -16, 0, 0)
            local totalHeight = 0
            for _, child in ipairs(target:GetChildren()) do
                if child:IsA("UIListLayout") then continue end
                totalHeight += child.Size.Y.Offset + 8
            end
            target.Size = UDim2.new(1, -16, 0, totalHeight)
        end
    end

    for name, btn in pairs(Tabs) do
        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Aimbot")
end

local function CreateToggle(parent, text, settingPath, defaultValue)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, 45)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton")
    toggle.Parent = holder
    toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(0.75, 0, 0, 10)
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle

    local function UpdateToggle()
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                value = value[key]
            else
                value = value[key]
            end
        end
        if value then
            toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                value[key] = not value[key]
            else
                value = value[key]
            end
        end
        SaveSettings()
        UpdateToggle()
    end)

    UpdateToggle()
    return holder
end

local function CreateSlider(parent, text, settingPath, min, max, default)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, 70)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 5)
    label.Size = UDim2.new(1, -24, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("TextButton")
    slider.Parent = holder
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.BorderSizePixel = 0
    slider.Position = UDim2.new(0, 12, 0, 30)
    slider.Size = UDim2.new(1, -24, 0, 20)
    slider.Text = ""
    slider.AutoButtonColor = false
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 10)
    sliderCorner.Parent = slider

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = fill

    local function GetValue()
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                return value[key]
            else
                value = value[key]
            end
        end
    end

    local function SetValue(val)
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                value[key] = val
            else
                value = value[key]
            end
        end
        SaveSettings()
    end

    local function UpdateSlider()
        local val = GetValue()
        local ratio = (val - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = text .. " : " .. tostring(val)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local function UpdateFromInput(pos)
                local relative = pos.X - slider.AbsolutePosition.X
                local ratio = math.clamp(relative / slider.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * ratio
                if max > 20 then
                    val = math.floor(val)
                else
                    val = math.floor(val * 10) / 10
                end
                SetValue(val)
                UpdateSlider()
            end
            UpdateFromInput(input.Position)
            local connection
            connection = UserInputService.InputChanged:Connect(function(change)
                if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                    UpdateFromInput(change.Position)
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

    UpdateSlider()
    return holder
end

local function CreateDropdown(parent, text, settingPath, options)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 0, 50)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 5)
    label.Size = UDim2.new(1, -24, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton")
    button.Parent = holder
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 12, 0, 25)
    button.Size = UDim2.new(1, -24, 0, 25)
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 15
    button.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button

    local function GetValue()
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                return value[key]
            else
                value = value[key]
            end
        end
    end

    local function SetValue(val)
        local value = Settings
        local path = settingPath:split(".")
        for i, key in ipairs(path) do
            if i == #path then
                value[key] = val
            else
                value = value[key]
            end
        end
        SaveSettings()
    end

    local function UpdateButton()
        button.Text = GetValue()
    end

    local dropdown = Instance.new("Frame")
    dropdown.Parent = holder
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.BorderSizePixel = 0
    dropdown.Position = UDim2.new(0, 12, 0, 55)
    dropdown.Size = UDim2.new(1, -24, 0, 0)
    dropdown.Visible = false
    dropdown.ZIndex = 5
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
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
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        optBtn.TextSize = 15
        optBtn.AutoButtonColor = false
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 6)
        optCorner.Parent = optBtn
        optBtn.MouseButton1Click:Connect(function()
            SetValue(opt)
            UpdateButton()
            dropdown.Visible = false
        end)
    end

    button.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
        dropdown.Size = UDim2.new(1, -24, 0, #options * 34)
    end)

    UpdateButton()
    return holder
end

local function BuildUI()
    local aimbotContent = ContentFrames["Aimbot"]
    CreateToggle(aimbotContent, "Enabled", "Aimbot.Enabled")
    CreateDropdown(aimbotContent, "Mode", "Aimbot.Mode", {"Rage", "Legit", "Silent"})
    CreateToggle(aimbotContent, "Smooth", "Aimbot.Smooth")
    CreateSlider(aimbotContent, "Smoothness", "Aimbot.Smoothness", 1, 20, 10)
    CreateSlider(aimbotContent, "FOV", "Aimbot.FOV", 10, 360, 100)
    CreateDropdown(aimbotContent, "Target", "Aimbot.Target", {"Closest", "LowestHealth"})
    CreateDropdown(aimbotContent, "Bone", "Aimbot.Bone", {"Head", "UpperTorso", "HumanoidRootPart"})
    CreateToggle(aimbotContent, "Triggerbot", "Aimbot.Triggerbot")
    CreateToggle(aimbotContent, "Team Check", "Aimbot.TeamCheck")

    local espContent = ContentFrames["ESP"]
    CreateToggle(espContent, "Enabled", "ESP.Enabled")
    CreateToggle(espContent, "Box 2D", "ESP.Box2D")
    CreateToggle(espContent, "Box 3D", "ESP.Box3D")
    CreateToggle(espContent, "Skeleton", "ESP.Skeleton")
    CreateToggle(espContent, "Line 2D", "ESP.Line2D")
    CreateToggle(espContent, "Glow", "ESP.Glow")
    CreateToggle(espContent, "Chams", "ESP.Chams")
    CreateToggle(espContent, "Health", "ESP.Health")
    CreateToggle(espContent, "Distance", "ESP.Distance")
    CreateToggle(espContent, "Name", "ESP.Name")
    CreateToggle(espContent, "Weapon", "ESP.Weapon")
    CreateToggle(espContent, "Barrel Line", "ESP.BarrelLine")
    CreateToggle(espContent, "Team Check", "ESP.TeamCheck")

    local worldContent = ContentFrames["World"]
    CreateToggle(worldContent, "Enabled", "World.Enabled")
    CreateToggle(worldContent, "Item ESP", "World.ItemESP")
    CreateToggle(worldContent, "Vehicle ESP", "World.VehicleESP")
    CreateToggle(worldContent, "Radar ESP", "World.RadarESP")
    CreateToggle(worldContent, "Grenade ESP", "World.GrenadeESP")

    local miscContent = ContentFrames["Misc"]
    CreateToggle(miscContent, "Fix Lag", "Misc.FixLag")
    CreateSlider(miscContent, "ESP Distance Limit", "Misc.ESPDistanceLimit", 1, 50, 5)
    CreateToggle(miscContent, "Clean Memory", "Misc.CleanMemory")
end

CreateGUI()
BuildUI()

local function IsTeamMate(player)
    if not Settings.Aimbot.TeamCheck and not Settings.ESP.TeamCheck then return false end
    if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return true end
    if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then return true end
    return false
end

local function GetBonePos(character, boneName)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    local part = character:FindFirstChild(boneName)
    if not part then return nil end
    return part.Position
end

local function GetAimbotTarget()
    local target = nil
    local bestValue = nil
    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeamMate(player) then continue end
        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local bonePos = GetBonePos(character, Settings.Aimbot.Bone)
        if not bonePos then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(bonePos)
        if not onScreen then continue end
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        local maxDistance = Settings.Aimbot.FOV / 2

        if distance <= maxDistance then
            if Settings.Aimbot.Target == "Closest" then
                if not bestValue or distance < bestValue then
                    bestValue = distance
                    target = player
                end
            elseif Settings.Aimbot.Target == "LowestHealth" then
                local health = humanoid.Health
                if not bestValue or health < bestValue then
                    bestValue = health
                    target = player
                end
            end
        end
    end
    return target
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

local function FireRemote(tool)
    local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Remotes")
    if remote then
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
        elseif remote:IsA("Folder") or remote:IsA("Configuration") then
            local fire = remote:FindFirstChild("FireServer") or remote:FindFirstChild("Shoot")
            if fire and fire:IsA("RemoteEvent") then
                fire:FireServer()
            end
        end
    end
end

local function ActivateTool()
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    if tool:FindFirstChild("Handle") then
        FireRemote(tool)
    end
end

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end
    local target = GetAimbotTarget()
    if target then
        local character = target.Character
        local bonePos = GetBonePos(character, Settings.Aimbot.Bone)
        if bonePos then
            if Settings.Aimbot.Mode == "Rage" then
                if Settings.Aimbot.Smooth then
                    local targetCF = CFrame.new(Camera.CFrame.Position, bonePos)
                    local smoothed = Camera.CFrame:Lerp(targetCF, Settings.Aimbot.Smoothness / 100)
                    Camera.CFrame = smoothed
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, bonePos)
                end
                ActivateTool()
            elseif Settings.Aimbot.Mode == "Legit" then
                local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.TouchEnabled
                if isAiming then
                    if Settings.Aimbot.Smooth then
                        local targetCF = CFrame.new(Camera.CFrame.Position, bonePos)
                        local smoothed = Camera.CFrame:Lerp(targetCF, Settings.Aimbot.Smoothness / 100)
                        Camera.CFrame = smoothed
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, bonePos)
                    end
                end
            elseif Settings.Aimbot.Mode == "Silent" then
                ActivateTool()
            end
        end
    end
    if Settings.Aimbot.Triggerbot then
        local mouseTarget = GetMouseTarget()
        if mouseTarget then
            ActivateTool()
        end
    end
end

local function DrawFOVCircle()
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Filled = false
        FOVCircle.Radius = Settings.Aimbot.FOV / 2
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
    FOVCircle.Visible = Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV / 2
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local ESPDrawings = {}

local function CleanupESP()
    for _, drawing in pairs(ESPDrawings) do
        drawing:Remove()
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
    local color = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    local drawingContainer = {}

    if Settings.ESP.Box2D then
        local box = Drawing.new("Square")
        box.Color = color
        box.Thickness = 2
        box.Filled = false
        box.Visible = false
        drawingContainer.Box2D = box
        ESPDrawings[#ESPDrawings + 1] = box
    end

    if Settings.ESP.Box3D then
        local box3d = Drawing.new("Square")
        box3d.Color = color
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
            line.Color = color
            line.Thickness = 2
            line.Visible = false
            drawingContainer.Skeleton[boneName] = line
            ESPDrawings[#ESPDrawings + 1] = line
        end
    end

    if Settings.ESP.Line2D then
        local line = Drawing.new("Line")
        line.Color = color
        line.Thickness = 2
        line.Visible = false
        drawingContainer.Line2D = line
        ESPDrawings[#ESPDrawings + 1] = line
    end

    if Settings.ESP.Health then
        local healthBar = Drawing.new("Square")
        healthBar.Color = color
        healthBar.Thickness = 2
        healthBar.Filled = true
        healthBar.Visible = false
        drawingContainer.HealthBar = healthBar
        ESPDrawings[#ESPDrawings + 1] = healthBar

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

    if Settings.ESP.BarrelLine then
        local barrelLine = Drawing.new("Line")
        barrelLine.Color = color
        barrelLine.Thickness = 1
        barrelLine.Visible = false
        drawingContainer.BarrelLine = barrelLine
        ESPDrawings[#ESPDrawings + 1] = barrelLine
    end

    return drawingContainer
end

local function UpdateESP()
    CleanupESP()
    if not Settings.ESP.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeamMate(player) and Settings.ESP.TeamCheck then
            local container = CreateESPForPlayer(player)
            if container then
                task.spawn(function()
                    while Settings.ESP.Enabled and player.Parent and player.Character do
                        local character = player.Character
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then break end
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if not rootPart then break end
                        local head = character:FindFirstChild("Head")
                        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            local size = (Camera.CFrame.Position - rootPart.Position).Magnitude
                            size = math.clamp(2000 / size, 10, 200)
                            if container.Box2D then
                                container.Box2D.Visible = true
                                container.Box2D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size)
                                container.Box2D.Size = Vector2.new(size, size)
                            end
                            if container.Box3D then
                                container.Box3D.Visible = true
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
                                            line.From = Vector2.new(screenPos.X, screenPos.Y)
                                            line.To = Vector2.new(boneScreen.X, boneScreen.Y)
                                        elseif line then
                                            line.Visible = false
                                        end
                                    end
                                end
                            end
                            if container.Line2D then
                                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                                container.Line2D.Visible = true
                                container.Line2D.From = center
                                container.Line2D.To = Vector2.new(screenPos.X, screenPos.Y)
                            end
                            if container.HealthBar and container.HealthText then
                                local health = humanoid.Health / humanoid.MaxHealth
                                container.HealthBar.Visible = true
                                container.HealthBar.Position = Vector2.new(screenPos.X - size/2 - 5, screenPos.Y - size)
                                container.HealthBar.Size = Vector2.new(4, size * health)
                                container.HealthText.Visible = true
                                container.HealthText.Text = tostring(math.floor(humanoid.Health))
                                container.HealthText.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size - 5)
                            end
                            if container.DistanceText then
                                local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
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
                            if container.BarrelLine then
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool and tool:FindFirstChild("Handle") then
                                    local handlePos = tool.Handle.Position
                                    local targetPos = GetBonePos(character, "Head") or rootPart.Position
                                    local handleScreen, handleOn = Camera:WorldToViewportPoint(handlePos)
                                    local targetScreen, targetOn = Camera:WorldToViewportPoint(targetPos)
                                    if handleOn and targetOn then
                                        container.BarrelLine.Visible = true
                                        container.BarrelLine.From = Vector2.new(handleScreen.X, handleScreen.Y)
                                        container.BarrelLine.To = Vector2.new(targetScreen.X, targetScreen.Y)
                                    else
                                        container.BarrelLine.Visible = false
                                    end
                                else
                                    container.BarrelLine.Visible = false
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
        elseif not IsTeamMate(player) then
            local container = CreateESPForPlayer(player)
            if container then
                task.spawn(function()
                    while Settings.ESP.Enabled and player.Parent and player.Character do
                        local character = player.Character
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then break end
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if not rootPart then break end
                        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            local size = (Camera.CFrame.Position - rootPart.Position).Magnitude
                            size = math.clamp(2000 / size, 10, 200)
                            if container.Box2D then
                                container.Box2D.Visible = true
                                container.Box2D.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size)
                                container.Box2D.Size = Vector2.new(size, size)
                            end
                            if container.Box3D then
                                container.Box3D.Visible = true
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
                                            line.From = Vector2.new(screenPos.X, screenPos.Y)
                                            line.To = Vector2.new(boneScreen.X, boneScreen.Y)
                                        elseif line then
                                            line.Visible = false
                                        end
                                    end
                                end
                            end
                            if container.Line2D then
                                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                                container.Line2D.Visible = true
                                container.Line2D.From = center
                                container.Line2D.To = Vector2.new(screenPos.X, screenPos.Y)
                            end
                            if container.HealthBar and container.HealthText then
                                local health = humanoid.Health / humanoid.MaxHealth
                                container.HealthBar.Visible = true
                                container.HealthBar.Position = Vector2.new(screenPos.X - size/2 - 5, screenPos.Y - size)
                                container.HealthBar.Size = Vector2.new(4, size * health)
                                container.HealthText.Visible = true
                                container.HealthText.Text = tostring(math.floor(humanoid.Health))
                                container.HealthText.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size - 5)
                            end
                            if container.DistanceText then
                                local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
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
                            if container.BarrelLine then
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool and tool:FindFirstChild("Handle") then
                                    local handlePos = tool.Handle.Position
                                    local targetPos = GetBonePos(character, "Head") or rootPart.Position
                                    local handleScreen, handleOn = Camera:WorldToViewportPoint(handlePos)
                                    local targetScreen, targetOn = Camera:WorldToViewportPoint(targetPos)
                                    if handleOn and targetOn then
                                        container.BarrelLine.Visible = true
                                        container.BarrelLine.From = Vector2.new(handleScreen.X, handleScreen.Y)
                                        container.BarrelLine.To = Vector2.new(targetScreen.X, targetScreen.Y)
                                    else
                                        container.BarrelLine.Visible = false
                                    end
                                else
                                    container.BarrelLine.Visible = false
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
end

local function UpdateGlowAndChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if Settings.ESP.Glow then
                        local glow = part:FindFirstChildOfClass("Highlight")
                        if not glow then
                            glow = Instance.new("Highlight")
                            glow.Parent = part
                        end
                        if IsTeamMate(player) then
                            glow.FillColor = Color3.fromRGB(0, 255, 0)
                            glow.OutlineColor = Color3.fromRGB(0, 255, 0)
                        else
                            glow.FillColor = Color3.fromRGB(255, 0, 0)
                            glow.OutlineColor = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        local glow = part:FindFirstChildOfClass("Highlight")
                        if glow then glow:Destroy() end
                    end
                    if Settings.ESP.Chams then
                        if IsTeamMate(player) then
                            part.Material = Enum.Material.ForceField
                            part.Color = Color3.fromRGB(0, 255, 0)
                        else
                            part.Material = Enum.Material.ForceField
                            part.Color = Color3.fromRGB(255, 0, 0)
                        end
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

local RadarDrawings = {}

local function UpdateRadar()
    if not Settings.World.RadarESP then
        for _, d in pairs(RadarDrawings) do d:Remove() end
        RadarDrawings = {}
        return
    end
    for _, d in pairs(RadarDrawings) do d:Remove() end
    RadarDrawings = {}
    local radarCenter = Vector2.new(Camera.ViewportSize.X - 120, Camera.ViewportSize.Y - 120)
    local radarRadius = 100
    local bg = Drawing.new("Circle")
    bg.Color = Color3.fromRGB(0, 0, 0)
    bg.Thickness = 2
    bg.Filled = true
    bg.Radius = radarRadius
    bg.Position = radarCenter
    bg.Visible = true
    RadarDrawings[#RadarDrawings + 1] = bg

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local character = player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local relative = root.Position - LocalPlayer.Character.HumanoidRootPart.Position
                local angle = math.atan2(relative.Z, relative.X) - math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)
                local dist = relative.Magnitude
                local scaledDist = math.clamp(dist / 10, 0, radarRadius - 5)
                local pos = radarCenter + Vector2.new(math.cos(angle) * scaledDist, math.sin(angle) * scaledDist)
                local dot = Drawing.new("Circle")
                dot.Color = IsTeamMate(player) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
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

local function FixLag()
    if not Settings.Misc.FixLag then return end
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Texture") or descendant:IsA("Decal") then
            descendant:Destroy()
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Smoke") or descendant:IsA("Fire") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic
            descendant.CastShadow = false
            descendant.Reflectance = 0
        elseif descendant:IsA("Lighting") then
            -- do nothing
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.SmoothPlastic
                    part.CastShadow = false
                elseif part:IsA("Accessory") or part:IsA("Hat") or part:IsA("Shirt") or part:IsA("Pants") then
                    part:Destroy()
                end
            end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            end
        end
    end
end

local function CleanMemory()
    if Settings.Misc.CleanMemory then
        task.spawn(function()
            while true do
                wait(30)
                local mem = collectgarbage("count")
                if mem > 500 then
                    collectgarbage("collect")
                end
            end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    DrawFOVCircle()
    AimbotLoop()
    UpdateRadar()
end)

RunService.Heartbeat:Connect(function()
    if Settings.ESP.Enabled then
        UpdateGlowAndChams()
    end
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

CleanMemory()

local function ToggleUI()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleUI()
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Superhero Team",
    Text = "Script loaded! Press RightShift to toggle.",
    Duration = 5
})