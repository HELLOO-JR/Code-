local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Settings = {
	Aim = {
		Enabled = false,
		Mode = "attack",
		Range = 100,
		Smoothness = 10,
		Target = "closest",
		Part = "Head"
	},
	Visuals = {
		Box2D = false,
		Box3D = false,
		Skeleton = false,
		Lines = false,
		Glow = false,
		Recolor = false,
		ShowName = false,
		ShowDistance = false,
		ShowHealth = false,
		ShowWeapon = false,
		Color = Color3.fromRGB(255, 0, 0)
	},
	World = {
		ShowItems = false,
		ShowVehicles = false,
		Radar = false,
		RadarZoom = 50
	},
	Performance = {
		Shadows = false,
		Decal = false,
		Texture = false,
		Particle = false,
		Trail = false,
		Beam = false,
		Smoke = false,
		Fire = false,
		Clay = false,
		Face = false,
		Clothing = false,
		Hair = false,
		SmoothPlastic = false,
		Quality = 1
	}
}

local function LoadSettings()
	local Success, Data = pcall(function()
		return HttpService:JSONDecode(Player:GetAttribute("AimSettings") or "{}")
	end)
	if Success and Data then
		for Key, Value in pairs(Data) do
			if Settings[Key] then
				for SubKey, SubValue in pairs(Value) do
					if Settings[Key][SubKey] ~= nil then
						Settings[Key][SubKey] = SubValue
					end
				end
			end
		end
	end
end

local function SaveSettings()
	local Success, Data = pcall(function()
		return HttpService:JSONEncode(Settings)
	end)
	if Success then
		Player:SetAttribute("AimSettings", Data)
	end
end

LoadSettings()

local function CreateSafe(Func)
	return function(...)
		local Success, Result = pcall(Func, ...)
		if not Success then
			warn("Error:", Result)
		end
		return Result
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.8, 0, 1, 0)
TitleText.Position = UDim2.new(0.1, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Delta Menu"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Center
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local Tabs = {}
local TabContents = {}
local TabNames = {"Aim", "Visuals", "World", "Performance"}
local TabData = {
	Aim = {Icon = "🎯"},
	Visuals = {Icon = "👁"},
	World = {Icon = "🌍"},
	Performance = {Icon = "⚡"}
}

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 45)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabBar.BackgroundTransparency = 0.1
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, 0, 1, 0)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 0
TabScroll.CanvasSize = UDim2.new(0, #TabNames * 80, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TabScroll.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabScroll

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -85)
ContentFrame.Position = UDim2.new(0, 0, 0, 85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, 0)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ContentScroll.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

local Dragging = false
local DragStart = nil
local DragOffset = nil

local function OnInputBegan(Input)
	if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
		local Pos = Input.Position
		local FramePos = MainFrame.AbsolutePosition
		local FrameSize = MainFrame.AbsoluteSize
		if Pos.X >= FramePos.X and Pos.X <= FramePos.X + FrameSize.X and
		   Pos.Y >= FramePos.Y and Pos.Y <= FramePos.Y + 40 then
			Dragging = true
			DragStart = Pos
			DragOffset = Vector2.new(Pos.X - FramePos.X, Pos.Y - FramePos.Y)
		end
	end
end

local function OnInputChanged(Input)
	if Dragging and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseMovement) then
		local Pos = Input.Position
		local NewX = Pos.X - DragOffset.X
		local NewY = Pos.Y - DragOffset.Y
		local ScreenSize = Camera.ViewportSize
		NewX = math.max(0, math.min(NewX, ScreenSize.X - MainFrame.AbsoluteSize.X))
		NewY = math.max(0, math.min(NewY, ScreenSize.Y - MainFrame.AbsoluteSize.Y))
		MainFrame.Position = UDim2.new(0, NewX, 0, NewY)
	end
end

local function OnInputEnded(Input)
	if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputChanged:Connect(OnInputChanged)
UserInputService.InputEnded:Connect(OnInputEnded)

