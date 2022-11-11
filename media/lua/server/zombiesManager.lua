local utilities = require('utilities')
local zombiesManager = {}

-- return the distribution based on the preset to be activated
zombiesManager.activatePreset = function(requestedPreset)
    local ZombieDistribution = {}
    ZombieDistribution.crawler = math.floor(100 * requestedPreset.crawler)
    ZombieDistribution.shambler = ZombieDistribution.crawler + math.floor(100 * requestedPreset.Shambler)
    ZombieDistribution.fastShambler = ZombieDistribution.shambler + math.floor(100 * requestedPreset.FastShambler)
    ZombieDistribution.sprinter = ZombieDistribution.fastShambler + math.floor(100 * requestedPreset.Sprinter)

    ZombieDistribution.Fragile = math.floor(100 * requestedPreset.Fragile)
    ZombieDistribution.Normal = ZombieDistribution.Fragile + math.floor(100 * requestedPreset.NormalTough)
    ZombieDistribution.Tough = ZombieDistribution.NormalTough + math.floor(100 * requestedPreset.Tough)

    ZombieDistribution.Smart = math.floor(100 * requestedPreset.Smart)

    return ZombieDistribution
end

-- Check for the hashes of zombies' distribution
zombiesManager.hashCheck = function(ZombieDistribution)
    local filename = "RandomZombiesFull-hashcheck-linear.txt"
    local fw = getFileWriter(filename, true, false)
    if not fw then
      error("could not get file writer to " .. (filename or "nil"))
    end
    local zombiesCount = {
      crawler = 0,
      crawlerSmart = 0,
      shambler = 0,
      shamblerSmart = 0,
      fastShambler = 0,
      fastShamblerSmart = 0,
      sprinter = 0,
      sprinterSmart = 0,
      total = 0,
    }
    local distribution = zombiesManager.activatePreset(ZombieDistribution)

    for i=-2^15, 2^15 do
      local h = utilities.hash(i)
      local slice = utilities.hashToSlice(h)
      local hh = utilities.hash(h)
      local slice2 = utilities.hashToSlice(hh)
      local hhh = utilities.hash(hh)

      if slice < distribution.crawler then
        zombiesCount.crawler = zombiesCount.crawler + 1
        if slice2 < distribution.Smart then
          zombiesCount.crawlerSmart = zombiesCount.crawlerSmart + 1
        end
      elseif slice < distribution.shambler then
        zombiesCount.shambler = zombiesCount.shambler + 1
        if slice2 < distribution.Smart then
          zombiesCount.shamblerSmart = zombiesCount.shamblerSmart + 1
        end
      elseif slice < distribution.fastShambler then
        zombiesCount.fastShambler = zombiesCount.fastShambler + 1
        if slice2 < distribution.Smart then
          zombiesCount.fastShamblerSmart = zombiesCount.fastShamblerSmart + 1
        end
      else
        zombiesCount.sprinter = zombiesCount.sprinter + 1
        if slice2 < distribution.Smart then
          zombiesCount.sprinterSmart = zombiesCount.sprinterSmart + 1
        end
      end
      zombiesCount.total = zombiesCount.total + 1

      fw:write(string.format("%d -> %d -> %d -> %d -> %s\r\n", i, h, hh, hhh, tostring(slice)))
    end
    fw:write(string.format(
               "crawler:%.2f%% (%d), shambler:%.2f%%, fastshambler:%.2f%%, sprinter:%.2f%% (%d)\r\n",
               zombiesCount.Crawler*100/zombiesCount.total,
               zombiesCount.Crawler,
               zombiesCount.Shambler*100/zombiesCount.total,
               zombiesCount.FastShambler*100/zombiesCount.total,
               zombiesCount.Sprinter*100/zombiesCount.total,
               zombiesCount.Sprinter))
    fw:write(string.format(
               "[smart] crawler:%.2f%% (%d), shambler:%.2f%% (%d), fastshambler:%.2f%% (%d), sprinter:%.2f%% (%d)\r\n",
               zombiesCount.CrawlerSmart*100/zombiesCount.Crawler,
               zombiesCount.CrawlerSmart,
               zombiesCount.ShamblerSmart*100/zombiesCount.Shambler,
               zombiesCount.ShamblerSmart,
               zombiesCount.FastShamblerSmart*100/zombiesCount.FastShambler,
               zombiesCount.FastShamblerSmart,
               zombiesCount.SprinterSmart*100/zombiesCount.Sprinter,
               zombiesCount.SprinterSmart))
    fw:close()
    print("wrote to " .. filename)

    filename = "RandomZombiesFull-hashcheck-zombies.txt"
    fw = getFileWriter(filename, true, false)
    if not fw then
      error("could not get file writer to " .. (filename or "nil"))
    end
    local zs = getCell():getZombieList()
    for i=0, zs:size() - 1 do
      local zid = utilities.zombieID(zs:get(i))
      local hh = utilities.hash(zid)
      local hhh = utilities.hash(zid)
      fw:write(string.format("%d -> %d -> %d\r\n", zid, utilities.hashToSlice(zid), utilities.hashToSlice(hh), utilities.hashToSlice(hhh)))
    end
    fw:close()
    print("wrote to " .. filename)
  end

return zombiesManager