--!strict
-- Mobs y jefes como datos. Ver las fichas en docs/fichas/mobs y docs/fichas/jefes.
-- Fase 0: los 3 mobs de la subárea de prueba y el jefe de prueba de 2 fases.
--
-- Cada ataque se avisa en el suelo con una zona roja durante `WindUp` segundos
-- y el daño se decide al terminar el aviso, en el lugar marcado: si el jugador
-- sale de la zona o esquiva (invulnerable), no recibe daño.
--
-- Nombres provisorios (decisión pendiente: nombres finales).

-- Swing: golpe frontal en un rectángulo. Bolt: proyectil recto que choca con el
-- primero que cruza o con una pared. Charge: el mob embiste en línea recta y daña
-- a todos los que atraviesa. Slam: círculo alrededor del mob. Barrage: círculos
-- bajo cada jugador cercano y unos al azar. Summon: llama ayudantes (sin aviso).
export type AttackKind = "Swing" | "Bolt" | "Charge" | "Slam" | "Barrage" | "Summon"

export type AttackDef = {
	Id: string,
	Kind: AttackKind,
	Damage: number,
	WindUp: number, -- segundos de aviso antes del golpe
	Recovery: number, -- segundos quieto después del golpe (la ventana para pegarle)
	Cooldown: number,
	Range: number, -- distancia máxima (desde el borde del objetivo) para empezar el ataque
	MinRange: number?, -- no lo usa si el objetivo está más cerca que esto
	Length: number?, -- Swing, Bolt, Charge: largo de la zona
	Width: number?, -- Swing, Bolt, Charge: ancho total de la zona
	Radius: number?, -- Slam, Barrage: radio de cada círculo
	Speed: number?, -- Bolt: velocidad del proyectil · Charge: velocidad de la embestida
	Extra: number?, -- Barrage: círculos extra al azar
	Spread: number?, -- Barrage: radio alrededor del jefe donde caen los extra
	Summon: { Mob: string, Count: number }?,
	Impact: string?, -- tipo de impacto que se ve en el jugador (Data/Feedback.Impacts)
	Cue: string?, -- señal de Data/Feedback al soltar el ataque
	WarnCue: string?, -- señal al empezar el aviso (sonido de aviso)
}

export type PhaseDef = {
	Below: number, -- empieza cuando la vida baja de esta fracción (la primera es 1)
	Attacks: { string },
	SpeedMultiplier: number?,
	CooldownMultiplier: number?, -- 0,8 = esperas un 20% más cortas
	OnEnter: string?, -- ataque que hace al entrar a la fase (p. ej. llamar ayudantes)
	Pause: number?, -- segundos inmune mientras ruge al cambiar de fase
}

export type MobDef = {
	Id: string,
	Name: string,
	Level: number,
	Body: string, -- forma provisoria (server/Mobs/Bodies)
	MaxHealth: number,
	HitRadius: number,
	WalkSpeed: number, -- persiguiendo
	PatrolSpeed: number,
	PatrolRadius: number, -- se mueve al azar hasta esta distancia de su sitio
	AggroRange: number, -- distancia a la que detecta jugadores
	LinkRange: number, -- los mobs quietos a esta distancia se suman a la pelea
	LeashRange: number, -- si se aleja más que esto de su sitio, vuelve
	KeepDistance: number?, -- a distancia: retrocede si el jugador se acerca más
	RespawnTime: number,
	Attacks: { string }, -- en orden de prioridad
	AggroCue: string?, -- señal al detectar al jugador (Data/Feedback)
	DeathCue: string?, -- señal al morir
	Phases: { PhaseDef }?, -- jefes
	Boss: boolean?,
}