local function CreateTab(Name)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0, 70, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	Btn.BackgroundTransparency = 0.2
	Btn.Text = TabData[Name].Icon .. " " .. Name
	Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	Btn.TextSize = 14
	Btn.Font = Enum.Font.GothamMedium
	Btn.BorderSizePixel = 0
	Btn.Parent = TabScroll

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 6)
	BtnCorner.Parent = Btn

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, 0, 0, 0)
	Content.BackgroundTransparency = 1
	Content.Visible = false
	Content.Parent = ContentScroll

	Tabs[Name] = Btn
	TabContents[Name] = Content

	Btn.MouseButton1Click:Connect(function()
		for Key, Value in pairs(TabContents) do
			Value.Visible = false
		end
		for Key, Value in pairs(Tabs) do
			Value.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Value.TextColor3 = Color3.fromRGB(200, 200, 210)
		end
		Content.Visible = true
		Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return Content
end

local function CreateToggle(Parent, Label, SettingKey, SubKey, Order)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -20, 0, 40)
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Order or 0
	Frame.Parent = Parent

	local LabelText = Instance.new("TextLabel")
	LabelText.Size = UDim2.new(0.6, 0, 1, 0)
	LabelText.Position = UDim2.new(0, 5, 0, 0)
	LabelText.BackgroundTransparency = 1
	LabelText.Text = Label
	LabelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	LabelText.TextSize = 14
	LabelText.Font = Enum.Font.GothamMedium
	LabelText.TextXAlignment = Enum.TextXAlignment.Left
	LabelText.Parent = Frame

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(0, 60, 0, 30)
	ToggleBtn.Position = UDim2.new(1, -65, 0, 5)
	ToggleBtn.BackgroundColor3 = Settings[SettingKey][SubKey] and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
	ToggleBtn.Text = Settings[SettingKey][SubKey] and "ON" or "OFF"
	ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToggleBtn.TextSize = 12
	ToggleBtn.Font = Enum.Font.GothamBold
	ToggleBtn.BorderSizePixel = 0
	ToggleBtn.Parent = Frame

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 6)
	ToggleCorner.Parent = ToggleBtn

	ToggleBtn.MouseButton1Click:Connect(function()
		local NewVal = not Settings[SettingKey][SubKey]
		Settings[SettingKey][SubKey] = NewVal
		ToggleBtn.BackgroundColor3 = NewVal and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
		ToggleBtn.Text = NewVal and "ON" or "OFF"
		SaveSettings()
		if SettingKey == "Performance" then
			ApplyPerformanceSettings()
		end
	end)

	return Frame
end

local function CreateSlider(Parent, Label, SettingKey, SubKey, Min, Max, Step, Order)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -20, 0, 60)
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Order or 0
	Frame.Parent = Parent

	local LabelText = Instance.new("TextLabel")
	LabelText.Size = UDim2.new(0.7, 0, 0, 20)
	LabelText.Position = UDim2.new(0, 5, 0, 0)
	LabelText.BackgroundTransparency = 1
	LabelText.Text = Label
	LabelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	LabelText.TextSize = 14
	LabelText.Font = Enum.Font.GothamMedium
	LabelText.TextXAlignment = Enum.TextXAlignment.Left
	LabelText.Parent = Frame

	local ValueText = Instance.new("TextLabel")
	ValueText.Size = UDim2.new(0.3, 0, 0, 20)
	ValueText.Position = UDim2.new(0.7, 0, 0, 0)
	ValueText.BackgroundTransparency = 1
	ValueText.Text = tostring(Settings[SettingKey][SubKey])
	ValueText.TextColor3 = Color3.fromRGB(200, 200, 210)
	ValueText.TextSize = 14
	ValueText.Font = Enum.Font.GothamMedium
	ValueText.TextXAlignment = Enum.TextXAlignment.Right
	ValueText.Parent = Frame

	local Slider = Instance.new("Frame")
	Slider.Size = UDim2.new(1, -10, 0, 6)
	Slider.Position = UDim2.new(0, 5, 0, 30)
	Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	Slider.BackgroundTransparency = 0.5
	Slider.BorderSizePixel = 0
	Slider.Parent = Frame

	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 3)
	SliderCorner.Parent = Slider

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((Settings[SettingKey][SubKey] - Min) / (Max - Min), 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	Fill.BorderSizePixel = 0
	Fill.Parent = Slider

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(0, 3)
	FillCorner.Parent = Fill

	local DragBtn = Instance.new("TextButton")
	DragBtn.Size = UDim2.new(0, 16, 0, 16)
	DragBtn.Position = UDim2.new((Settings[SettingKey][SubKey] - Min) / (Max - Min), -8, 0, -5)
	DragBtn.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
	DragBtn.Text = ""
	DragBtn.BorderSizePixel = 0
	DragBtn.Parent = Slider

	local DragCorner = Instance.new("UICorner")
	DragCorner.CornerRadius = UDim.new(0, 8)
	DragCorner.Parent = DragBtn

	local DraggingSlider = false

	DragBtn.MouseButton1Down:Connect(function()
		DraggingSlider = true
	end)

	DragBtn.MouseButton1Up:Connect(function()
		DraggingSlider = false
	end)

	local function UpdateSlider(Pos)
		if not DraggingSlider then return end
		local RelX = Pos.X - Slider.AbsolutePosition.X
		local Width = Slider.AbsoluteSize.X
		local Val = math.clamp(RelX / Width, 0, 1) * (Max - Min) + Min
		Val = math.round(Val / Step) * Step
		Val = math.clamp(Val, Min, Max)
		Settings[SettingKey][SubKey] = Val
		ValueText.Text = tostring(Val)
		Fill.Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)
		DragBtn.Position = UDim2.new((Val - Min) / (Max - Min), -8, 0, -5)
		SaveSettings()
	end

	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateSlider(Input.Position)
		end
	end)

	return Frame
