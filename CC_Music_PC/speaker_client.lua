local utils = require("modules/utils")
local commands = require("modules/commands")

local ws_url
if fs.exists("config.lua") then
    ws_url = dofile("config.lua").ws_url
else
    write("Enter WebSocket URL: ")
    ws_url = read()
    local f = fs.open("config.lua","w")
    f.write("return { ws_url='"..ws_url.."' }")
    f.close()
end

local ws, err = http.websocket(ws_url)
if not ws then error("Failed to connect: "..err) end
ws.send(textutils.serializeJSON({source="cc_music"}))

local speakers = { peripheral.find("speaker") }
if #speakers == 0 then error("No speakers found!") end

while true do
    local msg = ws.receive()
    if msg then
        local ok, data = pcall(textutils.unserializeJSON, msg)
        if ok and data.command and commands[data.command] then
            commands[data.command](speakers, data.args, utils.loadSong)
        end
    end
end
