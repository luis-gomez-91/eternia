--!strict
-- Definición única de todos los remotos. El servidor los crea y el cliente los espera.
-- Para agregar uno: sumarlo a EVENTS o FUNCTIONS con su límite; nada más.
--
-- Límite: `rate` llamadas por segundo sostenidas y `burst` seguidas como máximo.
-- En el servidor, escuchar siempre con Remotes.OnServerEvent / Remotes.OnServerInvoke:
-- descartan las llamadas que pasan el límite antes de llegar al handler.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RateLimiter = require(script.Parent.RateLimiter)

local FOLDER_NAME = "Remotes"

export type Limit = { rate: number, burst: number }

-- Intenciones del cliente y avisos del servidor. El servidor siempre valida.
-- Los remotos servidor -> cliente no llevan límite (limit = false).
local EVENTS: { [string]: Limit | false } = {
	UseAbility = { rate = 10, burst = 15 }, -- cliente -> servidor: quiere usar una habilidad
	Dodge = { rate = 3, burst = 4 }, -- cliente -> servidor: quiere esquivar
	SelectClass = { rate = 2, burst = 3 }, -- cliente -> servidor: cambia de clase (selector provisorio)
	CombatFeedback = false, -- servidor -> clientes: daño aplicado, para números y efectos
	CombatCue = false, -- servidor -> clientes: un jugador hizo un ataque (animación, efectos, sonido)
	MobCue = false, -- servidor -> clientes: un mob detecta, avisa un ataque, lo suelta, cambia de fase o muere
}

local FUNCTIONS: { [string]: Limit | false } = {}

-- Avisos de abuso: como mucho uno por jugador y remoto cada este número de segundos.
local WARN_INTERVAL = 10

local Remotes = {}

local function getFolder(): Folder
	if RunService:IsServer() then
		local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = FOLDER_NAME
			folder.Parent = ReplicatedStorage
		end
		return folder :: Folder
	end
	return ReplicatedStorage:WaitForChild(FOLDER_NAME) :: Folder
end

local function getOrCreate(folder: Folder, name: string, className: string): Instance
	if RunService:IsServer() then
		local existing = folder:FindFirstChild(name)
		if existing then
			return existing
		end
		local remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
		return remote
	end
	return folder:WaitForChild(name)
end

-- Crea el filtro de límite de un remoto. Devuelve true si la llamada pasa.
local function makeGate(name: string, limit: Limit | false): (player: Player) -> boolean
	assert(limit, `{name} es servidor -> cliente; no se escucha en el servidor`)
	local limiter = RateLimiter.new(limit.rate, limit.burst)
	local lastWarn: { [Player]: number } = {}

	Players.PlayerRemoving:Connect(function(player)
		limiter:Remove(player)
		lastWarn[player] = nil
	end)

	return function(player: Player): boolean
		if limiter:Allow(player) then
			return true
		end
		local t = os.clock()
		if t - (lastWarn[player] or -math.huge) >= WARN_INTERVAL then
			lastWarn[player] = t
			warn(`[Remotes] {player.Name} pasó el límite de {name} ({limit.rate}/s); llamadas descartadas`)
		end
		return false
	end
end

function Remotes.Event(name: string): RemoteEvent
	assert(EVENTS[name] ~= nil, `Remoto desconocido: {name}`)
	return getOrCreate(getFolder(), name, "RemoteEvent") :: RemoteEvent
end

function Remotes.Function(name: string): RemoteFunction
	assert(FUNCTIONS[name] ~= nil, `Remoto desconocido: {name}`)
	return getOrCreate(getFolder(), name, "RemoteFunction") :: RemoteFunction
end

-- Solo servidor: escucha un RemoteEvent con su límite por jugador aplicado.
function Remotes.OnServerEvent(name: string, handler: (player: Player, ...unknown) -> ()): RBXScriptConnection
	assert(RunService:IsServer(), "Remotes.OnServerEvent solo en el servidor")
	local remote = Remotes.Event(name)
	local allow = makeGate(name, EVENTS[name])
	return remote.OnServerEvent:Connect(function(player: Player, ...: unknown)
		if allow(player) then
			handler(player, ...)
		end
	end)
end

-- Solo servidor: responde un RemoteFunction con su límite por jugador.
-- Si pasa el límite, el cliente recibe nil.
function Remotes.OnServerInvoke(name: string, handler: (player: Player, ...unknown) -> ...unknown)
	assert(RunService:IsServer(), "Remotes.OnServerInvoke solo en el servidor")
	local remote = Remotes.Function(name)
	local allow = makeGate(name, FUNCTIONS[name])
	remote.OnServerInvoke = function(player: Player, ...: unknown): ...unknown
		if not allow(player) then
			return nil
		end
		return handler(player, ...)
	end
end

-- Solo servidor: crea todos los remotos al arrancar.
function Remotes.CreateAll()
	assert(RunService:IsServer(), "Remotes.CreateAll solo en el servidor")
	for name in EVENTS do
		Remotes.Event(name)
	end
	for name in FUNCTIONS do
		Remotes.Function(name)
	end
end

return Remotes
