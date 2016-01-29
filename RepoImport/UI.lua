local coreGui = game:GetService("CoreGui")


--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

Interface = {}
Interface.__index = Interface

function Interface.new(gui)
  local self = {}
  setmetatable(self, Interface)

  self.Gui = gui
  self.Container = gui.Container

  self:Intialize()

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

return getfenv()
