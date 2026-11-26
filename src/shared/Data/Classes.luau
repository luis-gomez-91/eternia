--!strict
-- Clases del juego como datos. Ver PLAN.md, sección "Clases".
-- En la Fase 0 solo están Warrior y Mage.

export type Resource = "Energy" | "Mana"
export type Role = "Tank" | "Healer" | "Damage" | "Support"

export type ClassDef = {
	Id: string,
	Name: string,
	Resource: Resource,
	Roles: { Role },
	BasicAttack: string,
	MaxResource: number,
	Actives: { string }, -- activas de clase, en orden de tecla (1, 2, 3)
}

local Classes: { [string]: ClassDef } = {
	Warrior = {
		Id = "Warrior",
		Name = "Warrior",
		Resource = "Energy",
		Roles = { "Tank", "Damage" },
		BasicAttack = "WarriorCombo",
		MaxResource = 100,
		Actives = { "Cleave", "BattleShout", "Charge" },
	},
	Mage = {
		Id = "Mage",
		Name = "Mage",
		Resource = "Mana",
		Roles = { "Damage" },
		BasicAttack = "MagicBolt",
		MaxResource = 100,
		Actives = {},
	},
}

return table.freeze(Classes)
