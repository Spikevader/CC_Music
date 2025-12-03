print("Welcome to CC Music Client Installer")

-- Prompt for WebSocket URL
write("Enter WebSocket URL (ws://...): ")
local ws_url = read()

-- Save URL to config
local f = fs.open("config.lua","w")
f.write("return { ws_url='"..ws_url.."' }")
f.close()

-- Ensure modules folder exists
if not fs.exists("modules") then fs.makeDir("modules") end

-- Replace these with your Gist raw URLs
local files = {
    {"modules/utils.lua","https://raw.githubusercontent.com/Spikevader/CC_Music/refs/heads/main/CC_Music_PC/modules/utils.lua"},
    {"modules/commands.lua","https://raw.githubusercontent.com/Spikevader/CC_Music/refs/heads/main/CC_Music_PC/modules/commands.lua"},
    {"speaker_client.lua","https://raw.githubusercontent.com/Spikevader/CC_Music/refs/heads/main/CC_Music_PC/speaker_client.lua"}
}

-- Download files
for _,v in ipairs(files) do
    local path, url = v[1], v[2]
    shell.run("wget", url, path)
end

print("CC Music Client installed successfully!")
print("Run 'speaker_client.lua' to start your music client.")
