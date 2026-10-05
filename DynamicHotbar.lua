-- inventory.lua
-- LocalScript for your own Roblox experience.
-- Place in StarterPlayer > StarterPlayerScripts.
--
-- Features:
-- * Dynamic hotbar: one slot per Tool, up to 10 visible slots.
-- * Stable slot positions: equipping a Tool does not move it.
-- * Selected slot gets a cyan/blue outline.
-- * Startup settings window: "Enable extended inventory" + toggle.
-- * Window is draggable on mouse/touch.
-- * X collapses the window to a square; tapping the square restores it.
-- * Author credit: by kitzkuro
--
-- This is intended for a Roblox Studio experience you control.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local existing = playerGui:FindFirstChild("ExtendedInventory")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ExtendedInventory"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- =========================
-- Utility
-- =========================

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function makeSmoothDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPos
	local tween

	local function tweenTo(position)
		if tween then
			tween:Cancel()
		end

		tween = TweenService:Create(
			frame,
			TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Position = position}
		)
		tween:Play()
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if connection then
						connection:Disconnect()
					end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		tweenTo(UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		))
	end)
end

-- =========================
-- Settings window
-- =========================

local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.AnchorPoint = Vector2.new(0.5, 0.5)
settings.Position = UDim2.new(0.5, 0, 0.5, 0)
settings.Size = UDim2.new(0, 390, 0, 330)
settings.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
settings.BorderSizePixel = 0
settings.ZIndex = 100
settings.Parent = gui
corner(settings, 12)
stroke(settings, 1.5, Color3.fromRGB(70, 75, 90), 0)

local header = Instance.new("TextLabel")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Position = UDim2.new(0, 16, 0, 8)
header.Size = UDim2.new(1, -60, 0, 28)
header.Text = "Inventory Settings"
header.TextColor3 = Color3.fromRGB(245, 245, 250)
header.TextSize = 18
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.ZIndex = 101
header.Parent = settings

local close = Instance.new("TextButton")
close.Name = "Close"
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -8, 0, 7)
close.Size = UDim2.new(0, 30, 0, 30)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.fromRGB(230, 230, 235)
close.TextSize = 26
close.Font = Enum.Font.GothamBold
close.ZIndex = 101
close.Parent = settings

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 16, 0, 48)
title.Size = UDim2.new(1, -100, 0, 30)
title.Text = "Enable extended inventory"
title.TextColor3 = Color3.fromRGB(235, 235, 240)
title.TextSize = 15
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 101
title.Parent = settings

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.AnchorPoint = Vector2.new(1, 0.5)
toggle.Position = UDim2.new(1, -18, 0, 63)
toggle.Size = UDim2.new(0, 58, 0, 30)
toggle.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
toggle.Text = ""
toggle.AutoButtonColor = false
toggle.ZIndex = 101
toggle.Parent = settings
corner(toggle, 15)

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.AnchorPoint = Vector2.new(0, 0.5)
knob.Position = UDim2.new(0, 3, 0.5, 0)
knob.Size = UDim2.new(0, 24, 0, 24)
knob.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
knob.ZIndex = 102
knob.Parent = toggle
corner(knob, 12)

local credit = Instance.new("TextLabel")
credit.BackgroundTransparency = 1
credit.Position = UDim2.new(0, 16, 1, -31)
credit.Size = UDim2.new(1, -32, 0, 20)
credit.Text = "by kitzkuro"
credit.TextColor3 = Color3.fromRGB(135, 140, 155)
credit.TextSize = 12
credit.Font = Enum.Font.Gotham
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.ZIndex = 101
credit.Parent = settings

