--!strict
-- Lo que se ve y se oye al atacar, como datos. Cada ataque y habilidad nombra
-- una señal (Cue) en Data/Abilities; aquí está qué animación, efectos y sonido lleva.
--
-- Provisorio (Fase 0): las animaciones son poses hechas en código (Data/Poses)
-- y los efectos son piezas simples. Para pasar al arte final basta poner
-- `Animation = "rbxassetid://..."` (reemplaza a la pose) y cambiar los IDs de sonido.
--
-- Sonidos: solo con licencia clara (ver PLAN.md, "Audio"). Catálogo con el
-- texto usado para generar cada uno en docs/AUDIO.md.

local Abilities = require(script.Parent.Abilities)

local Actives = Abilities.Actives
local Basics = Abilities.Abilities

export type SoundDef = {
	Id: string,
	Volume: number?,
	Pitch: number?,
	PitchJitter: number?, -- variación al azar de tono (0,05 = ±5%) para que no suene repetido
	Group: SoundGroupName?, -- grupo de volumen (por defecto "SFX")
	Delay: number?, -- segundos desde que empieza la señal
	AtTarget: boolean?, -- suena en el objetivo en vez de en el personaje
}

-- Grupos de volumen; cada uno tendrá su control en el menú de opciones.
export type SoundGroupName = "SFX" | "Music" | "Ambience" | "Voice"
local SOUND_GROUPS: { SoundGroupName } = { "SFX", "Music", "Ambience", "Voice" }

-- Slash: arco frente al personaje. Ring: onda que se expande en el suelo.
-- Trail: estela que sigue al personaje. Aura: brillo sobre el personaje.
-- Spark: chispa en el punto de impacto. Beam: rayo de la mano al objetivo.
-- Column: columna de luz que baja. Burst: esfera que se expande (explosión).
-- Field: círculo en el suelo que dura. Rain: flechas que caen en un área.
export type EffectKind = "Slash" | "Ring" | "Trail" | "Aura" | "Spark" | "Beam" | "Column" | "Burst" | "Field" | "Rain"

export type EffectDef = {
	Kind: EffectKind,
	Color: Color3,
	Delay: number?, -- segundos desde que empieza la señal
	Duration: number?,
	Size: number?, -- Slash: radio · Ring/Burst/Field/Rain: diámetro · Spark: escala · Column: alto
	Span: number?, -- Slash: grados que cubre el arco
	Roll: number?, -- Slash: inclinación del arco en grados (0 horizontal, 90 vertical)
	Sweep: number?, -- Slash: 1 de derecha a izquierda, -1 al revés
	Height: number?, -- Slash/Ring/Burst: altura respecto al centro (o al suelo con Ground)
	AtTarget: boolean?, -- se dibuja en el objetivo en vez de en el personaje
	Ground: boolean?, -- se apoya en el suelo bajo el punto
	From: string?, -- Beam: parte del personaje de donde sale (p. ej. "RightHand")
	EndColor: Color3?, -- Beam: color en el extremo del objetivo
}

-- Proyectil que sale de la mano y vuela hasta el objetivo (o recto `Distance`
-- studs si no hay). Al llegar se ven `Impact`. Su velocidad y su retraso son
-- los de la habilidad, así llega cuando el servidor aplica el daño.
export type ProjectileDef = {
	Shape: "Orb" | "Arrow",
	Color: Color3,
	Size: number,
	Speed: number,
	Delay: number?,
	From: string?, -- parte del personaje de donde sale (por defecto "RightHand")
	Distance: number?,
	Impact: { Effects: { EffectDef }?, Sound: SoundDef? }?,
}

export type Cue = {
	Animation: string?, -- arte final: ID de animación; si está, no se usa Pose
	Pose: string?, -- provisorio: pose de Data/Poses
	Speed: number?, -- velocidad de la animación o pose (1 = normal)
	Effects: { EffectDef }?,
	Sound: SoundDef?,
	Projectile: ProjectileDef?,
}

