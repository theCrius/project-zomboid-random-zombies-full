local utilities = require('rzf_utilities')
local presetManager = require('rzf_presetManager')

-- Global table for plugins
RZF_PLUGINS = RZF_PLUGINS or {}

local pluginsManager = {}

local function getPlugins()
    local totalPlugins = {}
    for i, pluginData in pairs(RZF_PLUGINS) do
        table.insert(totalPlugins, pluginData)
    end

    return totalPlugins
end

local function getEnabledPlugins()
    local activePlugins = {}
    for i, pluginData in pairs(RZF_PLUGINS) do
        if(pluginData.enabled) then
            table.insert(activePlugins, pluginData)
        end
    end

    return activePlugins
end

pluginsManager.getTotalPlugins = function(onlyActivated)
    onlyActivated = onlyActivated or false
    if (onlyActivated) then
        return utilities.getTableLength(getEnabledPlugins())
    else
        return utilities.getTableLength(getPlugins())
    end
end

pluginsManager.arePluginsLoaded = function() 
    return utilities.getTableLength(getEnabledPlugins()) > 0
end

pluginsManager.getAvailablePresets = function()
    local pluginsPresetNames = {}
    for i, pluginData in pairs(getEnabledPlugins()) do
        table.insert(pluginsPresetNames, pluginData.presetName)
    end
    
    return pluginsPresetNames
end

pluginsManager.overrideWithPlugin = function(detectedPreset)
    local activatedPlugins = getEnabledPlugins()
    for i, pluginData in pairs(activatedPlugins) do
        print("[RZF] Checking plugin with preset ", pluginData.presetName)
        if(pluginData.triggerMode == nil) then
            if (pluginData.triggerFn()) then
                print("[RZF] ", pluginData.presetName, " simple trigger has activated")
                detectedPreset = pluginData.presetName
            end
        end
        if(pluginData.triggerMode == 'threshold') then
            if (pluginData.triggerFn(pluginData.threshold)) then
                print("[RZF] ", pluginData.presetName, " threshold trigger has activated")
                detectedPreset = pluginData.presetName
            end
        end
        if(pluginData.triggerMode == 'schedule') then
            if (pluginData.triggerFn(pluginData.schedule)) then
                print("[RZF] ", pluginData.presetName, " schedule trigger has activated")
                detectedPreset = pluginData.presetName
            end
        end
    end
    return detectedPreset
end

pluginsManager.getPresetDatabyName = function(presetName)
    local activatedPlugins = getEnabledPlugins()
    for i, pluginData in pairs(activatedPlugins) do
        if (pluginData.presetName == presetName) then
            return pluginData.presetData
        end
    end
end

return pluginsManager