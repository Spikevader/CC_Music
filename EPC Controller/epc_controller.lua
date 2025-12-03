-- epc_controller.lua
local basalt = require("basalt")
local http = http  -- ensure HTTP API is available
local json = textutils  -- use textutils as JSON util (or your own)

-- Load config
local cfg = {}
if fs.exists("config.lua") then
  cfg = dofile("config.lua")
else
  print("No config.lua — please run installer first.")
  return
end

local ws, err = http.websocket(cfg.ws_url)
if not ws then
  print("WebSocket connect failed:", err)
  return
end
ws.send(json.serialize({ source = "epc" }))

-- Get main frame
local main = basalt.getMainFrame()
  :setBackground(colors.black)

-- Title label
local title = main:addLabel()
  :setText("CC Music Controller")
  :setPosition(2, 1)
  :setForeground(colors.white)

-- YouTube URL input
local urlInput = main:addInput()
  :setPosition(2, 3)
  :setSize(40, 1)
  :setText("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

-- Buttons
local function sendCmd(cmd)
  ws.send(json.serialize({ source = "epc", target = "cc", message = cmd }))
end

main:addButton()
  :setPosition(2,5):setSize(12,3)
  :setText("Play YT")
  :onClick(function() sendCmd("playYT:"..urlInput:getText()) end)

main:addButton()
  :setPosition(16,5):setSize(8,3)
  :setText("Pause")
  :onClick(function() sendCmd("pause") end)

main:addButton()
  :setPosition(26,5):setSize(8,3)
  :setText("Stop")
  :onClick(function() sendCmd("stop") end)

main:addButton()
  :setPosition(36,5):setSize(8,3)
  :setText("Next")
  :onClick(function() sendCmd("next") end)

-- Volume slider
local slider = main:addSlider()
  :setPosition(2,9):setSize(30,1)
  :setValue(50)
  :onChange(function(self, v)
     sendCmd("volume:"..v)
  end)

-- Status / feedback label
local status = main:addLabel()
  :setPosition(2, 11)
  :setSize(40, 1)
  :setForeground(colors.lightGray)
  :setText("Ready")

-- Loop to poll WebSocket and update UI
basalt.autoUpdate()  -- start Basalt event loop

while true do
  local msg, err = ws.receive()
  if msg then
    local ok, data = pcall(json.unserialize, msg)
    if ok and data.source == "cc" and data.message then
      status:setText("CC: "..tostring(data.message))
    end
  elseif err then
    status:setText("WS error: "..tostring(err))
    break
  end
  sleep(0.1)
end
