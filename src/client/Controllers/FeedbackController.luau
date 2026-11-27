--!strict
-- Reproduce las señales de combate de Data/Feedback: animación (o pose provisoria),
-- efectos y sonido. Es solo visual; nunca decide nada del combate.
--
-- Propias: los controles llaman a PlayLocal al instante, sin esperar al servidor.
-- De otros jugadores: llegan por CombatCue cuando el servidor acepta la acción.
-- Impactos: salen del daño que confirma el servidor (CombatFeedback); si el golpe
-- es propio, además sacude un poco la cámara.

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Effects = require(script.Parent.Parent.Feedback.Effects)
local Poser = require(script.Parent.Parent.Feedback.Poser)

local SOUND_MAX_DISTANCE = 90

local player = Players.LocalPlayer

local FeedbackController = {}

-- Animaciones finales ya cargadas, por personaje.
local tracks: { [Model]: { [string]: AnimationTrack } } = {}

-- Grupos de volumen (SFX, Music...) creados al arrancar.
local soundGroups: { [string]: SoundGroup } = {}

-- Sacudida de cámara en curso.
local shakeMagnitude = 0
local shakeUntil = 0
local shakeDuration = 1

local function flatOrigin(root: BasePart): CFrame
	local look = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	if look.Magnitude < 1e-3 then
		look = Vector3.new(0, 0, -1)
	end
	return CFrame.lookAt(root.Position, root.Position + look)
end

local function playAnimation(character: Model, animationId: string, speed: number)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	local byId = tracks[character]
	if not byId then
		byId = {}
		tracks[character] = byId
		character.Destroying:Connect(function()
			tracks[character] = nil
		end)
	end
	local track = byId[animationId]
	if not track then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action
		byId[animationId] = track
	end
	track:Play(0.05, 1, speed)
end

local function playSoundNow(def: Feedback.SoundDef, parent: Instance)
	if not parent.Parent then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = def.Id
	sound.Volume = def.Volume or 0.5
	local jitter = def.PitchJitter or 0
	sound.PlaybackSpeed = (def.Pitch or 1) * (1 + (math.random() * 2 - 1) * jitter)
	sound.RollOffMaxDistance = SOUND_MAX_DISTANCE
	sound.SoundGroup = soundGroups[def.Group or "SFX"]
	sound.Parent = parent
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
end

local function playSound(def: Feedback.SoundDef, parent: Instance)
	if def.Delay and def.Delay > 0 then
		task.delay(def.Delay, playSoundNow, def, parent)
	else
		playSoundNow(def, parent)
	end
end

-- Punto fijo en el mundo para que suene algo (se borra solo).
local function anchorAt(position: Vector3): Attachment
	local anchor = Instance.new("Attachment")
	anchor.WorldPosition = position
	anchor.Parent = workspace.Terrain
	task.delay(4, anchor.Destroy, anchor)
	return anchor
end

-- Mirando desde el que lanza hacia el objetivo, a la altura del objetivo.
local function targetOrigin(target: Model, from: Vector3): CFrame
	local position = target:GetPivot().Position
	local away = (position - from) * Vector3.new(1, 0, 1)
	if away.Magnitude < 1e-3 then
		return CFrame.new(position)
	end
	return CFrame.lookAt(position, position + away)
end

