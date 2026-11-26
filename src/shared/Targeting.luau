--!strict
-- Búsqueda de enemigos (tag "Enemy" con atributo Health) frente a un punto.
-- El cliente la usa para elegir objetivo y el servidor para validarlo,
-- así los dos aplican exactamente la misma regla.

local CollectionService = game:GetService("CollectionService")

-- Diferencia de altura máxima para que un enemigo cuente.
local MAX_HEIGHT_DIFF = 8
local FLAT = Vector3.new(1, 0, 1)

local Targeting = {}

-- Radio del enemigo en studs: el alcance se mide desde su borde.
function Targeting.Radius(enemy: Model): number
	local radius = enemy:GetAttribute("HitRadius")
	return if typeof(radius) == "number" then radius else 2
end

function Targeting.IsAlive(enemy: Instance): boolean
	if not enemy:IsA("Model") or not enemy:IsDescendantOf(workspace) then
		return false
	end
	if not CollectionService:HasTag(enemy, "Enemy") then
		return false
	end
	local health = enemy:GetAttribute("Health")
	return typeof(health) == "number" and health > 0
end

-- Distancia horizontal desde `origin` hasta el centro de `enemy`,
-- o nil si está fuera del alcance, del cono frontal o de la altura permitida.
-- `arcDot` es el coseno del medio ángulo del cono (0,5 = 120°, 0 = 180°).
function Targeting.Distance(enemy: Model, origin: CFrame, range: number, arcDot: number): number?
	local offset = enemy:GetPivot().Position - origin.Position
	if math.abs(offset.Y) > MAX_HEIGHT_DIFF then
		return nil
	end
	local radius = Targeting.Radius(enemy)
	local horizontal = offset * FLAT
	local dist = horizontal.Magnitude
	if dist - radius > range then
		return nil
	end
	-- Encima del objetivo cuenta como de frente.
	if dist > radius then
		local look = origin.LookVector * FLAT
		if look.Magnitude < 1e-3 or horizontal.Unit:Dot(look.Unit) < arcDot then
			return nil
		end
	end
	return dist
end

-- Enemigos vivos en el cono, del más cercano al más lejano.
function Targeting.InCone(origin: CFrame, range: number, arcDot: number): { Model }
	local found: { { enemy: Model, dist: number } } = {}
	for _, enemy in CollectionService:GetTagged("Enemy") do
		if Targeting.IsAlive(enemy) then
			local dist = Targeting.Distance(enemy :: Model, origin, range, arcDot)
			if dist then
				table.insert(found, { enemy = enemy :: Model, dist = dist })
			end
		end
	end
	table.sort(found, function(a, b)
		return a.dist < b.dist
	end)
	local result = table.create(#found)
	for i, entry in found do
		result[i] = entry.enemy
	end
	return result
end

return Targeting
