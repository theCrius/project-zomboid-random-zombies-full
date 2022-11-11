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

return timeManager
