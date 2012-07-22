
math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

__QEEPLAY_GLOBALS__ = {}

if type(DEBUG) ~= "number" then DEBUG = 1 end
io.output():setvbuf('no')

local prt = function(...)
    CCLuaLog("[LUA] "..string.format(...))
end

ccnotice  = function() end
ccwarning = function() end
ccerror   = prt

if DEBUG > 0 then ccwarning = prt end
if DEBUG > 1 then ccnotice = prt end

require("qeeplay.basic.debug")
require("qeeplay.basic.functions")

ccwarning("")
ccwarning("# DEBUG                        = "..DEBUG)
ccwarning("#")

-- define global module
device     = require("qeeplay.basic.device")
display    = require("qeeplay.basic.display")
scheduler  = require("qeeplay.basic.scheduler")
transition = require("qeeplay.basic.transition")
audio      = require("qeeplay.basic.audio")
ui         = require("qeeplay.basic.ui")

local timeCount = 0
local function checkMemory(dt)
    timeCount = timeCount + dt
    local used = tonumber(collectgarbage("count"))
    CCLuaLog(string.format("[LUA] MEMORY USED: %0.2f KB, UPTIME: %04.2fs", used, timeCount))
end
if DEBUG > 1 then
    CCScheduler:sharedScheduler():scheduleScriptFunc(checkMemory, 2.0, false)
end

collectgarbage("setpause", 150)
collectgarbage("setstepmul", 1000)
