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

return zombiesManager