-- IDs de los sonidos subidos (docs/AUDIO.md).
local SOUND_IDS = {
	WarriorCombo1 = "rbxassetid://111424923198216",
	WarriorCombo2 = "rbxassetid://124397046727052",
	WarriorCombo3 = "rbxassetid://103438577618554",
	Cleave = "rbxassetid://105049720867727",
	BattleShout = "rbxassetid://104391889530290",
	Charge = "rbxassetid://77904768404795",
	Dodge = "rbxassetid://83476574026443",
	Impact = "rbxassetid://88644710053967",
	ImpactCrit = "rbxassetid://125109039614338",
	PaladinSwing = "rbxassetid://129001422905314",
	PaladinSmash = "rbxassetid://117518788295543",
	HolyStrike = "rbxassetid://111709778313341",
	Consecration = "rbxassetid://95021981650169",
	HealingLight = "rbxassetid://114515546991936",
	RangerShot = "rbxassetid://70897685493016",
	PowerShot = "rbxassetid://77676074139895",
	ArrowRain = "rbxassetid://93857486191598",
	Disengage = "rbxassetid://90439571976116",
	MagicBolt = "rbxassetid://77777840439447",
	ArcaneOrb = "rbxassetid://110861100635255",
	Blink = "rbxassetid://101376722293859",
	FireballCast = "rbxassetid://129423200161204",
	FireballExplosion = "rbxassetid://128669217440977",
	LightRay = "rbxassetid://76696059392740",
	Smite = "rbxassetid://115490442257201",
	PriestHeal = "rbxassetid://105090647961010",
	HolyNova = "rbxassetid://138263651658995",
	ShadowBolt = "rbxassetid://122949372827472",
	Corruption = "rbxassetid://87196410508863",
	DrainLife = "rbxassetid://127601950191336",
	ShadowBlast = "rbxassetid://102715922573898",
}

local function sound(
	name: string,
	volume: number,
	jitter: number?,
	extra: { Delay: number?, AtTarget: boolean?, Pitch: number? }?
): SoundDef
	local id = SOUND_IDS[name]
	assert(id, `Sonido sin ID: {name}`)
	return {
		Id = id,
		Volume = volume,
		PitchJitter = jitter,
		Delay = extra and extra.Delay,
		AtTarget = extra and extra.AtTarget,
		Pitch = extra and extra.Pitch,
	}
end

local GOLD = Color3.fromRGB(255, 205, 90)
local STEEL = Color3.fromRGB(225, 235, 255)
local EMBER = Color3.fromRGB(255, 140, 60)
local HOLY = Color3.fromRGB(255, 225, 130)
local LIGHT = Color3.fromRGB(255, 248, 215)
local HEAL = Color3.fromRGB(140, 255, 160)
local NATURE = Color3.fromRGB(170, 230, 120)
local ARCANE = Color3.fromRGB(175, 120, 255)
local FIRE = Color3.fromRGB(255, 120, 35)
local SHADOW = Color3.fromRGB(150, 55, 230)
local FEL = Color3.fromRGB(120, 255, 110)