local Attacks: { [string]: AttackDef } = {
	-- Goblin Saqueador: garrotazo corto y rápido, avisado.
	GoblinClub = {
		Id = "GoblinClub",
		Kind = "Swing",
		Damage = 8,
		WindUp = 0.7,
		Recovery = 0.9,
		Cooldown = 2.6,
		Range = 4,
		Length = 6.5,
		Width = 5,
		Impact = "Melee",
		Cue = "GoblinClub",
	},
	-- Araña Escupidora: escupitajo de veneno en línea recta.
	SpiderSpit = {
		Id = "SpiderSpit",
		Kind = "Bolt",
		Damage = 9,
		WindUp = 0.9,
		Recovery = 0.6,
		Cooldown = 2.6,
		Range = 30,
		Length = 40,
		Width = 2.5,
		Speed = 45,
		Impact = "Venom",
		Cue = "SpiderSpit",
	},
	-- Araña Escupidora: mordida si el jugador se le pega.
	SpiderBite = {
		Id = "SpiderBite",
		Kind = "Swing",
		Damage = 7,
		WindUp = 0.5,
		Recovery = 0.8,
		Cooldown = 3,
		Range = 3,
		Length = 5,
		Width = 4,
		Impact = "Venom",
		Cue = "SpiderBite",
	},
	-- Lobo Gris: avisa y embiste en línea recta.
	WolfCharge = {
		Id = "WolfCharge",
		Kind = "Charge",
		Damage = 18,
		WindUp = 1.1,
		Recovery = 1.4,
		Cooldown = 6,
		Range = 24,
		MinRange = 7,
		Length = 30,
		Width = 4,
		Speed = 55,
		Impact = "Melee",
		Cue = "WolfCharge",
		WarnCue = "WolfGrowl",
	},
	-- Lobo Gris: mordida de cerca entre embestidas.
	WolfBite = {
		Id = "WolfBite",
		Kind = "Swing",
		Damage = 8,
		WindUp = 0.55,
		Recovery = 0.8,
		Cooldown = 2,
		Range = 3.5,
		Length = 6,
		Width = 4.5,
		Impact = "Melee",
		Cue = "WolfBite",
	},

	-- Jefe de prueba: Ogro del Claro.
	OgreSmash = {
		Id = "OgreSmash",
		Kind = "Swing",
		Damage = 22,
		WindUp = 1.0,
		Recovery = 1.0,
		Cooldown = 3.2,
		Range = 6,
		Length = 13,
		Width = 9,
		Impact = "Heavy",
		Cue = "OgreSmash",
	},
	OgreStomp = {
		Id = "OgreStomp",
		Kind = "Slam",
		Damage = 30,
		WindUp = 1.6,
		Recovery = 1.2,
		Cooldown = 11,
		Range = 9,
		Radius = 13,
		Impact = "Heavy",
		Cue = "OgreStomp",
		WarnCue = "BossWarn",
	},
	OgreRocks = {
		Id = "OgreRocks",
		Kind = "Barrage",
		Damage = 24,
		WindUp = 1.6,
		Recovery = 0.8,
		Cooldown = 9,
		Range = 40,
		Radius = 6,
		Extra = 4,
		Spread = 26,
		Impact = "Heavy",
		Cue = "OgreRock",
		WarnCue = "BossWarn",
	},
	OgreCall = {
		Id = "OgreCall",
		Kind = "Summon",
		Damage = 0,
		WindUp = 0,
		Recovery = 0.5,
		Cooldown = 0,
		Range = math.huge,
		Summon = { Mob = "GoblinRaider", Count = 2 },
	},
}

local Mobs: { [string]: MobDef } = {
	GoblinRaider = {
		Id = "GoblinRaider",
		Name = "Goblin Saqueador",
		Level = 2,
		Body = "Goblin",
		MaxHealth = 180,
		HitRadius = 1.5,
		WalkSpeed = 14,
		PatrolSpeed = 6,
		PatrolRadius = 8,
		AggroRange = 18,
		LinkRange = 14,
		LeashRange = 50,
		RespawnTime = 30,
		AggroCue = "GoblinAggro",
		DeathCue = "GoblinDeath",
		Attacks = { "GoblinClub" },
	},
	VenomSpider = {
		Id = "VenomSpider",
		Name = "Araña Escupidora",
		Level = 2,
		Body = "Spider",
		MaxHealth = 140,
		HitRadius = 2,
		WalkSpeed = 13,
		PatrolSpeed = 5,
		PatrolRadius = 6,
		AggroRange = 26,
		LinkRange = 14,
		LeashRange = 50,
		KeepDistance = 12,
		RespawnTime = 30,
		AggroCue = "SpiderAggro",
		DeathCue = "SpiderDeath",
		Attacks = { "SpiderBite", "SpiderSpit" },
	},
	GreyWolf = {
		Id = "GreyWolf",
		Name = "Lobo Gris",
		Level = 3,
		Body = "Wolf",
		MaxHealth = 220,
		HitRadius = 2,
		WalkSpeed = 16,
		PatrolSpeed = 7,
		PatrolRadius = 10,
		AggroRange = 22,
		LinkRange = 16,
		LeashRange = 55,
		RespawnTime = 30,
		AggroCue = "WolfGrowl",
		DeathCue = "WolfDeath",
		Attacks = { "WolfCharge", "WolfBite" },
	},
	ClearingOgre = {
		Id = "ClearingOgre",
		Name = "Ogro del Claro",
		Level = 5,
		Body = "Ogre",
		MaxHealth = 3000,
		HitRadius = 3.5,
		WalkSpeed = 12,
		PatrolSpeed = 0,
		PatrolRadius = 0,
		AggroRange = 20,
		LinkRange = 0,
		LeashRange = 38,
		RespawnTime = 45,
		Boss = true,
		AggroCue = "OgreAggro",
		DeathCue = "OgreDeath",
		Attacks = { "OgreStomp", "OgreSmash" },
		Phases = {
			{ Below = 1, Attacks = { "OgreStomp", "OgreSmash" } },
			{
				Below = 0.5,
				Attacks = { "OgreRocks", "OgreStomp", "OgreSmash" },
				SpeedMultiplier = 1.2,
				CooldownMultiplier = 0.8,
				OnEnter = "OgreCall",
				Pause = 1.5,
			},
		},
	},
}

for id, attack in Attacks do
	assert(attack.Id == id, `Ataque {id} con Id distinto`)
	table.freeze(attack)
end
for id, mob in Mobs do
	assert(mob.Id == id, `Mob {id} con Id distinto`)
	for _, cueId in { mob.AggroCue, mob.DeathCue } do
		assert(typeof(cueId) == "string", `{id}: falta AggroCue o DeathCue`)
	end
	for _, attackId in mob.Attacks do
		assert(Attacks[attackId], `{id}: ataque desconocido {attackId}`)
	end
	for _, phase in mob.Phases or {} do
		for _, attackId in phase.Attacks do
			assert(Attacks[attackId], `{id}: ataque desconocido {attackId}`)
		end
	end
	table.freeze(mob)
end

return table.freeze({
	Mobs = table.freeze(Mobs),
	Attacks = table.freeze(Attacks),
})
