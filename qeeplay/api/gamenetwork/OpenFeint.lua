
--[[--

OpenFeint is a 3rd party library that enables social gaming features such as public leaderboards and achievements. For more information, see http://www.openfeint.com/ and http://www.openfeint.com/developers.

@module qeeplay.api.gamenetwork.OpenFeint

]]
local M = {}

function M.new()
    local openfeint = {}

    ----

    function openfeint:init(params)
        CCOpenFeint:postInitWithProductKey(params.productKey,
                                           params.secret,
                                           params.displayName)
        return true
    end

    function openfeint:request(name, params)
        name = string.upper(name)
        if name == "GETACHIEVEMENTS" then
            return CCOpenFeint:getAchievementsLua()

        elseif name == "UNLOCKACHIEVEMENT" then
            local achievementId = tostring(params[1])
            if type(achievementId) ~= "string" then
                ccerror("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "unlockAchievement", "invalid achievementId")
            end

            return CCOpenFeint:unlockAchievement(achievementId)

        elseif name == "GETLEADERBOARDS" then
            return CCOpenFeint:getLeaderboardsLua()

        elseif name == "SETHIGHSCORE" then
            local leaderboardId = params[1]
            if type(leaderboardId) ~= "string" then
                ccerror("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "setHighScore", "invalid leaderboardId")
                return false
            end

            local score = tonumber(params[2])
            if type(score) ~= "number" then
                ccerror("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
                          "setHighScore", "invalid score")
                return false
            end

            local displayText = params[3]
            if type(displayText) ~= "string" then
                ccerror("[qeeplay.api.GameNetwork.OpenFeint] ERR, request(%s) %s",
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

        elseif name == "LEADERBOARD" then
            local leaderboardId = params[1]
            if type(leaderboardId) ~= "string" then
                ccerror("[qeeplay.api.GameNetwork.OpenFeint] ERR, show(%s) %s",
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

return M