local Cues: { [string]: Cue } = {
	-- Warrior: dos tajos cruzados y un golpe de arriba hacia abajo.
	WarriorCombo1 = {
		Pose = "WarriorSlashRight",
		Effects = {
			{ Kind = "Slash", Color = STEEL, Delay = 0.1, Size = 6, Span = 140, Roll = -15, Sweep = 1 },
		},
		Sound = sound("WarriorCombo1", 0.5, 0.05),
	},
	WarriorCombo2 = {
		Pose = "WarriorSlashLeft",
		Effects = {
			{ Kind = "Slash", Color = STEEL, Delay = 0.1, Size = 6, Span = 140, Roll = 15, Sweep = -1 },
		},
		Sound = sound("WarriorCombo2", 0.5, 0.05),
	},
	WarriorCombo3 = {
		Pose = "WarriorOverhead",
		Effects = {
			{ Kind = "Slash", Color = GOLD, Delay = 0.22, Size = 5, Span = 110, Roll = 90, Sweep = 1, Height = 1.2 },
			{ Kind = "Ring", Color = GOLD, Delay = 0.3, Duration = 0.35, Size = 9, Height = -2.8 },
		},
		Sound = sound("WarriorCombo3", 0.65, 0.04),
	},
	Cleave = {
		Pose = "WarriorCleave",
		Effects = {
			{ Kind = "Slash", Color = EMBER, Delay = 0.14, Size = 8.5, Span = 200, Roll = 0, Sweep = 1 },
		},
		Sound = sound("Cleave", 0.7, 0.04),
	},
	BattleShout = {
		Pose = "WarriorShout",
		Effects = {
			{ Kind = "Ring", Color = GOLD, Delay = 0.15, Duration = 0.5, Size = 22, Height = -2.8 },
			{ Kind = "Ring", Color = GOLD, Delay = 0.3, Duration = 0.5, Size = 14, Height = -2.8 },
			{ Kind = "Aura", Color = GOLD, Delay = 0.15, Duration = Actives.BattleShout.Duration },
		},
		Sound = sound("BattleShout", 0.7),
	},
	Charge = {
		Pose = "WarriorCharge",
		Effects = {
			{ Kind = "Trail", Color = EMBER, Duration = 0.4 },
		},
		Sound = sound("Charge", 0.6),
	},

	-- Paladín: maza pesada y luz dorada.
	PaladinCombo1 = {
		Pose = "PaladinSwing",
		Effects = {
			{ Kind = "Slash", Color = HOLY, Delay = 0.13, Size = 5.5, Span = 130, Roll = -25, Sweep = 1 },
		},
		Sound = sound("PaladinSwing", 0.55, 0.05),
	},
	PaladinCombo2 = {
		Pose = "WarriorOverhead",
		Speed = 0.95,
		Effects = {
			{ Kind = "Slash", Color = HOLY, Delay = 0.23, Size = 5, Span = 100, Roll = 90, Sweep = 1, Height = 1.2 },
			{ Kind = "Ring", Color = HOLY, Delay = 0.32, Duration = 0.4, Size = 10, Height = -2.8 },
		},
		Sound = sound("PaladinSmash", 0.65, 0.04),
	},
	HolyStrike = {
		Pose = "WarriorOverhead",
		Speed = 0.9,
		Effects = {
			{ Kind = "Aura", Color = HOLY, Duration = 0.5 },
			{ Kind = "Column", Color = HOLY, Delay = 0.28, Duration = 0.45, Size = 14, AtTarget = true, Ground = true },
			{ Kind = "Ring", Color = HOLY, Delay = 0.32, Duration = 0.4, Size = 10, AtTarget = true, Ground = true },
		},
		Sound = sound("HolyStrike", 0.7, 0.03),
	},
	Consecration = {
		Pose = "PaladinSlam",
		Effects = {
			{ Kind = "Ring", Color = HOLY, Delay = 0.3, Duration = 0.45, Size = 22, Height = -2.8 },
			{
				Kind = "Field",
				Color = HOLY,
				Delay = 0.3,
				Duration = (Actives.Consecration.Ticks :: number) * (Actives.Consecration.Interval :: number),
				Size = (Actives.Consecration.Radius :: number) * 2,
				Ground = true,
			},
		},
		Sound = sound("Consecration", 0.6),
	},
	HealingLight = {
		Pose = "CastRaise",
		Effects = {
			{ Kind = "Column", Color = HEAL, Delay = 0.35, Duration = 0.7, Size = 16, Ground = true },
			{ Kind = "Aura", Color = HEAL, Delay = 0.35, Duration = 1.2 },
			{ Kind = "Ring", Color = HEAL, Delay = 0.4, Duration = 0.6, Size = 14, Height = -2.8 },
		},
		Sound = sound("HealingLight", 0.6),
	},

	-- Ranger: arco, flechas verdes.
	RangerShot = {
		Pose = "BowShot",
		Projectile = {
			Shape = "Arrow",
			Color = STEEL,
			Size = 1,
			Speed = Basics.RangerShot.Speed :: number,
			From = "LeftHand",
		},
		Sound = sound("RangerShot", 0.45, 0.06),
	},
	PowerShot = {
		Pose = "BowPower",
		Effects = {
			{ Kind = "Aura", Color = NATURE, Duration = 0.6 },
		},
		Projectile = {
			Shape = "Arrow",
			Color = NATURE,
			Size = 1.8,
			Speed = Actives.PowerShot.Speed :: number,
			Delay = Actives.PowerShot.Delay,
			From = "LeftHand",
		},
		Sound = sound("PowerShot", 0.65, 0.03, { Delay = 0.38 }),
	},
	ArrowRain = {
		Pose = "BowSky",
		Effects = {
			{
				Kind = "Ring",
				Color = NATURE,
				Duration = 0.8,
				Size = (Actives.ArrowRain.Radius :: number) * 2,
				AtTarget = true,
				Ground = true,
			},
			{
				Kind = "Rain",
				Color = NATURE,
				Delay = (Actives.ArrowRain.Delay :: number) - 0.25,
				Duration = (Actives.ArrowRain.Ticks :: number) * (Actives.ArrowRain.Interval :: number) + 0.2,
				Size = (Actives.ArrowRain.Radius :: number) * 2,
				AtTarget = true,
				Ground = true,
			},
		},
		Sound = sound("ArrowRain", 0.6),
	},
	Disengage = {
		Pose = "LeapBack",
		Effects = {
			{ Kind = "Trail", Color = NATURE, Duration = Actives.Disengage.Duration },
			{ Kind = "Ring", Color = NATURE, Duration = 0.35, Size = 8, Height = -2.8 },
		},
		Sound = sound("Disengage", 0.5, 0.05),
	},

	-- Mage: arcano violeta y fuego.
	MagicBolt = {
		Pose = "CastRight",
		Projectile = { Shape = "Orb", Color = ARCANE, Size = 0.7, Speed = Basics.MagicBolt.Speed :: number },
		Sound = sound("MagicBolt", 0.45, 0.06),
	},
	ArcaneOrb = {
		Pose = "CastPush",
		Projectile = {
			Shape = "Orb",
			Color = ARCANE,
			Size = 2.6,
			Speed = Actives.ArcaneOrb.Speed :: number,
			Delay = Actives.ArcaneOrb.Delay,
			Distance = Actives.ArcaneOrb.Range,
		},
		Sound = sound("ArcaneOrb", 0.6),
	},
	BlinkOut = {
		Effects = { { Kind = "Burst", Color = ARCANE, Duration = 0.3, Size = 6 } },
	},
	Blink = {
		Effects = {
			{ Kind = "Burst", Color = ARCANE, Duration = 0.35, Size = 7 },
			{ Kind = "Aura", Color = ARCANE, Duration = 0.4 },
		},
		Sound = sound("Blink", 0.55, 0.04),
	},
	Fireball = {
		Pose = "CastOverhead",
		Projectile = {
			Shape = "Orb",
			Color = FIRE,
			Size = 1.5,
			Speed = Actives.Fireball.Speed :: number,
			Delay = Actives.Fireball.Delay,
			Impact = {
				Effects = {
					{ Kind = "Burst", Color = FIRE, Duration = 0.4, Size = (Actives.Fireball.Radius :: number) * 2 },
					{ Kind = "Ring", Color = EMBER, Duration = 0.4, Size = 12, Ground = true },
				},
				Sound = sound("FireballExplosion", 0.65, 0.05),
			},
		},
		Sound = sound("FireballCast", 0.55, 0.04),
	},

	-- Sacerdote: luz blanca y curación verde.
	LightRay = {
		Pose = "CastRight",
		Effects = {
			{ Kind = "Beam", Color = LIGHT, Delay = 0.08, Duration = 0.25, From = "RightHand", AtTarget = true },
		},
		Sound = sound("LightRay", 0.45, 0.06),
	},
	Smite = {
		Pose = "CastOverhead",
		Effects = {
			{ Kind = "Column", Color = LIGHT, Delay = 0.3, Duration = 0.5, Size = 18, AtTarget = true, Ground = true },
			{ Kind = "Burst", Color = HOLY, Delay = 0.35, Duration = 0.35, Size = 6, AtTarget = true },
		},
		Sound = sound("Smite", 0.65, 0.04, { Delay = 0.25, AtTarget = true }),
	},
	PriestHeal = {
		Pose = "CastRaise",
		Effects = {
			{ Kind = "Column", Color = HEAL, Delay = 0.4, Duration = 0.7, Size = 16, Ground = true },
			{ Kind = "Aura", Color = HEAL, Delay = 0.4, Duration = 1.2 },
			{ Kind = "Ring", Color = HEAL, Delay = 0.45, Duration = 0.6, Size = 14, Height = -2.8 },
		},
		Sound = sound("PriestHeal", 0.6),
	},
	HolyNova = {
		Pose = "CastRaise",
		Speed = 1.4,
		Effects = {
			{
				Kind = "Burst",
				Color = LIGHT,
				Delay = 0.28,
				Duration = 0.4,
				Size = (Actives.HolyNova.Radius :: number) * 2,
			},
			{
				Kind = "Ring",
				Color = HOLY,
				Delay = 0.3,
				Duration = 0.45,
				Size = (Actives.HolyNova.Radius :: number) * 2 + 2,
				Height = -2.8,
			},
		},
		Sound = sound("HolyNova", 0.65, 0.03, { Delay = 0.22 }),
	},

	-- Brujo: sombra violeta y verde vil.
	ShadowBolt = {
		Pose = "CastRight",
		Projectile = { Shape = "Orb", Color = SHADOW, Size = 0.8, Speed = Basics.ShadowBolt.Speed :: number },
		Sound = sound("ShadowBolt", 0.5, 0.06),
	},
	Corruption = {
		Pose = "CastRight",
		Speed = 0.8,
		Effects = {
			{ Kind = "Burst", Color = SHADOW, Delay = 0.3, Duration = 0.4, Size = 5, AtTarget = true },
			{
				Kind = "Aura",
				Color = SHADOW,
				Delay = 0.3,
				Duration = (Actives.Corruption.Dot :: Abilities.DotDef).Ticks
					* (Actives.Corruption.Dot :: Abilities.DotDef).Interval,
				AtTarget = true,
			},
		},
		Sound = sound("Corruption", 0.55, 0.04),
	},
	DrainLife = {
		Pose = "CastChannel",
		Effects = {
			{
				Kind = "Beam",
				Color = SHADOW,
				EndColor = FEL,
				Delay = 0.15,
				Duration = (Actives.DrainLife.Dot :: Abilities.DotDef).Ticks * (
					Actives.DrainLife.Dot :: Abilities.DotDef
				).Interval + 0.2,
				From = "RightHand",
				AtTarget = true,
			},
			{ Kind = "Aura", Color = FEL, Delay = 0.3, Duration = 2 },
		},
		Sound = sound("DrainLife", 0.55),
	},
	ShadowBlast = {
		Pose = "CastOverhead",
		Effects = {
			{
				Kind = "Ring",
				Color = SHADOW,
				Duration = 0.6,
				Size = (Actives.ShadowBlast.Radius :: number) * 2,
				AtTarget = true,
				Ground = true,
			},
			{
				Kind = "Burst",
				Color = SHADOW,
				Delay = Actives.ShadowBlast.Delay,
				Duration = 0.45,
				Size = (Actives.ShadowBlast.Radius :: number) * 2,
				AtTarget = true,
			},
		},
		Sound = sound(
			"ShadowBlast",
			0.7,
			0.04,
			{ Delay = (Actives.ShadowBlast.Delay :: number) - 0.05, AtTarget = true }
		),
	},

	-- Esquivar (todas las clases)
	Dodge = {
		Pose = "Dodge",
		Effects = {
			{ Kind = "Trail", Color = Color3.fromRGB(140, 210, 255), Duration = 0.25 },
		},
		Sound = sound("Dodge", 0.45, 0.05),
	},

	-- Impactos sobre el objetivo (llegan con el daño del servidor). Ver Impacts.
	Impact = {
		Effects = { { Kind = "Spark", Color = Color3.new(1, 1, 1), Size = 1 } },
		Sound = sound("Impact", 0.5, 0.08),
	},
	ImpactCrit = {
		Effects = { { Kind = "Spark", Color = Color3.fromRGB(255, 200, 60), Size = 1.7 } },
		Sound = sound("ImpactCrit", 0.7, 0.05),
	},
	-- La maza suena más grave que la espada.
	ImpactHoly = {
		Effects = { { Kind = "Spark", Color = HOLY, Size = 1.1 } },
		Sound = sound("Impact", 0.45, 0.06, { Pitch = 0.82 }),
	},
	ImpactHolyCrit = {
		Effects = { { Kind = "Spark", Color = HOLY, Size = 1.8 } },
		Sound = sound("ImpactCrit", 0.6, 0.05, { Pitch = 0.88 }),
	},
	ImpactArrow = {
		Effects = { { Kind = "Spark", Color = STEEL, Size = 0.7 } },
		Sound = sound("Impact", 0.35, 0.08, { Pitch = 1.25 }),
	},
	ImpactArrowCrit = {
		Effects = { { Kind = "Spark", Color = Color3.fromRGB(255, 200, 60), Size = 1.4 } },
		Sound = sound("ImpactCrit", 0.5, 0.05, { Pitch = 1.15 }),
	},
	-- Los hechizos ya suenan al lanzarse: su impacto es solo visual.
	ImpactArcane = { Effects = { { Kind = "Spark", Color = ARCANE, Size = 0.9 } } },
	ImpactArcaneCrit = { Effects = { { Kind = "Spark", Color = ARCANE, Size = 1.8 } } },
	ImpactFire = { Effects = { { Kind = "Spark", Color = FIRE, Size = 1 } } },
	ImpactFireCrit = { Effects = { { Kind = "Spark", Color = FIRE, Size = 1.9 } } },
	ImpactShadow = { Effects = { { Kind = "Spark", Color = SHADOW, Size = 0.9 } } },
	ImpactShadowCrit = { Effects = { { Kind = "Spark", Color = SHADOW, Size = 1.8 } } },
	-- Pulsos de daño en el tiempo: chispa chica, sin sonido.
	ImpactTick = { Effects = { { Kind = "Spark", Color = Color3.new(1, 1, 1), Size = 0.45 } } },
}

