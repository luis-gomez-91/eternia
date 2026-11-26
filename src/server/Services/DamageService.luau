--!strict
-- Aplica daño a cualquier objetivo con atributos Health/MaxHealth (tag "Enemy")
-- y avisa a los clientes en lotes cada 0,1 s, no golpe por golpe.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local FLUSH_INTERVAL = 0.1

export type Feedback = {
	Target: Model,
	Amount: number,
	Crit: boolean,
}

local DamageService = {}

local pending: { Feedback } = {}

-- Devuelve el daño que realmente se aplicó (0 si el objetivo ya no tenía vida).
function DamageService.Apply(target: Model, amount: number, crit: boolean): number
	local health = target:GetAttribute("Health")
	if typeof(health) ~= "number" or health <= 0 or amount <= 0 then
		return 0
	end
	local dealt = math.min(health, amount)
	target:SetAttribute("Health", health - dealt)
	table.insert(pending, { Target = target, Amount = amount, Crit = crit })
	return dealt
end

function DamageService:Start()
	local feedback = Remotes.Event("CombatFeedback")
	while true do
		task.wait(FLUSH_INTERVAL)
		if #pending > 0 then
			local batch = pending
			pending = {}
			feedback:FireAllClients(batch)
		end
	end
end

return DamageService
