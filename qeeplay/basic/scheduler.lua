
local M = {}

local sharedScheduler = CCScheduler:sharedScheduler()

function M.enterFrame(listener, isPaused)
    if type(isPaused) ~= "boolean" then isPaused = false end
    return sharedScheduler:scheduleScriptFunc(listener, 0, isPaused)
end

function M.schedule(listener, interval, isPaused)
    if type(isPaused) ~= "boolean" then isPaused = false end
    return sharedScheduler:scheduleScriptFunc(listener, interval, isPaused)
end

function M.unschedule(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
end
M.remove = M.unschedule

function M.performWithDelay(time, listener)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        sharedScheduler:unscheduleScriptEntry(handle)
        listener()
    end, time, false)
    return handle
end

return M