end

local function CreateDropdown(Parent, Label, SettingKey, SubKey, Options, Order)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -20, 0, 40)
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Order or 0
	Frame.Parent = Parent

	local LabelText = Instance.new("TextLabel")
	LabelText.Size = UDim2.new(0.4, 0, 1, 0)
	LabelText.Position = UDim2.new(0, 5, 0, 0)
	LabelText.BackgroundTransparency = 1
	LabelText.Text = Label
	LabelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	LabelText.TextSize = 14
	LabelText.Font = Enum.Font.GothamMedium
	LabelText.TextXAlignment = Enum.TextXAlignment.Left
	LabelText.Parent = Frame

	local DropdownBtn = Instance.new("TextButton")
	DropdownBtn.Size = UDim2.new(0.5, -10, 1, -5)
	DropdownBtn.Position = UDim2.new(0.5, 0, 0, 2)
	DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	DropdownBtn.Text = Settings[SettingKey][SubKey]
	DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	DropdownBtn.TextSize = 13
	DropdownBtn.Font = Enum.Font.GothamMedium
	DropdownBtn.BorderSizePixel = 0
	DropdownBtn.Parent = Frame

	local DropdownCorner = Instance.new("UICorner")
	DropdownCorner.CornerRadius = UDim.new(0, 6)
	DropdownCorner.Parent = DropdownBtn

	local Expanded = false
	local OptionFrame = Instance.new("Frame")
	OptionFrame.Size = UDim2.new(0.5, -10, 0, 0)
	OptionFrame.Position = UDim2.new(0.5, 0, 0, 40)
	OptionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	OptionFrame.BackgroundTransparency = 0.3
	OptionFrame.Visible = false
	OptionFrame.Parent = Frame

	local OptionCorner = Instance.new("UICorner")
	OptionCorner.CornerRadius = UDim.new(0, 6)
	OptionCorner.Parent = OptionFrame

	local OptionLayout = Instance.new("UIListLayout")
	OptionLayout.FillDirection = Enum.FillDirection.Vertical
	OptionLayout.Padding = UDim.new(0, 2)
	OptionLayout.Parent = OptionFrame

	for _, Opt in ipairs(Options) do
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 30)
		Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		Btn.BackgroundTransparency = 0.3
		Btn.Text = Opt
		Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		Btn.TextSize = 13
		Btn.Font = Enum.Font.GothamMedium
		Btn.BorderSizePixel = 0
		Btn.Parent = OptionFrame

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 4)
		BtnCorner.Parent = Btn

		Btn.MouseButton1Click:Connect(function()
			Settings[SettingKey][SubKey] = Opt
			DropdownBtn.Text = Opt
			Expanded = false
			OptionFrame.Visible = false
			OptionFrame.Size = UDim2.new(0.5, -10, 0, 0)
			SaveSettings()
		end)
	end

	DropdownBtn.MouseButton1Click:Connect(function()
		Expanded = not Expanded
		OptionFrame.Visible = Expanded
		if Expanded then
			local Count = #Options
			OptionFrame.Size = UDim2.new(0.5, -10, 0, Count * 32 + 5)
		else
			OptionFrame.Size = UDim2.new(0.5, -10, 0, 0)
		end
	end)

	return Frame