-- Qué señal se ve cuando un golpe acierta, según el tipo de impacto de la habilidad.
export type ImpactSet = { Hit: string, Crit: string }

local Impacts: { [string]: ImpactSet } = {
	Melee = { Hit = "Impact", Crit = "ImpactCrit" },
	Holy = { Hit = "ImpactHoly", Crit = "ImpactHolyCrit" },
	Arrow = { Hit = "ImpactArrow", Crit = "ImpactArrowCrit" },
	Arcane = { Hit = "ImpactArcane", Crit = "ImpactArcaneCrit" },
	Fire = { Hit = "ImpactFire", Crit = "ImpactFireCrit" },
	Shadow = { Hit = "ImpactShadow", Crit = "ImpactShadowCrit" },
}

-- Sacudida de cámara cuando un golpe propio acierta. Magnitude en grados.
export type ShakeDef = { Magnitude: number, Duration: number }

local Shakes: { [string]: ShakeDef } = {
	Hit = { Magnitude = 0.35, Duration = 0.12 },
	Crit = { Magnitude = 0.9, Duration = 0.2 },
}

-- Arma provisoria de cada clase, hecha con piezas pegadas a las manos.
-- `Offset` es respecto a la empuñadura: -Z es hacia adelante con el brazo
-- colgando, +Y hacia el hombro. Se reemplaza por el modelo final del arma.
export type WeaponPart = {
	Hand: "RightHand" | "LeftHand",
	Size: Vector3,
	Offset: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
}

