--!strict
-- Lo que se ve y se oye de los mobs y jefes (remoto MobCue): un "!" al detectar,
-- la zona roja en el suelo mientras avisan un ataque (se llena hasta que pega),
-- el ataque al soltarlo, el rugido al cambiar de fase y el cuerpo que se
-- desvanece al morir. También la barra del jefe arriba de la pantalla.
-- Todo es visual: dónde y cuándo pega lo decide el servidor (MobService).

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MobData = require(ReplicatedStorage.Shared.Data.Mobs)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Effects = require(script.Parent.Parent.Feedback.Effects)
local FeedbackController = require(script.Parent.FeedbackController)

local TELEGRAPH_COLOR = Color3.fromRGB(255, 45, 35)
local BOSS_BAR_DISTANCE = 90
local DEATH_FADE = 1

local player = Players.LocalPlayer

local folder = Instance.new("Folder")
folder.Name = "MobTelegraphs"

local MobFeedbackController = {}

local function flatPart(shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = TELEGRAPH_COLOR
	part.Shape = shape or Enum.PartType.Block
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function linear(instance: Instance, time: number, goal: { [string]: any })
	TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Linear), goal):Play()
end

local function finish(parts: { Part }, duration: number)
	task.delay(duration, function()
		for _, part in parts do
			TweenService:Create(part, TweenInfo.new(0.15), { Transparency = 1 }):Play()
			Debris:AddItem(part, 0.2)
		end
	end)
end

-- Rectángulo en el suelo desde `origin` hacia `direction`; el relleno avanza
-- desde el mob hasta la punta durante el aviso.
local function rectTelegraph(origin: Vector3, direction: Vector3, length: number, width: number, duration: number)
	if length <= 0 then
		return
	end
	local ground = Effects.Ground(origin)
	local base = CFrame.lookAt(ground, ground + direction)

	local outline = flatPart()
	outline.Size = Vector3.new(width, 0.06, length)
	outline.CFrame = base * CFrame.new(0, 0.12, -length / 2)
	outline.Transparency = 0.7
	outline.Parent = folder

	local fill = flatPart()
	fill.Size = Vector3.new(width, 0.08, 0.05)
	fill.CFrame = base * CFrame.new(0, 0.14, 0)
	fill.Transparency = 0.45
	fill.Parent = folder
	linear(
		fill,
		duration,
		{ Size = Vector3.new(width, 0.08, length), CFrame = base * CFrame.new(0, 0.14, -length / 2) }
	)

	finish({ outline, fill }, duration)
end

-- Círculo en el suelo; el relleno crece desde el centro durante el aviso.
local function circleTelegraph(center: Vector3, radius: number, duration: number)
	local ground = Effects.Ground(center)
	local flat = CFrame.new(ground) * CFrame.Angles(0, 0, math.rad(90))

	local outline = flatPart(Enum.PartType.Cylinder)
	outline.Size = Vector3.new(0.06, radius * 2, radius * 2)
	outline.CFrame = flat + Vector3.new(0, 0.12, 0)
	outline.Transparency = 0.7
	outline.Parent = folder

	local fill = flatPart(Enum.PartType.Cylinder)
	fill.Size = Vector3.new(0.08, 0.2, 0.2)
	fill.CFrame = flat + Vector3.new(0, 0.14, 0)
	fill.Transparency = 0.45
	fill.Parent = folder
	linear(fill, duration, { Size = Vector3.new(0.08, radius * 2, radius * 2) })

	finish({ outline, fill }, duration)
end

