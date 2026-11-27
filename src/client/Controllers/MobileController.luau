--!strict
-- Controles táctiles (móvil y tablet): botones en arco alrededor del pulgar
-- derecho. Ataque grande en la esquina, con saltar y las habilidades en un
-- primer arco, y esquivar, definitiva y cambiar de objetivo en un segundo arco.
-- Cada botón llama a la misma función que su tecla en PC, así que las reglas
-- (esperas, recurso, cargas) son las mismas. Reemplaza el botón de salto de
-- Roblox, que quedaba debajo del arco.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AbilityController = require(script.Parent.AbilityController)
local DodgeController = require(script.Parent.DodgeController)
local InputController = require(script.Parent.InputController)
local TargetController = require(script.Parent.TargetController)

-- Medidas en píxeles para una pantalla de 400 de alto; se escalan con UIScale.
local REFERENCE_HEIGHT = 400
local ATTACK_SIZE = 96
local INNER_SIZE = 54
local OUTER_SIZE = 48
local INNER_RADIUS = 112
local OUTER_RADIUS = 176
-- Centro del botón de ataque, medido desde la esquina inferior derecha.
local CENTER = Vector2.new(-100, -100)

local COLORS = {
	Attack = Color3.fromRGB(190, 60, 50),
	Ability = Color3.fromRGB(60, 50, 45),
	Dodge = Color3.fromRGB(40, 110, 170),
	Ultimate = Color3.fromRGB(70, 40, 30),
	Utility = Color3.fromRGB(45, 45, 55),
}
local ULTIMATE_COLOR = Color3.fromRGB(255, 120, 40)

local player = Players.LocalPlayer

local MobileController = {}

-- Posición en el arco: ángulo 0 a la izquierda del ataque y 90 arriba.
local function arc(angle: number, radius: number): Vector2
	local rad = math.rad(angle)
	return CENTER + Vector2.new(-math.cos(rad) * radius, -math.sin(rad) * radius)
end

type Button = { button: TextButton, label: TextLabel, timer: TextLabel, stroke: UIStroke }

local function makeButton(parent: Instance, name: string, center: Vector2, size: number, color: Color3): Button
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.new(1, center.X, 1, center.Y)
	button.Size = UDim2.fromOffset(size, size)
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0.15
	button.AutoButtonColor = true
	button.Text = ""
	button.Parent = parent
	Instance.new("UICorner", button).CornerRadius = UDim.new(0.5, 0)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Transparency = 0.6
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Size = UDim2.fromScale(0.86, 0.6)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Text = ""
	label.Parent = button
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = if size >= ATTACK_SIZE then 18 else 12
	limit.Parent = label

	-- Segundos de espera, encima de todo.
	local timer = Instance.new("TextLabel")
	timer.BackgroundTransparency = 1
	timer.Size = UDim2.fromScale(1, 1)
	timer.Font = Enum.Font.GothamBlack
	timer.TextSize = 22
	timer.TextColor3 = Color3.new(1, 1, 1)
	timer.TextStrokeTransparency = 0.3
	timer.Text = ""
	timer.ZIndex = 2
	timer.Parent = button

	return { button = button, label = label, timer = timer, stroke = stroke }
end

-- Botón que se mantiene apretado (ataque): avisa al apretar y al soltar.
local function onHold(button: TextButton, callback: (pressed: boolean) -> ())
	local touching = 0
	button.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
			touching += 1
			callback(true)
		end
	end)
	button.InputEnded:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
			touching = math.max(0, touching - 1)
			if touching == 0 then
				callback(false)
			end
		end
	end)
end

local function jump()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Jump = true
	end
end

