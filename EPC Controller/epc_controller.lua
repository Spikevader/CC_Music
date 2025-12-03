-- epc_controller.lua
-- Fully Basalt 2.x compatible EPC music controller

local basalt = require("Basalt")
local json = textutils  -- for simple JSON serialize/unserialize

-- Load config
local cfg = {}
if fs.exists("config.lua") then
    cfg = dofile("config.lua")
else
    print("No config.lua found. Please run the installer first.")
    return
end

-- Connect to WebSocket
local ws, err = http.websocket(cfg.ws_url)
if not ws then
    print("WebSocket connect failed:", err)
    return
end
ws.send(json.serialize({ source = "epc" }))

-- Create main frame
local main = basalt.getMainFrame()
    :setAutoUpdate(true)

-- Add full-screen background rectangle
local bg = main:addRectangle()
bg:setPosition(1,1)
bg:setSize(main:getSize())
bg:setBackground(colors.black)

-- Title label
local title = main:addLabel()
title:setPosition(2,1)
title:setText("CC Music Controller")
title:setForeground(colors.white)

-- YouTube URL input
local urlInput = main:addInput()
urlInput:setPosition(2,3)
urlInput:setSize(40,1)
urlInput:setText("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

-- Status label
local status = main:addLabel()
status:setPosition(2, 5)
status:setSize(40,1)
status:setText("Ready")
status:setForeground(colors.lightGray)

-- Button helper function
local function sendCmd(cmd)
    ws.send(json.serialize({ source="epc", target="cc", message=cmd }))
end

-- Buttons
local playBtn = main:addButton()
playBtn:setPosition(2,7)
playBtn:setSize(12,3)
playBtn:setText("Play YT")
playBtn:onClick(function() sendCmd("playYT:"..urlInput:getText()) end)

local pauseBtn = main:addButton()
pauseBtn:setPosition(16,7)
pauseBtn:setSize(8,3)
pauseBtn:setText("Pause")
pauseBtn:onClick(function() sendCmd("pause") end)

local stopBtn = main:addButton()
stopBtn:setPosition(26,7)
stopBtn:setSize(8,3)
stopBtn:setText("Stop")
stopBtn:onClick(function() sendCmd("stop") end)

local nextBtn = main:addButton()
nextBtn:setPosition(36,7)
nextBtn:setSize(8,3)
nextBtn:setText("Next")
nextBtn:onClick(function() sendCmd("next") end)

-- Volume slider
local slider = main:addSlider()
slider:setPosition(2,11)
slider:setSize(30,1)
slider:setValue(50)
slider:onChange(function(self, v)
    sendCmd("volume:"..v)
end)

-- Poll WebSocket and update status
basalt.onEvent("tick", function()
    local msg, err = ws.receive()
    if msg then
        local ok, data = pcall(json.unserialize, msg)
        if ok and data.source=="cc" and data.message then
            status:setText("CC: "..tostring(data.message))
        end
    elseif err then
        status:setText("WS error: "..tostring(err))
    end
end)

-- Start Basalt event loop
basalt.autoUpdate()
