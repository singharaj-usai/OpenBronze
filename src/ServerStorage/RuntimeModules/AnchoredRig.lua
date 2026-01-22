return function(_p)
local Utilities = _p.Utilities

local Tween = Utilities.Tween
local lerpCFrame = Utilities.lerpCFrame

local rig = Utilities.class({
	className = 'AnchoredRig',
	
}, function(model)
	local self = {
		model = model,
		models = {},
	}
	
	return self
end)


--function rig:setRootOrientation(cf)
--	self.rootOrientation = cf - cf.p
--end

function rig:indexModels(...)
	for _, model in pairs({...}) do
		if not self.models[model.Name] then
			local main = model:FindFirstChild('Main') or model:FindFirstChild('Hinge')
			local d = {
				main = main,
				cframe = CFrame.new(),
				cframes = {},
				children = {},
			}
			local mainCF = main.CFrame
			local function index(m)
				for _, part in pairs(m:GetChildren()) do
					if part:IsA('BasePart') and part ~= main then
						d.cframes[part] = mainCF:toObjectSpace(part.CFrame)
					elseif part:IsA('Model') and m ~= self.model then
						index(part)
					end
				end
			end
			index(model)
			self.models[model.Name] = d
		end
	end
end

function rig:connect(model0, model1, orientToRoot)
	self:indexModels(model0, model1)
	local d0, d1 = self.models[model0.Name], self.models[model1.Name]
	d1.parent = d0
	table.insert(d0.children, d1)
	if orientToRoot then
		local root = d0
		while true do
			if not root.parent then break end
			root = root.parent
		end
		local rootCF = root.main.CFrame
		local c1 = rootCF-rootCF.p+d1.main.Position
		d1.rCF = d0.main.CFrame:toObjectSpace(c1)
		d1.rCF1 = c1:toObjectSpace(d1.main.CFrame)
	else
		d1.rCF = d0.main.CFrame:toObjectSpace(d1.main.CFrame)
	end
end

local function resolveChildPose(child, cf)
	if not child.rCF1 then
		return cf * child.rCF * child.cframe
	end
	return cf * child.rCF * child.cframe * child.rCF1
end

function rig:move(model, cf)
	model.main.CFrame = cf
	for part, rcf in pairs(model.cframes) do
		part.CFrame = cf * rcf
	end
	for _, child in pairs(model.children) do
		self:move(child, resolveChildPose(child, cf))
	end
end

local function resolvePose(model, cf)
	if not model.parent then return cf end
	if not model.rCF1 then
		return model.parent.main.CFrame * model.rCF * cf
	end
	return model.parent.main.CFrame * model.rCF * cf * model.rCF1
end

function rig:pose(jointName, cf, t, tfn)
	local model = self.models[jointName]
	if not cf then
		model.thread = nil
		return
	end
	local thisThread = {}
	model.thread = thisThread
	if t then
		local lerp = select(2, lerpCFrame(model.cframe, cf))
		Tween(t, tfn, function(a)
			if model.thread ~= thisThread then return false end
			local cf = lerp(a)
			model.cframe = cf
			self:move(model, resolvePose(model, cf))
		end)
	else
		model.cframe = cf
		self:move(model, resolvePose(model, cf))
	end
end

function rig:poses(...)
	local maxT = 0
	local poses = {...}
	for _, pose in pairs(poses) do
		if pose[3] then
			maxT = math.max(maxT, pose[3])
		end
		Utilities.fastSpawn(function()
			self:pose(unpack(pose))
		end)
	end
	wait(maxT)
end

function rig:reset()
	for name in pairs(self.models) do
		self:pose(name, CFrame.new())
	end
end


function rig:remove()
	pcall(function() self.model:remove() end)
	for _, model in pairs(self.models) do
		model.parent = nil
		model.children = nil
	end
	self.models = nil
end


return rig
end