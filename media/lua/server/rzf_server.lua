local timeManager = require('rzf_timeManager')
local zombiesManager = require('rzf_zombiesManager')
local utilities = require('rzf_utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = 'default'

-- Check if presets are actually enabled, expect input as 'dayTime', 'nightTime' or 'rainTime'
local function isPresetEnabled(preset)
    print("[RZF] Checking if preset ", preset, " is a valid preset and if enabled")
    if (preset ~= 'dayTime' and preset ~= 'nightTime' and preset ~= 'rainTime') then
        error("preset not recognized, accepted values are 'dayTime', 'nightTime' or 'rainTime'.")
    end

    if configuration.toggles[preset] then
        return true
    else
        return false
    end
end

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = timeManager.DetectPreset(configuration.schedule)
    -- Check for rain preset being enabled. This check is done earlier to preserve retrocompatibility prior to implement Rain
    if (isPresetEnabled('rainTime')) then
        detectedPreset = timeManager.overrideWithRain(detectedPreset)
    end
    print("[RZF] Schedule detected -> ", detectedPreset)
    -- Check if the preset has changed and is enabled (includes day, night, rain)
    if currentPreset ~= detectedPreset then
        if (isPresetEnabled(detectedPreset)) then
            print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset)
            local zombieDistribution = zombiesManager.activatePreset(configuration[detectedPreset])
            zombiesManager.disable()
            zombiesManager.enable(zombieDistribution, configuration.updateFrequency)
            currentPreset = detectedPreset
        else
            print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset, " but the preset is not enabled.")
            zombiesManager.disable()
            currentPreset = 'default'
        end
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
        -- Todo might be worth adding the check for rain on a separate event that check more often than once every hour?
    end
end

print("[RZF] Starting")
Events.OnGameStart.Add(LoadConfiguration)
Events.OnServerStarted.Add(LoadConfiguration)