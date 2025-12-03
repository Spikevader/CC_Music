print("Welcome to EPC Music Controller Installer")

-- Prompt for WebSocket URL
write("Enter WebSocket URL (ws://...): ")
local ws_url = read()

-- Save URL to config
local f = fs.open("config.lua","w")
f.write("return { ws_url='"..ws_url.."' }")
f.close()

-- Ensure modules folder exists
if not fs.exists("modules") then fs.makeDir("modules") end

-- Use raw GitHub URLs
local files = {
    {"modules/utils.lua","https://raw.githubusercontent.com/Spikevader/CC_Music/main/EPC%20Controller/modules/utils.lua"},
    {"epc_controller.lua","https://raw.githubusercontent.com/Spikevader/CC_Music/main/EPC%20Controller/epc_controller.lua"}
}

-- Download files
for _,v in ipairs(files) do
    local path, url = v[1], v[2]
    shell.run("wget", url, path)
end

print("EPC Music Controller installed successfully!")
print("Run 'epc_controller.lua' to start the touchscreen UI.")
