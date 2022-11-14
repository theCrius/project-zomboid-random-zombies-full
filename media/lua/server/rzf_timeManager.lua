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

timeManager.overrideWithRain = function(detectedPreset)
	local isRaining = RainManager:isRaining()
	-- TODO: Future version might allow different thresholds, for now it's going to be just "it's raining"
	-- local rainIntensity = RainManager:getRainIntensity()
	-- local rainThreshold = 0

	-- check if it's raining. If it is, rain override the time of day presets
	if (isRaining) then
		detectedPreset = 'rainTime'
	end

	return detectedPreset
end

-- Determine che right preset to use. Return 'nightTime' or 'dayTime'
timeManager.DetectPreset = function(schedule)
	local detectedPreset = nil
	local hourOfDay = math.floor(getGameTime():getTimeOfDay());
	local startHour = timeManager.GetStartTime(schedule)
	local endHour = timeManager.GetEndTime(schedule)

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
