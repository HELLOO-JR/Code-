local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local settings = {
	aim = {
		enabled = false,
		mode = "attack",
		range = 100,
		smoothness = 10,
		target = "closest",
		part = "Head"
	},
	visuals = {
		box2d = false,
		box3d = false,
		skeleton = false,
		lines = false,
		glow = false,
		recolor = false,
		showName = false,
		showDistance = false,
		showHealth = false,
		showWeapon = false,
		color = Color3.fromRGB(255, 0, 0)
	},
	world = {
		showItems = false,
		showVehicles = false,
		radar = false,
		radarZoom = 50
	},
	performance = {
		shadows = false,
		decal = false,
		texture = false,
		particle = false,
		trail = false,
		beam = false,
		smoke = false,
		fire = false,
		clay = false,
		face = false,
		clothing = false,
		hair = false,
		smoothPlastic = false,
		quality = 1
	}
}

local function loadSettings()
	local success, data = pcall(function()
		return HttpService:JSONDecode(player:GetAttribute("AimSettings") or "{}")
	end)
	if success and data then
		for k, v in pairs(data) do
			if settings[k] then
				for k2, v2 in pairs(v) do
					if settings[k][k2] ~= nil then
						settings[k][k2] = v2
					end
				end
			end
		end
	end
end

local function saveSettings()
	local success, data = pcall(function()
		return HttpService:JSONEncode(settings)
	end)
	if success then
		player:SetAttribute("AimSettings", data)
	end
end

loadSettings()

local function createSafe(func)
	return function(...)
		local success, result = pcall(func, ...)
		if not success then
			warn("Error in safe function:", result)
		end
		return result
	end
end

local function createTween(obj, props, duration)
	local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316044365"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.8, 0, 1, 0)
titleText.Position = UDim2.new(0.1, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Aim Menu"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Center
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local tabs = {}
local tabContents = {}

local tabNames = {"Aim", "Visuals", "World", "Performance"}
local tabData = {
	Aim = {icon = "🎯"},
	Visuals = {icon = "👁"},
	World = {icon = "🌍"},
	Performance = {icon = "⚡"}
}

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 45)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabBar.BackgroundTransparency = 0.1
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, 0, 1, 0)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 0
tabScroll.CanvasSize = UDim2.new(0, #tabNames * 80, 0, 0)
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
tabScroll.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabScroll

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -85)
contentFrame.Position = UDim2.new(0, 0, 0, 85)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 4
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
contentScroll.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentScroll

local dragging = false
local dragStart = nil
local dragOffset = nil

local function onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local pos = input.Position
		local framePos = mainFrame.AbsolutePosition
		local frameSize = mainFrame.AbsoluteSize
		if pos.X >= framePos.X and pos.X <= framePos.X + frameSize.X and
		   pos.Y >= framePos.Y and pos.Y <= framePos.Y + 40 then
			dragging = true
			dragStart = pos
			dragOffset = Vector2.new(pos.X - framePos.X, pos.Y - framePos.Y)
		end
	end
end

