local utilities = {}

-- we want 2^p bits
local P = 16
-- OnlineID defined as a short as of 41.71+
local MAXVALUE = 2^P
local TWO_32 = 2^32

-- Validate the sandbox options' values
utilities.ValidateConfiguration = function()
  if not type(SandboxVars.RandomZombiesFull) == "table" then
    error("[RZF] No RandomZombiesFull table in config")
  end

  if not (
    type(SandboxVars.RandomZombiesFull.Summer_Night_Start) == "number" and
    type(SandboxVars.RandomZombiesFull.Summer_Night_End) == "number" and
    type(SandboxVars.RandomZombiesFull.Autumn_Night_Start) == "number" and
    type(SandboxVars.RandomZombiesFull.Autumn_Night_End) == "number" and
    type(SandboxVars.RandomZombiesFull.Winter_Night_Start) == "number" and
    type(SandboxVars.RandomZombiesFull.Winter_Night_End) == "number" and
    type(SandboxVars.RandomZombiesFull.Spring_Night_Start) == "number" and
    type(SandboxVars.RandomZombiesFull.Spring_Night_End) == "number"
  )
  then
    error("[RZF] Config value is not a number for the Season Night times")
  end

  if not (
    type(SandboxVars.RandomZombiesFull.Crawler_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Shambler_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.FastShambler_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Sprinter_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Fragile_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Normal_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Tough_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Smart_Day) == "number" and
    type(SandboxVars.RandomZombiesFull.Crawler_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Shambler_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.FastShambler_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Sprinter_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Fragile_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Normal_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Tough_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Smart_Night) == "number" and
    type(SandboxVars.RandomZombiesFull.Crawler_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Shambler_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.FastShambler_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Sprinter_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Fragile_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Normal_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Tough_Special) == "number" and
    type(SandboxVars.RandomZombiesFull.Smart_Special) == "number")
  then
    error("[RZF] Config value is not a number for the Night Settings")
  end
end

utilities.LoadConfiguration = function()
  local configuration = {}
  configuration.updateFrequency = SandboxVars.RandomZombiesFull.Frequency
  configuration.toggles = {
    dayTime = SandboxVars.RandomZombiesFull.Enable_Day,
    nightTime = SandboxVars.RandomZombiesFull.Enable_Night,
    specialTime = SandboxVars.RandomZombiesFull.Enable_Special,
    specialThreshold = SandboxVars.RandomZombiesFull.Special_Threshold
  }
  configuration.schedule = {
    summer = {
      startTime = SandboxVars.RandomZombiesFull.Summer_Night_Start,
      endTime = SandboxVars.RandomZombiesFull.Summer_Night_End
    },
    autumn = {
      startTime = SandboxVars.RandomZombiesFull.Autumn_Night_Start,
      endTime = SandboxVars.RandomZombiesFull.Autumn_Night_End
    },
    winter = {
      startTime = SandboxVars.RandomZombiesFull.Winter_Night_Start,
      endTime = SandboxVars.RandomZombiesFull.Winter_Night_End
    },
    spring = {
      startTime = SandboxVars.RandomZombiesFull.Spring_Night_Start,
      endTime = SandboxVars.RandomZombiesFull.Spring_Night_End
    }
  }
  configuration.dayTime = utilities.getValidProbabilities("Day")
  configuration.nightTime = utilities.getValidProbabilities("Night")
  configuration.specialTime = utilities.getValidProbabilities("Special")

  return configuration
end

utilities.movementsEqual100 = {}
utilities.strengthsEqual100 = {}