local WOOD = Color3.fromRGB(110, 75, 40)
local IRON = Color3.fromRGB(200, 205, 215)
local Weapons: { [string]: { WeaponPart } } = {
	Warrior = {
		{
			Hand = "RightHand",
			Size = Vector3.new(0.9, 0.25, 0.25),
			Offset = CFrame.new(),
			Color = WOOD,
			Material = Enum.Material.Wood,
		},
		{
			Hand = "RightHand",
			Size = Vector3.new(0.2, 0.45, 3.6),
			Offset = CFrame.new(0, 0, -1.925),
			Color = IRON,
			Material = Enum.Material.Metal,
		},
	},
	-- Maza y escudo.
	Paladin = {
		{
			Hand = "RightHand",
			Size = Vector3.new(0.25, 0.25, 2.6),
			Offset = CFrame.new(0, 0, -0.9),
			Color = WOOD,
			Material = Enum.Material.Wood,
		},
		{
			Hand = "RightHand",
			Size = Vector3.new(0.8, 0.8, 0.9),
			Offset = CFrame.new(0, 0, -2.4),
			Color = IRON,
			Material = Enum.Material.Metal,
		},
		{
			Hand = "RightHand",
			Size = Vector3.new(0.9, 0.9, 0.2),
			Offset = CFrame.new(0, 0, -2.4),
			Color = HOLY,
			Material = Enum.Material.Neon,
		},
		{
			Hand = "LeftHand",
			Size = Vector3.new(0.25, 2.6, 2.1),
			Offset = CFrame.new(-0.35, 0.6, 0),
			Color = Color3.fromRGB(70, 90, 160),
			Material = Enum.Material.Metal,
		},
		{
			Hand = "LeftHand",
			Size = Vector3.new(0.27, 0.9, 0.9),
			Offset = CFrame.new(-0.36, 0.6, 0),
			Color = HOLY,
			Material = Enum.Material.Neon,
		},
	},
	-- Arco en la izquierda, curvado hacia adelante (se arma en WeaponService).
	Ranger = {},
	-- Bastón con orbe violeta.
	Mage = {
		{
			Hand = "RightHand",
			Size = Vector3.new(0.22, 6, 0.22),
			Offset = CFrame.new(0, 1.3, 0),
			Color = Color3.fromRGB(80, 55, 40),
			Material = Enum.Material.Wood,
		},
		{
			Hand = "RightHand",
			Size = Vector3.one * 0.7,
			Offset = CFrame.new(0, 4.5, 0),
			Color = ARCANE,
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Ball,
		},
	},
	-- Bastón claro con orbe de luz.
	Priest = {
		{
			Hand = "RightHand",
			Size = Vector3.new(0.22, 6, 0.22),
			Offset = CFrame.new(0, 1.3, 0),
			Color = Color3.fromRGB(235, 225, 200),
			Material = Enum.Material.Wood,
		},
		{
			Hand = "RightHand",
			Size = Vector3.new(0.9, 0.15, 0.15),
			Offset = CFrame.new(0, 4.1, 0),
			Color = HOLY,
			Material = Enum.Material.Metal,
		},
		{
			Hand = "RightHand",
			Size = Vector3.one * 0.65,
			Offset = CFrame.new(0, 4.55, 0),
			Color = LIGHT,
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Ball,
		},
	},
	-- Varita y grimorio.
	Warlock = {
		{
			Hand = "RightHand",
			Size = Vector3.new(0.15, 0.15, 1.6),
			Offset = CFrame.new(0, 0, -0.6),
			Color = Color3.fromRGB(40, 30, 45),
			Material = Enum.Material.Wood,
		},
		{
			Hand = "RightHand",
			Size = Vector3.one * 0.35,
			Offset = CFrame.new(0, 0, -1.45),
			Color = SHADOW,
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Ball,
		},
		{
			Hand = "LeftHand",
			Size = Vector3.new(0.45, 1.3, 1),
			Offset = CFrame.new(-0.3, 0, -0.2),
			Color = Color3.fromRGB(70, 20, 60),
			Material = Enum.Material.Fabric,
		},
		{
			Hand = "LeftHand",
			Size = Vector3.new(0.47, 0.35, 0.35),
			Offset = CFrame.new(-0.3, 0, -0.2),
			Color = FEL,
			Material = Enum.Material.Neon,
		},
	},
}

