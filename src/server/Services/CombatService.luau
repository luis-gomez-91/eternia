--!strict
-- Combate validado en servidor: cooldown, recurso, distancia y línea de visión.
-- Por ahora solo escucha las intenciones; la lógica llega con el ataque básico del Warrior.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CombatService = {}

function CombatService:Start()
	Remotes.Event("UseAbility").OnServerEvent:Connect(function(player: Player, abilityId: unknown)
		if typeof(abilityId) ~= "string" then
			return
		end
		print(`[CombatService] {player.Name} quiere usar {abilityId}`)
	end)
end

return CombatService
