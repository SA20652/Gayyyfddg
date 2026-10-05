-- DynamicHotbar.lua
-- LocalScript for your own Roblox experience.
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local old = playerGui:FindFirstChild("DynamicHotbar")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DynamicHotbar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local bar = Instance.new("Frame")
bar.Name = "Hotbar"
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 0.98, 0)
bar.Size = UDim2.new(0.78, 0, 0.14, 0)
bar.BackgroundTransparency = 1
bar.Parent = gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0.008, 0)
layout.Parent = bar

local function getTools()
	local tools = {}

	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") then
			table.insert(tools, obj)
		end
	end

	local character = player.Character
	if character then
		for _, obj in ipairs(character:GetChildren()) do
			if obj:IsA("Tool") then
				table.insert(tools, obj)
			end
		end
	end

	return tools
end

local function clearSlots()
	for _, child in ipairs(bar:GetChildren()) do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end
end

local function createHotbar()
	clearSlots()

	local tools = getTools()
	local count = #tools

	if count == 0 then
		return
	end

	-- Up to 10 visible slots. If there are more than 10 tools,
	-- only the first 10 are shown.
	local visibleCount = math.min(count, 10)
	local slotWidth = math.min(0.18, 0.9 / visibleCount)

	for index = 1, visibleCount do
		local tool = tools[index]

		local slot = Instance.new("ImageButton")
		slot.Name = "Slot_" .. index
		slot.LayoutOrder = index
		slot.Size = UDim2.new(slotWidth, 0, 0.82, 0)
		slot.BackgroundColor3 = Color3.fromRGB(235, 225, 185)
		slot.BackgroundTransparency = 0.12
		slot.BorderSizePixel = 2
		slot.BorderColor3 = Color3.fromRGB(120, 105, 75)
		slot.AutoButtonColor = true
		slot.Image = ""
		slot.ScaleType = Enum.ScaleType.Fit
		slot.Parent = bar

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.06, 0)
		corner.Parent = slot

		local number = Instance.new("TextLabel")
		number.Name = "Number"
		number.BackgroundTransparency = 1
		number.Position = UDim2.new(0.04, 0, 0.02, 0)
		number.Size = UDim2.new(0.25, 0, 0.25, 0)
		number.Text = tostring(index)
		number.TextScaled = true
		number.TextColor3 = Color3.fromRGB(40, 40, 40)
		number.Font = Enum.Font.GothamBold
		number.Parent = slot

		if tool.TextureId and tool.TextureId ~= "" then
			slot.Image = tool.TextureId
		end

		slot.Activated:Connect(function()
			local character = player.Character
			if not character then return end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end

			if tool.Parent == backpack then
				humanoid:EquipTool(tool)
			elseif tool.Parent == character then
				humanoid:UnequipTools()
			end
		end)
	end
end

local function refresh()
	task.defer(createHotbar)
end

backpack.ChildAdded:Connect(function(obj)
	if obj:IsA("Tool") then
		refresh()
	end
end)

backpack.ChildRemoved:Connect(function(obj)
	if obj:IsA("Tool") then
		refresh()
	end
end)

local function connectCharacter(character)
	character.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then
			refresh()
		end
	end)

	character.ChildRemoved:Connect(function(obj)
		if obj:IsA("Tool") then
			refresh()
		end
	end)

	refresh()
end

player.CharacterAdded:Connect(connectCharacter)

if player.Character then
	connectCharacter(player.Character)
else
	refresh()
end
