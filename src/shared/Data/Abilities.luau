--!strict
-- Habilidades como datos. Cliente y servidor leen la misma tabla:
-- el cliente para el ritmo de los controles, el servidor para validar.
-- Distancias en studs (1 stud ≈ 0,28 m).
--
-- Fase 0: cada clase tiene su ataque básico, sus 3 activas de clase (las mismas
-- para sus 3 especializaciones) y una definitiva provisoria. Ver PLAN.md, "Clases".

export type BasicHit = {
	Damage: number,
	Recovery: number, -- segundos mínimos hasta el siguiente golpe o disparo
	Cue: string, -- animación, efectos y sonido (Data/Feedback)
}

-- MeleeCombo: golpes al frente en un cono. Ranged: un disparo al objetivo.
export type BasicKind = "MeleeCombo" | "Ranged"

export type BasicAttack = {
	Id: string,
	Name: string,
	Kind: BasicKind,
	Range: number, -- alcance desde el borde del objetivo
	ArcDot: number, -- coseno del medio ángulo del cono frontal (0,5 = 120° en total)
	ComboReset: number, -- sin atacar este tiempo, el combo vuelve al golpe 1
	ResourcePerHit: number, -- Energía que genera o Maná que recupera cada acierto
	Speed: number?, -- Ranged: studs por segundo del proyectil (sin valor: instantáneo)
	Impact: string?, -- tipo de impacto que se ve (Data/Feedback.Impacts); "Melee" por defecto
	Hits: { BasicHit },
}

-- Activas: gastan recurso y tienen tiempo de espera propio, más la espera global.
-- Kind decide qué hace; cada tipo usa solo algunos de los campos opcionales.
--   Cleave: daña a todos en el cono frontal.
--   SelfBuff: más daño por un tiempo y recurso al instante.
--   Charge: corre hasta un enemigo y lo golpea.
--   Strike: daña a un objetivo (cuerpo a cuerpo o con proyectil); puede
--     salpicar alrededor, dejar daño en el tiempo y curar al que lo lanza.
--   Line: proyectil que avanza recto y atraviesa a todos los que toca.
--   Area: daña (y puede curar aliados) en un círculo, en el objetivo o en uno mismo,
--     una vez o en varios pulsos.
--   Heal: cura al que la usa y a los aliados cercanos.
--   Blink: teletransporte hacia adelante.
--   Leap: salto hacia atrás.
export type ActiveKind = "Cleave" | "SelfBuff" | "Charge" | "Strike" | "Line" | "Area" | "Heal" | "Blink" | "Leap"

-- Daño en el tiempo: `Damage` en cada pulso, `Ticks` pulsos cada `Interval` s.
export type DotDef = { Damage: number, Ticks: number, Interval: number }

export type ActiveDef = {
	Id: string,
	Name: string,
	Kind: ActiveKind,
	Cost: number, -- recurso de la clase (Energía o Maná)
	Cooldown: number,
	Cue: string, -- animación, efectos y sonido (Data/Feedback)
	Impact: string?, -- tipo de impacto que se ve (Data/Feedback.Impacts)
	Damage: number?,
	Range: number?,
	ArcDot: number?,
	Duration: number?, -- SelfBuff: segundos que dura · Leap: segundos en el aire
	DamageBonus: number?, -- SelfBuff: 0,2 = +20% de daño
	EnergyGain: number?, -- SelfBuff: recurso que da al usarla
	Speed: number?, -- Charge: studs/s del personaje · Strike/Line: del proyectil
	Delay: number?, -- segundos desde que se usa hasta que sale el golpe o el proyectil
	Radius: number?, -- Area: radio · Strike: radio de salpicadura · Heal: alcance a aliados
	SplashDamage: number?, -- Strike: daño a los demás dentro de Radius
	Width: number?, -- Line: ancho a cada lado
	Ticks: number?, -- Area: cantidad de pulsos (1 por defecto)
	Interval: number?, -- Area: segundos entre pulsos
	AtSelf: boolean?, -- Area: centrada en uno mismo en vez del objetivo
	Dot: DotDef?, -- Strike: daño en el tiempo tras el golpe
	Drain: number?, -- Strike: fracción del daño que cura al que la lanza
	Heal: number?, -- Heal/Area: fracción de la vida máxima que cura
	Distance: number?, -- Blink/Leap: studs que recorre
	-- Hechizos con carga (PLAN.md, "Hechizos con carga"): sale al terminar la carga.
	CastTime: number?, -- segundos de carga; sin valor, instantánea
	CastCue: string?, -- señal mientras carga (brillo que ven todos)
	CastMove: number?, -- velocidad al cargar, fracción de la normal (CAST_MOVE por defecto)
	CastMoveCancels: boolean?, -- moverse cancela la carga (prueba al estilo WoW)
}

