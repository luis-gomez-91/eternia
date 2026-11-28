--!strict
-- Esquivar con Q: dash corto hacia donde te mueves (o hacia adelante si estás quieto).
-- Cancela la carga de un hechizo.
-- El movimiento se hace aquí para que responda al instante; el servidor lleva
-- las cargas con las mismas reglas (Shared/Charges) y da la invulnerabilidad.
-- También dibuja las cargas: dos puntos a la izquierda de la barra de vida.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Charges = require(ReplicatedStorage.Shared.Charges)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Dash = require(script.Parent.Parent.Util.Dash)
local AbilityController = require(script.Parent.AbilityController)
local FeedbackController = require(script.Parent.FeedbackController)

local DODGE = AbilityData.Dodge
local KEY = Enum.KeyCode.Q

local player = Players.LocalPlayer

local DodgeController = {}

local meter = Charges.new(DODGE.Charges, DODGE.Recharge)
local dashing = false

local function dash(root: BasePart, humanoid: Humanoid)
	local direction = humanoid.MoveDirection
	if direction.Magnitude < 0.1 then
		direction = root.CFrame.LookVector
	end
	dashing = Dash.Start(root, direction, DODGE.Distance / DODGE.Duration, DODGE.Duration, function()
		dashing = false
	end)
end

local function tryDodge()
	if dashing then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return
	end
	if not meter:TryConsume(os.clock()) then
		return
	end
	-- Esquivar cancela la carga de un hechizo (antes del dash, que devuelve la velocidad).
	AbilityController.CancelCast()
	Remotes.Event("Dodge"):FireServer()
	dash(root, humanoid)
	FeedbackController.PlayLocal(DODGE.Cue)
end

-- Puntos de las cargas, pegados a la izquierda de las barras de vida y recurso.
local PIP_SIZE = 10
local PIP_COLOR = Color3.fromRGB(140, 210, 255) -- azul cielo de esquivar (GUIA-VISUAL.md)
-- Mientras se recupera, gris acero: se distingue de una carga lista.
local PIP_CHARGING_COLOR = Color3.fromRGB(120, 130, 145)

local function buildHud(bars: Frame): { Frame }
	local row = Instance.new("Frame")
	row.Name = "DodgeCharges"
	row.AnchorPoint = Vector2.new(1, 0)
	row.Position = UDim2.fromOffset(-6, 0)
	-- Alto de las dos barras juntas (vida y recurso), para centrar los puntos.
	row.Size = UDim2.new(0, DODGE.Charges * (PIP_SIZE + 4), 1, 6)
	row.BackgroundTransparency = 1
	row.Parent = bars

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 4)
	layout.Parent = row

	local fills: { Frame } = {}
	for i = 1, DODGE.Charges do
		local pip = Instance.new("Frame")
		pip.Name = `Charge{i}`
		pip.LayoutOrder = i
		pip.Size = UDim2.fromOffset(PIP_SIZE, PIP_SIZE)
		pip.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		pip.BackgroundTransparency = 0.2
		pip.Parent = row
		Instance.new("UICorner", pip).CornerRadius = UDim.new(0.5, 0)

		-- El relleno crece desde el centro mientras la carga se recupera.
		local fill = Instance.new("Frame")
		fill.AnchorPoint = Vector2.new(0.5, 0.5)
		fill.Position = UDim2.fromScale(0.5, 0.5)
		fill.Size = UDim2.fromScale(1, 1)
		fill.BackgroundColor3 = PIP_COLOR
		fill.BorderSizePixel = 0
		fill.Parent = pip
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0.5, 0)
		fills[i] = fill
	end
	return fills
end

-- Un dash rápido contra algo (p. ej. la base de un muñeco) hace tropezar al
-- Humanoid y lo deja tirado. En este juego nunca se cae por choques.
local function preventTripping(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end
end

-- Esquivar (tecla Q o botón táctil).
DodgeController.Dodge = tryDodge

-- Cargas actuales (con fracción de la que se recupera) para los botones táctiles.
function DodgeController.Charges(): number
	return meter:Get(os.clock())
end

function DodgeController:Start()
	player.CharacterAdded:Connect(preventTripping)
	if player.Character then
		task.spawn(preventTripping, player.Character)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == KEY then
			tryDodge()
		end
	end)

	-- En pantallas táctiles las cargas se ven en el botón de esquivar.
	if UserInputService.TouchEnabled then
		return
	end
	local bars = AbilityController.Bars()
	while not bars do
		task.wait()
		bars = AbilityController.Bars()
	end
	local fills = buildHud(bars)
	RunService.RenderStepped:Connect(function()
		local current = meter:Get(os.clock())
		for i, fill in fills do
			local amount = math.clamp(current - (i - 1), 0, 1)
			fill.Size = UDim2.fromScale(amount, amount)
			fill.BackgroundColor3 = if amount >= 1 then PIP_COLOR else PIP_CHARGING_COLOR
			fill.BackgroundTransparency = 0
		end
	end)
end

return DodgeController
