local coreGui = game:GetService("CoreGui")

local RadioButton = require(script.Parent.RadioButton)


--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

--[[
  Class for managing a generic Gui.

  gui : ScreenGui
    This is the Gui that the class will be managing.

    It requries the following elements to exist inside of it:

    - "Container" : Frame

      This will act as the main wrapper for the Gui. All of your other elements
      go inside of it.

    - "Close" : GuiButton

      This is the button that will close the Gui. It can be located anywhere
      inside of the gui's descendants, but there should only be one instance
      with this name.
--]]
Interface = {}
Interface.__index = Interface

function Interface.new(gui)
  local self = {}
  setmetatable(self, Interface)

  self.Gui = gui
  self.Container = gui.Container
  self.Close = self:GetElementByName("Close")

  self.Close.MouseButton1Down:connect(function()
    self:Hide()
  end)

  return self
end

function Interface:Show()
  self.Container.Visible = true
end

function Interface:Hide()
  self.Container.Visible = false
end

function Interface:GetElementByName(name)
  return self.Container:FindFirstChild(name, true)
end


--------------------------------------------------------------------------------
-- PluginInterface
--------------------------------------------------------------------------------

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

return getfenv()
