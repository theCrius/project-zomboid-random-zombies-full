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

  if not (type(SandboxVars.RandomZombiesFull.Crawler_Day) == "number" and
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

  if SandboxVars.RandomZombiesFull.Crawler_Night +
    SandboxVars.RandomZombiesFull.Shambler_Night +
    SandboxVars.RandomZombiesFull.FastShambler_Night +
    SandboxVars.RandomZombiesFull.Sprinter_Night
    ~= 100 then
    error("[RZF] Crawler, Shambler, FastShambler and Sprinter for the Night Settings do not add up to 100")
  end

  if SandboxVars.RandomZombiesFull.Crawler_Day +
    SandboxVars.RandomZombiesFull.Shambler_Day +
    SandboxVars.RandomZombiesFull.FastShambler_Day +
    SandboxVars.RandomZombiesFull.Sprinter_Day
    ~= 100 then
    error("[RZF] Crawler, Shambler, FastShambler and Sprinter for the Day Settings do not add up to 100")
  end

  if SandboxVars.RandomZombiesFull.Crawler_Special +
    SandboxVars.RandomZombiesFull.Shambler_Special +
    SandboxVars.RandomZombiesFull.FastShambler_Special +
    SandboxVars.RandomZombiesFull.Sprinter_Special
    ~= 100 then
    error("[RZF] Crawler, Shambler, FastShambler and Sprinter for the Special Settings do not add up to 100")
  end

  if SandboxVars.RandomZombiesFull.Fragile_Night +
    SandboxVars.RandomZombiesFull.Normal_Night +
    SandboxVars.RandomZombiesFull.Tough_Night
    ~= 100 then
    error("[RZF] Fragile, Normal and Tough for the Night Settings do not add up to 100")
  end

  if SandboxVars.RandomZombiesFull.Fragile_Day +
    SandboxVars.RandomZombiesFull.Normal_Day +
    SandboxVars.RandomZombiesFull.Tough_Day
    ~= 100 then
    error("[RZF] Fragile, Normal and Tough for the Day Settings do not add up to 100")
  end

  if SandboxVars.RandomZombiesFull.Fragile_Special +
    SandboxVars.RandomZombiesFull.Normal_Special +
    SandboxVars.RandomZombiesFull.Tough_Special
    ~= 100 then
    error("[RZF] Fragile, Normal and Tough for the Special Settings do not add up to 100")
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
  configuration.dayTime = {
    crawler = SandboxVars.RandomZombiesFull.Crawler_Day,
    shambler = SandboxVars.RandomZombiesFull.Shambler_Day,
    fastShambler = SandboxVars.RandomZombiesFull.FastShambler_Day,
    sprinter = SandboxVars.RandomZombiesFull.Sprinter_Day,
    fragile = SandboxVars.RandomZombiesFull.Fragile_Day,
    normal = SandboxVars.RandomZombiesFull.Normal_Day,
    tough = SandboxVars.RandomZombiesFull.Tough_Day,
    smart = SandboxVars.RandomZombiesFull.Smart_Day,
  }
  configuration.nightTime = {
    crawler = SandboxVars.RandomZombiesFull.Crawler_Night,
    shambler = SandboxVars.RandomZombiesFull.Shambler_Night,
    fastShambler = SandboxVars.RandomZombiesFull.FastShambler_Night,
    sprinter = SandboxVars.RandomZombiesFull.Sprinter_Night,
    fragile = SandboxVars.RandomZombiesFull.Fragile_Night,
    normal = SandboxVars.RandomZombiesFull.Normal_Night,
    tough = SandboxVars.RandomZombiesFull.Tough_Night,
    smart = SandboxVars.RandomZombiesFull.Smart_Night,
  }
  configuration.specialTime = {
    crawler = SandboxVars.RandomZombiesFull.Crawler_Special,
    shambler = SandboxVars.RandomZombiesFull.Shambler_Special,
    fastShambler = SandboxVars.RandomZombiesFull.FastShambler_Special,
    sprinter = SandboxVars.RandomZombiesFull.Sprinter_Special,
    fragile = SandboxVars.RandomZombiesFull.Fragile_Special,
    normal = SandboxVars.RandomZombiesFull.Normal_Special,
    tough = SandboxVars.RandomZombiesFull.Tough_Special,
    smart = SandboxVars.RandomZombiesFull.Smart_Special,
  }

  return configuration
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

return utilities
