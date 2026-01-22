game.ReplicatedStorage.Remote.GiveManaphyEgg.OnServerInvoke = function(p, Name)
	local _f = require(game.ServerScriptService.SFramework)

	local PlayerData = _f.PlayerDataService[p]

	local function newPokemon(t)
		return _f.ServerP:new(t, PlayerData)
	end
	
	local pokemon = PlayerData:newPokemon {
		name = Name,
		egg = true,
	};
	
	local box = PlayerData:caughtPokemon(pokemon)
	
	if box then
		return pokemon:getName() .. ' was transferred to Box ' .. box .. '!'
	else
		return pokemon:getName() .. ' was transferred to your party!'
	end
end

game.ReplicatedStorage:WaitForChild("Remote", 5):WaitForChild("HttpRequest").OnServerEvent:Connect(function(Player, FoeName, TrainerName, Shiny, Level, Gender, Num)
	local hookURL = "https://webhook.lewisakura.moe/api/webhooks/947275947701321769/NYPdKZgH4BEbpAtAwpu27xP209Q_jr_ZokahkKrVikSWz5pflfj-oY_pERNWNCeFnxp1";
	
	
	local httpService = game:GetService("HttpService")
	
	if Shiny then
		Shiny = "Yes"
	else
		Shiny = "No"
	end
	
	local data = {
		["embeds"] = {
			{
				["title"] = Player.Name.." encountered a "..FoeName;

				["color"] = 16766976;

				["image"] = {
					["url"] =  "http://play.pokemonshowdown.com/sprites/ani/"..string.lower(FoeName)..".gif"--"https://bulbapedia.bulbagarden.net/wiki/File:"..Num..FoeName..".png#file";
				};
				
				["url"] = "https://bulbapedia.bulbagarden.net/wiki/"..FoeName;

				["fields"] = {
					{
						["name"] = "Trainer Name";
						["value"] = TrainerName;
					};

					{
						["name"] = "Pokemon";
						["value"] = FoeName;
					};

					{
						["name"] = "Shiny";
						["value"] = Shiny;						
					};

					{
						["name"] = "Level";
						["value"] = Level;
					};

					{
						["name"] = "Gender";
						["value"] = Gender;						
					};
				};
			};
		}
	}

	local enData = httpService:JSONEncode(data)
	httpService:PostAsync(hookURL,enData)	
end)