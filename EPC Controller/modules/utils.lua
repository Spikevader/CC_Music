local utils = {}

function utils.fetchJSON(url)
    local resp = http.get(url)
    if not resp then return nil end
    local data = resp.readAll()
    resp.close()
    return textutils.unserializeJSON(data)
end

return utils
