local Timing = {}
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local pi = math.pi
function Timing.linear(d)
	return function(t)
		return t / d
	end
end
function Timing.easeInQuad(d)
	return function(t)
		return (t / d) ^ 2
	end
end
function Timing.easeOutQuad(d)
	return function(t)
		t = t / d
		return -t * (t - 2)
	end
end
function Timing.easeInOutQuad(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * t ^ 2
		end
		t = t - 1
		return -0.5 * (t * (t - 2) - 1)
	end
end
function Timing.easeInCubic(d)
	return function(t)
		return (t / d) ^ 3
	end
end
function Timing.easeOutCubic(d)
	return function(t)
		t = t / d - 1
		return t * t * t + 1
	end
end
function Timing.easeInOutCubic(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * t ^ 3
		end
		t = t - 2
		return 0.5 * (t ^ 3 + 2)
	end
end
function Timing.easeInQuart(d)
	return function(t)
		return (t / d) ^ 4
	end
end
function Timing.easeOutQuart(d)
	return function(t)
		t = t / d - 1
		return -(t ^ 4 - 1)
	end
end
function Timing.easeInOutQuart(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * t ^ 4
		end
		t = t - 2
		return -0.5 * (t ^ 4 - 2)
	end
end
function Timing.easeInQuint(d)
	return function(t)
		return (t / d) ^ 5
	end
end
function Timing.easeOutQuint(d)
	return function(t)
		t = t / d - 1
		return t ^ 5 + 1
	end
end
function Timing.easeInOutQuint(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * t ^ 5
		end
		t = t - 2
		return 0.5 * (t ^ 5 + 2)
	end
end
function Timing.easeInSine(d)
	return function(t)
		return -cos(t / d * pi / 2) + 1
	end
end
function Timing.easeOutSine(d)
	return function(t)
		return sin(t / d * pi / 2)
	end
end
function Timing.easeInOutSine(d)
	return function(t)
		return -0.5 * (cos(pi * t / d) - 1)
	end
end
function Timing.easeInExpo(d)
	return function(t)
		return 2 ^ (10 * (t / d - 1))
	end
end
function Timing.easeOutExpo(d)
	return function(t)
		return -2 ^ (-10 * t / d) + 1
	end
end
function Timing.easeInOutExpo(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return 0.5 * 2 ^ (10 * (t - 1))
		end
		t = t - 1
		return 0.5 * (-2 ^ (-10 * t) + 2)
	end
end
function Timing.easeInCirc(d)
	return function(t)
		return -(sqrt(1 - (t / d) ^ 2) - 1)
	end
end
function Timing.easeOutCirc(d)
	return function(t)
		t = t / d - 1
		return sqrt(1 - t ^ 2)
	end
end
function Timing.easeInOutCirc(d)
	return function(t)
		t = t * 2 / d
		if t < 1 then
			return -0.5 * (sqrt(1 - t ^ 2) - 1)
		end
		t = t - 2
		return 0.5 * (sqrt(1 - t ^ 2) + 1)
	end
end
function Timing.sineBack(d)
	return function(t)
		return sin(t / d * pi)
	end
end
function Timing.easeInBack(d, s)
	s = s or 1.70158
	return function(t)
		t = t / d
		return t * t * ((s + 1) * t - s)
	end
end
function Timing.easeOutBounce(d)
	return function(t)
		t = t / d
		if t < 0.36363636363636365 then
			return 7.5625 * t * t
		elseif t < 0.7272727272727273 then
			t = t - 0.5454545454545454
			return 7.5625 * t * t + 0.75
		elseif t < 0.9090909090909091 then
			t = t - 0.8181818181818182
			return 7.5625 * t * t + 0.9375
		else
			t = t - 0.9545454545454546
			return 7.5625 * t * t + 0.984375
		end
	end
end
function Timing.cubicBezier(d, p1x, p1y, p2x, p2y)
	p1x = p1x or 0
	p1y = p1y or 0
	p2x = p2x or 1
	p2y = p2y or 1
	local cx = 3 * p1x
	local bx = 3 * (p2x - p1x) - cx
	local ax = 1 - cx - bx
	local cy = 3 * p1y
	local by = 3 * (p2y - p1y) - cy
	local ay = 1 - cy - by
	local epsilon = 1 / (200 * d)
	local function sampleCurveX(t)
		return ((ax * t + bx) * t + cx) * t
	end
	local function sampleCurveY(t)
		return ((ay * t + by) * t + cy) * t
	end
	local function sampleCurveDerivativeX(t)
		return (3 * ax * t + 2 * bx) * t + cx
	end
	local function solveCurveX(x)
		local t0, t1, t2, x2, d2, i
		local fabs = function(n)
			return n >= 0 and n or 0 - n
		end
		t2 = x
		for i = 0, 7 do
			x2 = sampleCurveX(t2) - x
			if fabs(x2) < epsilon then
				return t2
			end
			d2 = sampleCurveDerivativeX(t2)
			if fabs(d2) < 1.0E-6 then
				break
			end
			t2 = t2 - x2 / d2
		end
		t0 = 0
		t1 = 1
		t2 = x
		if t0 > t2 then
			return t0
		elseif t1 < t2 then
			return t1
		end
		while t0 < t1 do
			x2 = sampleCurveX(t2)
			if fabs(x2 - x) < epsilon then
				return t2
			elseif x > x2 then
				t0 = t2
			else
				t1 = t2
			end
			t2 = (t1 - t0) * 0.5 + t0
		end
		return t2
	end
	return function(t)
		return sampleCurveY(solveCurveX(t / d))
	end
end
return Timing