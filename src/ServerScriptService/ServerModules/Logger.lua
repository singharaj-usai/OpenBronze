local logger = {
	Template = {
		fields = {},
		author = {
			name = "Project Bronze",
		},
		thumbnail = {
			url = "https://imgur.com/H1VO6Jv.gif" --  Still Image: 1i48tb2.png
		},
		footer = { -- don't remove ples
			text = "PBB Logs 🪵 | mrbobbilly",
			icon_url = "https://imgur.com/Z1h372o.png"
		},
	},
	hooks = {
		trade = "https://webhook.lewisakura.moe/api/webhooks/947296447060148334/Cwtm0mtuO4ronRvLr7DTOIyP7xNfrM_WFdxnhbPNcFKqKISlCJ-JNQbpUHtQlKsiYbJS",
		encounter = "https://webhook.lewisakura.moe/api/webhooks/947296447060148334/Cwtm0mtuO4ronRvLr7DTOIyP7xNfrM_WFdxnhbPNcFKqKISlCJ-JNQbpUHtQlKsiYbJS",

	}
}

local http = game:GetService("HttpService")
local natures = {
	'Hardy', 'Lonely', 'Brave', 
	'Adamant', 'Naughty', 'Bold', 
	'Docile', 'Relaxed', 'Impish', 
	'Lax', 'Timid', 'Hasty', 
	'Serious', 'Jolly', 'Naive', 
	'Modest', 'Mild','Quiet',
	'Bashful','Rash','Calm',
	'Gentle','Sassy','Careful',
	'Quirky'
} 

local function isArray(t: table)
	if not (typeof(t) == 'table') then return false end -- not a table
	local i = 0
	if #t == 0 then
		for n in next, t do
			i += 1
			if i >= 1 then break end
		end
		if i >= 1 then return 'dictionary' end
	end
	return true
end

