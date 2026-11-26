--!strict
-- Esquivar con Q: dash corto hacia donde te mueves (o hacia adelante si estás quieto).
-- El movimiento se hace aquí para que responda al instante; el servidor lleva
-- las cargas con las mismas reglas (Shared/Charges) y da la invulnerabilidad.
-- También dibuja las cargas abajo al centro.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Charges = require(ReplicatedStorage.Shared.Charges)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local DODGE = AbilityData.Dodge
local KEY = Enum.KeyCode.Q

local player = Players.LocalPlayer

local DodgeController = {}

local meter = Charges.new(DODGE.Charges, DODGE.Recharge)
local dashing = false

local function dash(root: BasePart, humanoid: Humanoid)
	local direction = humanoid.MoveDirection * Vector3.new(1, 0, 1)
	if direction.Magnitude < 0.1 then
		direction = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	end
	if direction.Magnitude < 1e-3 then
		return
	end
	direction = direction.Unit
	local speed = DODGE.Distance / DODGE.Duration

	-- Velocidad horizontal fija; la vertical queda libre para la gravedad.
	local attachment = Instance.new("Attachment")
	attachment.Name = "DodgeAttachment"
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "DodgeVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	velocity.PrimaryTangentAxis = Vector3.xAxis
	velocity.SecondaryTangentAxis = Vector3.zAxis
	velocity.PlaneVelocity = Vector2.new(direction.X, direction.Z) * speed
	velocity.MaxForce = math.huge
	velocity.Parent = root

	dashing = true
	task.delay(DODGE.Duration, function()
		velocity:Destroy()
		attachment:Destroy()
		-- Frena el arrastre del dash para que no patine al terminar.
		if root.Parent then
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end
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
	Remotes.Event("Dodge"):FireServer()
	dash(root, humanoid)
end

local function buildHud(): { Frame }
	local gui = Instance.new("ScreenGui")
	gui.Name = "DodgeHud"
	gui.ResetOnSpawn = false

	local row = Instance.new("Frame")
	row.AnchorPoint = Vector2.new(0.5, 1)
	row.Position = UDim2.new(0.5, 0, 1, -24)
	row.Size = UDim2.fromOffset(DODGE.Charges * 34, 28)
	row.BackgroundTransparency = 1
	row.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = row

	local fills: { Frame } = {}
	for i = 1, DODGE.Charges do
		local pip = Instance.new("Frame")
		pip.Name = `Charge{i}`
		pip.LayoutOrder = i
		pip.Size = UDim2.fromOffset(28, 28)
		pip.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		pip.BackgroundTransparency = 0.2
		pip.ClipsDescendants = true
		pip.Parent = row
		Instance.new("UICorner", pip).CornerRadius = UDim.new(0.5, 0)

		-- El relleno sube desde abajo mientras la carga se recupera.
		local fill = Instance.new("Frame")
		fill.AnchorPoint = Vector2.new(0, 1)
		fill.Position = UDim2.fromScale(0, 1)
		fill.Size = UDim2.fromScale(1, 1)
		fill.BackgroundColor3 = Color3.fromRGB(90, 190, 255)
		fill.BorderSizePixel = 0
		fill.Parent = pip
		fills[i] = fill

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 13
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0.5
		label.Text = "Q"
		label.ZIndex = 2
		label.Parent = pip
	end

	gui.Parent = player:WaitForChild("PlayerGui")
	return fills
end

function DodgeController:Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == KEY then
			tryDodge()
		end
	end)

	local fills = buildHud()
	RunService.RenderStepped:Connect(function()
		local current = meter:Get(os.clock())
		for i, fill in fills do
			local amount = math.clamp(current - (i - 1), 0, 1)
			fill.Size = UDim2.fromScale(1, amount)
			fill.BackgroundTransparency = if amount >= 1 then 0 else 0.55
		end
	end)
end

return DodgeController
