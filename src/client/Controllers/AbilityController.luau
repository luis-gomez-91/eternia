--!strict
-- Activas de clase con las teclas 1, 2 y 3, y su barra en pantalla
-- (Energía arriba y un espacio por habilidad con su tiempo de espera).
-- El cliente predice esperas y Energía con los mismos datos que el servidor
-- para no mandar pedidos que se van a rechazar; el servidor sigue decidiendo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Targeting = require(ReplicatedStorage.Shared.Targeting)
local Dash = require(script.Parent.Parent.Util.Dash)
local FeedbackController = require(script.Parent.FeedbackController)

local KEYS = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three }
local SLOT_SIZE = 56
-- Igual que en el servidor: la Embestida se detiene a esta distancia del borde.
local CHARGE_STOP_DISTANCE = 2.5

local player = Players.LocalPlayer

local AbilityController = {}

local readyAt: { [string]: number } = {}
local globalReadyAt = 0

local function getClass(): Classes.ClassDef?
	local classId = player:GetAttribute("Class")
	return if typeof(classId) == "string" then Classes[classId] else nil
end

local function getEnergy(): (number, number)
	local energy = player:GetAttribute("Energy")
	local max = player:GetAttribute("MaxEnergy")
	return if typeof(energy) == "number" then energy else 0, if typeof(max) == "number" then max else 0
end

local function getAliveRoot(): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

-- Embestida: gira hacia el objetivo y avanza hasta quedar a su lado.
local function startCharge(root: BasePart, def: AbilityData.ActiveDef, target: Model)
	local targetPos = target:GetPivot().Position
	local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
	local offset = flatTarget - root.Position
	local travel = math.max(0, offset.Magnitude - Targeting.Radius(target) - CHARGE_STOP_DISTANCE)
	root.CFrame = CFrame.lookAt(root.Position, flatTarget)
	local speed = def.Speed :: number
	Dash.Start(root, offset, speed, travel / speed)
end

local function tryUse(slot: number)
	local class = getClass()
	local abilityId = class and class.Actives[slot]
	local def = abilityId and AbilityData.Actives[abilityId]
	local root = getAliveRoot()
	if not abilityId or not def or not root then
		return
	end

	local now = os.clock()
	if now < globalReadyAt or now < (readyAt[abilityId] or 0) then
		return
	end
	if getEnergy() < def.Cost then
		return
	end

	local target: Model? = nil
	if def.Kind == "Charge" then
		target = Targeting.InCone(root.CFrame, def.Range :: number, def.ArcDot :: number)[1]
		if not target then
			return -- nadie a quien embestir: no se gasta
		end
	end

	Remotes.Event("UseAbility"):FireServer(abilityId, target)
	readyAt[abilityId] = now + def.Cooldown
	globalReadyAt = now + AbilityData.GlobalCooldown

	if def.Kind == "Charge" and target then
		startCharge(root, def, target)
	end
	FeedbackController.PlayLocal(def.Cue)
end

type Slot = { frame: Frame, shade: Frame, timer: TextLabel }

