--!strict
-- Barra de definitiva (tecla R). Se llena con el daño que hace el jugador, lo
-- que cura y lo que recibe (ver Data/Abilities: UltimateFill). Vive en el
-- atributo UltimateCharge del jugador, de 0 a 1, para que el cliente la dibuje.
-- No se pierde al morir ni al cambiar de clase.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local DamageService = require(script.Parent.DamageService)

local ATTRIBUTE = "UltimateCharge"

local UltimateService = {}

local function getCharge(player: Player): number
	local value = player:GetAttribute(ATTRIBUTE)
	return if typeof(value) == "number" then value else 0
end

local function addPoints(player: Player?, points: number)
	if player and player.Parent and points > 0 then
		player:SetAttribute(ATTRIBUTE, math.min(1, getCharge(player) + points / AbilityData.UltimateFill))
	end
end

function UltimateService.IsFull(player: Player): boolean
	return getCharge(player) >= 1
end

function UltimateService.Consume(player: Player)
	player:SetAttribute(ATTRIBUTE, 0)
end

function UltimateService:Start()
	for _, player in Players:GetPlayers() do
		player:SetAttribute(ATTRIBUTE, getCharge(player))
	end
	Players.PlayerAdded:Connect(function(player)
		player:SetAttribute(ATTRIBUTE, 0)
	end)

	DamageService.OnDamaged(function(_target, dealt, source)
		addPoints(source, dealt)
	end)
	DamageService.OnHealed(function(_character, healed, source)
		addPoints(source, healed)
	end)
	DamageService.OnPlayerHurt(function(character, dealt)
		addPoints(Players:GetPlayerFromCharacter(character), dealt * AbilityData.UltimateTakenWeight)
	end)
end

return UltimateService