-- Optional quality-of-life setting: faster UI animations.
local performanceToggle = Instance.new("TextButton")
performanceToggle.Name = "PerformanceToggle"
performanceToggle.Size = UDim2.new(0, 150, 0, 28)
performanceToggle.Position = UDim2.new(0, 20, 0, 282)
performanceToggle.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
performanceToggle.BackgroundTransparency = 0.05
performanceToggle.Text = "Performance mode: OFF"
performanceToggle.TextColor3 = Color3.fromRGB(225, 230, 240)
performanceToggle.TextSize = 13
performanceToggle.Font = Enum.Font.GothamMedium
performanceToggle.AutoButtonColor = false
performanceToggle.ZIndex = 101
performanceToggle.Parent = settings
corner(performanceToggle, 7)

local performanceMode = false
local function uiTweenInfo(duration, style, direction)
	if performanceMode then
		duration = duration * 0.55
	end
	return TweenInfo.new(duration, style, direction)
end

performanceToggle.Activated:Connect(function()
	performanceMode = not performanceMode
	performanceToggle.Text = performanceMode and "Performance mode: ON" or "Performance mode: OFF"
	performanceToggle.BackgroundColor3 = performanceMode
		and Color3.fromRGB(35, 130, 185)
		or Color3.fromRGB(45, 50, 60)
end)


-- Collapsed square
local collapsed = Instance.new("TextButton")
collapsed.Name = "Collapsed"
collapsed.AnchorPoint = Vector2.new(0.5, 0.5)
collapsed.Position = settings.Position
collapsed.Size = UDim2.new(0, 54, 0, 54)
collapsed.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
collapsed.BorderSizePixel = 0
collapsed.Text = "≡"
collapsed.AutoButtonColor = false
collapsed.ZIndex = 100
collapsed.TextColor3 = Color3.fromRGB(235, 235, 240)
collapsed.TextSize = 25
collapsed.Font = Enum.Font.GothamBold
collapsed.Visible = false
collapsed.Parent = gui
corner(collapsed, 12)
stroke(collapsed, 1.5, Color3.fromRGB(70, 75, 90), 0)

makeSmoothDraggable(collapsed, collapsed)


-- =========================
-- Extra quality-of-life settings
-- =========================

local groupTitle = Instance.new("TextLabel")
groupTitle.Name = "GroupMoverTitle"
groupTitle.BackgroundTransparency = 1
groupTitle.Position = UDim2.new(0, 20, 0, 92)
groupTitle.Size = UDim2.new(1, -40, 0, 22)
groupTitle.Text = "GUI Group Mover"
groupTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
groupTitle.TextSize = 14
groupTitle.Font = Enum.Font.GothamBold
groupTitle.TextXAlignment = Enum.TextXAlignment.Left
groupTitle.ZIndex = 101
groupTitle.Parent = settings

local groupInfo = Instance.new("TextLabel")
groupInfo.Name = "GroupMoverInfo"
groupInfo.BackgroundTransparency = 1
groupInfo.Position = UDim2.new(0, 20, 0, 115)
groupInfo.Size = UDim2.new(1, -40, 0, 32)
groupInfo.Text = "Выбери контейнер GUI — двигай всю группу целиком."
groupInfo.TextColor3 = Color3.fromRGB(145, 150, 165)
groupInfo.TextSize = 12
groupInfo.Font = Enum.Font.Gotham
groupInfo.TextXAlignment = Enum.TextXAlignment.Left
groupInfo.ZIndex = 101
groupInfo.Parent = settings

local groupList = Instance.new("ScrollingFrame")
groupList.Name = "GroupList"
groupList.Position = UDim2.new(0, 20, 0, 150)
groupList.Size = UDim2.new(1, -40, 0, 78)
groupList.BackgroundColor3 = Color3.fromRGB(32, 35, 42)
groupList.BackgroundTransparency = 0.05
groupList.BorderSizePixel = 0
groupList.ScrollBarThickness = 3
groupList.CanvasSize = UDim2.new()
groupList.AutomaticCanvasSize = Enum.AutomaticSize.Y
groupList.ZIndex = 101
groupList.Parent = settings
corner(groupList, 8)

local groupLayout = Instance.new("UIListLayout")
groupLayout.Padding = UDim.new(0, 4)
groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
groupLayout.Parent = groupList

