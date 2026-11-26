--!strict
-- Arma provisoria en la mano derecha según la clase (Data/Feedback.Weapons):
-- un bloque con forma de espada para que los tajos se entiendan. Se crea en
-- el servidor para que todos la vean. Se reemplaza por el modelo final del arma.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Feedback = require(ReplicatedStorage.Shared.Data.Feedback)

local WEAPON_NAME = "ProvisionalWeapon"
-- La empuñadura queda un poco por delante del centro de la mano (-Z es al frente).
local GRIP_OFFSET = CFrame.new(0, -0.15, -0.3)

local WeaponService = {}

local function newPiece(name: string, size: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
	return part
end

local function weld(part: BasePart, hand: BasePart, offset: CFrame)
	local joint = Instance.new("Weld")
	joint.Part0 = hand
	joint.Part1 = part
	joint.C0 = offset
	joint.Parent = part
end

local function equip(player: Player, character: Model)
	local classId = player:GetAttribute("Class")
	local def = if typeof(classId) == "string" then Feedback.Weapons[classId] else nil
	local existing = character:FindFirstChild(WEAPON_NAME)
	if existing then
		existing:Destroy()
	end
	if not def then
		return
	end
	local hand = character:WaitForChild("RightHand", 10)
	if not hand or not hand:IsA("BasePart") then
		return
	end

	local model = Instance.new("Model")
	model.Name = WEAPON_NAME

	local hilt = newPiece("Hilt", def.HiltSize, def.HiltColor, Enum.Material.Wood)
	weld(hilt, hand, GRIP_OFFSET)
	hilt.Parent = model

	local blade = newPiece("Blade", def.BladeSize, def.BladeColor, Enum.Material.Metal)
	local bladeOffset = def.HiltSize.Z / 2 + def.BladeSize.Z / 2
	weld(blade, hand, GRIP_OFFSET * CFrame.new(0, 0, -bladeOffset))
	blade.Parent = model

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