utilities.getValidProbabilities = function(context)
  local weights = {
    crawler = SandboxVars.RandomZombiesFull["Crawler_" .. context],
    shambler = SandboxVars.RandomZombiesFull["Shambler_" .. context],
    fastShambler = SandboxVars.RandomZombiesFull["FastShambler_" .. context],
    sprinter = SandboxVars.RandomZombiesFull["Sprinter_" .. context],
    fragile = SandboxVars.RandomZombiesFull["Fragile_" .. context],
    normal = SandboxVars.RandomZombiesFull["Normal_" .. context],
    tough = SandboxVars.RandomZombiesFull["Tough_" .. context],
    smart = SandboxVars.RandomZombiesFull["Smart_" .. context],
  }

  local totalMovementWeight = math.max(weights.crawler + weights.shambler + weights.fastShambler + weights.sprinter, 1)
  
  -- Allows precision of up to .001%.
  local crawler = math.floor(100000 * weights.crawler / totalMovementWeight) / 1000
  local shambler = math.floor(100000 * weights.shambler / totalMovementWeight) / 1000
  local fastShambler = math.floor(100000 * weights.fastShambler / totalMovementWeight) / 1000
  local sprinter = math.floor(100000 * weights.sprinter / totalMovementWeight) / 1000

  local totalStrengthWeight = math.max(weights.fragile + weights.normal + weights.tough, 1)

  local fragile = math.floor(100000 * weights.fragile / totalStrengthWeight) / 1000
  local normal = math.floor(100000 * weights.normal / totalStrengthWeight) / 1000
  local tough = math.floor(100000 * weights.tough / totalStrengthWeight) / 1000

  local smart = weights.smart -- Unaffected by this process.

  index = 0

  while crawler + shambler + fastShambler + sprinter < 100 do
    index = (index % 4) + 1

    local nextChunk = math.min(1, 100 - (crawler + shambler + fastShambler + sprinter))

    if index == 1 then
      crawler = crawler + nextChunk
    elseif index == 2 then
      shambler = shambler + nextChunk
    elseif index == 3 then
      fastShambler = fastShambler + nextChunk
    else -- index == 4 so
      sprinter = sprinter + nextChunk
    end
  end

  utilities.movementsEqual100[#utilities.movementsEqual100 + 1] = crawler + shambler + fastShambler + sprinter == 100

  while fragile + normal + tough < 100 do
    index = (index % 3) + 1

    local nextChunk = math.min(1, 100 - (fragile + normal + tough))

    if index == 1 then
      fragile = fragile + nextChunk
    elseif index == 2 then
      normal = normal + nextChunk
    else -- index == 3 so
      tough = tough + nextChunk
    end
  end

  utilities.strengthsEqual100[#utilities.strengthsEqual100 + 1] = fragile + normal + tough == 100

  return {
    crawler = crawler,
    shambler = shambler,
    fastShambler = fastShambler,
    sprinter = sprinter,
    fragile = fragile,
    normal = normal,
    tough = tough,
    smart = smart
  }
end

-- search for function in an object
utilities.findField = function(obj, fname)
  for i = 0, getNumClassFields(obj) - 1 do
    local fn = getClassField(obj, i)
    if tostring(fn) == fname then
      return fn
    end
  end
end

-- Custom made module function
utilities.modulo =  function(a, b)
  return a - math.floor(a/b)*b
end

-- Custom made shiftRight function
utilities.shiftRight = function(a, b)
  while a > 0 and b > 0 do
    a = math.floor(a / 2)
    b = b - 1
  end
  return a
end

-- Return hash of an entity
utilities.hash = function(x)
  -- (x*2654435769 % 2^32) >> (32 - p)
  x = utilities.modulo(x*2654435769, TWO_32)
  return utilities.shiftRight(x, 32-P)
end

-- Custom made hashToSlice
utilities.hashToSlice = function(h)
  return math.floor((h / MAXVALUE) * 10000)
end

-- Return the ZombieId of a Zombie Entity
utilities.zombieID = function(zombie)
  local id = zombie:getOnlineID()
  if id == -1 then
    id = utilities.modulo(zombie:hashCode(), MAXVALUE)
  end

  return utilities.hash(id)
end

utilities.getTableLength = function (table)
  local length = 0
  for _ in pairs(table) do length = length + 1 end
  return length
end

utilities.tableHasValue = function (table, findValue)
  for i, value in pairs(table) do
    if(value == findValue) then
        return true
    end
  end
  return false
end

utilities.getSandboxVarValue = function (name)
  return getSandboxOptions():getOptionByName(name):getValue()
end

utilities.setSandboxVarValue = function (name, value)
  return getSandboxOptions():set(name, value)
end

return utilities
