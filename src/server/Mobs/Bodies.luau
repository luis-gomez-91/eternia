--!strict
-- Cuerpos provisorios de mobs (caja gris): piezas simples pegadas a una raíz con
-- Humanoid, para que caminen con MoveTo y choquen con el escenario.
-- Se cambian por los modelos finales en la fase de arte.

export type Body = {
	model: Model,
	root: BasePart,
	humanoid: Humanoid,
}

type PartDef = {
	Name: string,
	Size: Vector3,
	At: CFrame, -- posición respecto al suelo bajo la raíz, mirando a -Z
	Color: Color3,
	Shape: Enum.PartType?,
	Material: Enum.Material?,
}

type BodyDef = {
	RootSize: Vector3,
	HipHeight: number, -- distancia del suelo a la base de la raíz
	Parts: { PartDef },
}

local function p(
	name: string,
	size: Vector3,
	at: CFrame,
	color: Color3,
	shape: Enum.PartType?,
	material: Enum.Material?
): PartDef
	return { Name = name, Size = size, At = at, Color = color, Shape = shape, Material = material }
end

local BALL = Enum.PartType.Ball
local NEON = Enum.Material.Neon

local GOBLIN = Color3.fromRGB(95, 140, 60)
local LEATHER = Color3.fromRGB(100, 70, 45)
local WOOD = Color3.fromRGB(110, 75, 40)
local SPIDER = Color3.fromRGB(55, 40, 70)
local VENOM = Color3.fromRGB(200, 240, 40)
local EYE = Color3.fromRGB(255, 60, 50)
local WOLF = Color3.fromRGB(125, 125, 130)
local WOLF_DARK = Color3.fromRGB(80, 80, 88)
local OGRE = Color3.fromRGB(150, 120, 85)
local OGRE_CLOTH = Color3.fromRGB(90, 60, 50)

local function spiderLegs(): { PartDef }
	local legs = {}
	for side = -1, 1, 2 do
		for i = 0, 3 do
			local z = -1.1 + i * 0.75
			local spread = math.rad(-35 + i * 23)
			local at = CFrame.new(side * 2.1, 1.1, z) * CFrame.Angles(0, side * spread, side * math.rad(-35))
			table.insert(legs, p("Leg", Vector3.new(2.8, 0.25, 0.25), at, SPIDER))
		end
	end
	return legs
end

