--!strict
-- Efectos visuales provisorios hechos con piezas simples (sin texturas ni assets).
-- Son solo del cliente: cada cliente dibuja los suyos y los de los demás.
-- Cada tipo de Data/Feedback (EffectKind) tiene aquí su constructor.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)

-- Contexto de una señal: quién la hace, dónde y contra quién.
export type Context = {
	character: Model?, -- el que la hace (o el objetivo, en efectos AtTarget)
	origin: CFrame, -- centro del personaje mirando al frente (sin inclinación)
	caster: Model?, -- el que la hace, siempre (para los rayos)
	target: Model?, -- enemigo al que apunta, si hay
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Targeting = require(ReplicatedStorage.Shared.Targeting)

local SLASH_SEGMENTS = 12
local SLASH_SWEEP_TIME = 0.08 -- lo que tarda el arco en dibujarse
local SLASH_FADE_TIME = 0.22
local RING_SEGMENTS = 24

local folder = Instance.new("Folder")
folder.Name = "CombatEffects"
folder.Parent = workspace

local Effects = {}

local function newPart(color: Color3): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function fade(instance: Instance, time: number, goal: { [string]: any })
	TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

-- Arco de tajo: cinta de segmentos que aparece en orden y se desvanece.
local function slash(def: Feedback.EffectDef, ctx: Context)
	local radius = def.Size or 6
	local span = math.rad(def.Span or 140)
	local sweep = def.Sweep or 1
	local center = ctx.origin * CFrame.new(0, def.Height or 0.3, 0) * CFrame.Angles(0, 0, math.rad(def.Roll or 0))

	local step = span / SLASH_SEGMENTS
	local chord = 2 * radius * math.sin(step / 2) * 1.15 -- un poco más largo para que no queden huecos
	for i = 0, SLASH_SEGMENTS - 1 do
		-- Ángulo 0 al frente y positivo a la derecha; con sweep 1 empieza a la derecha.
		-- Con Roll 90 la derecha queda arriba: el arco baja.
		local angle = sweep * (span / 2 - (i + 0.5) * step)
		local position = Vector3.new(math.sin(angle) * radius, 0, -math.cos(angle) * radius)
		local tangent = Vector3.new(math.cos(angle), 0, math.sin(angle)) * -sweep
		-- Más ancho en el centro del recorrido y fino en las puntas.
		local progress = (i + 0.5) / SLASH_SEGMENTS
		local width = 0.25 + 0.9 * math.sin(progress * math.pi)

		local part = newPart(def.Color)
		part.Size = Vector3.new(width, 0.08, chord)
		part.CFrame = center * CFrame.lookAt(position, position + tangent)
		part.Transparency = 1
		part.Parent = folder

		task.delay(progress * SLASH_SWEEP_TIME, function()
			part.Transparency = 0.15
			fade(part, SLASH_FADE_TIME, { Transparency = 1, Size = Vector3.new(width * 0.3, 0.05, chord) })
		end)
		Debris:AddItem(part, SLASH_SWEEP_TIME + SLASH_FADE_TIME + 0.05)
	end
end

-- Onda en el suelo: anillo de segmentos que se abre y se desvanece.
local function ring(def: Feedback.EffectDef, ctx: Context)
	local duration = def.Duration or 0.4
	local radius = (def.Size or 10) / 2
	local startRadius = 1
	local center = ctx.origin * CFrame.new(0, def.Height or (if def.Ground then 0.15 else -2.8), 0)
	local step = 2 * math.pi / RING_SEGMENTS
	local function chordAt(r: number): number
		return 2 * r * math.sin(step / 2) * 1.1
	end
	for i = 0, RING_SEGMENTS - 1 do
		local angle = i * step
		local direction = Vector3.new(math.sin(angle), 0, -math.cos(angle))
		local tangent = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local part = newPart(def.Color)
		part.Size = Vector3.new(0.9, 0.12, chordAt(startRadius))
		part.CFrame = center * CFrame.lookAt(direction * startRadius, direction * startRadius + tangent)
		part.Transparency = 0.1
		part.Parent = folder
		fade(part, duration, {
			CFrame = center * CFrame.lookAt(direction * radius, direction * radius + tangent),
			Size = Vector3.new(0.3, 0.05, chordAt(radius)),
			Transparency = 1,
		})
		Debris:AddItem(part, duration + 0.05)
	end
end

-- Estela que sigue al personaje mientras dura.
local function trail(def: Feedback.EffectDef, ctx: Context)
	local character = ctx.character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local duration = def.Duration or 0.3
	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, 1.4, 0)
	top.Parent = root
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -1.6, 0)
	bottom.Parent = root

	local effect = Instance.new("Trail")
	effect.Attachment0 = top
	effect.Attachment1 = bottom
	effect.Color = ColorSequence.new(def.Color)
	effect.LightEmission = 1
	effect.Lifetime = 0.25
	effect.Transparency = NumberSequence.new(0.35, 1)
	effect.WidthScale = NumberSequence.new(1, 0.2)
	effect.Parent = root

	task.delay(duration, function()
		effect.Enabled = false
	end)
	for _, instance in { effect, top, bottom } :: { Instance } do
		Debris:AddItem(instance, duration + effect.Lifetime + 0.05)
	end
