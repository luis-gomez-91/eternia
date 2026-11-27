--!strict
-- Combate validado en servidor. El cliente solo dice "quiero usar X" (y, si hace
-- falta, a quién); el servidor revisa clase, distancia, ritmo, tiempos de espera
-- y recurso, y aplica el resultado.
--
-- Definitiva: la de la clase (Classes.Ultimate) se usa con la barra llena
-- (UltimateService) en vez de gastar recurso.
--
-- Recurso: atributos Resource y MaxResource del jugador (Energía o Maná según la
-- clase, ver Data/Classes). La Energía la genera el ataque básico; el Maná se
-- recupera solo y un poco con el ataque básico. Las activas lo gastan.
--
-- Hechizos con carga (CastTime): el cliente avisa al empezar (StartCast) y
-- manda UseAbility al terminar. El servidor revisa que la carga haya durado lo
-- que dice la habilidad y que no haya esquivado en medio; si no, la ignora.
-- Cancelar no cobra nada ni empieza la espera.
--
-- Clase: atributo Class. Mientras no exista la selección de personaje, el
-- jugador la cambia con el selector provisorio (remoto SelectClass).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Targeting = require(ReplicatedStorage.Shared.Targeting)
local CueService = require(script.Parent.CueService)
local DamageService = require(script.Parent.DamageService)
local UltimateService = require(script.Parent.UltimateService)

type ActiveDef = AbilityData.ActiveDef

-- Margen para el jitter de red en ritmos y tiempos de espera.
local TIMING_TOLERANCE = 0.1
-- Margen de distancia para objetivos que elige el cliente (se movieron un poco).
local TARGET_RANGE_TOLERANCE = 3
-- Los objetivos que elige el cliente pueden estar en cualquier dirección: el
-- personaje gira hacia ellos en su cliente y ese giro llega después.
local ANY_DIRECTION = -1
-- La Embestida se detiene a esta distancia del borde del objetivo.
local CHARGE_STOP_DISTANCE = 2.5
-- Clase por defecto hasta que exista la selección de personaje.
local DEFAULT_CLASS = "Warrior"
-- Cada cuánto se recupera el Maná.
local REGEN_INTERVAL = 0.5
-- Margen de latencia para el tiempo de carga de un hechizo.
local CAST_TOLERANCE = 0.15
-- Atributo del personaje que pone DodgeService: fin de la invulnerabilidad del esquive.
local INVULNERABLE_ATTRIBUTE = "InvulnerableUntil"

type Cast = {
	abilityId: string,
	startedAt: number, -- os.clock() del servidor
	serverStart: number, -- workspace:GetServerTimeNow(), para compararlo con el esquive
}

type PlayerState = {
	comboIndex: number,
	lastSwing: number,
	readyAt: { [string]: number }, -- tiempo de espera de cada activa
	globalReadyAt: number,
	buffUntil: number,
	buffBonus: number,
	cast: Cast?, -- hechizo que está cargando
}

local CombatService = {}

local states: { [Player]: PlayerState } = {}

local function getState(player: Player): PlayerState
	local state = states[player]
	if not state then
		state = {
			comboIndex = 0,
			lastSwing = -math.huge,
			readyAt = {},
			globalReadyAt = 0,
			buffUntil = 0,
			buffBonus = 0,
		}
		states[player] = state
	end
	return state
end

local function getClass(player: Player): Classes.ClassDef?
	local classId = player:GetAttribute("Class")
	return if typeof(classId) == "string" then Classes[classId] else nil
end

local function setClass(player: Player, classId: string)
	local class = Classes[classId]
	states[player] = nil -- combo, esperas y bonos no pasan de una clase a otra
	player:SetAttribute("Class", classId)
	player:SetAttribute("ResourceKind", class.Resource)
	player:SetAttribute("MaxResource", class.MaxResource)
	player:SetAttribute("Resource", if class.Resource == "Mana" then class.MaxResource else 0)
end

local function getResource(player: Player): number
	local value = player:GetAttribute("Resource")
	return if typeof(value) == "number" then value else 0
end

local function addResource(player: Player, amount: number)
	local max = player:GetAttribute("MaxResource")
	local cap = if typeof(max) == "number" then max else 0
	player:SetAttribute("Resource", math.clamp(getResource(player) + amount, 0, cap))
end

local function getAliveRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