local Abilities: { [string]: BasicAttack } = {
	WarriorCombo = {
		Id = "WarriorCombo",
		Name = "Combo de guerrero",
		Kind = "MeleeCombo",
		Range = 7,
		ArcDot = 0.5,
		ComboReset = 1.2,
		ResourcePerHit = 8,
		Hits = {
			{ Damage = 12, Recovery = 0.45, Cue = "WarriorCombo1" },
			{ Damage = 12, Recovery = 0.45, Cue = "WarriorCombo2" },
			{ Damage = 22, Recovery = 0.75, Cue = "WarriorCombo3" },
		},
	},
	-- Paladín: dos golpes de maza; el segundo, más lento, carga más Energía (Luz).
	PaladinCombo = {
		Id = "PaladinCombo",
		Name = "Golpe de maza",
		Kind = "MeleeCombo",
		Range = 7,
		ArcDot = 0.5,
		ComboReset = 1.3,
		ResourcePerHit = 10,
		Impact = "Holy",
		Hits = {
			{ Damage = 15, Recovery = 0.55, Cue = "PaladinCombo1" },
			{ Damage = 24, Recovery = 0.8, Cue = "PaladinCombo2" },
		},
	},
	RangerShot = {
		Id = "RangerShot",
		Name = "Disparo rápido",
		Kind = "Ranged",
		Range = 40,
		ArcDot = 0.8,
		ComboReset = 1,
		ResourcePerHit = 8,
		Speed = 140,
		Impact = "Arrow",
		Hits = { { Damage = 11, Recovery = 0.5, Cue = "RangerShot" } },
	},
	MagicBolt = {
		Id = "MagicBolt",
		Name = "Proyectil mágico",
		Kind = "Ranged",
		Range = 38,
		ArcDot = 0.8,
		ComboReset = 1,
		ResourcePerHit = 3,
		Speed = 90,
		Impact = "Arcane",
		Hits = { { Damage = 10, Recovery = 0.6, Cue = "MagicBolt" } },
	},
	LightRay = {
		Id = "LightRay",
		Name = "Rayo de luz",
		Kind = "Ranged",
		Range = 35,
		ArcDot = 0.8,
		ComboReset = 1,
		ResourcePerHit = 3,
		Impact = "Holy",
		Hits = { { Damage = 9, Recovery = 0.6, Cue = "LightRay" } },
	},
	ShadowBolt = {
		Id = "ShadowBolt",
		Name = "Descarga de sombra",
		Kind = "Ranged",
		Range = 38,
		ArcDot = 0.8,
		ComboReset = 1,
		ResourcePerHit = 3,
		Speed = 80,
		Impact = "Shadow",
		Hits = { { Damage = 10, Recovery = 0.6, Cue = "ShadowBolt" } },
	},
}