local function onInputChanged(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local pos = input.Position
		local newX = pos.X - dragOffset.X
		local newY = pos.Y - dragOffset.Y
		local screenSize = camera.ViewportSize
		newX = math.max(0, math.min(newX, screenSize.X - mainFrame.AbsoluteSize.X))
		newY = math.max(0, math.min(newY, screenSize.Y - mainFrame.AbsoluteSize.Y))
		mainFrame.Position = UDim2.new(0, newX, 0, newY)
	end
end

local function onInputEnded(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

local function createTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 70, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.BackgroundTransparency = 0.2
	btn.Text = tabData[name].icon .. " " .. name
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamMedium
	btn.BorderSizePixel = 0
	btn.Parent = tabScroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 0, 0)
	content.BackgroundTransparency = 1
	content.Visible = false
	content.Parent = contentScroll

	tabs[name] = btn
	tabContents[name] = content

	btn.MouseButton1Click:Connect(function()
		for k, v in pairs(tabContents) do
			v.Visible = false
		end
		for k, v in pairs(tabs) do
			v.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			v.TextColor3 = Color3.fromRGB(200, 200, 210)
		end
		content.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return content
end

local function createToggle(parent, label, settingKey, subKey, order)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 40)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = order or 0
	frame.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.6, 0, 1, 0)
	labelText.Position = UDim2.new(0, 5, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	labelText.TextSize = 14
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = frame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 60, 0, 30)
	toggleBtn.Position = UDim2.new(1, -65, 0, 5)
	toggleBtn.BackgroundColor3 = settings[settingKey][subKey] and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
	toggleBtn.Text = settings[settingKey][subKey] and "ON" or "OFF"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 12
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Parent = frame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleCorner.Parent = toggleBtn

	toggleBtn.MouseButton1Click:Connect(function()
		local newVal = not settings[settingKey][subKey]
		settings[settingKey][subKey] = newVal
		toggleBtn.BackgroundColor3 = newVal and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
		toggleBtn.Text = newVal and "ON" or "OFF"
		saveSettings()
		if settingKey == "performance" then
			applyPerformanceSettings()
		end
	end)

	return frame
end

local function createSlider(parent, label, settingKey, subKey, min, max, step, order)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 60)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = order or 0
	frame.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.7, 0, 0, 20)
	labelText.Position = UDim2.new(0, 5, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	labelText.TextSize = 14
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = frame

	local valueText = Instance.new("TextLabel")
	valueText.Size = UDim2.new(0.3, 0, 0, 20)
	valueText.Position = UDim2.new(0.7, 0, 0, 0)
	valueText.BackgroundTransparency = 1
	valueText.Text = tostring(settings[settingKey][subKey])
	valueText.TextColor3 = Color3.fromRGB(200, 200, 210)
	valueText.TextSize = 14
	valueText.Font = Enum.Font.GothamMedium
	valueText.TextXAlignment = Enum.TextXAlignment.Right
	valueText.Parent = frame

	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, -10, 0, 6)
	slider.Position = UDim2.new(0, 5, 0, 30)
	slider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	slider.BackgroundTransparency = 0.5
	slider.BorderSizePixel = 0
	slider.Parent = frame

	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius = UDim.new(0, 3)
	sliderCorner.Parent = slider

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((settings[settingKey][subKey] - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	fill.BorderSizePixel = 0
	fill.Parent = slider

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = fill

	local dragBtn = Instance.new("TextButton")
	dragBtn.Size = UDim2.new(0, 16, 0, 16)
	dragBtn.Position = UDim2.new((settings[settingKey][subKey] - min) / (max - min), -8, 0, -5)
	dragBtn.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
	dragBtn.Text = ""
	dragBtn.BorderSizePixel = 0
	dragBtn.Parent = slider

	local dragCorner = Instance.new("UICorner")
	dragCorner.CornerRadius = UDim.new(0, 8)
	dragCorner.Parent = dragBtn

	local draggingSlider = false

	dragBtn.MouseButton1Down:Connect(function()
		draggingSlider = true
	end)

	dragBtn.MouseButton1Up:Connect(function()
		draggingSlider = false
	end)

	local function updateSlider(pos)
		if not draggingSlider then return end
		local relX = pos.X - slider.AbsolutePosition.X
		local width = slider.AbsoluteSize.X
		local val = math.clamp(relX / width, 0, 1) * (max - min) + min
		val = math.round(val / step) * step
		val = math.clamp(val, min, max)
		settings[settingKey][subKey] = val
		valueText.Text = tostring(val)
		fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		dragBtn.Position = UDim2.new((val - min) / (max - min), -8, 0, -5)
		saveSettings()
	end

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position)
		end
	end)

	dragBtn.MouseButton1Click:Connect(function()
		-- click to jump
	end)

	return frame
end

