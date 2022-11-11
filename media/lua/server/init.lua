local timeManager = require('timeManager')
local zombiesManager = require('zombiesManager')
local utilities = require('utilities')

-- Mod "global" configuration
local configuration = nil
local currentPreset = nil

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = utilities.DetectPreset(timeManager.GetStartTime(configuration.schedule), timeManager.GetEndTime(configuration.schedule))
    if currentPreset ~= detectedPreset then
        zombiesManager.activatePreset(configuration[detectedPreset])
        currentPreset = detectedPreset
    end
end

-- Initialize the mod
local function init()
    utilities.ValidateConfiguration()
    configuration = utilities.LoadConfiguration()
    UpdatePreset()
end

Events.OnGameStart.Add(init);
Events.EveryHours.Add(UpdatePreset)