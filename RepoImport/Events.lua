
--[[
  Class for managing the Connection object returned by events.

  This lets you connect, disconnect and reconnect an event to a listner
--]]
ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new(event, listener)
  local self = {}
  setmetatable(self, ConnectionManager)

  self.Event = event
  self.Listener = listener

  -- Holds the Connection object of `event`.
  self.Connection = nil

  return self
end

function ConnectionManager:IsConnected()
  return self.Connection and self.Connection.connected
end

function ConnectionManager:Disconnect()
  if self:IsConnected() then
    self.Connection:disconnect()
  end
end

function ConnectionManager:Connect()
  if self:IsConnected() then
    error("You need to disconnect the current event before connecting " ..
      "another function")
  else
    self.Connection = self.Event:connect(self.Listener)
  end
end

return getfenv()
