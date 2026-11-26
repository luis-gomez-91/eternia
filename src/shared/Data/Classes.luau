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
}

local Classes: { [string]: ClassDef } = {
	Warrior = {
		Id = "Warrior",
		Name = "Warrior",
		Resource = "Energy",
		Roles = { "Tank", "Damage" },
		BasicAttack = "WarriorCombo",
	},
	Mage = {
		Id = "Mage",
		Name = "Mage",
		Resource = "Mana",
		Roles = { "Damage" },
		BasicAttack = "MagicBolt",
	},
}

return table.freeze(Classes)
