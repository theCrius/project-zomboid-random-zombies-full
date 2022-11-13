local timeManager = {}

timeManager.GetStartTime = function(timeSchedule)
    local currentMonth = GameTime:getInstance():getMonth();
	if currentMonth >= 2 and currentMonth <= 4 then
		return timeSchedule.spring.startTime
	elseif currentMonth >= 5 and currentMonth <= 7 then
		return timeSchedule.summer.startTime
	elseif currentMonth >= 8 and currentMonth <= 10 then
		return timeSchedule.autumn.startTime
	end
	return timeSchedule.winter.startTime
end

timeManager.GetEndTime = function(timeSchedule)
    local currentMonth = GameTime:getInstance():getMonth();
	if currentMonth >= 2 and currentMonth <= 4 then
		return timeSchedule.spring.endTime
	elseif currentMonth >= 5 and currentMonth <= 7 then
		return timeSchedule.summer.endTime
	elseif currentMonth >= 8 and currentMonth <= 10 then
		return timeSchedule.autumn.endTime
	end
	return timeSchedule.winter.endTime
end

-- Determine che right preset to use. Return 'nightTime' or 'dayTime'
timeManager.DetectPreset = function(schedule)
	local detectedPreset = nil
	local hourOfDay = math.floor(getGameTime():getTimeOfDay());
	local startHour = timeManager.GetStartTime(schedule)
	local endHour = timeManager.GetEndTime(schedule)

	print("[RZF] Night starts at ", startHour)
	print("[RZF] Night ends at ", endHour)
	print("[RZF] Current time is ", hourOfDay)

	if (hourOfDay >= startHour and hourOfDay < endHour) then
		detectedPreset = 'nightTime';
	elseif (hourOfDay >= startHour or hourOfDay < endHour) and startHour > endHour then
		detectedPreset = 'nightTime';
	else
		detectedPreset = 'dayTime';
	end

	return detectedPreset
  end

return timeManager
