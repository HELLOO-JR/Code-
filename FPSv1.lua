local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
	EnableFixLag = true,
	RemoveDecals = true,
	RemoveTextures = true,
	RemoveParticles = true,
	RemoveClothing = false,
	DisableShadows = true,
	LowGraphics = true,
	CleanWorkspace = true,
	AutoPurgeRAM = true,
}

local FloorKeywords = {"floor", "baseplate", "ground", "map", "road", "platform"}
local ParticleClasses = {"ParticleEmitter", "Trail", "Beam", "Smoke", "Fire", "Sparkles"}

local function safeSet(obj, prop, value)
	pcall(function()
		obj[prop] = value
	end)
end

local function isFloorPart(part)
	local n = string.lower(part.Name)
	for _, k in ipairs(FloorKeywords) do
		if string.find(n, k) then
			return true
		end
	end
	return false
end

local function applyLevel1(part)
	safeSet(part, "Material", Enum.Material.SmoothPlastic)
end

local function applyLevel2(part)
	if isFloorPart(part) then
		safeSet(part, "Material", Enum.Material.SmoothPlastic)
		safeSet(part, "Color", Color3.fromRGB(128, 128, 128))
	end
end

local function removeDecalsFrom(obj)
	if obj:IsA("Decal") then
		pcall(function()
			obj:Destroy()
		end)
	end
end

local function removeTexturesFrom(obj)
	if obj:IsA("Texture") then
		pcall(function()
			obj:Destroy()
		end)
	elseif obj:IsA("MeshPart") then
		safeSet(obj, "TextureID", "")
	elseif obj:IsA("SpecialMesh") then
		safeSet(obj, "TextureId", "")
	end
end

local function removeParticlesFrom(obj)
	for _, className in ipairs(ParticleClasses) do
		if obj.ClassName == className then
			pcall(function()
				obj:Destroy()
			end)
			return
		end
	end
end

local function isClothingItem(obj)
	return obj:IsA("Clothing") or obj:IsA("Accessory") or obj:IsA("Hat")
end

local function processInstance(obj)
	if not Settings.EnableFixLag then
		return
	end
	pcall(function()
		if obj:IsA("BasePart") then
			applyLevel1(obj)
			applyLevel2(obj)
		end
		if Settings.RemoveDecals then
			removeDecalsFrom(obj)
		end
		if Settings.RemoveTextures then
			removeTexturesFrom(obj)
		end
		if Settings.RemoveParticles then
			removeParticlesFrom(obj)
		end
	end)
end

local function cleanJunk()
	if not Settings.CleanWorkspace then
		return
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("Sound") and not obj.IsPlaying and obj.TimePosition > 0 then
				obj:Destroy()
			elseif (obj:IsA("Folder") or obj:IsA("Model")) and #obj:GetChildren() == 0 then
				obj:Destroy()
			end
		end)
	end
end

local function scanWorkspace()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		processInstance(obj)
	end
	cleanJunk()
end

local function handleCharacter(character)
	if Settings.RemoveClothing then
		for _, item in ipairs(character:GetChildren()) do
			if isClothingItem(item) then
				pcall(function()
					item:Destroy()
				end)
			end
		end
	end
	for _, part in ipairs(character:GetDescendants()) do
		processInstance(part)
	end
end

local function applyGlobalSettings()
	pcall(function()
		Lighting.GlobalShadows = not Settings.DisableShadows
	end)
	if Settings.LowGraphics then
		pcall(function()
			local gameSettings = UserSettings():GetService("UserGameSettings")
			gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
		end)
		pcall(function()
			Lighting.LightingStyle = Enum.LightingStyle.Soft
		end)
		for _, effect in ipairs(Lighting:GetChildren()) do
			if effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") then
				safeSet(effect, "Enabled", false)
			end
		end
	end
end

