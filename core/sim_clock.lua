-- Persistent simulated time with stable subsecond precision.
-- Floating additions such as 0.1 + ... otherwise miss egg and research
-- deadlines, changing the order of RNG calls relative to shop visitors.
-- Rounding only the fractional second avoids multiplying large game times.
local Clock={}
local SCALE=1000000000
function Clock.snap(value)
 local integral=math.floor(value)
 return integral+math.floor((value-integral)*SCALE+0.5)/SCALE
end
return Clock
