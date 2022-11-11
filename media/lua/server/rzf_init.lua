local timeManager = require('timeManager')
local zombiesManager = require('zombiesManager')
local utilities = require('utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = ''

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = utilities.DetectPreset(timeManager.GetStartTime(configuration.schedule), timeManager.GetEndTime(configuration.schedule))
    if currentPreset ~= detectedPreset then
        local zombieDistribution = zombiesManager.activatePreset(configuration[detectedPreset])
        zombiesManager.disable()
        zombiesManager.enable(zombieDistribution, configuration.updateFrequency)
        currentPreset = detectedPreset
    end
end

-- Initialize the mod
local function init()
    utilities.ValidateConfiguration()
    configuration = utilities.LoadConfiguration()
    Events.OnServerStarted.Add(UpdatePreset);
    Events.EveryHours.Add(UpdatePreset)
end

Events.OnGameStart.Add(init);