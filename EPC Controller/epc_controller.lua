-- epc_controller_vanilla.lua
-- EPC Music Controller using vanilla CC:Tweaked APIs

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
    print("Failed to connect:", err)
    return
end

-- Identify as EPC
ws.send(textutils.serializeJSON({ source = "epc" }))

-- Clear screen and set up colors
term.clear()
term.setCursorPos(1,1)
local w,h = term.getSize()

-- Simple UI functions
local function drawBox(x,y,width,height)
    for i=0,height-1 do
        term.setCursorPos(x,y+i)
        term.write(string.rep(" ",width))
    end
end

local function drawLabel(x,y,text)
    term.setCursorPos(x,y)
    term.write(text)
end

local function readInput(prompt,x,y)
    term.setCursorPos(x,y)
    write(prompt)
    return read()
end

-- Draw basic UI
drawBox(1,1,w,3)
drawLabel(2,2,"CC Music Controller")

drawBox(1,5,w,3)
drawLabel(2,6,"YouTube URL:")

drawBox(1,10,w,3)
drawLabel(2,11,"[P]lay  [S]top  [U]pause  [N]ext  [V]olume")

-- Main loop
local volume = 50
local ytURL = ""

while true do
    -- Input YouTube URL
    term.setCursorPos(16,6)
    ytURL = read()

    drawLabel(2,8,"Enter command (P/S/U/N/V/Q):")
    local cmd = read():upper()

    if cmd == "P" then
        ws.send(textutils.serializeJSON({ source="epc", target="cc", message="playYT:"..ytURL }))
    elseif cmd == "S" then
        ws.send(textutils.serializeJSON({ source="epc", target="cc", message="stop" }))
    elseif cmd == "U" then
        ws.send(textutils.serializeJSON({ source="epc", target="cc", message="pause" }))
    elseif cmd == "N" then
        ws.send(textutils.serializeJSON({ source="epc", target="cc", message="next" }))
    elseif cmd == "V" then
        drawLabel(2,12,"Set volume (0-100):")
        term.setCursorPos(20,12)
        local vol = tonumber(read())
        if vol then
            volume = math.max(0, math.min(100, vol))
            ws.send(textutils.serializeJSON({ source="epc", target="cc", message="volume:"..volume }))
        end
    elseif cmd == "Q" then
        break
    end

    -- Poll for messages from CC
    local msg, err = ws.receive()
    if msg then
        local ok, data = pcall(textutils.unserializeJSON, msg)
        if ok and data.source=="cc" and data.message then
            drawLabel(2,14,"CC: "..tostring(data.message))
        end
    end
end
