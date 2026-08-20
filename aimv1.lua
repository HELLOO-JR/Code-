local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local function UltraOptimize()
    settings().Rendering.QualityLevel = 1
    Workspace.StreamingEnabled = true
    Workspace.Streaming.PreferPbr = false
    Workspace.FogEnd = 100
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Legacy
    Lighting.Brightness = 0.5
    Lighting.Ambient = Color3.fromRGB(80,80,80)
    Workspace.DecalRemove = true
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") then 
            v.Enabled = false 
            v:Destroy()
        end
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
        if v:IsA("BasePart") and not v:IsA("Terrain") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end
end

local Settings = {
    RageAimbot = false,
    LegitAimbot = false,
    SilentAimbot = false,
    SmoothAimbot = false,
    Triggerbot = false,
    FOVAimbot = false,
    FixLag = false,
    FOVRadius = 250,
    TargetMode = "Closest",
    Bone = "Head",
    AimSmoothness = 0.3,
    ESPBox = false,
    ESPBox3D = false,
    ESPSkeleton = false,
    ESPLine = false,
    ESPGlow = false,
    ESPChams = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPName = false,
    ESPWeapon = false,
    ESPBarrel = false,
    ESPItem = false,
    ESPVehicle = false,
    ESPRadar = false,
    ESPGrenade = false
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "DeltaMenu"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0, 5, 0.5, -280)
MainFrame.Size = UDim2.new(0, 250, 0, 560)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
Title.Text = "DELTA MOBILE"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.BorderSizePixel = 0

local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Position = UDim2.new(0, 0, 0, 28)
TabBar.Size = UDim2.new(1, 0, 0, 26)
TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
TabBar.BorderSizePixel = 0

local TabButtons = {}

local function CreateTabButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new(position, 0, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Name = name
    TabButtons[name] = btn
    return btn
end

local TabAimbot = CreateTabButton("Aimbot", 0)
local TabESP = CreateTabButton("ESP", 0.25)
local TabWorld = CreateTabButton("World", 0.5)
local TabMisc = CreateTabButton("Misc", 0.75)

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 0, 0, 54)
ContentFrame.Size = UDim2.new(1, 0, 1, -54)
ContentFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
ContentFrame.BorderSizePixel = 0

local function ClearContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end
end

local function MakeToggle(parent, text, settingKey, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -8, 0, 24)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 30)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Position = UDim2.new(0.75, 0, 0.1, 0)
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 160, 50) or Color3.fromRGB(160, 30, 30)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0

    Settings[settingKey] = default
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 160, 50) or Color3.fromRGB(160, 30, 30)
        btn.Text = Settings[settingKey] and "ON" or "OFF"
        if settingKey == "FixLag" and Settings.FixLag then
            UltraOptimize()
        end
    end)
    return frame
end

local function MakeSlider(parent, text, settingKey, minVal, maxVal, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -8, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 30)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Text = text .. " (" .. tostring(default) .. ")"
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 10

    local slider = Instance.new("Frame")
    slider.Parent = frame
    slider.Position = UDim2.new(0, 0, 0.6, 0)
    slider.Size = UDim2.new(1, 0, 0, 10)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 50)

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0

    local drag = Instance.new("TextButton")
    drag.Parent = slider
    drag.Size = UDim2.new(0, 10, 1, 0)
    drag.Position = UDim2.new((default - minVal) / (maxVal - minVal), -5, 0, 0)
    drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    drag.Text = ""
    drag.BorderSizePixel = 0

    Settings[settingKey] = default
    local dragging = false
    drag.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = (Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            local val = math.round(minVal + pos * (maxVal - minVal))
            Settings[settingKey] = val
            fill.Size = UDim2.new(pos, 0, 1, 0)
            drag.Position = UDim2.new(pos, -5, 0, 0)
            label.Text = text .. " (" .. tostring(val) .. ")"
        end
    end)
    return frame
end

local function MakeDropdown(parent, text, settingKey, options, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -8, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 30)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 10

    local drop = Instance.new("TextButton")
    drop.Parent = frame
    drop.Position = UDim2.new(0.55, 0, 0.1, 0)
    drop.Size = UDim2.new(0.4, 0, 0.8, 0)
    drop.Text = default
    drop.TextColor3 = Color3.fromRGB(255,255,255)
    drop.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    drop.Font = Enum.Font.GothamBold
    drop.TextSize = 10
    drop.BorderSizePixel = 0

    local currentIdx = 1
    for i, v in ipairs(options) do if v == default then currentIdx = i break end end
    Settings[settingKey] = default

    drop.MouseButton1Click:Connect(function()
        currentIdx = currentIdx % #options + 1
        local chosen = options[currentIdx]
        Settings[settingKey] = chosen
        drop.Text = chosen
    end)
    return frame
