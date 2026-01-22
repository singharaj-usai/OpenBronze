gui = script.Parent
repeat wait() until gui:FindFirstChild("Relay")
relay = gui:FindFirstChild("Relay")
--print("Relay Found!")

gui.Catalog.Search.Changed:connect(function() relay:InvokeServer("Search",gui.Catalog.Search.Text) end)
gui.Catalog.Go.MouseButton1Down:connect(function() relay:InvokeServer("Go")end)
gui.Catalog.Forward.MouseButton1Down:connect(function() relay:InvokeServer("Forward") end)
gui.Catalog.Backward.MouseButton1Down:connect(function() relay:InvokeServer("Backward") end)
gui.Catalog.PerPage.Changed:connect(function() relay:InvokeServer("PerPage",gui.Catalog.PerPage.Text) end)
gui.Catalog.Type.MouseButton1Down:connect(function() relay:InvokeServer("Type") end)
for _,button in pairs(gui.Catalog.TypeList:GetChildren()) do if button.ClassName == "TextButton" then button.MouseButton1Down:connect(function() relay:InvokeServer("TypeChange",button.Name) end) end end
gui.MoreInfo.Close.MouseButton1Down:connect(function() relay:InvokeServer("Close") end)
gui.MoreInfo.Robux.MouseButton1Down:connect(function() relay:InvokeServer("Robux") end)
gui.MoreInfo.Tickets.MouseButton1Down:connect(function() relay:InvokeServer("Tickets") end)
gui.MoreInfo.Take.MouseButton1Down:connect(function() if gui.MoreInfo.Take.Text == "Take" then relay:InvokeServer("Take") end end)
gui.MoreInfo.Wear.MouseButton1Down:connect(function() relay:InvokeServer("Wear") end)

for _,p in pairs (gui.Catalog.Area:GetChildren()) do
	if p.Name ~= "Background" then
		p.Info.MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",p.Name)  end)
		p.Title.MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",p.Name)  end)
		p.Display.MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",p.Name)  end)
	end
end

gui.Catalog.Area.ChildAdded:connect(function(child)child:WaitForChild("Info").MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",child.Name) end) child:WaitForChild("Title").MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",child.Name) end) child:WaitForChild("Display").MouseButton1Down:connect(function() relay:InvokeServer("DisplayMore",child.Name) end) end)

relay:InvokeServer("SizeChange",gui.Catalog.Area.AbsoluteSize)

while wait() do
	relay:InvokeServer("SizeChange",gui.Catalog.Area.AbsoluteSize)
end