end

-- Brillo sobre el personaje mientras dura un efecto (p. ej. el Grito de batalla).
local auras: { [Model]: Highlight } = {}

local function aura(def: Feedback.EffectDef, ctx: Context)
	local character = ctx.character
	if not character then
		return
	end
	local previous = auras[character]
	if previous then
		previous:Destroy()
	end
	local duration = def.Duration or 1
	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = def.Color
	highlight.OutlineColor = def.Color
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.1
	highlight.Parent = character
	auras[character] = highlight

	-- Destello fuerte al empezar; después queda un brillo suave.
	fade(highlight, 0.4, { FillTransparency = 0.88, OutlineTransparency = 0.45 })
	task.delay(math.max(duration - 0.3, 0), function()
		if auras[character] == highlight then
			fade(highlight, 0.3, { FillTransparency = 1, OutlineTransparency = 1 })
		end
	end)
	task.delay(duration, function()
		if auras[character] == highlight then
			auras[character] = nil
		end
		highlight:Destroy()
	end)
end

-- Apaga el brillo del personaje antes de tiempo (carga cancelada).
function Effects.ClearAura(character: Model)
	local highlight = auras[character]
	if highlight then
		auras[character] = nil
		highlight:Destroy()
	end
end

-- Chispa de impacto: destello y esquirlas que salen en todas direcciones.
local function spark(def: Feedback.EffectDef, ctx: Context)
	local scale = def.Size or 1
	local position = ctx.origin.Position

	local flash = newPart(def.Color)
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.one * 0.6 * scale
	flash.CFrame = CFrame.new(position)
	flash.Transparency = 0.1
	flash.Parent = folder
	fade(flash, 0.12, { Size = Vector3.one * 2.6 * scale, Transparency = 1 })
	Debris:AddItem(flash, 0.15)

	for _ = 1, math.round(5 * scale) do
		local direction = Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5)
		if direction.Magnitude < 1e-3 then
			direction = Vector3.yAxis
		end
		direction = direction.Unit
		local shard = newPart(def.Color)
		shard.Size = Vector3.new(0.12, 0.12, 0.7) * scale
		shard.CFrame = CFrame.lookAt(position, position + direction)
		shard.Parent = folder
		local travel = (1.8 + math.random() * 1.4) * scale
		fade(shard, 0.2, {
			CFrame = shard.CFrame + direction * travel,
			Size = Vector3.new(0.02, 0.02, 0.1),
			Transparency = 1,
		})
		Debris:AddItem(shard, 0.25)
	end
end

-- Punto del suelo bajo `position` (sin contar personajes, enemigos ni efectos).
function Effects.Ground(position: Vector3): Vector3
	local exclude: { Instance } = { folder }
	local enemies = workspace:FindFirstChild("Enemies")
	if enemies then
		table.insert(exclude, enemies)
	end
	for _, other in Players:GetPlayers() do
		if other.Character then
			table.insert(exclude, other.Character)
		end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclude
	local hit = workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -60, 0), params)
	return if hit then hit.Position else position - Vector3.new(0, 3, 0)
end

-- Posición de una parte del personaje (la mano que lanza), o delante del pecho.
function Effects.PartPosition(character: Model?, partName: string?): Vector3?
	if not character then
		return nil
	end
	local part = partName and character:FindFirstChild(partName)
	if part and part:IsA("BasePart") then
		return part.Position
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return (root.CFrame * CFrame.new(0, 0.5, -1.5)).Position
	end
	return nil
end

