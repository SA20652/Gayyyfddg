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
local HttpService = game:GetService("HttpService")

-- Persistent settings for executors that expose readfile/writefile.
-- This is client-side storage on the current device, not Roblox DataStore.
local SETTINGS_FILE = "DynamicHotbar_settings.json"
local savedSettings = {}
local canPersist = type(readfile) == "function"
    and type(writefile) == "function"
    and type(isfile) == "function"

if canPersist then
    pcall(function()
        if isfile(SETTINGS_FILE) then
            savedSettings = HttpService:JSONDecode(readfile(SETTINGS_FILE))
            if type(savedSettings) ~= "table" then
                savedSettings = {}
            end
        end
    end)
end

local function saveSettings()
    if not canPersist then return end
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode(savedSettings))
    end)
end

local function positionToTable(position)
    return {position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset}
end

local function tableToPosition(value, fallback)
    if type(value) ~= "table" or #value < 4 then return fallback end
    for i = 1, 4 do
        if type(value[i]) ~= "number" then return fallback end
    end
    return UDim2.new(value[1], value[2], value[3], value[4])
end

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

local function makeSmoothDraggable(frame, handle, onDragEnd)
	local dragging = false
	local moved = false
	local dragStart
	local startPos
	local tween
	local dragThreshold = 8

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
			moved = false
			dragStart = input.Position
			startPos = frame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if connection then
						connection:Disconnect()
					end
					if onDragEnd then onDragEnd(moved) end
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
		if math.abs(delta.X) >= dragThreshold or math.abs(delta.Y) >= dragThreshold then
			moved = true
		end

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
settings.Size = UDim2.new(0, 320, 0, 245)
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

-- Theme selector (available only when custom inventory is enabled)
local themes = {
	{
		Name = "Default",
		Slot = Color3.fromRGB(128, 128, 128),
		SlotTransparency = 0.30,
		Outline = Color3.fromRGB(70, 75, 85),
		Selected = Color3.fromRGB(55, 205, 255),
		Number = Color3.fromRGB(40, 40, 40),
	},
	{
		Name = "Dark",
		Slot = Color3.fromRGB(45, 48, 55),
		SlotTransparency = 0.12,
		Outline = Color3.fromRGB(90, 95, 110),
		Selected = Color3.fromRGB(90, 190, 255),
		Number = Color3.fromRGB(235, 235, 240),
	},
	{
		Name = "Blue",
		Slot = Color3.fromRGB(55, 95, 135),
		SlotTransparency = 0.18,
		Outline = Color3.fromRGB(90, 130, 170),
		Selected = Color3.fromRGB(80, 220, 255),
		Number = Color3.fromRGB(240, 248, 255),
	},
}

local themeIndex = 1
local themeLabel = Instance.new("TextLabel")
themeLabel.Name = "ThemeLabel"
themeLabel.BackgroundTransparency = 1
themeLabel.Position = UDim2.new(0, 16, 0, 94)
themeLabel.Size = UDim2.new(0, 110, 0, 30)
themeLabel.Text = "Theme"
themeLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
themeLabel.TextSize = 14
themeLabel.Font = Enum.Font.GothamMedium
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.Visible = false
themeLabel.ZIndex = 101
themeLabel.Parent = settings

local themeButton = Instance.new("TextButton")
themeButton.Name = "ThemeButton"
themeButton.Size = UDim2.new(0, 125, 0, 30)
themeButton.Position = UDim2.new(1, -141, 0, 94)
themeButton.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
themeButton.BorderSizePixel = 0
themeButton.Text = "Default"
themeButton.TextColor3 = Color3.fromRGB(235, 235, 240)
themeButton.TextSize = 13
themeButton.Font = Enum.Font.GothamMedium
themeButton.AutoButtonColor = false
themeButton.Visible = false
themeButton.ZIndex = 101
themeButton.Parent = settings
corner(themeButton, 7)


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
collapsed.AutoButtonColor = false
collapsed.ZIndex = 100
collapsed.TextColor3 = Color3.fromRGB(235, 235, 240)
collapsed.TextSize = 25
collapsed.Font = Enum.Font.GothamBold
collapsed.Visible = false
collapsed.Parent = gui
corner(collapsed, 12)
stroke(collapsed, 1.5, Color3.fromRGB(70, 75, 90), 0)

