


module("qeeplay", package.seeall)
require("qeeplay.support.debug")

log.warning("")
log.warning("# debug                        = "..DEBUG)
log.warning("#")

require("qeeplay.support.device")
require("qeeplay.support.functions")
require("qeeplay.support.director")
require("qeeplay.support.display")
require("qeeplay.support.scheduler")
require("qeeplay.support.transition")
require("qeeplay.support.ui")
require("qeeplay.support.audio")
require("qeeplay.support.json")
require("qeeplay.support.network")
require("qeeplay.support.localize")


local timeCount = 0
local function checkMemory(dt)
    timeCount = timeCount + dt
    print(string.format("[LUA] MEMORY USED: %04.2fs, %0.2f KB",
                        timeCount,
                        tonumber(collectgarbage("count"))))
end
if DEBUG > 1 then scheduler.schedule(checkMemory, 10.0) end

collectgarbage("setpause", 150)
collectgarbage("setstepmul", 1000)
