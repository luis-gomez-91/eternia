--!strict
-- Habilidades como datos. Cliente y servidor leen la misma tabla:
-- el cliente para el ritmo de los controles, el servidor para validar.
-- Distancias en studs (1 stud ≈ 0,28 m).

export type MeleeHit = {
	Damage: number,
	Recovery: number, -- segundos mínimos hasta el siguiente golpe del combo
	Cue: string, -- animación, efectos y sonido (Data/Feedback)
}

export type MeleeBasicAttack = {
	Id: string,
	Name: string,
	Kind: "MeleeCombo",
	Range: number, -- alcance desde el borde del objetivo
	ArcDot: number, -- coseno del medio ángulo del cono frontal (0,5 = 120° en total)
	ComboReset: number, -- sin golpear este tiempo, el combo vuelve al golpe 1
	EnergyPerHit: number, -- Energía que genera cada golpe que acierta
	Hits: { MeleeHit },
}

-- Activas: gastan recurso y tienen tiempo de espera propio, más la espera global.
-- Kind decide qué hace; cada tipo usa solo algunos de los campos opcionales.
export type ActiveKind = "Cleave" | "SelfBuff" | "Charge"

export type ActiveDef = {
	Id: string,
	Name: string,
	Kind: ActiveKind,
	Cost: number, -- recurso de la clase (Energía o Maná)
	Cooldown: number,
	Cue: string, -- animación, efectos y sonido (Data/Feedback)
	Damage: number?,
	Range: number?,
	ArcDot: number?,
	Duration: number?, -- SelfBuff: segundos que dura
	DamageBonus: number?, -- SelfBuff: 0,2 = +20% de daño
	EnergyGain: number?, -- SelfBuff: Energía que da al usarla
	Speed: number?, -- Charge: studs por segundo
}

local Abilities = {
	WarriorCombo = {
		Id = "WarriorCombo",
		Name = "Combo de guerrero",
		Kind = "MeleeCombo",
		Range = 7,
		ArcDot = 0.5,
		ComboReset = 1.2,
		EnergyPerHit = 8,
		Hits = {
			{ Damage = 12, Recovery = 0.45, Cue = "WarriorCombo1" },
			{ Damage = 12, Recovery = 0.45, Cue = "WarriorCombo2" },
			{ Damage = 22, Recovery = 0.75, Cue = "WarriorCombo3" },
		},
	} :: MeleeBasicAttack,
}

local Actives: { [string]: ActiveDef } = {
	-- Warrior, clase (nivel 1, 3 y 6)
	Cleave = {
		Id = "Cleave",
		Cue = "Cleave",
		Name = "Tajo",
		Kind = "Cleave",
		Cost = 20,
		Cooldown = 4,
		Damage = 30,
		Range = 8,
		ArcDot = 0, -- 180°: todo lo que está al frente
	},
	BattleShout = {
		Id = "BattleShout",
		Cue = "BattleShout",
		Name = "Grito de batalla",
		Kind = "SelfBuff",
		Cost = 0,
		Cooldown = 20,
		Duration = 8,
		DamageBonus = 0.2,
		EnergyGain = 30,
	},
	Charge = {
		Id = "Charge",
		Cue = "Charge",
		Name = "Embestida",
		Kind = "Charge",
		Cost = 15,
		Cooldown = 12,
		Damage = 25,
		Range = 25,
		ArcDot = 0.5,
		Speed = 70,
	},
}

-- Espera mínima entre dos activas cualesquiera.
local GLOBAL_COOLDOWN = 0.5

-- Probabilidad base de crítico (doble de daño) hasta que lleguen los stats de equipo.
local BASE_CRIT_CHANCE = 0.05

export type DodgeDef = {
	Charges: number, -- cargas máximas
	Recharge: number, -- segundos para recuperar una carga
	Distance: number, -- studs recorridos
	Duration: number, -- segundos que dura el dash
	Invulnerable: number, -- segundos sin recibir daño desde que empieza
	Cue: string, -- animación, efectos y sonido (Data/Feedback)
}

-- Esquivar: igual para todas las clases.
local DODGE: DodgeDef = {
	Charges = 2,
	Recharge = 4,
	Distance = 16,
	Duration = 0.2,
	Invulnerable = 0.3,
	Cue = "Dodge",
}

return table.freeze({
	Abilities = table.freeze(Abilities),
	Actives = table.freeze(Actives),
	GlobalCooldown = GLOBAL_COOLDOWN,
	BaseCritChance = BASE_CRIT_CHANCE,
	Dodge = table.freeze(DODGE),
})