local Actives: { [string]: ActiveDef } = {
	-- Warrior
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

	-- Paladín
	HolyStrike = {
		Id = "HolyStrike",
		Cue = "HolyStrike",
		Name = "Golpe sagrado",
		Kind = "Strike",
		Impact = "Holy",
		Cost = 20,
		Cooldown = 5,
		Damage = 40,
		Range = 8,
		ArcDot = 0.5,
		Delay = 0.3,
	},
	Consecration = {
		Id = "Consecration",
		Cue = "Consecration",
		Name = "Consagración",
		Kind = "Area",
		Impact = "Holy",
		Cost = 25,
		Cooldown = 15,
		Damage = 8,
		Radius = 10,
		AtSelf = true,
		Delay = 0.35,
		Ticks = 6,
		Interval = 1,
	},
	HealingLight = {
		Id = "HealingLight",
		Cue = "HealingLight",
		Name = "Luz sanadora",
		Kind = "Heal",
		Cost = 30,
		Cooldown = 18,
		Heal = 0.25,
		Radius = 20,
		Delay = 0.4,
	},

	-- Ranger
	PowerShot = {
		Id = "PowerShot",
		Cue = "PowerShot",
		Name = "Disparo potente",
		Kind = "Strike",
		Impact = "Arrow",
		Cost = 25,
		Cooldown = 6,
		Damage = 45,
		Range = 45,
		ArcDot = 0.8,
		Speed = 170,
		Delay = 0.45,
	},
	ArrowRain = {
		Id = "ArrowRain",
		Cue = "ArrowRain",
		Name = "Lluvia de flechas",
		Kind = "Area",
		Impact = "Arrow",
		Cost = 30,
		Cooldown = 14,
		Damage = 12,
		Range = 40,
		ArcDot = 0.8,
		Radius = 8,
		Delay = 0.8,
		Ticks = 3,
		Interval = 0.35,
	},
	Disengage = {
		Id = "Disengage",
		Cue = "Disengage",
		Name = "Retirada",
		Kind = "Leap",
		Cost = 10,
		Cooldown = 10,
		Distance = 20,
		Duration = 0.35,
	},

	-- Mage
	ArcaneOrb = {
		Id = "ArcaneOrb",
		Cue = "ArcaneOrb",
		Name = "Orbe arcano",
		Kind = "Line",
		Impact = "Arcane",
		Cost = 15,
		Cooldown = 6,
		Damage = 30,
		Range = 35,
		Width = 3,
		Speed = 35,
		Delay = 0.25,
	},
	Blink = {
		Id = "Blink",
		Cue = "Blink",
		Name = "Parpadeo",
		Kind = "Blink",
		Cost = 10,
		Cooldown = 12,
		Distance = 30,
	},
	Fireball = {
		Id = "Fireball",
		Cue = "Fireball",
		Name = "Bola de fuego",
		Kind = "Strike",
		Impact = "Fire",
		Cost = 20,
		Cooldown = 3,
		-- Con carga pega más que una instantánea del mismo costo (antes 35 y 15).
		Damage = 55,
		Range = 40,
		ArcDot = 0.8,
		Speed = 75,
		Delay = 0.1,
		Radius = 6,
		SplashDamage = 20,
		CastTime = 1,
		CastCue = "FireballCharge",
		-- Para probar la regla de WoW: CastMove = 1 y CastMoveCancels = true.
		CastMove = 0.5,
		Dot = { Damage = 4, Ticks = 4, Interval = 1 },
	},

	-- Sacerdote
	Smite = {
		Id = "Smite",
		Cue = "Smite",
		Name = "Castigo",
		Kind = "Strike",
		Impact = "Holy",
		Cost = 20,
		Cooldown = 6,
		Damage = 35,
		Range = 35,
		ArcDot = 0.8,
		Delay = 0.35,
	},
	Heal = {
		Id = "Heal",
		Cue = "PriestHeal",
		Name = "Curación",
		Kind = "Heal",
		Cost = 25,
		Cooldown = 8,
		Heal = 0.3,
		Radius = 25,
		Delay = 0.45,
	},
	HolyNova = {
		Id = "HolyNova",
		Cue = "HolyNova",
		Name = "Nova sagrada",
		Kind = "Area",
		Impact = "Holy",
		Cost = 25,
		Cooldown = 10,
		Damage = 20,
		Radius = 10,
		AtSelf = true,
		Delay = 0.3,
		Heal = 0.1,
	},

	-- Brujo
	Corruption = {
		Id = "Corruption",
		Cue = "Corruption",
		Name = "Corrupción",
		Kind = "Strike",
		Impact = "Shadow",
		Cost = 15,
		Cooldown = 8,
		Damage = 0,
		Range = 38,
		ArcDot = 0.8,
		Delay = 0.3,
		Dot = { Damage = 8, Ticks = 6, Interval = 1 },
	},
	DrainLife = {
		Id = "DrainLife",
		Cue = "DrainLife",
		Name = "Drenar vida",
		Kind = "Strike",
		Impact = "Shadow",
		Cost = 20,
		Cooldown = 10,
		Damage = 0,
		Range = 30,
		ArcDot = 0.8,
		Delay = 0.2,
		Dot = { Damage = 10, Ticks = 4, Interval = 0.5 },
		Drain = 0.5,
	},
	ShadowBlast = {
		Id = "ShadowBlast",
		Cue = "ShadowBlast",
		Name = "Explosión de sombra",
		Kind = "Area",
		Impact = "Shadow",
		Cost = 30,
		Cooldown = 12,
		Damage = 35,
		Range = 38,
		ArcDot = 0.8,
		Radius = 8,
		Delay = 0.6,
	},

	-- Definitivas provisorias (Fase 0), una por clase, con la tecla R. Se usan
	-- con la barra de definitiva llena en vez de recurso (Cost 0). Las finales
	-- son una por especialización, en el nivel 50 (Fase 2).
	Whirlwind = {
		Id = "Whirlwind",
		Cue = "Whirlwind",
		Name = "Torbellino",
		Kind = "Area",
		Cost = 0,
		Cooldown = 1,
		Damage = 35,
		Radius = 11,
		AtSelf = true,
		Delay = 0.1,
		Ticks = 4,
		Interval = 0.35,
	},
	DawnHammer = {
		Id = "DawnHammer",
		Cue = "DawnHammer",
		Name = "Martillo del alba",
		Kind = "Area",
		Impact = "Holy",
		Cost = 0,
		Cooldown = 1,
		Damage = 70,
		Radius = 14,
		AtSelf = true,
		Delay = 0.45,
		Heal = 0.4,
	},
	Volley = {
		Id = "Volley",
		Cue = "Volley",
		Name = "Andanada",
		Kind = "Area",
		Impact = "Arrow",
		Cost = 0,
		Cooldown = 1,
		Damage = 28,
		Range = 45,
		ArcDot = 0.8,
		Radius = 11,
		Delay = 0.6,
		Ticks = 5,
		Interval = 0.3,
	},
	MeteorShower = {
		Id = "MeteorShower",
		Cue = "MeteorShower",
		Name = "Lluvia de meteoros",
		Kind = "Area",
		Impact = "Fire",
		Cost = 0,
		Cooldown = 1,
		Damage = 55,
		Range = 40,
		ArcDot = 0.8,
		Radius = 10,
		Delay = 1,
		Ticks = 3,
		Interval = 0.35,
	},
	DivineHymn = {
		Id = "DivineHymn",
		Cue = "DivineHymn",
		Name = "Himno divino",
		Kind = "Area",
		Impact = "Holy",
		Cost = 0,
		Cooldown = 1,
		Damage = 30,
		Radius = 16,
		AtSelf = true,
		Delay = 0.4,
		Heal = 0.5,
	},
	ShadowPact = {
		Id = "ShadowPact",
		Cue = "ShadowPact",
		Name = "Pacto de sombras",
		Kind = "Strike",
		Impact = "Shadow",
		Cost = 0,
		Cooldown = 1,
		Damage = 90,
		Range = 38,
		ArcDot = 0.8,
		Delay = 0.5,
		Drain = 0.5,
		Dot = { Damage = 15, Ticks = 4, Interval = 1 },
	},
}

