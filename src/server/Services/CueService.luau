--!strict
-- Avisa a los demás clientes que un jugador hizo un ataque aceptado, para que
-- vean su animación, efectos y sonido. Al que lo hizo no se le manda:
-- su cliente ya lo reprodujo al apretar.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CueService = {}

function CueService.Broadcast(player: Player, cueId: string)
	local character = player.Character
	if not character then
		return
	end
	assert(Feedback.Cues[cueId], `Señal desconocida: {cueId}`)
	local remote = Remotes.Event("CombatCue")
	for _, other in Players:GetPlayers() do
		if other ~= player then
			remote:FireClient(other, character, cueId)
		end
	end
end

return CueService
