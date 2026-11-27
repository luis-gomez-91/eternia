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
-- Tamaño de un botón mientras se mantiene apretado.
local PRESSED_SCALE = 0.9
-- Dejar el dedo apretado este tiempo en una habilidad muestra su nombre, y al
-- soltar no se usa (los íconos no llevan texto).
local LONG_PRESS = 0.4

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

type Button = { button: TextButton, label: TextLabel, timer: TextLabel, stroke: UIStroke, icon: ImageLabel }

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

	-- Ícono de la habilidad (Data/Abilities, campo Icon); oculto si no tiene.
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromScale(0.8, 0.8)
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Visible = false
	icon.ZIndex = 0 -- debajo del % de la definitiva y del tiempo de espera
	icon.Parent = button

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

	return { button = button, label = label, timer = timer, stroke = stroke, icon = icon }
end

-- Muestra el ícono si hay; si no, el texto.
local function setIcon(entry: Button, image: string?, text: string)
	entry.icon.Visible = image ~= nil
	entry.icon.Image = image or ""
	entry.label.Text = if image then "" else text
end

-- Toque corto: usa la habilidad (al soltar, como Activated). Dedo apretado
-- LONG_PRESS segundos: muestra el nombre arriba del botón y al soltar no la usa.
local function onTapOrHold(entry: Button, bubble: TextLabel, getName: () -> string?, use: () -> ())
	local button = entry.button
	local pressId = 0
	local held = false
	local longPressed = false
	button.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind ~= Enum.UserInputType.Touch and kind ~= Enum.UserInputType.MouseButton1 then
			return
		end
		pressId += 1
		local id = pressId
		held = true
		longPressed = false
		task.delay(LONG_PRESS, function()
			local name = getName()
			if id ~= pressId or not held or not name then
				return
			end
			longPressed = true
			local position = button.Position
			bubble.Text = name
			bubble.Position = position - UDim2.fromOffset(0, button.Size.Y.Offset / 2 + 8)
			bubble.Visible = true
		end)
	end)
	button.InputEnded:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
			held = false
			if longPressed then
				bubble.Visible = false
			end
		end
	end)
	-- longPressed se limpia en el próximo toque, así no importa si Activated
	-- llega antes o después de InputEnded.
	button.Activated:Connect(function()
		if not longPressed then
			use()
		end
	end)
end

-- Botón que se mantiene apretado (ataque, saltar): avisa al apretar y al
-- soltar, y se achica mientras está apretado para que se note que tomó el toque.
local function onHold(button: TextButton, callback: (pressed: boolean) -> ())
	local touching = 0
	local scale = Instance.new("UIScale")
	scale.Parent = button
	button.InputBegan:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
			touching += 1
			scale.Scale = PRESSED_SCALE
			callback(true)
		end
	end)
	button.InputEnded:Connect(function(input)
		local kind = input.UserInputType
		if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
			touching = math.max(0, touching - 1)
			if touching == 0 then
				scale.Scale = 1
				callback(false)
			end
		end
	end)
end

-- Salto: al tocar, si está en el suelo, salta en el acto cambiando el estado
-- del Humanoid. Además, mientras el botón siga apretado, Humanoid.Jump queda en
-- true justo después de que el ControlModule de Roblox lo escriba (prioridad
-- Input) en cada fotograma; puesto una sola vez, el ControlModule lo borra.
-- Igual que el botón de Roblox: mantenerlo apretado sigue saltando.
local JUMP_STEP = "EterniaTouchJump"
local jumpHeld = false

local function getHumanoid(): Humanoid?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return if humanoid and humanoid.Health > 0 then humanoid else nil
end

local function setJumpHeld(pressed: boolean)
	jumpHeld = pressed
	if not pressed then
		RunService:UnbindFromRenderStep(JUMP_STEP)
		return
	end
	local humanoid = getHumanoid()
	if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	RunService:BindToRenderStep(JUMP_STEP, Enum.RenderPriority.Input.Value + 1, function()
		local current = getHumanoid()
		if jumpHeld and current then
			current.Jump = true
		end
	end)
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

	-- Nombre de la habilidad mientras se deja el dedo apretado.
	local bubble = Instance.new("TextLabel")
	bubble.Name = "NameBubble"
	bubble.AnchorPoint = Vector2.new(0.5, 1)
	bubble.AutomaticSize = Enum.AutomaticSize.X
	bubble.Size = UDim2.fromOffset(0, 26)
	bubble.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	bubble.BackgroundTransparency = 0.1
	bubble.Font = Enum.Font.GothamBold
	bubble.TextSize = 14
	bubble.TextColor3 = Color3.new(1, 1, 1)
	bubble.Visible = false
	bubble.ZIndex = 5
	bubble.Parent = holder
	Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 6)
	local bubblePadding = Instance.new("UIPadding")
	bubblePadding.PaddingLeft = UDim.new(0, 8)
	bubblePadding.PaddingRight = UDim.new(0, 8)
	bubblePadding.Parent = bubble

	local function nameOf(slot: number | "Ultimate"): () -> string?
		return function()
			local info = AbilityController.Info(slot)
			return info and info.name
		end
	end

	local attack = makeButton(holder, "Attack", CENTER, ATTACK_SIZE, COLORS.Attack)
	attack.label.Text = "Atacar"
	onHold(attack.button, InputController.SetAttacking)

	local jumpButton = makeButton(holder, "Jump", arc(0, INNER_RADIUS), INNER_SIZE, COLORS.Utility)
	jumpButton.label.Text = "Saltar"
	-- Al tocar, no al soltar: el salto tiene que sentirse inmediato.
	onHold(jumpButton.button, setJumpHeld)

	-- Habilidades 1 a 3 en el primer arco. Las de especialización (4 a 6)
	-- se suman aquí cuando existan.
	local abilities: { [number]: Button } = {}
	for slot, angle in { 28, 56, 84 } do
		local button = makeButton(holder, `Ability{slot}`, arc(angle, INNER_RADIUS), INNER_SIZE, COLORS.Ability)
		onTapOrHold(button, bubble, nameOf(slot), function()
			AbilityController.Use(slot)
		end)
		abilities[slot] = button
	end

	local dodge = makeButton(holder, "Dodge", arc(8, OUTER_RADIUS), OUTER_SIZE, COLORS.Dodge)
	dodge.button.Activated:Connect(DodgeController.Dodge)

	local ultimate = makeButton(holder, "Ultimate", arc(42, OUTER_RADIUS), OUTER_SIZE + 6, COLORS.Ultimate)
	ultimate.stroke.Color = ULTIMATE_COLOR
	onTapOrHold(ultimate, bubble, nameOf("Ultimate"), function()
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
				setIcon(button, info.icon, info.name)
				button.icon.ImageTransparency = if info.remaining >= 1 then 0.6 else 0
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
			-- Cargando: el % encima del ícono apagado. Llena: solo el ícono (o el nombre).
			local percent = `{math.floor(info.charge * 100)}%`
			setIcon(ultimate, info.icon, info.name)
			ultimate.icon.ImageTransparency = if full then 0 else 0.6
			if not full then
				ultimate.label.Text = percent
			end
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
