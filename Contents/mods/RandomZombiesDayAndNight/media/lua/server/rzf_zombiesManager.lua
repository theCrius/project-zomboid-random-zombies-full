local utilities = require("rzf_utilities")
local zombiesManager = {}

-- Default Values from Core
local SPEED_DEFAULT         = 2
local SPEED_SPRINTER        = 1
local SPEED_FAST_SHAMBLER   = 2
local SPEED_SHAMBLER        = 3

local COGNITION_DEFAULT     = 2
local COGNITION_DOORS       = 1
local COGNITION_BASIC       = 3

-- Memory 1 - 1250 - Long
-- Memory 2 - 800  - Normal
-- Memory 3 - 500  - Short
-- Memory 4 - 25   - None
-- Memory 5 - ??   - random
local MEMORY_LONG           = 1
local MEMORY_DEFAULT        = 2
local MEMORY_SHORT          = 3
local MEMORY_NONE           = 4
local MEMORY_RANDOM         = 5

local SIGHT_GOOD            = 1
local SIGHT_DEFAULT         = 2
local SIGHT_POOR            = 3
local SIGHT_RANDOM          = 4

local HEARING_GOOD          = 1
local HEARING_DEFAULT       = 2
local HEARING_POOR          = 3
local HEARING_RANDOM        = 3


-- Shared variables for the module
zombiesManager.tickFrequency = 10
zombiesManager.lastTicks = {16, 16, 16, 16, 16}
zombiesManager.lastTicksIdx = 1
zombiesManager.last = getTimestampMs()
zombiesManager.tickCount = 0

zombiesManager.zombieDistribution = {}
zombiesManager.updateFrequency = 1000

-- Check if zombie can actually stand up
zombiesManager.shouldBeStanding = function(zombie)
    return not zombie:isKnockedDown()
        and zombie:getCrawlerType() == 0
        and not zombie:wasFakeDead()
end

zombiesManager.updateSpeed = function(zombie, targetSpeed, actualSpeed)
    local didChange = false
    if actualSpeed ~= targetSpeed then
        utilities.setSandboxVarValue('ZombieLore.Speed', targetSpeed)
        zombie:makeInactive(true)
        zombie:makeInactive(false)
        utilities.setSandboxVarValue('ZombieLore.Speed', SPEED_DEFAULT)
        didChange = true
    end
    return didChange
end

zombiesManager.updateCognition = function(zombie, targetCognition, actualCognition, cognition)
    local didChange = false
    if targetCognition == COGNITION_DOORS and actualCognition ~= COGNITION_DOORS  then
      utilities.setSandboxVarValue('ZombieLore.Cognition', COGNITION_DOORS)
      zombie:DoZombieStats()
      utilities.setSandboxVarValue('ZombieLore.Cognition', COGNITION_DEFAULT)
      didChange = true
    elseif targetCognition == COGNITION_DEFAULT and actualCognition == COGNITION_DOORS then
      utilities.setSandboxVarValue('ZombieLore.Cognition', COGNITION_DOORS)
      while getClassFieldVal(zombie, cognition) == COGNITION_DOORS do
        zombie:DoZombieStats()
      end
      utilities.setSandboxVarValue('ZombieLore.Cognition', COGNITION_DEFAULT)
      didChange = true
    end
    return didChange
end

zombiesManager.updateMemory = function(zombie, targetMemory, actualMemory, memory)
  local didChange = false
  if targetMemory == MEMORY_LONG and actualMemory ~= MEMORY_LONG  then
    utilities.setSandboxVarValue('ZombieLore.Cognition', MEMORY_LONG)
    zombie:DoZombieStats()
    utilities.setSandboxVarValue('ZombieLore.Cognition', MEMORY_DEFAULT)
    didChange = true
  elseif targetMemory == MEMORY_DEFAULT and actualMemory == MEMORY_LONG then
    utilities.setSandboxVarValue('ZombieLore.Cognition', MEMORY_LONG)
    while getClassFieldVal(zombie, memory) == MEMORY_LONG do
      zombie:DoZombieStats()
    end
    utilities.setSandboxVarValue('ZombieLore.Cognition', MEMORY_DEFAULT)
    didChange = true
  end
  return didChange