local function createDropdown(parent, label, settingKey, subKey, options, order)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 40)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = order or 0
	frame.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.4, 0, 1, 0)
	labelText.Position = UDim2.new(0, 5, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	labelText.TextSize = 14
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = frame

	local dropdownBtn = Instance.new("TextButton")
	dropdownBtn.Size = UDim2.new(0.5, -10, 1, -5)
	dropdownBtn.Position = UDim2.new(0.5, 0, 0, 2)
	dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	dropdownBtn.Text = settings[settingKey][subKey]
	dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	dropdownBtn.TextSize = 13
	dropdownBtn.Font = Enum.Font.GothamMedium
	dropdownBtn.BorderSizePixel = 0
	dropdownBtn.Parent = frame

	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.CornerRadius = UDim.new(0, 6)
	dropdownCorner.Parent = dropdownBtn

	local expanded = false
	local optionFrame = Instance.new("Frame")
	optionFrame.Size = UDim2.new(0.5, -10, 0, 0)
	optionFrame.Position = UDim2.new(0.5, 0, 0, 40)
	optionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	optionFrame.BackgroundTransparency = 0.3
	optionFrame.Visible = false
	optionFrame.Parent = frame

	local optionCorner = Instance.new("UICorner")
	optionCorner.CornerRadius = UDim.new(0, 6)
	optionCorner.Parent = optionFrame

	local optionLayout = Instance.new("UIListLayout")
	optionLayout.FillDirection = Enum.FillDirection.Vertical
	optionLayout.Padding = UDim.new(0, 2)
	optionLayout.Parent = optionFrame

	for _, opt in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		btn.BackgroundTransparency = 0.3
		btn.Text = opt
		btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		btn.TextSize = 13
		btn.Font = Enum.Font.GothamMedium
		btn.BorderSizePixel = 0
		btn.Parent = optionFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			settings[settingKey][subKey] = opt
			dropdownBtn.Text = opt
			expanded = false
			optionFrame.Visible = false
			optionFrame.Size = UDim2.new(0.5, -10, 0, 0)
			saveSettings()
		end)
	end

	dropdownBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		optionFrame.Visible = expanded
		if expanded then
			local count = #options
			optionFrame.Size = UDim2.new(0.5, -10, 0, count * 32 + 5)
		else
			optionFrame.Size = UDim2.new(0.5, -10, 0, 0)
		end
	end)

	return frame
end

local function createColorPicker(parent, label, settingKey, subKey, order)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 40)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = order or 0
	frame.Parent = parent

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0.5, 0, 1, 0)
	labelText.Position = UDim2.new(0, 5, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	labelText.TextSize = 14
	labelText.Font = Enum.Font.GothamMedium
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = frame

	local colorBtn = Instance.new("TextButton")
	colorBtn.Size = UDim2.new(0, 40, 0, 30)
	colorBtn.Position = UDim2.new(1, -45, 0, 5)
	colorBtn.BackgroundColor3 = settings[settingKey][subKey]
	colorBtn.Text = ""
	colorBtn.BorderSizePixel = 0
	colorBtn.Parent = frame

	local colorCorner = Instance.new("UICorner")
	colorCorner.CornerRadius = UDim.new(0, 6)
	colorCorner.Parent = colorBtn

	local colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(255, 0, 255),
		Color3.fromRGB(0, 255, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(128, 128, 128)
	}

	local pickerOpen = false
	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 200, 0, 50)
	pickerFrame.Position = UDim2.new(1, -205, 0, 40)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	pickerFrame.BackgroundTransparency = 0.3
	pickerFrame.Visible = false
	pickerFrame.Parent = frame

	local pickerCorner = Instance.new("UICorner")
	pickerCorner.CornerRadius = UDim.new(0, 6)
	pickerCorner.Parent = pickerFrame

	local pickerLayout = Instance.new("UIListLayout")
	pickerLayout.FillDirection = Enum.FillDirection.Horizontal
	pickerLayout.Padding = UDim.new(0, 4)
	pickerLayout.Parent = pickerFrame

	for _, col in ipairs(colors) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 22, 0, 22)
		btn.BackgroundColor3 = col
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.Parent = pickerFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			settings[settingKey][subKey] = col
			colorBtn.BackgroundColor3 = col
			pickerOpen = false
			pickerFrame.Visible = false
			saveSettings()
		end)
	end

	colorBtn.MouseButton1Click:Connect(function()
		pickerOpen = not pickerOpen
		pickerFrame.Visible = pickerOpen
	end)

	return frame