end

local function CreateColorPicker(Parent, Label, SettingKey, SubKey, Order)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -20, 0, 40)
	Frame.BackgroundTransparency = 1
	Frame.LayoutOrder = Order or 0
	Frame.Parent = Parent

	local LabelText = Instance.new("TextLabel")
	LabelText.Size = UDim2.new(0.5, 0, 1, 0)
	LabelText.Position = UDim2.new(0, 5, 0, 0)
	LabelText.BackgroundTransparency = 1
	LabelText.Text = Label
	LabelText.TextColor3 = Color3.fromRGB(220, 220, 230)
	LabelText.TextSize = 14
	LabelText.Font = Enum.Font.GothamMedium
	LabelText.TextXAlignment = Enum.TextXAlignment.Left
	LabelText.Parent = Frame

	local ColorBtn = Instance.new("TextButton")
	ColorBtn.Size = UDim2.new(0, 40, 0, 30)
	ColorBtn.Position = UDim2.new(1, -45, 0, 5)
	ColorBtn.BackgroundColor3 = Settings[SettingKey][SubKey]
	ColorBtn.Text = ""
	ColorBtn.BorderSizePixel = 0
	ColorBtn.Parent = Frame

	local ColorCorner = Instance.new("UICorner")
	ColorCorner.CornerRadius = UDim.new(0, 6)
	ColorCorner.Parent = ColorBtn

	local Colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(255, 0, 255),
		Color3.fromRGB(0, 255, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(128, 128, 128)
	}

	local PickerOpen = false
	local PickerFrame = Instance.new("Frame")
	PickerFrame.Size = UDim2.new(0, 200, 0, 50)
	PickerFrame.Position = UDim2.new(1, -205, 0, 40)
	PickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	PickerFrame.BackgroundTransparency = 0.3
	PickerFrame.Visible = false
	PickerFrame.Parent = Frame

	local PickerCorner = Instance.new("UICorner")
	PickerCorner.CornerRadius = UDim.new(0, 6)
	PickerCorner.Parent = PickerFrame

	local PickerLayout = Instance.new("UIListLayout")
	PickerLayout.FillDirection = Enum.FillDirection.Horizontal
	PickerLayout.Padding = UDim.new(0, 4)
	PickerLayout.Parent = PickerFrame

	for _, Col in ipairs(Colors) do
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(0, 22, 0, 22)
		Btn.BackgroundColor3 = Col
		Btn.Text = ""
		Btn.BorderSizePixel = 0
		Btn.Parent = PickerFrame

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 4)
		BtnCorner.Parent = Btn

		Btn.MouseButton1Click:Connect(function()
			Settings[SettingKey][SubKey] = Col
			ColorBtn.BackgroundColor3 = Col
			PickerOpen = false
			PickerFrame.Visible = false
			SaveSettings()
		end)
	end

	ColorBtn.MouseButton1Click:Connect(function()
		PickerOpen = not PickerOpen
		PickerFrame.Visible = PickerOpen
	end)

	return Frame
end

local AimTab = CreateTab("Aim")
CreateToggle(AimTab, "Enable Aim", "Aim", "Enabled", 1)
CreateDropdown(AimTab, "Mode", "Aim", "Mode", {"attack", "valid", "silent", "smooth"}, 2)
CreateSlider(AimTab, "Range", "Aim", "Range", 10, 360, 5, 3)
CreateSlider(AimTab, "Smoothness", "Aim", "Smoothness", 1, 20, 1, 4)
CreateDropdown(AimTab, "Target", "Aim", "Target", {"closest", "lowest"}, 5)
CreateDropdown(AimTab, "Part", "Aim", "Part", {"Head", "UpperTorso", "Root"}, 6)

