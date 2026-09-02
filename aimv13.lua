local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    FOV = 150,
    Smoothness = 0.25,
    AimPart = "Head",
    ShowFOVCircle = true,
    MenuOpen = true
}

local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle = nil
    end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Settings.ShowFOVCircle
    FOVCircle.Radius = Settings.FOV / 1.5
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(0, 200, 255)
    FOVCircle.Filled = false
    FOVCircle.NumSides = 72
    FOVCircle.Transparency = 0.5
end

local function UpdateFOVCircle()
    if FOVCircle then
        local centerX = Camera.ViewportSize.X / 2
        local centerY = Camera.ViewportSize.Y / 2
        FOVCircle.Position = Vector2.new(centerX, centerY)
        FOVCircle.Radius = Settings.FOV / 1.5
        FOVCircle.Visible = Settings.ShowFOVCircle and Settings.AimbotEnabled
    end
end

local menuGui = nil
local bubbleFrame = nil
local isDragging = false
local dragStart = Vector2.new()
local dragOffset = Vector2.new()

local function CreateBubbleMenu()
    if menuGui then
        menuGui:Destroy()
        menuGui = nil
    end

    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "BubbleMenu"
    menuGui.Parent = LocalPlayer.PlayerGui
    menuGui.ResetOnSpawn = false
    menuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    bubbleFrame = Instance.new("Frame")
    bubbleFrame.Size = UDim2.new(0, 48, 0, 48)
    bubbleFrame.Position = UDim2.new(0.5, -24, 0.5, -24)
    bubbleFrame.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    bubbleFrame.BackgroundTransparency = 0.15
    bubbleFrame.BorderSizePixel = 2
    bubbleFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    bubbleFrame.ClipsDescendants = true
    bubbleFrame.Parent = menuGui

    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubbleFrame

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0.5, -10, 0.5, -10)
    glow.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    glow.BackgroundTransparency = 0.85
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
    icon.TextSize = 28
    icon.TextScaled = true
    icon.Parent = bubbleFrame

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(1, 0, 1, 0)
    expandBtn.BackgroundTransparency = 1
    expandBtn.Text = ""
    expandBtn.Parent = bubbleFrame
    expandBtn.MouseButton1Click:Connect(function()
        Settings.MenuOpen = not Settings.MenuOpen
        if Settings.MenuOpen then
            expandMenu()
        else
            collapseMenu()
        end
    end)

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
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = dragOffset.X + delta.X
            local newY = dragOffset.Y + delta.Y
            local viewport = Camera.ViewportSize
            newX = math.clamp(newX, 0, viewport.X - bubbleFrame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, viewport.Y - bubbleFrame.AbsoluteSize.Y)
            bubbleFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