local function concat(...: { PartDef }): { PartDef }
	local result = {}
	for _, list in { ... } do
		table.move(list, 1, #list, #result + 1, result)
	end
	return result
end

local Defs: { [string]: BodyDef } = {
	Goblin = {
		RootSize = Vector3.new(2, 2, 1),
		HipHeight = 1.2,
		Parts = {
			p("LeftLeg", Vector3.new(0.6, 1.3, 0.6), CFrame.new(-0.45, 0.65, 0), LEATHER),
			p("RightLeg", Vector3.new(0.6, 1.3, 0.6), CFrame.new(0.45, 0.65, 0), LEATHER),
			p("Torso", Vector3.new(1.8, 1.6, 1.1), CFrame.new(0, 2.1, 0), GOBLIN),
			p("Head", Vector3.new(1.4, 1.2, 1.2), CFrame.new(0, 3.5, -0.1), GOBLIN),
			p("LeftEar", Vector3.new(0.8, 0.25, 0.3), CFrame.new(-0.95, 3.7, 0) * CFrame.Angles(0, 0, 0.4), GOBLIN),
			p("RightEar", Vector3.new(0.8, 0.25, 0.3), CFrame.new(0.95, 3.7, 0) * CFrame.Angles(0, 0, -0.4), GOBLIN),
			p("LeftEye", Vector3.new(0.25, 0.2, 0.1), CFrame.new(-0.3, 3.6, -0.72), EYE, nil, NEON),
			p("RightEye", Vector3.new(0.25, 0.2, 0.1), CFrame.new(0.3, 3.6, -0.72), EYE, nil, NEON),
			p("LeftArm", Vector3.new(0.5, 1.4, 0.5), CFrame.new(-1.15, 2.1, 0), GOBLIN),
			p("RightArm", Vector3.new(0.5, 1.4, 0.5), CFrame.new(1.15, 2.1, -0.2), GOBLIN),
			p(
				"Club",
				Vector3.new(0.45, 2.4, 0.45),
				CFrame.new(1.2, 2.6, -1) * CFrame.Angles(math.rad(-50), 0, 0),
				WOOD
			),
		},
	},
	Spider = {
		RootSize = Vector3.new(3, 1.4, 3),
		HipHeight = 0.6,
		Parts = concat({
			p("Body", Vector3.new(2.6, 1.8, 2.6), CFrame.new(0, 1.5, -0.2), SPIDER, BALL),
			p("Abdomen", Vector3.new(3, 2.4, 3.2), CFrame.new(0, 1.9, 2), SPIDER, BALL),
			p("Mark", Vector3.new(1, 0.2, 1.2), CFrame.new(0, 3.1, 2), VENOM, nil, NEON),
			p("Head", Vector3.new(1.5, 1.2, 1.3), CFrame.new(0, 1.5, -1.7), SPIDER, BALL),
			p("LeftEye", Vector3.new(0.3, 0.3, 0.3), CFrame.new(-0.35, 1.8, -2.3), EYE, BALL, NEON),
			p("RightEye", Vector3.new(0.3, 0.3, 0.3), CFrame.new(0.35, 1.8, -2.3), EYE, BALL, NEON),
			p("Fangs", Vector3.new(0.8, 0.5, 0.3), CFrame.new(0, 1.1, -2.35), VENOM, nil, NEON),
		}, spiderLegs()),
	},
	Wolf = {
		RootSize = Vector3.new(2, 2, 3),
		HipHeight = 1.2,
		Parts = {
			p("Body", Vector3.new(2, 1.8, 4), CFrame.new(0, 2.4, 0.2), WOLF),
			p("Head", Vector3.new(1.5, 1.4, 1.6), CFrame.new(0, 3.1, -2.4), WOLF),
			p("Snout", Vector3.new(0.9, 0.7, 1.1), CFrame.new(0, 2.8, -3.6), WOLF_DARK),
			p("LeftEar", Vector3.new(0.4, 0.6, 0.3), CFrame.new(-0.45, 4, -2.3), WOLF_DARK),
			p("RightEar", Vector3.new(0.4, 0.6, 0.3), CFrame.new(0.45, 4, -2.3), WOLF_DARK),
			p(
				"LeftEye",
				Vector3.new(0.25, 0.2, 0.1),
				CFrame.new(-0.4, 3.3, -3.22),
				Color3.fromRGB(255, 200, 60),
				nil,
				NEON
			),
			p(
				"RightEye",
				Vector3.new(0.25, 0.2, 0.1),
				CFrame.new(0.4, 3.3, -3.22),
				Color3.fromRGB(255, 200, 60),
				nil,
				NEON
			),
			p("FrontLeftLeg", Vector3.new(0.5, 1.6, 0.5), CFrame.new(-0.6, 0.8, -1.4), WOLF_DARK),
			p("FrontRightLeg", Vector3.new(0.5, 1.6, 0.5), CFrame.new(0.6, 0.8, -1.4), WOLF_DARK),
			p("BackLeftLeg", Vector3.new(0.5, 1.6, 0.5), CFrame.new(-0.6, 0.8, 1.6), WOLF_DARK),
			p("BackRightLeg", Vector3.new(0.5, 1.6, 0.5), CFrame.new(0.6, 0.8, 1.6), WOLF_DARK),
			p(
				"Tail",
				Vector3.new(0.4, 0.4, 1.8),
				CFrame.new(0, 2.9, 2.9) * CFrame.Angles(math.rad(25), 0, 0),
				WOLF_DARK
			),
		},
	},
	Ogre = {
		RootSize = Vector3.new(4, 4, 3),
		HipHeight = 2.6,
		Parts = {
			p("LeftLeg", Vector3.new(1.6, 3, 1.6), CFrame.new(-1.2, 1.5, 0), OGRE_CLOTH),
			p("RightLeg", Vector3.new(1.6, 3, 1.6), CFrame.new(1.2, 1.5, 0), OGRE_CLOTH),
			p("Belly", Vector3.new(5, 4.6, 3.6), CFrame.new(0, 5.2, 0), OGRE),
			p("Belt", Vector3.new(5.1, 0.8, 3.7), CFrame.new(0, 3.4, 0), OGRE_CLOTH),
			p("Head", Vector3.new(2.6, 2.4, 2.4), CFrame.new(0, 8.6, -0.3), OGRE),
			p("Jaw", Vector3.new(2.2, 0.8, 0.6), CFrame.new(0, 7.8, -1.5), OGRE),
			p("LeftTusk", Vector3.new(0.3, 0.7, 0.3), CFrame.new(-0.6, 8.3, -1.7), Color3.fromRGB(240, 235, 210)),
			p("RightTusk", Vector3.new(0.3, 0.7, 0.3), CFrame.new(0.6, 8.3, -1.7), Color3.fromRGB(240, 235, 210)),
			p("LeftEye", Vector3.new(0.4, 0.3, 0.1), CFrame.new(-0.6, 9, -1.52), EYE, nil, NEON),
			p("RightEye", Vector3.new(0.4, 0.3, 0.1), CFrame.new(0.6, 9, -1.52), EYE, nil, NEON),
			p("LeftArm", Vector3.new(1.4, 4.4, 1.4), CFrame.new(-3.3, 5.2, 0), OGRE),
			p("RightArm", Vector3.new(1.4, 4.4, 1.4), CFrame.new(3.3, 5.2, -0.4), OGRE),
			p("Club", Vector3.new(1.2, 6, 1.2), CFrame.new(3.4, 6, -2.4) * CFrame.Angles(math.rad(-55), 0, 0), WOOD),
		},
	},
}

local Bodies = {}

-- Arma el cuerpo parado en `ground` (punto del suelo, mirando a su -Z).
function Bodies.Build(bodyId: string, ground: CFrame): Body
	local def = Defs[bodyId]
	assert(def, `Cuerpo desconocido: {bodyId}`)

	local model = Instance.new("Model")
	local rootHeight = def.HipHeight + def.RootSize.Y / 2

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = def.RootSize
	root.CFrame = ground * CFrame.new(0, rootHeight, 0)
	root.Transparency = 1
	root.CanCollide = true
	root.TopSurface = Enum.SurfaceType.Smooth
	root.BottomSurface = Enum.SurfaceType.Smooth
	root.Parent = model

	for _, partDef in def.Parts do
		local part = Instance.new("Part")
		part.Name = partDef.Name
		part.Size = partDef.Size
		part.Shape = partDef.Shape or Enum.PartType.Block
		part.Material = partDef.Material or Enum.Material.SmoothPlastic
		part.Color = partDef.Color
		part.CFrame = ground * partDef.At
		part.CanCollide = false
		part.CanTouch = false
		part.Massless = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
		part.Parent = model
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = def.HipHeight
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	-- La vida real está en atributos; el Humanoid solo camina.
	for _, state in
		{
			Enum.HumanoidStateType.Dead,
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.Climbing,
			Enum.HumanoidStateType.Swimming,
			Enum.HumanoidStateType.Seated,
		}
	do
		humanoid:SetStateEnabled(state, false)
	end
	humanoid.Parent = model

	model.PrimaryPart = root
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	return { model = model, root = root, humanoid = humanoid }
end

return Bodies