local VisualsTab = CreateTab("Visuals")
CreateToggle(VisualsTab, "2D Box", "Visuals", "Box2D", 1)
CreateToggle(VisualsTab, "3D Box", "Visuals", "Box3D", 2)
CreateToggle(VisualsTab, "Skeleton", "Visuals", "Skeleton", 3)
CreateToggle(VisualsTab, "Lines", "Visuals", "Lines", 4)
CreateToggle(VisualsTab, "Glow", "Visuals", "Glow", 5)
CreateToggle(VisualsTab, "Recolor", "Visuals", "Recolor", 6)
CreateToggle(VisualsTab, "Show Name", "Visuals", "ShowName", 7)
CreateToggle(VisualsTab, "Show Distance", "Visuals", "ShowDistance", 8)
CreateToggle(VisualsTab, "Show Health", "Visuals", "ShowHealth", 9)
CreateToggle(VisualsTab, "Show Weapon", "Visuals", "ShowWeapon", 10)
CreateColorPicker(VisualsTab, "Color", "Visuals", "Color", 11)

local WorldTab = CreateTab("World")
CreateToggle(WorldTab, "Show Items", "World", "ShowItems", 1)
CreateToggle(WorldTab, "Show Vehicles", "World", "ShowVehicles", 2)
CreateToggle(WorldTab, "Radar", "World", "Radar", 3)
CreateSlider(WorldTab, "Radar Zoom", "World", "RadarZoom", 20, 200, 5, 4)

local PerfTab = CreateTab("Performance")
CreateToggle(PerfTab, "Disable Shadows", "Performance", "Shadows", 1)
CreateToggle(PerfTab, "Remove Decals", "Performance", "Decal", 2)
CreateToggle(PerfTab, "Remove Textures", "Performance", "Texture", 3)
CreateToggle(PerfTab, "Remove Particles", "Performance", "Particle", 4)
CreateToggle(PerfTab, "Remove Trails", "Performance", "Trail", 5)
CreateToggle(PerfTab, "Remove Beams", "Performance", "Beam", 6)
CreateToggle(PerfTab, "Remove Smoke", "Performance", "Smoke", 7)
CreateToggle(PerfTab, "Remove Fire", "Performance", "Fire", 8)
CreateToggle(PerfTab, "Clay Mode", "Performance", "Clay", 9)
CreateToggle(PerfTab, "Remove Faces", "Performance", "Face", 10)
CreateToggle(PerfTab, "Remove Clothing", "Performance", "Clothing", 11)
CreateToggle(PerfTab, "Remove Hair", "Performance", "Hair", 12)
CreateToggle(PerfTab, "Smooth Plastic", "Performance", "SmoothPlastic", 13)
CreateSlider(PerfTab, "Quality Level", "Performance", "Quality", 1, 10, 1, 14)

local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 10, 0, 10)
MenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MenuBtn.BackgroundTransparency = 0.3
MenuBtn.Text = "Δ"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.TextSize = 24
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.BorderSizePixel = 0
MenuBtn.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MenuBtn

local MenuOpen = false

MenuBtn.MouseButton1Click:Connect(function()
	MenuOpen = not MenuOpen
	MainFrame.Visible = MenuOpen
end)

CloseBtn.MouseButton1Click:Connect(function()
	MenuOpen = false
	MainFrame.Visible = false
end)