local expandedMenu = nil
local function expandMenu()
    if expandedMenu then return end

    expandedMenu = Instance.new("Frame")
    expandedMenu.Size = UDim2.new(0, 340, 0, 420)
    expandedMenu.Position = UDim2.new(0, bubbleFrame.AbsolutePosition.X + 56, 0, bubbleFrame.AbsolutePosition.Y - 20)
    expandedMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    expandedMenu.BackgroundTransparency = 0.08
    expandedMenu.BorderSizePixel = 1
    expandedMenu.BorderColor3 = Color3.fromRGB(0, 200, 255)
    expandedMenu.ClipsDescendants = true
    expandedMenu.Visible = true
    expandedMenu.Parent = menuGui

    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 16)
    menuCorner.Parent = expandedMenu

    local menuGlow = Instance.new("Frame")
    menuGlow.Size = UDim2.new(1, 0, 1, 0)
    menuGlow.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    menuGlow.BackgroundTransparency = 0.9
    menuGlow.BorderSizePixel = 0
    menuGlow.Parent = expandedMenu

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 40, 70)
    titleBar.BackgroundTransparency = 0.4
    titleBar.BorderSizePixel = 0
    titleBar.Parent = expandedMenu

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 16, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ AI NGU VL ✦"
    titleText.TextColor3 = Color3.fromRGB(0, 220, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        Settings.MenuOpen = false
        collapseMenu()
    end)

    local function CreateToggleButton(parent, x, y, width, label, settingKey, colorOn)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 0, 34)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(50, 50, 80)
        btn.Text = label .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local status = Settings[settingKey]
        btn.Text = label .. ": " .. (status and "ON" or "OFF")
        btn.BackgroundColor3 = status and colorOn or Color3.fromRGB(25, 25, 45)
        btn.BorderColor3 = status and colorOn or Color3.fromRGB(50, 50, 80)

        btn.MouseButton1Click:Connect(function()
            status = not status
            Settings[settingKey] = status
            btn.Text = label .. ": " .. (status and "ON" or "OFF")
            btn.BackgroundColor3 = status and colorOn or Color3.fromRGB(25, 25, 45)
            btn.BorderColor3 = status and colorOn or Color3.fromRGB(50, 50, 80)
            if settingKey == "AimbotEnabled" then
                UpdateFOVCircle()
            end
        end)
        return btn
    end

    CreateToggleButton(expandedMenu, 14, 52, 152, "AIMBOT", "AimbotEnabled", Color3.fromRGB(0, 180, 100))
    CreateToggleButton(expandedMenu, 174, 52, 152, "ESP", "ESPEnabled", Color3.fromRGB(0, 150, 255))

    local function CreateSlider(parent, x, y, width, label, settingKey, minVal, maxVal, formatStr)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 52)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.6, 0, 0, 18)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(170, 180, 200)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0.4, 0, 0, 18)
        valueDisplay.Position = UDim2.new(0.6, 0, 0, 0)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = string.format(formatStr, Settings[settingKey])
        valueDisplay.TextColor3 = Color3.fromRGB(0, 200, 255)
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextSize = 13
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valueDisplay.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 4)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        track.BorderSizePixel = 0
        track.Parent = container

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 2)
        trackCorner.Parent = track

        local fill = Instance.new("Frame")
        local fillWidth = (Settings[settingKey] - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(fillWidth, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        fill.BackgroundTransparency = 0.3
        fill.BorderSizePixel = 0
        fill.Parent = track

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill

        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 16, 0, 16)
        handle.Position = UDim2.new(fillWidth, -8, 0, -6)
        handle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
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
            if settingKey == "FOV" then
                UpdateFOVCircle()
            end
        end

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input)
                local con
                con = UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                        UpdateSlider(i)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        con:Disconnect()
                    end
                end)
            end
        end)

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateSlider(input)
            end
        end)

        return container
    end

    CreateSlider(expandedMenu, 14, 96, 312, "FOV", "FOV", 10, 360, "%.0f°")
    CreateSlider(expandedMenu, 14, 156, 312, "SMOOTH", "Smoothness", 0.05, 0.9, "%.2f")

    local function CreateDropdown(parent, x, y, width, label, settingKey, options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 52)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0.6, 0, 0, 18)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(170, 180, 200)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.Position = UDim2.new(0, 0, 0, 22)
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
        dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 28)
        dropdownFrame.Position = UDim2.new(0, 0, 0, 50)
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
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 28)
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

    CreateDropdown(expandedMenu, 14, 218, 312, "AIM PART", "AimPart", {"Head", "HumanoidRootPart", "Random"})

    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Size = UDim2.new(0, 312, 0, 36)
    CheckboxFrame.Position = UDim2.new(0, 14, 0, 280)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.Parent = expandedMenu

    local function CreateCheckbox(parent, x, label, settingKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 145, 0, 24)
        container.Position = UDim2.new(0, x, 0, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local checkBtn = Instance.new("TextButton")
        checkBtn.Size = UDim2.new(0, 18, 0, 18)
        checkBtn.Position = UDim2.new(0, 0, 0, 3)
        checkBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        checkBtn.BorderSizePixel = 1
        checkBtn.BorderColor3 = Settings[settingKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(50, 50, 80)
        checkBtn.Text = ""
        checkBtn.Parent = container

        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 4)
        checkCorner.Parent = checkBtn

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.new(1, 0, 1, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "✓"
        checkMark.TextColor3 = Color3.fromRGB(0, 200, 255)
        checkMark.Font = Enum.Font.GothamBold
        checkMark.TextSize = 14
        checkMark.Visible = Settings[settingKey]
        checkMark.Parent = checkBtn

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(0, 120, 0, 24)
        labelText.Position = UDim2.new(0, 24, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(160, 170, 190)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        checkBtn.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            checkMark.Visible = Settings[settingKey]
            checkBtn.BorderColor3 = Settings[settingKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(50, 50, 80)
        end)

        return container
    end

    CreateCheckbox(CheckboxFrame, 0, "Team Check", "TeamCheck")
    CreateCheckbox(CheckboxFrame, 155, "Visible Check", "VisibleCheck")

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 1, -30)
    statusBar.BackgroundColor3 = Color3.fromRGB(0, 30, 50)
    statusBar.BackgroundTransparency = 0.5
    statusBar.BorderSizePixel = 0
    statusBar.Parent = expandedMenu

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 16)
    statusCorner.Parent = statusBar

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "● ONLINE ●"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 150)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 11
    statusText.Parent = statusBar
