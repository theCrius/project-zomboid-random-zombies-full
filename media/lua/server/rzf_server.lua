local timeManager = require('../shared/rzf_timeManager')
local zombiesManager = require('../shared/rzf_zombiesManager')
local utilities = require('../shared/rzf_utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = ''

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    print("[RZF] In UpdatePreset (Server)")
    local detectedPreset = timeManager.DetectPreset(timeManager.GetStartTime(configuration.schedule), timeManager.GetEndTime(configuration.schedule))
    print("[RZF] Server Preset detected -> ", detectedPreset)
    if currentPreset ~= detectedPreset then
        local zombieDistribution = zombiesManager.activatePreset(configuration[detectedPreset])
        zombiesManager.disable()
        zombiesManager.enable(zombieDistribution, configuration.updateFrequency)
        currentPreset = detectedPreset
    end
end

-- Load configuration from options
local function LoadConfiguration()
    print("[RZF] In LoadConfiguration (Server)")
    utilities.ValidateConfiguration()
    configuration = utilities.LoadConfiguration()

    if type(configuration) ~= 'table' then
        error("[RZF] Configuration is not a table of values")
    else
        UpdatePreset()
        Events.EveryHours.Add(UpdatePreset)
    end
end

-- Initialize the mod
local function Init()
    print("[RZF] In Init (Server)")
    Events.OnServerStarted.Add(LoadConfiguration)
end

print("[RZF] Starting (Server)")
Events.OnGameStart.Add(Init)