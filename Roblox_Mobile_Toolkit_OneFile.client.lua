local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local CFG = {
    Fov = 180,
    Smooth = 8,
    TargetMode = "Nearest",
    BodyPart = "Head",
    ShowESP = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowWeapon = true,
    ShowRadar = true,
    Clay = false,
    LowGraphics = false,
    DisableEffects = false,
    RadarScale = 1,
    PanelScale = 0.82,
}

local state = {
    gui = nil,
    panel = nil,
    content = nil,
    tabs = {},
    pages = {},
    esp = {},
    registry = {},
    targets = {},
    radarDots = {},
    currentTab = "Ngắm",
    drag = false,
    dragStart = nil,
    panelStart = nil,
    alive = true,
    conns = {},
}

local function safe(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
end

local function conn(signal, fn)
    local c = signal:Connect(function(...)
        safe(fn, ...)
    end)
    table.insert(state.conns, c)
    return c
end

local function saveRuntimeConfig()
    for k, v in pairs(CFG) do
        LocalPlayer:SetAttribute("RMT_" .. k, v)
    end
end

local function loadRuntimeConfig()
    for k, v in pairs(CFG) do
        local x = LocalPlayer:GetAttribute("RMT_" .. k)
        if typeof(x) == typeof(v) then
            CFG[k] = x
        end
    end
end

local function mk(className, props, parent)
    local o = Instance.new(className)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    o.Parent = parent
    return o
end

local function corner(o, r)
    mk("UICorner", {CornerRadius = UDim.new(0, r or 10)}, o)
end

local function stroke(o, color, trans, thick)
    mk("UIStroke", {Color = color or Color3.fromRGB(60,60,70), Transparency = trans or 0, Thickness = thick or 1}, o)
end

local function pad(o, a)
    mk("UIPadding", {PaddingTop=UDim.new(0,a), PaddingBottom=UDim.new(0,a), PaddingLeft=UDim.new(0,a), PaddingRight=UDim.new(0,a)}, o)
end

local function label(parent, text, size, color)
    return mk("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Color3.new(1,1,1),
        TextSize = size or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,0,24),
    }, parent)
end

local function button(parent, text, callback, h)
    local b = mk("TextButton", {
        Size = UDim2.new(1,0,0,h or 46),
        BackgroundColor3 = Color3.fromRGB(38,38,48),
        TextColor3 = Color3.new(1,1,1),
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Text = text,
        AutoButtonColor = true,
    }, parent)
    corner(b, 10)
    stroke(b, Color3.fromRGB(70,70,85), 0.2, 1)
    conn(b.Activated, callback)
    return b
end

local function setStatusButton(b, name, value)
    b.Text = name .. ": " .. (value and "ON" or "OFF")
    b.BackgroundColor3 = value and Color3.fromRGB(30,100,70) or Color3.fromRGB(55,42,48)
end

local function findPart(model, wanted)
    if not model then return nil end
    if wanted == "Head" then return model:FindFirstChild("Head") end
    if wanted == "UpperTorso" then return model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") end
    if wanted == "Root" then return model:FindFirstChild("HumanoidRootPart") end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
end

local function isAliveCharacter(model)
    local hum = model and model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isFriendly(model)
    local p = Players:GetPlayerFromCharacter(model)
    if p and LocalPlayer.Team ~= nil and p.Team ~= nil then
        return p.Team == LocalPlayer.Team
    end
    if p then return false end
    return false
end

local function rebuildRegistry()
    state.registry = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local ch = p.Character
            if ch and isAliveCharacter(ch) then
                state.registry[ch] = true
            end
        end
    end
    for _, obj in ipairs(CollectionService:GetTagged("Targetable")) do
        if obj:IsA("Model") and isAliveCharacter(obj) then
            state.registry[obj] = true
        end
    end
end

local function candidateList()
    local out = {}
    local cam = Workspace.CurrentCamera
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not cam or not root then return out end
    for model in pairs(state.registry) do
        if model.Parent and isAliveCharacter(model) and not isFriendly(model) then
            local part = findPart(model, CFG.BodyPart)
            if part then
                local d = (part.Position - root.Position).Magnitude
                local vp, visible = cam:WorldToViewportPoint(part.Position)
                if visible and vp.Z > 0 then
                    out[#out+1] = {model=model, part=part, dist=d}
                end
            end
        end
    end
    table.sort(out, function(a,b)
        if CFG.TargetMode == "LowestHealth" then
            local ha = a.model:FindFirstChildOfClass("Humanoid")
            local hb = b.model:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or math.huge) < (hb and hb.Health or math.huge)
        end
        return a.dist < b.dist
    end)
    return out
