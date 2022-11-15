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

-- Expect the detectedTimePreset (day/night) and the value of the specialTime (2=Rain,3=Snow,4=Fog), returns the final preset to be activated
timeManager.OverrideWithSpecial = function(detectedPreset, specialTrigger)
	local specialHappening = false
	local specialThreshold = 0.3
	local specialIntensity = 0.0
	local ClimateManager = getClimateManager()

	-- TODO: Allow the user to determine on which intensity these conditions should trigger
	if(specialTrigger == 2) then
		specialIntensity = ClimateManager:getRainIntensity()
		specialHappening = ClimateManager:isRaining()
	elseif(specialTrigger == 3) then
		specialIntensity = ClimateManager:getSnowIntensity()
		specialHappening = ClimateManager:isSnowing()
	elseif (specialTrigger == 4) then
		specialIntensity = ClimateManager:getFogIntensity()
		specialHappening = specialIntensity >= specialThreshold
	else
		print("[RZF] The trigger ID ", specialTrigger ," passed to the overrideWithSpecial is not recognized. Skipping special override.")
	end

	if (specialHappening) then
		detectedPreset = 'specialTime'
	end

	return detectedPreset
end

-- Determine che right preset to use. Return 'nightTime' or 'dayTime'
timeManager.DetectTimePreset = function(schedule)
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