local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FixLagBoosterGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 460)
mainFrame.Position = UDim2.new(0, 40, 0, 90)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(64, 166, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -44, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FPS Booster"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -34, 0.5, -13)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -20, 1, -100)
body.Position = UDim2.new(0, 10, 0, 50)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 4
body.ScrollBarImageColor3 = Color3.fromRGB(64, 166, 255)
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = body

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	body.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

local cleanBtn = Instance.new("TextButton")
cleanBtn.Size = UDim2.new(1, -20, 0, 36)
cleanBtn.Position = UDim2.new(0, 10, 1, -46)
cleanBtn.BackgroundColor3 = Color3.fromRGB(64, 166, 255)
cleanBtn.Text = "Clean Now"
cleanBtn.Font = Enum.Font.GothamBold
cleanBtn.TextSize = 14
cleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cleanBtn.AutoButtonColor = false
cleanBtn.Parent = mainFrame

local cleanCorner = Instance.new("UICorner")
cleanCorner.CornerRadius = UDim.new(0, 8)
cleanCorner.Parent = cleanBtn

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 20, 0, 20)
openBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
openBtn.Text = "FPS"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
openBtn.AutoButtonColor = false
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(64, 166, 255)
openStroke.Thickness = 1
openStroke.Parent = openBtn

minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
end)

makeDraggable(mainFrame, titleBar)
makeDraggable(openBtn, openBtn)

cleanBtn.MouseButton1Click:Connect(function()
	scanWorkspace()
	collectgarbage("collect")
end)

local function createToggle(labelText, defaultState, order, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 34)
	row.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = body

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 6)
	rowCorner.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 44, 0, 22)
	btn.Position = UDim2.new(1, -52, 0.5, -11)
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.BackgroundColor3 = defaultState and Color3.fromRGB(64, 166, 255) or Color3.fromRGB(70, 70, 76)
	btn.Parent = row

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = btn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = btn

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local state = defaultState

	btn.MouseButton1Click:Connect(function()
		state = not state
		local knobGoal = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local colorGoal = state and Color3.fromRGB(64, 166, 255) or Color3.fromRGB(70, 70, 76)
		TweenService:Create(knob, TweenInfo.new(0.15), {Position = knobGoal}):Play()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = colorGoal}):Play()
		callback(state)
	end)

	return row
end

createToggle("Enable Fix Lag", Settings.EnableFixLag, 1, function(v)
	Settings.EnableFixLag = v
	if v then
		scanWorkspace()
	end
end)

createToggle("Remove Decals", Settings.RemoveDecals, 2, function(v)
	Settings.RemoveDecals = v
	if v then
		scanWorkspace()
	end
end)

createToggle("Remove Textures", Settings.RemoveTextures, 3, function(v)
	Settings.RemoveTextures = v
	if v then
		scanWorkspace()
	end
end)

createToggle("Remove Particles", Settings.RemoveParticles, 4, function(v)
	Settings.RemoveParticles = v
	if v then
		scanWorkspace()
	end
end)

createToggle("Remove Clothing", Settings.RemoveClothing, 5, function(v)
	Settings.RemoveClothing = v
	if v and LocalPlayer.Character then
		handleCharacter(LocalPlayer.Character)
	end
end)

createToggle("Disable Shadows", Settings.DisableShadows, 6, function(v)
	Settings.DisableShadows = v
	applyGlobalSettings()
end)

createToggle("Low Graphics", Settings.LowGraphics, 7, function(v)
	Settings.LowGraphics = v
	applyGlobalSettings()
end)

createToggle("Clean Workspace", Settings.CleanWorkspace, 8, function(v)
	Settings.CleanWorkspace = v
end)

createToggle("Auto Purge RAM", Settings.AutoPurgeRAM, 9, function(v)
	Settings.AutoPurgeRAM = v
end)

applyGlobalSettings()
scanWorkspace()

if LocalPlayer.Character then
	handleCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(handleCharacter)

Workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		processInstance(obj)
	end)
end)

task.spawn(function()
	while true do
		task.wait(15)
		if Settings.AutoPurgeRAM then
			collectgarbage("collect")
		end
	end
end)