settings.Position = tableToPosition(savedSettings.settingsPosition, settings.Position)
collapsed.Position = tableToPosition(savedSettings.collapsedPosition, UDim2.new(
    settings.Position.X.Scale,
    settings.Position.X.Offset,
    settings.Position.Y.Scale,
    settings.Position.Y.Offset
))

local settingsOpenSize = settings.Size
local settingsOpenPosition = settings.Position
local collapsedSize = collapsed.Size

local fadeObjects = {
    header, close, title, toggle, credit, themeLabel, themeButton
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

local function tweenGroupTransparency(target, duration, easingStyle)
    local value = Instance.new("NumberValue")
    value.Value = target == 0 and 1 or 0

    local connection = value:GetPropertyChangedSignal("Value"):Connect(function()
        setGroupTransparency(value.Value)
    end)

    local tween = TweenService:Create(
        value,
        TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Value = target}
    )
    tween:Play()

    tween.Completed:Connect(function()
        connection:Disconnect()
        value:Destroy()
    end)

    return tween
end

local function collapse()
    if not settings.Visible then
        return
    end

    -- Settings and the collapsed square have completely independent positions.
    savedSettings.isCollapsed = true
    savedSettings.settingsPosition = positionToTable(settings.Position)
    savedSettings.collapsedPosition = positionToTable(collapsed.Position)
    saveSettings()

    local sourcePosition = settings.Position

    collapsed.Visible = true
    collapsed.Size = UDim2.new(0, 8, 0, 8)
    collapsed.BackgroundTransparency = 1
    collapsed.TextTransparency = 1

    local windowTween = TweenService:Create(
        settings,
        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 185, 0, 135),
            BackgroundTransparency = 1
        }
    )
    windowTween:Play()
    tweenGroupTransparency(1, 0.16, Enum.EasingStyle.Quad)

    TweenService:Create(
        collapsed,
        TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = collapsedSize,
            BackgroundTransparency = 0,
            TextTransparency = 0
        }
    ):Play()

    windowTween.Completed:Connect(function()
        settings.Visible = false
        settings.Size = settingsOpenSize
        settings.Position = sourcePosition
        settings.BackgroundTransparency = 0
        setGroupTransparency(0)
    end)
end

local function expand()
    if settings.Visible then
        return
    end

    -- Do NOT move the settings window to the square's position.
    savedSettings.isCollapsed = false
    savedSettings.settingsPosition = positionToTable(settings.Position)
    savedSettings.collapsedPosition = positionToTable(collapsed.Position)
    saveSettings()

    settings.Position = tableToPosition(
        savedSettings.settingsPosition,
        settingsOpenPosition
    )
    settings.Visible = true
    settings.Size = UDim2.new(0, 185, 0, 135)
    settings.BackgroundTransparency = 1
    setGroupTransparency(1)

    collapsed.Visible = false

    TweenService:Create(
        settings,
        TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {
            Size = settingsOpenSize,
            BackgroundTransparency = 0
        }
    ):Play()

    tweenGroupTransparency(0, 0.25, Enum.EasingStyle.Quad)
end

local suppressCollapsedClickUntil = 0

makeSmoothDraggable(collapsed, collapsed, function(wasDragged)
    if wasDragged then
        suppressCollapsedClickUntil = os.clock() + 0.20
    end
    savedSettings.collapsedPosition = positionToTable(collapsed.Position)
    saveSettings()
end)

makeSmoothDraggable(settings, header, function()
    savedSettings.settingsPosition = positionToTable(settings.Position)
    saveSettings()
end)

close.Activated:Connect(collapse)
collapsed.Activated:Connect(function()
    if os.clock() < suppressCollapsedClickUntil then
        return
    end
    expand()
end)

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
		local currentTheme = themes[themeIndex]
		slot.BackgroundColor3 = currentTheme.Slot
		slot.BackgroundTransparency = currentTheme.SlotTransparency
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

		local outlineColor = currentTheme.Outline
		local outlineWidth = 1

		if tool == selectedTool then
			outlineColor = currentTheme.Selected
			outlineWidth = 3
		end

		local outline = stroke(slot, outlineWidth, outlineColor, 0)

		local number = Instance.new("TextLabel")
		number.Name = "Number"
		number.BackgroundTransparency = 1
		number.Position = UDim2.new(0.04, 0, 0.02, 0)
		number.Size = UDim2.new(0.20, 0, 0.20, 0)
		number.Text = tostring(i)
		number.TextColor3 = currentTheme.Number
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