local function ApplyPerformanceSettings()
	local Success, Err = pcall(function()
		if Settings.Performance.Shadows then
			Lighting.ShadowSoftness = 0
			Lighting.ShadowIntensity = 0
			Lighting.ShadowColor = Color3.fromRGB(0, 0, 0)
			Lighting.GlobalShadows = false
		end

		if Settings.Performance.Quality then
			local Qual = Settings.Performance.Quality
			Lighting.Brightness = math.max(0.5, 3 - Qual * 0.2)
			Lighting.Ambient = Color3.fromRGB(128 + Qual * 10, 128 + Qual * 10, 128 + Qual * 10)
			Lighting.OutdoorAmbient = Color3.fromRGB(128 + Qual * 10, 128 + Qual * 10, 128 + Qual * 10)
		end

		for _, Obj in ipairs(Workspace:GetDescendants()) do
			if Settings.Performance.Decal and Obj:IsA("Decal") then
				Obj:Destroy()
			end
			if Settings.Performance.Texture and Obj:IsA("Texture") then
				Obj:Destroy()
			end
			if Settings.Performance.Particle and Obj:IsA("ParticleEmitter") then
				Obj.Enabled = false
			end
			if Settings.Performance.Trail and Obj:IsA("Trail") then
				Obj:Destroy()
			end
			if Settings.Performance.Beam and Obj:IsA("Beam") then
				Obj:Destroy()
			end
			if Settings.Performance.Smoke and Obj:IsA("Smoke") then
				Obj:Destroy()
			end
			if Settings.Performance.Fire and Obj:IsA("Fire") then
				Obj:Destroy()
			end
			if Settings.Performance.Clay and Obj:IsA("BasePart") then
				Obj.Material = Enum.Material.SmoothPlastic
			end
			if Settings.Performance.SmoothPlastic and Obj:IsA("BasePart") then
				Obj.Material = Enum.Material.SmoothPlastic
			end
			if Settings.Performance.Clothing and Obj:IsA("Clothing") then
				Obj:Destroy()
			end
			if Settings.Performance.Hair and Obj:IsA("Accessory") then
				Obj:Destroy()
			end
		end
	end)
	if not Success then
		warn("Performance error:", Err)
	end
end

ApplyPerformanceSettings()

local function CleanupMemory()
	local Success, Err = pcall(function()
		for _, Obj in ipairs(Workspace:GetDescendants()) do
			if Obj:IsA("BasePart") and Obj.Name == "Part" and not Obj.Parent:IsA("Model") then
				Obj:Destroy()
			end
		end
		collectgarbage("collect")
	end)
	if not Success then
		warn("Cleanup error:", Err)
	end
end

local function FindTargets()
	local Targets = {}
	for _, Plr in ipairs(Players:GetPlayers()) do
		if Plr ~= Player and Plr.Character and Plr.Character.PrimaryPart then
			local Char = Plr.Character
			local Dist = (Char.PrimaryPart.Position - Camera.CFrame.Position).Magnitude
			if Dist <= Settings.Aim.Range then
				table.insert(Targets, {
					Player = Plr,
					Character = Char,
					Distance = Dist,
					Health = Plr.Character.Humanoid and Plr.Character.Humanoid.Health or 100
				})
			end
		end
	end
	return Targets
end

local function GetTarget()
	local Targets = FindTargets()
	if #Targets == 0 then return nil end
	if Settings.Aim.Target == "closest" then
		table.sort(Targets, function(A, B) return A.Distance < B.Distance end)
	else
		table.sort(Targets, function(A, B) return A.Health < B.Health end)
	end
	return Targets[1]
endlocal function AimAtTarget(Target)
	if not Target then return end
	local Part = Target.Character:FindFirstChild(Settings.Aim.Part)
	if not Part then
		Part = Target.Character.PrimaryPart
	end
	if not Part then return end
	local Pos = Part.Position
	local Current = Camera.CFrame
	local TargetCF = CFrame.new(Current.Position, Pos)
	local Smooth = Settings.Aim.Smoothness / 20
	local LerpCF = Current:Lerp(TargetCF, Smooth)
	Camera.CFrame = LerpCF
end

RunService.Heartbeat:Connect(function()
	if Settings.Aim.Enabled then
		local Target = GetTarget()
		if Target then
			AimAtTarget(Target)
			if Settings.Aim.Mode == "attack" then
				local Tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
				if Tool then
					Tool:Activate()
				end
			end
		end
	end
end)

local function ClearDrawingObjects()
	for _, Obj in ipairs(ScreenGui:GetDescendants()) do
		if Obj:IsA("Frame") and Obj.Name == "DrawObject" then
			Obj:Destroy()
		end
	end
end

