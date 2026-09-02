local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    AimbotEnabled = false,
    SilentAim = false,
    TriggerBot = false,
    TriggerDelay = 0.1,
    FOV = 150,
    Smoothness = 0.25,
    AimPart = "Head",
    TeamCheck = true,
    VisibleCheck = true,
    Prediction = false,
    PredictionAmount = 0.2,
    ESPEnabled = false,
    BoxESP = true,
    SkeletonESP = true,
    NameESP = true,
    HealthBar = true,
    Tracer = true,
    DistanceCheck = true,
    MaxDistance = 200,
    ESPColor = Color3.fromRGB(0, 255, 100),
    MenuOpen = true,
    ShowFOVCircle = true,
    ThemeColor = "Cyan",
    MenuX = 0.5,
    MenuY = 0.5
}

local Themes = {
    Cyan = {primary = Color3.fromRGB(0, 200, 255), secondary = Color3.fromRGB(0, 255, 200), glow = Color3.fromRGB(0, 180, 255)},
    Red = {primary = Color3.fromRGB(255, 50, 50), secondary = Color3.fromRGB(255, 100, 50), glow = Color3.fromRGB(255, 0, 0)},
    Purple = {primary = Color3.fromRGB(180, 50, 255), secondary = Color3.fromRGB(220, 50, 255), glow = Color3.fromRGB(150, 0, 255)},
    Gold = {primary = Color3.fromRGB(255, 200, 0), secondary = Color3.fromRGB(255, 220, 50), glow = Color3.fromRGB(255, 180, 0)}
}

local function GetTheme()
    return Themes[Settings.ThemeColor] or Themes.Cyan
end

local ESPPool = {
    Lines = {},
    Boxes = {},
    Texts = {},
    HealthBars = {}
}

local function GetLine()
    for i, line in pairs(ESPPool.Lines) do
        if not line.Visible then
            line.Visible = true
            return line
        end
    end
    local newLine = Drawing.new("Line")
    newLine.Visible = true
    table.insert(ESPPool.Lines, newLine)
    return newLine
end

local function GetText()
    for i, text in pairs(ESPPool.Texts) do
        if not text.Visible then
            text.Visible = true
            return text
        end
    end
    local newText = Drawing.new("Text")
    newText.Visible = true
    newText.Center = true
    newText.Outline = true
    newText.OutlineColor = Color3.fromRGB(0, 0, 0)
    newText.Size = 12
    table.insert(ESPPool.Texts, newText)
    return newText
end

local function ResetPool()
    for _, obj in pairs(ESPPool.Lines) do obj.Visible = false end
    for _, obj in pairs(ESPPool.Boxes) do obj.Visible = false end
    for _, obj in pairs(ESPPool.Texts) do obj.Visible = false end
    for _, obj in pairs(ESPPool.HealthBars) do obj.Visible = false end
end

local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then FOVCircle.Visible = false; FOVCircle = nil end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Settings.ShowFOVCircle and Settings.AimbotEnabled
    FOVCircle.Radius = Settings.FOV / 1.5
    FOVCircle.Thickness = 2
    FOVCircle.Color = GetTheme().primary
    FOVCircle.Filled = false
    FOVCircle.NumSides = 72
    FOVCircle.Transparency = 0.4
end

local function UpdateFOVCircle()
    if FOVCircle then
        local centerX = Camera.ViewportSize.X / 2
        local centerY = Camera.ViewportSize.Y / 2
        FOVCircle.Position = Vector2.new(centerX, centerY)
        FOVCircle.Radius = Settings.FOV / 1.5
        FOVCircle.Visible = Settings.ShowFOVCircle and Settings.AimbotEnabled
        FOVCircle.Color = GetTheme().primary
    end
end

local Cache = {
    Players = {},
    LastUpdate = 0
}

