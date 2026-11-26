--!strict
-- Arma provisoria según la clase (Data/Feedback.Weapons): piezas simples pegadas
-- a las manos para que cada clase se reconozca y sus golpes se entiendan. Se crea en
-- el servidor para que todos la vean. Se reemplaza por el modelo final del arma.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)

local WEAPON_NAME = "ProvisionalWeapon"
-- La empuñadura queda un poco por delante del centro de la mano (-Z es al frente).
local GRIP_OFFSET = CFrame.new(0, -0.15, -0.3)

local WeaponService = {}

local function newPiece(def: Feedback.WeaponPart, index: number): Part
	local part = Instance.new("Part")
	part.Name = `Piece{index}`
	part.Size = def.Size
	part.Color = def.Color
	part.Material = def.Material or Enum.Material.SmoothPlastic
	part.Shape = def.Shape or Enum.PartType.Block
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
	return part
end

local function equip(player: Player, character: Model)
	local classId = player:GetAttribute("Class")
	local parts = if typeof(classId) == "string" then Feedback.Weapons[classId] else nil
	local existing = character:FindFirstChild(WEAPON_NAME)
	if existing then
		existing:Destroy()
	end
	if not parts then
		return
	end

	local model = Instance.new("Model")
	model.Name = WEAPON_NAME
	for index, def in parts do
		local hand = character:WaitForChild(def.Hand, 10)
		if not hand or not hand:IsA("BasePart") then
			continue
		end
		local piece = newPiece(def, index)
		local joint = Instance.new("Weld")
		joint.Part0 = hand
		joint.Part1 = piece
		joint.C0 = GRIP_OFFSET * def.Offset
		joint.Parent = piece
		piece.Parent = model
	end
	model.Parent = character
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		equip(player, character)
	end)
	player:GetAttributeChangedSignal("Class"):Connect(function()
		if player.Character then
			equip(player, player.Character)
		end
	end)
	if player.Character then
		task.spawn(equip, player, player.Character)
	end
end

function WeaponService:Start()
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return WeaponService
