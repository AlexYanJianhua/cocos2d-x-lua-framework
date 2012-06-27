
if type(DEBUG) ~= "number" then DEBUG = 1 end
io.output():setvbuf('no')

local prt = function(...)
    ccprintf("[LUA] "..string.format(...))
end

log = {}
log.notice  = function() end
log.warning = function() end
log.error   = prt

if DEBUG > 0 then log.warning = prt end
if DEBUG > 1 then log.notice = prt end


function trackback()
    ccprintf(debug.traceback())
end

function ccprintf(fmt, ...)
    local output = string.format(fmt, select(1, ...))
    CCLuaLog(output)
end

function ccassert(expr, message, ...)
    if expr then return expr end
    local output = string.format(message, select(1, ...))
    error(output, 2)
end