local function playEffectsAndSound(cue: Feedback.Cue, ctx: Effects.Context, soundParent: Instance)
	local target = ctx.target
	local targetCtx: Effects.Context? = nil
	if target and target.Parent then
		targetCtx = {
			character = target,
			caster = ctx.caster,
			target = target,
			origin = targetOrigin(target, ctx.origin.Position),
		}
	end
	if cue.Effects then
		for _, effect in cue.Effects do
			if not effect.AtTarget then
				Effects.Play(effect, ctx)
			elseif targetCtx then
				Effects.Play(effect, targetCtx)
			end
		end
	end
	if cue.Sound then
		if cue.Sound.AtTarget and targetCtx then
			playSound(cue.Sound, anchorAt(targetCtx.origin.Position))
		else
			playSound(cue.Sound, soundParent)
		end
	end
	local projectile = cue.Projectile
	if projectile then
		local function launch()
			Effects.Projectile(projectile, ctx, function(position)
				local impact = projectile.Impact
				if not impact then
					return
				end
				local impactCtx: Effects.Context = {
					caster = ctx.caster,
					target = ctx.target,
					origin = CFrame.new(position) * ctx.origin.Rotation,
				}
				if impact.Effects then
					for _, effect in impact.Effects do
						Effects.Play(effect, impactCtx)
					end
				end
				if impact.Sound then
					playSound(impact.Sound, anchorAt(position))
				end
			end)
		end
		if projectile.Delay and projectile.Delay > 0 then
			task.delay(projectile.Delay, launch)
		else
			launch()
		end
	end
end

-- Reproduce una señal sobre un personaje. `replicated` es true si el personaje es
-- de otro jugador: sus animaciones finales ya llegan solas por el Animator.
-- `target` es el enemigo al que apunta (proyectiles, rayos, efectos en el objetivo).
function FeedbackController.Play(character: Model, cueId: string, replicated: boolean?, target: Model?)
	local cue = Feedback.Cues[cueId]
	if not cue then
		warn(`[Feedback] Señal desconocida: {cueId}`)
		return
	end
	if cue.ClearAura then
		Effects.ClearAura(character)
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end

	local speed = cue.Speed or 1
	if cue.Animation then
		if not replicated then
			playAnimation(character, cue.Animation, speed)
		end
	elseif cue.Pose then
		Poser.Play(character, cue.Pose, speed)
	end
	local ctx: Effects.Context =
		{ character = character, caster = character, target = target, origin = flatOrigin(root) }
	playEffectsAndSound(cue, ctx, root)
end

-- Señal de un mob o jefe desde un punto y dirección que manda el servidor (el
-- modelo puede no haber girado todavía en este cliente). `projectileDistance`
-- acorta el proyectil hasta donde choca con el escenario.
function FeedbackController.PlayFrom(caster: Model, cueId: string, origin: CFrame, projectileDistance: number?)
	local cue = Feedback.Cues[cueId]
	if not cue then
		warn(`[Feedback] Señal desconocida: {cueId}`)
		return
	end
	local root = caster:FindFirstChild("HumanoidRootPart")
	if cue.Projectile and projectileDistance then
		local projectile = table.clone(cue.Projectile)
		projectile.Distance = projectileDistance
		local copy = table.clone(cue)
		copy.Projectile = projectile
		cue = copy
	end
	local ctx: Effects.Context = { character = caster, caster = caster, origin = origin }
	playEffectsAndSound(cue, ctx, if root then root else anchorAt(origin.Position))
end

-- Señal del propio personaje.
function FeedbackController.PlayLocal(cueId: string?, target: Model?)
	local character = player.Character
	if cueId and character then
		FeedbackController.Play(character, cueId, false, target)
	end
end

-- Señal en un punto del mundo (impactos).
function FeedbackController.PlayAt(position: Vector3, cueId: string)
	local cue = Feedback.Cues[cueId]
	if not cue then
		return
	end
	playEffectsAndSound(cue, { origin = CFrame.new(position) }, anchorAt(position))
end

local function impactPosition(target: Model): Vector3
	local pivot = target:GetPivot()
	local jitter = Vector3.new(math.random() - 0.5, math.random() - 0.3, math.random() - 0.5)
	-- Del lado de la cámara para que la chispa no quede tapada por el objetivo.
	local camera = workspace.CurrentCamera
	local toward = if camera then (camera.CFrame.Position - pivot.Position) * Vector3.new(1, 0, 1) else Vector3.zero
	local front = if toward.Magnitude > 1e-3 then toward.Unit * 1.2 else Vector3.zero
	return pivot.Position + front + jitter
end

