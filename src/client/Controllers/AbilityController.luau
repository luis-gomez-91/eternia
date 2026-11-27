--!strict
-- Activas con las teclas 1 a 6 y la definitiva con R, y su barra en pantalla
-- (Energía o Maná arriba, un espacio por habilidad con su tiempo de espera y
-- la definitiva con su barra de carga). Los espacios 4 a 6 son de las
-- habilidades de especialización (Fase 2): por ahora se ven bloqueados.
-- El cliente predice esperas y recurso con los mismos datos que el servidor
-- para no mandar pedidos que se van a rechazar; el servidor sigue decidiendo.
-- Los movimientos (Embestida, Parpadeo, Retirada) se hacen aquí para que
-- respondan al instante, igual que esquivar.
--
-- Hechizos con carga (CastTime): al apretar empieza la carga (barra en pantalla,
-- brillo y velocidad reducida) y el hechizo sale solo al terminar. Esquivar,
-- perder el objetivo o salirse de alcance la cancelan sin gastar nada.

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
local TargetController = require(script.Parent.TargetController)

local KEYS = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
}
local ULTIMATE_KEY = Enum.KeyCode.R
-- Nivel en que se desbloquea cada habilidad de especialización (espacios 4 a 6).
local SPEC_LEVELS = { [4] = 10, [5] = 20, [6] = 30 }
local ULTIMATE_COLOR = Color3.fromRGB(255, 120, 40)
-- Ancho de la barra de recurso en pantallas táctiles.
local TOUCH_BAR_WIDTH = 200
-- Abajo, un poco a la izquierda del centro: lejos del arco del pulgar.
local TOUCH_BAR_POSITION = UDim2.new(0.4, 0, 1, -40)
local RESOURCE_COLORS = {
	Energy = Color3.fromRGB(240, 190, 50),
	Mana = Color3.fromRGB(70, 140, 255),
}
local RESOURCE_NAMES = { Energy = "Energía", Mana = "Maná" }
-- El Parpadeo se detiene a esta distancia de una pared.
local BLINK_WALL_MARGIN = 2
-- Salto de la Retirada: velocidad hacia arriba al empezar.
local LEAP_UP_SPEED = 28
local SLOT_SIZE = 56
-- Igual que en el servidor: la Embestida se detiene a esta distancia del borde.
local CHARGE_STOP_DISTANCE = 2.5
-- Durante la carga, el objetivo puede alejarse esto más allá del alcance antes de
-- cancelar (un poco menos que el margen del servidor, para que no la rechace).
local CAST_RANGE_TOLERANCE = 2
-- Cualquier dirección: el objetivo no tiene que estar al frente mientras se carga.
local ANY_DIRECTION = -1
local CAST_BAR_SIZE = Vector2.new(220, 20)
local CAST_COLOR = Color3.fromRGB(255, 150, 50)

local player = Players.LocalPlayer

local AbilityController = {}

local readyAt: { [string]: number } = {}
local globalReadyAt = 0

type Cast = {
	abilityId: string,
	def: AbilityData.ActiveDef,
	target: Model?,
	startedAt: number,
	humanoid: Humanoid,
	baseSpeed: number, -- velocidad antes de la carga, para devolverla
}
local cast: Cast? = nil

local function getClass(): Classes.ClassDef?
	local classId = player:GetAttribute("Class")
	return if typeof(classId) == "string" then Classes[classId] else nil
end

local function getResource(): (number, number)
	local value = player:GetAttribute("Resource")
	local max = player:GetAttribute("MaxResource")
	return if typeof(value) == "number" then value else 0, if typeof(max) == "number" then max else 0
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

-- Parpadeo: aparece `distance` studs al frente, antes si hay una pared.
local function blink(root: BasePart, distance: number)
	local look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	if look.Magnitude < 1e-3 then
		return
	end
	look = look.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character :: Instance }
	local hit = workspace:Raycast(root.Position, look * distance, params)
	local travel = if hit then math.max(0, hit.Distance - BLINK_WALL_MARGIN) else distance
	FeedbackController.PlayLocal("BlinkOut")
	root.CFrame = root.CFrame + look * travel
	root.AssemblyLinearVelocity = Vector3.zero
end

-- Retirada: salto hacia atrás.
local function leap(root: BasePart, def: AbilityData.ActiveDef)
	local back = -root.CFrame.LookVector
	local duration = def.Duration :: number
	root.AssemblyLinearVelocity = Vector3.new(0, LEAP_UP_SPEED, 0)
	Dash.Start(root, back, (def.Distance :: number) / duration, duration)
