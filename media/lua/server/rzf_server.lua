local timeManager = require('rzf_timeManager')
local zombiesManager = require('rzf_zombiesManager')
local utilities = require('rzf_utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = ''

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = timeManager.DetectPreset(configuration.schedule)
    print("[RZF] Schedule detected -> ", detectedPreset)
    if currentPreset ~= detectedPreset then
        print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset)
        local zombieDistribution = zombiesManager.activatePreset(configuration[detectedPreset])
        zombiesManager.disable()
        zombiesManager.enable(zombieDistribution, configuration.updateFrequency)
        currentPreset = detectedPreset
        print("[RZF] Schedule Preset changed -> ", currentPreset)
    end
end

-- Load configuration from options
local function LoadConfiguration()
    utilities.ValidateConfiguration()
    configuration = utilities.LoadConfiguration()

    if type(configuration) ~= 'table' then
        error("[RZF] Configuration is not a table of values")
    else
        UpdatePreset()
        Events.EveryHours.Add(UpdatePreset)
    end
end

print("[RZF] Starting")
Events.OnGameStart.Add(LoadConfiguration)
Events.OnServerStarted.Add(LoadConfiguration)