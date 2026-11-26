--!strict
-- Habilidades como datos. Cliente y servidor leen la misma tabla:
-- el cliente para el ritmo de los controles, el servidor para validar.
-- Distancias en studs (1 stud ≈ 0,28 m).

export type MeleeHit = {
	Damage: number,
	Recovery: number, -- segundos mínimos hasta el siguiente golpe del combo
}

export type MeleeBasicAttack = {
	Id: string,
	Name: string,
	Kind: "MeleeCombo",
	Range: number, -- alcance desde el borde del objetivo
	ArcDot: number, -- coseno del medio ángulo del cono frontal (0,5 = 120° en total)
	ComboReset: number, -- sin golpear este tiempo, el combo vuelve al golpe 1
	Hits: { MeleeHit },
}

local Abilities = {
	WarriorCombo = {
		Id = "WarriorCombo",
		Name = "Combo de guerrero",
		Kind = "MeleeCombo",
		Range = 7,
		ArcDot = 0.5,
		ComboReset = 1.2,
		Hits = {
			{ Damage = 12, Recovery = 0.45 },
			{ Damage = 12, Recovery = 0.45 },
			{ Damage = 22, Recovery = 0.75 },
		},
	} :: MeleeBasicAttack,
}

-- Probabilidad base de crítico (doble de daño) hasta que lleguen los stats de equipo.
local BASE_CRIT_CHANCE = 0.05

return table.freeze({
	Abilities = table.freeze(Abilities),
	BaseCritChance = BASE_CRIT_CHANCE,
})