-- Columna de luz que baja del cielo al punto y se adelgaza.
local function column(def: Feedback.EffectDef, ctx: Context)
	local duration = def.Duration or 0.5
	local height = def.Size or 14
	local base = ctx.origin.Position
	local function piece(width: number, transparency: number, color: Color3): Part
		local part = newPart(color)
		part.Shape = Enum.PartType.Cylinder
		-- El eje del cilindro es X: se gira para que quede vertical.
		part.CFrame = CFrame.new(base + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
		part.Size = Vector3.new(height, width, width)
		part.Transparency = transparency
		part.Parent = folder
		fade(part, duration, { Size = Vector3.new(height, width * 0.15, width * 0.15), Transparency = 1 })
		Debris:AddItem(part, duration + 0.05)
		return part
	end
	piece(3.2, 0.45, def.Color)
	piece(1.2, 0.05, Color3.new(1, 1, 1):Lerp(def.Color, 0.3))
end

-- Esfera que se expande y se desvanece (explosiones, novas, parpadeo).
local function burst(def: Feedback.EffectDef, ctx: Context)
	local duration = def.Duration or 0.35
	local size = def.Size or 6
	local center = ctx.origin.Position + Vector3.new(0, def.Height or 0, 0)
	for i, settings in { { 0.15, 1 }, { 0.6, 1.25 } } do
		local part = newPart(if i == 1 then def.Color else Color3.new(1, 1, 1):Lerp(def.Color, 0.5))
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.one * math.min(1.2, size * 0.2)
		part.CFrame = CFrame.new(center)
		part.Transparency = settings[1]
		part.Parent = folder
		fade(
			part,
			duration * settings[2],
			{ Size = Vector3.one * size * (if i == 1 then 1 else 0.6), Transparency = 1 }
		)
		Debris:AddItem(part, duration * settings[2] + 0.05)
	end
	local light = Instance.new("PointLight")
	light.Color = def.Color
	light.Range = size * 0.9
	light.Brightness = 1.5
	local holder = newPart(def.Color)
	holder.Transparency = 1
	holder.Size = Vector3.one * 0.1
	holder.CFrame = CFrame.new(center)
	light.Parent = holder
	holder.Parent = folder
	fade(light, duration, { Brightness = 0 })
	Debris:AddItem(holder, duration + 0.05)
end

-- Círculo en el suelo que dura y late (Consagración).
local function field(def: Feedback.EffectDef, ctx: Context)
	local duration = def.Duration or 3
	local size = def.Size or 16
	local disc = newPart(def.Color)
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(0.12, size, size)
	disc.CFrame = CFrame.new(ctx.origin.Position + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Transparency = 0.6
	disc.Parent = folder
	local start = os.clock()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local t = os.clock() - start
		if t >= duration or not disc.Parent then
			connection:Disconnect()
			fade(disc, 0.3, { Transparency = 1 })
			Debris:AddItem(disc, 0.35)
			return
		end
		disc.Transparency = 0.62 + 0.12 * math.sin(t * 6)
	end)
end

-- Flechas que caen al azar dentro del círculo mientras dura.
local function rain(def: Feedback.EffectDef, ctx: Context)
	local duration = def.Duration or 1
	local radius = (def.Size or 16) / 2
	local base = ctx.origin.Position
	task.spawn(function()
		local start = os.clock()
		while os.clock() - start < duration do
			local angle = math.random() * 2 * math.pi
			local r = radius * math.sqrt(math.random())
			local landing = base + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
			local top = landing + Vector3.new(-3, 22, -3)
			local arrow = newPart(def.Color)
			arrow.Size = Vector3.new(0.12, 0.12, 2.6)
			arrow.CFrame = CFrame.lookAt(top, landing)
			arrow.Transparency = 0.1
			arrow.Parent = folder
			local fall = 0.22
			TweenService:Create(arrow, TweenInfo.new(fall, Enum.EasingStyle.Linear), {
				CFrame = CFrame.lookAt(landing, landing + (landing - top).Unit),
			}):Play()
			task.delay(fall, function()
				fade(arrow, 0.25, { Transparency = 1 })
			end)
			Debris:AddItem(arrow, fall + 0.3)
			task.wait(0.035)
		end
	end)
end

-- Rayo de la mano del que lanza al objetivo mientras dura.
local function beam(def: Feedback.EffectDef, ctx: Context)
	local caster = ctx.caster
	local target = ctx.target
	local handName = def.From or "RightHand"
	local hand = caster and caster:FindFirstChild(handName)
	local targetPart = target and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart"))
	if not hand or not hand:IsA("BasePart") or not targetPart then
		return
	end
	local duration = def.Duration or 0.3
	local a0 = Instance.new("Attachment")
	a0.Parent = hand
	local a1 = Instance.new("Attachment")
	a1.Parent = targetPart
	local effect = Instance.new("Beam")
	effect.Attachment0 = a0
	effect.Attachment1 = a1
	effect.FaceCamera = true
	effect.LightEmission = 1
	effect.LightInfluence = 0
	effect.Segments = 1
	effect.Width0 = 0.5
	effect.Width1 = 0.8
	effect.Color = ColorSequence.new(def.Color, def.EndColor or def.Color)
	effect.Parent = a0
	local start = os.clock()
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if t >= duration or not a0.Parent or not a1.Parent then
			connection:Disconnect()
			a0:Destroy()
			a1:Destroy()
			return
		end
		-- Late un poco y se apaga al final.
		local fadeOut = math.clamp((duration - t) / 0.12, 0, 1)
		local pulse = 0.15 + 0.15 * math.sin(t * 30)
		effect.Transparency = NumberSequence.new(1 - fadeOut * (1 - pulse))
	end)
