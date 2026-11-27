--!strict
-- Reproduce las poses provisorias de Data/Poses sobre cualquier personaje R15.
-- Cada frame, en PreSimulation (después de que el Animator escribe), multiplica
-- el giro de la pose sobre el Transform de cada articulación. Funciona con
-- AnimationConstraint (rig nuevo) y con Motor6D.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Poses = require(ReplicatedStorage.Shared.Data.Poses)

type Joint = AnimationConstraint | Motor6D

-- Pista de una articulación: momentos y giros (radianes), con 0 al principio y al final.
type Track = { times: { number }, angles: { Vector3 } }

type Playing = {
	tracks: { [string]: Track },
	duration: number,
	speed: number,
	start: number,
	joints: { [string]: Joint },
	-- Si el Animator no escribió este frame (p. ej. está lejos y se salta frames),
	-- se reusa la base anterior para no sumar el giro dos veces.
	lastBase: { [Joint]: CFrame },
	lastWritten: { [Joint]: CFrame },
}

local Poser = {}

local trackCache: { [string]: { [string]: Track } } = {}
local playing: { [Model]: Playing } = {}

local function buildTracks(pose: Poses.PoseDef): { [string]: Track }
	local tracks: { [string]: Track } = {}
	for _, key in pose.Keys do
		for jointName, angles in key.Joints do
			local track = tracks[jointName]
			if not track then
				track = { times = { 0 }, angles = { Vector3.zero } }
				tracks[jointName] = track
			end
			table.insert(track.times, key.Time)
			table.insert(track.angles, Vector3.new(math.rad(angles[1]), math.rad(angles[2]), math.rad(angles[3])))
		end
	end
	for _, track in tracks do
		table.insert(track.times, pose.Duration)
		table.insert(track.angles, Vector3.zero)
	end
	return tracks
end

local function getTracks(poseId: string): { [string]: Track }?
	local cached = trackCache[poseId]
	if cached then
		return cached
	end
	local pose = Poses[poseId]
	if not pose then
		return nil
	end
	local tracks = buildTracks(pose)
	trackCache[poseId] = tracks
	return tracks
end

local function sample(track: Track, t: number): Vector3
	local times = track.times
	for i = 2, #times do
		if t <= times[i] then
			local span = times[i] - times[i - 1]
			local alpha = if span > 0 then (t - times[i - 1]) / span else 1
			-- Suavizado de entrada y salida.
			alpha = alpha * alpha * (3 - 2 * alpha)
			return track.angles[i - 1]:Lerp(track.angles[i], alpha)
		end
	end
	return Vector3.zero
end

local function findJoints(character: Model, tracks: { [string]: Track }): { [string]: Joint }
	local joints: { [string]: Joint } = {}
	for _, descendant in character:GetDescendants() do
		if (descendant:IsA("AnimationConstraint") or descendant:IsA("Motor6D")) and tracks[descendant.Name] then
			joints[descendant.Name] = descendant :: any
		end
	end
	return joints
end

-- Empieza una pose en el personaje. Reemplaza la que estuviera sonando.
function Poser.Play(character: Model, poseId: string, speed: number?)
	local tracks = getTracks(poseId)
	if not tracks then
		warn(`[Poser] Pose desconocida: {poseId}`)
		return
	end
	local previous = playing[character]
	playing[character] = {
		tracks = tracks,
		duration = Poses[poseId].Duration,
		speed = speed or 1,
		start = os.clock(),
		joints = findJoints(character, tracks),
		lastBase = if previous then previous.lastBase else {},
		lastWritten = if previous then previous.lastWritten else {},
	}
end

local function apply(entry: Playing, t: number)
	for jointName, joint in entry.joints do
		if not joint.Parent then
			continue
		end
		local current = joint.Transform
		local base = if current == entry.lastWritten[joint] then entry.lastBase[joint] else current
		local track = entry.tracks[jointName]
		local angles = if track and t < entry.duration then sample(track, t) else Vector3.zero
		local written = CFrame.Angles(angles.X, angles.Y, angles.Z) * base
		joint.Transform = written
		entry.lastBase[joint] = base
		entry.lastWritten[joint] = written
	end
end

RunService.PreSimulation:Connect(function()
	local now = os.clock()
	for character, entry in playing do
		if not character.Parent then
			playing[character] = nil
			continue
		end
		local t = (now - entry.start) * entry.speed
		apply(entry, t)
		if t >= entry.duration then
			playing[character] = nil -- el último frame ya dejó todo en 0
		end
	end
end)

return Poser
