--!strict
-- IA de mobs y jefes (Fase 0), toda en el servidor:
--   Quieto: patrulla cerca de su sitio y busca jugadores a su distancia de detección.
--   Persigue: se acerca (o mantiene distancia, si es a distancia) y usa el primer
--     ataque listo de su lista. Al recibir daño también entra en pelea.
--   Ataca: se queda quieto, avisa con una zona roja en el suelo (remoto MobCue) y
--     al terminar el aviso aplica el daño en esa zona. Después queda quieto un rato.
--   Vuelve: si se aleja demasiado de su sitio o pierde a todos, vuelve corriendo,
--     inmune (atributo Evading), y recupera la vida al llegar.
--   Muere: desaparece y reaparece en su sitio a los `RespawnTime` segundos.
-- Los jefes además cambian de fase según su vida (Data/Mobs, Phases).
-- Ver las fichas en docs/fichas/mobs y docs/fichas/jefes.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MobData = require(ReplicatedStorage.Shared.Data.Mobs)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Bodies = require(script.Parent.Parent.Mobs.Bodies)
local ArenaService = require(script.Parent.ArenaService)
local DamageService = require(script.Parent.DamageService)

type MobDef = MobData.MobDef
type AttackDef = MobData.AttackDef

local TICK = 0.1
local FLAT = Vector3.new(1, 0, 1)
-- Diferencia de altura máxima para detectar o golpear a un jugador.
local MAX_HEIGHT_DIFF = 8
-- Medio ancho de un personaje: cuenta como golpeado si su borde toca la zona.
local PLAYER_RADIUS = 1.2
-- Se acerca hasta esta fracción del alcance de su ataque más corto.
local APPROACH = 0.8
-- Al volver: corre más rápido y, si en este tiempo no llegó, aparece en su sitio.
local RETURN_SPEED = 1.6
local RETURN_TIMEOUT = 10
local HOME_RADIUS = 2.5
-- Un jugador más lejos que esto (más allá del límite del mob) deja de ser su objetivo.
local TARGET_LEASH_MARGIN = 10
-- Lo que queda el cuerpo antes de desaparecer.
local DEATH_LINGER = 1.2
local SUMMON_DISTANCE = 8
-- Retraso medio del primer ataque al entrar en pelea (entre 0,5 y 1,5 veces esto).
local FIRST_ATTACK_DELAY = 0.8

type State = "Idle" | "Chase" | "Attack" | "Return" | "Dead"

type Mob = {
	def: MobDef,
	model: Model,
	root: BasePart,
	humanoid: Humanoid,
	home: Vector3,
	spawn: ArenaService.Spawn?, -- nil en los ayudantes que llama un jefe (no reaparecen)
	state: State,
	target: Player?,
	readyAt: { [string]: number },
	token: number, -- cambia al morir o volver: cancela el ataque en curso
	nextPatrol: number,
	returnStarted: number,
	phase: number,
	adds: { Mob },
}

local MobService = {}

local mobs: { [Model]: Mob } = {}
local folder: Folder
local cueRemote: RemoteEvent

local function flatDistance(a: Vector3, b: Vector3): number
	return ((a - b) * FLAT).Magnitude
end