end

local builders: { [Feedback.EffectKind]: (Feedback.EffectDef, Context) -> () } = {
	Slash = slash,
	Ring = ring,
	Trail = trail,
	Aura = aura,
	Spark = spark,
	Column = column,
	Burst = burst,
	Field = field,
	Rain = rain,
	Beam = beam,
}

local function build(def: Feedback.EffectDef, ctx: Context)
	local builder = builders[def.Kind]
	if not builder then
		warn(`[Effects] Tipo de efecto desconocido: {def.Kind}`)
		return
	end
	if def.Ground then
		-- Se calcula al dibujarse: el objetivo pudo moverse durante el retraso.
		local position = ctx.origin.Position
		if def.AtTarget and ctx.target and ctx.target.Parent then
			position = ctx.target:GetPivot().Position
		end
		local ground = Effects.Ground(position)
		ctx = {
			character = ctx.character,
			caster = ctx.caster,
			target = ctx.target,
			origin = CFrame.new(ground) * ctx.origin.Rotation,
		}
	end
	builder(def, ctx)
end

function Effects.Play(def: Feedback.EffectDef, ctx: Context)
	if def.Delay and def.Delay > 0 then
		task.delay(def.Delay, build, def, ctx)
	else
		build(def, ctx)
	end
end

-- Proyectil desde la mano hasta el objetivo (lo sigue si se mueve) o recto hacia
-- adelante. Llama a `onArrive` con el punto de llegada si alcanzó a un objetivo.
function Effects.Projectile(def: Feedback.ProjectileDef, ctx: Context, onArrive: ((Vector3) -> ())?)
	local start = Effects.PartPosition(ctx.caster, def.From or "RightHand")
	if not start then
		return
	end
	local target = ctx.target
	local forward = ctx.origin.LookVector
	local maxDistance = def.Distance or 45

	local part = newPart(def.Color)
	if def.Shape == "Orb" then
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.one * def.Size
		local light = Instance.new("PointLight")
		light.Color = def.Color
		light.Range = 2 + def.Size * 2
		light.Brightness = 1
		light.Parent = part
	else
		part.Size = Vector3.new(0.14, 0.14, 1.6 * def.Size)
	end
	part.CFrame = CFrame.lookAt(start, start + forward)
	part.Parent = folder

	local a0 = Instance.new("Attachment")
	a0.Position = if def.Shape == "Orb" then Vector3.new(0, def.Size * 0.3, 0) else Vector3.new(0, 0.07, 0)
	a0.Parent = part
	local a1 = Instance.new("Attachment")
	a1.Position = -a0.Position
	a1.Parent = part
	local streak = Instance.new("Trail")
	streak.Attachment0 = a0
	streak.Attachment1 = a1
	streak.Color = ColorSequence.new(def.Color)
	streak.LightEmission = 1
	streak.Lifetime = if def.Shape == "Orb" then 0.25 else 0.12
	streak.Transparency = NumberSequence.new(0.2, 1)
	streak.WidthScale = NumberSequence.new(1, 0)
	streak.Parent = part

	local travelled = 0
	local position = start
	local connection
	local function finish(arrived: boolean)
		connection:Disconnect()
		part.Transparency = 1
		streak.Enabled = false
		Debris:AddItem(part, streak.Lifetime + 0.05)
		if arrived and onArrive then
			onArrive(position)
		end
	end
	connection = RunService.RenderStepped:Connect(function(dt)
		local step = def.Speed * dt
		if target then
			if not target.Parent then
				finish(false)
				return
			end
			local goal = target:GetPivot().Position
			local offset = goal - position
			local remaining = offset.Magnitude - Targeting.Radius(target) * 0.6
			if remaining <= step then
				position = goal - offset.Unit * Targeting.Radius(target) * 0.6
				finish(true)
				return
			end
			position += offset.Unit * step
			part.CFrame = CFrame.lookAt(position, goal)
		else
			position += forward * step
			travelled += step
			part.CFrame = CFrame.lookAt(position, position + forward)
			if travelled >= maxDistance then
				finish(false)
			end
		end
	end)
end

return Effects
