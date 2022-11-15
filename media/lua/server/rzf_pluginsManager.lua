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

-- This function is just here to show how to add a new plugin to the global plugins table
local function exampleAddPluginTemplate()
    local pluginDataTemplate = {
        presetName = "exampleTime",              -- give a unique name to your preset, possibly with the suffix `Time`
        enabled = false,                         -- determine if this plugin is enabled or disable
        triggerFn = function() return true end,  -- this function must return true/false (boolean) and will be used to determine if the preset must activate
        presetData = {                           -- follow this structure to specify the distribution data for your preset
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

    table.insert(RZF_PLUGINS, pluginDataTemplate) -- use this to add your table created above to the global RZF_PLUGINS table
end

return pluginsManager