end

local aimTab = createTab("Aim")
createToggle(aimTab, "Enable Aim", "aim", "enabled", 1)
createDropdown(aimTab, "Mode", "aim", "mode", {"attack", "valid", "silent", "smooth"}, 2)
createSlider(aimTab, "Range", "aim", "range", 10, 360, 5, 3)
createSlider(aimTab, "Smoothness", "aim", "smoothness", 1, 20, 1, 4)
createDropdown(aimTab, "Target", "aim", "target", {"closest", "lowest"}, 5)
createDropdown(aimTab, "Part", "aim", "part", {"Head", "UpperTorso", "Root"}, 6)

local visualsTab = createTab("Visuals")
createToggle(visualsTab, "2D Box", "visuals", "box2d", 1)
createToggle(visualsTab, "3D Box", "visuals", "box3d", 2)
createToggle(visualsTab, "Skeleton", "visuals", "skeleton", 3)
createToggle(visualsTab, "Lines", "visuals", "lines", 4)
createToggle(visualsTab, "Glow", "visuals", "glow", 5)
createToggle(visualsTab, "Recolor", "visuals", "recolor", 6)
createToggle(visualsTab, "Show Name", "visuals", "showName", 7)
createToggle(visualsTab, "Show Distance", "visuals", "showDistance", 8)
createToggle(visualsTab, "Show Health", "visuals", "showHealth", 9)
createToggle(visualsTab, "Show Weapon", "visuals", "showWeapon", 10)
createColorPicker(visualsTab, "Color", "visuals", "color", 11)

local worldTab = createTab("World")
createToggle(worldTab, "Show Items", "world", "showItems", 1)
createToggle(worldTab, "Show Vehicles", "world", "showVehicles", 2)
createToggle(worldTab, "Radar", "world", "radar", 3)
createSlider(worldTab, "Radar Zoom", "world", "radarZoom", 20, 200, 5, 4)

local perfTab = createTab("Performance")
createToggle(perfTab, "Disable Shadows", "performance", "shadows", 1)
createToggle(perfTab, "Remove Decals", "performance", "decal", 2)
createToggle(perfTab, "Remove Textures", "performance", "texture", 3)
createToggle(perfTab, "Remove Particles", "performance", "particle", 4)
createToggle(perfTab, "Remove Trails", "performance", "trail", 5)
createToggle(perfTab, "Remove Beams", "performance", "beam", 6)
createToggle(perfTab, "Remove Smoke", "performance", "smoke", 7)
createToggle(perfTab, "Remove Fire", "performance", "fire", 8)
createToggle(perfTab, "Clay Mode", "performance", "clay", 9)
createToggle(perfTab, "Remove Faces", "performance", "face", 10)
createToggle(perfTab, "Remove Clothing", "performance", "clothing", 11)
createToggle(perfTab, "Remove Hair", "performance", "hair", 12)
createToggle(perfTab, "Smooth Plastic", "performance", "smoothPlastic", 13)
createSlider(perfTab, "Quality Level", "performance", "quality", 1, 10, 1, 14)

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 50, 0, 50)
menuBtn.Position = UDim2.new(0, 10, 0, 10)
menuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menuBtn.BackgroundTransparency = 0.3
menuBtn.Text = "⚙"
menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtn.TextSize = 24
menuBtn.Font = Enum.Font.GothamBold
menuBtn.BorderSizePixel = 0
menuBtn.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuBtn

