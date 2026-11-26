--!strict
-- Muñecos de práctica: reciben daño, nunca mueren y vuelven a vida completa
-- tras unos segundos sin recibir golpes.

local CollectionService = game:GetService("CollectionService")

local MAX_HEALTH = 5000
local REGEN_DELAY = 5
local POSITIONS = {
	Vector3.new(-12, 0, -25),
	Vector3.new(0, 0, -25),
	Vector3.new(12, 0, -25),
}

local DummyService = {}

local function part(name: string, size: Vector3, cframe: CFrame, color: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Shape = shape or Enum.PartType.Block
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

local function buildDummy(position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "TrainingDummy"

	local wood = Color3.fromRGB(150, 110, 70)
	local straw = Color3.fromRGB(215, 185, 110)
	local base = CFrame.new(position)

	-- El eje del cilindro es X: se gira 90° para que quede como disco en el suelo.
	local standCFrame = base * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
	part("Stand", Vector3.new(1, 4, 4), standCFrame, wood, Enum.PartType.Cylinder).Parent = model
	part("Post", Vector3.new(0.8, 3, 0.8), base * CFrame.new(0, 2.5, 0), wood).Parent = model
	local body = part("Body", Vector3.new(2.5, 3.5, 1.5), base * CFrame.new(0, 5.25, 0), straw)
	body.Parent = model
	part("Arms", Vector3.new(5, 0.8, 0.8), base * CFrame.new(0, 6.2, 0), wood).Parent = model
	part("Head", Vector3.new(2, 2, 2), base * CFrame.new(0, 8, 0), straw, Enum.PartType.Ball).Parent = model

	model.PrimaryPart = body
	-- Con streaming, que llegue al cliente entero y no parte por parte.
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model:SetAttribute("DisplayName", "Muñeco de práctica")
	model:SetAttribute("MaxHealth", MAX_HEALTH)
	model:SetAttribute("Health", MAX_HEALTH)
	model:SetAttribute("HitRadius", 1.5)
	CollectionService:AddTag(model, "Enemy")
	return model
end

function DummyService:Start()
	local folder = workspace:FindFirstChild("Enemies") or Instance.new("Folder")
	folder.Name = "Enemies"
	folder.Parent = workspace

	local lastHit: { [Model]: number } = {}

	for _, position in POSITIONS do
		local dummy = buildDummy(position)
		lastHit[dummy] = 0
		dummy:GetAttributeChangedSignal("Health"):Connect(function()
			local health = dummy:GetAttribute("Health") :: number
			if health < MAX_HEALTH then
				lastHit[dummy] = os.clock()
			end
			if health <= 0 then
				-- Nunca muere: vuelve a vida completa en el siguiente cuadro.
				task.defer(dummy.SetAttribute, dummy, "Health", MAX_HEALTH)
			end
		end)
		dummy.Parent = folder
	end

	while true do
		task.wait(1)
		local now = os.clock()
		for dummy, t in lastHit do
			if now - t >= REGEN_DELAY and (dummy:GetAttribute("Health") :: number) < MAX_HEALTH then
				dummy:SetAttribute("Health", MAX_HEALTH)
			end
		end
	end
end

return DummyService
