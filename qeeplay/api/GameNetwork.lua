
module(..., package.seeall)

local instance

--[[
初始化游戏网络

-   providerName: 可以是 GameCenter, OpenFeint，不区分大小写
-   params: 根据不同类型的服务，params 提供必须的参数


How to use:

    require("qeeplay.api.GameNetwork")
    qeeplay.api.GameNetwork.init("OpenFeint", {
        productKey  = "XXX",
        secret      = "XXX",
        displayName = "XXXX"
    })

    local achievements = qeeplay.api.GameNetwork.request("getAchievements")
    dump(achievements, "All achievements")

    local leaderboards = qeeplay.api.GameNetwork.request("getLeaderboards")
    dump(leaderboards, "All leaderboards")

    local score = math.random(100, 200)
    local displayText = string.format("My score is %d", score)
    qeeplay.api.GameNetwork.request("setHighScore", "916960912", score, displayText)

    local i = math.random(#achievements)
    qeeplay.api.GameNetwork.request("unlockAchievement", achievements[i].id)

    qeeplay.api.GameNetwork.show("dashboard")

]]
function init(providerName, params)
    if instance then
        return instance:isReady()
    end

    providerName = string.upper(providerName)
    local provider
    if providerName == "GAMECENTER" then
        provider = require("qeeplay.api.gamenetwork.GameCenter")
    elseif providerName == "OPENFEINT" then
        provider = require("qeeplay.api.gamenetwork.OpenFeint")
    else
        log.error("[qeeplay.api.GameNetwork] ERR, init() invalid providerName: %s", providerName)
        return false
    end

    if type(params) ~= "table" then
        log.error("[qeeplay.api.GameNetwork] ERR, init() invalid params")
        return false
    end

    instance = provider.new()
    return instance:init(params)
end

function request(name, ...)
    if not instance or not instance:isReady() then return end
    local c = select("#", ...)
    local params = {}
    for i = 1, c do
        params[i] = select(i, ...)
    end
    return instance:request(name, params)
end

function show(name, ...)
    if not instance or not instance:isReady() then return end
    local c = select("#", ...)
    local params = {}
    for i = 1, c do
        params[i] = select(i, ...)
    end
    instance:show(name, params)
end