local selectedGroup = nil
local groupDragConnection = nil
local groupDragEndConnection = nil
local groupDragInputConnection = nil
local currentGroupHandle = nil

local function isGuiGroupCandidate(obj)
	if not obj:IsA("GuiObject") then
		return false
	end

	if obj:IsDescendantOf(gui) then
		return false
	end

	-- A "group" is a GuiObject container. Moving its Position moves
	-- every descendant with it, so children stay together.
	return obj.Parent and obj.Parent:IsA("LayerCollector")
		or (obj.Parent and obj.Parent:IsA("GuiObject") and obj:IsA("Frame"))
end

local function stopGroupDrag()
	if currentGroupHandle then
		currentGroupHandle:Destroy()
		currentGroupHandle = nil
	end
	if groupDragConnection then
		groupDragConnection:Disconnect()
		groupDragConnection = nil
	end
	if groupDragEndConnection then
		groupDragEndConnection:Disconnect()
		groupDragEndConnection = nil
	end
	if groupDragInputConnection then
		groupDragInputConnection:Disconnect()
		groupDragInputConnection = nil
	end
end

local function dragGroup(group)
	stopGroupDrag()
	selectedGroup = group

	local dragging = false
	local startInput
	local startPosition

	local handle = Instance.new("TextButton")
	handle.Name = "GroupDragHandle"
	handle.Text = "✥"
	handle.TextSize = 18
	handle.TextColor3 = Color3.fromRGB(80, 205, 255)
	handle.BackgroundColor3 = Color3.fromRGB(28, 32, 38)
	handle.AutoButtonColor = false
	handle.ZIndex = 100000
	handle.Size = UDim2.new(0, 36, 0, 36)
	handle.AnchorPoint = Vector2.new(0.5, 1)
	handle.Position = UDim2.new(0.5, 0, 0, -8)
	handle.Parent = group
	currentGroupHandle = handle
	corner(handle, 8)

	local handleStroke = stroke(handle, 1.5, Color3.fromRGB(65, 190, 240), 0)

	local function begin(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		startInput = input.Position
		startPosition = group.Position

		groupDragEndConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if groupDragEndConnection then
					groupDragEndConnection:Disconnect()
					groupDragEndConnection = nil
				end
			end
		end)
	end

	handle.InputBegan:Connect(begin)

	groupDragInputConnection = UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - startInput
		group.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	-- Remove the helper handle when the group is deselected.
	local function removeHandle()
		if handle and handle.Parent then
			handle:Destroy()
		end
	end

	group.AncestryChanged:Connect(function()
		if not group:IsDescendantOf(playerGui) then
			removeHandle()
			stopGroupDrag()
		end
	end)
end

