local Library = {}
local Settings = {
    Aimbot = {
        Enabled = false,
        Rage = false,
        Legit = false,
        Silent = false,
        Smooth = true,
        Triggerbot = false,
        FOV = 120,
        Smoothness = 5,
        Target = "Closest",
        Bone = "Head"
    },
    ESP = {
        Box2D = false,
        Box3D = false,
        Skeleton = false,
        Line2D = false,
        Glow = false,
        Chams = false,
        Health = false,
        Distance = false,
        Name = false,
        Weapon = false,
        BarrelLine = false
    },
    World = {
        Items = false,
        Vehicles = false,
        Radar = false,
        Grenades = false
    },
    Misc = {
        NoShadows = false,
        RemoveDecals = false,
        RemoveParticles = false,
        RemoveEffects = false,
        LowGraphics = false,
        ClayMode = false
    }
}

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local function IsEnemy(character)
    if not character or not character.Parent then return false end
    local enemy = game:GetService("Players"):GetPlayerFromCharacter(character)
    if not enemy then return false end
    return enemy ~= Player and enemy.Team ~= Player.Team
end

local function GetClosestPlayer()
    local players = game:GetService("Players"):GetPlayers()
    local closest, minDist = nil, math.huge
    for _, p in ipairs(players) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = p
            end
        end
    end
    return closest
end

local function GetTarget()
    local players = game:GetService("Players"):GetPlayers()
    local targets = {}
    for _, p in ipairs(players) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if dist <= Settings.Aimbot.FOV then
                table.insert(targets, {Player = p, Distance = dist, Health = p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health or 100})
            end
        end
    end
    if #targets == 0 then return nil end
    if Settings.Aimbot.Target == "Closest" then
        table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    else
        table.sort(targets, function(a, b) return a.Health < b.Health end)
    end
    return targets[1].Player
end

local function GetBonePosition(character, bone)
    if not character then return nil end
    if bone == "Head" and character:FindFirstChild("Head") then
        return character.Head.Position
    elseif bone == "UpperTorso" and character:FindFirstChild("UpperTorso") then
        return character.UpperTorso.Position
    elseif bone == "HumanoidRootPart" and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    return nil
end

local function AimAt(targetPos)
    if not targetPos then return end
    local currentPos = Camera.CFrame.Position
    local direction = (targetPos - currentPos).Unit
    local targetCFrame = CFrame.lookAt(currentPos, currentPos + direction)
    if Settings.Aimbot.Smooth then
        local smooth = Settings.Aimbot.Smoothness / 20
        local lerpedCFrame = Camera.CFrame:Lerp(targetCFrame, smooth)
        Camera.CFrame = lerpedCFrame
    else
        Camera.CFrame = targetCFrame
    end
end