end

local function getWeapon(model)
    local tool = model and model:FindFirstChildOfClass("Tool")
    return tool and tool.Name or ""
end

local function clearESP(model)
    local e = state.esp[model]
    if not e then return end
    for _, o in pairs(e) do
        if typeof(o) == "Instance" then safe(function() o:Destroy() end) end
    end
    state.esp[model] = nil
end

local function makeESP(model)
    if not CFG.ShowESP or state.esp[model] or not model.Parent then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head") or hrp
    if not hrp or not head then return end
    local friendly = isFriendly(model)
    local color = friendly and Color3.fromRGB(70,170,255) or Color3.fromRGB(255,70,70)
    local hl = mk("Highlight", {Adornee=model, FillColor=color, OutlineColor=color, FillTransparency=0.78, OutlineTransparency=0.05, DepthMode=Enum.HighlightDepthMode.Occluded}, model)
    local bb = mk("BillboardGui", {Adornee=head, Size=UDim2.fromOffset(180,82), StudsOffset=Vector3.new(0,2.8,0), AlwaysOnTop=false, MaxDistance=5}, model)
    local root = mk("Frame", {BackgroundTransparency=1, Size=UDim2.fromScale(1,1)}, bb)
    local title = label(root, model.Name, 14, color)
    title.Size = UDim2.new(1,0,0,18)
    local hp = label(root, "", 13, Color3.new(1,1,1)); hp.Position = UDim2.fromOffset(0,18); hp.Size = UDim2.new(1,0,0,18)
    local info = label(root, "", 13, Color3.fromRGB(220,220,220)); info.Position = UDim2.fromOffset(0,36); info.Size = UDim2.new(1,0,0,36)
    local line = mk("Frame", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,0,0), Size=UDim2.fromOffset(2,20), BackgroundColor3=color, BorderSizePixel=0}, bb)
    line.Visible = false
    state.esp[model] = {hl=hl, bb=bb, title=title, hp=hp, info=info}
end

local function updateESP(model, data)
    local e = state.esp[model]
    if not e then return end
    local head = findPart(model, "Head") or findPart(model, "Root")
    local root = findPart(model, "Root")
    if not head or not root then clearESP(model) return end
    local cam = Workspace.CurrentCamera
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not cam or not myRoot then return end
    local dist = (root.Position - myRoot.Position).Magnitude
    local vp = cam:WorldToViewportPoint(head.Position)
    local inside = vp.Z > 0 and dist <= 5
    e.bb.Enabled = CFG.ShowESP and inside
    e.hl.Enabled = CFG.ShowESP and inside
    if inside then
        local hum = model:FindFirstChildOfClass("Humanoid")
        local text = ""
        if CFG.ShowHealth and hum then text = string.format("HP: %d/%d", hum.Health, hum.MaxHealth) end
        if CFG.ShowDistance then text = (text ~= "" and text.."  " or "") .. string.format("%.1fm", dist) end
        e.hp.Text = text
        local info = ""
        if CFG.ShowWeapon then info = getWeapon(model) end
        e.info.Text = info
        e.title.Text = CFG.ShowNames and model.Name or ""
    end
end

local function setLowGraphics(enable)
    CFG.LowGraphics = enable
    safe(function()
        Lighting.GlobalShadows = not enable
        Lighting.Brightness = enable and 1 or 2
    end)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        safe(function()
            if obj:IsA("BasePart") and enable then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = enable and 1 or obj.Transparency
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = not (enable or CFG.DisableEffects)
            end
        end)
    end
    saveRuntimeConfig()
end

local function setDisableEffects(enable)
    CFG.DisableEffects = enable
    for _, obj in ipairs(Workspace:GetDescendants()) do
        safe(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = not enable
            end
        end)
    end
    saveRuntimeConfig()
end

local function createRadar(parent)
    local frame = mk("Frame", {AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-12,1,-12), Size=UDim2.fromOffset(150,150), BackgroundColor3=Color3.fromRGB(12,12,18), BackgroundTransparency=0.2, Visible=CFG.ShowRadar}, parent)
    corner(frame, 75); stroke(frame, Color3.fromRGB(90,90,110), 0.15, 1)
    mk("UIAspectRatioConstraint", {AspectRatio=1}, frame)
    local center = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(6,6), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0}, frame); corner(center,3)
    state.radarFrame = frame
