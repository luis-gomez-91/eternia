--!strict
-- Lo que se ve de los enemigos (tag "Enemy"): barra de vida con nombre,
-- números de daño flotantes y un destello al recibir un golpe. También los
-- números verdes de curación sobre los jugadores.
-- Todo es visual; la vida real la decide el servidor en los atributos.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local BAR_WIDTH = 120
local NUMBER_LIFETIME = 0.8

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local screenFolder = Instance.new("Folder")
screenFolder.Name = "EnemyUI"

local EnemyUIController = {}

-- Distancia desde el centro de la parte principal hasta encima del modelo.
local function topOffset(model: Model, primary: BasePart): number
	local cframe, size = model:GetBoundingBox()
	return (cframe.Position.Y + size.Y / 2) - primary.Position.Y
end

local function attachHealthBar(model: Model)
	-- Con streaming el modelo puede llegar antes que sus partes.
	while not model.PrimaryPart and model:IsDescendantOf(workspace) do
		model:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end
	local primary = model.PrimaryPart
	if not primary then
		return
	end

	local gui = Instance.new("BillboardGui")
	gui.Name = model.Name .. "_Health"
	gui.Adornee = primary
	gui.Size = UDim2.fromOffset(BAR_WIDTH, 34)
	gui.StudsOffsetWorldSpace = Vector3.new(0, topOffset(model, primary) + 1.5, 0)
	gui.MaxDistance = 80
	gui.LightInfluence = 0

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.5
	local displayName = model:GetAttribute("DisplayName")
	nameLabel.Text = if typeof(displayName) == "string" then displayName else model.Name
	nameLabel.Parent = gui

	local back = Instance.new("Frame")
	back.Position = UDim2.fromOffset(0, 18)
	back.Size = UDim2.new(1, 0, 0, 14)
	back.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	back.BorderSizePixel = 0
	back.Parent = gui

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = back

	local hpText = Instance.new("TextLabel")
	hpText.BackgroundTransparency = 1
	hpText.Size = UDim2.fromScale(1, 1)
	hpText.Font = Enum.Font.GothamBold
	hpText.TextSize = 11
	hpText.TextColor3 = Color3.new(1, 1, 1)
	hpText.ZIndex = 2
	hpText.Parent = back

	local function refresh()
		local health = model:GetAttribute("Health")
		local maxHealth = model:GetAttribute("MaxHealth")
		if typeof(health) ~= "number" or typeof(maxHealth) ~= "number" or maxHealth <= 0 then
			return
		end
		fill.Size = UDim2.fromScale(math.clamp(health / maxHealth, 0, 1), 1)
		hpText.Text = `{math.ceil(health)} / {maxHealth}`
	end
	refresh()
	model:GetAttributeChangedSignal("Health"):Connect(refresh)
	model:GetAttributeChangedSignal("MaxHealth"):Connect(refresh)

	gui.Parent = screenFolder
	model.Destroying:Connect(function()
		gui:Destroy()
	end)
	model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(workspace) then
			gui:Destroy()
		end
	end)
end

local HEAL_COLOR = Color3.fromRGB(110, 255, 130)

-- `kind`: "Hit" (golpe), "Tick" (daño en el tiempo, más chico) o "Heal" (verde, con +).
local function showNumber(model: Model, amount: number, crit: boolean, kind: "Hit" | "Tick" | "Heal")
	local primary = model.PrimaryPart
	if not primary then
		return
	end
	local start = Vector3.new((math.random() - 0.5) * 3, topOffset(model, primary) - 0.5, 0)

	local gui = Instance.new("BillboardGui")
	gui.Adornee = primary
	gui.AlwaysOnTop = true
	gui.Size = UDim2.fromOffset(100, 40)
	gui.StudsOffsetWorldSpace = start
	gui.LightInfluence = 0

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = if crit then 30 elseif kind == "Tick" then 16 else 22
	label.TextColor3 = if kind == "Heal"
		then HEAL_COLOR
		elseif crit then Color3.fromRGB(255, 210, 60)
		elseif kind == "Tick" then Color3.fromRGB(215, 190, 255)
		else Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Text = if kind == "Heal"
		then `+{math.floor(amount)}`
		elseif crit then `{math.floor(amount)}!`
		else tostring(math.floor(amount))
	label.Parent = gui
	gui.Parent = screenFolder

	local info = TweenInfo.new(NUMBER_LIFETIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(gui, info, { StudsOffsetWorldSpace = start + Vector3.new(0, 2.5, 0) }):Play()
	TweenService:Create(label, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(NUMBER_LIFETIME, gui.Destroy, gui)
end

local flashes: { [Model]: Highlight } = {}

local function flash(model: Model)
	local highlight = flashes[model]
	if not highlight or not highlight.Parent then
		highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = model
		flashes[model] = highlight
		model.Destroying:Connect(function()
			flashes[model] = nil
		end)
	end
	highlight.FillTransparency = 0.35
	TweenService:Create(highlight, TweenInfo.new(0.15), { FillTransparency = 1 }):Play()
end

function EnemyUIController:Start()
	screenFolder.Parent = playerGui

	local function onEnemy(instance: Instance)
		if instance:IsA("Model") then
			task.spawn(attachHealthBar, instance)
		end
	end
	CollectionService:GetInstanceAddedSignal("Enemy"):Connect(onEnemy)
	for _, instance in CollectionService:GetTagged("Enemy") do
		onEnemy(instance)
	end

	Remotes.Event("CombatFeedback").OnClientEvent:Connect(function(batch: unknown)
		if typeof(batch) ~= "table" then
			return
		end
		for _, entry in batch :: { any } do
			local target = entry.Target
			if typeof(target) == "Instance" and target:IsA("Model") and typeof(entry.Amount) == "number" then
				if entry.Heal then
					showNumber(target, entry.Amount, false, "Heal")
				else
					showNumber(target, entry.Amount, entry.Crit == true, if entry.Tick then "Tick" else "Hit")
					flash(target)
				end
			end
		end
	end)
end

return EnemyUIController
