--!strict
-- Efectos visuales provisorios hechos con piezas simples (sin texturas ni assets).
-- Son solo del cliente: cada cliente dibuja los suyos y los de los demás.
-- Cada tipo de Data/Feedback (EffectKind) tiene aquí su constructor.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)

-- Contexto de una señal: quién la hace y dónde.
export type Context = {
	character: Model?,
	origin: CFrame, -- centro del personaje mirando al frente (sin inclinación)
}

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
	local center = ctx.origin * CFrame.new(0, def.Height or -2.8, 0)
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

local builders: { [Feedback.EffectKind]: (Feedback.EffectDef, Context) -> () } = {
	Slash = slash,
	Ring = ring,
	Trail = trail,
	Aura = aura,
	Spark = spark,
}

function Effects.Play(def: Feedback.EffectDef, ctx: Context)
	local build = builders[def.Kind]
	if not build then
		warn(`[Effects] Tipo de efecto desconocido: {def.Kind}`)
		return
	end
	if def.Delay and def.Delay > 0 then
		task.delay(def.Delay, build, def, ctx)
	else
		build(def, ctx)
	end
end

return Effects
