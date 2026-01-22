print("Animation")
-- abstract singleton object for managing animation stuff
-- see StarterPack.AnimationOverload

local Animation = {
	keyframeReachedEvents = {}
}

function Animation:BindKeyframeReachedEvent(animationName, keyframeName, fn)
	local list = self.keyframeReachedEvents[animationName]
	if not list then
		list = {}
		self.keyframeReachedEvents[animationName] = list
	end
	list[keyframeName] = fn
end

function Animation:UnbindKeyframeReachedEvent(animationName, keyframeName)
	local list = self.keyframeReachedEvents[animationName]
	if not list then return end
	list[keyframeName] = nil
end


return Animation