-- Daño base con bonos activos y tirada de crítico.
local function hit(player: Player, state: PlayerState, target: Model, base: number, impact: string?): number
	local multiplier = if os.clock() < state.buffUntil then 1 + state.buffBonus else 1
	local crit = math.random() < AbilityData.BaseCritChance
	local amount = base * multiplier * (if crit then 2 else 1)
	return DamageService.Apply(target, math.floor(amount + 0.5), crit, player, { Impact = impact })
end

-- Cura una fracción de la vida máxima al jugador y a los aliados a menos de `radius`.
local function healAround(player: Player, root: BasePart, fraction: number, radius: number)
	for _, other in Players:GetPlayers() do
		local character = other.Character
		local otherRoot = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not character or not otherRoot or not otherRoot:IsA("BasePart") or not humanoid then
			continue
		end
		if other == player or (otherRoot.Position - root.Position).Magnitude <= radius then
			DamageService.Heal(character, math.floor(humanoid.MaxHealth * fraction + 0.5), player)
		end
	end
end

-- El objetivo que mandó el cliente si es válido; si no, el primero en el cono.
local function resolveTarget(root: BasePart, range: number, arcDot: number, target: unknown): Model?
	if typeof(target) == "Instance" and Targeting.IsAlive(target) then
		local enemy = target :: Model
		if Targeting.Distance(enemy, root.CFrame, range + TARGET_RANGE_TOLERANCE, ANY_DIRECTION) then
			return enemy
		end
	end
	return Targeting.InCone(root.CFrame, range, arcDot)[1]
end

-- Segundos que tarda un proyectil desde el personaje hasta el borde del objetivo.
local function travelTime(root: BasePart, target: Model, speed: number?): number
	if not speed then
		return 0
	end
	local offset = (target:GetPivot().Position - root.Position) * Vector3.new(1, 0, 1)
	return math.max(0, offset.Magnitude - Targeting.Radius(target)) / speed
end

local function applyDot(player: Player, enemy: Model, def: ActiveDef)
	local dot = def.Dot
	if not dot then
		return
	end
	for _ = 1, dot.Ticks do
		task.wait(dot.Interval)
		if not Targeting.IsAlive(enemy) then
			return
		end
		local dealt = DamageService.Apply(enemy, dot.Damage, false, player, { Impact = def.Impact, Tick = true })
		local character = player.Character
		if def.Drain and dealt > 0 and character then
			DamageService.Heal(character, math.floor(dealt * def.Drain + 0.5), player)
		end
	end
end

local function basicAttack(player: Player, target: unknown)
	local root = getAliveRoot(player)
	local class = getClass(player)
	local ability = class and AbilityData.Abilities[class.BasicAttack]
	if not root or not ability then
		return
	end

	local state = getState(player)
	local now = os.clock()
	local elapsed = now - state.lastSwing
	if state.comboIndex > 0 and elapsed < ability.Hits[state.comboIndex].Recovery - TIMING_TOLERANCE then
		return -- demasiado pronto: se ignora sin avanzar el combo
	end
	if elapsed > ability.ComboReset then
		state.comboIndex = 0
	end
	state.comboIndex = state.comboIndex % #ability.Hits + 1
	state.lastSwing = now
	local swing = ability.Hits[state.comboIndex]

	-- Un golpe al aire también avanza el combo.
	local enemy: Model?
	if ability.Kind == "Ranged" then
		enemy = resolveTarget(root, ability.Range, ability.ArcDot, target)
	else
		enemy = Targeting.InCone(root.CFrame, ability.Range, ability.ArcDot)[1]
	end
	CueService.Broadcast(player, swing.Cue, enemy)
	if not enemy then
		return
	end
	local hitEnemy = enemy
	task.delay(travelTime(root, hitEnemy, ability.Speed), function()
		if Targeting.IsAlive(hitEnemy) and hit(player, state, hitEnemy, swing.Damage, ability.Impact) > 0 then
			addResource(player, ability.ResourcePerHit)
		end
	end)
end

-- Cada tipo de activa: devuelve true si se usó (entonces se cobra y empieza la espera),
-- y el objetivo para que los demás clientes dibujen el efecto.
type Handler = (
	player: Player,
	state: PlayerState,
	root: BasePart,
	def: ActiveDef,
	target: unknown
) -> (boolean, Model?)

