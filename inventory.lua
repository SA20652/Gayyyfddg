
-- LocalScript
-- Помести в StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileInventory10"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Нижняя панель
local inventory = Instance.new("Frame")
inventory.Name = "Inventory"
inventory.AnchorPoint = Vector2.new(0.5, 1)
inventory.Position = UDim2.new(0.5, 0, 0.98, 0)
inventory.Size = UDim2.new(0.82, 0, 0.14, 0)
inventory.BackgroundTransparency = 1
inventory.Parent = gui

-- Сетка
local grid = Instance.new("UIGridLayout")
grid.FillDirection = Enum.FillDirection.Horizontal
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.VerticalAlignment = Enum.VerticalAlignment.Center
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.CellPadding = UDim2.new(0.008, 0, 0, 0)
grid.CellSize = UDim2.new(0.092, 0, 0.82, 0)
grid.Parent = inventory

-- 10 слотов
for i = 1, 10 do
	local slot = Instance.new("ImageButton")
	slot.Name = "Slot" .. i
	slot.LayoutOrder = i
	slot.BackgroundColor3 = Color3.fromRGB(235, 225, 185)
	slot.BackgroundTransparency = 0.12
	slot.BorderSizePixel = 2
	slot.BorderColor3 = Color3.fromRGB(120, 105, 75)
	slot.AutoButtonColor = true
	slot.Parent = inventory

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.08, 0)
	corner.Parent = slot

	-- Номер слота
	local number = Instance.new("TextLabel")
	number.BackgroundTransparency = 1
	number.Position = UDim2.new(0.04, 0, 0.02, 0)
	number.Size = UDim2.new(0.3, 0, 0.25, 0)
	number.Text = tostring(i)
	number.TextScaled = true
	number.TextColor3 = Color3.fromRGB(40, 40, 40)
	number.Font = Enum.Font.GothamBold
	number.Parent = slot

	-- Обработка нажатия
	slot.Activated:Connect(function()
		print("Выбран слот:", i)

		-- Здесь можно подключить выдачу/выбор предмета
	end)
end
