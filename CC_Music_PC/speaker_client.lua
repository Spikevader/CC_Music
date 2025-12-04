-------------------------------
-- CC MUSIC WEBSOCKET CLIENT --
-- Full rebuild by request   --
-------------------------------

-- Load WebSocket config
local config = {}
if fs.exists("config.lua") then
    config = dofile("config.lua")
else
    print("No config.lua found! Run installer first.")
    return
end

--------------------------------
-- UTILITY FUNCTIONS
--------------------------------
local function playYouTube(url)
    print("▶ Playing:", url)
    shell.run("music", url)
end

local function stopMusic()
    print("■ Stopping playback...")
    shell.run("music", "stop")
end

local function pauseMusic()
    print("⏸ Paused.")
    shell.run("music", "pause")
end

local function resumeMusic()
    print("⏵ Resuming.")
    shell.run("music", "resume")
end

local function setVolume(level)
    print("🔊 Volume:", level)
    shell.run("music", "volume", tostring(level))
end

--------------------------------
-- CONNECT TO WEBSOCKET SERVER
--------------------------------
print("Connecting to WebSocket:", config.ws_url)
local ws, err = http.websocket(config.ws_url)

if not ws then
    print("❌ Failed to connect:", err)
    return
end

print("✅ Connected! Waiting for commands...")
print("Listening for JSON like:")
print([[ {"action":"play","url":"https://youtube.com/watch?v=..."} ]])

--------------------------------
-- MAIN LISTENER LOOP
--------------------------------
while true do
    local msg = ws.receive()

    if msg then
        local cmd = textutils.unserializeJSON(msg)

        if not cmd or not cmd.action then
            print("⚠ Invalid message:", msg)
        else
            if cmd.action == "play" and cmd.url then
                playYouTube(cmd.url)

            elseif cmd.action == "stop" then
                stopMusic()

            elseif cmd.action == "pause" then
                pauseMusic()

            elseif cmd.action == "resume" then
                resumeMusic()

            elseif cmd.action == "volume" and cmd.level then
                setVolume(cmd.level)

            else
                print("⚠ Unknown command:", cmd.action)
            end
        end
    end
end
