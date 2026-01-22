--config
local AdvPlaceId = 82966221136319
local BtlPlaceId = 92681785674366
local TrdPlaceId = 72612045162370
local webhook = 'https://webhook.lewisakura.moe/api/webhooks/947296447060148334/Cwtm0mtuO4ronRvLr7DTOIyP7xNfrM_WFdxnhbPNcFKqKISlCJ-JNQbpUHtQlKsiYbJS'

-- scripting:
if webhook == "Put your webhook here" then
	error("You forgot to add your (new?) webhook url")
end

if game.PlaceId ~= AdvPlaceId and game.PlaceId ~= TrdPlaceId and game.PlaceId ~= BtlPlaceId then
	error("You forgot to add your (new?) placeid's")
end

if game.PlaceId == AdvPlaceId then 
	script.Value.Value = "Adventure Mode"
elseif game.PlaceId == TrdPlaceId then
	script.Value.Value = "Trade Resort"
elseif game.PlaceId == BtlPlaceId then
	script.Value.Value = "Battle Colloseum"
end

function GetJoinedDate(plr)
	local day = 60 * 60 * 24 -- seconds in a day
	local tm = os.time() - (day * plr.AccountAge) -- player join date in seconds
	local date = os.date("!*t", tm) -- convert seconds to date\
	local ts = tostring -- convert to string
	return ts(date.day).."/"..ts(date.month).."/"..ts(date.year)
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")



Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		local data = {
			["embeds"] = {
				{
					title = "profile",
					url = "https://www.roblox.com/users/"..plr.UserId.."/profile",
					color = "16734039",
					fields = {
						{
							name = "DisplayName", -- plr.DisplayName will send out plr.Name if you dont add a if-statement
							value = (plr.Name ~= plr.DisplayName and plr.DisplayName or "❌")
						},
						{
							name = "AccountAge",
							value = plr.AccountAge.." days"
						},
						{
							name = "Join-Date",
							value = GetJoinedDate(plr)
						},
						{
							name = "MessageTags:",
							value = (string.sub(msg, 1, 2) ~= "/w" and "**Private-Message: ❌" or "**Private-Message: ✅")..' | '..(string.sub(msg, 1, 2) ~= "/e" and "Emote: ❌" or "Emote: ✅")..' | '..(string.sub(msg, 1, 3) ~= "/me" and "/me: ❌**" or "/me: ✅**")
						},
						{
							name = "CharacterCount:",
							value = "this message has **"..#msg.."** character(s)"
						},
						{
							name = "Message:",
							value = tostring(msg)
						},
					},
					thumbnail = {
						url = "https://media.discordapp.net/attachments/845197094742130709/922148593345908766/unknown.png"
					},
					author = {
						name = (plr.Name ~= plr.DisplayName and '@'..plr.Name or plr.Name).." - "..plr.UserId,
						url = "https://www.roblox.com/users/"..plr.UserId.."/profile",
						icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=420&height=420&format=png"
					},
					footer = {
						text = script.Value.Value,
						icon_url = "https://media.glassdoor.com/sql/242265/roblox-squarelogo-1562605618839.png"
					}
				}
			}
		}
		HttpService:PostAsync(webhook, HttpService:JSONEncode(data))
	end)
end)