local function animateToggle(enabled)
	local target = enabled and UDim2.new(1, -27, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	TweenService:Create(
		knob,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = target}
	):Play()

	TweenService:Create(
		toggle,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = enabled and Color3.fromRGB(35, 155, 235) or Color3.fromRGB(55, 60, 70)}
	):Play()
end

local function setEnabled(enabled)
	toggle:SetAttribute("Enabled", enabled)
    savedSettings.enabled = enabled
    saveSettings()
	themeLabel.Visible = enabled
	themeButton.Visible = enabled
	animateToggle(enabled)

	if enabled then
		-- Hide Roblox's built-in hotbar while the custom inventory is active.
		setNativeBackpackEnabled(false)
		updateHotbar()
	else
		-- Hide our hotbar and restore Roblox's native Backpack UI.
		bar.Visible = false
		setNativeBackpackEnabled(true)
	end
end

toggle:SetAttribute("Enabled", false)
toggle.Activated:Connect(function()
	setEnabled(not toggle:GetAttribute("Enabled"))
end)


themeButton.Activated:Connect(function()
	themeIndex = (themeIndex % #themes) + 1
	themeButton.Text = themes[themeIndex].Name
    savedSettings.themeIndex = themeIndex
    saveSettings()
	updateHotbar()
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
	-- Rebuild from the new Character/Backpack. The hotbar visibility is
	-- determined only by whether Tools currently exist, so it cannot get
	-- stuck hidden after respawn.
	bar.Visible = false

	local function hasInventoryTool()
		for _, obj in ipairs(character:GetChildren()) do
			if obj:IsA("Tool") then
				rememberTool(obj)
				return true
			end
		end
		for _, obj in ipairs(backpack:GetChildren()) do
			if obj:IsA("Tool") then
				rememberTool(obj)
				return true
			end
		end
		return false
	end

	hasInventoryTool()

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			bar.Visible = false
			selectedTool = nil
			task.defer(updateHotbar)
		end)
	end

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

-- Some experiences replace the Backpack instance after death. Rebind to
-- the new Backpack so the custom inventory can come back with it.
local backpackConnection
local function connectBackpack(newBackpack)
	if not newBackpack or not newBackpack:IsA("Backpack") then
		return
	end

	backpack = newBackpack
	if backpackConnection then
		backpackConnection:Disconnect()
	end

	backpackConnection = backpack.ChildAdded:Connect(function(obj)
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

	local hasTool = false
	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") then
			hasTool = true
			break
		end
	end
	if hasTool then
	end
	task.defer(updateHotbar)
end

player.ChildAdded:Connect(function(obj)
	if obj:IsA("Backpack") then
		connectBackpack(obj)
	end
end)

player.CharacterAdded:Connect(connectCharacter)

if player.Character then
	connectCharacter(player.Character)
end

-- Continuously reconcile the custom hotbar with the live Roblox inventory.
-- Some games recreate/move Tools several frames after respawn; relying only
-- on ChildAdded can miss that transition. This loop only rebuilds when the
-- inventory state actually changes.
local lastInventorySignature = ""
task.spawn(function()
	while gui.Parent do
		if toggle:GetAttribute("Enabled") == true then
			local parts = {}
			local currentBackpack = player:FindFirstChildOfClass("Backpack")
			if currentBackpack then
				if currentBackpack ~= backpack then
					connectBackpack(currentBackpack)
				end
				for _, obj in ipairs(currentBackpack:GetChildren()) do
					if obj:IsA("Tool") then table.insert(parts, "B:" .. obj:GetDebugId()) end
				end
			end
			local character = player.Character
			if character then
				for _, obj in ipairs(character:GetChildren()) do
					if obj:IsA("Tool") then table.insert(parts, "C:" .. obj:GetDebugId()) end
				end
			end
			table.sort(parts)
			local signature = table.concat(parts, "|")
			if signature ~= lastInventorySignature then
				lastInventorySignature = signature
				updateHotbar()
			end
		end
		task.wait(0.35)
	end
end)

-- Restore saved settings on startup.
if type(savedSettings.themeIndex) == "number" then
    themeIndex = math.clamp(math.floor(savedSettings.themeIndex), 1, #themes)
end
themeButton.Text = themes[themeIndex].Name

setEnabled(savedSettings.enabled == true)
task.defer(updateHotbar)

if savedSettings.isCollapsed == true then
    -- Collapse after the UI and callbacks have been initialized.
    task.defer(collapse)
end
