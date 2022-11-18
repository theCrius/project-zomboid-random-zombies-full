local utilities = require('rzf_utilities')
local presetManager = require('rzf_presetManager')

-- Global table for plugins
RZF_PLUGINS = RZF_PLUGINS or {}

local pluginsManager = {}

local function getEnabledPlugins()
    local activePlugins = {}
    for i, pluginData in pairs(RZF_PLUGINS) do
        if(pluginData.enabled) then
            table.insert(activePlugins, pluginData)
        end
    end

    return activePlugins
end

pluginsManager.arePluginsLoaded = function() 
    return utilities.getTableLength(getEnabledPlugins()) > 0
end

pluginsManager.getAvailablePresets = function()
    local pluginsPresetNames = {}
    for i, pluginData in pairs(getEnabledPlugins()) do
        table.insert(pluginsPresetNames, pluginData.presetName)
    end
end

pluginsManager.overrideWithPlugin = function(detectedPreset)
    local activatedPlugins = pluginsManager.getEnabledPlugins()
    for i, pluginData in pairs(activatedPlugins) do
        if(pluginData.triggerMode == nil) then
            if (pluginData.triggerFn()) then
                detectedPreset = pluginData.presetName
            end
        end
        if(pluginData.triggerMode == 'threshold') then
            if (pluginData.triggerFn(pluginData.threshold)) then
                detectedPreset = pluginData.presetName
            end
        end
        if(pluginData.triggerMode == 'schedule') then
            if (pluginData.triggerFn(pluginData.schedule)) then
                detectedPreset = pluginData.presetName
            end
        end
    end
    return detectedPreset
end

pluginsManager.getPresetDatabyName = function(presetName)
    local activatedPlugins = pluginsManager.getEnabledPlugins()
    for i, pluginData in pairs(activatedPlugins) do
        if (pluginData.presetName == presetName) then
            return pluginData.presetData
        end
    end
end

return pluginsManager