local function GetValidPlayers()
    if tick() - Cache.LastUpdate < 0.05 then return Cache.Players end
    
    local valid = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local character = player.Character
            if not character or not character.PrimaryPart then continue end
            
            local aimPart = character:FindFirstChild(Settings.AimPart)
            if not aimPart then aimPart = character.PrimaryPart end
            
            local vectorToTarget = (aimPart.Position - Camera.CFrame.Position).unit
            local angle = math.deg(math.acos(Camera.CFrame.LookVector:Dot(vectorToTarget)))
            
            if angle <= Settings.FOV then
                table.insert(valid, {
                    Player = player,
                    Character = character,
                    AimPart = aimPart,
                    Angle = angle,
                    Distance = (aimPart.Position - Camera.CFrame.Position).Magnitude
                })
            end
        end
    end
    
    table.sort(valid, function(a, b) return a.Angle < b.Angle end)
    Cache.Players = valid
    Cache.LastUpdate = tick()
    return valid
end

local function GetClosestPlayer()
    local players = GetValidPlayers()
    if #players == 0 then return nil end
    
    for _, data in pairs(players) do
        if Settings.VisibleCheck then
            local ray = Ray.new(Camera.CFrame.Position, (data.AimPart.Position - Camera.CFrame.Position).unit * 1000)
            local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and not hit:IsDescendantOf(data.Character) then
                continue
            end
        end
        return data
    end
    return nil
end

local function GetPredictedPosition(target)
    if not Settings.Prediction then return target end
    
    local velocity = target.Velocity or Vector3.new()
    local prediction = velocity * Settings.PredictionAmount
    return target + prediction
end

local function GetBoxSize(character)
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not root then return nil end
    
    local headPos, onScreen1 = Camera:WorldToScreenPoint(head.Position)
    local rootPos, onScreen2 = Camera:WorldToScreenPoint(root.Position)
    if not onScreen1 or not onScreen2 then return nil end
    
    local height = math.abs(headPos.Y - rootPos.Y) * 1.2
    local width = height * 0.5
    
    return {
        Top = rootPos.Y - height,
        Left = rootPos.X - width / 2,
        Width = width,
        Height = height,
        Center = Vector2.new(rootPos.X, rootPos.Y - height / 2)
    }
end

local function DrawBoxESP(player)
    if not Settings.BoxESP then return end
    
    local character = player.Character
    if not character then return end
    
    local box = GetBoxSize(character)
    if not box then return end
    
    local line1 = GetLine()
    line1.From = Vector2.new(box.Left, box.Top)
    line1.To = Vector2.new(box.Left + box.Width, box.Top)
    line1.Color = Settings.ESPColor
    line1.Thickness = 1.5
    
    local line2 = GetLine()
    line2.From = Vector2.new(box.Left + box.Width, box.Top)
    line2.To = Vector2.new(box.Left + box.Width, box.Top + box.Height)
    line2.Color = Settings.ESPColor
    line2.Thickness = 1.5
    
    local line3 = GetLine()
    line3.From = Vector2.new(box.Left + box.Width, box.Top + box.Height)
    line3.To = Vector2.new(box.Left, box.Top + box.Height)
    line3.Color = Settings.ESPColor
    line3.Thickness = 1.5
    
    local line4 = GetLine()
    line4.From = Vector2.new(box.Left, box.Top + box.Height)
    line4.To = Vector2.new(box.Left, box.Top)
    line4.Color = Settings.ESPColor
    line4.Thickness = 1.5
    
    return box
end

local function DrawSkeletonESP(player)
    if not Settings.SkeletonESP then return end
    
    local character = player.Character
    if not character then return end
    
    local joints = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"RightUpperLeg", "RightLowerLeg"}
    }
    
    for _, joint in pairs(joints) do
        local part1 = character:FindFirstChild(joint[1])
        local part2 = character:FindFirstChild(joint[2])
        if part1 and part2 then
            local pos1, onScreen1 = Camera:WorldToScreenPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToScreenPoint(part2.Position)
            if onScreen1 and onScreen2 then
                local line = GetLine()
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = Settings.ESPColor
                line.Thickness = 1.5
            end
        end
    end
end

