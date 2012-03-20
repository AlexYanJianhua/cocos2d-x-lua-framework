
module("dispatcher", package.seeall)

BREAK_EVENT_DISPATCHING = "BREAK_EVENT_DISPATCHING"


local eventsMap = {}

function addEventListener(event, listener)
    if not eventsMap[event] then eventsMap[event] = {} end
    local listeners = eventsMap[event]
    listeners[#listeners + 1] = listener
end

function removeEventListener(event, listener)
    if not eventsMap[event] then return end
    local listeners = eventsMap[event]
    for i = 1, #listeners do
        if listeners[i] == listener then
            table.remove(listeners, i)
            return
        end
    end
end

function dispatch(event, ...)
    if not eventsMap[event] then return end
    local listeners = eventsMap[event]
    for i = 1, #listeners do
        if listeners[i](...) == BREAK_EVENT_DISPATCHING then break end
    end
end
