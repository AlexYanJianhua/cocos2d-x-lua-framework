
local M = {}

local device = require("qeeplay.basic.device")

local dict = {}

function M.setDict(dict_)
    dict = dict_
end

function M.text(source)
    if dict[device.language] then
        local result = dict[device.language][source]
        if result then return result end
    else
        return source
    end
end

return M
