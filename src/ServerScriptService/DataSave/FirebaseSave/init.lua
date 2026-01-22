-- Not trello but no one cares

local HttpService = game:GetService("HttpService");
local FirebaseService = require(script.FirebaseService);
local database = FirebaseService:GetFirebase("Saves");

local mod = {
	["DataSave"] = function(ID, Data) -- RE ADD _
		--print(ID)
		--print(Data)
		
		database:SetAsync(ID, Data);
	end;
	
	["DataLoad"] = function(ID)
		--print(ID)
		
		return database:GetAsync(ID)
	end;
};

return mod