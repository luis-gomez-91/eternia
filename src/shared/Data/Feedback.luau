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

export type SoundDef = {
	Id: string,
	Volume: number?,
	Pitch: number?,
	PitchJitter: number?, -- variación al azar de tono (0,05 = ±5%) para que no suene repetido
	Group: SoundGroupName?, -- grupo de volumen (por defecto "SFX")
}

-- Grupos de volumen; cada uno tendrá su control en el menú de opciones.
export type SoundGroupName = "SFX" | "Music" | "Ambience" | "Voice"
local SOUND_GROUPS: { SoundGroupName } = { "SFX", "Music", "Ambience", "Voice" }

-- Slash: arco frente al personaje. Ring: onda que se expande en el suelo.
-- Trail: estela que sigue al personaje. Aura: brillo sobre el personaje.
-- Spark: chispa en el punto de impacto.
export type EffectKind = "Slash" | "Ring" | "Trail" | "Aura" | "Spark"

export type EffectDef = {
	Kind: EffectKind,
	Color: Color3,
	Delay: number?, -- segundos desde que empieza la señal
	Duration: number?,
	Size: number?, -- Slash: radio · Ring: diámetro final · Spark: escala
	Span: number?, -- Slash: grados que cubre el arco
	Roll: number?, -- Slash: inclinación del arco en grados (0 horizontal, 90 vertical)
	Sweep: number?, -- Slash: 1 de derecha a izquierda, -1 al revés
	Height: number?, -- Slash/Ring: altura respecto al centro del personaje
}

export type Cue = {
	Animation: string?, -- arte final: ID de animación; si está, no se usa Pose
	Pose: string?, -- provisorio: pose de Data/Poses
	Speed: number?, -- velocidad de la animación o pose (1 = normal)
	Effects: { EffectDef }?,
	Sound: SoundDef?,
}

local GOLD = Color3.fromRGB(255, 205, 90)
local STEEL = Color3.fromRGB(225, 235, 255)
local EMBER = Color3.fromRGB(255, 140, 60)

local Cues: { [string]: Cue } = {
	-- Combo básico del Warrior: dos tajos cruzados y un golpe de arriba hacia abajo.
	WarriorCombo1 = {
		Pose = "WarriorSlashRight",
		Effects = {
			{ Kind = "Slash", Color = STEEL, Delay = 0.1, Size = 6, Span = 140, Roll = -15, Sweep = 1 },
		},
		Sound = { Id = "rbxassetid://111424923198216", Volume = 0.5, PitchJitter = 0.05 },
	},
	WarriorCombo2 = {
		Pose = "WarriorSlashLeft",
		Effects = {
			{ Kind = "Slash", Color = STEEL, Delay = 0.1, Size = 6, Span = 140, Roll = 15, Sweep = -1 },
		},
		Sound = { Id = "rbxassetid://124397046727052", Volume = 0.5, PitchJitter = 0.05 },
	},
	WarriorCombo3 = {
		Pose = "WarriorOverhead",
		Effects = {
			{ Kind = "Slash", Color = GOLD, Delay = 0.22, Size = 5, Span = 110, Roll = 90, Sweep = 1, Height = 1.2 },
			{ Kind = "Ring", Color = GOLD, Delay = 0.3, Duration = 0.35, Size = 9, Height = -2.8 },
		},
		Sound = { Id = "rbxassetid://103438577618554", Volume = 0.65, PitchJitter = 0.04 },
	},

	-- Activas del Warrior
	Cleave = {
		Pose = "WarriorCleave",
		Effects = {
			{ Kind = "Slash", Color = EMBER, Delay = 0.14, Size = 8.5, Span = 200, Roll = 0, Sweep = 1 },
		},
		Sound = { Id = "rbxassetid://105049720867727", Volume = 0.7, PitchJitter = 0.04 },
	},
	BattleShout = {
		Pose = "WarriorShout",
		Effects = {
			{ Kind = "Ring", Color = GOLD, Delay = 0.15, Duration = 0.5, Size = 22, Height = -2.8 },
			{ Kind = "Ring", Color = GOLD, Delay = 0.3, Duration = 0.5, Size = 14, Height = -2.8 },
			{ Kind = "Aura", Color = GOLD, Delay = 0.15, Duration = Abilities.Actives.BattleShout.Duration },
		},
		Sound = { Id = "rbxassetid://104391889530290", Volume = 0.7 },
	},
	Charge = {
		Pose = "WarriorCharge",
		Effects = {
			{ Kind = "Trail", Color = EMBER, Duration = 0.4 },
		},
		Sound = { Id = "rbxassetid://77904768404795", Volume = 0.6 },
	},

	-- Esquivar (todas las clases)
	Dodge = {
		Pose = "Dodge",
		Effects = {
			{ Kind = "Trail", Color = Color3.fromRGB(140, 210, 255), Duration = 0.25 },
		},
		Sound = { Id = "rbxassetid://83476574026443", Volume = 0.45, PitchJitter = 0.05 },
	},

	-- Impactos sobre el objetivo (llegan con el daño del servidor)
	Impact = {
		Effects = { { Kind = "Spark", Color = Color3.new(1, 1, 1), Size = 1 } },
		Sound = { Id = "rbxassetid://88644710053967", Volume = 0.5, PitchJitter = 0.08 },
	},
	ImpactCrit = {
		Effects = { { Kind = "Spark", Color = Color3.fromRGB(255, 200, 60), Size = 1.7 } },
		Sound = { Id = "rbxassetid://125109039614338", Volume = 0.7, PitchJitter = 0.05 },
	},
}

-- Sacudida de cámara cuando un golpe propio acierta. Magnitude en grados.
export type ShakeDef = { Magnitude: number, Duration: number }

local Shakes: { [string]: ShakeDef } = {
	Hit = { Magnitude = 0.35, Duration = 0.12 },
	Crit = { Magnitude = 0.9, Duration = 0.2 },
}

-- Arma provisoria que se ve en la mano de cada clase (un bloque con forma de espada).
export type WeaponDef = {
	BladeSize: Vector3,
	HiltSize: Vector3,
	BladeColor: Color3,
	HiltColor: Color3,
}

local Weapons: { [string]: WeaponDef } = {
	Warrior = {
		BladeSize = Vector3.new(0.2, 0.45, 3.6),
		HiltSize = Vector3.new(0.9, 0.25, 0.25),
		BladeColor = Color3.fromRGB(200, 205, 215),
		HiltColor = Color3.fromRGB(110, 75, 40),
	},
}

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
	ImpactCue = "Impact",
	ImpactCritCue = "ImpactCrit",
	Shakes = table.freeze(Shakes),
	SoundGroups = table.freeze(SOUND_GROUPS),
	Weapons = table.freeze(Weapons),
})
