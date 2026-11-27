--!strict
-- Selector de clase provisorio (arriba a la izquierda) para probar las 6 clases
-- mientras no existe la selección de personaje. El servidor valida y cambia
-- la clase; el arma, la barra y las habilidades se actualizan solas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local BUTTON_SIZE = Vector2.new(110, 30)
local SELECTED = Color3.fromRGB(240, 190, 50)
local IDLE = Color3.fromRGB(45, 40, 38)

local player = Players.LocalPlayer

local ClassPickerController = {}

function ClassPickerController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ClassPicker"
	gui.ResetOnSpawn = false

	local list = Instance.new("Frame")
	list.Position = UDim2.fromOffset(12, 60)
	list.Size = UDim2.fromOffset(BUTTON_SIZE.X, 0)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.BackgroundTransparency = 1
	list.Parent = gui
	-- En pantallas táctiles, más chico para no tapar el joystick.
	if UserInputService.TouchEnabled then
		local scale = Instance.new("UIScale")
		scale.Scale = 0.6
		scale.Parent = list
	end
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local title = Instance.new("TextLabel")
	title.LayoutOrder = 0
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromOffset(BUTTON_SIZE.X, 18)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0.5
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Clase (prueba)"
	title.Parent = list

	local buttons: { [string]: TextButton } = {}
	for id, class in Classes do
		local button = Instance.new("TextButton")
		button.Name = id
		button.LayoutOrder = class.Order
		button.Size = UDim2.fromOffset(BUTTON_SIZE.X, BUTTON_SIZE.Y)
		button.BackgroundColor3 = IDLE
		button.AutoButtonColor = true
		button.Font = Enum.Font.GothamBold
		button.TextSize = 14
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Text = class.Name
		button.Parent = list
		Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
		-- Franja con el color de la clase (GUIA-VISUAL.md).
		local stripe = Instance.new("Frame")
		stripe.Name = "ClassColor"
		stripe.Size = UDim2.new(0, 5, 1, -10)
		stripe.Position = UDim2.fromOffset(5, 5)
		stripe.BackgroundColor3 = class.Color
		stripe.BorderSizePixel = 0
		stripe.Parent = button
		Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 2)
		button.Activated:Connect(function()
			Remotes.Event("SelectClass"):FireServer(id)
		end)
		buttons[id] = button
	end

	local function refresh()
		local current = player:GetAttribute("Class")
		for id, button in buttons do
			local selected = id == current
			button.BackgroundColor3 = if selected then SELECTED else IDLE
			button.TextColor3 = if selected then Color3.new(0.1, 0.08, 0.05) else Color3.new(1, 1, 1)
		end
	end
	player:GetAttributeChangedSignal("Class"):Connect(refresh)
	refresh()

	gui.Parent = player:WaitForChild("PlayerGui")
end

return ClassPickerController
