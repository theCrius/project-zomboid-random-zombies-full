local presetManager = {}

presetManager.getAvailablePresets = function()
	return {'dayTime', 'nightTime', 'specialTime'}
end

presetManager.GetStartTime = function(timeSchedule)
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

presetManager.GetEndTime = function(timeSchedule)
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

-- Expect the detectedTimePreset (day/night), the value of the specialTime (2=Rain,3=Snow,4=Fog) and the threshold (1,2,3,4). Returns the final preset to be activated.
presetManager.OverrideWithSpecial = function(detectedPreset, specialTrigger, selectedThreshold)
	local specialHappening = false
	local specialThreshold = 0.3
	local specialIntensity = 0.0
	local ClimateManager = getClimateManager()

	if (selectedThreshold == 1) then
		specialThreshold = 0.0
	elseif (selectedThreshold == 2) then
		specialThreshold = 0.3
	elseif (selectedThreshold == 3) then
		specialThreshold = 0.5
	elseif (selectedThreshold == 4) then
		specialThreshold = 0.7
	end

	if (specialTrigger == 2) then
		specialIntensity = ClimateManager:getRainIntensity()
		specialHappening = ClimateManager:isRaining() and specialIntensity >= specialThreshold
	elseif (specialTrigger == 3) then
		specialIntensity = ClimateManager:getSnowIntensity()
		specialHappening = ClimateManager:isSnowing() and specialIntensity >= specialThreshold
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
presetManager.DetectTimePreset = function(schedule)
	local detectedPreset = nil
	local hourOfDay = math.floor(getGameTime():getTimeOfDay());
	local startHour = presetManager.GetStartTime(schedule)
	local endHour = presetManager.GetEndTime(schedule)

	-- print("[RZF] Hour of Day: ", hourOfDay)
	-- print("[RZF] Starting hour for nightTime: ", startHour)
	-- print("[RZF] Ending hour for nightTime: ", endHour)

	if (hourOfDay >= startHour and hourOfDay < endHour) then
		detectedPreset = 'nightTime';
	elseif (hourOfDay >= startHour or hourOfDay < endHour) and startHour > endHour then
		detectedPreset = 'nightTime';
	else
		detectedPreset = 'dayTime';
	end

	return detectedPreset
end

-- return a distribution based on the preset to be activated
presetManager.activatePreset = function(requestedPreset)
    local ZombieDistribution = {}
    ZombieDistribution.crawler = math.floor(100 * requestedPreset.crawler)
    ZombieDistribution.shambler = ZombieDistribution.crawler + math.floor(100 * requestedPreset.shambler)
    ZombieDistribution.fastShambler = ZombieDistribution.shambler + math.floor(100 * requestedPreset.fastShambler)
    ZombieDistribution.sprinter = ZombieDistribution.fastShambler + math.floor(100 * requestedPreset.sprinter)

    ZombieDistribution.fragile = math.floor(100 * requestedPreset.fragile)
    ZombieDistribution.normal = ZombieDistribution.fragile + math.floor(100 * requestedPreset.normal)
    ZombieDistribution.tough = ZombieDistribution.normal + math.floor(100 * requestedPreset.tough)

    ZombieDistribution.smart = math.floor(100 * requestedPreset.smart)

    return ZombieDistribution
end

return presetManager