local function aliveRoot(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

local function cue(mob: Mob, event: string, data: { [string]: any }?)
	cueRemote:FireAllClients(mob.model, event, data)
end

local function currentPhase(mob: Mob): MobData.PhaseDef?
	local phases = mob.def.Phases
	return if phases then phases[mob.phase] else nil
end

local function currentAttacks(mob: Mob): { string }
	local phase = currentPhase(mob)
	return if phase then phase.Attacks else mob.def.Attacks
end

local function setSpeed(mob: Mob, base: number)
	local phase = currentPhase(mob)
	mob.humanoid.WalkSpeed = base * (if phase and phase.SpeedMultiplier then phase.SpeedMultiplier else 1)
end

local function stop(mob: Mob)
	mob.humanoid:MoveTo(mob.root.Position)
end

local function face(mob: Mob, point: Vector3)
	local position = mob.root.Position
	local flat = Vector3.new(point.X, position.Y, point.Z)
	if (flat - position).Magnitude > 1e-3 then
		mob.root.CFrame = CFrame.lookAt(position, flat)
	end
end

-- Personajes vivos con su raíz, cerca de la altura de `origin`.
local function charactersNear(origin: Vector3): { { character: Model, root: BasePart } }
	local result = {}
	for _, player in Players:GetPlayers() do
		local root = aliveRoot(player)
		if root and math.abs(root.Position.Y - origin.Y) <= MAX_HEIGHT_DIFF then
			table.insert(result, { character = player.Character :: Model, root = root })
		end
	end
	return result
end

-- El jugador vivo más cerca del mob, dentro de su distancia de detección.
local function findTarget(mob: Mob): Player?
	local best: Player? = nil
	local bestDistance = mob.def.AggroRange
	local position = mob.root.Position
	for _, player in Players:GetPlayers() do
		local root = aliveRoot(player)
		if root and math.abs(root.Position.Y - position.Y) <= MAX_HEIGHT_DIFF then
			local distance = flatDistance(root.Position, position)
			if distance <= bestDistance then
				best = player
				bestDistance = distance
			end
		end
	end
	return best
end

local function aggro(mob: Mob, player: Player)
	if mob.state ~= "Idle" then
		return
	end
	mob.state = "Chase"
	mob.target = player
	mob.model:SetAttribute("InCombat", true)
	-- Un respiro al azar antes del primer ataque, para que un grupo no pegue a la vez.
	local now = os.clock()
	for _, id in currentAttacks(mob) do
		mob.readyAt[id] = math.max(mob.readyAt[id] or 0, now + FIRST_ATTACK_DELAY * (0.5 + math.random()))
	end
	setSpeed(mob, mob.def.WalkSpeed)
	cue(mob, "Aggro")
	-- Los del mismo campamento se suman.
	for _, other in mobs do
		if
			other ~= mob
			and other.state == "Idle"
			and flatDistance(other.root.Position, mob.root.Position) <= mob.def.LinkRange
		then
			aggro(other, player)
		end
	end
end

local function despawn(mob: Mob)
	mob.state = "Dead"
	mob.token += 1
	mobs[mob.model] = nil
	mob.model:Destroy()
end

local function startReturn(mob: Mob)
	mob.state = "Return"
	mob.target = nil
	mob.token += 1
	mob.returnStarted = os.clock()
	mob.model:SetAttribute("Evading", true)
	mob.model:SetAttribute("InCombat", false)
	mob.root.Anchored = false
	mob.humanoid.AutoRotate = true
	if mob.def.Phases then
		mob.phase = 1
	end
	for _, add in mob.adds do
		if add.state ~= "Dead" then
			despawn(add)
		end
	end
	table.clear(mob.adds)
	setSpeed(mob, mob.def.WalkSpeed * RETURN_SPEED)
	mob.humanoid:MoveTo(mob.home)
end

-- Personajes cuyo borde toca un rectángulo que sale de `origin` hacia `direction`.
local function inRect(origin: Vector3, direction: Vector3, length: number, width: number): { Model }
	local hits = {}
	for _, entry in charactersNear(origin) do
		local offset = (entry.root.Position - origin) * FLAT
		local along = offset:Dot(direction)
		local side = (offset - direction * along).Magnitude
		if along >= -PLAYER_RADIUS and along <= length + PLAYER_RADIUS and side <= width / 2 + PLAYER_RADIUS then
			table.insert(hits, entry.character)
		end
	end
	return hits
end

local function inCircle(center: Vector3, radius: number): { Model }
	local hits = {}
	for _, entry in charactersNear(center) do
		if flatDistance(entry.root.Position, center) <= radius + PLAYER_RADIUS then
			table.insert(hits, entry.character)
		end
	end
	return hits
end

local spawnMob: (def: MobDef, position: Vector3, spawn: ArenaService.Spawn?) -> Mob

-- Proyectil recto: daña al primer jugador que cruza y se detiene.
local function flyBolt(attack: AttackDef, data: { [string]: any })
	local origin: Vector3 = data.Origin
	local direction: Vector3 = data.Direction
	local length: number = data.Length
	local halfWidth = (attack.Width or 2) / 2 + PLAYER_RADIUS
	local travelled = 0
	while travelled < length do
		local dt = RunService.Heartbeat:Wait()
		local previous = travelled
		travelled = math.min(length, travelled + (attack.Speed :: number) * dt)
		for _, entry in charactersNear(origin) do
			local offset = (entry.root.Position - origin) * FLAT
			local along = offset:Dot(direction)
			local side = (offset - direction * along).Magnitude
			if along >= previous - PLAYER_RADIUS and along <= travelled + PLAYER_RADIUS and side <= halfWidth then
				DamageService.DamagePlayer(entry.character, attack.Damage, attack.Impact)
				return
			end
		end
	end
end

-- Embestida: el mob recorre la línea y daña una vez a cada jugador que atraviesa.
local function charge(mob: Mob, attack: AttackDef, data: { [string]: any }, token: number)
	local origin: Vector3 = data.Origin
	local direction: Vector3 = data.Direction
	local length: number = data.Length
	local reach = (attack.Width or 4) / 2 + PLAYER_RADIUS
	local start = CFrame.lookAt(origin, origin + direction)
	local hit: { [Model]: boolean } = {}
	local travelled = 0
	mob.root.Anchored = true
	while travelled < length and mob.token == token do
		local dt = RunService.Heartbeat:Wait()
		travelled = math.min(length, travelled + (attack.Speed :: number) * dt)
		mob.root.CFrame = start + direction * travelled
		for _, entry in charactersNear(mob.root.Position) do
			if not hit[entry.character] and flatDistance(entry.root.Position, mob.root.Position) <= reach then
				hit[entry.character] = true
				DamageService.DamagePlayer(entry.character, attack.Damage, attack.Impact)
			end
		end
	end
	if mob.state ~= "Dead" then
		mob.root.Anchored = false
	end
end

local function summon(mob: Mob, attack: AttackDef)
	local summonDef = attack.Summon
	if not summonDef then
		return
	end
	local def = MobData.Mobs[summonDef.Mob]
	for i = 1, summonDef.Count do
		local angle = (i / summonDef.Count) * 2 * math.pi + math.random() * 0.5
		local position = mob.root.Position + Vector3.new(math.sin(angle), 0, math.cos(angle)) * SUMMON_DISTANCE
		local add = spawnMob(def, position, nil)
		table.insert(mob.adds, add)
		local target = mob.target
		if target then
			aggro(add, target)
		end
	end
end

-- Aplica el daño del ataque en la zona que se avisó.
local function resolve(mob: Mob, attack: AttackDef, data: { [string]: any }, token: number)
	local kind = attack.Kind
	if kind == "Swing" then
		for _, character in inRect(data.Origin, data.Direction, data.Length, attack.Width :: number) do
			DamageService.DamagePlayer(character, attack.Damage, attack.Impact)
		end
	elseif kind == "Slam" then
		for _, character in inCircle(data.Origin, attack.Radius :: number) do
			DamageService.DamagePlayer(character, attack.Damage, attack.Impact)
		end
	elseif kind == "Barrage" then
		local hit: { [Model]: boolean } = {}
		for _, position in data.Positions :: { Vector3 } do
			for _, character in inCircle(position, attack.Radius :: number) do
				if not hit[character] then
					hit[character] = true
					DamageService.DamagePlayer(character, attack.Damage, attack.Impact)
				end
			end
		end
	elseif kind == "Bolt" then
		task.spawn(flyBolt, attack, data) -- el proyectil sigue aunque el mob muera
	elseif kind == "Charge" then
		charge(mob, attack, data, token)
	elseif kind == "Summon" then
		summon(mob, attack)
	end
end

-- Dónde cae el ataque, calculado al empezar el aviso (no sigue al jugador).
local function geometry(mob: Mob, attack: AttackDef, targetRoot: BasePart): { [string]: any }
	local origin = mob.root.Position
	local direction = (targetRoot.Position - origin) * FLAT
	if direction.Magnitude < 1e-3 then
		direction = mob.root.CFrame.LookVector * FLAT
	end
	direction = direction.Unit
	local data: { [string]: any } = {
		Attack = attack.Id,
		Origin = origin,
		Direction = direction,
		WindUp = attack.WindUp,
	}
	local kind = attack.Kind
	if kind == "Swing" then
		data.Length = attack.Length
	elseif kind == "Bolt" then
		data.Length = ArenaService.FreeDistance(origin, direction, attack.Length :: number)
	elseif kind == "Charge" then
		local free = ArenaService.FreeDistance(origin, direction, attack.Length :: number)
		data.Length = math.max(0, free - mob.def.HitRadius)
	elseif kind == "Slam" then
		data.Radius = attack.Radius
	elseif kind == "Barrage" then
		local positions: { Vector3 } = {}
		for _, entry in charactersNear(origin) do
			if flatDistance(entry.root.Position, origin) <= attack.Range then
				table.insert(positions, entry.root.Position * FLAT + Vector3.new(0, origin.Y, 0))
			end
		end
		local spread = attack.Spread or 20
		for _ = 1, attack.Extra or 0 do
			local angle = math.random() * 2 * math.pi
			local distance = math.sqrt(math.random()) * spread
			table.insert(positions, mob.home + Vector3.new(math.sin(angle), 0, math.cos(angle)) * distance)
		end
		data.Positions = positions
		data.Radius = attack.Radius
	end
	return data
end

local function startAttack(mob: Mob, attack: AttackDef, targetRoot: BasePart?)
	mob.state = "Attack"
	local token = mob.token
	local phase = currentPhase(mob)
	local cooldownMultiplier = if phase and phase.CooldownMultiplier then phase.CooldownMultiplier else 1
	mob.readyAt[attack.Id] = os.clock() + attack.Cooldown * cooldownMultiplier
	stop(mob)
	mob.humanoid.AutoRotate = false

	local data: { [string]: any } = { Attack = attack.Id }
	if targetRoot and attack.Kind ~= "Summon" then
		data = geometry(mob, attack, targetRoot)
		face(mob, data.Origin + data.Direction)
		cue(mob, "Warn", data)
	end

	task.spawn(function()
		if attack.WindUp > 0 then
			task.wait(attack.WindUp)
		end
		if mob.token ~= token then
			return
		end
		cue(mob, "Release", data)
		resolve(mob, attack, data, token)
		task.wait(attack.Recovery)
		if mob.token ~= token then
			return
		end
		mob.humanoid.AutoRotate = true
		if mob.state == "Attack" then
			mob.state = "Chase"
		end
	end)
end

-- Jefe: pasa a la siguiente fase si su vida bajó del umbral. Ruge inmune un momento.
local function checkPhase(mob: Mob): boolean
	local phases = mob.def.Phases
	local nextPhase = phases and phases[mob.phase + 1]
	if not nextPhase then
		return false
	end
	local health = mob.model:GetAttribute("Health") :: number
	if health / mob.def.MaxHealth >= nextPhase.Below then
		return false
	end
	mob.phase += 1
	mob.state = "Attack"
	local token = mob.token
	stop(mob)
	setSpeed(mob, mob.def.WalkSpeed)
	mob.model:SetAttribute("Evading", true)
	cue(mob, "Phase", { Phase = mob.phase })
	task.spawn(function()
		task.wait(nextPhase.Pause or 0)
		if mob.token ~= token then
			return
		end
		mob.model:SetAttribute("Evading", false)
		mob.state = "Chase"
		if nextPhase.OnEnter then
			startAttack(mob, MobData.Attacks[nextPhase.OnEnter], nil)
		end
	end)
	return true
end

-- Hasta dónde se acerca antes de atacar.
local function approachRange(mob: Mob): number
	local best: number? = nil
	for _, id in currentAttacks(mob) do
		local attack = MobData.Attacks[id]
		if attack.Kind ~= "Summon" then
			if best == nil then
				best = attack.Range
			elseif mob.def.KeepDistance then
				best = math.max(best, attack.Range)
			else
				best = math.min(best, attack.Range)
			end
		end
	end
	return (best or 4) * APPROACH
end

local function updateIdle(mob: Mob, now: number)
	local target = findTarget(mob)
	if target then
		aggro(mob, target)
		return
	end
	if mob.def.PatrolRadius > 0 and now >= mob.nextPatrol then
		mob.nextPatrol = now + 4 + math.random() * 3
		local angle = math.random() * 2 * math.pi
		local distance = math.random() * mob.def.PatrolRadius
		setSpeed(mob, mob.def.PatrolSpeed)
		mob.humanoid:MoveTo(mob.home + Vector3.new(math.sin(angle), 0, math.cos(angle)) * distance)
	end
end

local function updateChase(mob: Mob, now: number)
	if checkPhase(mob) then
		return
	end
	local target = mob.target
	local targetRoot = target and aliveRoot(target)
	local position = mob.root.Position
	if flatDistance(position, mob.home) > mob.def.LeashRange then
		startReturn(mob)
		return
	end
	if not targetRoot or flatDistance(targetRoot.Position, mob.home) > mob.def.LeashRange + TARGET_LEASH_MARGIN then
		-- Busca a otro cerca; si no hay nadie, vuelve.
		local other = findTarget(mob)
		local otherRoot = other and aliveRoot(other)
		if not other or not otherRoot then
			startReturn(mob)
			return
		end
		mob.target = other
		targetRoot = otherRoot
	end
	local goal = (targetRoot :: BasePart).Position
	local edge = flatDistance(position, goal) - mob.def.HitRadius

	for _, id in currentAttacks(mob) do
		local attack = MobData.Attacks[id]
		if
			attack.Kind ~= "Summon"
			and now >= (mob.readyAt[id] or 0)
			and edge <= attack.Range
			and edge >= (attack.MinRange or -math.huge)
		then
			startAttack(mob, attack, targetRoot)
			return
		end
	end

	setSpeed(mob, mob.def.WalkSpeed)
	if mob.def.KeepDistance and edge < mob.def.KeepDistance then
		local away = (position - goal) * FLAT
		if away.Magnitude > 1e-3 then
			mob.humanoid:MoveTo(position + away.Unit * 6)
		end
	elseif edge > approachRange(mob) then
		mob.humanoid:MoveTo(goal)
	else
		stop(mob)
		face(mob, goal)
	end
end

local function updateReturn(mob: Mob, now: number)
	local arrived = flatDistance(mob.root.Position, mob.home) <= HOME_RADIUS
	if not arrived and now - mob.returnStarted < RETURN_TIMEOUT then
		mob.humanoid:MoveTo(mob.home)
		return
	end
	if not arrived then
		mob.root.CFrame = CFrame.new(mob.home + Vector3.new(0, mob.root.Position.Y - mob.home.Y, 0))
	end
	mob.model:SetAttribute("Health", mob.def.MaxHealth)
	mob.model:SetAttribute("Evading", false)
	mob.state = "Idle"
	mob.nextPatrol = now + 2
	setSpeed(mob, mob.def.PatrolSpeed)
end

local function onDeath(mob: Mob)
	mob.state = "Dead"
	mob.token += 1
	mob.target = nil
	mob.model:SetAttribute("InCombat", false)
	mob.root.Anchored = true
	cue(mob, "Death")
	for _, add in mob.adds do
		if add.state ~= "Dead" then
			add.model:SetAttribute("Health", 0)
		end
	end
	task.delay(DEATH_LINGER, function()
		mobs[mob.model] = nil
		mob.model:Destroy()
	end)
	local spawn = mob.spawn
	if spawn then
		task.delay(mob.def.RespawnTime, function()
			spawnMob(mob.def, spawn.Position, spawn)
		end)
	end
end

spawnMob = function(def: MobDef, position: Vector3, spawn: ArenaService.Spawn?): Mob
	local ground = Vector3.new(position.X, 0.1, position.Z)
	local body = Bodies.Build(def.Body, CFrame.lookAt(ground, ground + Vector3.new(0, 0, 1)))
	local model = body.model
	model.Name = def.Id
	model:SetAttribute("MobId", def.Id)
	model:SetAttribute("DisplayName", `{def.Name} · Nv. {def.Level}`)
	model:SetAttribute("MaxHealth", def.MaxHealth)
	model:SetAttribute("Health", def.MaxHealth)
	model:SetAttribute("HitRadius", def.HitRadius)
	model:SetAttribute("Boss", def.Boss == true)
	model:SetAttribute("InCombat", false)
	CollectionService:AddTag(model, "Enemy")

	local mob: Mob = {
		def = def,
		model = model,
		root = body.root,
		humanoid = body.humanoid,
		home = ground + Vector3.new(0, body.root.Position.Y - ground.Y, 0),
		spawn = spawn,
		state = "Idle",
		target = nil,
		readyAt = {},
		token = 0,
		nextPatrol = os.clock() + math.random() * 3,
		returnStarted = 0,
		phase = 1,
		adds = {},
	}
	mob.humanoid.WalkSpeed = def.PatrolSpeed
	model.Parent = folder
	body.root:SetNetworkOwner(nil)
	mobs[model] = mob

	model:GetAttributeChangedSignal("Health"):Connect(function()
		local health = model:GetAttribute("Health")
		if mob.state ~= "Dead" and typeof(health) == "number" and health <= 0 then
			onDeath(mob)
		end
	end)
	return mob
end

local updaters: { [State]: (Mob, number) -> () } = {
	Idle = updateIdle,
	Chase = updateChase,
	Return = updateReturn,
}

function MobService:Start()
	cueRemote = Remotes.Event("MobCue")
	local existing = workspace:FindFirstChild("Enemies")
	folder = if existing and existing:IsA("Folder") then existing else Instance.new("Folder")
	folder.Name = "Enemies"
	folder.Parent = workspace

	DamageService.OnDamaged(function(target, _dealt, source)
		local mob = mobs[target]
		if mob and source and mob.state == "Idle" then
			aggro(mob, source)
		end
	end)

	for _, spawn in ArenaService.Spawns do
		spawnMob(MobData.Mobs[spawn.Mob], spawn.Position, spawn)
	end

	while true do
		task.wait(TICK)
		local now = os.clock()
		local list: { Mob } = {}
		for _, mob in mobs do
			table.insert(list, mob)
		end
		for _, mob in list do
			local update = updaters[mob.state]
			if update and mob.model.Parent then
				local ok, err = pcall(update, mob, now)
				if not ok then
					warn(`[MobService] {mob.def.Id}: {err}`)
				end
			end
		end
	end
end

return MobService
