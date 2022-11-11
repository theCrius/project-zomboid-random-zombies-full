local timeManager = require('timeManager')
local zombiesManager = require('zombiesManager')
local utilities = require('utilities')

-- Default Values from Core
local SPEED_SPRINTER        = 1
local SPEED_FAST_SHAMBLER   = 2
local SPEED_SHAMBLER        = 3
local COGNITION_SMART       = 1
local COGNITION_DEFAULT     = 3
local COGNITION_RANDOM      = 4

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