end

-- Update a single zombie according to parameters passed
zombiesManager.updateZombie = function(zombie, distribution, speedType, cognition, memory, sight, hearing)
    local modData = zombie:getModData()
    local speedTypeVal = getClassFieldVal(zombie, speedType)
    local cognitionVal = getClassFieldVal(zombie, cognition)
    local memoryVal = getClassFieldVal(zombie, memory)
    local sightVal = getClassFieldVal(zombie, sight)
    local hearingVal = getClassFieldVal(zombie, hearing)
    local crawlingVal = zombie:isCrawling()
    local square = zombie:getCurrentSquare()
    local squareXVal = square and square:getX() or 0
    local squareYVal = square and square:getY() or 0

    -- NOTE (RandomZombie - Belette) we have to include X and Y in the check to catch zombies that have been recycled
    -- from _intended_ default state (i.e. RZ happened to assign it to default bucket) to _unintended_
    -- default state (i.e. RZ would not assign it to the default bucket, even though it's the same zombie)
    -- see IsoZombie::resetForReuse and VirtualZombieManager::createRealZombieAlways for more info
    -- local shouldSkip = speedTypeVal == modData.speed
    --                     and cognitionVal == modData.cognition
    --                     and crawlingVal == modData.crawling
    --                     and math.abs(squareXVal - modData.x) <= 20
    --                     and math.abs(squareYVal - modData.y) <= 20
    local shouldSkip = false

    -- NOTE (RandomZombie - Belette) we check for square to avoid crash in Java engine postupdate calls later
    if shouldSkip or (not square) then
      return true
    end

    local zid = utilities.zombieID(zombie)
    local slice = utilities.hashToSlice(zid)

    -- update speed
    if slice < distribution.crawler then
      if not zombie:isCrawling() then
        zombie:toggleCrawling()
        zombie:setCanWalk(false);
        zombie:setFallOnFront(true)
      end
    elseif slice < distribution.shambler then
      zombiesManager.updateSpeed(zombie, SPEED_SHAMBLER, speedTypeVal)
      if zombie:isCrawling() and zombiesManager.shouldBeStanding(zombie) then
        zombie:toggleCrawling()
        zombie:setCanWalk(true);
      end
    elseif slice < distribution.fastShambler then
        zombiesManager.updateSpeed(zombie, SPEED_FAST_SHAMBLER, speedTypeVal)
      if zombie:isCrawling() and zombiesManager.shouldBeStanding(zombie) then
        zombie:toggleCrawling()
        zombie:setCanWalk(true);
      end
    elseif slice < distribution.sprinter then
        zombiesManager.updateSpeed(zombie, SPEED_SPRINTER, speedTypeVal)
      if zombie:isCrawling() and zombiesManager.shouldBeStanding(zombie) then
        zombie:toggleCrawling()
        zombie:setCanWalk(true);
      end
    -- fallback to 'proper zombies' in case something is missed
    else
      zombiesManager.updateSpeed(zombie, SPEED_DEFAULT, speedTypeVal)
      if zombie:isCrawling() and zombiesManager.shouldBeStanding(zombie) then
        zombie:toggleCrawling()
        zombie:setCanWalk(true);
      end
    end

    -- update smart zombies
    if distribution.smart > 0 then
      zid = utilities.hash(zid)
      local slice2 = utilities.hashToSlice(zid)
      if slice2 < distribution.smart then
        zombiesManager.updateCognition(zombie, COGNITION_DOORS, cognitionVal, cognition)
        zombiesManager.updateMemory(zombie, MEMORY_LONG, memoryVal, memory)
      else
        zombiesManager.updateCognition(zombie, COGNITION_DEFAULT, cognitionVal, cognition)
        zombiesManager.updateMemory(zombie, MEMORY_DEFAULT, memoryVal, memory)
      end
    end

    -- update toughness
    if distribution.normal ~= 100 then
      -- Only update health of zombies that are not on fire and not being attacked.
      -- The getAttackedBy() check returns truthy if the last damage the zombie took was from a player...
      -- however if the zombie is on fire, then any fire damage will cause the "AttackedBy" status to expire,
      -- so we need to also check for burning, otherwise burning zombies will regen health.
      -- See https://github.com/theCrius/project-zomboid-random-zombies-full/issues/9 for more info.
      if not zombie:getAttackedBy() and not zombie:isOnFire() then
        zid = utilities.hash(zid)
        local slice3 = utilities.hashToSlice(zid)
        local health = 0.1 * ZombRand(4)
        if slice3 < distribution.fragile  then
          health = health + 0.5
        elseif slice3 < distribution.tough then
          health = health + 1.5
        else
          health = health + 3.5
        end
        zombie:setHealth(health)
      end
    end

    modData.speed = getClassFieldVal(zombie, speedType)
    modData.cognition = getClassFieldVal(zombie, cognition)
    modData.crawling = zombie:isCrawling()
    modData.x = squareXVal
    modData.y = squareYVal

    return false
  end

-- Update all zombies in a cell according to the active distribution
zombiesManager.updateAllZombies = function(zombieDistribution, updateFrequency)
  zombiesManager.tickCount = zombiesManager.tickCount + 1
  if zombiesManager.tickCount % zombiesManager.tickFrequency ~= 1 then
      return
  end
  -- print("[RZF] Updating zombies...")
  zombiesManager.tickCount = 1

  local now = getTimestampMs()
  local diff = now - zombiesManager.last
  zombiesManager.last = now

  local tickMs = diff / zombiesManager.tickFrequency
  zombiesManager.lastTicks[zombiesManager.lastTicksIdx] = tickMs
  zombiesManager.lastTicksIdx = (zombiesManager.lastTicksIdx % 5) + 1
  local totalTicks = 0
  local sumTicks = 0
  for _, v in ipairs(zombiesManager.lastTicks) do
      sumTicks = sumTicks + v
      totalTicks = totalTicks + 1
  end

  local avgTickMs = sumTicks / totalTicks
  zombiesManager.tickFrequency = math.max(2, math.ceil(updateFrequency / avgTickMs))

  local zs = getCell():getZombieList()
  local sz = zs:size()
  -- print("[RZF] Zombies in active cell(s): ", sz)
  local ZombieObj = IsoZombie.new(nil)
  local cognition = utilities.findField(ZombieObj, "public int zombie.characters.IsoZombie.cognition")
  local speedType = utilities.findField(ZombieObj, "public int zombie.characters.IsoZombie.speedType")
  local memory = utilities.findField(ZombieObj, "public int zombie.characters.IsoZombie.memory")
  local sight = utilities.findField(ZombieObj, "public int zombie.characters.IsoZombie.sight")
  local hearing = utilities.findField(ZombieObj, "public int zombie.characters.IsoZombie.hearing")
  local zombieUpdated = 0;
  for i = 0, sz - 1 do
      local z = zs:get(i)
      -- removing this condition to provide 100% accuracy with zombies in the cell and zombies updated
      -- if not (client and z:isRemoteZombie()) then
          zombiesManager.updateZombie(z, zombieDistribution, speedType, cognition, memory, sight, hearing)
          zombieUpdated = zombieUpdated + 1
      -- end
  end
  -- print("[RZF] Zombies updated: ", zombieUpdated)
end

zombiesManager.updateAllZombiesWithParams = function()
  zombiesManager.updateAllZombies(zombiesManager.zombieDistribution, zombiesManager.updateFrequency)
end

-- enable the process of updating the zombies
zombiesManager.enable = function(zombieDistribution, updateFrequency)
  -- print ("[RZF] Override activated with update frequency of ", updateFrequency, " msec")
  local prevTickMs = zombiesManager.lastTicks[((zombiesManager.lastTicksIdx + 3) % 5) + 1]
  zombiesManager.last = getTimestampMs() - prevTickMs*zombiesManager.tickCount
  zombiesManager.zombieDistribution = zombieDistribution
  zombiesManager.updateFrequency = updateFrequency
  Events.OnTick.Add(zombiesManager.updateAllZombiesWithParams)
end

-- disable the process of updating the zombies
zombiesManager.disable = function ()
    Events.OnTick.Remove(zombiesManager.updateAllZombiesWithParams)
end

return zombiesManager