-- Oculta el botón de salto de Roblox: el nuestro está en el arco.
local function hideDefaultJump()
	local playerGui = player:WaitForChild("PlayerGui")
	local touchGui = playerGui:WaitForChild("TouchGui", 30)
	local frame = touchGui and touchGui:WaitForChild("TouchControlFrame", 10)
	local jumpButton = frame and frame:WaitForChild("JumpButton", 10)
	if jumpButton and jumpButton:IsA("GuiObject") then
		jumpButton.Visible = false
		jumpButton:GetPropertyChangedSignal("Visible"):Connect(function()
			jumpButton.Visible = false
		end)
	end
end

local function build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "MobileControls"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets

	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1, 1)
	holder.Parent = gui
	local scale = Instance.new("UIScale")
	scale.Parent = holder

	local attack = makeButton(holder, "Attack", CENTER, ATTACK_SIZE, COLORS.Attack)
	attack.label.Text = "Atacar"
	onHold(attack.button, InputController.SetAttacking)

	local jumpButton = makeButton(holder, "Jump", arc(0, INNER_RADIUS), INNER_SIZE, COLORS.Utility)
	jumpButton.label.Text = "Saltar"
	jumpButton.button.Activated:Connect(jump)

	-- Habilidades 1 a 3 en el primer arco. Las de especialización (4 a 6)
	-- se suman aquí cuando existan.
	local abilities: { [number]: Button } = {}
	for slot, angle in { 28, 56, 84 } do
		local button = makeButton(holder, `Ability{slot}`, arc(angle, INNER_RADIUS), INNER_SIZE, COLORS.Ability)
		button.button.Activated:Connect(function()
			AbilityController.Use(slot)
		end)
		abilities[slot] = button
	end

	local dodge = makeButton(holder, "Dodge", arc(8, OUTER_RADIUS), OUTER_SIZE, COLORS.Dodge)
	dodge.button.Activated:Connect(DodgeController.Dodge)

	local ultimate = makeButton(holder, "Ultimate", arc(42, OUTER_RADIUS), OUTER_SIZE + 6, COLORS.Ultimate)
	ultimate.stroke.Color = ULTIMATE_COLOR
	ultimate.button.Activated:Connect(function()
		AbilityController.Use("Ultimate")
	end)

	local target = makeButton(holder, "Target", arc(76, OUTER_RADIUS), OUTER_SIZE - 6, COLORS.Utility)
	target.label.Text = "Cambiar objetivo"
	target.button.Activated:Connect(TargetController.Switch)

	gui.Parent = player:WaitForChild("PlayerGui")

	RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if camera then
			scale.Scale = math.clamp(camera.ViewportSize.Y / REFERENCE_HEIGHT, 0.8, 1.6)
		end

		for slot, button in abilities do
			local info = AbilityController.Info(slot)
			button.button.Visible = info ~= nil
			if info then
				button.label.Text = info.name
				button.timer.Text = if info.remaining >= 1 then tostring(math.ceil(info.remaining)) else ""
				local ready = info.remaining <= 0 and info.usable
				button.button.BackgroundTransparency = if ready then 0.15 else 0.6
				button.label.TextTransparency = if info.remaining >= 1 then 0.6 else 0
			end
		end

		local charges = DodgeController.Charges()
		dodge.label.Text = `Esquivar {math.floor(charges)}`
		dodge.button.BackgroundTransparency = if charges >= 1 then 0.15 else 0.6

		local info = AbilityController.Info("Ultimate")
		ultimate.button.Visible = info ~= nil
		if info and info.charge then
			local full = info.charge >= 1
			ultimate.label.Text = if full then info.name else `{math.floor(info.charge * 100)}%`
			ultimate.button.BackgroundTransparency = if full then 0.1 else 0.55
			-- Llena: el borde late para avisar que se puede usar.
			ultimate.stroke.Thickness = if full then 3 + math.sin(os.clock() * 6) else 2
			ultimate.stroke.Transparency = if full then 0 else 0.6
		end
	end)
end

function MobileController:Start()
	if not UserInputService.TouchEnabled then
		return
	end
	task.spawn(hideDefaultJump)
	build()
end

return MobileController
