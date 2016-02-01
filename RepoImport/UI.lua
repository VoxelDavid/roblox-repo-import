local coreGui = game:GetService("CoreGui")


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

function Interface:Intialize()
  self.Gui.Parent = coreGui
  self:Hide()
end

function Interface:GetElementByName(name)
  return self.Container:FindFirstChild(name, true)
end

return getfenv()
