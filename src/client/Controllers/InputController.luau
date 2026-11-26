--!strict
-- Controles del jugador. Envía intenciones al servidor; nunca decide el resultado.
-- Por ahora: clic izquierdo = ataque básico. Teclas 1-6, Q y R llegan en la Fase 0.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local InputController = {}

function InputController:Start()
	local useAbility = Remotes.Event("UseAbility")

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			useAbility:FireServer("BasicAttack")
		end
	end)
end

return InputController
