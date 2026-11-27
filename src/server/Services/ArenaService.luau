--!strict
-- Subárea de prueba en caja gris (Fase 0): suelo, paredes, coberturas, los 3
-- campamentos de mobs y la arena del jefe. Se arma en código para que viva en
-- Git; se reemplaza por la zona real (Claro del Molino) en la Fase 3.
--
-- Plano (vista de arriba, -Z es hacia el fondo):
--   z = -8      fogata (punto de aparición) y muñecos de práctica
--   z = -50     entrada a la subárea
--   z = -90     campamento de goblins (izquierda, cajas)
--   z = -125    campamento de arañas (derecha, pilares para cubrirse)
--   z = -170    manada de lobos (izquierda, campo abierto)
--   z = -235    arena del jefe (círculo con entrada al frente)

local ArenaService = {}

export type Spawn = { Mob: string, Position: Vector3 }

local FLOOR_TOP = 0.1
local WALL_HEIGHT = 10

local GREY = Color3.fromRGB(150, 150, 155)
local DARK = Color3.fromRGB(105, 105, 112)
local LIGHT = Color3.fromRGB(185, 185, 190)
local ARENA = Color3.fromRGB(120, 100, 95)

local BOSS_CENTER = Vector3.new(0, 0, -235)
local BOSS_RADIUS = 28

ArenaService.BossCenter = BOSS_CENTER
ArenaService.BossRadius = BOSS_RADIUS

ArenaService.Spawns = {
	-- Goblins
	{ Mob = "GoblinRaider", Position = Vector3.new(-32, 0, -86) },
	{ Mob = "GoblinRaider", Position = Vector3.new(-25, 0, -93) },
	{ Mob = "GoblinRaider", Position = Vector3.new(-35, 0, -96) },
	-- Arañas con un goblin de guardia
	{ Mob = "VenomSpider", Position = Vector3.new(38, 0, -123) },
	{ Mob = "VenomSpider", Position = Vector3.new(31, 0, -131) },
	{ Mob = "GoblinRaider", Position = Vector3.new(34, 0, -116) },
	-- Lobos
	{ Mob = "GreyWolf", Position = Vector3.new(-33, 0, -168) },
	{ Mob = "GreyWolf", Position = Vector3.new(-25, 0, -175) },
	-- Jefe
	{ Mob = "ClearingOgre", Position = BOSS_CENTER },
} :: { Spawn }

local folder: Folder