end

local function updateRadar()
    if not state.radarFrame then return end
    state.radarFrame.Visible = CFG.ShowRadar
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local cam = Workspace.CurrentCamera
    if not root or not cam then return end
    for _, d in pairs(state.radarDots) do d:Destroy() end
    state.radarDots = {}
    local radius = 65
    local scale = 60 * CFG.RadarScale
    for model in pairs(state.registry) do
        if model.Parent and isAliveCharacter(model) then
            local part = findPart(model,"Root")
            if part then
                local delta = part.Position - root.Position
                local horizontal = Vector3.new(delta.X,0,delta.Z)
                local mag = horizontal.Magnitude
                if mag > 0 then
                    local r = math.min(mag / scale, 0.48)
                    local dotPos = horizontal.Unit * (r * 150)
                    local color = isFriendly(model) and Color3.fromRGB(70,170,255) or Color3.fromRGB(255,70,70)
                    local dot = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,dotPos.X,0.5,dotPos.Z), Size=UDim2.fromOffset(7,7), BackgroundColor3=color, BorderSizePixel=0}, state.radarFrame)
                    corner(dot,4)
                    table.insert(state.radarDots,dot)
                end
            end
        end
    end
end

local function makePage(parent)
    local sc = mk("ScrollingFrame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=5, ScrollBarImageTransparency=0.4}, parent)
    pad(sc,8)
    local list = mk("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, sc)
    return sc
end

local function sectionTitle(page, text)
    local l = label(page, text, 15, Color3.fromRGB(190,190,205))
    l.Size = UDim2.new(1,0,0,25)
    return l
end

local function makeSlider(page, titleText, minV, maxV, value, setter)
    local box = mk("Frame", {Size=UDim2.new(1,0,0,72), BackgroundColor3=Color3.fromRGB(30,30,40)}, page); corner(box,10); pad(box,8)
    local t = label(box, titleText .. ": " .. tostring(value), 14)
    t.Size = UDim2.new(1,0,0,22)
    local bar = mk("Frame", {AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,1,-16), Size=UDim2.new(1,0,0,8), BackgroundColor3=Color3.fromRGB(60,60,72)}, box); corner(bar,4)
    local fill = mk("Frame", {Size=UDim2.new((value-minV)/(maxV-minV),0,1,0), BackgroundColor3=Color3.fromRGB(95,110,255)}, bar); corner(fill,4)
    local knob = mk("TextButton", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new((value-minV)/(maxV-minV),0,0.5,0), Size=UDim2.fromOffset(24,24), BackgroundColor3=Color3.new(1,1,1), Text=""}, bar); corner(knob,12)
    local sliding = false
    local function setFromX(x)
        local pct = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v = math.floor(minV + (maxV-minV)*pct + 0.5)
        fill.Size = UDim2.new(pct,0,1,0); knob.Position = UDim2.new(pct,0,0.5,0); t.Text = titleText .. ": " .. tostring(v); setter(v); saveRuntimeConfig()
    end
    conn(knob.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end end)
    conn(UserInputService.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
    conn(UserInputService.InputChanged,function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromX(i.Position.X) end end)
    return box
end

local function buildUI()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local gui = mk("ScreenGui", {Name="RobloxMobileToolkit", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, pg)
    state.gui = gui
    local panel = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(CFG.PanelScale,0,0.74,0), BackgroundColor3=Color3.fromRGB(18,18,24)}, gui)
    corner(panel,10); stroke(panel,Color3.fromRGB(65,65,80),0.15,1); state.panel=panel
    local scale = mk("UIScale", {Scale=1}, panel)
    if UserInputService.TouchEnabled then scale.Scale = 0.92 end
    local titleBar = mk("Frame", {Size=UDim2.new(1,0,0,50), BackgroundColor3=Color3.fromRGB(24,24,32)}, panel); corner(titleBar,10)
    local title = label(titleBar,"Mobile Toolkit",16); title.Position=UDim2.fromOffset(14,0); title.Size=UDim2.new(1,-70,1,0); title.TextYAlignment=Enum.TextYAlignment.Center
    local close = mk("TextButton", {AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(42,38),BackgroundColor3=Color3.fromRGB(190,55,55),Text="×",TextSize=24,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold},titleBar);corner(close,9)
    local tabBar = mk("Frame", {Position=UDim2.new(0,8,0,58),Size=UDim2.new(1,-16,0,46),BackgroundTransparency=1},panel)
    local tabLayout=mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,6)},tabBar)
    local body = mk("Frame", {Position=UDim2.new(0,8,0,112),Size=UDim2.new(1,-16,1,-120),BackgroundTransparency=1},panel); state.content=body
    local names={"Ngắm","Hiển thị","Thế giới","Cài đặt"}
    for _,name in ipairs(names) do
        local b=mk("TextButton",{Size=UDim2.new(0,100,1,0),BackgroundColor3=Color3.fromRGB(34,34,44),Text=name,TextColor3=Color3.new(1,1,1),TextSize=14,Font=Enum.Font.GothamMedium},tabBar);corner(b,8);state.tabs[name]=b
        conn(b.Activated,function() state.currentTab=name; for n,t in pairs(state.tabs) do t.BackgroundColor3=(n==name) and Color3.fromRGB(75,85,160) or Color3.fromRGB(34,34,44); end for n,p in pairs(state.pages) do p.Visible=(n==name) end end)
    end
    for _,name in ipairs(names) do state.pages[name]=makePage(body) end
    local a=state.pages["Ngắm"]
    sectionTitle(a,"Hệ thống mục tiêu")
    makeSlider(a,"Phạm vi",10,360,CFG.Fov,function(v) CFG.Fov=v end)
    makeSlider(a,"Độ mượt",1,20,CFG.Smooth,function(v) CFG.Smooth=v end)
    local b1=button(a,"Mục tiêu: "..CFG.TargetMode,function() CFG.TargetMode=(CFG.TargetMode=="Nearest") and "LowestHealth" or "Nearest"; b1.Text="Mục tiêu: "..CFG.TargetMode; saveRuntimeConfig() end)
    local b2=button(a,"Bộ phận: "..CFG.BodyPart,function() local arr={"Head","UpperTorso","Root"}; local i=table.find(arr,CFG.BodyPart) or 1; CFG.BodyPart=arr[i%#arr+1]; b2.Text="Bộ phận: "..CFG.BodyPart; saveRuntimeConfig() end)
    local note=label(a,"Targeting chỉ chọn mục tiêu hợp lệ trong game của bạn và không tự bắn.",13,Color3.fromRGB(180,180,190));note.TextWrapped=true
    local v=state.pages["Hiển thị"]
    sectionTitle(v,"Hiển thị")
    local e=button(v,"ESP",function() CFG.ShowESP=not CFG.ShowESP; setStatusButton(e,"ESP",CFG.ShowESP); saveRuntimeConfig() end); setStatusButton(e,"ESP",CFG.ShowESP)
    local n=button(v,"Tên",function() CFG.ShowNames=not CFG.ShowNames; setStatusButton(n,"Tên",CFG.ShowNames); saveRuntimeConfig() end); setStatusButton(n,"Tên",CFG.ShowNames)
    local d=button(v,"Khoảng cách",function() CFG.ShowDistance=not CFG.ShowDistance; setStatusButton(d,"Khoảng cách",CFG.ShowDistance); saveRuntimeConfig() end); setStatusButton(d,"Khoảng cách",CFG.ShowDistance)
    local h=button(v,"Máu",function() CFG.ShowHealth=not CFG.ShowHealth; setStatusButton(h,"Máu",CFG.ShowHealth); saveRuntimeConfig() end); setStatusButton(h,"Máu",CFG.ShowHealth)
    local w=button(v,"Vũ khí",function() CFG.ShowWeapon=not CFG.ShowWeapon; setStatusButton(w,"Vũ khí",CFG.ShowWeapon); saveRuntimeConfig() end); setStatusButton(w,"Vũ khí",CFG.ShowWeapon)
    local world=state.pages["Thế giới"]
    sectionTitle(world,"Thế giới & Radar")
    local r=button(world,"Radar",function() CFG.ShowRadar=not CFG.ShowRadar; setStatusButton(r,"Radar",CFG.ShowRadar); saveRuntimeConfig() end);setStatusButton(r,"Radar",CFG.ShowRadar)
    makeSlider(world,"Thu phóng radar",1,5,CFG.RadarScale,function(v) CFG.RadarScale=v end)
    local info=label(world,"Gắn tag Targetable cho NPC. Dùng attribute RadarType = Item hoặc Vehicle cho đối tượng thế giới.",13,Color3.fromRGB(180,180,190));info.TextWrapped=true
    createRadar(gui)
    local s=state.pages["Cài đặt"]
    sectionTitle(s,"Hiệu suất")
    local lg=button(s,"Đồ họa thấp",function() setLowGraphics(not CFG.LowGraphics); setStatusButton(lg,"Đồ họa thấp",CFG.LowGraphics) end);setStatusButton(lg,"Đồ họa thấp",CFG.LowGraphics)
    local de=button(s,"Tắt hiệu ứng",function() setDisableEffects(not CFG.DisableEffects); setStatusButton(de,"Tắt hiệu ứng",CFG.DisableEffects) end);setStatusButton(de,"Tắt hiệu ứng",CFG.DisableEffects)
    local reset=button(s,"Đặt lại cài đặt",function() for k,vv in pairs({Fov=180,Smooth=8,TargetMode="Nearest",BodyPart="Head",ShowESP=true,ShowNames=true,ShowDistance=true,ShowHealth=true,ShowWeapon=true,ShowRadar=true,Clay=false,LowGraphics=false,DisableEffects=false,RadarScale=1}) do CFG[k]=vv end saveRuntimeConfig(); buildAndRefresh() end)
    conn(close.Activated,function() panel.Visible=false end)
    conn(UserInputService.InputBegan,function(i,gp) if gp then return end if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and i.Position.X>=titleBar.AbsolutePosition.X and i.Position.X<=titleBar.AbsolutePosition.X+titleBar.AbsoluteSize.X and i.Position.Y>=titleBar.AbsolutePosition.Y and i.Position.Y<=titleBar.AbsolutePosition.Y+titleBar.AbsoluteSize.Y then state.drag=true;state.dragStart=i.Position;state.panelStart=panel.Position end end)
    conn(UserInputService.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then state.drag=false end end)
    conn(UserInputService.InputChanged,function(i) if state.drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local delta=i.Position-state.dragStart;panel.Position=UDim2.new(state.panelStart.X.Scale,state.panelStart.X.Offset+delta.X,state.panelStart.Y.Scale,state.panelStart.Y.Offset+delta.Y) end end)
    state.tabs["Ngắm"].BackgroundColor3=Color3.fromRGB(75,85,160)
    for n,p in pairs(state.pages) do p.Visible=(n=="Ngắm") end
end

function buildAndRefresh()
    if state.gui then state.gui:Destroy() end
    state.esp={};state.radarDots={}
    buildUI()
end

loadRuntimeConfig()
rebuildRegistry()
buildUI()

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        conn(p.CharacterAdded,function() task.wait(0.5); rebuildRegistry() end)
        conn(p.CharacterRemoving,function(ch) clearESP(ch); rebuildRegistry() end)
    end
end
conn(Players.PlayerAdded,function(p) conn(p.CharacterAdded,function() task.wait(0.5); rebuildRegistry() end) end)
conn(Players.PlayerRemoving,function(p) if p.Character then clearESP(p.Character) end; rebuildRegistry() end)
conn(CollectionService:GetInstanceAddedSignal("Targetable"),function() rebuildRegistry() end)
conn(CollectionService:GetInstanceRemovedSignal("Targetable"),function() rebuildRegistry() end)

local scanClock, radarClock = 0, 0
conn(RunService.Heartbeat,function(dt)
    if not state.alive then return end
    scanClock += dt; radarClock += dt
    if scanClock >= 0.5 then
        scanClock = 0
        rebuildRegistry()
        for model in pairs(state.registry) do
            if CFG.ShowESP then makeESP(model); updateESP(model) else clearESP(model) end
        end
    end
    if radarClock >= 0.25 then radarClock=0; updateRadar() end
end)

conn(LocalPlayer.CharacterAdded,function() task.wait(0.5); rebuildRegistry() end)

local fovGui = mk("ScreenGui", {Name="RMT_Fov", ResetOnSpawn=false, IgnoreGuiInset=true}, LocalPlayer:WaitForChild("PlayerGui"))
local fov = mk("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(CFG.Fov*2,CFG.Fov*2), BackgroundTransparency=1}, fovGui)
corner(fov,CFG.Fov)
stroke(fov,Color3.fromRGB(120,130,255),0.35,1)
conn(RunService.RenderStepped,function() fov.Size=UDim2.fromOffset(CFG.Fov*2,CFG.Fov*2); fov.Visible=state.panel and state.panel.Visible end)
