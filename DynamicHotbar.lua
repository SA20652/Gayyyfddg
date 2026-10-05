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
settings.Size = UDim2.new(0, 350, 0, 150)
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

-- Collapsed square
local collapsed = Instance.new("TextButton")
collapsed.Name = "Collapsed"
collapsed.AnchorPoint = Vector2.new(0.5, 0.5)
collapsed.Position = settings.Position
collapsed.Size = UDim2.new(0, 54, 0, 54)
collapsed.BackgroundColor3 = Color3.fromRGB(24, 25, 30)
collapsed.BorderSizePixel = 0
collapsed.Text = "≡"
collapsed.ZIndex = 100
collapsed.TextColor3 = Color3.fromRGB(235, 235, 240)
collapsed.TextSize = 25
collapsed.Font = Enum.Font.GothamBold
collapsed.Visible = false
collapsed.Parent = gui
corner(collapsed, 12)
stroke(collapsed, 1.5, Color3.fromRGB(70, 75, 90), 0)

makeSmoothDraggable(collapsed, collapsed)

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

	local outInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(settings, outInfo, {
		Size = UDim2.new(0, 70, 0, 70),
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(collapsed, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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

	TweenService:Create(settings, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = settingsOpenSize,
		BackgroundTransparency = 0
	}):Play()

	local dummy = Instance.new("NumberValue")
	dummy.Value = 1
	dummy:GetPropertyChangedSignal("Value"):Connect(function()
		setGroupTransparency(dummy.Value)
	end)

	TweenService:Create(dummy, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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

			if tool.Parent == backpack then
				humanoid:EquipTool(tool)
				selectedTool = tool
			elseif tool.Parent == character then
				selectedTool = tool
			end

			updateHotbar()
		end)
	end
end

local function setEnabled(enabled)
	toggle:SetAttribute("Enabled", enabled)

	if enabled then
		toggle.BackgroundColor3 = Color3.fromRGB(35, 155, 235)
		knob.Position = UDim2.new(1, -27, 0.5, 0)
	else
		toggle.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
		knob.Position = UDim2.new(0, 3, 0.5, 0)
		bar.Visible = false
		setNativeBackpackEnabled(true)
	end

	if enabled then
		setNativeBackpackEnabled(false)
		updateHotbar()
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
			selectedTool = obj
			task.defer(updateHotbar)
		end
	end)

	character.ChildRemoved:Connect(function(obj)
		if obj:IsA("Tool") then
			task.defer(updateHotbar)
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