local menuOpen = false

menuBtn.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	mainFrame.Visible = menuOpen
	if menuOpen then
		createTween(mainFrame, {BackgroundTransparency = 0.05}, 0.2)
	else
		createTween(mainFrame, {BackgroundTransparency = 0.05}, 0.2)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	menuOpen = false
	mainFrame.Visible = false
end)

local function applyPerformanceSettings()
	local success, err = pcall(function()
		if settings.performance.shadows then
			Lighting.ShadowSoftness = 0
			Lighting.ShadowIntensity = 0
			Lighting.ShadowColor = Color3.fromRGB(0, 0, 0)
			Lighting.GlobalShadows = false
		end

		if settings.performance.quality then
			local qual = settings.performance.quality
			Lighting.Brightness = math.max(0.5, 3 - qual * 0.2)
			Lighting.Ambient = Color3.fromRGB(128 + qual * 10, 128 + qual * 10, 128 + qual * 10)
			Lighting.OutdoorAmbient = Color3.fromRGB(128 + qual * 10, 128 + qual * 10, 128 + qual * 10)
		end

		for _, obj in ipairs(Workspace:GetDescendants()) do
			if settings.performance.decal and obj:IsA("Decal") then
				obj:Destroy()
			end
			if settings.performance.texture and obj:IsA("Texture") then
				obj:Destroy()
			end
			if settings.performance.particle and obj:IsA("ParticleEmitter") then
				obj.Enabled = false
			end
			if settings.performance.trail and obj:IsA("Trail") then
				obj:Destroy()
			end
			if settings.performance.beam and obj:IsA("Beam") then
				obj:Destroy()
			end
			if settings.performance.smoke and obj:IsA("Smoke") then
				obj:Destroy()
			end
			if settings.performance.fire and obj:IsA("Fire") then
				obj:Destroy()
			end
			if settings.performance.clay and obj:IsA("BasePart") then
				obj.Material = Enum.Material.SmoothPlastic
			end
			if settings.performance.smoothPlastic and obj:IsA("BasePart") then
				obj.Material = Enum.Material.SmoothPlastic
			end
			if settings.performance.face and obj:IsA("Character") then
				-- Face removal
			end
			if settings.performance.clothing and obj:IsA("Clothing") then
				obj:Destroy()
			end
			if settings.performance.hair and obj:IsA("Accessory") then
				obj:Destroy()
			end
		end
	end)
	if not success then
		warn("Performance apply error:", err)
	end
end

applyPerformanceSettings()

local function cleanupMemory()
	local success, err = pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name == "Part" and not obj.Parent:IsA("Model") then
				obj:Destroy()
			end
		end
		collectgarbage("collect")
	end)
	if not success then
		warn("Cleanup error:", err)
	end
end

local function findTargets()
	local targets = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character.PrimaryPart then
			local char = plr.Character
			local dist = (char.PrimaryPart.Position - camera.CFrame.Position).Magnitude
			if dist <= settings.aim.range then
				table.insert(targets, {
					player = plr,
					character = char,
					distance = dist,
					health = plr.Character.Humanoid and plr.Character.Humanoid.Health or 100
				})
			end
		end
	end
	return targets
end

local function getTarget()
	local targets = findTargets()
	if #targets == 0 then return nil end
	if settings.aim.target == "closest" then
		table.sort(targets, function(a, b) return a.distance < b.distance end)
	else
		table.sort(targets, function(a, b) return a.health < b.health end)
	end
	return targets[1]
end

local function aimAtTarget(target)
	if not target then return end
	local part = target.character:FindFirstChild(settings.aim.part)
	if not part then
		part = target.character.PrimaryPart
	end
	if not part then return end
	local pos = part.Position
	local current = camera.CFrame
	local targetCF = CFrame.new(current.Position, pos)
	local smooth = settings.aim.smoothness / 20
	local lerpCF = current:Lerp(targetCF, smooth)
	camera.CFrame = lerpCF
