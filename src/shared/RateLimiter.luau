--!strict
-- Límite de llamadas por clave (normalmente un jugador) con "cubeta de fichas":
-- cada clave tiene hasta `burst` fichas, se recuperan `rate` por segundo
-- y cada llamada gasta una. Sin fichas, la llamada se rechaza.

export type RateLimiter = {
	Allow: (self: RateLimiter, key: any) -> boolean,
	Remove: (self: RateLimiter, key: any) -> (),
}

type Bucket = { tokens: number, last: number }

local RateLimiter = {}

function RateLimiter.new(rate: number, burst: number, clock: (() -> number)?): RateLimiter
	assert(rate > 0, "rate debe ser mayor que 0")
	assert(burst >= 1, "burst debe ser al menos 1")
	local now = clock or os.clock
	local buckets: { [any]: Bucket } = {}

	local limiter = {}

	function limiter.Allow(_self: RateLimiter, key: any): boolean
		local t = now()
		local bucket = buckets[key]
		if not bucket then
			bucket = { tokens = burst, last = t }
			buckets[key] = bucket
		else
			bucket.tokens = math.min(burst, bucket.tokens + (t - bucket.last) * rate)
			bucket.last = t
		end
		if bucket.tokens < 1 then
			return false
		end
		bucket.tokens -= 1
		return true
	end

	function limiter.Remove(_self: RateLimiter, key: any)
		buckets[key] = nil
	end

	return (limiter :: any) :: RateLimiter
end

return RateLimiter