end

local function AddCategory(parent, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = UDim2.new(1, -8, 0, 18)
    label.Text = "--- " .. text .. " ---"
    label.TextColor3 = Color3.fromRGB(0, 200, 255)
    label.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Center
    return label
end

local function BuildAimbotTab()
    ClearContent()
    local list = Instance.new("UIListLayout")
    list.Parent = ContentFrame
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)

    AddCategory(ContentFrame, "AIMBOT")
    MakeToggle(ContentFrame, "Rage Aimbot", "RageAimbot", false)
    MakeToggle(ContentFrame, "Legit Aimbot", "LegitAimbot", false)
    MakeToggle(ContentFrame, "Silent Aimbot", "SilentAimbot", false)
    MakeToggle(ContentFrame, "Smooth Aimbot", "SmoothAimbot", false)
    MakeToggle(ContentFrame, "Triggerbot", "Triggerbot", false)
    MakeToggle(ContentFrame, "FOV Circle", "FOVAimbot", false)
    MakeSlider(ContentFrame, "FOV Radius", "FOVRadius", 10, 360, 250)
    MakeSlider(ContentFrame, "Smoothness", "AimSmoothness", 1, 20, 5)
    MakeDropdown(ContentFrame, "Target", "TargetMode", {"Closest", "LowestHealth"}, "Closest")
    MakeDropdown(ContentFrame, "Bone", "Bone", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head")
    MakeToggle(ContentFrame, "Fix Lag", "FixLag", false)
end

local function BuildESPTab()
    ClearContent()
    local list = Instance.new("UIListLayout")
    list.Parent = ContentFrame
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)

    AddCategory(ContentFrame, "PLAYER ESP")
    MakeToggle(ContentFrame, "Box 2D", "ESPBox", false)
    MakeToggle(ContentFrame, "Box 3D", "ESPBox3D", false)
    MakeToggle(ContentFrame, "Skeleton", "ESPSkeleton", false)
    MakeToggle(ContentFrame, "Line", "ESPLine", false)
    MakeToggle(ContentFrame, "Glow", "ESPGlow", false)
    MakeToggle(ContentFrame, "Chams", "ESPChams", false)
    MakeToggle(ContentFrame, "Health", "ESPHealth", false)
    MakeToggle(ContentFrame, "Distance", "ESPDistance", false)
    MakeToggle(ContentFrame, "Name", "ESPName", false)
    MakeToggle(ContentFrame, "Weapon", "ESPWeapon", false)
    MakeToggle(ContentFrame, "Barrel", "ESPBarrel", false)
end

local function BuildWorldTab()
    ClearContent()
    local list = Instance.new("UIListLayout")
    list.Parent = ContentFrame
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)

    AddCategory(ContentFrame, "WORLD ESP")
    MakeToggle(ContentFrame, "Item/Loot", "ESPItem", false)
    MakeToggle(ContentFrame, "Vehicle", "ESPVehicle", false)
    MakeToggle(ContentFrame, "Radar", "ESPRadar", false)
    MakeToggle(ContentFrame, "Grenade", "ESPGrenade", false)
end

local function BuildMiscTab()
    ClearContent()
    local list = Instance.new("UIListLayout")
    list.Parent = ContentFrame
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)

    AddCategory(ContentFrame, "MISC")
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ContentFrame
    lbl.Size = UDim2.new(1, -8, 0, 16)
    lbl.Text = "F1: Toggle Menu"
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local lbl2 = Instance.new("TextLabel")
    lbl2.Parent = ContentFrame
    lbl2.Size = UDim2.new(1, -8, 0, 16)
    lbl2.Text = "Touch/RMB: Legit Aimbot"
    lbl2.TextColor3 = Color3.fromRGB(200,200,200)
    lbl2.BackgroundTransparency = 1
    lbl2.Font = Enum.Font.Gotham
    lbl2.TextSize = 11
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
end

TabAimbot.MouseButton1Click:Connect(function()
    for _, btn in pairs(TabButtons) do btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40) end
    TabAimbot.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    BuildAimbotTab()
end)

TabESP.MouseButton1Click:Connect(function()
    for _, btn in pairs(TabButtons) do btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40) end
    TabESP.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    BuildESPTab()
