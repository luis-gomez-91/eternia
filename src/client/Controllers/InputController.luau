--!strict
-- Controles del jugador. Envía intenciones al servidor; nunca decide el resultado.
-- Clic izquierdo: ataque básico. Mantenerlo apretado sigue el ritmo del combo
-- (o de los disparos), usando los mismos tiempos que valida el servidor.
-- En pantallas táctiles el botón de ataque llama a SetAttacking (MobileController).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Targeting = require(ReplicatedStorage.Shared.Targeting)
local AbilityController = require(script.Parent.AbilityController)
local FeedbackController = require(script.Parent.FeedbackController)
local TargetController = require(script.Parent.TargetController)

-- Con objetivo fijado a esta distancia extra del alcance, el personaje gira hacia él al golpear.
local FACE_MARGIN = 3

local player = Players.LocalPlayer

local InputController = {}

local function currentBasicAttack(): AbilityData.BasicAttack?
	local classId = player:GetAttribute("Class")
	local class = if typeof(classId) == "string" then Classes[classId] else nil
	return class and AbilityData.Abilities[class.BasicAttack]
end

local holding = false
local startLoop: () -> ()

-- Mantener apretado el ataque básico desde otro control (botón táctil).
function InputController.SetAttacking(pressed: boolean)
	holding = pressed
	if pressed and startLoop then
		task.spawn(startLoop)
	end
end

function InputController:Start()
	local useAbility = Remotes.Event("UseAbility")

	local looping = false
	local comboIndex = 0
	local lastSwing = -math.huge

	-- El combo es de la clase: al cambiarla empieza de nuevo. Si no, un índice
	-- del Warrior (golpe 2 o 3) no existe en un ataque de un solo disparo.
	player:GetAttributeChangedSignal("Class"):Connect(function()
		comboIndex = 0
		lastSwing = -math.huge
	end)

	-- Golpea mientras el botón siga apretado, esperando lo que pide cada golpe.
	local function attackLoop()
		if looping then
			return
		end
		looping = true
		while holding do
			local ability = currentBasicAttack()
			if not ability then
				break
			end
			if AbilityController.IsCasting() then
				task.wait() -- no se ataca mientras se carga un hechizo
				continue
			end
			local now = os.clock()
			local elapsed = now - lastSwing
			local previous = ability.Hits[comboIndex]
			local wait = if previous then previous.Recovery - elapsed else 0
			if wait > 0 then
				task.wait(wait)
				continue
			end
			if elapsed > ability.ComboReset then
				comboIndex = 0
			end
			comboIndex = comboIndex % #ability.Hits + 1
			lastSwing = now
			local target = TargetController.FaceIfWithin(ability.Range + FACE_MARGIN)
			if ability.Kind == "Ranged" and not target then
				-- Sin objetivo fijado: el mismo que elegiría el servidor.
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if root and root:IsA("BasePart") then
					target = Targeting.InCone(root.CFrame, ability.Range, ability.ArcDot)[1]
				end
			end
			useAbility:FireServer("BasicAttack", target)
			FeedbackController.PlayLocal(ability.Hits[comboIndex].Cue, target)
		end
		looping = false
	end
	startLoop = attackLoop

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holding = true
			task.spawn(attackLoop)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holding = false
		end
	end)
end

return InputController
