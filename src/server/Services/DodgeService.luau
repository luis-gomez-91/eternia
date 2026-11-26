--!strict
-- Esquivar validado en servidor. El cliente mueve al personaje al instante
-- (es dueño de su física); el servidor lleva las cargas y solo un esquive
-- con carga da invulnerabilidad. La detección de movimiento imposible
-- (Fase 1) es la que frena un dash sin carga.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Charges = require(ReplicatedStorage.Shared.Charges)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local CueService = require(script.Parent.CueService)

local DODGE = AbilityData.Dodge
-- Margen de carga por latencia: el cliente puede ver la carga lista un poco antes.
local CHARGE_TOLERANCE = 0.1

local DodgeService = {}

-- Atributo del personaje con la hora del servidor (GetServerTimeNow) en que termina
-- la invulnerabilidad. Se puede leer desde el cliente y se borra solo al reaparecer.
local INVULNERABLE_ATTRIBUTE = "InvulnerableUntil"

local charges: { [Player]: Charges.Charges } = {}

-- Para el daño a jugadores: true durante la ventana de invulnerabilidad del esquive.
function DodgeService.IsInvulnerable(character: Model): boolean
	local untilTime = character:GetAttribute(INVULNERABLE_ATTRIBUTE)
	return typeof(untilTime) == "number" and workspace:GetServerTimeNow() < untilTime
end

local function onDodge(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid or humanoid.Health <= 0 then
		return
	end

	local meter = charges[player]
	if not meter then
		meter = Charges.new(DODGE.Charges, DODGE.Recharge)
		charges[player] = meter
	end

	if not meter:TryConsume(os.clock(), CHARGE_TOLERANCE) then
		return
	end
	character:SetAttribute(INVULNERABLE_ATTRIBUTE, workspace:GetServerTimeNow() + DODGE.Invulnerable)
	CueService.Broadcast(player, DODGE.Cue)
end

function DodgeService:Start()
	Players.PlayerRemoving:Connect(function(player)
		charges[player] = nil
	end)
	Remotes.OnServerEvent("Dodge", onDodge)
end

return DodgeService