end

local function getUltimateCharge(): number
	local value = player:GetAttribute("UltimateCharge")
	return if typeof(value) == "number" then value else 0
end

-- Habilidad del espacio `slot` (1 a 6) o la definitiva ("Ultimate").
local function abilityAt(slot: number | "Ultimate"): (string?, AbilityData.ActiveDef?)
	local class = getClass()
	if not class then
		return nil, nil
	end
	local abilityId = if slot == "Ultimate" then class.Ultimate else class.Actives[slot]
	return abilityId, abilityId and AbilityData.Actives[abilityId]
end

-- Lanza la activa: avisa al servidor, empieza la espera y hace el movimiento
-- y la señal en el acto.
local function release(root: BasePart, abilityId: string, def: AbilityData.ActiveDef, target: Model?)
	local now = os.clock()
	Remotes.Event("UseAbility"):FireServer(abilityId, target)
	readyAt[abilityId] = now + def.Cooldown
	globalReadyAt = now + AbilityData.GlobalCooldown

	if def.Kind == "Charge" and target then
		startCharge(root, def, target)
	elseif def.Kind == "Blink" then
		blink(root, def.Distance :: number)
	elseif def.Kind == "Leap" then
		leap(root, def)
	end
	FeedbackController.PlayLocal(def.Cue, target)
end

-- Termina la carga y devuelve la velocidad normal.
local function endCast(): Cast?
	local current = cast
	if not current then
		return nil
	end
	cast = nil
	if current.humanoid.Parent then
		current.humanoid.WalkSpeed = current.baseSpeed
	end
	return current
end

-- Cancela la carga en curso (esquivar, objetivo perdido): no gasta nada.
local function cancelCast()
	if endCast() then
		Remotes.Event("CancelCast"):FireServer()
		FeedbackController.PlayLocal("CastCancel")
	end
end

local function startCast(abilityId: string, def: AbilityData.ActiveDef, target: Model?)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	Remotes.Event("StartCast"):FireServer(abilityId, target)
	cast = {
		abilityId = abilityId,
		def = def,
		target = target,
		startedAt = os.clock(),
		humanoid = humanoid,
		baseSpeed = humanoid.WalkSpeed,
	}
	humanoid.WalkSpeed *= def.CastMove or AbilityData.CastMove
	FeedbackController.PlayLocal(def.CastCue, target)
end

-- Cada fotograma: cancela si se perdió el objetivo (o se movió y la habilidad
-- no lo permite) y lanza el hechizo al completar la carga.
local function updateCast()
	local current = cast
	if not current then
		return
	end
	local root = getAliveRoot()
	if not root or current.humanoid.Health <= 0 then
		cancelCast()
		return
	end
	local def = current.def
	local target = current.target
	if target then
		local range = (def.Range or 0) + CAST_RANGE_TOLERANCE
		if not Targeting.IsAlive(target) or not Targeting.Distance(target, root.CFrame, range, ANY_DIRECTION) then
			cancelCast()
			return
		end
	end
	if def.CastMoveCancels and current.humanoid.MoveDirection.Magnitude > 0.1 then
		cancelCast()
		return
	end
	if os.clock() - current.startedAt < (def.CastTime :: number) then
		return
	end
	endCast()
	if target then
		local position = target:GetPivot().Position
		local flat = Vector3.new(position.X, root.Position.Y, position.Z)
		if (flat - root.Position).Magnitude > 0.1 then
			root.CFrame = CFrame.lookAt(root.Position, flat)
		end
	end
	release(root, current.abilityId, def, target)
end

local function tryUse(slot: number | "Ultimate")
	if cast then
		return -- una carga a la vez; esquivar la cancela
	end
	local abilityId, def = abilityAt(slot)
	local root = getAliveRoot()
	if not abilityId or not def or not root then
		return
	end

	local now = os.clock()
	if now < globalReadyAt or now < (readyAt[abilityId] or 0) then
		return
	end
	if slot == "Ultimate" then
		if getUltimateCharge() < 1 then
			return
		end
	elseif getResource() < def.Cost then
		return
	end

	-- Con objetivo fijado, la habilidad va siempre a él: el personaje gira hacia
	-- él, y si está fuera de alcance no se usa (no salta a otro enemigo más cerca).
	-- Sin objetivo fijado, el primero al frente (la misma regla que el servidor).
	-- Las de área frente a uno (cono) no necesitan objetivo: solo giran si está cerca.
	local target: Model? = nil
	if def.Range and not AbilityData.NeedsTarget(def) then
		target = TargetController.FaceIfWithin(def.Range)
	elseif def.Range then
		if TargetController.Get() then
			target = TargetController.FaceIfWithin(def.Range)
			if not target then
				return -- el objetivo fijado está lejos: no se gasta
			end
		else
			target = Targeting.InCone(root.CFrame, def.Range, def.ArcDot or 0.5)[1]
		end
	end
	if AbilityData.NeedsTarget(def) and not target then
		return -- nadie al alcance: no se gasta
	end

	if def.CastTime then
		startCast(abilityId, def, target)
	else
		release(root, abilityId, def, target)
	end
