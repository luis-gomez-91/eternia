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