end

RunService.Heartbeat:Connect(function()
	if settings.aim.enabled then
		local target = getTarget()
		if target then
			aimAtTarget(target)
			if settings.aim.mode == "attack" then
				local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
				if tool then
					tool:Activate()
				end
			end
		end
	end
end)

local function clearDrawingObjects()
	for _, obj in ipairs(screenGui:GetDescendants()) do
		if obj:IsA("Frame") and obj.Name == "DrawObject" then
			obj:Destroy()
		end
	end
end

local function drawVisuals()
	clearDrawingObjects()
	if not settings.visuals.box2d and not settings.visuals.box3d and not settings.visuals.skeleton and
	   not settings.visuals.lines and not settings.visuals.glow and not settings.visuals.recolor and
	   not settings.visuals.showName and not settings.visuals.showDistance and not settings.visuals.showHealth and
	   not settings.visuals.showWeapon then
		return
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character.PrimaryPart then
			local char = plr.Character
			local dist = (char.PrimaryPart.Position - camera.CFrame.Position).Magnitude
			if dist <= 5 then
				local pos, onScreen = camera:WorldToViewportPoint(char.PrimaryPart.Position)
				if onScreen then
					local teamColor = plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(200, 200, 200)
					local isEnemy = plr.Team ~= player.Team
					local color = isEnemy and settings.visuals.color or Color3.fromRGB(0, 255, 0)

					if settings.visuals.box2d then
						local box = Instance.new("Frame")
						box.Name = "DrawObject"
						box.Size = UDim2.new(0, 50, 0, 80)
						box.Position = UDim2.new(0, pos.X - 25, 0, pos.Y - 40)
						box.BackgroundTransparency = 0.7
						box.BackgroundColor3 = color
						box.BorderSizePixel = 1
						box.BorderColor3 = color
						box.Parent = screenGui
					end

					if settings.visuals.showName then
						local label = Instance.new("TextLabel")
						label.Name = "DrawObject"
						label.Size = UDim2.new(0, 100, 0, 20)
						label.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 50)
						label.BackgroundTransparency = 1
						label.Text = plr.Name
						label.TextColor3 = color
						label.TextSize = 14
						label.Font = Enum.Font.GothamMedium
						label.Parent = screenGui
					end

					if settings.visuals.showHealth and char:FindFirstChild("Humanoid") then
						local health = char.Humanoid.Health
						local label = Instance.new("TextLabel")
						label.Name = "DrawObject"
						label.Size = UDim2.new(0, 80, 0, 20)
						label.Position = UDim2.new(0, pos.X - 40, 0, pos.Y - 30)
						label.BackgroundTransparency = 1
						label.Text = "❤ " .. math.floor(health)
						label.TextColor3 = health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
						label.TextSize = 12
						label.Font = Enum.Font.GothamMedium
						label.Parent = screenGui
					end
				end
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	drawVisuals()
end)

