-- speaker_client.lua
-- Vanilla CC Speaker Client (modular, WebSocket-controlled)

-- Load WebSocket config
local cfg = {}
if fs.exists("config.lua") then
    cfg = dofile("config.lua")
else
    print("No config.lua found. Please run the installer first.")
    return
end

-- Download required modules if missing
local modules = {
    {"music.lua", "https://pastebin.com/raw/pdJ1agSb"},
    {"music_multi.lua", "https://pastebin.com/raw/Pgmg7zA7"},
    {"music_broadcast.lua", "https://pastebin.com/raw/91ERAC8Z"},
    {"waveflow.lua", "https://pastebin.com/raw/fhaLt6ng"},
    {"apple.nfp", "https://pastebin.com/raw/ESEDF58T"},
    {"applew.nfp", "https://pastebin.com/raw/r8gZx6bp"}
}

for _, v in ipairs(modules) do
    local filename, url = v[1], v[2]
    if not fs.exists(filename) then
        print("Downloading " .. filename)
        shell.run("wget", url, filename)
    end
end

-- Require/load modules
local music = dofile("music.lua")
local multi = dofile("music_multi.lua")
local broadcast = dofile("music_broadcast.lua")
dofile("waveflow.lua") -- visualization

-- Find speaker peripheral
local speaker = peripheral.find("speaker")
if not speaker then
    error("No speaker attached!")
end

-- Connect to WebSocket
local ws, err = http.websocket(cfg.ws_url)
if not ws then
    print("Failed to connect to WebSocket:", err)
    return
end

ws.send(textutils.serializeJSON({ source="cc" }))
print("Connected to WebSocket as CC speaker client.")

-- Helper to play a song using music.lua
local function playSong(url)
    -- download or parse YouTube/NBS song data
    -- If using YouTube: music.fetchYoutube(url) or similar (from your music.lua)
    local songData = music.fetchSong(url) -- assuming music.lua has fetchSong
    if songData then
        print("Playing song...")
        multi.play(songData, speaker) -- multi plays on all connected speakers
    else
        print("Failed to load song data for:", url)
    end
end

-- Helper to stop music
local function stopMusic()
    multi.stop() -- assuming multi module has stop
end

-- Helper to pause music
local function pauseMusic()
    multi.pause() -- if supported
end

-- Helper to set volume
local function setVolume(vol)
    if type(vol)=="number" then
        multi.setVolume(vol)
    end
end

-- Main loop: listen for EPC or PC commands
while true do
    local msg, err = ws.receive()
    if msg then
        local ok, data = pcall(textutils.unserializeJSON, msg)
        if ok and data.source and data.message then
            local cmd = data.message
            if cmd:sub(1,7)=="playYT:" then
                local url = cmd:sub(8)
                playSong(url)
            elseif cmd=="stop" then
                stopMusic()
            elseif cmd=="pause" then
                pauseMusic()
            elseif cmd=="next" then
                multi.next() -- skip to next song
            elseif cmd:sub(1,7)=="volume:" then
                local vol = tonumber(cmd:sub(8))
                setVolume(vol)
            end
        end
    end
end