-- El mob brilla en rojo mientras avisa.
local function windUpGlow(mob: Model, duration: number)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = TELEGRAPH_COLOR
	highlight.OutlineColor = TELEGRAPH_COLOR
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0.3
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = mob
	linear(highlight, duration, { FillTransparency = 0.45 })
	task.delay(duration, function()
		TweenService:Create(highlight, TweenInfo.new(0.15), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
		Debris:AddItem(highlight, 0.2)
	end)
end

local function exclaim(mob: Model)
	local root = mob.PrimaryPart
	if not root then
		return
	end
	local _, size = mob:GetBoundingBox()
	local gui = Instance.new("BillboardGui")
	gui.Adornee = root
	gui.Size = UDim2.fromOffset(40, 40)
	gui.StudsOffsetWorldSpace = Vector3.new(0, size.Y / 2 + 3.5, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 32
	label.TextColor3 = Color3.fromRGB(255, 210, 60)
	label.TextStrokeTransparency = 0.2
	label.Text = "!"
	label.Parent = gui
	gui.Parent = folder
	TweenService:Create(label, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.4), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	Debris:AddItem(gui, 1.05)
end

-- Señal propia del mob (detectar, morir) según su ficha en Data/Mobs.
local function playOwn(mob: Model, field: "AggroCue" | "DeathCue")
	local id = mob:GetAttribute("MobId")
	local def = if typeof(id) == "string" then MobData.Mobs[id] else nil
	local cueId = def and def[field]
	local root = mob.PrimaryPart
	if not cueId or not root then
		return
	end
	if field == "DeathCue" then
		-- En un punto fijo: el cuerpo desaparece antes de que termine el sonido.
		FeedbackController.PlayAt(root.Position, cueId)
	else
		FeedbackController.PlayFrom(mob, cueId, CFrame.new(root.Position))
	end
end

local function fadeOut(mob: Model)
	local root = mob.PrimaryPart
	playOwn(mob, "DeathCue")
	for _, part in mob:GetDescendants() do
		if part:IsA("BasePart") and part ~= root then
			TweenService:Create(part, TweenInfo.new(DEATH_FADE), { Transparency = 1 }):Play()
		end
	end
end

-- Banner al centro de la pantalla (cambio de fase del jefe).
local banner: TextLabel

local function showBanner(text: string)
	banner.Text = text
	banner.TextTransparency = 0
	banner.TextStrokeTransparency = 0.3
	banner.Visible = true
	TweenService:Create(banner, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.6), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

local function onWarn(mob: Model, data: { [string]: any })
	local attack = MobData.Attacks[data.Attack]
	if not attack then
		return
	end
	local windUp: number = data.WindUp
	local kind = attack.Kind
	if kind == "Swing" or kind == "Bolt" or kind == "Charge" then
		rectTelegraph(data.Origin, data.Direction, data.Length, attack.Width :: number, windUp)
	elseif kind == "Slam" then
		circleTelegraph(data.Origin, data.Radius, windUp)
	elseif kind == "Barrage" then
		for _, position in data.Positions :: { Vector3 } do
			circleTelegraph(position, data.Radius, windUp)
		end
	end
	windUpGlow(mob, windUp)
	if attack.WarnCue then
		FeedbackController.PlayFrom(mob, attack.WarnCue, CFrame.lookAt(data.Origin, data.Origin + data.Direction))
	end
end

local function onRelease(mob: Model, data: { [string]: any })
	local attack = MobData.Attacks[data.Attack]
	if not attack or not attack.Cue or not data.Origin then
		return
	end
	if attack.Kind == "Barrage" then
		for _, position in data.Positions :: { Vector3 } do
			FeedbackController.PlayAt(position, attack.Cue)
		end
		return
	end
	local origin = CFrame.lookAt(data.Origin, data.Origin + data.Direction)
	FeedbackController.PlayFrom(mob, attack.Cue, origin, if attack.Kind == "Bolt" then data.Length else nil)
end

local function onPhase(mob: Model)
	local root = mob.PrimaryPart
	if root then
		FeedbackController.PlayFrom(mob, "OgreRoar", CFrame.new(root.Position))
	end
	local name = mob:GetAttribute("DisplayName")
	local short = if typeof(name) == "string" then string.split(name, " · ")[1] else "El jefe"
	showBanner(`¡{short} se enfurece!`)
end

-- Barra del jefe: aparece mientras un jefe cercano está en pelea.
local function bossBar(gui: ScreenGui)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 56)
	frame.Size = UDim2.fromOffset(420, 40)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = gui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = frame

	local back = Instance.new("Frame")
	back.Position = UDim2.fromOffset(0, 20)
	back.Size = UDim2.new(1, 0, 0, 16)
	back.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
	back.BorderSizePixel = 0
	back.Parent = frame

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(190, 40, 35)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.Parent = back

	local hpText = Instance.new("TextLabel")
	hpText.BackgroundTransparency = 1
	hpText.Size = UDim2.fromScale(1, 1)
	hpText.Font = Enum.Font.GothamBold
	hpText.TextSize = 12
	hpText.TextColor3 = Color3.new(1, 1, 1)
	hpText.ZIndex = 2
	hpText.Parent = back

	task.spawn(function()
		while true do
			task.wait(0.1)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local shown: Model? = nil
			if root and root:IsA("BasePart") then
				for _, enemy in CollectionService:GetTagged("Enemy") do
					if
						enemy:IsA("Model")
						and enemy:GetAttribute("Boss") == true
						and enemy:GetAttribute("InCombat") == true
						and enemy.PrimaryPart
						and (enemy.PrimaryPart.Position - root.Position).Magnitude <= BOSS_BAR_DISTANCE
					then
						shown = enemy
						break
					end
				end
			end
			frame.Visible = shown ~= nil
			if shown then
				local health = shown:GetAttribute("Health")
				local maxHealth = shown:GetAttribute("MaxHealth")
				local name = shown:GetAttribute("DisplayName")
				nameLabel.Text = if typeof(name) == "string" then name else shown.Name
				if typeof(health) == "number" and typeof(maxHealth) == "number" and maxHealth > 0 then
					fill.Size = UDim2.fromScale(math.clamp(health / maxHealth, 0, 1), 1)
					hpText.Text = `{math.ceil(health)} / {maxHealth}`
				end
			end
		end
	end)
end

function MobFeedbackController:Start()
	folder.Parent = workspace

	local gui = Instance.new("ScreenGui")
	gui.Name = "MobUI"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	banner = Instance.new("TextLabel")
	banner.AnchorPoint = Vector2.new(0.5, 0.5)
	banner.Position = UDim2.fromScale(0.5, 0.3)
	banner.Size = UDim2.fromOffset(600, 50)
	banner.BackgroundTransparency = 1
	banner.Font = Enum.Font.GothamBlack
	banner.TextSize = 34
	banner.TextColor3 = Color3.fromRGB(255, 120, 80)
	banner.Visible = false
	banner.Parent = gui

	bossBar(gui)

	Remotes.Event("MobCue").OnClientEvent:Connect(function(mob: unknown, event: unknown, data: unknown)
		if typeof(mob) ~= "Instance" or not mob:IsA("Model") or typeof(event) ~= "string" then
			return
		end
		local payload = if typeof(data) == "table" then data :: { [string]: any } else {}
		if event == "Aggro" then
			exclaim(mob)
			playOwn(mob, "AggroCue")
		elseif event == "Warn" then
			onWarn(mob, payload)
		elseif event == "Release" then
			onRelease(mob, payload)
		elseif event == "Phase" then
			onPhase(mob)
		elseif event == "Death" then
			fadeOut(mob)
		end
	end)
end

return MobFeedbackController