local activeHandlers: { [AbilityData.ActiveKind]: Handler } = {
	Cleave = function(player, state, root, def)
		for _, enemy in Targeting.InCone(root.CFrame, def.Range :: number, def.ArcDot :: number) do
			hit(player, state, enemy, def.Damage :: number, def.Impact)
		end
		return true -- al aire también gasta: es un golpe que se ve
	end,

	SelfBuff = function(player, state, _root, def)
		state.buffUntil = os.clock() + (def.Duration :: number)
		state.buffBonus = def.DamageBonus or 0
		addResource(player, def.EnergyGain or 0)
		return true
	end,

	Charge = function(player, state, root, def, target)
		-- El cliente elige el objetivo y se mueve; el servidor revisa que fuera válido.
		if typeof(target) ~= "Instance" or not Targeting.IsAlive(target) then
			return false
		end
		local enemy = target :: Model
		local dist =
			Targeting.Distance(enemy, root.CFrame, (def.Range :: number) + TARGET_RANGE_TOLERANCE, ANY_DIRECTION)
		if not dist then
			return false
		end
		-- El golpe llega cuando termina el recorrido.
		local travel = math.max(0, dist - Targeting.Radius(enemy) - CHARGE_STOP_DISTANCE)
		task.delay(travel / (def.Speed :: number), function()
			if Targeting.IsAlive(enemy) then
				hit(player, state, enemy, def.Damage :: number, def.Impact)
			end
		end)
		return true, enemy
	end,

	Strike = function(player, state, root, def, target)
		local enemy = resolveTarget(root, def.Range :: number, def.ArcDot or 0.5, target)
		if not enemy then
			return false
		end
		local primary = enemy
		task.delay((def.Delay or 0) + travelTime(root, primary, def.Speed), function()
			if not Targeting.IsAlive(primary) then
				return
			end
			local position = primary:GetPivot().Position
			if (def.Damage or 0) > 0 then
				local dealt = hit(player, state, primary, def.Damage :: number, def.Impact)
				local character = player.Character
				if def.Drain and dealt > 0 and character then
					DamageService.Heal(character, math.floor(dealt * def.Drain + 0.5), player)
				end
			end
			if def.SplashDamage and def.Radius then
				for _, other in Targeting.InRadius(position, def.Radius) do
					if other ~= primary then
						hit(player, state, other, def.SplashDamage, def.Impact)
					end
				end
			end
			applyDot(player, primary, def)
		end)
		return true, enemy
	end,

	Line = function(player, state, root, def)
		local origin = root.CFrame
		for _, entry in Targeting.InLine(origin, def.Range :: number, def.Width :: number) do
			task.delay((def.Delay or 0) + entry.along / (def.Speed :: number), function()
				if Targeting.IsAlive(entry.enemy) then
					hit(player, state, entry.enemy, def.Damage :: number, def.Impact)
				end
			end)
		end
		return true
	end,

	Area = function(player, state, root, def, target)
		local center: Vector3
		local enemy: Model? = nil
		if def.AtSelf then
			center = root.Position
		else
			enemy = resolveTarget(root, def.Range :: number, def.ArcDot or 0.5, target)
			if not enemy then
				return false
			end
			center = enemy:GetPivot().Position
		end
		local ticks = def.Ticks or 1
		for i = 0, ticks - 1 do
			task.delay((def.Delay or 0) + i * (def.Interval or 0), function()
				for _, other in Targeting.InRadius(center, def.Radius :: number) do
					hit(player, state, other, def.Damage :: number, def.Impact)
				end
				if i == 0 and def.Heal then
					healAround(player, root, def.Heal, def.Radius :: number)
				end
			end)
		end
		return true, enemy
	end,

	Heal = function(player, _state, root, def)
		task.delay(def.Delay or 0, function()
			if root.Parent then
				healAround(player, root, def.Heal :: number, def.Radius or 0)
			end
		end)
		return true
	end,

	-- Movimientos: el cliente mueve al personaje (como al esquivar) para que
	-- responda al instante; aquí se cobra y empieza la espera.
	Blink = function()
		return true
	end,

	Leap = function()
		return true
	end,
}

