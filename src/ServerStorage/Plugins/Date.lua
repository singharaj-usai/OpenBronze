print("Date")
local date = {}

local RELEASE_DATE = os.time({
	month = 10,
	day   = 24,
	year  = 2015,
	hour  = 0,
})

local SECONDS_PER_MINUTE = 60
local SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR
local DAYS_PER_WEEK = 7
local DAYS_PER_YEAR = 365

--local getTimeRemote = game:GetService('ReplicatedStorage').Remote.GetWorldTime
local function now()
	return os.time() - 5*SECONDS_PER_HOUR -- CDT
end

local months = {
	--{name,   ndays, no-longer-used},
	{'January',   31, 6},
	{'February',  28, 2},
	{'March',     31, 2},
	{'April',     30, 5},
	{'May',       31, 0},
	{'June',      30, 3},
	{'July',      31, 5},
	{'August',    31, 1},
	{'September', 30, 4},
	{'October',   31, 6},
	{'November',  30, 2},
	{'December',  31, 4},
}

local weekdays = {[0]='Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}

function isLeapYear(yr)
	if yr % 400 == 0 then
		return true
	elseif yr % 100 == 0 then
		return false
	elseif yr % 4 == 0 then
		return true
	end
	return false
end

function twodigit(num)
	num = math.floor(num)
	if num < 10 then
		return '0'..tostring(num)
	end
	return tostring(num)
end

function date:getWeekdayName(currenttime)
	if not currenttime then currenttime = now() end
	return weekdays[(math.floor(currenttime/SECONDS_PER_DAY)+4)%7]
end

function date:getWeekId(currenttime) -- 12b
	if not currenttime then currenttime = now() end
	return math.floor(((currenttime - RELEASE_DATE) / SECONDS_PER_DAY + 6) / DAYS_PER_WEEK)
end

function date:getDayId(currenttime) -- 15b
	if not currenttime then currenttime = now() end
	return math.floor((currenttime - RELEASE_DATE) / SECONDS_PER_DAY)
end

function date:getDate(currenttime)
	if not currenttime then currenttime = now() end
	local monthS, monthN, weekday, day, hour, minute, sec, year = '', 0, '', 0, 0, 0, 0, 1970

	local days = math.ceil(currenttime/SECONDS_PER_DAY)
	local dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	while days > dpy do
		days = days - dpy
		year = year + 1
		dpy = DAYS_PER_YEAR + (isLeapYear(year) and 1 or 0)
	end

	if isLeapYear(year) then
		months[2][2] = 29
	end
	for i, j in ipairs(months) do
		if days > j[2] then
			days = days - j[2]
		else
			monthS = j[1]
			monthN = i
			day = days
			break
		end
	end
	months[2][2] = 28
	local t = currenttime % SECONDS_PER_DAY
	hour = math.floor(t/SECONDS_PER_HOUR)
	minute = math.floor((t%SECONDS_PER_HOUR)/SECONDS_PER_MINUTE)
	sec = t % SECONDS_PER_MINUTE

	--	local dayFig = year%100
	--	dayFig = dayFig + math.floor(dayFig/4)
	--	dayFig = dayFig + day + months[monthN][3]
	--	dayFig = dayFig % 7
	local dayFig = (math.floor(currenttime/SECONDS_PER_DAY)+4)%7
	weekday = weekdays[dayFig]

	local stringed = weekday..', '..monthS..' '..twodigit(day)..', '..tostring(year)..'; '..twodigit(hour)..':'..twodigit(minute)..':'..twodigit(sec)
	--	print(stringed)
	return {
		MonthName = monthS,
		MonthNum = monthN,
		DayOfMonth = day,
		Year = year,
		WeekdayName = weekday,
		WeekdayNum = dayFig,
		Hour = hour,
		Minute = minute,
		Second = sec,
		TimeString = stringed,
	}
end

function date:hasExpired(expirationDate)
	if not expirationDate then return false end
	local currentTime = now()
	return currentTime > expirationDate
end

function date:createExpirationDate(year, month, day, hour, minute)
	return os.time({
		year = year or 2025,
		month = month or 1,
		day = day or 1,
		hour = hour or 0,
		minute = minute or 0
	})
end

return date