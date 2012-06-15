
module(..., package.seeall)

function new()
    local openfeint = {}

    ----

    local isReady = false

    ----

    function openfeint:init(params)
        CCOpenFeint:postInitWithProductKey(params.productKey,
                                           params.secret,
                                           params.displayName)
        isReady = true
        return true
    end

    function openfeint:isReady()
        return isReady
    end

    function openfeint:request(name, params)
        name = string.upper(name)
        if name == "GETACHIEVEMENTS" then
            return CCOpenFeint:getAchievementsLua()

        elseif name == "UNLOCKACHIEVEMENT" then
            local achievementId = tostring(params[1])
            if type(achievementId) ~= "string" then
                log.error("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "unlockAchievement", "invalid achievementId")
            end

            return CCOpenFeint:unlockAchievement(achievementId)

        elseif name == "GETLEADERBOARDS" then
            return CCOpenFeint:getLeaderboardsLua()

        elseif name == "SETHIGHSCORE" then
            local leaderboardId = params[1]
            if type(leaderboardId) ~= "string" then
                log.error("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "setHighScore", "invalid leaderboardId")
                return false
            end

            local score = tonumber(params[2])
            if type(score) ~= "number" then
                log.error("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "setHighScore", "invalid score")
                return false
            end

            local displayText = params[3]
            if type(displayText) ~= "string" then
                log.error("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "setHighScore", "invalid displayText")
                return false
            end

            return CCOpenFeint:setHighScore(leaderboardId, score, displayText)
        end

        return false
    end

    function openfeint:show(name, params)
        name = string.upper(name)
        if name == "LEADERBOARDS" and #params < 1 then
            CCOpenFeint:showLeaderboards()

        elseif name == "LEADERBOARDS" then
            local leaderboardId = params[1]
            if type(leaderboardId) ~= "string" then
                log.error("[qeeplay.api.GameNetwork.OpenFeint] ERR, show(%s) %s",
                          "leaderboards", "invalid leaderboardId")
            else
                CCOpenFeint:showLeaderboards(leaderboardId)
            end

        elseif name == "ACHIEVEMENTS" then
            CCOpenFeint:showAchievements()

        elseif name == "CHALLENGES" then
            CCOpenFeint:showChallenges()

        elseif name == "FRIENDS" then
            CCOpenFeint:showFriends()

        elseif name == "PLAYING" then
            CCOpenFeint:showPlaying()

        else -- DASHBOARD
            CCOpenFeint:showDashboard()
        end
    end

    ----

    return openfeint
end