local function buildHud(): (Frame, { Slot })
	local gui = Instance.new("ScreenGui")
	gui.Name = "AbilityHud"
	gui.ResetOnSpawn = false

	local root = Instance.new("Frame")
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.Position = UDim2.new(0.5, 0, 1, -62)
	root.Size = UDim2.fromOffset(#KEYS * (SLOT_SIZE + 8), SLOT_SIZE + 16)
	root.BackgroundTransparency = 1
	root.Parent = gui

	-- Energía
	local energyBack = Instance.new("Frame")
	energyBack.Size = UDim2.new(1, 0, 0, 8)
	energyBack.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	energyBack.BorderSizePixel = 0
	energyBack.Parent = root
	local energyFill = Instance.new("Frame")
	energyFill.Name = "Fill"
	energyFill.BackgroundColor3 = Color3.fromRGB(240, 190, 50)
	energyFill.BorderSizePixel = 0
	energyFill.Size = UDim2.fromScale(0, 1)
	energyFill.Parent = energyBack

	local row = Instance.new("Frame")
	row.Position = UDim2.fromOffset(0, 16)
	row.Size = UDim2.new(1, 0, 0, SLOT_SIZE)
	row.BackgroundTransparency = 1
	row.Parent = root
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = row

	local slots: { Slot } = {}
	for i in KEYS do
		local frame = Instance.new("Frame")
		frame.Name = `Slot{i}`
		frame.LayoutOrder = i
		frame.Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE)
		frame.BackgroundColor3 = Color3.fromRGB(60, 50, 45)
		frame.ClipsDescendants = true
		frame.Parent = row
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

		local name = Instance.new("TextLabel")
		name.Name = "AbilityName"
		name.BackgroundTransparency = 1
		name.Position = UDim2.fromOffset(3, 0)
		name.Size = UDim2.new(1, -6, 1, -4)
		name.Font = Enum.Font.GothamBold
		-- Se achica para que palabras largas ("Embestida") no se corten.
		name.TextScaled = true
		name.TextWrapped = true
		local sizeLimit = Instance.new("UITextSizeConstraint")
		sizeLimit.MaxTextSize = 11
		sizeLimit.Parent = name
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextYAlignment = Enum.TextYAlignment.Bottom
		name.Parent = frame

		local key = Instance.new("TextLabel")
		key.BackgroundTransparency = 1
		key.Position = UDim2.fromOffset(5, 3)
		key.Size = UDim2.fromOffset(14, 14)
		key.Font = Enum.Font.GothamBlack
		key.TextSize = 13
		key.TextColor3 = Color3.fromRGB(240, 190, 50)
		key.TextXAlignment = Enum.TextXAlignment.Left
		key.Text = tostring(i)
		key.ZIndex = 3
		key.Parent = frame

		-- Sombra que baja mientras dura la espera.
		local shade = Instance.new("Frame")
		shade.BackgroundColor3 = Color3.new(0, 0, 0)
		shade.BackgroundTransparency = 0.35
		shade.BorderSizePixel = 0
		shade.Size = UDim2.fromScale(1, 0)
		shade.ZIndex = 2
		shade.Parent = frame

		local timer = Instance.new("TextLabel")
		timer.BackgroundTransparency = 1
		timer.Size = UDim2.fromScale(1, 1)
		timer.Font = Enum.Font.GothamBlack
		timer.TextSize = 20
		timer.TextColor3 = Color3.new(1, 1, 1)
		timer.TextStrokeTransparency = 0.4
		timer.ZIndex = 3
		timer.Parent = frame

		slots[i] = { frame = frame, shade = shade, timer = timer }
	end

	gui.Parent = player:WaitForChild("PlayerGui")
	return energyFill, slots
end

function AbilityController:Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		local slot = table.find(KEYS, input.KeyCode)
		if slot then
			tryUse(slot)
		end
	end)

	local energyFill, slots = buildHud()
	RunService.RenderStepped:Connect(function()
		local energy, maxEnergy = getEnergy()
		energyFill.Size = UDim2.fromScale(if maxEnergy > 0 then energy / maxEnergy else 0, 1)

		local class = getClass()
		local now = os.clock()
		for i, slot in slots do
			local abilityId = class and class.Actives[i]
			local def = abilityId and AbilityData.Actives[abilityId]
			slot.frame.Visible = def ~= nil
			if not abilityId or not def then
				continue
			end
			(slot.frame:FindFirstChild("AbilityName") :: TextLabel).Text = def.Name

			local remaining = math.max((readyAt[abilityId] or 0) - now, globalReadyAt - now, 0)
			local total = if (readyAt[abilityId] or 0) - now >= globalReadyAt - now
				then def.Cooldown
				else AbilityData.GlobalCooldown
			slot.shade.Size = UDim2.fromScale(1, if remaining > 0 then remaining / total else 0)
			slot.timer.Text = if remaining >= 1 then tostring(math.ceil(remaining)) else ""
			-- Sin Energía suficiente: el espacio se ve apagado.
			slot.frame.BackgroundTransparency = if energy < def.Cost then 0.6 else 0
		end
	end)
end

return AbilityController
