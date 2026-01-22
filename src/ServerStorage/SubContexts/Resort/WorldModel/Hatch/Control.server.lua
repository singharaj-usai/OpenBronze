local stepped = game:GetService('RunService').Stepped

local hinge = script.Parent.Hinge
local ocf = hinge.CFrame
local cfs = {}
for _, p in pairs(script.Parent:GetChildren()) do
	if p:IsA('BasePart') and p ~= hinge then
		cfs[p] = hinge.CFrame:toObjectSpace(p.CFrame)
	end
end

local thread
local active = false
local currentAngle = 0
local lastClickTime
local function activate()
	lastClickTime = tick()
	if active then return end
	active = true
	local thisThread = {}
	thread = thisThread
	local st = tick()
	local startAngle = currentAngle
	while true do
		stepped:wait()
		local now = tick()
		local angle = math.min(math.pi/2, startAngle+(now-st)*3)
		if angle ~= currentAngle then
			currentAngle = angle
			local hcf = ocf * CFrame.Angles(angle, 0, 0)
			hinge.CFrame = hcf
			for p, cf in pairs(cfs) do
				p.CFrame = hcf:toWorldSpace(cf)
			end
		end
		if now-lastClickTime > 5 then break end
	end
	active = false
	local st = tick()
	while thisThread == thread do
		local angle = math.max(0, math.pi/2-(tick()-st)*3)
		if angle ~= currentAngle then
			currentAngle = angle
			local hcf = ocf * CFrame.Angles(angle, 0, 0)
			hinge.CFrame = hcf
			for p, cf in pairs(cfs) do
				p.CFrame = hcf:toWorldSpace(cf)
			end
		end
		if angle == 0 then break end
		stepped:wait()
	end
end
script.Parent.HatchButtonClicked.OnServerEvent:connect(activate)