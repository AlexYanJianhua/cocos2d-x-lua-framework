
module(..., package.seeall)

--[[ 给指定的对象添加事件处理机制
]]
function extend(target)
    target.listeners = {}   -- 所有的事件处理函数

    --[[ 注册一个事件
    用法：
        -- BOAT_DEAD 事件的处理函数
        local function onBoatDead(event)
            print(event.name, event.boat)
        end

        -- 注册 BOAT_DEAD 事件
        target:addEventListener("BOAT_DEAD", onBoatDead)

        -- 触发 BOAT_DEAD 事件
        local event = {name = "BOAT_DEAD", boat = boat}
        target:dispatchEvent(event)
    ]]
    function target:addEventListener(name, listener)
        name = string.upper(name)
        if target.listeners[name] == nil then target.listeners[name] = {} end
        local t = target.listeners[name]
        t[#t + 1] = listener
    end

    --[[ 触发一个事件
    event 参数必须是一个对象，其 name 属性指定事件名称，其他属性则事件附带的参数。
    事件处理函数如果返回 false，则表示阻止该事件继续传播给同一事件的其他处理函数。
    ]]
    function target:dispatchEvent(event)
        event.name = string.upper(event.name)
        local name = event.name
        if target.listeners[name] == nil then return end
        local t = target.listeners[name]
        for i = #t, 1, -1 do
            local listener = t[i]
            if listener(event) == false then break end
        end
    end

    --[[ 删除指定事件的一个处理函数
    用法：
        target:removeEventListener("BOAT_DEAD", onBoatDead)
    ]]
    function target:removeEventListener(name, listener)
        name = string.upper(name)
        if target.listeners[name] == nil then return end
        local t = target.listeners[name]
        for i = #t, 1, -1 do
            if t[i] == listener then
                table.remove(t, i)
                return
            end
        end
        if #t == 0 then target.listeners[name] = nil end
    end

    --[[ 删除指定事件的所有处理函数
    ]]
    function target:removeAllEventListenersForEvent(name)
        target.listeners[string.upper(name)] = nil
    end

    --[[ 删除所有事件处理函数
    ]]
    function target:removeAllEventListeners()
        target.listeners = {}
    end
end