local function DrawNameESP(player, box)
    if not Settings.NameESP or not box then return end
    
    local distance = math.floor((player.Character.PrimaryPart.Position - Camera.CFrame.Position).Magnitude)
    if Settings.DistanceCheck and distance > Settings.MaxDistance then return end
    
    local text = GetText()
    text.Position = Vector2.new(box.Left + box.Width / 2, box.Top - 20)
    text.Text = player.Name .. " [" .. distance .. "m]"
    text.Color = Settings.ESPColor
    text.Size = 12
end

local function DrawHealthBar(player, box)
    if not Settings.HealthBar or not box then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local health = humanoid.Health / humanoid.MaxHealth
    local healthColor = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
    
    local barX = box.Left - 8
    local barY = box.Top
    local barWidth = 4
    local barHeight = box.Height
    
    local bgLine = GetLine()
    bgLine.From = Vector2.new(barX, barY)
    bgLine.To = Vector2.new(barX, barY + barHeight)
    bgLine.Color = Color3.fromRGB(40, 40, 40)
    bgLine.Thickness = barWidth
    
    local healthLine = GetLine()
    healthLine.From = Vector2.new(barX, barY + barHeight * (1 - health))
    healthLine.To = Vector2.new(barX, barY + barHeight)
    healthLine.Color = healthColor
    healthLine.Thickness = barWidth
end

local function DrawTracer(player)
    if not Settings.Tracer then return end
    
    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
    if not onScreen then return end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local line = GetLine()
    line.From = center
    line.To = Vector2.new(pos.X, pos.Y)
    line.Color = Settings.ESPColor
    line.Thickness = 1
    line.Transparency = 0.3
end

local function CreateESP()
    ResetPool()
    if not Settings.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
            if not character or not character.PrimaryPart then continue end
            
            local distance = (character.PrimaryPart.Position - Camera.CFrame.Position).Magnitude
            if Settings.DistanceCheck and distance > Settings.MaxDistance then continue end
            
            local box = DrawBoxESP(player)
            DrawSkeletonESP(player)
            DrawNameESP(player, box)
            DrawHealthBar(player, box)
            DrawTracer(player)
        end
    end
end

local TriggerCooldown = 0
local function TriggerBot()
    if not Settings.TriggerBot then return end
    if tick() - TriggerCooldown < Settings.TriggerDelay then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local aimPart = target.AimPart
    local ray = Ray.new(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).unit * 1000)
    local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit and hit:IsDescendantOf(target.Character) then
        mouse1click()
        TriggerCooldown = tick()
    end
end

local menuGui = nil
local mainFrame = nil
local bubbleFrame = nil
local isDragging = false
local dragStart = Vector2.new()
local dragOffset = Vector2.new()
local isMenuOpen = true
local currentTab = "Main"