-- Barra de definitiva: puntos para llenarla. Suman el daño hecho, la curación
-- hecha y el daño recibido (este último vale el doble). Con unos 3.000 de daño
-- contra el jefe de prueba se llena unas 2 veces por pelea.
local ULTIMATE_FILL = 1500
local ULTIMATE_TAKEN_WEIGHT = 2

-- Tipos que necesitan un enemigo elegido para usarse.
local NEEDS_TARGET: { [ActiveKind]: boolean } = {
	Charge = true,
	Strike = true,
}

-- Espera mínima entre dos activas cualesquiera.
local GLOBAL_COOLDOWN = 0.5

-- Velocidad al cargar un hechizo si la habilidad no dice otra (fracción de la normal).
local CAST_MOVE = 0.5

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

-- Strike y Charge necesitan un enemigo elegido; Area también, salvo la centrada en uno mismo.
local function needsTarget(def: ActiveDef): boolean
	return NEEDS_TARGET[def.Kind] == true or (def.Kind == "Area" and not def.AtSelf)
end

for _, def in Actives do
	if def.Dot then
		table.freeze(def.Dot)
	end
	table.freeze(def)
end
for _, def in Abilities do
	for _, hit in def.Hits do
		table.freeze(hit)
	end
	table.freeze(def.Hits)
	table.freeze(def)
end

return table.freeze({
	Abilities = table.freeze(Abilities),
	Actives = table.freeze(Actives),
	NeedsTarget = needsTarget,
	GlobalCooldown = GLOBAL_COOLDOWN,
	CastMove = CAST_MOVE,
	UltimateFill = ULTIMATE_FILL,
	UltimateTakenWeight = ULTIMATE_TAKEN_WEIGHT,
	BaseCritChance = BASE_CRIT_CHANCE,
	Dodge = table.freeze(DODGE),
})
