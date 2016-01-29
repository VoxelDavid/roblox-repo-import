
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local events = require(script.Parent.Events)
local ui = require(script.Parent.UI)
local RadioButton = require(script.Parent.RadioButton)


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
    print("Setting ReporImport settings for the first time")

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
  overlayFolderStructure(repo, OVERLAY_LOCATION)
  repo:Destroy()
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function initialize()
  local interface do
    local gui = script.Parent.RepoImportUI
    interface = ui.Interface.new(gui)
  end

  local conManager do
    local event = IMPORT_LOCATION.ChildAdded

    local function listener(obj)
      if isRepo(obj) then
        importRepo(obj)
      end
    end

    conManager = events.ConnectionManager.new(event, listener)
  end

  -- Gui elements
  local contents = interface.Container.Contents
  local connectionToggle = contents.ConnectionToggle
  local connectAutomatically do
    local setting = plugin:GetSetting("ListenByDefault")
    local button = contents.ListenAutomatically.RadioButton
    connectAutomatically = RadioButton.new(button, setting)
  end
  local close = interface.Container.Header.Close

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

  local function onConnectAutomaticallyChanged(newValue)
    plugin:SetSetting("ListenByDefault", newValue)
  end

  if plugin:GetSetting("ListenByDefault") then
    connect()
  end

  connectAutomatically.StateChanged.Event:connect(onConnectAutomaticallyChanged)
  connectionToggle.MouseButton1Down:connect(onConnectionToggled)
  close.MouseButton1Down:connect(onPluginToggled)
  button.Click:connect(onPluginToggled)
end

initializeSettings()
initialize()