local function shake(def: Feedback.ShakeDef)
	local now = os.clock()
	-- Si ya hay una más fuerte en curso, se queda esa.
	local remaining = math.max(shakeUntil - now, 0) / shakeDuration
	if shakeMagnitude * remaining > def.Magnitude then
		return
	end
	shakeMagnitude = def.Magnitude
	shakeDuration = def.Duration
	shakeUntil = now + def.Duration
end

-- Se aplica después de que la cámara se mueve, así no se acumula entre frames.
local function applyShake()
	local remaining = shakeUntil - os.clock()
	local camera = workspace.CurrentCamera
	if remaining <= 0 or not camera then
		return
	end
	local strength = math.rad(shakeMagnitude) * (remaining / shakeDuration)
	camera.CFrame *= CFrame.Angles((math.random() * 2 - 1) * strength, (math.random() * 2 - 1) * strength, 0)
end

local function createSoundGroups()
	for _, name in Feedback.SoundGroups do
		local group = SoundService:FindFirstChild(name)
		if not group or not group:IsA("SoundGroup") then
			group = Instance.new("SoundGroup")
			group.Name = name
			group.Parent = SoundService
		end
		soundGroups[name] = group :: SoundGroup
	end
end

-- Roblox libera un audio cuando se destruye la última instancia que lo usa, y
-- volver a cargarlo tarda unos 300 ms. Por eso queda una instancia de cada
-- sonido viva (sin sonar) toda la sesión: así cada golpe suena al siguiente frame.
local function preload()
	local folder = Instance.new("Folder")
	folder.Name = "PreloadedCombatSounds"
	folder.Parent = SoundService
	local sounds: { Instance } = {}
	local seen: { [string]: boolean } = {}
	local function add(def: Feedback.SoundDef?)
		if def and not seen[def.Id] then
			seen[def.Id] = true
			local sound = Instance.new("Sound")
			sound.SoundId = def.Id
			sound.Parent = folder
			table.insert(sounds, sound)
		end
	end
	for _, cue in Feedback.Cues do
		add(cue.Sound)
		add(cue.Projectile and cue.Projectile.Impact and cue.Projectile.Impact.Sound)
	end
	ContentProvider:PreloadAsync(sounds)
end

function FeedbackController:Init()
	createSoundGroups()
end

function FeedbackController:Start()
	task.spawn(preload)
	RunService:BindToRenderStep("CombatShake", Enum.RenderPriority.Camera.Value + 1, applyShake)

	Remotes.Event("CombatCue").OnClientEvent:Connect(function(character: unknown, cueId: unknown, target: unknown)
		if typeof(character) ~= "Instance" or not character:IsA("Model") or typeof(cueId) ~= "string" then
			return
		end
		if character == player.Character then
			return -- la propia ya se reprodujo al apretar
		end
		local enemy = if typeof(target) == "Instance" and target:IsA("Model") then target else nil
		FeedbackController.Play(character, cueId, true, enemy)
	end)

	Remotes.Event("CombatFeedback").OnClientEvent:Connect(function(batch: unknown)
		if typeof(batch) ~= "table" then
			return
		end
		for _, entry in batch :: { any } do
			local target = entry.Target
			if typeof(target) ~= "Instance" or not target:IsA("Model") or entry.Heal or entry.Dodged then
				continue -- las curaciones ya se ven en la señal que las lanzó
			end
			local crit = entry.Crit == true
			if entry.Tick then
				FeedbackController.PlayAt(impactPosition(target), Feedback.ImpactTickCue)
				continue
			end
			local set = Feedback.Impacts[if typeof(entry.Impact) == "string" then entry.Impact else "Melee"]
				or Feedback.Impacts.Melee
			FeedbackController.PlayAt(impactPosition(target), if crit then set.Crit else set.Hit)
			if entry.Source == player then
				shake(if crit then Feedback.Shakes.Crit else Feedback.Shakes.Hit)
			elseif entry.Incoming and target == player.Character then
				shake(Feedback.Shakes.Hurt)
			end
		end
	end)
end

return FeedbackController