-- Revisa que el jugador pueda usar la activa ahora: es de su clase (o su
-- definitiva), está vivo, terminó las esperas y tiene recurso o barra llena.
local function checkReady(player: Player, abilityId: string): (ActiveDef?, PlayerState?, BasePart?, boolean)
	local class = getClass(player)
	local def = AbilityData.Actives[abilityId]
	if not class or not def then
		return nil, nil, nil, false
	end
	-- La definitiva se paga con la barra llena en vez de recurso.
	local isUltimate = abilityId == class.Ultimate
	if not isUltimate and not table.find(class.Actives, abilityId) then
		return nil, nil, nil, false
	end
	local root = getAliveRoot(player)
	if not root then
		return nil, nil, nil, false
	end

	local state = getState(player)
	local now = os.clock()
	if now < state.globalReadyAt - TIMING_TOLERANCE then
		return nil, nil, nil, false
	end
	if now < (state.readyAt[abilityId] or 0) - TIMING_TOLERANCE then
		return nil, nil, nil, false
	end
	if isUltimate then
		if not UltimateService.IsFull(player) then
			return nil, nil, nil, false
		end
	elseif getResource(player) < def.Cost then
		return nil, nil, nil, false
	end
	return def, state, root, isUltimate
end

-- true si el jugador esquivó después de `since` (hora del servidor).
local function dodgedSince(player: Player, since: number): boolean
	local character = player.Character
	local untilTime = character and character:GetAttribute(INVULNERABLE_ATTRIBUTE)
	return typeof(untilTime) == "number" and untilTime - AbilityData.Dodge.Invulnerable > since
end

local function startCast(player: Player, abilityId: string, target: unknown)
	local def, state, root = checkReady(player, abilityId)
	if not def or not state or not root or not def.CastTime then
		return
	end
	local enemy: Model? = nil
	if AbilityData.NeedsTarget(def) then
		enemy = resolveTarget(root, def.Range :: number, def.ArcDot or 0.5, target)
		if not enemy then
			return
		end
	end
	state.cast = { abilityId = abilityId, startedAt = os.clock(), serverStart = workspace:GetServerTimeNow() }
	if def.CastCue then
		CueService.Broadcast(player, def.CastCue, enemy)
	end
end

local function cancelCast(player: Player)
	local state = states[player]
	if state and state.cast then
		state.cast = nil
		CueService.Broadcast(player, "CastCancel")
	end
end

local function useActive(player: Player, abilityId: string, target: unknown)
	local def, state, root, isUltimate = checkReady(player, abilityId)
	if not def or not state or not root then
		return
	end
	if def.CastTime then
		-- Solo vale si cargó todo el tiempo, sin esquivar, este mismo hechizo.
		local cast = state.cast
		state.cast = nil
		if not cast or cast.abilityId ~= abilityId then
			return
		end
		if os.clock() - cast.startedAt < def.CastTime - CAST_TOLERANCE then
			return
		end
		if dodgedSince(player, cast.serverStart) then
			return
		end
	end

	local used, cueTarget = activeHandlers[def.Kind](player, state, root, def, target)
	if not used then
		return
	end
	if isUltimate then
		UltimateService.Consume(player)
	else
		addResource(player, -def.Cost)
	end
	local now = os.clock()
	state.readyAt[abilityId] = now + def.Cooldown
	state.globalReadyAt = now + AbilityData.GlobalCooldown
	CueService.Broadcast(player, def.Cue, cueTarget)
end

-- El Maná se recupera solo; la Energía no.
local function regenLoop()
	while true do
		task.wait(REGEN_INTERVAL)
		for _, player in Players:GetPlayers() do
			local class = getClass(player)
			if class and class.ResourceRegen > 0 then
				addResource(player, class.MaxResource * class.ResourceRegen * REGEN_INTERVAL)
			end
		end
	end
end

function CombatService:Start()
	Players.PlayerAdded:Connect(function(player)
		setClass(player, DEFAULT_CLASS)
	end)
	for _, player in Players:GetPlayers() do
		setClass(player, DEFAULT_CLASS)
	end
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)

	Remotes.OnServerEvent("UseAbility", function(player: Player, abilityId: unknown, target: unknown)
		if typeof(abilityId) ~= "string" then
			return
		end
		if abilityId == "BasicAttack" then
			basicAttack(player, target)
		else
			useActive(player, abilityId, target)
		end
	end)

	Remotes.OnServerEvent("StartCast", function(player: Player, abilityId: unknown, target: unknown)
		if typeof(abilityId) == "string" then
			startCast(player, abilityId, target)
		end
	end)

	Remotes.OnServerEvent("CancelCast", cancelCast)

	Remotes.OnServerEvent("SelectClass", function(player: Player, classId: unknown)
		if typeof(classId) == "string" and Classes[classId] and player:GetAttribute("Class") ~= classId then
			setClass(player, classId)
		end
	end)

	task.spawn(regenLoop)
end

return CombatService
