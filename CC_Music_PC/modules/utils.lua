local utils = {}

function utils.loadSong(filename)
    local path = "songs/" .. filename
    if not fs.exists(path) then return nil end
    local f = fs.open(path, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data
end

function utils.fetchJSON(url)
    local resp = http.get(url)
    if not resp then return nil end
    local data = resp.readAll()
    resp.close()
    return textutils.unserializeJSON(data)
end

return utils
