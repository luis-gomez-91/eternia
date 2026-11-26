--!strict
-- Mueve al personaje en línea recta a velocidad fija durante un tiempo.
-- Solo horizontal: la vertical queda libre para la gravedad.
-- Lo usan esquivar y las habilidades de desplazamiento (Embestida).

local FLAT = Vector3.new(1, 0, 1)

local Dash = {}

-- Devuelve false si no hay dirección válida. `onDone` se llama al terminar.
function Dash.Start(root: BasePart, direction: Vector3, speed: number, duration: number, onDone: (() -> ())?): boolean
	local flat = direction * FLAT
	if flat.Magnitude < 1e-3 or duration <= 0 then
		return false
	end
	flat = flat.Unit

	local attachment = Instance.new("Attachment")
	attachment.Name = "DashAttachment"
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "DashVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	velocity.PrimaryTangentAxis = Vector3.xAxis
	velocity.SecondaryTangentAxis = Vector3.zAxis
	velocity.PlaneVelocity = Vector2.new(flat.X, flat.Z) * speed
	velocity.MaxForce = math.huge
	velocity.Parent = root

	task.delay(duration, function()
		velocity:Destroy()
		attachment:Destroy()
		-- Frena el arrastre para que no patine al terminar.
		if root.Parent then
			root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
		end
		if onDone then
			onDone()
		end
	end)
	return true
end

return Dash
