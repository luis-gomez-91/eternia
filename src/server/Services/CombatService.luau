--!strict
-- Combate validado en servidor. El cliente solo dice "quiero usar X" (y, si hace
-- falta, a quién); el servidor revisa clase, distancia, ritmo, tiempos de espera
-- y Energía, y aplica el resultado.
--
-- Energía: atributos Energy y MaxEnergy del jugador. La genera el ataque básico
-- y la gastan las activas.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Targeting = require(ReplicatedStorage.Shared.Targeting)
local DamageService = require(script.Parent.DamageService)

-- Margen para el jitter de red en ritmos y tiempos de espera.
local TIMING_TOLERANCE = 0.1
-- Margen de distancia para objetivos que elige el cliente (se movieron un poco).
local TARGET_RANGE_TOLERANCE = 3
-- La Embestida se detiene a esta distancia del borde del objetivo.
local CHARGE_STOP_DISTANCE = 2.5
-- Clase por defecto hasta que exista la selección de personaje.
local DEFAULT_CLASS = "Warrior"

type PlayerState = {
	comboIndex: number,
	lastSwing: number,
	readyAt: { [string]: number }, -- tiempo de espera de cada activa
	globalReadyAt: number,
	buffUntil: number,
	buffBonus: number,
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
	player:SetAttribute("Class", classId)
	player:SetAttribute("MaxEnergy", class.MaxResource)
	player:SetAttribute("Energy", 0)
end

local function getEnergy(player: Player): number
	local energy = player:GetAttribute("Energy")
	return if typeof(energy) == "number" then energy else 0
end

local function addEnergy(player: Player, amount: number)
	local max = player:GetAttribute("MaxEnergy")
	local cap = if typeof(max) == "number" then max else 0
	player:SetAttribute("Energy", math.clamp(getEnergy(player) + amount, 0, cap))
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
local function hit(state: PlayerState, target: Model, base: number): number
	local multiplier = if os.clock() < state.buffUntil then 1 + state.buffBonus else 1
	local crit = math.random() < AbilityData.BaseCritChance
	local amount = base * multiplier * (if crit then 2 else 1)
	return DamageService.Apply(target, math.floor(amount + 0.5), crit)
end

local function basicAttack(player: Player)
	local root = getAliveRoot(player)
	local class = getClass(player)
	local ability = class and AbilityData.Abilities[class.BasicAttack]
	if not root or not ability then
		return -- p. ej. el ataque del Mage todavía no existe
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

	-- Un golpe al aire también avanza el combo.
	local target = Targeting.InCone(root.CFrame, ability.Range, ability.ArcDot)[1]
	if target and hit(state, target, ability.Hits[state.comboIndex].Damage) > 0 then
		addEnergy(player, ability.EnergyPerHit)
	end
end

-- Cada tipo de activa: devuelve true si se usó (entonces se cobra y empieza la espera).
local activeHandlers: {
	[AbilityData.ActiveKind]: (
		player: Player,
		state: PlayerState,
		root: BasePart,
		def: AbilityData.ActiveDef,
		target: unknown
	) -> boolean,
} =
	{
		Cleave = function(_player, state, root, def)
			for _, enemy in Targeting.InCone(root.CFrame, def.Range :: number, def.ArcDot :: number) do
				hit(state, enemy, def.Damage :: number)
			end
			return true -- al aire también gasta: es un golpe que se ve
		end,

		SelfBuff = function(player, state, _root, def)
			state.buffUntil = os.clock() + (def.Duration :: number)
			state.buffBonus = def.DamageBonus or 0
			addEnergy(player, def.EnergyGain or 0)
			return true
		end,

		Charge = function(_player, state, root, def, target)
			-- El cliente elige el objetivo y se mueve; el servidor revisa que fuera válido.
			if typeof(target) ~= "Instance" or not Targeting.IsAlive(target) then
				return false
			end
			local enemy = target :: Model
			local dist = Targeting.Distance(
				enemy,
				root.CFrame,
				(def.Range :: number) + TARGET_RANGE_TOLERANCE,
				(def.ArcDot :: number) - 0.2
			)
			if not dist then
				return false
			end
			-- El golpe llega cuando termina el recorrido.
			local travel = math.max(0, dist - Targeting.Radius(enemy) - CHARGE_STOP_DISTANCE)
			task.delay(travel / (def.Speed :: number), function()
				if Targeting.IsAlive(enemy) then
					hit(state, enemy, def.Damage :: number)
				end
			end)
			return true
		end,
	}

local function useActive(player: Player, abilityId: string, target: unknown)
	local class = getClass(player)
	local def = AbilityData.Actives[abilityId]
	if not class or not def or not table.find(class.Actives, abilityId) then
		return
	end
	local root = getAliveRoot(player)
	if not root then
		return
	end

	local state = getState(player)
	local now = os.clock()
	if now < state.globalReadyAt - TIMING_TOLERANCE then
		return
	end
	if now < (state.readyAt[abilityId] or 0) - TIMING_TOLERANCE then
		return
	end
	if getEnergy(player) < def.Cost then
		return
	end

	if not activeHandlers[def.Kind](player, state, root, def, target) then
		return
	end
	addEnergy(player, -def.Cost)
	state.readyAt[abilityId] = now + def.Cooldown
	state.globalReadyAt = now + AbilityData.GlobalCooldown
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
			basicAttack(player)
		else
			useActive(player, abilityId, target)
		end
	end)
end

return CombatService
