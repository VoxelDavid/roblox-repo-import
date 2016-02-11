
local changeHistory = game:GetService("ChangeHistoryService")

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local events = script.Parent.Events
local ui = script.Parent.UI

local ConnectionManager = require(events.ConnectionManager)
local PluginInterface = require(ui.PluginInterface)


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- This is where we listen for repositories being added to.
local IMPORT_LOCATION = workspace

-- The location where the repository is overlayed on top of.
--
-- Repositories typically mimic the hierarchy of the datamodel, but in the event
-- that you only want one service (for example ServerScriptService), you can
-- change it to only overlay the imported repo on that location.
local OVERLAY_LOCATION = game


--------------------------------------------------------------------------------
-- Plugin
--------------------------------------------------------------------------------

local toolbar = plugin:CreateToolbar("RepoImport")
local button = toolbar:CreateButton("Import", "", "")

-- The plugin's globally accessible active state.
local isActive = false

local function initializeSettings()
  local runBefore = plugin:GetSetting("RunBefore")

  if not runBefore then
    plugin:SetSetting("RunBefore", true)

    -- Allows repositories to be listened for immediately.
    --
    -- With this off, you have to turn on the plugin each time you start a game.
    plugin:SetSetting("ListenByDefault", true)
  end
end


--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function isRepo(obj)
  return obj.Name == "game"
end

local function copy(obj, parent)
  local clone = obj:Clone()
  clone.Parent = parent
end

local function overwrite(obj1, obj2)
  copy(obj1, obj2.Parent)
  obj2:Destroy()
end


--------------------------------------------------------------------------------
-- Repository Importing
--------------------------------------------------------------------------------

local function overlayFolderStructure(folder, parent)
  local children = folder:GetChildren()
  for _, child in pairs(children) do
    local existingChild = parent:FindFirstChild(child.Name)

    if existingChild then
      if child:IsA("Folder") then
        overlayFolderStructure(child, existingChild)
      else
        overwrite(child, existingChild)
      end
    else
      copy(child, parent)
    end
  end
end

local function importRepo(repo)
  changeHistory:SetWaypoint("Import Repository")
  overlayFolderStructure(repo, OVERLAY_LOCATION)
  repo:Destroy()
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function getInterface()
  local gui = script.Parent.RepoImportUI
  local interface = PluginInterface.new(plugin, gui)
  interface:MoveToStudio()

  return interface
end

local function getConnectionManager()
  local event = IMPORT_LOCATION.ChildAdded

  local function listener(obj)
    if isRepo(obj) then
      importRepo(obj)
    end
  end

  return ConnectionManager.new(event, listener)
end

local function initialize()
  local interface = getInterface()
  local conManager = getConnectionManager()

  local connectionToggle = interface.ConnectionToggle
  local listenAutomatically = interface.ListenAutomatically

  local function connect()
    conManager:Connect()
    connectionToggle.Text = "Disconnect"
  end

  local function disconnect()
    conManager:Disconnect()
    connectionToggle.Text = "Connect"
  end

  local function onPluginToggled()
    isActive = not isActive

    button:SetActive(isActive)

    if isActive then
      interface:Show()
    else
      interface:Hide()
    end
  end

  local function onConnectionToggled()
    if conManager:IsConnected() then
      disconnect()
    else
      connect()
    end
  end

  if plugin:GetSetting("ListenByDefault") then
    connect()
  end

  connectionToggle.MouseButton1Down:connect(onConnectionToggled)
  interface.Close.MouseButton1Down:connect(onPluginToggled)
  button.Click:connect(onPluginToggled)
end

initializeSettings()
initialize()