local function clearGroupList()
	for _, child in ipairs(groupList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function refreshGroupList()
	clearGroupList()

	local candidates = {}
	for _, child in ipairs(playerGui:GetChildren()) do
		if child ~= gui and child:IsA("ScreenGui") then
			for _, obj in ipairs(child:GetChildren()) do
				if isGuiGroupCandidate(obj) then
					table.insert(candidates, obj)
				end
			end
		end
	end

	table.sort(candidates, function(a, b)
		return a:GetFullName() < b:GetFullName()
	end)

	for index, obj in ipairs(candidates) do
		local button = Instance.new("TextButton")
		button.Name = "Group_" .. index
		button.Size = UDim2.new(1, -8, 0, 28)
		button.BackgroundColor3 = Color3.fromRGB(45, 49, 58)
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = "  " .. obj.Name
		button.TextColor3 = Color3.fromRGB(225, 230, 240)
		button.TextSize = 12
		button.Font = Enum.Font.GothamMedium
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.ZIndex = 102
		button.Parent = groupList
		corner(button, 6)

		button.Activated:Connect(function()
			for _, other in ipairs(groupList:GetChildren()) do
				if other:IsA("TextButton") then
					other.BackgroundColor3 = Color3.fromRGB(45, 49, 58)
				end
			end
			button.BackgroundColor3 = Color3.fromRGB(35, 125, 175)
			dragGroup(obj)
		end)
	end

	if #candidates == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, -8, 0, 28)
		empty.BackgroundTransparency = 1
		empty.Text = "Нет подходящих GUI-групп"
		empty.TextColor3 = Color3.fromRGB(135, 140, 155)
		empty.TextSize = 12
		empty.Font = Enum.Font.Gotham
		empty.ZIndex = 102
		empty.Parent = groupList
	end
end

local refreshGroups = Instance.new("TextButton")
refreshGroups.Name = "RefreshGroups"
refreshGroups.Size = UDim2.new(0, 88, 0, 28)
refreshGroups.Position = UDim2.new(1, -108, 0, 92)
refreshGroups.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
refreshGroups.BorderSizePixel = 0
refreshGroups.Text = "Refresh"
refreshGroups.TextColor3 = Color3.fromRGB(225, 230, 240)
refreshGroups.TextSize = 12
refreshGroups.Font = Enum.Font.GothamMedium
refreshGroups.AutoButtonColor = false
refreshGroups.ZIndex = 102
refreshGroups.Parent = settings
corner(refreshGroups, 7)

refreshGroups.Activated:Connect(refreshGroupList)
refreshGroupList()

-- A compact UI-scale control. It scales the whole custom GUI without changing
-- the device resolution.
local scaleTitle = Instance.new("TextLabel")
scaleTitle.BackgroundTransparency = 1
scaleTitle.Position = UDim2.new(0, 220, 0, 245)
scaleTitle.Size = UDim2.new(0, 65, 0, 28)
scaleTitle.Text = "UI Scale"
scaleTitle.TextColor3 = Color3.fromRGB(225, 230, 240)
scaleTitle.TextSize = 12
scaleTitle.Font = Enum.Font.GothamMedium
scaleTitle.TextXAlignment = Enum.TextXAlignment.Left
scaleTitle.ZIndex = 101
scaleTitle.Parent = settings

local scaleDown = Instance.new("TextButton")
scaleDown.Size = UDim2.new(0, 28, 0, 28)
scaleDown.Position = UDim2.new(0, 285, 0, 245)
scaleDown.Text = "−"
scaleDown.TextSize = 18
scaleDown.TextColor3 = Color3.fromRGB(230, 235, 240)
scaleDown.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
scaleDown.BorderSizePixel = 0
scaleDown.AutoButtonColor = false
scaleDown.ZIndex = 101
scaleDown.Parent = settings
corner(scaleDown, 7)

local scaleUp = Instance.new("TextButton")
scaleUp.Size = UDim2.new(0, 28, 0, 28)
scaleUp.Position = UDim2.new(0, 317, 0, 245)
scaleUp.Text = "+"
scaleUp.TextSize = 18
scaleUp.TextColor3 = Color3.fromRGB(230, 235, 240)
scaleUp.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
scaleUp.BorderSizePixel = 0
scaleUp.AutoButtonColor = false
scaleUp.ZIndex = 101
scaleUp.Parent = settings
corner(scaleUp, 7)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = gui

local function changeUIScale(delta)
	uiScale.Scale = math.clamp(uiScale.Scale + delta, 0.75, 1.25)
end

scaleDown.Activated:Connect(function()
	changeUIScale(-0.05)
end)

scaleUp.Activated:Connect(function()
	changeUIScale(0.05)
end)

makeSmoothDraggable(settings, header)

local settingsOpenSize = settings.Size
local settingsOpenPosition = settings.Position
local collapsedSize = collapsed.Size

local fadeObjects = {
	header, close, title, toggle, credit
}

local function setGroupTransparency(value)
	for _, object in ipairs(fadeObjects) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			object.TextTransparency = value
		end
	end

	toggle.BackgroundTransparency = math.clamp(value, 0, 0.9)
	knob.BackgroundTransparency = math.clamp(value, 0, 0.9)
end

local function collapse()
	if not settings.Visible then
		return
	end

	collapsed.Position = settings.Position
	collapsed.Visible = true
	collapsed.Size = UDim2.new(0, 10, 0, 10)
	collapsed.BackgroundTransparency = 1
	collapsed.TextTransparency = 1

	local outInfo = uiTweenInfo(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(settings, outInfo, {
		Size = UDim2.new(0, 70, 0, 70),
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(collapsed, uiTweenInfo(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = collapsedSize,
		BackgroundTransparency = 0,
		TextTransparency = 0
	}):Play()

	TweenService:Create(settings, fadeInfo, {
		BackgroundTransparency = 1
	}):Play()

	setGroupTransparency(1)

	task.delay(0.30, function()
		settings.Visible = false
		settings.Size = settingsOpenSize
		settings.BackgroundTransparency = 0
		setGroupTransparency(0)
	end)
end

local function expand()
	if settings.Visible then
		return
	end

	settings.Position = collapsed.Position
	settings.Visible = true
	settings.Size = UDim2.new(0, 70, 0, 70)
	settings.BackgroundTransparency = 1
	setGroupTransparency(1)

	collapsed.Visible = false

	TweenService:Create(settings, uiTweenInfo(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = settingsOpenSize,
		BackgroundTransparency = 0
	}):Play()

	local dummy = Instance.new("NumberValue")
	dummy.Value = 1
	dummy:GetPropertyChangedSignal("Value"):Connect(function()
		setGroupTransparency(dummy.Value)
	end)

	TweenService:Create(dummy, uiTweenInfo(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Value = 0
	}):Play()

	task.delay(0.28, function()
		dummy:Destroy()
	end)
end

close.Activated:Connect(collapse)
collapsed.Activated:Connect(expand)

-- =========================
-- Stable dynamic hotbar
-- =========================

local bar = Instance.new("Frame")
bar.Name = "Hotbar"
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 0.985, 0)
bar.Size = UDim2.new(0.72, 0, 0.16, 0)
bar.BackgroundTransparency = 1
bar.Visible = false
bar.Parent = gui

local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 4)
list.Parent = bar

-- Stable order is maintained by Tool instance, so equipping a Tool
-- does not make its slot jump to another position.
local order = {}
local orderCounter = 0
local selectedTool = nil

local function rememberTool(tool)
	if order[tool] == nil then
		orderCounter += 1
		order[tool] = orderCounter
	end
end

local function forgetMissingTools()
	for tool in pairs(order) do
		if not tool:IsDescendantOf(player) then
			order[tool] = nil
		end
	end
end

local function getTools()
	local result = {}

	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") then
			rememberTool(obj)
			table.insert(result, obj)
		end
	end

	local character = player.Character
	if character then
		for _, obj in ipairs(character:GetChildren()) do
			if obj:IsA("Tool") then
				rememberTool(obj)
				table.insert(result, obj)
			end
		end
	end

	table.sort(result, function(a, b)
		return (order[a] or math.huge) < (order[b] or math.huge)
	end)

	return result
end

local function updateHotbar()
	for _, child in ipairs(bar:GetChildren()) do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end

	-- Keep the order table intact. Roblox can briefly set a Tool's
	-- Parent to nil while moving it between Backpack and Character.
	-- Keeping its original order prevents the selected item from jumping.
	local tools = getTools()
	local count = #tools

	bar.Visible = toggle:GetAttribute("Enabled") == true and count > 0

	if count == 0 then
		return
	end

	local visibleCount = math.min(count, 10)
	local width = math.min(0.12, 0.88 / visibleCount)

	for i = 1, visibleCount do
		local tool = tools[i]

		local slot = Instance.new("ImageButton")
		slot.Name = "Slot_" .. i
		slot.LayoutOrder = i
		slot.Size = UDim2.new(width, 0, 0.78, 0)
		slot.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
		slot.BackgroundTransparency = 0.30
		slot.BorderSizePixel = 0
		slot.AutoButtonColor = true
		slot.Image = tool.TextureId or ""
		slot.ScaleType = Enum.ScaleType.Fit
		slot.Parent = bar
		corner(slot, 4)

		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.DominantAxis = Enum.DominantAxis.Width
		aspect.Parent = slot

		local outlineColor = Color3.fromRGB(70, 75, 85)
		local outlineWidth = 1

		if tool == selectedTool then
			outlineColor = Color3.fromRGB(55, 205, 255)
			outlineWidth = 3
		end

		local outline = stroke(slot, outlineWidth, outlineColor, 0)

		local number = Instance.new("TextLabel")
		number.Name = "Number"
		number.BackgroundTransparency = 1
		number.Position = UDim2.new(0.04, 0, 0.02, 0)
		number.Size = UDim2.new(0.20, 0, 0.20, 0)
		number.Text = tostring(i)
		number.TextColor3 = Color3.fromRGB(40, 40, 40)
		number.TextScaled = true
		number.Font = Enum.Font.GothamBold
		number.Parent = slot

		slot.Activated:Connect(function()
			local character = player.Character
			if not character then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			-- Tap ANY currently selected/equipped Tool again:
			-- unequip it, clear the blue outline, but KEEP the Tool.
			-- This applies equally to hammers, brushes, weapons, etc.
			if tool == selectedTool and tool.Parent == character then
				humanoid:UnequipTools()
				selectedTool = nil
				updateHotbar()
				return
			end

			-- Select/equip another tool without changing its stored slot.
			if tool.Parent == backpack then
				humanoid:EquipTool(tool)
				selectedTool = tool
				updateHotbar()
				return
			end

			-- If it is already in Character, keep it selected.
			if tool.Parent == character then
				selectedTool = tool
				updateHotbar()
			end
		end)
	end
end

local function setNativeBackpackEnabled(enabled)
	-- Roblox CoreGui can be a little slow to initialize, so retry briefly.
	task.spawn(function()
		for _ = 1, 8 do
			local ok = pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, enabled)
			end)
			if ok then
				return
			end
			task.wait(0.1)
		end
	end)