local function createRadar()
	local radar = Instance.new("Frame")
	radar.Size = UDim2.new(0, 120, 0, 120)
	radar.Position = UDim2.new(1, -135, 1, -135)
	radar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	radar.BackgroundTransparency = 0.3
	radar.BorderSizePixel = 1
	radar.BorderColor3 = Color3.fromRGB(60, 60, 70)
	radar.Parent = screenGui

	local radarCorner = Instance.new("UICorner")
	radarCorner.CornerRadius = UDim.new(0, 8)
	radarCorner.Parent = radar

	local center = Instance.new("Frame")
	center.Size = UDim2.new(0, 4, 0, 4)
	center.Position = UDim2.new(0.5, -2, 0.5, -2)
	center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	center.BorderSizePixel = 0
	center.Parent = radar

	local centerCorner = Instance.new("UICorner")
	centerCorner.CornerRadius = UDim.new(0, 2)
	centerCorner.Parent = center

	local dots = {}

	local function updateRadar()
		if not settings.world.radar then
			radar.Visible = false
			return
		end
		radar.Visible = true
		for _, dot in ipairs(dots) do
			dot:Destroy()
		end
		dots = {}

		local zoom = settings.world.radarZoom / 50
		local centerPos = camera.CFrame.Position
		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character.PrimaryPart then
				local char = plr.Character
				local pos = char.PrimaryPart.Position
				local rel = pos - centerPos
				local x = rel:Dot(right) * zoom
				local z = rel:Dot(forward) * zoom
				local dist = (pos - centerPos).Magnitude
				if dist <= 100 then
					local dot = Instance.new("Frame")
					dot.Size = UDim2.new(0, 6, 0, 6)
					dot.Position = UDim2.new(0.5, x - 3, 0.5, z - 3)
					local isEnemy = plr.Team ~= player.Team
					dot.BackgroundColor3 = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
					dot.BorderSizePixel = 0
					dot.Parent = radar

					local dotCorner = Instance.new("UICorner")
					dotCorner.CornerRadius = UDim.new(0, 3)
					dotCorner.Parent = dot
					table.insert(dots, dot)
				end
			end
		end
	end

	RunService.Heartbeat:Connect(updateRadar)
end

createRadar()

local function autoCleanup()
	while true do
		task.wait(300)
		cleanupMemory()
		applyPerformanceSettings()
	end
end

task.spawn(autoCleanup)

local function checkWorldObjects()
	if not settings.world.showItems and not settings.world.showVehicles then
		return
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if settings.world.showItems and obj:IsA("Tool") and obj.Parent ~= player.Character then
			local pos = obj.PrimaryPart and obj.PrimaryPart.Position or obj.Position
			local dist = (pos - camera.CFrame.Position).Magnitude
			if dist <= 20 then
				local label = Instance.new("BillboardGui")
				label.Adornee = obj
				label.Size = UDim2.new(0, 100, 0, 30)
				label.Parent = obj

				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.Text = "📦 " .. obj.Name
				text.TextColor3 = Color3.fromRGB(255, 255, 150)
				text.TextSize = 12
				text.Font = Enum.Font.GothamMedium
				text.Parent = label
			end
		end
		if settings.world.showVehicles and obj:IsA("VehicleSeat") then
			local parent = obj.Parent
			if parent and parent:IsA("Model") then
				local pos = parent.PrimaryPart and parent.PrimaryPart.Position or obj.Position
				local dist = (pos - camera.CFrame.Position).Magnitude
				if dist <= 30 then
					local label = Instance.new("BillboardGui")
					label.Adornee = parent
					label.Size = UDim2.new(0, 120, 0, 30)
					label.Parent = parent

					local text = Instance.new("TextLabel")
					text.Size = UDim2.new(1, 0, 1, 0)
					text.BackgroundTransparency = 1
					text.Text = "🚗 " .. parent.Name
					text.TextColor3 = Color3.fromRGB(150, 200, 255)
					text.TextSize = 12
					text.Font = Enum.Font.GothamMedium
					text.Parent = label
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(checkWorldObjects)

local function handleResize()
	local screenSize = camera.ViewportSize
	local width = math.min(screenSize.X * 0.8, 400)
	local height = math.min(screenSize.Y * 0.8, 550)
	mainFrame.Size = UDim2.new(0, width, 0, height)
	mainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(handleResize)
handleResize()

for _, tab in ipairs(tabNames) do
	local content = tabContents[tab]
	if content then
		local size = 0
		for _, child in ipairs(content:GetChildren()) do
			if child:IsA("Frame") then
				size = size + child.Size.Y.Offset + 8
			end
		end
		content.Size = UDim2.new(1, 0, 0, size + 20)
	end
end

tabContents.Aim.Visible = true
tabs.Aim.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
tabs.Aim.TextColor3 = Color3.fromRGB(255, 255, 255)

return {
	settings = settings,
	applyPerformance = applyPerformanceSettings,
	cleanup = cleanupMemory
}