local function block(name: string, size: Vector3, cframe: CFrame, color: Color3, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = folder
	return part
end

-- Bloque apoyado en el suelo, con su centro horizontal en (x, z).
local function onFloor(name: string, size: Vector3, x: number, z: number, color: Color3, yaw: number?): Part
	local cframe = CFrame.new(x, FLOOR_TOP + size.Y / 2, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	return block(name, size, cframe, color)
end

local function buildCampfire()
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Campfire"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 0.5, -8)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0 -- sin campo de fuerza
	spawn.Color = Color3.fromRGB(90, 70, 55)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.Parent = folder
	for _, decal in spawn:GetChildren() do
		decal:Destroy() -- sin el logo de aparición
	end

	local flame = block("Flame", Vector3.new(1.2, 1.6, 1.2), CFrame.new(3, 1.8, -11), Color3.fromRGB(255, 140, 50))
	flame.Material = Enum.Material.Neon
	flame.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 160, 80)
	light.Range = 14
	light.Parent = flame
	for i = 0, 3 do
		local angle = i * math.pi / 2
		block(
			"Log",
			Vector3.new(0.6, 0.6, 2.2),
			CFrame.new(3, 1.3, -11)
				* CFrame.Angles(0, angle, 0)
				* CFrame.new(0, 0, 0.9)
				* CFrame.Angles(math.rad(25), 0, 0),
			Color3.fromRGB(100, 70, 40)
		).CanCollide =
			false
	end
end

local function buildBounds()
	-- Suelo de la subárea, apenas sobre la base.
	block("Floor", Vector3.new(140, 1, 222), CFrame.new(0, FLOOR_TOP - 0.5, -160), GREY)
	local w = 2
	onFloor("WallWest", Vector3.new(w, WALL_HEIGHT, 222), -71, -160, DARK)
	onFloor("WallEast", Vector3.new(w, WALL_HEIGHT, 222), 71, -160, DARK)
	onFloor("WallBack", Vector3.new(144, WALL_HEIGHT, w), 0, -271, DARK)
	-- Frente con entrada de 16 studs al medio.
	onFloor("WallFrontLeft", Vector3.new(63, WALL_HEIGHT, w), -39.5, -49, DARK)
	onFloor("WallFrontRight", Vector3.new(63, WALL_HEIGHT, w), 39.5, -49, DARK)
	onFloor("GatePostLeft", Vector3.new(3, WALL_HEIGHT + 3, 3), -8, -49, LIGHT)
	onFloor("GatePostRight", Vector3.new(3, WALL_HEIGHT + 3, 3), 8, -49, LIGHT)
end

local function buildCamps()
	-- Goblins: cajas y una carpa.
	onFloor("Crate", Vector3.new(4, 4, 4), -40, -84, LIGHT, 15)
	onFloor("Crate", Vector3.new(4, 4, 4), -20, -100, LIGHT, -20)
	onFloor("Crate", Vector3.new(3, 3, 3), -41, -88, LIGHT, 40)
	local tent = Instance.new("WedgePart")
	tent.Name = "Tent"
	tent.Size = Vector3.new(8, 5, 5)
	tent.CFrame = CFrame.new(-45, FLOOR_TOP + 2.5, -100) * CFrame.Angles(0, math.rad(90), 0)
	tent.Color = Color3.fromRGB(140, 110, 80)
	tent.Material = Enum.Material.SmoothPlastic
	tent.Anchored = true
	tent.Parent = folder

	-- Arañas: pilares para cortar la línea de los escupitajos.
	onFloor("Pillar", Vector3.new(3, 12, 3), 27, -117, LIGHT)
	onFloor("Pillar", Vector3.new(3, 12, 3), 42, -134, LIGHT)
	onFloor("Pillar", Vector3.new(3, 12, 3), 22, -136, LIGHT)
	onFloor("Pillar", Vector3.new(3, 12, 3), 46, -112, LIGHT)

	-- Plataforma alta con rampa, para probar alturas.
	onFloor("Platform", Vector3.new(16, 4, 16), 55, -165, LIGHT)
	local ramp = Instance.new("WedgePart")
	ramp.Name = "Ramp"
	ramp.Size = Vector3.new(8, 4, 10)
	ramp.CFrame = CFrame.new(55, FLOOR_TOP + 2, -152) * CFrame.Angles(0, math.rad(180), 0)
	ramp.Color = LIGHT
	ramp.Material = Enum.Material.SmoothPlastic
	ramp.Anchored = true
	ramp.Parent = folder

	-- Lobos: unas rocas sueltas en campo abierto.
	onFloor("Rock", Vector3.new(6, 3, 5), -45, -162, DARK, 20)
	onFloor("Rock", Vector3.new(5, 2.5, 6), -15, -185, DARK, -35)
end

local function buildBossArena()
	local floor = block(
		"BossFloor",
		Vector3.new(0.2, BOSS_RADIUS * 2, BOSS_RADIUS * 2),
		CFrame.new(BOSS_CENTER + Vector3.new(0, FLOOR_TOP + 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		ARENA,
		Enum.PartType.Cylinder
	)
	floor.CanCollide = false

	-- Anillo de muros con una entrada mirando hacia la fogata (+Z).
	local segments = 28
	local wallRadius = BOSS_RADIUS + 1
	local segmentLength = 2 * math.pi * wallRadius / segments + 0.3
	for i = 0, segments - 1 do
		local angle = (i + 0.5) / segments * 2 * math.pi
		-- Ángulo 0 = +Z: se dejan 3 segmentos libres para la entrada.
		local fromFront = math.abs(math.atan2(math.sin(angle), math.cos(angle)))
		if fromFront > math.rad(20) then
			local position = BOSS_CENTER + Vector3.new(math.sin(angle) * wallRadius, 0, math.cos(angle) * wallRadius)
			local cframe = CFrame.lookAt(position, BOSS_CENTER) * CFrame.new(0, FLOOR_TOP + 4, 0)
			block("ArenaWall", Vector3.new(segmentLength, 8, 2), cframe, DARK)
		end
	end
end

-- Distancia libre desde `from` en la dirección `direction` (horizontal) hasta
-- chocar con el escenario, como mucho `maxDistance`.
function ArenaService.FreeDistance(from: Vector3, direction: Vector3, maxDistance: number): number
	local flat = direction * Vector3.new(1, 0, 1)
	if flat.Magnitude < 1e-3 then
		return 0
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { folder }
	local origin = Vector3.new(from.X, FLOOR_TOP + 1.5, from.Z)
	local hit = workspace:Raycast(origin, flat.Unit * maxDistance, params)
	return if hit then math.max(0, hit.Distance - 1) else maxDistance
end

function ArenaService:Init()
	local old = workspace:FindFirstChild("TestArea")
	if old then
		old:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = "TestArea"
	buildCampfire()
	buildBounds()
	buildCamps()
	buildBossArena()
	folder.Parent = workspace
end

return ArenaService
