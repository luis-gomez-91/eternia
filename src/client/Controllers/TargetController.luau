--!strict
-- Objetivo fijado: automático al enemigo visible más cerca del centro de la
-- pantalla, y la tecla T pasa al siguiente. Un anillo bajo los pies lo marca.
-- Es solo una ayuda del cliente: el servidor valida cada golpe con su propia regla.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Targeting = require(ReplicatedStorage.Shared.Targeting)

local SWITCH_KEY = Enum.KeyCode.T
-- Distancia máxima para elegir un objetivo solo, y para mantenerlo.
local ACQUIRE_RANGE = 30
local KEEP_RANGE = 45
-- Cada cuánto se revisa si hay que elegir otro.
local SCAN_INTERVAL = 0.2
-- Peso de la distancia frente a la cercanía al centro de la pantalla.
local DISTANCE_WEIGHT = 0.35

local RING_SEGMENTS = 20
local RING_COLOR = Color3.fromRGB(255, 80, 70)
local RING_SPIN = 1.2 -- radianes por segundo

local player = Players.LocalPlayer

local TargetController = {}

local current: Model? = nil
local ring: Model? = nil

local function getRoot(): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

local function flatDistance(a: Vector3, b: Vector3): number
	return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

-- Enemigos visibles y cerca, ordenados del mejor al peor candidato.
local function candidates(root: BasePart, range: number): { Model }
	local camera = workspace.CurrentCamera
	if not camera then
		return {}
	end
	local viewport = camera.ViewportSize
	local center = viewport / 2
	local maxScreen = center.Magnitude

	local scored: { { enemy: Model, score: number } } = {}
	for _, instance in CollectionService:GetTagged("Enemy") do
		if not Targeting.IsAlive(instance) then
			continue
		end
		local enemy = instance :: Model
		local position = enemy:GetPivot().Position
		local distance = flatDistance(position, root.Position) - Targeting.Radius(enemy)
		if distance > range then
			continue
		end
		local screen, visible = camera:WorldToViewportPoint(position)
		if not visible then
			continue
		end
		local offCenter = (Vector2.new(screen.X, screen.Y) - center).Magnitude / maxScreen
		table.insert(scored, { enemy = enemy, score = offCenter + DISTANCE_WEIGHT * distance / range })
	end
	table.sort(scored, function(a, b)
		return a.score < b.score
	end)
	local result = table.create(#scored)
	for i, entry in scored do
		result[i] = entry.enemy
	end
	return result
end

local function isKeepable(enemy: Model, root: BasePart): boolean
	return Targeting.IsAlive(enemy)
		and flatDistance(enemy:GetPivot().Position, root.Position) - Targeting.Radius(enemy) <= KEEP_RANGE
end

local function setTarget(enemy: Model?)
	current = enemy
end

-- El siguiente candidato después del actual (o el primero).
local function switchTarget()
	local root = getRoot()
	if not root then
		return
	end
	local list = candidates(root, KEEP_RANGE)
	if #list == 0 then
		return
	end
	local index = if current then table.find(list, current) else nil
	setTarget(list[if index then index % #list + 1 else 1])
end

local function scan()
	local root = getRoot()
	if not root then
		setTarget(nil)
		return
	end
	if current and isKeepable(current, root) then
		return
	end
	setTarget(candidates(root, ACQUIRE_RANGE)[1])
end

local function buildRing(): Model
	local model = Instance.new("Model")
	model.Name = "TargetRing"
	local step = 2 * math.pi / RING_SEGMENTS
	for i = 0, RING_SEGMENTS - 1 do
		-- Segmentos alternos con hueco, para que se lea como marca y no como piso.
		if i % 2 == 1 then
			continue
		end
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = RING_COLOR
		part.Transparency = 0.2
		part.Size = Vector3.new(0.25, 0.08, 1)
		part:SetAttribute("Angle", i * step)
		part.Parent = model
	end
	model.Parent = workspace
	return model
end

-- Mueve el anillo bajo los pies del objetivo, girando despacio.
local function updateRing(now: number)
	local model = ring
	if not model then
		return
	end
	local enemy = current
	if not enemy or not enemy.Parent then
		for _, part in model:GetChildren() do
			(part :: BasePart).Transparency = 1
		end
		return
	end
	local boxCFrame, boxSize = enemy:GetBoundingBox()
	local floor = boxCFrame.Position - Vector3.new(0, boxSize.Y / 2 - 0.1, 0)
	local radius = Targeting.Radius(enemy) + 0.8
	local step = 2 * math.pi / RING_SEGMENTS
	local chord = 2 * radius * math.sin(step / 2)
	local spin = now * RING_SPIN
	for _, child in model:GetChildren() do
		local part = child :: BasePart
		local angle = (part:GetAttribute("Angle") :: number) + spin
		local direction = Vector3.new(math.sin(angle), 0, -math.cos(angle))
		local tangent = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local position = floor + direction * radius
		part.Size = Vector3.new(0.25, 0.08, chord)
		part.CFrame = CFrame.lookAt(position, position + tangent)
		part.Transparency = 0.2
	end
end

-- Objetivo actual, si sigue vivo.
function TargetController.Get(): Model?
	if current and Targeting.IsAlive(current) then
		return current
	end
	return nil
end

-- Gira al personaje hacia el objetivo si está a menos de `maxDistance` studs
-- (desde su borde). Devuelve el objetivo si giró.
function TargetController.FaceIfWithin(maxDistance: number): Model?
	local enemy = TargetController.Get()
	local root = getRoot()
	if not enemy or not root then
		return nil
	end
	local position = enemy:GetPivot().Position
	if flatDistance(position, root.Position) - Targeting.Radius(enemy) > maxDistance then
		return nil
	end
	local flat = Vector3.new(position.X, root.Position.Y, position.Z)
	if (flat - root.Position).Magnitude > 0.1 then
		root.CFrame = CFrame.lookAt(root.Position, flat)
	end
	return enemy
end

function TargetController:Start()
	ring = buildRing()

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == SWITCH_KEY then
			switchTarget()
		end
	end)

	local lastScan = 0
	RunService.RenderStepped:Connect(function()
		local now = os.clock()
		if now - lastScan >= SCAN_INTERVAL then
			lastScan = now
			scan()
		end
		updateRing(now)
	end)
end

return TargetController