local function convertVar(var)
	local arrayType = isArray(var)

	if type(var) == "string" then
		return '"'..var..'"'
	elseif type(var) == "number" then
		return tostring(var)
	elseif type(var) == "boolean" then
		return tostring(var)
	elseif var.ClassName then

		if var.ClassName == "DataModel" then
			return "game"
		end

		local str, o = "", var

		repeat
			str = "."..o.Name..str
			o = o.Parent
			wait(.1)
		until o.ClassName == "DataModel"

		str = "game"..str

		return str
	elseif arrayType == true then
		local str = "{"

		for i=1, #var do
			str = str..convertVar(var[i])..(i == #var and "" or ",")
		end
		str = str.."}"
		return str
	elseif arrayType == 'dictionary' then
		local str = "{"
		for k, v in pairs(var) do
			str = str.."["..convertVar(k).."] = "..convertVar(v)..","
		end
		str = str.."}"
		return str
	end
end

local function getBool(val)
	return val and "Yes" or "No"
end

local function getPlrStr(plr, noBold)
	return "["..(noBold and "" or "**")..plr.Name..(noBold and "" or "**").."](https://www.roblox.com/users/"..plr.UserId..")"
end

local function getTimeStamp()
	local t = os.date("*t", os.time())
	
	local function handle2Digit(s)
		if string.len(s) == 1 then return "0"..s end
		return s
	end
	
	local date = t.year.."-"..handle2Digit(t.month).."-"..handle2Digit(t.day)
	local t = handle2Digit(t.hour)..":"..handle2Digit(t.min)..":"..handle2Digit(t.sec)

	return date.."T"..t..".000Z"
end

function logger:getTemplate(val)
	local function copy(tblr)
		local t = {}
		for k, v in pairs(tblr) do
			if type(v) == "table" then
				t[k] = copy(v)
			else
				t[k] = v
			end
		end
		return t
	end
	
	local template = copy(self.Template)
	local fns = {
		obj = template
	}
	
	if val then
		template.title, template.color, template.description = unpack(val)
	end
	
	template.timestamp = getTimeStamp()
	
	function fns:addFeild(n, v, i)
		table.insert(template.fields, {
			name = n  or "** **",
			value = v or "** **",
			inline = i and true or false,
		})
	end
	
	return val and fns or template
end

function logger:logTrade(info)
	local embed = self:getTemplate({
		"Trade Logs",
		41983,
	})

	local function TorF(val)
		return val and "T" or "F"
	end

	local function calcIVs(ivs)
		local num = 0
		
		for i, stat in pairs(ivs) do
			if stat == 31 then
				num += 1
			end
		end

		return num.."x31"
	end
	
	local desc = ""
	
	for i, data in pairs(info) do
		local plr = data.p
		desc = desc.."**----------| 🤝 | "..getPlrStr(plr, true).."'s Offer | 🤝 |----------**\n\n"
		if #data.offer > 0 then
			for i=1, #data.offer do
				local poke = data.offer[i]
				desc ..= "> **"..poke.name.."**" 
				desc ..= "| "..poke.level.." |(" 
				desc ..= "Ha: "..TorF(poke.hiddenAbility)..", " 
				desc ..= "Shiny: "..TorF(poke.shiny)..", "
				desc ..= "Item: "..(poke.item or "None")..", "
				desc ..= "IVs: "..calcIVs(poke.ivs)
				desc ..= ")\n"
			end
		else
			desc = desc.."> **None**\n"
		end
		
		desc = desc.."\n"
	end

	embed.obj.description = desc

	http:PostAsync(self.hooks.trade,http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logPanel(plr, info)
	local texts = {
		["Item"] = "an item",
		["Currency"] = "a currency",
		["Pokémon"] = "a pokemon"
	}
	local embed = self:getTemplate({
		"Panel Logs | "..info.spawner.. " Spawner",
		255,
		getPlrStr(plr).." spawned "..texts[info.spawner]..(info.forPlr and  " for "..getPlrStr(info.forPlr) or "").."."
	})
	
	local function doStats(s)	
		local str = ""
		local statNames = {
			"Health",
			"Attack", "Defense",
			"Sp. Attack", "Sp. Defense",
			"Speed"
		}
		
		for i=1, 6 do
			str = str..statNames[i].." | "..s[i]..(i ~= 6 and "\n" or "")
		end
		
		return str
	end
	
	embed:addFeild("----------| 🍨 | Basic | 🍨 |----------")
	
	if info.spawner == "Item" then
		embed:addFeild("Item", info.item, true)
		embed:addFeild("Amount", info.amount, true)
	elseif info.spawner == "Currency" then
		embed:addFeild("Type", info.cur, true)
		embed:addFeild("Amount", info.qty, true)
	else
		local data = info.details

		embed:addFeild("Pokemon", data.name..(data.forme and " ("..data.forme..")" or ""), true)
		embed:addFeild("Level", data.level, true)
		embed:addFeild()
		embed:addFeild("Item", data.item ~= "" and data.item or "None", true)
		embed:addFeild("Nature", natures[data.nature], true)
		embed:addFeild("----------| 🎌 | Flags | 🎌 |----------")
		embed:addFeild("Shiny", getBool(data.shiny), true)
		embed:addFeild("Hidden Ability", getBool(data.hiddenAbility), true)
		embed:addFeild()
		embed:addFeild("Egg", getBool(data.eg), true)
		embed:addFeild("Untradable", getBool(data.untradable), true)
		embed:addFeild("----------| 🔢 | Stats | 🔢 |----------")
		embed:addFeild("IVs", doStats(data.ivs), true)
		embed:addFeild("EVs", doStats(data.evs), true)
		
		
		embed.obj.image = {
			url = "https://play.pokemonshowdown.com/sprites/"..(data.shiny and "ani-shiny" or "ani").."/"..string.lower(data.name)..".gif"
		}
	end
	
	embed:addFeild("------------------------------------------")
	
	http:PostAsync(self.hooks.panel,http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logRoulette(plr, info)
	local embed = self:getTemplate({
		"Roulette Logs",
		65280,
		"["..plr.Name.."](https://www.roblox.com/users/"..plr.UserId..") rolled the Pokémon roulette,"
	})
	
	local data = info.won
	
	embed:addFeild("-----------| 🧻 | Info | 🧻 |-----------")
	embed:addFeild("Roulette Type", info.tier, true)
	embed:addFeild("--------| 💰 | Winnings | 💰 |--------")
	embed:addFeild("Pokemon", data.name..(data.forme and " ("..data.forme..")" or ""), true)
	embed:addFeild("Shiny", getBool(data.shiny), true)
	embed:addFeild("Hidden Ability", getBool(data.hiddenAbility), true)
	embed:addFeild("------------------------------------------")
	
	embed.obj.image = {
		url = "https://play.pokemonshowdown.com/sprites/"..(data.shiny and "ani-shiny" or "ani").."/"..string.lower(data.name)..".gif"
	}
	
	http:PostAsync(self.hooks.roulette,http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logExploit(plr, info)
	local embed = self:getTemplate({
		"Exploit Log",
		16711680,
		getPlrStr(plr).." was logged for potential exploiting."
	})
	
	embed:addFeild("-----------| 💥 | Info | 💥 |-----------")
	embed:addFeild("Exploit Type", info.exploit, true)
	embed:addFeild("Extra Info", info.extra or "Not given.", true)
	embed:addFeild("------------------------------------------")

	http:PostAsync(self.hooks.exploit,http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logEncounter(plr, info)	
	local embed = self:getTemplate({
		"Encounter Logs",
		41983,
		getPlrStr(plr).." found a special Pokemon!"
	})
	
	local data = info.details
	
	embed:addFeild("----------| ☕ | Info | ☕ |-----------")
	embed:addFeild("Gamemode", info.data.gamemode or "normal", true)
	embed:addFeild("Capture Chain", info.data.chain, true)
	embed:addFeild("-------| 👾 | Poke Data | 👾 |-------")
	embed:addFeild("Pokemon", data.name..(data.forme and " ("..data.forme..")" or ""), true)
	embed:addFeild("Level", data.level, true)
	embed:addFeild()
	embed:addFeild("Shiny", getBool(data.shiny), true)
	embed:addFeild("Hidden Ability", getBool(data.hiddenAbility), true)

	embed.obj.image = {
		url = "https://play.pokemonshowdown.com/sprites/"..(data.shiny and "ani-shiny" or "ani").."/"..string.lower(data.name)..".gif"
	}
	
	http:PostAsync(self.hooks.encounter,http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logError(plr, info)
	local embed = self:getTemplate({
		"Error Logs",
		16745728,
		((type(plr) == "table" and plr.IsServer) and "The Server" or getPlrStr(plr)).." encountered an error..."
	})
	
	embed:addFeild("-----------| 🚧 | Info | 🚧 |-----------")
	embed:addFeild("Error Type", info.ErrType, true)
	embed:addFeild("Extra Info", info.Errors or "Not given.", true)
	embed:addFeild("------------------------------------------")

	http:PostAsync(self.hooks.errors, http:JSONEncode({
		embeds = {embed.obj}
	}))
end

function logger:logRemote(plr, info)	
	local susUsers = {
		["114252431"] = "Karma", 
		["112091162"] = "Albern",
		["12171767"] = "FaithV2",
		["230509563"] = "MrRoger_Noob", -- [Can we find a way to update this remote log without updating module every time?] --  4/25/23
		["4546371114"] = "Roger\'s Alt",
		--["3881398035"] = "BGC (Testing)"
	}
	local sus = susUsers[tostring(plr.UserId)]
	
	if sus then
		local embed = self:getTemplate({
			"Remote Logs",
			16776960,
			getPlrStr(plr).." (aka "..sus..")  was remote logged."
		})
		
		embed:addFeild("-----------| ⚡ | Info | ⚡ |-----------")
		embed:addFeild("Remote Type", info.called, true)
		embed:addFeild("Func Name", info.fnName, true)
		embed:addFeild("Arguments", convertVar(info.args), true)
		embed:addFeild("------------------------------------------")

		http:PostAsync(self.hooks.remote,http:JSONEncode({
			embeds = {embed.obj}
		}))
	end
end

function logger:logIllegal(plr, info)
	local embed = self:getTemplate({
		"Legality Logs",
		16711422,
		getPlrStr(plr).." was logged for an Illegal pokemon: "..info.pName.."."
	})

	embed:addFeild("----------| ⛔ | Info | ⛔ |-----------")
	embed:addFeild("Type", info.type, true)
	embed:addFeild("Action Taken", info.action, true)
	embed:addFeild()
	embed:addFeild("Extra Info", info.extra, true)
	embed:addFeild("Poke Hash", info.hash, true)

	http:PostAsync(self.hooks.illegal, http:JSONEncode({
		embeds = {embed.obj}
	}))
end

return logger
