local utilities = require('rzf_utilities')

-- Global table for plugins
RZF_PLUGINS = {}

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

pluginsManager.addPluginTemplate = function()
    local pluginDataTemplate = {
        presetName = "examplePreset",
        enabled = false,
        triggerFn = function() return true end,
        presetData = {
            crawler = 20.0,
            shambler = 30.0,
            fastShambler = 30.0,
            sprinter = 20.0,
            fragile = 50.0,
            normal = 30.0,
            tough = 20.0,
            smart = 10.0
        }
    }

    table.insert(RZF_PLUGINS, pluginDataTemplate)
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
        if (pluginData.triggerFn()) then
            detectedPreset = pluginData.presetName
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