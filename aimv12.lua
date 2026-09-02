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
    ShowFOVCircle = true
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
    FOVCircle.NumSides = 64
    FOVCircle.Transparency = 0.6
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

local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotMenu"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 360)
    MainFrame.Position = UDim2.new(0, 20, 0, 20)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame

    local function CreateGlowLine(parent, yPos, color)
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 2)
        line.Position = UDim2.new(0, 0, 0, yPos)
        line.BackgroundColor3 = color
        line.BackgroundTransparency = 0.3
        line.Parent = parent
        return line
    end

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(0, 40, 60)
    Title.BackgroundTransparency = 0.5
    Title.Text = "✦ AI NGU VL ✦"
    Title.TextColor3 = Color3.fromRGB(0, 220, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextScaled = false
    Title.Parent = MainFrame

    local TitleGlow = Instance.new("Frame")
    TitleGlow.Size = UDim2.new(1, 0, 0, 2)
    TitleGlow.Position = UDim2.new(0, 0, 0, 40)
    TitleGlow.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    TitleGlow.BackgroundTransparency = 0.2
    TitleGlow.Parent = MainFrame

    local function CreateToggleButton(parent, x, y, width, label, settingKey, colorOn)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 0, 32)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = label .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        local status = false
        btn.MouseButton1Click:Connect(function()
            status = not status
            Settings[settingKey] = status
            btn.Text = label .. ": " .. (status and "ON" or "OFF")
            btn.BackgroundColor3 = status and colorOn or Color3.fromRGB(30, 30, 45)
            btn.BorderColor3 = status and colorOn or Color3.fromRGB(60, 60, 80)
            if settingKey == "AimbotEnabled" then
                UpdateFOVCircle()
            end
        end)
        return btn
    end

    CreateToggleButton(MainFrame, 10, 48, 145, "AIMBOT", "AimbotEnabled", Color3.fromRGB(0, 180, 100))
    CreateToggleButton(MainFrame, 165, 48, 145, "ESP", "ESPEnabled", Color3.fromRGB(0, 150, 255))

    local function CreateSlider(parent, x, y, width, label, settingKey, minVal, maxVal, formatStr)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 50)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 18)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label .. ": " .. string.format(formatStr, Settings[settingKey])
        labelText.TextColor3 = Color3.fromRGB(180, 190, 210)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0, 50, 0, 18)
        valueDisplay.Position = UDim2.new(1, -50, 0, 0)
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
        track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
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
        handle.Size = UDim2.new(0, 14, 0, 14)
        handle.Position = UDim2.new(fillWidth, -7, 0, -5)
        handle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        handle.BorderSizePixel = 1
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
            handle.Position = UDim2.new(newFill, -7, 0, -5)
            labelText.Text = label .. ": " .. string.format(formatStr, value)
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

    CreateSlider(MainFrame, 10, 95, 300, "FOV", "FOV", 10, 360, "%.0f°")
    CreateSlider(MainFrame, 10, 155, 300, "SMOOTH", "Smoothness", 0.05, 0.9, "%.2f")

    local function CreateDropdown(parent, x, y, width, label, settingKey, options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, width, 0, 50)
        container.Position = UDim2.new(0, x, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local labelText = Instance.new("TextLabel")
        labelText.Size = UDim2.new(1, 0, 0, 18)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(180, 190, 210)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.Position = UDim2.new(0, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = Settings[settingKey]
        btn.TextColor3 = Color3.fromRGB(200, 210, 230)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = container

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        local dropdownOpen = false
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 26)
        dropdownFrame.Position = UDim2.new(0, 0, 0, 46)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        dropdownFrame.BackgroundTransparency = 0.05
        dropdownFrame.BorderSizePixel = 1
        dropdownFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
        dropdownFrame.Visible = false
        dropdownFrame.ClipsDescendants = true
        dropdownFrame.Parent = container

        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 4)
        dropCorner.Parent = dropdownFrame

        for i, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 26)
            optBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
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

    CreateDropdown(MainFrame, 10, 215, 300, "AIM PART", "AimPart", {"Head", "HumanoidRootPart", "Random"})

    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Size = UDim2.new(0, 300, 0, 40)
    CheckboxFrame.Position = UDim2.new(0, 10, 0, 275)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.Parent = MainFrame

    local function CreateCheckbox(parent, x, label, settingKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 140, 0, 20)
        container.Position = UDim2.new(0, x, 0, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local checkBtn = Instance.new("TextButton")
        checkBtn.Size = UDim2.new(0, 16, 0, 16)
        checkBtn.Position = UDim2.new(0, 0, 0, 2)
        checkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        checkBtn.BorderSizePixel = 1
        checkBtn.BorderColor3 = Color3.fromRGB(60, 60, 80)
        checkBtn.Text = ""
        checkBtn.Parent = container

        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 3)
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
        labelText.Size = UDim2.new(0, 110, 0, 20)
        labelText.Position = UDim2.new(0, 22, 0, 0)
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
            checkBtn.BorderColor3 = Settings[settingKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(60, 60, 80)
        end)

        return container
    end

    CreateCheckbox(CheckboxFrame, 0, "Team Check", "TeamCheck")
    CreateCheckbox(CheckboxFrame, 150, "Visible Check", "VisibleCheck")

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -22)
    Footer.BackgroundTransparency = 1
    Footer.Text = "♦ FOV Circle ON ♦"
    Footer.TextColor3 = Color3.fromRGB(0, 180, 220)
    Footer.Font = Enum.Font.Gotham
    Footer.TextSize = 10
    Footer.TextScaled = false
    Footer.Parent = MainFrame
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
pcall(CreateMenu)
print("AI NGU VL - Aimbot & ESP Loaded")