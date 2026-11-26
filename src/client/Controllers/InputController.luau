--!strict
-- Controles del jugador. Envía intenciones al servidor; nunca decide el resultado.
-- Clic izquierdo: ataque básico. Mantenerlo apretado sigue el ritmo del combo
-- (o de los disparos), usando los mismos tiempos que valida el servidor.
-- Teclas 1-6, Q y R llegan más adelante en la Fase 0.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Targeting = require(ReplicatedStorage.Shared.Targeting)
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

function InputController:Start()
	local useAbility = Remotes.Event("UseAbility")

	local holding = false
	local looping = false
	local comboIndex = 0
	local lastSwing = -math.huge

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
			local now = os.clock()
			local elapsed = now - lastSwing
			local wait = if comboIndex > 0 then ability.Hits[comboIndex].Recovery - elapsed else 0
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
