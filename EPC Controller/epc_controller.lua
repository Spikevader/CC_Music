local basalt = require("basalt")
local utils = require("modules/utils")

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
ws.send(textutils.serializeJSON({source="epc_controller"}))

local ui = basalt.createFrame()
ui:setSize(50,20)
ui:setTitle("CC Music Controller")

local search_input = ui:addInput():setPos(2,2):setSize(20,1):setText("Search song...")
local search_btn = ui:addButton():setPos(23,2):setSize(10,1):setText("Search")
local song_list = ui:addList():setPos(2,4):setSize(40,10)
local play_btn = ui:addButton():setPos(2,15):setSize(10,1):setText("Play")
local instrument_input = ui:addInput():setPos(25,4):setSize(10,1):setText("harp")
local volume_input = ui:addInput():setPos(25,5):setSize(5,1):setText("3")
local pitch_input = ui:addInput():setPos(25,6):setSize(5,1):setText("5")
local progress_bar = ui:addProgressBar():setPos(2,17):setSize(40,1):setValue(0)

local search_results = {}

local function sendPlaySong(filename)
    ws.send(textutils.serializeJSON({
        source="epc_controller",
        target="cc_music",
        command="play_song",
        args={filename=filename}
    }))
end

local function sendPlayNote(instr, vol, pitch)
    ws.send(textutils.serializeJSON({
        source="epc_controller",
        target="cc_music",
        command="play_note",
        args={instrument=instr, volume=vol, pitch=pitch}
    }))
end

search_btn:onClick(function()
    local query = search_input:getText()
    local songs = utils.fetchJSON("https://pastebin.com/raw/Rc1PCzLH") or {}
    search_results = {}
    query = query:lower()
    for _,s in ipairs(songs) do
        if s.name:lower():find(query) then table.insert(search_results, s) end
    end
    song_list:clear()
    for i,s in ipairs(search_results) do song_list:addItem(s.name) end
end)

play_btn:onClick(function()
    local idx = song_list:getSelected()
    if idx and search_results[idx] then
        sendPlaySong(search_results[idx].file)
        progress_bar:setValue(0)
    else
        sendPlayNote(instrument_input:getText(),
                    tonumber(volume_input:getText()),
                    tonumber(pitch_input:getText()))
    end
end)

while true do
    ui:draw()
    os.sleep(0.05)
end