end

local function collapseMenu()
    if expandedMenu then
        expandedMenu:Destroy()
        expandedMenu = nil
    end
end

local function GetClosestPlayer()
    local closest = nil
    local closestAngle = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            local character = player.Character
            if not character or not character.PrimaryPart then
                continue
            end

            local aimPart = character:FindFirstChild(Settings.AimPart)
            if not aimPart then
                aimPart = character.PrimaryPart
            end

            if Settings.VisibleCheck then
                local ray = Ray.new(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).unit * 1000)
                local hit, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hit and hit:IsDescendantOf(player.Character) == false then
                    continue
                end
            end

            local vectorToTarget = (aimPart.Position - Camera.CFrame.Position).unit
            local angle = math.deg(math.acos(Camera.CFrame.LookVector:Dot(vectorToTarget)))
            
            if angle <= Settings.FOV and angle < closestAngle then
                closestAngle = angle
                closest = player
            end
        end
    end
    return closest
end

local espObjects = {}
local function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Remove then
            obj:Remove()
        end
    end
    espObjects = {}
end

local function CreateESP()
    ClearESP()
    if not Settings.ESPEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character.PrimaryPart then
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
                            local line = Drawing.new("Line")
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Color = Color3.fromRGB(0, 255, 100)
                            line.Thickness = 1.5
                            line.Visible = true
                            table.insert(espObjects, line)
                        end
                    end
                end

                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local line = Drawing.new("Line")
                        line.From = center
                        line.To = Vector2.new(headPos.X, headPos.Y)
                        line.Color = Color3.fromRGB(255, 50, 50)
                        line.Thickness = 1
                        line.Visible = true
                        table.insert(espObjects, line)
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestPlayer()
        if target then
            local character = target.Character
            if character and character.PrimaryPart then
                local aimPart = character:FindFirstChild(Settings.AimPart)
                if not aimPart then
                    aimPart = character.PrimaryPart
                end
                local targetPos = aimPart.Position
                local currentPos = Camera.CFrame.Position
                local direction = (targetPos - currentPos).unit
                local newCFrame = CFrame.lookAt(currentPos, currentPos + direction)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.Smoothness)
            end
        end
    end

    UpdateFOVCircle()
    CreateESP()
end)

CreateFOVCircle()
CreateBubbleMenu()
expandMenu()

print("AI NGU VL - Bubble Menu Loaded")