end)

TabWorld.MouseButton1Click:Connect(function()
    for _, btn in pairs(TabButtons) do btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40) end
    TabWorld.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    BuildWorldTab()
end)

TabMisc.MouseButton1Click:Connect(function()
    for _, btn in pairs(TabButtons) do btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40) end
    TabMisc.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    BuildMiscTab()
end)

TabAimbot.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
BuildAimbotTab()

UltraOptimize()

local espObjects = {}
local function ClearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Remove() end)
    end
    espObjects = {}
end

local function CreateLine(p1, p2, color, thickness)
    local line = Drawing.new("Line")
    line.From = p1
    line.To = p2
    line.Color = color
    line.Thickness = thickness or 1
    line.Visible = true
    table.insert(espObjects, line)
    return line
end

local function CreateText(text, pos, color, size, center)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Position = pos
    txt.Color = color
    txt.Size = size or 11
    txt.Center = center or false
    txt.Outline = true
    txt.OutlineColor = Color3.fromRGB(0,0,0)
    txt.Visible = true
    table.insert(espObjects, txt)
    return txt
end

local function CreateBox(pos, size, color, thickness)
    local box = Drawing.new("Square")
    box.Position = pos
    box.Size = size
    box.Color = color
    box.Thickness = thickness or 1.5
    box.Filled = false
    box.Visible = true
    table.insert(espObjects, box)
    return box
end

local function CreateCircle(pos, radius, color, thickness, filled)
    local circle = Drawing.new("Circle")
    circle.Position = pos
    circle.Radius = radius
    circle.Color = color
    circle.Thickness = thickness or 1
    circle.Filled = filled or false
    circle.Visible = true
    table.insert(espObjects, circle)
    return circle
end

