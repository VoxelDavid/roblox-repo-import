--[[
  A speciailized version of the Interface class, containing specific Plugin
  elements.

  plugin : Plugin
    Instance of the current plugin. This is used so we can get/set settings via
    the user interface.
  gui : ScreenGui
    This is the gui that the class will be managing. See the Interface class for
    more details.
--]]

local coreGui = game:GetService("CoreGui")
local Interface = require(script.Parent.Interface)
local RadioButton = require(script.Parent.RadioButton)

PluginInterface = {}
PluginInterface.__index = PluginInterface
setmetatable(PluginInterface, Interface)

function PluginInterface.new(plugin, gui)
  local self = Interface.new(gui)
  setmetatable(self, PluginInterface)

  self.Plugin = plugin

  self.ConnectionToggle = self:GetElementByName("ConnectionToggle")

  local listenAutomatically = self:GetElementByName("ListenAutomatically")
  self.ListenAutomatically = RadioButton.new(listenAutomatically.RadioButton,
    plugin:GetSetting("ListenByDefault"))

  self.ListenAutomatically.StateChanged.Event:connect(function(newValue)
    plugin:SetSetting("ListenByDefault", newValue)
  end)

  return self
end

function PluginInterface:MoveToStudio()
  self.Gui.Parent = coreGui

  -- We need the gui in CoreGui, but we don't want it visible until the user
  -- interacts with the plugin.
  self:Hide()
end

return PluginInterface
