
local M = {}

local cjson = require("cjson")
local _encode = cjson.encode
local _decode = cjson.decode

function M.encode(var)
    local status, result = pcall(_encode, var)
    if status then return result end
    ccerror("[qeeplay.ext.json] encode failed: %s", result)
end

function M.decode(text)
    local status, result = pcall(_decode, text)
    if status then return result end
    ccerror("[qeeplay.ext.json] decode failed: %s", result)
end

return M