local function DrawVisuals()
	ClearDrawingObjects()
	if not Settings.Visuals.Box2D and not Settings.Visuals.Box3D and not Settings.Visuals.Skeleton and
	   not Settings.Visuals.Lines and not Settings.Visuals.Glow and not Settings.Visuals.Recolor and
	   not Settings.Visuals.ShowName and not Settings.Visuals.ShowDistance and not Settings.Visuals.ShowHealth and
	   not Settings.Visuals.ShowWeapon then
		return
	end

	for _, Plr in ipairs(Players:GetPlayers()) do
		if Plr ~= Player and Plr.Character and Plr.Character.PrimaryPart then
			local Char = Plr.Character
			local Dist = (Char.PrimaryPart.Position - Camera.CFrame.Position).Magnitude
			if Dist <= 5 then
				local Pos, OnScreen = Camera:WorldToViewportPoint(Char.PrimaryPart.Position)
				if OnScreen then
					local IsEnemy = Plr.Team ~= Player.Team
					local Color = IsEnemy and Settings.Visuals.Color or Color3.fromRGB(0, 255, 0)

					if Settings.Visuals.Box2D then
						local Box = Instance.new("Frame")
						Box.Name = "DrawObject"
						Box.Size = UDim2.new(0, 50, 0, 80)
						Box.Position = UDim2.new(0, Pos.X - 25, 0, Pos.Y - 40)
						Box.BackgroundTransparency = 0.7
						Box.BackgroundColor3 = Color
						Box.BorderSizePixel = 1
						Box.BorderColor3 = Color
						Box.Parent = ScreenGui
					end

					if Settings.Visuals.ShowName then
						local Label = Instance.new("TextLabel")
						Label.Name = "DrawObject"
						Label.Size = UDim2.new(0, 100, 0, 20)
						Label.Position = UDim2.new(0, Pos.X - 50, 0, Pos.Y - 50)
						Label.BackgroundTransparency = 1
						Label.Text = Plr.Name
						Label.TextColor3 = Color
						Label.TextSize = 14
						Label.Font = Enum.Font.GothamMedium
						Label.Parent = ScreenGui
					end

					if Settings.Visuals.ShowHealth and Char:FindFirstChild("Humanoid") then
						local Health = Char.Humanoid.Health
						local Label = Instance.new("TextLabel")
						Label.Name = "DrawObject"
						Label.Size = UDim2.new(0, 80, 0, 20)
						Label.Position = UDim2.new(0, Pos.X - 40, 0, Pos.Y - 30)
						Label.BackgroundTransparency = 1
						Label.Text = "❤ " .. math.floor(Health)
						Label.TextColor3 = Health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
						Label.TextSize = 12
						Label.Font = Enum.Font.GothamMedium
						Label.Parent = ScreenGui
					end
				end
			end
		end
	end
end

RunService.RenderStepped:Connect(DrawVisuals)

local function CreateRadar()
	local Radar = Instance.new("Frame")
	Radar.Size = UDim2.new(0, 120, 0, 120)
	Radar.Position = UDim2.new(1, -135, 1, -135)
	Radar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	Radar.BackgroundTransparency = 0.3
	Radar.BorderSizePixel = 1
	Radar.BorderColor3 = Color3.fromRGB(60, 60, 70)
	Radar.Parent = ScreenGui

	local RadarCorner = Instance.new("UICorner")
	RadarCorner.CornerRadius = UDim.new(0, 8)
	RadarCorner.Parent = Radar

	local Center = Instance.new("Frame")
	Center.Size = UDim2.new(0, 4, 0, 4)
	Center.Position = UDim2.new(0.5, -2, 0.5, -2)
	Center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Center.BorderSizePixel = 0
	Center.Parent = Radar

	local CenterCorner = Instance.new("UICorner")
	CenterCorner.CornerRadius = UDim.new(0, 2)
	CenterCorner.Parent = Center

	local Dots = {}

	local function UpdateRadar()
		if not Settings.World.Radar then
			Radar.Visible = false
			return
		end
		Radar.Visible = true
		for _, Dot in ipairs(Dots) do
			Dot:Destroy()
		end
		Dots = {}

		local Zoom = Settings.World.RadarZoom / 50
		local CenterPos = Camera.CFrame.Position
		local Forward = Camera.CFrame.LookVector
		local Right = Camera.CFrame.RightVector

		for _, Plr in ipairs(Players:GetPlayers()) do
			if Plr ~= Player and Plr.Character and Plr.Character.PrimaryPart then
				local Char = Plr.Character
				local Pos = Char.PrimaryPart.Position
				local Rel = Pos - CenterPos
				local X = Rel:Dot(Right) * Zoom
				local Z = Rel:Dot(Forward) * Zoom
				local Dist = (Pos - CenterPos).Magnitude
				if Dist <= 100 then
					local Dot = Instance.new("Frame")
					Dot.Size = UDim2.new(0, 6, 0, 6)
					Dot.Position = UDim2.new(0.5, X - 3, 0.5, Z - 3)
					local IsEnemy = Plr.Team ~= Player.Team
					Dot.BackgroundColor3 = IsEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
					Dot.BorderSizePixel = 0
					Dot.Parent = Radar

					local DotCorner = Instance.new("UICorner")
					DotCorner.CornerRadius = UDim.new(0, 3)
					DotCorner.Parent = Dot
					table.insert(Dots, Dot)
				end
			end
		end
	end

	RunService.Heartbeat:Connect(UpdateRadar)
