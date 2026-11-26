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

export type DodgeDef = {
	Charges: number, -- cargas máximas
	Recharge: number, -- segundos para recuperar una carga
	Distance: number, -- studs recorridos
	Duration: number, -- segundos que dura el dash
	Invulnerable: number, -- segundos sin recibir daño desde que empieza
}

-- Esquivar: igual para todas las clases.
local DODGE: DodgeDef = {
	Charges = 2,
	Recharge = 4,
	Distance = 16,
	Duration = 0.2,
	Invulnerable = 0.3,
}

return table.freeze({
	Abilities = table.freeze(Abilities),
	BaseCritChance = BASE_CRIT_CHANCE,
	Dodge = table.freeze(DODGE),
})
