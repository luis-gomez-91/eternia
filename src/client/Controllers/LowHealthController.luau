--!strict
-- Aviso de vida baja: los bordes de la pantalla se tiñen de rojo claro y laten
-- mientras la vida propia está en el 30% o menos. Sin texto: se nota de reojo
-- y no tapa el combate. Más fuerte cuanto menos vida queda.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LOW_FRACTION = 0.3
-- Rojo claro del daño recibido (GUIA-VISUAL.md).
local COLOR = Color3.fromRGB(255, 70, 60)
-- Qué parte de la pantalla cubre cada borde.
local EDGE_DEPTH = 0.16
-- Transparencia del fondo con poca vida (más baja = más fuerte) y al borde del 30%.
local STRONGEST = 0.35
local WEAKEST = 0.8
local PULSE_SPEED = 5

local player = Players.LocalPlayer

local LowHealthController = {}

-- Un borde: degradado del color en el canto a nada hacia el centro.
local function edge(parent: Instance, anchor: Vector2, size: UDim2, rotation: number): Frame
	local frame = Instance.new("Frame")
	frame.AnchorPoint = anchor
	frame.Position = UDim2.fromScale(anchor.X, anchor.Y)
	frame.Size = size
	frame.BackgroundColor3 = COLOR
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = rotation
	gradient.Transparency = NumberSequence.new(0, 1)
	gradient.Parent = frame
	return frame
end

function LowHealthController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "LowHealth"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	-- Hasta los cantos reales, también bajo la muesca: no hay nada que tocar.
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.DisplayOrder = -1 -- debajo del resto de la interfaz
	gui.Enabled = false

	local edges = {
		edge(gui, Vector2.new(0, 0), UDim2.fromScale(1, EDGE_DEPTH), 90),
		edge(gui, Vector2.new(0, 1), UDim2.fromScale(1, EDGE_DEPTH), -90),
		edge(gui, Vector2.new(0, 0), UDim2.fromScale(EDGE_DEPTH * 0.6, 1), 0),
		edge(gui, Vector2.new(1, 0), UDim2.fromScale(EDGE_DEPTH * 0.6, 1), 180),
	}
	gui.Parent = player:WaitForChild("PlayerGui")

	RunService.RenderStepped:Connect(function()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local fraction = if humanoid and humanoid.MaxHealth > 0 then humanoid.Health / humanoid.MaxHealth else 1
		local low = humanoid ~= nil and humanoid.Health > 0 and fraction <= LOW_FRACTION
		gui.Enabled = low
		if not low then
			return
		end
		-- 0 en el límite del 30%, 1 casi sin vida.
		local severity = 1 - fraction / LOW_FRACTION
		local base = WEAKEST + (STRONGEST - WEAKEST) * severity
		local pulse = 0.12 * (0.5 + 0.5 * math.sin(os.clock() * PULSE_SPEED))
		for _, frame in edges do
			frame.BackgroundTransparency = math.clamp(base + pulse, 0, 1)
		end
	end)
end

return LowHealthController
