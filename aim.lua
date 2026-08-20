local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Teams = game:GetService("Teams")

local Settings = {
    RageAimbot = false,
    LegitAimbot = false,
    SilentAimbot = false,
    SmoothAimbot = false,
    Triggerbot = false,
    FOVAimbot = false,
    FixLag = false,
    FOVRadius = 200,
    TargetMode = "Closest",
    Bone = "Head",
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
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "DeltaMenu"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0, 20, 0.5, -300)
MainFrame.Size = UDim2.new(0, 300, 0, 600)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.Text = "DELTA ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollingFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)

local function MakeToggle(parent, text, settingKey, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(70, 70, 90)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.Size = UDim2.new(0.25, 0, 0.8, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(180, 40, 40)
    btn.Text = default and "BAT" or "TAT"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0

    Settings[settingKey] = default
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(180, 40, 40)
        btn.Text = Settings[settingKey] and "BAT" or "TAT"
    end)
    return frame
end

local function MakeSlider(parent, text, settingKey, minVal, maxVal, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -10, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(70, 70, 90)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. " (" .. tostring(default) .. ")"
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13

    local slider = Instance.new("Frame")
    slider.Parent = frame
    slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.Size = UDim2.new(1, 0, 0, 16)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)

    local fill = Instance.new("Frame")
    fill.Parent = slider
    fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
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
    frame.Size = UDim2.new(1, -10, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(70, 70, 90)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13

    local drop = Instance.new("TextButton")
    drop.Parent = frame
    drop.Position = UDim2.new(0.55, 0, 0, 0)
    drop.Size = UDim2.new(0.4, 0, 0.8, 0)
    drop.Text = default
    drop.TextColor3 = Color3.fromRGB(255,255,255)
    drop.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    drop.Font = Enum.Font.GothamBold
    drop.TextSize = 12
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
    label.Size = UDim2.new(1, -10, 0, 24)
    label.Text = "--- " .. text .. " ---"
    label.TextColor3 = Color3.fromRGB(255, 200, 100)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Center
    return label
end

AddCategory(ScrollingFrame, "AIMBOT")
MakeToggle(ScrollingFrame, "Rage Aimbot", "RageAimbot", false)
MakeToggle(ScrollingFrame, "Legit Aimbot", "LegitAimbot", false)
MakeToggle(ScrollingFrame, "Silent Aimbot", "SilentAimbot", false)
MakeToggle(ScrollingFrame, "Smooth Aimbot", "SmoothAimbot", false)
MakeToggle(ScrollingFrame, "Triggerbot", "Triggerbot", false)
MakeToggle(ScrollingFrame, "FOV Circle", "FOVAimbot", false)
MakeSlider(ScrollingFrame, "FOV Radius", "FOVRadius", 10, 360, 200)
MakeDropdown(ScrollingFrame, "Target Mode", "TargetMode", {"Closest", "LowestHealth"}, "Closest")
MakeDropdown(ScrollingFrame, "Bone", "Bone", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head")
MakeToggle(ScrollingFrame, "Fix Lag", "FixLag", false)

AddCategory(ScrollingFrame, "ESP PLAYER")
MakeToggle(ScrollingFrame, "Box 2D", "ESPBox", false)
MakeToggle(ScrollingFrame, "Box 3D", "ESPBox3D", false)
MakeToggle(ScrollingFrame, "Skeleton", "ESPSkeleton", false)
MakeToggle(ScrollingFrame, "Line (2D)", "ESPLine", false)
MakeToggle(ScrollingFrame, "Glow", "ESPGlow", false)
MakeToggle(ScrollingFrame, "Chams", "ESPChams", false)
MakeToggle(ScrollingFrame, "Health", "ESPHealth", false)
MakeToggle(ScrollingFrame, "Distance", "ESPDistance", false)
MakeToggle(ScrollingFrame, "Name", "ESPName", false)
MakeToggle(ScrollingFrame, "Weapon", "ESPWeapon", false)
MakeToggle(ScrollingFrame, "Barrel/View Line", "ESPBarrel", false)

AddCategory(ScrollingFrame, "ESP WORLD")
MakeToggle(ScrollingFrame, "Item/Loot", "ESPItem", false)
MakeToggle(ScrollingFrame, "Vehicle", "ESPVehicle", false)
MakeToggle(ScrollingFrame, "Radar", "ESPRadar", false)
MakeToggle(ScrollingFrame, "Grenade/Projectile", "ESPGrenade", false)

local espObjects = {}
local function ClearESP()
    for _, obj in pairs(espObjects) do
        obj:Remove()
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
    txt.Size = size or 14
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
    box.Thickness = thickness or 2
    box.Filled = false
    box.Visible = true
    table.insert(espObjects, box)
    return box
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

local function WorldToScreen(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    if onScreen then
        return Vector2.new(v.X, v.Y), v.Z
    end
    return nil, nil
end

local function GetBonePos(char, boneName)
    if not char then return nil end
    if boneName == "Head" then
        local head = char:FindFirstChild("Head")
        if head then return head.Position end
    end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if torso then return torso.Position end
    return nil
end

local function GetHumanoidRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetJoints(char)
    local joints = {}
    local root = GetHumanoidRoot(char)
    if not root then return joints end
    local head = char:FindFirstChild("Head")
    local upper = char:FindFirstChild("UpperTorso")
    local lower = char:FindFirstChild("LowerTorso")
    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("LeftArm")
    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("RightArm")
    local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("LeftLeg")
    local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("RightLeg")
    if head and root then
        joints.Head = head.Position
        joints.Root = root.Position
        if upper then joints.Upper = upper.Position else joints.Upper = root.Position end
        if lower then joints.Lower = lower.Position else joints.Upper = root.Position end
        if leftArm then joints.LeftArm = leftArm.Position else joints.LeftArm = root.Position end
        if rightArm then joints.RightArm = rightArm.Position else joints.RightArm = root.Position end
        if leftLeg then joints.LeftLeg = leftLeg.Position else joints.LeftLeg = root.Position end
        if rightLeg then joints.RightLeg = rightLeg.Position else joints.RightLeg = root.Position end
    end
    return joints
end

local function DrawSkeleton(char)
    local joints = GetJoints(char)
    if not joints.Head then return end
    local h, hz = WorldToScreen(joints.Head)
    local r, rz = WorldToScreen(joints.Root)
    local u, uz = WorldToScreen(joints.Upper)
    local l, lz = WorldToScreen(joints.Lower)
    local la, laz = WorldToScreen(joints.LeftArm)
    local ra, raz = WorldToScreen(joints.RightArm)
    local ll, llz = WorldToScreen(joints.LeftLeg)
    local rl, rlz = WorldToScreen(joints.RightLeg)
    if not (h and r and u and l and la and ra and ll and rl) then return end
    local col = Color3.fromRGB(255,255,255)
    CreateLine(h, u, col, 1)
    CreateLine(u, r, col, 1)
    CreateLine(u, l, col, 1)
    CreateLine(l, r, col, 1)
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
    local screen, depth = WorldToScreen(pos)
    if not screen then return end
    local col = GetColor(player)
    if Settings.ESPBox then
        local size = char:GetExtentsSize()
        local w = size.X * 1.5
        local h = size.Y * 1.5
        local top = WorldToScreen(pos + Vector3.new(0, size.Y/2, 0))
        local bottom = WorldToScreen(pos - Vector3.new(0, size.Y/2, 0))
        if top and bottom then
            local height = (bottom - top).Y
            local width = height * 0.5
            local boxPos = Vector2.new(screen.X - width/2, top.Y)
            CreateBox(boxPos, Vector2.new(width, height), col, 2)
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
        glow.FillTransparency = 0.5
        glow.OutlineTransparency = 0
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
                cham.Color3 = col
                cham.Transparency = 0.5
                cham.ZIndex = 0
                cham.AlwaysOnTop = true
                table.insert(espObjects, cham)
            end
        end
    end
    if Settings.ESPHealth then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            local hp = math.round(hum.Health / hum.MaxHealth * 100)
            local txt = tostring(hp) .. "%"
            local hpPos = Vector2.new(screen.X + 20, screen.Y - 10)
            CreateText(txt, hpPos, Color3.fromRGB(0,255,0), 14, false)
        end
    end
    if Settings.ESPDistance then
        local dist = math.round((pos - Camera.CFrame.Position).Magnitude)
        local txt = dist .. "m"
        local dPos = Vector2.new(screen.X + 20, screen.Y + 10)
        CreateText(txt, dPos, Color3.fromRGB(255,255,255), 14, false)
    end
    if Settings.ESPName then
        local name = player.Name
        local nPos = Vector2.new(screen.X, screen.Y - 30)
        CreateText(name, nPos, col, 16, true)
    end
    if Settings.ESPWeapon then
        local tool = player:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            local wPos = Vector2.new(screen.X, screen.Y + 30)
            CreateText(tool.Name, wPos, Color3.fromRGB(255,255,0), 14, true)
        end
    end
    if Settings.ESPBarrel then
        local rootPos = root.Position
        local look = root.CFrame.LookVector
        local barrelEnd = rootPos + look * 10
        local bScreen = WorldToScreen(barrelEnd)
        if bScreen then
            CreateLine(screen, bScreen, Color3.fromRGB(255,0,255), 1)
        end
    end
end

local function DrawWorldESP()
    if Settings.ESPItem then
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Tool") or item:IsA("Part") and item.Name:find("Loot") then
                local pos = item.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("ITEM", scr, Color3.fromRGB(0,255,255), 14, true)
                    end
                end
            end
        end
    end
    if Settings.ESPVehicle then
        for _, vehicle in pairs(workspace:GetDescendants()) do
            if vehicle:IsA("VehicleSeat") or vehicle:IsA("Model") and vehicle:FindFirstChild("Vehicle") then
                local pos = vehicle.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("VEHICLE", scr, Color3.fromRGB(255,165,0), 14, true)
                    end
                end
            end
        end
    end
    if Settings.ESPItem then
        for _, proj in pairs(workspace:GetDescendants()) do
            if proj:IsA("Projectile") or proj:FindFirstChild("Projectile") or proj.Name:find("Grenade") then
                local pos = proj.Position
                if pos then
                    local scr = WorldToScreen(pos)
                    if scr then
                        CreateText("GRENADE", scr, Color3.fromRGB(255,0,0), 14, true)
                    end
                end
            end
        end
    end
    if Settings.ESPRadar then
        local radarPos = Vector2.new(50, 50)
        local radarSize = 100
        local radar = Drawing.new("Circle")
        radar.Position = radarPos + Vector2.new(radarSize/2, radarSize/2)
        radar.Radius = radarSize/2
        radar.Color = Color3.fromRGB(100,100,100)
        radar.Thickness = 1
        radar.Filled = false
        radar.Visible = true
        table.insert(espObjects, radar)
        local center = radarPos + Vector2.new(radarSize/2, radarSize/2)
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
                    local dotObj = Drawing.new("Circle")
                    dotObj.Position = dotPos
                    dotObj.Radius = 3
                    dotObj.Color = GetColor(player)
                    dotObj.Filled = true
                    dotObj.Visible = true
                    table.insert(espObjects, dotObj)
                end
            end
        end
    end
end

local function GetTarget()
    local bestDist = math.huge
    local bestTarget = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if IsTeammate(player) then
                continue
            end
            local root = player.Character:FindFirstChild(Settings.Bone) or player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < Settings.FOVRadius then
                        local checkVal = Settings.TargetMode == "Closest" and dist or player.Character.Humanoid.Health
                        if checkVal < bestDist then
                            bestDist = checkVal
                            bestTarget = {player = player, part = root, screenPos = Vector2.new(pos.X, pos.Y)}
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function AimAt(target)
    if not target then return end
    local current = Camera.CFrame
    local targetPos = target.part.Position
    local lookAt = CFrame.new(current.Position, targetPos)
    if Settings.SmoothAimbot then
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.25)
    else
        Camera.CFrame = lookAt
    end
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 100)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)

if Settings.FixLag then
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").Technology = Enum.Technology.Legacy
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
    end
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Settings.FOVRadius
    FOVCircle.Visible = Settings.FOVAimbot

    if Settings.FixLag then
        game:GetService("Lighting").GlobalShadows = false
    end

    ClearESP()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            DrawESPPlayer(player)
        end
    end
    DrawWorldESP()

    local target = GetTarget()
    if not target then return end

    if Settings.RageAimbot then
        AimAt(target)
        mouse1click()
    end

    if Settings.LegitAimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        AimAt(target)
    end

    if Settings.SilentAimbot then
        AimAt(target)
        mouse1click()
    end

    if Settings.Triggerbot then
        local pos = target.screenPos
        if pos and (pos - Vector2.new(Mouse.X, Mouse.Y)).Magnitude < 15 then
            mouse1click()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)