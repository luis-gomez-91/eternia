--!strict
-- Poses provisorias: animaciones hechas en código sobre las articulaciones R15.
-- Se suman encima de la animación normal (caminar, quieto), así no la cortan.
-- Se reemplazan por animaciones reales poniendo `Animation` en la señal (Data/Feedback).
--
-- Cada clave dice, en un momento, cuánto gira cada articulación en grados {X, Y, Z}.
-- Entre claves se interpola suave; antes de la primera y después de la última
-- se vuelve a 0. Ejes en el espacio de la articulación:
--   X: hombros y codos hacia adelante y arriba; cintura y cuello hacia atrás.
--   Y: cintura y cuello giran a la izquierda.
--   Z: brazo derecho hacia afuera (el izquierdo hacia afuera con Z negativo).

export type Angles = { number } -- {X, Y, Z} en grados

export type Key = {
	Time: number,
	Joints: { [string]: Angles },
}

export type PoseDef = {
	Duration: number,
	Keys: { Key },
}

local Poses: { [string]: PoseDef } = {
	-- Tajo de derecha a izquierda
	WarriorSlashRight = {
		Duration = 0.42,
		Keys = {
			{
				Time = 0.08,
				Joints = {
					Waist = { 0, -40, 0 },
					RightShoulder = { 75, 0, 55 },
					RightElbow = { 35, 0, 0 },
				},
			},
			{
				Time = 0.2,
				Joints = {
					Waist = { 0, 40, 0 },
					RightShoulder = { 85, 0, -35 },
					RightElbow = { 5, 0, 0 },
				},
			},
			{
				Time = 0.28,
				Joints = {
					Waist = { 0, 35, 0 },
					RightShoulder = { 80, 0, -30 },
					RightElbow = { 10, 0, 0 },
				},
			},
		},
	},

	-- Revés de izquierda a derecha
	WarriorSlashLeft = {
		Duration = 0.42,
		Keys = {
			{
				Time = 0.08,
				Joints = {
					Waist = { 0, 35, 0 },
					RightShoulder = { 80, 0, -40 },
					RightElbow = { 45, 0, 0 },
				},
			},
			{
				Time = 0.2,
				Joints = {
					Waist = { 0, -40, 0 },
					RightShoulder = { 75, 0, 60 },
					RightElbow = { 5, 0, 0 },
				},
			},
			{
				Time = 0.28,
				Joints = {
					Waist = { 0, -35, 0 },
					RightShoulder = { 70, 0, 55 },
					RightElbow = { 10, 0, 0 },
				},
			},
		},
	},

	-- Golpe de arriba hacia abajo con las dos manos (cierre del combo)
	WarriorOverhead = {
		Duration = 0.7,
		Keys = {
			{
				Time = 0.18,
				Joints = {
					Waist = { 12, 0, 0 },
					RightShoulder = { 165, 0, 10 },
					LeftShoulder = { 155, 0, -15 },
					RightElbow = { 30, 0, 0 },
					LeftElbow = { 30, 0, 0 },
				},
			},
			{
				Time = 0.3,
				Joints = {
					Waist = { -28, 0, 0 },
					RightShoulder = { 45, 0, -5 },
					LeftShoulder = { 50, 0, 20 },
					RightElbow = { 5, 0, 0 },
					LeftElbow = { 5, 0, 0 },
				},
			},
			{
				Time = 0.48,
				Joints = {
					Waist = { -22, 0, 0 },
					RightShoulder = { 40, 0, -5 },
					LeftShoulder = { 45, 0, 20 },
				},
			},
		},
	},

	-- Tajo: giro amplio de 180°
	WarriorCleave = {
		Duration = 0.55,
		Keys = {
			{
				Time = 0.1,
				Joints = {
					Waist = { 0, -70, 0 },
					RightShoulder = { 70, 0, 75 },
					RightElbow = { 20, 0, 0 },
					LeftShoulder = { 30, 0, -20 },
				},
			},
			{
				Time = 0.26,
				Joints = {
					Waist = { 0, 75, 0 },
					RightShoulder = { 85, 0, -45 },
					RightElbow = { 0, 0, 0 },
					LeftShoulder = { 20, 0, -40 },
				},
			},
			{
				Time = 0.36,
				Joints = {
					Waist = { 0, 65, 0 },
					RightShoulder = { 80, 0, -40 },
				},
			},
		},
	},

	-- Grito de batalla: brazos arriba, pecho afuera, cabeza atrás
	WarriorShout = {
		Duration = 0.9,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { 14, 0, 0 },
					Neck = { 22, 0, 0 },
					RightShoulder = { 140, 0, 45 },
					LeftShoulder = { 140, 0, -45 },
					RightElbow = { 25, 0, 0 },
					LeftElbow = { 25, 0, 0 },
				},
			},
			{
				Time = 0.6,
				Joints = {
					Waist = { 12, 0, 0 },
					Neck = { 18, 0, 0 },
					RightShoulder = { 135, 0, 50 },
					LeftShoulder = { 135, 0, -50 },
					RightElbow = { 30, 0, 0 },
					LeftElbow = { 30, 0, 0 },
				},
			},
		},
	},

	-- Embestida: cuerpo adelante, espada atrás, golpe al llegar
	WarriorCharge = {
		Duration = 0.65,
		Keys = {
			{
				Time = 0.08,
				Joints = {
					Waist = { -30, 0, 0 },
					RightShoulder = { -35, 0, 25 },
					LeftShoulder = { 45, 0, -10 },
				},
			},
			{
				Time = 0.32,
				Joints = {
					Waist = { -30, 0, 0 },
					RightShoulder = { -35, 0, 25 },
					LeftShoulder = { 45, 0, -10 },
				},
			},
			{
				Time = 0.42,
				Joints = {
					Waist = { -20, 25, 0 },
					RightShoulder = { 95, 0, -20 },
					LeftShoulder = { 20, 0, -20 },
				},
			},
		},
	},

	-- Esquivar: agachado hacia adelante, brazos atrás
	Dodge = {
		Duration = 0.32,
		Keys = {
			{
				Time = 0.06,
				Joints = {
					Waist = { -25, 0, 0 },
					RightShoulder = { -30, 0, 15 },
					LeftShoulder = { -30, 0, -15 },
				},
			},
			{
				Time = 0.2,
				Joints = {
					Waist = { -20, 0, 0 },
					RightShoulder = { -25, 0, 15 },
					LeftShoulder = { -25, 0, -15 },
				},
			},
		},
	},

	-- Paladín: maza en diagonal, de arriba a la derecha hacia abajo a la izquierda
	PaladinSwing = {
		Duration = 0.5,
		Keys = {
			{
				Time = 0.1,
				Joints = {
					Waist = { 0, -40, 0 },
					RightShoulder = { 135, 0, 55 },
					RightElbow = { 40, 0, 0 },
				},
			},
			{
				Time = 0.24,
				Joints = {
					Waist = { -10, 35, 0 },
					RightShoulder = { 65, 0, -30 },
					RightElbow = { 5, 0, 0 },
				},
			},
			{
				Time = 0.34,
				Joints = {
					Waist = { -8, 30, 0 },
					RightShoulder = { 60, 0, -25 },
					RightElbow = { 10, 0, 0 },
				},
			},
		},
	},

	-- Consagración: maza arriba con las dos manos y golpe al suelo
	PaladinSlam = {
		Duration = 0.85,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { 12, 0, 0 },
					RightShoulder = { 165, 0, 10 },
					LeftShoulder = { 160, 0, -10 },
					RightElbow = { 30, 0, 0 },
					LeftElbow = { 30, 0, 0 },
				},
			},
			{
				Time = 0.3,
				Joints = {
					Waist = { -38, 0, 0 },
					RightShoulder = { 30, 0, -5 },
					LeftShoulder = { 35, 0, 15 },
				},
			},
			{
				Time = 0.6,
				Joints = {
					Waist = { -32, 0, 0 },
					RightShoulder = { 28, 0, -5 },
					LeftShoulder = { 32, 0, 15 },
				},
			},
		},
	},

	-- Hechizo con la mano derecha al frente (proyectiles y rayos)
	CastRight = {
		Duration = 0.45,
		Keys = {
			{
				Time = 0.06,
				Joints = {
					Waist = { 0, -10, 0 },
					RightShoulder = { 60, 0, 30 },
					RightElbow = { 70, 0, 0 },
				},
			},
			{
				Time = 0.15,
				Joints = {
					Waist = { -5, 18, 0 },
					RightShoulder = { 95, 0, 0 },
					RightElbow = { 0, 0, 0 },
				},
			},
			{
				Time = 0.28,
				Joints = {
					Waist = { -4, 15, 0 },
					RightShoulder = { 90, 0, 0 },
					RightElbow = { 5, 0, 0 },
				},
			},
		},
	},

	-- Empuje con las dos manos (Orbe arcano)
	CastPush = {
		Duration = 0.7,
		Keys = {
			{
				Time = 0.12,
				Joints = {
					Waist = { 8, 0, 0 },
					RightShoulder = { 40, 0, 25 },
					LeftShoulder = { 40, 0, -25 },
					RightElbow = { 90, 0, 0 },
					LeftElbow = { 90, 0, 0 },
				},
			},
			{
				Time = 0.28,
				Joints = {
					Waist = { -12, 0, 0 },
					RightShoulder = { 95, 0, -12 },
					LeftShoulder = { 95, 0, 12 },
					RightElbow = { 0, 0, 0 },
					LeftElbow = { 0, 0, 0 },
				},
			},
			{
				Time = 0.45,
				Joints = {
					Waist = { -10, 0, 0 },
					RightShoulder = { 90, 0, -10 },
					LeftShoulder = { 90, 0, 10 },
				},
			},
		},
	},

	-- Mano derecha arriba y lanzamiento al frente (Bola de fuego, Castigo)
	CastOverhead = {
		Duration = 0.65,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { 8, -12, 0 },
					RightShoulder = { 170, 0, 15 },
					RightElbow = { 40, 0, 0 },
					LeftShoulder = { 40, 0, -15 },
				},
			},
			{
				Time = 0.32,
				Joints = {
					Waist = { -15, 15, 0 },
					RightShoulder = { 85, 0, -5 },
					RightElbow = { 0, 0, 0 },
					LeftShoulder = { 20, 0, -10 },
				},
			},
			{
				Time = 0.45,
				Joints = {
					Waist = { -12, 12, 0 },
					RightShoulder = { 80, 0, -5 },
				},
			},
		},
	},

	-- Brazos arriba y abiertos (curaciones, Nova sagrada)
	CastRaise = {
		Duration = 0.9,
		Keys = {
			{
				Time = 0.2,
				Joints = {
					Waist = { 8, 0, 0 },
					Neck = { 15, 0, 0 },
					RightShoulder = { 150, 0, 35 },
					LeftShoulder = { 150, 0, -35 },
					RightElbow = { 15, 0, 0 },
					LeftElbow = { 15, 0, 0 },
				},
			},
			{
				Time = 0.65,
				Joints = {
					Waist = { 6, 0, 0 },
					Neck = { 12, 0, 0 },
					RightShoulder = { 145, 0, 40 },
					LeftShoulder = { 145, 0, -40 },
					RightElbow = { 20, 0, 0 },
					LeftElbow = { 20, 0, 0 },
				},
			},
		},
	},

	-- Canalizar con las dos manos al frente (Drenar vida)
	CastChannel = {
		Duration = 2.4,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { -8, 0, 0 },
					RightShoulder = { 90, 0, -5 },
					LeftShoulder = { 80, 0, 5 },
					RightElbow = { 10, 0, 0 },
					LeftElbow = { 25, 0, 0 },
				},
			},
			{
				Time = 2.1,
				Joints = {
					Waist = { -10, 0, 0 },
					RightShoulder = { 92, 0, -5 },
					LeftShoulder = { 82, 0, 5 },
					RightElbow = { 10, 0, 0 },
					LeftElbow = { 25, 0, 0 },
				},
			},
		},
	},

	-- Ranger: arco al frente con la izquierda, la derecha tensa la cuerda
	BowShot = {
		Duration = 0.45,
		Keys = {
			{
				Time = 0.07,
				Joints = {
					Waist = { 0, -25, 0 },
					LeftShoulder = { 90, 25, 0 },
					RightShoulder = { 90, 0, -30 },
					RightElbow = { 110, 0, 0 },
				},
			},
			{
				Time = 0.16,
				Joints = {
					Waist = { 0, -25, 0 },
					LeftShoulder = { 90, 25, 0 },
					RightShoulder = { 90, 0, 10 },
					RightElbow = { 40, 0, 0 },
				},
			},
			{
				Time = 0.28,
				Joints = {
					Waist = { 0, -20, 0 },
					LeftShoulder = { 85, 20, 0 },
					RightShoulder = { 70, 0, 15 },
					RightElbow = { 30, 0, 0 },
				},
			},
		},
	},

	-- Disparo potente: la misma postura con la cuerda tensa más tiempo
	BowPower = {
		Duration = 0.8,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { 0, -25, 0 },
					LeftShoulder = { 90, 25, 0 },
					RightShoulder = { 90, 0, -30 },
					RightElbow = { 120, 0, 0 },
				},
			},
			{
				Time = 0.42,
				Joints = {
					Waist = { -4, -28, 0 },
					LeftShoulder = { 92, 25, 0 },
					RightShoulder = { 92, 0, -32 },
					RightElbow = { 125, 0, 0 },
				},
			},
			{
				Time = 0.5,
				Joints = {
					Waist = { 0, -25, 0 },
					LeftShoulder = { 90, 25, 0 },
					RightShoulder = { 90, 0, 15 },
					RightElbow = { 35, 0, 0 },
				},
			},
		},
	},

	-- Lluvia de flechas: apuntar hacia el cielo
	BowSky = {
		Duration = 0.75,
		Keys = {
			{
				Time = 0.15,
				Joints = {
					Waist = { 12, -25, 0 },
					LeftShoulder = { 140, 25, 0 },
					RightShoulder = { 140, 0, -30 },
					RightElbow = { 110, 0, 0 },
				},
			},
			{
				Time = 0.4,
				Joints = {
					Waist = { 14, -25, 0 },
					LeftShoulder = { 142, 25, 0 },
					RightShoulder = { 142, 0, -30 },
					RightElbow = { 115, 0, 0 },
				},
			},
			{
				Time = 0.48,
				Joints = {
					Waist = { 12, -22, 0 },
					LeftShoulder = { 140, 25, 0 },
					RightShoulder = { 140, 0, 15 },
					RightElbow = { 35, 0, 0 },
				},
			},
		},
	},

	-- Retirada: salto hacia atrás, cuerpo echado atrás y brazos al frente
	LeapBack = {
		Duration = 0.45,
		Keys = {
			{
				Time = 0.08,
				Joints = {
					Waist = { 22, 0, 0 },
					RightShoulder = { 60, 0, 30 },
					LeftShoulder = { 60, 0, -30 },
				},
			},
			{
				Time = 0.3,
				Joints = {
					Waist = { 15, 0, 0 },
					RightShoulder = { 50, 0, 30 },
					LeftShoulder = { 50, 0, -30 },
				},
			},
		},
	},
}

for _, pose in Poses do
	for _, key in pose.Keys do
		for _, angles in key.Joints do
			table.freeze(angles)
		end
		table.freeze(key.Joints)
		table.freeze(key)
	end
	table.freeze(pose.Keys)
	table.freeze(pose)
end

return table.freeze(Poses)
