
module(..., package.seeall)
require("qeeplay.api.EventProtocol")

--[[ 提供事件注册、触发服务，以及配置管理的模块
]]
function new()
    local context = {}

    ----

    local config = {}       -- 所有的设置

    ----

    local function init()
        qeeplay.api.EventProtocol.extend(context)
    end

    ----

    --[[ 查询 key 指定键名的设置，如果设置不存在则返回 defaultValue 参数指定的默认值
    用法：
        local numOfEnemys = context:getConfig("NUM_OF_ENEMYS", 10)
    ]]
    function context:getConfig(key, defaultValue)
        if config[key] ~= nil then return config[key] end
        return defaultValue
    end

    --[[ 修改指定键名的设置
    用法：
        context:setConfig("NUM_OF_ENEMYS", 15)
    ]]
    function context:setConfig(key, value)
        config[key] = value
    end

    ----

    init()
    return context
end
