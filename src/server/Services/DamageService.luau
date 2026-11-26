--!strict
-- Aplica daño a cualquier objetivo con atributos Health/MaxHealth (tag "Enemy"),
-- cura a jugadores, y avisa a los clientes en lotes cada 0,1 s, no golpe por golpe.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local FLUSH_INTERVAL = 0.1

export type Feedback = {
	Target: Model,
	Amount: number,
	Crit: boolean,
	Source: Player?, -- quién pegó (para la sacudida de cámara de su cliente)
	Impact: string?, -- tipo de impacto que se ve (Data/Feedback.Impacts)
	Tick: boolean?, -- pulso de daño en el tiempo: número chico, sin sonido ni sacudida
	Heal: boolean?, -- curación: número verde sobre el personaje
}

export type HitOptions = {
	Impact: string?,
	Tick: boolean?,
}

local DamageService = {}

local pending: { Feedback } = {}

-- Devuelve el daño que realmente se aplicó (0 si el objetivo ya no tenía vida).
function DamageService.Apply(
	target: Model,
	amount: number,
	crit: boolean,
	source: Player?,
	options: HitOptions?
): number
	local health = target:GetAttribute("Health")
	if typeof(health) ~= "number" or health <= 0 or amount <= 0 then
		return 0
	end
	local dealt = math.min(health, amount)
	target:SetAttribute("Health", health - dealt)
	table.insert(pending, {
		Target = target,
		Amount = amount,
		Crit = crit,
		Source = source,
		Impact = options and options.Impact,
		Tick = options and options.Tick,
	})
	return dealt
end

-- Cura al personaje de un jugador. Devuelve cuánto curó de verdad.
-- El número que se ve es el valor completo, aunque esté con la vida llena.
function DamageService.Heal(character: Model, amount: number, source: Player?): number
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or amount <= 0 then
		return 0
	end
	local healed = math.min(amount, humanoid.MaxHealth - humanoid.Health)
	humanoid.Health += healed
	table.insert(pending, { Target = character, Amount = amount, Crit = false, Source = source, Heal = true })
	return healed
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