end

local function setEnabled(enabled)
	toggle:SetAttribute("Enabled", enabled)

	if enabled then
		toggle.BackgroundColor3 = Color3.fromRGB(35, 155, 235)
		knob.Position = UDim2.new(1, -27, 0.5, 0)

		-- Hide Roblox's built-in hotbar while the extended one is active.
		setNativeBackpackEnabled(false)
		updateHotbar()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
		knob.Position = UDim2.new(0, 3, 0.5, 0)

		-- Hide our hotbar and restore Roblox's built-in hotbar.
		bar.Visible = false
		setNativeBackpackEnabled(true)
	end
end

toggle:SetAttribute("Enabled", true)
toggle.Activated:Connect(function()
	setEnabled(not toggle:GetAttribute("Enabled"))
end)

-- Detect inventory changes without changing the stable slot order.
backpack.ChildAdded:Connect(function(obj)
	if obj:IsA("Tool") then
		rememberTool(obj)
		task.defer(updateHotbar)
	end
end)

backpack.ChildRemoved:Connect(function(obj)
	if obj:IsA("Tool") then
		task.defer(updateHotbar)
	end
end)

local function connectCharacter(character)
	character.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then
			rememberTool(obj)
			-- Character movement is not itself a selection change.
			-- Selection is controlled by the slot button.
			task.defer(updateHotbar)
		end
	end)

	character.ChildRemoved:Connect(function(obj)
		if obj:IsA("Tool") then
			task.defer(function()
				if selectedTool == obj and obj.Parent ~= character then
					-- If it went back to Backpack, keep it selected only when
					-- it was equipped by the hotbar. Explicit unequip clears it
					-- before this callback runs.
					if obj.Parent ~= backpack then
						selectedTool = nil
					end
				end
				updateHotbar()
			end)
		end
	end)

	task.defer(updateHotbar)
end

player.CharacterAdded:Connect(connectCharacter)

if player.Character then
	connectCharacter(player.Character)
end

-- Start enabled.
setEnabled(true)
