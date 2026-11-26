--!strict
-- Combate validado en servidor. El cliente solo dice "quiero usar X";
-- el servidor elige el objetivo, revisa distancia y ritmo, y aplica el daño.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityData = require(ReplicatedStorage.Shared.Data.Abilities)
local Classes = require(ReplicatedStorage.Shared.Data.Classes)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DamageService = require(script.Parent.DamageService)

-- Margen para el jitter de red entre dos golpes del combo.
local TIMING_TOLERANCE = 0.1
-- Diferencia de altura máxima para pegar cuerpo a cuerpo.
local MAX_HEIGHT_DIFF = 8
-- Clase por defecto hasta que exista la selección de personaje.
local DEFAULT_CLASS = "Warrior"

type ComboState = { index: number, lastSwing: number }

local CombatService = {}

local comboStates: { [Player]: ComboState } = {}

local function getAliveRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil
	end
	return root
end

-- El enemigo vivo más cercano dentro del alcance y del cono frontal.
local function findMeleeTarget(root: BasePart, range: number, arcDot: number): Model?
	local flat = Vector3.new(1, 0, 1)
	local look = root.CFrame.LookVector * flat
	if look.Magnitude < 1e-3 then
		return nil
	end
	look = look.Unit

	local best: Model? = nil
	local bestDist = math.huge
	for _, enemy in CollectionService:GetTagged("Enemy") do
		if not enemy:IsA("Model") or not enemy:IsDescendantOf(workspace) then
			continue
		end
		local health = enemy:GetAttribute("Health")
		if typeof(health) ~= "number" or health <= 0 then
			continue
		end
		local offset = enemy:GetPivot().Position - root.Position
		if math.abs(offset.Y) > MAX_HEIGHT_DIFF then
			continue
		end
		local radius = enemy:GetAttribute("HitRadius")
		local r = if typeof(radius) == "number" then radius else 2
		local horizontal = offset * flat
		local dist = horizontal.Magnitude
		if dist - r > range then
			continue
		end
		-- Si estás encima del objetivo cuenta como de frente.
		if dist > r and horizontal.Unit:Dot(look) < arcDot then
			continue
		end
		if dist < bestDist then
			best = enemy
			bestDist = dist
		end
	end
	return best
end

local function basicAttack(player: Player)
	local root = getAliveRoot(player)
	if not root then
		return
	end

	local classId = player:GetAttribute("Class")
	local class = Classes[if typeof(classId) == "string" then classId else DEFAULT_CLASS]
	local ability = class and AbilityData.Abilities[class.BasicAttack]
	if not ability then
		return -- p. ej. el ataque del Mage todavía no existe
	end

	local state = comboStates[player]
	if not state then
		state = { index = 0, lastSwing = -math.huge }
		comboStates[player] = state
	end

	local now = os.clock()
	local elapsed = now - state.lastSwing
	if state.index > 0 and elapsed < ability.Hits[state.index].Recovery - TIMING_TOLERANCE then
		return -- demasiado pronto: se ignora sin avanzar el combo
	end
	if elapsed > ability.ComboReset then
		state.index = 0
	end
	state.index = state.index % #ability.Hits + 1
	state.lastSwing = now

	-- Un golpe al aire también avanza el combo.
	local target = findMeleeTarget(root, ability.Range, ability.ArcDot)
	if not target then
		return
	end
	local hit = ability.Hits[state.index]
	local crit = math.random() < AbilityData.BaseCritChance
	DamageService.Apply(target, if crit then hit.Damage * 2 else hit.Damage, crit)
end

function CombatService:Start()
	Players.PlayerAdded:Connect(function(player)
		player:SetAttribute("Class", DEFAULT_CLASS)
	end)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("Class", DEFAULT_CLASS)
	end
	Players.PlayerRemoving:Connect(function(player)
		comboStates[player] = nil
	end)

	Remotes.OnServerEvent("UseAbility", function(player: Player, abilityId: unknown)
		if abilityId == "BasicAttack" then
			basicAttack(player)
		end
	end)
end

return CombatService