end

-- Usar un espacio (1 a 6) o la definitiva desde otro control (botones táctiles).
AbilityController.Use = tryUse

-- Para esquivar y el ataque básico: cancelar la carga y saber si hay una en curso.
AbilityController.CancelCast = cancelCast

function AbilityController.IsCasting(): boolean
	return cast ~= nil
end

-- Barra de carga al centro, debajo del personaje.
local function buildCastBar(): (Frame, Frame, TextLabel)
	local gui = Instance.new("ScreenGui")
	gui.Name = "CastBar"
	gui.ResetOnSpawn = false

	local back = Instance.new("Frame")
	back.AnchorPoint = Vector2.new(0.5, 0.5)
	back.Position = UDim2.fromScale(0.5, 0.66)
	back.Size = UDim2.fromOffset(CAST_BAR_SIZE.X, CAST_BAR_SIZE.Y)
	back.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	back.BackgroundTransparency = 0.2
	back.BorderSizePixel = 0
	back.Visible = false
	back.Parent = gui
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke")
	stroke.Color = CAST_COLOR
	stroke.Thickness = 1.5
	stroke.Parent = back

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = CAST_COLOR
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = back
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.ZIndex = 2
	label.Parent = back

	gui.Parent = player:WaitForChild("PlayerGui")
	return back, fill, label
end

export type SlotInfo = {
	name: string,
	remaining: number, -- segundos de espera que faltan
	total: number, -- espera completa de la que se está descontando
	usable: boolean, -- hay recurso (o la barra de definitiva está llena)
	charge: number?, -- definitiva: carga de 0 a 1
}

-- Estado de un espacio para dibujarlo, o nil si está vacío.
function AbilityController.Info(slot: number | "Ultimate"): SlotInfo?
	local abilityId, def = abilityAt(slot)
	if not abilityId or not def then
		return nil
	end
	local now = os.clock()
	local own = (readyAt[abilityId] or 0) - now
	local global = globalReadyAt - now
	local charge = if slot == "Ultimate" then getUltimateCharge() else nil
	return {
		name = def.Name,
		remaining = math.max(own, global, 0),
		total = if own >= global then def.Cooldown else AbilityData.GlobalCooldown,
		usable = if charge then charge >= 1 else getResource() >= def.Cost,
		charge = charge,
	}
end

type Slot = { frame: Frame, shade: Frame, timer: TextLabel, name: TextLabel, charge: Frame? }