local function IsInFOV(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    if not onScreen then return false end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return dist <= Settings.Aimbot.FOV
end

local function Triggerbot()
    if not Settings.Aimbot.Triggerbot then return end
    local target = GetTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local bonePos = GetBonePosition(target.Character, Settings.Aimbot.Bone)
        if bonePos and IsInFOV(bonePos) then
            Mouse1Click()
        end
    end
end

local function DrawCircle()
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 64
    circle.Radius = Settings.Aimbot.FOV
    circle.Transparency = 1
    circle.Color = Color3.new(1, 0, 0)
    circle.Visible = false
    return circle
end

local ESPObjects = {}
local function CreateESPObject(character)
    if not character then return end
    local esp = {}
    esp.Box2D = Drawing.new("Square")
    esp.Box2D.Thickness = 2
    esp.Box2D.Transparency = 1
    esp.Box2D.Visible = false
    esp.Box2D.Color = IsEnemy(character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    
    esp.Box3D = Drawing.new("Quad")
    esp.Box3D.Thickness = 2
    esp.Box3D.Transparency = 1
    esp.Box3D.Visible = false
    esp.Box3D.Color = IsEnemy(character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    
    esp.Line2D = Drawing.new("Line")
    esp.Line2D.Thickness = 2
    esp.Line2D.Transparency = 1
    esp.Line2D.Visible = false
    esp.Line2D.Color = IsEnemy(character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    
    esp.Skeleton = {}
    for i = 1, 10 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        line.Color = IsEnemy(character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
        table.insert(esp.Skeleton, line)
    end
    
    esp.Health = Drawing.new("Square")
    esp.Health.Thickness = 2
    esp.Health.Transparency = 1
    esp.Health.Visible = false
    esp.Health.Color = Color3.new(0, 1, 0)
    esp.Health.Filled = true
    
    esp.Distance = Drawing.new("Text")
    esp.Distance.Size = 14
    esp.Distance.Center = true
    esp.Distance.Transparency = 1
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Font = 2
    
    esp.Name = Drawing.new("Text")
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Transparency = 1
    esp.Name.Visible = false
    esp.Name.Color = IsEnemy(character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    esp.Name.Font = 2
    
    esp.Weapon = Drawing.new("Text")
    esp.Weapon.Size = 14
    esp.Weapon.Center = true
    esp.Weapon.Transparency = 1
    esp.Weapon.Visible = false
    esp.Weapon.Color = Color3.new(1, 1, 1)
    esp.Weapon.Font = 2
    
    ESPObjects[character] = esp
end

local function UpdateESP()
    local characters = {}
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if dist <= 500 then
                table.insert(characters, p.Character)
            end
        end
    end
    
    for char, esp in pairs(ESPObjects) do
        if not char or not char.Parent then
            for _, obj in pairs(esp) do
                if type(obj) == "table" then
                    for _, line in ipairs(obj) do
                        line:Remove()
                    end
                else
                    obj:Remove()
                end
            end
            ESPObjects[char] = nil
        end
    end
    
    for _, char in ipairs(characters) do
        if not ESPObjects[char] then
            CreateESPObject(char)
        end
        local esp = ESPObjects[char]
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if root and humanoid and root.Position and Camera then
            local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
            if onScreen then
                local size = 100 / (root.Position - Camera.CFrame.Position).Magnitude * 50
                local yPos = screenPos.Y
                
                if Settings.ESP.Box2D then
                    esp.Box2D.Visible = true
                    esp.Box2D.Size = Vector2.new(size, size * 1.5)
                    esp.Box2D.Position = Vector2.new(screenPos.X - size/2, yPos - size * 1.5)
                    esp.Box2D.Color = IsEnemy(char) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
                else
                    esp.Box2D.Visible = false
                end
                
                if Settings.ESP.Health then
                    esp.Health.Visible = true
                    esp.Health.Size = Vector2.new(4, size * 1.5)
                    esp.Health.Position = Vector2.new(screenPos.X - size/2 - 6, yPos - size * 1.5)
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    esp.Health.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                else
                    esp.Health.Visible = false
                end
                
                if Settings.ESP.Distance then
                    esp.Distance.Visible = true
                    esp.Distance.Position = Vector2.new(screenPos.X, yPos + size/2 + 15)
                    esp.Distance.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. "m"
                else
                    esp.Distance.Visible = false
                end
                
                if Settings.ESP.Name then
                    esp.Name.Visible = true
                    esp.Name.Position = Vector2.new(screenPos.X, yPos - size * 1.5 - 20)
                    local player = game:GetService("Players"):GetPlayerFromCharacter(char)
                    if player then
                        esp.Name.Text = player.Name
                    end
                    esp.Name.Color = IsEnemy(char) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
                else
                    esp.Name.Visible = false
                end
                
                if Settings.ESP.Line2D then
                    esp.Line2D.Visible = true
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    esp.Line2D.From = center
                    esp.Line2D.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Line2D.Color = IsEnemy(char) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
                else
                    esp.Line2D.Visible = false
                end
            else
                esp.Box2D.Visible = false
                esp.Box3D.Visible = false
                esp.Health.Visible = false
                esp.Distance.Visible = false
                esp.Name.Visible = false
                esp.Weapon.Visible = false
                esp.Line2D.Visible = false
                for _, line in ipairs(esp.Skeleton) do
                    line.Visible = false
                end
            end
        end
    end
end

local function CreateRadar()
    local radar = Drawing.new("Square")
    radar.Thickness = 2
    radar.Transparency = 1
    radar.Filled = true
    radar.Size = Vector2.new(150, 150)
    radar.Position = Vector2.new(Camera.ViewportSize.X - 170, Camera.ViewportSize.Y - 170)
    radar.Color = Color3.new(0, 0, 0)
    radar.Visible = false
    return radar
end

local function UpdateRadar()
    if not Settings.World.Radar then return end
    local radar = CreateRadar()
    radar.Visible = true
    
    local center = radar.Position + radar.Size / 2
    local scale = 50
    
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local relPos = root.Position - Player.Character.HumanoidRootPart.Position
            local rot = Camera.CFrame - Camera.CFrame.Position
            local localPos = rot:PointToObjectSpace(relPos)
            local screenPos = center + Vector2.new(localPos.X * scale, -localPos.Z * scale)
            
            local dot = Drawing.new("Circle")
            dot.Radius = 4
            dot.Filled = true
            dot.Color = IsEnemy(p.Character) and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
            dot.Transparency = 1
            dot.Position = screenPos
            dot.Visible = true
            
            game:GetService("Debris"):AddItem(dot, 0.1)
        end
    end
end

local function FixLag()
    if Settings.Misc.NoShadows then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Shadow = 0
            end
        end
    end
    
    if Settings.Misc.RemoveDecals then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
    
    if Settings.Misc.RemoveParticles then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
    end
    
    if Settings.Misc.RemoveEffects then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Explosion") or v:IsA("Sparkles") then
                v:Destroy()
            end
        end
    end
    
    if Settings.Misc.LowGraphics then
        game:GetService("Lighting").Brightness = 0
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Technology = "Legacy"
        settings().Rendering.QualityLevel = 1
    end
    
    if Settings.Misc.ClayMode then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.BrickColor = BrickColor.new("Medium stone grey")
            end
        end
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.Plastic
                        v.BrickColor = BrickColor.new("Medium stone grey")
                    end
                end
            end
        end
    end
end

local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HackGUI"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Hack Menu"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        wait(0.3)
        MainFrame.Visible = false
    end)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local Tabs = {}
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -80)
    Content.Position = UDim2.new(0, 0, 0, 80)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.Parent = MainFrame
    
    local function CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 85, 1, 0)
        btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = TabContainer
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.Visible = false
        content.Parent = Content
        
        btn.MouseButton1Click:Connect(function()
            for _, c in pairs(Content:GetChildren()) do
                if c:IsA("Frame") then
                    c.Visible = false
                end
            end
            content.Visible = true
            for _, b in pairs(TabContainer:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
                end
            end
            btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        end)
        
        return content
    end
    
    local function CreateToggle(parent, label, setting)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local labelObj = Instance.new("TextLabel")
        labelObj.Size = UDim2.new(0.7, 0, 1, 0)
        labelObj.BackgroundTransparency = 1
        labelObj.Text = label
        labelObj.TextColor3 = Color3.new(1, 1, 1)
        labelObj.TextSize = 14
        labelObj.Font = Enum.Font.Gotham
        labelObj.TextXAlignment = Enum.TextXAlignment.Left
        labelObj.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 25)
        btn.Position = UDim2.new(0.8, 0, 0.5, -12.5)
        btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = frame
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(1, -4, 1, -4)
        indicator.Position = UDim2.new(0, 2, 0, 2)
        indicator.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        indicator.BorderSizePixel = 0
        indicator.Parent = btn
        
        local function updateState()
            local path = setting
            local current = Settings
            for _, p in ipairs(path) do
                current = current[p]
            end
            indicator.BackgroundColor3 = current and Color3.new(0, 1, 0) or Color3.new(0.5, 0.5, 0.5)
        end
        updateState()
        
        btn.MouseButton1Click:Connect(function()
            local path = setting
            local current = Settings
            for i = 1, #path - 1 do
                current = current[path[i]]
            end
            current[path[#path]] = not current[path[#path]]
            updateState()
            pcall(function()
                game:GetService("HttpService"):JSONEncode(Settings)
            end)
        end)
        
        return frame
    end
    
    local function CreateSlider(parent, label, setting, min, max, step)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local labelObj = Instance.new("TextLabel")
        labelObj.Size = UDim2.new(0.5, 0, 0.5, 0)
        labelObj.BackgroundTransparency = 1
        labelObj.Text = label
        labelObj.TextColor3 = Color3.new(1, 1, 1)
        labelObj.TextSize = 14
        labelObj.Font = Enum.Font.Gotham
        labelObj.TextXAlignment = Enum.TextXAlignment.Left
        labelObj.Parent = frame
        
        local valueObj = Instance.new("TextLabel")
        valueObj.Size = UDim2.new(0.3, 0, 0.5, 0)
        valueObj.Position = UDim2.new(0.7, 0, 0, 0)
        valueObj.BackgroundTransparency = 1
        valueObj.Text = ""
        valueObj.TextColor3 = Color3.new(1, 1, 1)
        valueObj.TextSize = 14
        valueObj.Font = Enum.Font.Gotham
        valueObj.TextXAlignment = Enum.TextXAlignment.Right
        valueObj.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0.3, 0)
        slider.Position = UDim2.new(0, 0, 0.6, 0)
        slider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.new(0, 0.5, 1)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local function updateSlider()
            local path = setting
            local current = Settings
            for i = 1, #path - 1 do
                current = current[path[i]]
            end
            local val = current[path[#path]]
            local percent = (val - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueObj.Text = tostring(val)
        end
        updateSlider()
        
        local dragging = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        slider.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local percent = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * percent
                val = math.floor(val / step + 0.5) * step
                val = math.clamp(val, min, max)
                
                local path = setting
                local current = Settings
                for i = 1, #path - 1 do
                    current = current[path[i]]
                end
                current[path[#path]] = val
                updateSlider()
                pcall(function()
                    game:GetService("HttpService"):JSONEncode(Settings)
                end)
            end
        end)
        
        return frame
    end
    
    local function CreateDropdown(parent, label, setting, options)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local labelObj = Instance.new("TextLabel")
        labelObj.Size = UDim2.new(0.5, 0, 0.5, 0)
        labelObj.BackgroundTransparency = 1
        labelObj.Text = label
        labelObj.TextColor3 = Color3.new(1, 1, 1)
        labelObj.TextSize = 14
        labelObj.Font = Enum.Font.Gotham
        labelObj.TextXAlignment = Enum.TextXAlignment.Left
        labelObj.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0.4, 0)
        btn.Position = UDim2.new(0.6, 0, 0.5, -12)
        btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        btn.Text = ""
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = frame
        
        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(0.4, 0, 0, 0)
        dropdown.Position = UDim2.new(0.6, 0, 0.9, 0)
        dropdown.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        dropdown.BorderSizePixel = 0
        dropdown.ClipsDescendants = true
        dropdown.Parent = frame
        
        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, 0, 1, 0)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 2
        list.Parent = dropdown
        
        local function updateDropdown()
            local path = setting
            local current = Settings
            for i = 1, #path - 1 do
                current = current[path[i]]
            end
            btn.Text = current[path[#path]]
            
            for _, child in pairs(list:GetChildren()) do
                child:Destroy()
            end
            
            local y = 0
            for _, opt in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 30)
                item.Position = UDim2.new(0, 0, 0, y)
                item.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
                item.Text = opt
                item.TextColor3 = Color3.new(1, 1, 1)
                item.TextSize = 14
                item.Font = Enum.Font.Gotham
                item.BorderSizePixel = 0
                item.Parent = list
                item.MouseButton1Click:Connect(function()
                    local path = setting
                    local current = Settings
                    for i = 1, #path - 1 do
                        current = current[path[i]]
                    end
                    current[path[#path]] = opt
                    updateDropdown()
                    dropdown.Size = UDim2.new(0.4, 0, 0, 0)
                    pcall(function()
                        game:GetService("HttpService"):JSONEncode(Settings)
                    end)
                end)
                y = y + 30
            end
            list.CanvasSize = UDim2.new(0, 0, 0, y)
            dropdown.Size = UDim2.new(0.4, 0, 0, math.min(y, 150))
        end
        updateDropdown()
        
        btn.MouseButton1Click:Connect(function()
            dropdown.Size = dropdown.Size.Y.Offset == 0 and UDim2.new(0.4, 0, 0, 150) or UDim2.new(0.4, 0, 0, 0)
        end)
        
        return frame
    end
    
    local tabs = {
        Aimbot = CreateTab("Aimbot"),
        ESP = CreateTab("ESP"),
        World = CreateTab("World"),
        Misc = CreateTab("Misc")
    }
    
    -- Aimbot tab
    CreateToggle(tabs.Aimbot, "Enable Aimbot", {"Aimbot", "Enabled"})
    CreateToggle(tabs.Aimbot, "Rage Mode", {"Aimbot", "Rage"})
    CreateToggle(tabs.Aimbot, "Legit Mode", {"Aimbot", "Legit"})
    CreateToggle(tabs.Aimbot, "Silent Aim", {"Aimbot", "Silent"})
    CreateToggle(tabs.Aimbot, "Smooth Aim", {"Aimbot", "Smooth"})
    CreateToggle(tabs.Aimbot, "Triggerbot", {"Aimbot", "Triggerbot"})
    CreateSlider(tabs.Aimbot, "FOV", {"Aimbot", "FOV"}, 10, 360, 5)
    CreateSlider(tabs.Aimbot, "Smoothness", {"Aimbot", "Smoothness"}, 1, 20, 1)
    CreateDropdown(tabs.Aimbot, "Target", {"Aimbot", "Target"}, {"Closest", "LowestHealth"})
    CreateDropdown(tabs.Aimbot, "Bone", {"Aimbot", "Bone"}, {"Head", "UpperTorso", "HumanoidRootPart"})
    
    -- ESP tab
    CreateToggle(tabs.ESP, "Box 2D", {"ESP", "Box2D"})
    CreateToggle(tabs.ESP, "Box 3D", {"ESP", "Box3D"})
    CreateToggle(tabs.ESP, "Skeleton", {"ESP", "Skeleton"})
    CreateToggle(tabs.ESP, "Line 2D", {"ESP", "Line2D"})
    CreateToggle(tabs.ESP, "Glow", {"ESP", "Glow"})
    CreateToggle(tabs.ESP, "Chams", {"ESP", "Chams"})
    CreateToggle(tabs.ESP, "Health", {"ESP", "Health"})
    CreateToggle(tabs.ESP, "Distance", {"ESP", "Distance"})
    CreateToggle(tabs.ESP, "Name", {"ESP", "Name"})
    CreateToggle(tabs.ESP, "Weapon", {"ESP", "Weapon"})
    CreateToggle(tabs.ESP, "Barrel Line", {"ESP", "BarrelLine"})
    
    -- World tab
    CreateToggle(tabs.World, "Item ESP", {"World", "Items"})
    CreateToggle(tabs.World, "Vehicle ESP", {"World", "Vehicles"})
    CreateToggle(tabs.World, "Radar", {"World", "Radar"})
    CreateToggle(tabs.World, "Grenade ESP", {"World", "Grenades"})
    
    -- Misc tab
    CreateToggle(tabs.Misc, "No Shadows", {"Misc", "NoShadows"})
    CreateToggle(tabs.Misc, "Remove Decals", {"Misc", "RemoveDecals"})
    CreateToggle(tabs.Misc, "Remove Particles", {"Misc", "RemoveParticles"})
    CreateToggle(tabs.Misc, "Remove Effects", {"Misc", "RemoveEffects"})
    CreateToggle(tabs.Misc, "Low Graphics", {"Misc", "LowGraphics"})
    CreateToggle(tabs.Misc, "Clay Mode", {"Misc", "ClayMode"})
    
    -- Show first tab
    local firstBtn = TabContainer:GetChildren()[1]
    if firstBtn then
        firstBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        for _, c in pairs(Content:GetChildren()) do
            if c:IsA("Frame") then
                c.Visible = false
            end
        end
        local firstContent = Content:GetChildren()[1]
        if firstContent then
            firstContent.Visible = true
        end
    end
    
    -- Drag
    local dragging = false
    local dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return MainFrame
end

local function MainLoop()
    pcall(function()
        if Settings.Aimbot.Enabled and Settings.Aimbot.Rage then
            local target = GetTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local bonePos = GetBonePosition(target.Character, Settings.Aimbot.Bone)
                if bonePos then
                    AimAt(bonePos)
                    Mouse1Click()
                end
            end
        elseif Settings.Aimbot.Enabled and Settings.Aimbot.Legit then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService:IsTouchEnabled() then
                local target = GetTarget()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local bonePos = GetBonePosition(target.Character, Settings.Aimbot.Bone)
                    if bonePos then
                        AimAt(bonePos)
                    end
                end
            end
        end
        
        Triggerbot()
        UpdateESP()
        if Settings.World.Radar then
            UpdateRadar()
        end
        FixLag()
    end)
end

local function Start()
    local gui = CreateGUI()
    
    RunService.RenderStepped:Connect(function()
        pcall(MainLoop)
    end)
    
    game:GetService("HttpService"):JSONEncode(Settings)
    
    -- Cleanup
    spawn(function()
        while wait(60) do
            pcall(function()
                for char, esp in pairs(ESPObjects) do
                    if not char or not char.Parent then
                        for _, obj in pairs(esp) do
                            if type(obj) == "table" then
                                for _, line in ipairs(obj) do
                                    line:Remove()
                                end
                            else
                                obj:Remove()
                            end
                        end
                        ESPObjects[char] = nil
                    end
                end
                collectgarbage()
            end)
        end
    end)
end

pcall(Start)