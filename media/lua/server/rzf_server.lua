local presetManager = require('rzf_presetManager')
local zombiesManager = require('rzf_zombiesManager')
local utilities = require('rzf_utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = 'default'

-- Check if presets are actually enabled, expect input as 'dayTime', 'nightTime' or 'specialTime'
local function isPresetEnabled(preset)
    if (preset ~= 'dayTime' and preset ~= 'nightTime' and preset ~= 'specialTime') then
        error("preset not recognized, accepted values are 'dayTime', 'nightTime' or 'specialTime'.")
    end

    -- all toggles have 1 as the "disabled" option
    if configuration.toggles[preset] ~= 1 then
        return true
    else
        return false
    end
end

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = 'default'
    local detectedTimePreset = presetManager.DetectTimePreset(configuration.schedule)
    -- Check for special preset being enabled. This check is done earlier to preserve retrocompatibility prior to implementing Special presets
    if (isPresetEnabled('specialTime')) then
        detectedPreset = presetManager.OverrideWithSpecial(detectedTimePreset, configuration.toggles.specialTime, configuration.toggles.specialThreshold)
    end
    print("[RZF] Schedule detected is ", detectedPreset)
    print("[RZF] Checking if preset ", detectedPreset, " is enabled")
    if (isPresetEnabled(detectedPreset)) then
        if currentPreset ~= detectedPreset then
            print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset)
            local zombieDistribution = zombiesManager.activatePreset(configuration[detectedPreset])
            zombiesManager.disable()
            zombiesManager.enable(zombieDistribution, configuration.updateFrequency)
            currentPreset = detectedPreset
            print("[RZF] Schedule Preset changed ---> ", currentPreset)
        else
            print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset, ". No change is necessary.")
        end
    else
        print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset, " but the preset is not enabled.")
        zombiesManager.disable()
        currentPreset = 'default'
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
        -- Todo might be worth adding the check for special triggers on a separate event that check more often than once every hour?
    end
end

print("[RZF] Starting")
Events.OnGameStart.Add(LoadConfiguration)
Events.OnServerStarted.Add(LoadConfiguration)