local function IsTeammate(player)
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function GetColor(player)
    if IsTeammate(player) then
        return Color3.fromRGB(0, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function GetColorBright(player)
    if IsTeammate(player) then
        return Color3.fromRGB(100, 255, 100)
    else
        return Color3.fromRGB(255, 50, 50)
    end
end

local function WorldToScreen(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    if onScreen then
        return Vector2.new(v.X, v.Y), v.Z
    end
    return nil, nil
end

local function GetHumanoidRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetJoints(char)
    local joints = {}
    local root = GetHumanoidRoot(char)
    if not root then return joints end
    local head = char:FindFirstChild("Head")
    local upper = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local lower = char:FindFirstChild("LowerTorso")
    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("LeftArm")
    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("RightArm")
    local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("LeftLeg")
    local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("RightLeg")
    if head and root then
        joints.Head = head.Position
        joints.Root = root.Position
        joints.Upper = upper and upper.Position or root.Position
        joints.Lower = lower and lower.Position or root.Position
        joints.LeftArm = leftArm and leftArm.Position or root.Position
        joints.RightArm = rightArm and rightArm.Position or root.Position
        joints.LeftLeg = leftLeg and leftLeg.Position or root.Position
        joints.RightLeg = rightLeg and rightLeg.Position or root.Position
    end
    return joints
end

local function DrawSkeleton(char)
    local joints = GetJoints(char)
    if not joints.Head then return end
    local h = WorldToScreen(joints.Head)
    local r = WorldToScreen(joints.Root)
    local u = WorldToScreen(joints.Upper)
    local l = WorldToScreen(joints.Lower)
    local la = WorldToScreen(joints.LeftArm)
    local ra = WorldToScreen(joints.RightArm)
    local ll = WorldToScreen(joints.LeftLeg)
    local rl = WorldToScreen(joints.RightLeg)
    if not (h and r and u and l and la and ra and ll and rl) then return end
    local col = GetColorBright(char.Parent)
    local col2 = Color3.fromRGB(255,255,255)
    CreateLine(h, u, col, 1)
    CreateLine(u, r, col2, 1)
    CreateLine(u, l, col2, 1)
    CreateLine(l, r, col2, 1)
    CreateLine(u, la, col, 1)
    CreateLine(u, ra, col, 1)
    CreateLine(l, ll, col, 1)
    CreateLine(l, rl, col, 1)
    CreateLine(ll, rl, col, 1)
end

local function DrawBox3D(char)
    local root = GetHumanoidRoot(char)
    if not root then return end
    local size = char:GetExtentsSize()
    local pos = root.Position
    local cf = root.CFrame
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-size.X/2, -size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new( size.X/2, -size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new( size.X/2, -size.Y/2,  size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2, -size.Y/2,  size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2,  size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new( size.X/2,  size.Y/2, -size.Z/2)),
        cf:PointToWorldSpace(Vector3.new( size.X/2,  size.Y/2,  size.Z/2)),
        cf:PointToWorldSpace(Vector3.new(-size.X/2,  size.Y/2,  size.Z/2))
    }
    local scr = {}
    for _, c in ipairs(corners) do
        local s = WorldToScreen(c)
        if s then table.insert(scr, s) end
    end
    if #scr < 8 then return end
    local col = GetColor(char.Parent)
    local edges = {
        {1,2},{2,3},{3,4},{4,1},
        {5,6},{6,7},{7,8},{8,5},
        {1,5},{2,6},{3,7},{4,8}
    }
    for _, e in ipairs(edges) do
        if scr[e[1]] and scr[e[2]] then
            CreateLine(scr[e[1]], scr[e[2]], col, 1)
        end
    end
end

local function DrawESPPlayer(player)
    local char = player.Character
    if not char then return end
    local root = GetHumanoidRoot(char)
    if not root then return end
    local pos = root.Position
    local screen = WorldToScreen(pos)
    if not screen then return end
    local col = GetColor(player)
    local colBright = GetColorBright(player)
    local hum = char:FindFirstChild("Humanoid")
    local healthPercent = hum and (hum.Health / hum.MaxHealth) or 1
    
    if Settings.ESPBox then
        local size = char:GetExtentsSize()
        local top = WorldToScreen(pos + Vector3.new(0, size.Y/2, 0))
        local bottom = WorldToScreen(pos - Vector3.new(0, size.Y/2, 0))
        if top and bottom then
            local height = (bottom - top).Y
            local width = height * 0.4
            local boxPos = Vector2.new(screen.X - width/2, top.Y)
            CreateBox(boxPos, Vector2.new(width, height), col, 1.5)
        end
    end
    
    if Settings.ESPBox3D then
        DrawBox3D(char)
    end
    
    if Settings.ESPSkeleton then
        DrawSkeleton(char)
    end
    
    if Settings.ESPLine then
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        CreateLine(center, screen, col, 1)
    end
    
    if Settings.ESPGlow then
        local glow = char:FindFirstChild("Highlight") or Instance.new("Highlight")
        glow.Parent = char
        glow.Enabled = true
        glow.FillColor = col
        glow.FillTransparency = 0.6
        glow.OutlineTransparency = 0.4
        table.insert(espObjects, glow)
    end
    
    if Settings.ESPChams then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local cham = part:FindFirstChild("ChamESP") or Instance.new("BoxHandleAdornment")
                cham.Name = "ChamESP"
                cham.Parent = part
                cham.Adornee = part
                cham.Size = part.Size
                cham.Color3 = colBright
                cham.Transparency = 0.5
                cham.ZIndex = 0
                cham.AlwaysOnTop = true
                table.insert(espObjects, cham)
            end
        end
    end
    
    if Settings.ESPHealth then
        if hum then
            local hp = math.round(hum.Health / hum.MaxHealth * 100)
            local hpColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            local txt = tostring(hp) .. "%"
            local hpPos = Vector2.new(screen.X + 18, screen.Y - 6)
            CreateText(txt, hpPos, hpColor, 12, false)
        end
    end
    
    if Settings.ESPDistance then
        local dist = math.round((pos - Camera.CFrame.Position).Magnitude)
        local txt = dist .. "m"
        local dPos = Vector2.new(screen.X + 18, screen.Y + 8)
        CreateText(txt, dPos, Color3.fromRGB(200,200,255), 11, false)
    end
    
    if Settings.ESPName then
        local name = player.Name
        local nPos = Vector2.new(screen.X, screen.Y - 28)
        CreateText(name, nPos, col, 14, true)
    end
    
    if Settings.ESPWeapon then
        local tool = player:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            local wPos = Vector2.new(screen.X, screen.Y + 28)
            CreateText(tool.Name, wPos, Color3.fromRGB(255,255,0), 11, true)
        end
    end
    
    if Settings.ESPBarrel then
        local look = root.CFrame.LookVector
        local barrelEnd = pos + look * 10
        local bScreen = WorldToScreen(barrelEnd)
        if bScreen then
            CreateLine(screen, bScreen, Color3.fromRGB(255,0,255), 1)
        end
    end
end

local function DrawWorldESP()
    if Settings.ESPItem then
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") or (item:IsA("Part") and string.find(string.lower(item.Name or ""), "loot")) then
                local pos = item.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("ITEM", scr, Color3.fromRGB(0,255,255), 12, true)
                    end
                end
            end
        end
    end
    
    if Settings.ESPVehicle then
        for _, vehicle in pairs(Workspace:GetDescendants()) do
            if vehicle:IsA("VehicleSeat") or (vehicle:IsA("Model") and vehicle:FindFirstChild("Vehicle")) then
                local pos = vehicle.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("VEHICLE", scr, Color3.fromRGB(255,165,0), 12, true)
                    end
                end
            end
        end
    end
    
    if Settings.ESPGrenade then
        for _, proj in pairs(Workspace:GetDescendants()) do
            if proj:IsA("Projectile") or proj:FindFirstChild("Projectile") or string.find(string.lower(proj.Name or ""), "grenade") then
                local pos = proj.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("GRENADE", scr, Color3.fromRGB(255,0,0), 12, true)
                    end
                end
            end
        end
    end
    
    if Settings.ESPRadar then
        local radarPos = Vector2.new(45, Camera.ViewportSize.Y - 120)
        local radarSize = 85
        CreateCircle(radarPos + Vector2.new(radarSize/2, radarSize/2), radarSize/2, Color3.fromRGB(100,100,150), 1, false)
        local center = radarPos + Vector2.new(radarSize/2, radarSize/2)
        CreateText("RADAR", radarPos + Vector2.new(radarSize/2 - 20, -10), Color3.fromRGB(200,200,255), 9, false)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = GetHumanoidRoot(player.Character)
                if root then
                    local rel = root.Position - Camera.CFrame.Position
                    local angle = math.atan2(rel.X, rel.Z)
                    local dist = rel.Magnitude
                    local scale = math.min(dist/100, 1)
                    local dot = Vector2.new(math.sin(angle), math.cos(angle)) * scale * (radarSize/2 - 5)
                    local dotPos = center + dot
                    CreateCircle(dotPos, 2.5, GetColor(player), 1.5, true)
                end
            end
        end
    end
end

local function GetClosestPlayer()
    local bestDist = math.huge
    local bestTarget = nil
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local fovRadius = Settings.FOVRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if IsTeammate(player) then
                continue
            end
            
            local boneName = Settings.Bone
            local targetPart = player.Character:FindFirstChild(boneName) or player.Character:FindFirstChild("HumanoidRootPart")
            if not targetPart then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local screenPos = Vector2.new(pos.X, pos.Y)
                local dist = (screenPos - mousePos).Magnitude
                
                if dist < fovRadius then
                    local checkVal = Settings.TargetMode == "Closest" and dist or player.Character.Humanoid.Health
                    if checkVal < bestDist then
                        bestDist = checkVal
                        bestTarget = {
                            player = player,
                            part = targetPart,
                            screenPos = screenPos,
                            position = targetPart.Position
                        }
                    end
                end
            end
        end
    end
    return bestTarget
end

local function AimAtTarget(target)
    if not target then return end
    
    local currentCF = Camera.CFrame
    local targetPos = target.position
    local newCF = CFrame.new(currentCF.Position, targetPos)
    
    if Settings.SmoothAimbot then
        local smoothFactor = 1 - (Settings.AimSmoothness / 20)
        Camera.CFrame = currentCF:Lerp(newCF, smoothFactor)
    else
        Camera.CFrame = newCF
    end
end

local function Shoot()
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        return
    end
    mouse1click()
    VirtualUser:CaptureController()
    VirtualUser:SetKeyDown("0x01")
    wait(0.05)
    VirtualUser:SetKeyUp("0x01")
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 100)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)

local lastTarget = nil
local targetLocked = false

RunService.RenderStepped:Connect(function()
    
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Settings.FOVRadius
    FOVCircle.Visible = Settings.FOVAimbot
    
    
    ClearESP()
    
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            DrawESPPlayer(player)
        end
    end
    DrawWorldESP()
    
    
    local target = GetClosestPlayer()
    if not target then 
        targetLocked = false
        return 
    end
    
    if Settings.RageAimbot then
        AimAtTarget(target)
        Shoot()
    end
    
    if Settings.LegitAimbot then
        local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService:IsTouchEnabled()
        if isAiming then
            AimAtTarget(target)
        end
    end
    
    if Settings.SilentAimbot then
        AimAtTarget(target)
        Shoot()
    end
    
    if Settings.Triggerbot then
        local dist = (target.screenPos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        if dist < 20 then
            Shoot()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)putBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)