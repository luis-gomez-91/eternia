--!strict
-- Clases del juego como datos. Ver PLAN.md, sección "Clases".
-- Fase 0: las 6 clases con su ataque básico y sus 3 activas de clase.

export type Resource = "Energy" | "Mana"
export type Role = "Tank" | "Healer" | "Damage" | "Support"

export type ClassDef = {
	Id: string,
	Name: string,
	Order: number, -- orden en el selector
	Resource: Resource,
	Roles: { Role },
	BasicAttack: string,
	MaxResource: number,
	-- Maná: empieza lleno y se recupera solo (esta fracción del máximo por segundo).
	-- Energía: empieza en 0 y la genera el ataque básico.
	ResourceRegen: number,
	Actives: { string }, -- activas de clase, en orden de tecla (1, 2, 3)
	Ultimate: string, -- definitiva (tecla R); provisoria hasta las especializaciones
}

local Classes: { [string]: ClassDef } = {
	Warrior = {
		Id = "Warrior",
		Name = "Warrior",
		Order = 1,
		Resource = "Energy",
		Roles = { "Tank", "Damage" },
		BasicAttack = "WarriorCombo",
		MaxResource = 100,
		ResourceRegen = 0,
		Actives = { "Cleave", "BattleShout", "Charge" },
		Ultimate = "Whirlwind",
	},
	Paladin = {
		Id = "Paladin",
		Name = "Paladín",
		Order = 2,
		Resource = "Energy",
		Roles = { "Tank", "Healer", "Damage" },
		BasicAttack = "PaladinCombo",
		MaxResource = 100,
		ResourceRegen = 0,
		Actives = { "HolyStrike", "Consecration", "HealingLight" },
		Ultimate = "DawnHammer",
	},
	Ranger = {
		Id = "Ranger",
		Name = "Ranger",
		Order = 3,
		Resource = "Energy",
		Roles = { "Damage" },
		BasicAttack = "RangerShot",
		MaxResource = 100,
		ResourceRegen = 0,
		Actives = { "PowerShot", "ArrowRain", "Disengage" },
		Ultimate = "Volley",
	},
	Mage = {
		Id = "Mage",
		Name = "Mage",
		Order = 4,
		Resource = "Mana",
		Roles = { "Damage" },
		BasicAttack = "MagicBolt",
		MaxResource = 150,
		ResourceRegen = 0.02,
		Actives = { "ArcaneOrb", "Blink", "Fireball" },
		Ultimate = "MeteorShower",
	},
	Priest = {
		Id = "Priest",
		Name = "Sacerdote",
		Order = 5,
		Resource = "Mana",
		Roles = { "Healer", "Damage" },
		BasicAttack = "LightRay",
		MaxResource = 150,
		ResourceRegen = 0.02,
		Actives = { "Smite", "Heal", "HolyNova" },
		Ultimate = "DivineHymn",
	},
	Warlock = {
		Id = "Warlock",
		Name = "Brujo",
		Order = 6,
		Resource = "Mana",
		Roles = { "Damage", "Support" },
		BasicAttack = "ShadowBolt",
		MaxResource = 150,
		ResourceRegen = 0.02,
		Actives = { "Corruption", "DrainLife", "ShadowBlast" },
		Ultimate = "ShadowPact",
	},
}

for _, class in Classes do
	table.freeze(class.Roles)
	table.freeze(class.Actives)
	table.freeze(class)
end

return table.freeze(Classes)
