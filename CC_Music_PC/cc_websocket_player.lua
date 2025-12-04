local WS_URL = "ws://cccontrol.duckdns.org:8080"
local ws, err = http.websocket(WS_URL)

if not ws then
    print("Failed to connect:", err)
    return
end

-- Identify as CC
ws.send(textutils.serializeJSON({ source = "cc" }))
print("Connected to WebSocket relay!")

while true do
    local msg = ws.receive()
    if msg then
        print("Received raw message:", msg)
        local ok, data = pcall(textutils.unserializeJSON, msg)
        if ok and data then
            if data.command == "play" then
                print("🎵 Play command received:", data.song)
                local success, err = pcall(music.play, data.song)
                if not success then print("Error playing song:", err) end
            elseif data.command == "stop" then
                print("⏹ Stop command received")
                pcall(music.stop)
            elseif data.command == "skip" then
                print("⏭ Skip command received")
                pcall(music.skip)
            end
        else
            print("Failed to parse JSON:", data)
        end
    end
end
