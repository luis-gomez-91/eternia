--!strict
-- Definición única de todos los remotos. El servidor los crea y el cliente los espera.
-- Para agregar uno: sumarlo a EVENTS o FUNCTIONS; nada más.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "Remotes"

-- Intenciones del cliente y avisos del servidor. El servidor siempre valida.
local EVENTS = {
	"UseAbility", -- cliente -> servidor: quiere usar una habilidad
	"Dodge", -- cliente -> servidor: quiere esquivar
	"CombatFeedback", -- servidor -> clientes: daño aplicado, para números y efectos
}

local FUNCTIONS: { string } = {}

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

function Remotes.Event(name: string): RemoteEvent
	assert(table.find(EVENTS, name), `Remoto desconocido: {name}`)
	return getOrCreate(getFolder(), name, "RemoteEvent") :: RemoteEvent
end

function Remotes.Function(name: string): RemoteFunction
	assert(table.find(FUNCTIONS, name), `Remoto desconocido: {name}`)
	return getOrCreate(getFolder(), name, "RemoteFunction") :: RemoteFunction
end

-- Solo servidor: crea todos los remotos al arrancar.
function Remotes.CreateAll()
	assert(RunService:IsServer(), "Remotes.CreateAll solo en el servidor")
	for _, name in EVENTS do
		Remotes.Event(name)
	end
	for _, name in FUNCTIONS do
		Remotes.Function(name)
	end
end

return Remotes