-- Arco del Ranger: segmentos en curva más la cuerda.
do
	local bow: { WeaponPart } = {}
	local radius = 2.4
	local segments = 7
	local half = math.rad(55)
	for i = 0, segments - 1 do
		local a0 = -half + (2 * half) * i / segments
		local a1 = -half + (2 * half) * (i + 1) / segments
		local p0 = Vector3.new(0, radius * math.sin(a0), radius * (1 - math.cos(a0)))
		local p1 = Vector3.new(0, radius * math.sin(a1), radius * (1 - math.cos(a1)))
		local mid = (p0 + p1) / 2
		table.insert(bow, {
			Hand = "LeftHand",
			Size = Vector3.new(0.18, (p1 - p0).Magnitude + 0.05, 0.22),
			Offset = CFrame.lookAt(mid, mid + Vector3.xAxis, p1 - p0), -- el eje Y de la pieza sigue la curva
			Color = WOOD,
			Material = Enum.Material.Wood,
		})
	end
	local tip = radius * (1 - math.cos(half))
	local reach = radius * math.sin(half)
	table.insert(bow, {
		Hand = "LeftHand",
		Size = Vector3.new(0.04, reach * 2, 0.04),
		Offset = CFrame.new(0, 0, tip),
		Color = Color3.fromRGB(235, 235, 225),
	})
	Weapons.Ranger = bow
end

for _, cue in Cues do
	if cue.Effects then
		for _, effect in cue.Effects do
			table.freeze(effect)
		end
		table.freeze(cue.Effects)
	end
	table.freeze(cue)
end

return table.freeze({
	Cues = table.freeze(Cues),
	Impacts = table.freeze(Impacts),
	ImpactTickCue = "ImpactTick",
	Shakes = table.freeze(Shakes),
	SoundGroups = table.freeze(SOUND_GROUPS),
	Weapons = table.freeze(Weapons),
})
