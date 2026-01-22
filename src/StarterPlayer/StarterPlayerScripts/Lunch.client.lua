local rs = game:GetService('ReplicatedStorage')
local d = rs.Remote.Launch:InvokeServer()
rs.Remote.Launch:remove()
d.Parent = game:GetService('Players').LocalPlayer
require(d)
d:remove()
script:remove()