end

CreateRadar()

local function AutoCleanup()
	while true do
		task.wait(300)
		CleanupMemory()
		ApplyPerformanceSettings()
	end
end

task.spawn(AutoCleanup)

local function CheckWorldObjects()
	if not Settings.World.ShowItems and not Settings.World.ShowVehicles then
		return
	end

	for _, Obj in ipairs(Workspace:GetDescendants()) do
		if Settings.World.ShowItems and Obj:IsA("Tool") and Obj.Parent ~= Player.Character then
			local Pos = Obj.PrimaryPart and Obj.PrimaryPart.Position or Obj.Position
			local Dist = (Pos - Camera.CFrame.Position).Magnitude
			if Dist <= 20 then
				local Label = Instance.new("BillboardGui")
				Label.Adornee = Obj
				Label.Size = UDim2.new(0, 100, 0, 30)
				Label.Parent = Obj

				local Text = Instance.new("TextLabel")
				Text.Size = UDim2.new(1, 0, 1, 0)
				Text.BackgroundTransparency = 1
				Text.Text = "📦 " .. Obj.Name
				Text.TextColor3 = Color3.fromRGB(255, 255, 150)
				Text.TextSize = 12
				Text.Font = Enum.Font.GothamMedium
				Text.Parent = Label
			end
		end
		if Settings.World.ShowVehicles and Obj:IsA("VehicleSeat") then
			local Parent = Obj.Parent
			if Parent and Parent:IsA("Model") then
				local Pos = Parent.PrimaryPart and Parent.PrimaryPart.Position or Obj.Position
				local Dist = (Pos - Camera.CFrame.Position).Magnitude
				if Dist <= 30 then
					local Label = Instance.new("BillboardGui")
					Label.Adornee = Parent
					Label.Size = UDim2.new(0, 120, 0, 30)
					Label.Parent = Parent

					local Text = Instance.new("TextLabel")
					Text.Size = UDim2.new(1, 0, 1, 0)
					Text.BackgroundTransparency = 1
					Text.Text = "🚗 " .. Parent.Name
					Text.TextColor3 = Color3.fromRGB(150, 200, 255)
					Text.TextSize = 12
					Text.Font = Enum.Font.GothamMedium
					Text.Parent = Label
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(CheckWorldObjects)

local function HandleResize()
	local ScreenSize = Camera.ViewportSize
	local Width = math.min(ScreenSize.X * 0.8, 400)
	local Height = math.min(ScreenSize.Y * 0.8, 550)
	MainFrame.Size = UDim2.new(0, Width, 0, Height)
	MainFrame.Position = UDim2.new(0.5, -Width/2, 0.5, -Height/2)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(HandleResize)
HandleResize()

for _, Tab in ipairs(TabNames) do
	local Content = TabContents[Tab]
	if Content then
		local Size = 0
		for _, Child in ipairs(Content:GetChildren()) do
			if Child:IsA("Frame") then
				Size = Size + Child.Size.Y.Offset + 8
			end
		end
		Content.Size = UDim2.new(1, 0, 0, Size + 20)
	end
end

TabContents.Aim.Visible = true
Tabs.Aim.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Tabs.Aim.TextColor3 = Color3.fromRGB(255, 255, 255)