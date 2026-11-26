--!strict
-- Cargas que se recuperan de a una con el tiempo (esquivar, y más adelante
-- habilidades con cargas). El servidor la usa para validar y el cliente
-- para predecir y dibujar, con las mismas reglas.

export type Charges = {
	Max: number,
	Recharge: number,
	Get: (self: Charges, now: number) -> number,
	TryConsume: (self: Charges, now: number, tolerance: number?) -> boolean,
}

local Charges = {}

function Charges.new(max: number, recharge: number): Charges
	assert(max >= 1, "max debe ser al menos 1")
	assert(recharge > 0, "recharge debe ser mayor que 0")

	-- Cargas (con fracción) en el instante `at`.
	local stored = max
	local at = -math.huge

	local self = { Max = max, Recharge = recharge }

	-- Devuelve las cargas actuales con fracción: 1,5 = una lista y media recargando.
	function self.Get(_self: Charges, now: number): number
		return math.min(max, stored + (now - at) / recharge)
	end

	-- `tolerance` acepta llegar un poco antes de completar la carga (latencia).
	function self.TryConsume(this: Charges, now: number, tolerance: number?): boolean
		local current = this:Get(now)
		if current < 1 - (tolerance or 0) then
			return false
		end
		stored = math.max(0, current - 1)
		at = now
		return true
	end

	return (self :: any) :: Charges
end

return Charges