local function CreateModernUI()
    if menuGui then
        menuGui:Destroy()
        menuGui = nil
    end
    
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "ModernMenu"
    menuGui.Parent = LocalPlayer.PlayerGui
    menuGui.ResetOnSpawn = false
    menuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    bubbleFrame = Instance.new("Frame")
    bubbleFrame.Size = UDim2.new(0, 56, 0, 56)
    bubbleFrame.Position = UDim2.new(Settings.MenuX, -28, Settings.MenuY, -28)
    bubbleFrame.BackgroundColor3 = GetTheme().primary
    bubbleFrame.BackgroundTransparency = 0.1
    bubbleFrame.BorderSizePixel = 2
    bubbleFrame.BorderColor3 = GetTheme().primary
    bubbleFrame.ClipsDescendants = true
    bubbleFrame.Parent = menuGui
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubbleFrame
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.Position = UDim2.new(0.5, -15, 0.5, -15)
    glow.BackgroundColor3 = GetTheme().primary
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.Parent = bubbleFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 30
    icon.TextScaled = true
    icon.Parent = bubbleFrame
    
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(1, 0, 1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.Parent = bubbleFrame
    
    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            dragOffset = Vector2.new(bubbleFrame.AbsolutePosition.X, bubbleFrame.AbsolutePosition.Y)
        end
    end)
    
    dragBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            Settings.MenuX = (dragOffset.X + (bubbleFrame.AbsoluteSize.X / 2)) / Camera.ViewportSize.X
            Settings.MenuY = (dragOffset.Y + (bubbleFrame.AbsoluteSize.Y / 2)) / Camera.ViewportSize.Y
        end
    end)
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0, bubbleFrame.AbsolutePosition.X + 64, 0, bubbleFrame.AbsolutePosition.Y - 70)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = GetTheme().primary
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = true
    mainFrame.Parent = menuGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame
    
    local glass = Instance.new("Frame")
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.95
    glass.BorderSizePixel = 0
    glass.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = GetTheme().primary
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✦ AI NGU VL v13.1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        isMenuOpen = false
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    end)
    
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(1, 0, 0, 40)
    tabs.Position = UDim2.new(0, 0, 0, 52)
    tabs.BackgroundTransparency = 1
    tabs.Parent = mainFrame
    
    local function CreateTab(name, x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 32)
        btn.Position = UDim2.new(0, x, 0, 4)
        btn.BackgroundColor3 = GetTheme().primary
        btn.BackgroundTransparency = 0.85
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = currentTab == name and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 160, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = tabs
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        if currentTab == name then
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        btn.MouseButton1Click:Connect(function()
            currentTab = name
            for _, child in pairs(tabs:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = 0.85
                    child.TextColor3 = Color3.fromRGB(150, 160, 180)
                end
            end
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            for _, child in pairs(content:GetChildren()) do
                if child:IsA("Frame") then
                    child.Visible = (child.Name == name)
                end
            end
        end)
        
        return btn
    end
    
    CreateTab("MAIN", 10)
    CreateTab("AIM", 105)
    CreateTab("ESP", 200)
    CreateTab("THEME", 295)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 300)
    content.Position = UDim2.new(0, 0, 0, 94)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = mainFrame
    
    local mainTab = Instance.new("Frame")
    mainTab.Name = "MAIN"
    mainTab.Size = UDim2.new(1, 0, 1, 0)
    mainTab.BackgroundTransparency = 1
    mainTab.Visible = true
    mainTab.Parent = content
    
    local function CreateBigCard(parent, x, y, label, settingKey, icon, color)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 140, 0, 65)
        card.Position = UDim2.new(0, x, 0, y)
        card.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        card.BackgroundTransparency = 0.5
        card.BorderSizePixel = 1
        card.BorderColor3 = Settings[settingKey] and color or Color3.fromRGB(40, 40, 70)
        card.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = card
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 30, 0, 30)
        iconLabel.Position = UDim2.new(0, 8, 0, 5)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.TextSize = 24
        iconLabel.Parent = card
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 90, 0, 20)
        labelText.Position = UDim2.new(0, 42, 0, 8)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(180, 190, 210)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 13
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = card
        
        local statusText = Instance.new("TextLabel")
        statusText.Size = UDim2.new(0, 90, 0, 16)
        statusText.Position = UDim2.new(0, 42, 0, 30)
        statusText.BackgroundTransparency = 1
        statusText.Text = Settings[settingKey] and "● ON" or "○ OFF"
        statusText.TextColor3 = Settings[settingKey] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        statusText.Font = Enum.Font.GothamBold
        statusText.TextSize = 14
        statusText.TextXAlignment = Enum.TextXAlignment.Left
        statusText.Parent = card
        
        card.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            statusText.Text = Settings[settingKey] and "● ON" or "○ OFF"
            statusText.TextColor3 = Settings[settingKey] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            card.BorderColor3 = Settings[settingKey] and color or Color3.fromRGB(40, 40, 70)
            if settingKey == "AimbotEnabled" then UpdateFOVCircle() end
        end)
        
        return card
    end
    
    CreateBigCard(mainTab, 10, 10, "AIMBOT", "AimbotEnabled", "🎯", GetTheme().primary)
    CreateBigCard(mainTab, 160, 10, "ESP", "ESPEnabled", "👁", GetTheme().secondary)
    CreateBigCard(mainTab, 10, 85, "TRIGGER", "TriggerBot", "🔫", Color3.fromRGB(255, 200, 0))
    CreateBigCard(mainTab, 160, 85, "SILENT", "SilentAim", "🤫", Color3.fromRGB(200, 100, 255))
    
    local status = Instance.new("Frame")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 250)
    status.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
    status.BackgroundTransparency = 0.5
    status.BorderSizePixel = 0
    status.Parent = mainTab
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = status
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "◆ SYSTEM ONLINE ◆"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.Parent = status
    
    local aimTab = Instance.new("Frame")
    aimTab.Name = "AIM"
    aimTab.Size = UDim2.new(1, 0, 1, 0)
    aimTab.BackgroundTransparency = 1
    aimTab.Visible = false
    aimTab.Parent = content
    
    local function CreateModernSlider(parent, x, y, width, label, settingKey, minVal, maxVal, formatStr, icon)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 55)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        container.BackgroundTransparency = 0.5
        container.BorderSizePixel = 1
        container.BorderColor3 = Color3.fromRGB(40, 40, 70)
        container.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = container
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.Position = UDim2.new(0, 10, 0, 8)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = GetTheme().primary
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.TextSize = 16
        iconLabel.Parent = container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.5, 0, 0, 18)
        labelText.Position = UDim2.new(0, 35, 0, 6)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(170, 180, 200)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0.4, 0, 0, 18)
        valueDisplay.Position = UDim2.new(0.6, 0, 0, 6)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = string.format(formatStr, Settings[settingKey])
        valueDisplay.TextColor3 = GetTheme().primary
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextSize = 13
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valueDisplay.Parent = container
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0.85, 0, 0, 4)
        track.Position = UDim2.new(0, 10, 0, 36)
        track.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        track.BorderSizePixel = 0
        track.Parent = container
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 2)
        trackCorner.Parent = track
        
        local fill = Instance.new("Frame")
        local fillWidth = (Settings[settingKey] - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(fillWidth, 0, 1, 0)
        fill.BackgroundColor3 = GetTheme().primary
        fill.BackgroundTransparency = 0.2
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill
        
        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 16, 0, 16)
        handle.Position = UDim2.new(fillWidth, -8, 0, -6)
        handle.BackgroundColor3 = GetTheme().primary
        handle.BorderSizePixel = 2
        handle.BorderColor3 = Color3.fromRGB(100, 220, 255)
        handle.Parent = track
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0)
        handleCorner.Parent = handle
        
        local dragging = false
        local function UpdateSlider(input)
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = minVal + (maxVal - minVal) * relX
            if settingKey == "FOV" then
                value = math.round(value / 5) * 5
                value = math.clamp(value, minVal, maxVal)
            else
                value = math.round(value * 10) / 10
                value = math.clamp(value, minVal, maxVal)
            end
            Settings[settingKey] = value
            local newFill = (value - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(newFill, 0, 1, 0)
            handle.Position = UDim2.new(newFill, -8, 0, -6)
            valueDisplay.Text = string.format(formatStr, value)
            if settingKey == "FOV" then UpdateFOVCircle() end
        end
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return container
    end
    
    CreateModernSlider(aimTab, 10, 10, 290, "FOV", "FOV", 10, 360, "%.0f°", "◉")
    CreateModernSlider(aimTab, 10, 70, 290, "SMOOTHNESS", "Smoothness", 0.05, 0.9, "%.2f", "◈")
    CreateModernSlider(aimTab, 10, 130, 290, "TRIGGER DELAY", "TriggerDelay", 0.05, 0.5, "%.2fs", "⏱")
    CreateModernSlider(aimTab, 10, 190, 290, "PREDICTION", "PredictionAmount", 0, 0.5, "%.2f", "➤")
    
    local function CreateDropdown(parent, x, y, width, label, settingKey, options, icon)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 55)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        container.BackgroundTransparency = 0.5
        container.BorderSizePixel = 1
        container.BorderColor3 = Color3.fromRGB(40, 40, 70)
        container.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = container
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.Position = UDim2.new(0, 10, 0, 8)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = GetTheme().primary
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.TextSize = 16
        iconLabel.Parent = container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.5, 0, 0, 18)
        labelText.Position = UDim2.new(0, 35, 0, 6)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(170, 180, 200)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 26)
        btn.Position = UDim2.new(0, 10, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(50, 50, 80)
        btn.Text = Settings[settingKey]
        btn.TextColor3 = Color3.fromRGB(200, 210, 230)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local dropdownOpen = false
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0.8, 0, 0, #options * 26)
        dropdownFrame.Position = UDim2.new(0, 10, 0, 52)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        dropdownFrame.BackgroundTransparency = 0.05
        dropdownFrame.BorderSizePixel = 1
        dropdownFrame.BorderColor3 = Color3.fromRGB(50, 50, 80)
        dropdownFrame.Visible = false
        dropdownFrame.ClipsDescendants = true
        dropdownFrame.Parent = container
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 6)
        dropCorner.Parent = dropdownFrame
        
        for i, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 26)
            optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
            optBtn.BackgroundTransparency = 0.5
            optBtn.BorderSizePixel = 0
            optBtn.Text = opt
            optBtn.TextColor3 = Color3.fromRGB(180, 190, 210)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.Parent = dropdownFrame
            optBtn.MouseButton1Click:Connect(function()
                Settings[settingKey] = opt
                btn.Text = opt
                dropdownFrame.Visible = false
                dropdownOpen = false
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            dropdownFrame.Visible = dropdownOpen
        end)
        
        return container
    end
    
    CreateDropdown(aimTab, 10, 250, 290, "AIM PART", "AimPart", {"Head", "HumanoidRootPart", "Random"}, "◆")
    
    local espTab = Instance.new("Frame")
    espTab.Name = "ESP"
    espTab.Size = UDim2.new(1, 0, 1, 0)
    espTab.BackgroundTransparency = 1
    espTab.Visible = false
    espTab.Parent = content
    
    local function CreateCheckbox(parent, x, y, label, settingKey, icon)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 135, 0, 35)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
        container.BackgroundTransparency = 0.5
        container.BorderSizePixel = 1
        container.BorderColor3 = Settings[settingKey] and GetTheme().primary or Color3.fromRGB(40, 40, 70)
        container.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = container
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.Position = UDim2.new(0, 8, 0, 7)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = GetTheme().primary
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.TextSize = 14
        iconLabel.Parent = container
        
        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 75, 0, 20)
        labelText.Position = UDim2.new(0, 32, 0, 7)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(180, 190, 210)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local mark = Instance.new("TextLabel")
        mark.Size = UDim2.new(0, 20, 0, 20)
        mark.Position = UDim2.new(1, -25, 0, 7)
        mark.BackgroundTransparency = 1
        mark.Text = Settings[settingKey] and "✓" or "✗"
        mark.TextColor3 = Settings[settingKey] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        mark.Font = Enum.Font.GothamBold
        mark.TextSize = 14
        mark.Parent = container
        
        container.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            mark.Text = Settings[settingKey] and "✓" or "✗"
            mark.TextColor3 = Settings[settingKey] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            container.BorderColor3 = Settings[settingKey] and GetTheme().primary or Color3.fromRGB(40, 40, 70)
        end)
        
        return container
    end
    
    CreateCheckbox(espTab, 10, 10, "Box ESP", "BoxESP", "📦")
    CreateCheckbox(espTab, 155, 10, "Skeleton", "SkeletonESP", "🦴")
    CreateCheckbox(espTab, 10, 55, "Name & Dist", "NameESP", "📝")
    CreateCheckbox(espTab, 155, 55, "Health Bar", "HealthBar", "❤️")
    CreateCheckbox(espTab, 10, 100, "Tracer", "Tracer", "〰️")
    CreateCheckbox(espTab, 155, 100, "Team Check", "TeamCheck", "👥")
    CreateCheckbox(espTab, 10, 145, "Visible Check", "VisibleCheck", "👁")
    CreateCheckbox(espTab, 155, 145, "Distance Check", "DistanceCheck", "📏")
    
    CreateModernSlider(espTab, 10, 195, 280, "MAX DISTANCE", "MaxDistance", 50, 500, "%.0fm", "📏")
    
    local themeTab = Instance.new("Frame")
    themeTab.Name = "THEME"
    themeTab.Size = UDim2.new(1, 0, 1, 0)
    themeTab.BackgroundTransparency = 1
    themeTab.Visible = false
    themeTab.Parent = content
    
    local function CreateColorButton(parent, x, y, color, name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 35)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Themes[color].primary
        btn.BackgroundTransparency = Settings.ThemeColor == color and 0.2 or 0.5
        btn.BorderSizePixel = 2
        btn.BorderColor3 = Settings.ThemeColor == color and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 70)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Settings.ThemeColor = color
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = 0.5
                    child.BorderColor3 = Color3.fromRGB(40, 40, 70)
                end
            end
            btn.BackgroundTransparency = 0.2
            btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
            UpdateFOVCircle()
        end)
        
        return btn
    end
    
    CreateColorButton(themeTab, 10, 10, "Cyan", "CYAN")
    CreateColorButton(themeTab, 100, 10, "Red", "RED")
    CreateColorButton(themeTab, 190, 10, "Purple", "PURPLE")
    CreateColorButton(themeTab, 10, 60, "Gold", "GOLD")
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 40)
    info.Position = UDim2.new(0, 10, 0, 140)
    info.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
    info.BackgroundTransparency = 0.5
    info.BorderSizePixel = 1
    info.BorderColor3 = GetTheme().primary
    info.Text = "⚡ v13.1 ULTIMATE EDITION\n🎯 Aimbot • ESP • Trigger Bot"
    info.TextColor3 = Color3.fromRGB(200, 210, 230)
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextScaled = true
    info.Parent = themeTab
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = info
    
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 420),
        BackgroundTransparency = 0.08
    })
    tween:Play()
    
    bubbleFrame.Changed:Connect(function(prop)
        if prop == "AbsolutePosition" and mainFrame then
            mainFrame.Position = UDim2.new(0, bubbleFrame.AbsolutePosition.X + 64, 0, bubbleFrame.AbsolutePosition.Y - 70)
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            local aimPos = target.AimPart.Position
            if Settings.Prediction then
                aimPos = GetPredictedPosition(aimPos)
            end
            
            local currentPos = Camera.CFrame.Position
            local direction = (aimPos - currentPos).unit
            local newCFrame = CFrame.lookAt(currentPos, currentPos + direction)
            
            if Settings.SilentAim then
                local hitPos = currentPos + direction * 1000
                Mouse.Hit = CFrame.new(hitPos)
            else
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Smoothness)
            end
        end
    end
    
    UpdateFOVCircle()
    CreateESP()
    TriggerBot()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.F1 then
            Settings.AimbotEnabled = not Settings.AimbotEnabled
            UpdateFOVCircle()
        elseif key == Enum.KeyCode.F2 then
            Settings.ESPEnabled = not Settings.ESPEnabled
        elseif key == Enum.KeyCode.F3 then
            Settings.TriggerBot = not Settings.TriggerBot
        elseif key == Enum.KeyCode.Insert then
            if isMenuOpen then
                isMenuOpen = false
                local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                })
                tween:Play()
                tween.Completed:Connect(function()
                    if mainFrame then mainFrame.Visible = false end
                end)
            else
                isMenuOpen = true
                if mainFrame then
                    mainFrame.Visible = true
                    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 340, 0, 420),
                        BackgroundTransparency = 0.08
                    })
                    tween:Play()
                end
            end
        end
    end
end)

CreateFOVCircle()
CreateModernUI()

print("AI NGU VL v13.1 ULTIMATE EDITION LOADED")