local function buildHud(): (Frame, TextLabel, { [number | "Ultimate"]: Slot }, Frame)
	local gui = Instance.new("ScreenGui")
	gui.Name = "AbilityHud"
	gui.ResetOnSpawn = false

	local root = Instance.new("Frame")
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.Position = UDim2.new(0.5, 0, 1, -62)
	root.Size = UDim2.fromOffset((#KEYS + 1) * (SLOT_SIZE + 8) + 12, SLOT_SIZE + 16)
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
	local energyText = Instance.new("TextLabel")
	energyText.BackgroundTransparency = 1
	energyText.AnchorPoint = Vector2.new(0, 1)
	energyText.Position = UDim2.fromOffset(0, -1)
	energyText.Size = UDim2.new(1, 0, 0, 12)
	energyText.Font = Enum.Font.GothamBold
	energyText.TextSize = 11
	energyText.TextColor3 = Color3.new(1, 1, 1)
	energyText.TextStrokeTransparency = 0.5
	energyText.TextXAlignment = Enum.TextXAlignment.Left
	energyText.Parent = energyBack

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

	local slots: { [number | "Ultimate"]: Slot } = {}
	local order: { number | "Ultimate" } = { 1, 2, 3, 4, 5, 6, "Ultimate" }
	for index, i in order do
		local isUltimate = i == "Ultimate"
		local frame = Instance.new("Frame")
		frame.Name = `Slot{i}`
		frame.LayoutOrder = index
		if isUltimate then
			frame.LayoutOrder = index + 1 -- después del separador
		end
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
		key.Text = if isUltimate then "R" else tostring(i)
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

		-- Definitiva: barra que sube desde abajo mientras se carga.
		local charge: Frame? = nil
		if isUltimate then
			frame.BackgroundColor3 = Color3.fromRGB(70, 40, 30)
			local fill = Instance.new("Frame")
			fill.AnchorPoint = Vector2.new(0, 1)
			fill.Position = UDim2.fromScale(0, 1)
			fill.Size = UDim2.fromScale(1, 0)
			fill.BackgroundColor3 = ULTIMATE_COLOR
			fill.BackgroundTransparency = 0.45
			fill.BorderSizePixel = 0
			fill.ZIndex = 0
			fill.Parent = frame
			local stroke = Instance.new("UIStroke")
			stroke.Color = ULTIMATE_COLOR
			stroke.Thickness = 2
			stroke.Parent = frame
			charge = fill
		end

		slots[i] = { frame = frame, shade = shade, timer = timer, name = name, charge = charge }
	end
	-- Espacio vacío entre la barra de 6 y la definitiva.
	local spacer = Instance.new("Frame")
	spacer.BackgroundTransparency = 1
	spacer.Size = UDim2.fromOffset(4, SLOT_SIZE)
	spacer.LayoutOrder = #order
	spacer.Parent = row

	gui.Parent = player:WaitForChild("PlayerGui")
	return energyFill, energyText, slots, row
end

function AbilityController:Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		local slot = table.find(KEYS, input.KeyCode)
		if slot then
			tryUse(slot)
		elseif input.KeyCode == ULTIMATE_KEY then
			tryUse("Ultimate")
		end
	end)

	local castBack, castFill, castLabel = buildCastBar()
	RunService.Heartbeat:Connect(updateCast)
	player.CharacterAdded:Connect(function()
		endCast()
	end)

	local energyFill, energyText, slots, row = buildHud()
	local hud = row.Parent :: Frame
	local hudSize = hud.Size
	local hudPosition = hud.Position
	RunService.RenderStepped:Connect(function()
		local current = cast
		castBack.Visible = current ~= nil
		if current then
			local progress = (os.clock() - current.startedAt) / (current.def.CastTime :: number)
			castFill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
			castLabel.Text = current.def.Name
		end

		local energy, maxEnergy = getResource()
		energyFill.Size = UDim2.fromScale(if maxEnergy > 0 then energy / maxEnergy else 0, 1)

		local class = getClass()
		local kind = if class then class.Resource else "Energy"
		energyFill.BackgroundColor3 = RESOURCE_COLORS[kind]
		energyText.Text = `{RESOURCE_NAMES[kind]} {math.floor(energy)}`
		-- En pantallas táctiles las habilidades están en los botones del pulgar:
		-- queda solo la barra de recurso, angosta para no pasar bajo el arco.
		local touch = UserInputService.TouchEnabled
		row.Visible = not touch
		hud.Size = if touch then UDim2.fromOffset(TOUCH_BAR_WIDTH, hud.Size.Y.Offset) else hudSize
		hud.Position = if touch then TOUCH_BAR_POSITION else hudPosition
		for i, slot in slots do
			local info = AbilityController.Info(i)
			local specLevel = if typeof(i) == "number" then SPEC_LEVELS[i] else nil
			slot.frame.Visible = info ~= nil or specLevel ~= nil
			if not info then
				-- Bloqueado hasta la especialización.
				slot.name.Text = if specLevel then `Nv {specLevel}` else ""
				slot.frame.BackgroundTransparency = 0.7
				slot.shade.Size = UDim2.fromScale(1, 0)
				slot.timer.Text = ""
				continue
			end
			slot.name.Text = info.name
			slot.shade.Size = UDim2.fromScale(1, if info.remaining > 0 then info.remaining / info.total else 0)
			slot.timer.Text = if info.remaining >= 1 then tostring(math.ceil(info.remaining)) else ""
			local charge = slot.charge
			if charge and info.charge then
				charge.Size = UDim2.fromScale(1, info.charge)
				-- Llena: late para avisar que se puede usar.
				charge.BackgroundTransparency = if info.charge >= 1 then 0.25 + 0.2 * math.sin(os.clock() * 6) else 0.45
				slot.frame.BackgroundTransparency = 0
			else
				-- Sin recurso suficiente: el espacio se ve apagado.
				slot.frame.BackgroundTransparency = if info.usable then 0 else 0.6
			end
		end
	end)
end

return AbilityController
