local pluginsManager = require("rzf_pluginsManager")
local presetManager = require('rzf_presetManager')
local zombiesManager = require('rzf_zombiesManager')
local utilities = require('rzf_utilities')

-- Mod "global" configuration
local configuration = {}
local currentPreset = 'default'

-- Check if presets are actually enabled, expect input as 'dayTime', 'nightTime' or 'specialTime'
local function isPresetEnabled(presetName)
    local presetFound = false
    local corePresets = presetManager.getAvailablePresets()
    local pluginsPresets = pluginsManager.getAvailablePresets()
    if (utilities.tableHasValue(corePresets, presetName)) then
        -- all toggles have 1 as the "disabled" option
        if configuration.toggles[presetName] ~= 1 then
            presetFound = true
        else
            presetFound = false
        end
    elseif(utilities.tableHasValue(pluginsPresets, presetName)) then
        presetFound = true
    end

    return presetFound
end

-- Check the time and decide which preset to load for the zombies
local function UpdatePreset()
    local detectedPreset = 'default'
    local detectedTimePreset = presetManager.DetectTimePreset(configuration.schedule)
    
    -- Check for special preset being enabled. This check is done earlier to preserve retrocompatibility prior to implementing Special presets
    if (isPresetEnabled('specialTime')) then
        detectedPreset = presetManager.OverrideWithSpecial(detectedTimePreset, configuration.toggles.specialTime, configuration.toggles.specialThreshold)
    else
        detectedPreset = detectedTimePreset
    end
    
    -- Check for plugins and load the activated ones
    if (pluginsManager.arePluginsLoaded()) then
        print("[RZF] Plugins detected - Checking conditions to override")
        detectedPreset = pluginsManager.overrideWithPlugin(detectedPreset)
        configuration[detectedPreset] = pluginsManager.getPresetDatabyName(detectedPreset)
    end
    
    print("[RZF] Schedule detected is ", detectedPreset)
    print("[RZF] Checking if preset ", detectedPreset, " is enabled")
    if (isPresetEnabled(detectedPreset)) then
        if currentPreset ~= detectedPreset then
            print("[RZF] Schedule need to change from ", currentPreset, " to ", detectedPreset)
            local zombieDistribution = presetManager.activatePreset(configuration[detectedPreset])
            if (currentPreset ~= 'default') then
                print("[RZF] Disabling previous preset")
                zombiesManager.disable()
            end
            print("[RZF] Enabling new preset")
            zombiesManager.enable(zombieDistribution, configuration.updateFrequency, configuration.toggles)
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
        if (pluginsManager.getTotalPlugins()) then
            print("[RZF] Plugins activated ", pluginsManager.getTotalPlugins(true), " of a total of ", pluginsManager.getTotalPlugins(), " detected.")
        end
        UpdatePreset()
        Events.EveryHours.Add(UpdatePreset)
        -- Todo might be worth adding the check for special triggers on a separate event that check more often than once every hour?
    end
end

print("[RZF] Starting")
Events.OnGameStart.Add(LoadConfiguration)
Events.OnServerStarted.Add(LoadConfiguration)