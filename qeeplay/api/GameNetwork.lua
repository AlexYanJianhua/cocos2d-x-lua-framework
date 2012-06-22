
--[[

## Overview

Game Network allows access to 3rd party libraries that enables social gaming features
such as public leaderboards and achievements.

Currently, the OpenFeint and Game Center (iOS only) libraries are supported.

If you want to use both OpenFeint and Game Center, iOS OpenFeint will post achievement
updates and leaderboard updates to Game Center provided OFGameCenter.plist is present
in the project folder.

See http://support.openfeint.com/dev/game-center-compatibility/ for details.

]]
module(..., package.seeall)

local instance

--[[ Initializes an app with the parameters (e.g., product key, secret, display name, etc.)
required by the game network provider.

**Syntax:**

    -- OpenFeint
    gameNetwork.init("openfeint", {
        productKey  = ...,
        secret      = ...,
        displayName = ...,
    })

    -- GameCenter
    gameNetwork.init("gamecenter", {
        listener = ...
    })

**Example:**

    require("qeeplay.api.GameNetwork")
    qeeplay.api.GameNetwork.init("openfeint", {
        productKey  = ...,
        secret      = ...,
        displayName = ...
    })

    --
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

**Parameters:**

-   providerName:

    String of the game network provider. ("openfeint" or "gamecenter", case insensitive)

-   params:

    Additional parameters required by the "openfeint" provider.

    -   productKey: String of your application's OpenFeint product key (provided by OpenFeint).
    -   secret: String of your application's product secret (provided by OpenFeint).
    -   displayName: String of the name to display in OpenFeint leaderboards and other views.

    If using GameCenter, the params.listener allows you to specify a callback function.
    (Instead of secret keys, your bundle identifier is used automatically to identify your app.)
    On successful login, event.data will be 'true'. On unsuccessful init, event.data will be false.
    When problems such as network errors occur, event.errorCode (integer) and event.errorString
    (string) will be defined.

    Also be aware that iOS backgrounding will cause your app to automatically log out your user
    from Game Center. When the app is resumed, Game Center will automatically try to re-login
    your user. The callback function you specified here will be invoked again telling you the
    result of that re-login attempt. Thus, this callback function exists for the life of your
    application. With Game Center, it is advisable to avoid calling other Game Center functions
    when the user is not logged in.

**Returns:**

Nothing.

**Note:**

GameNetwork only supports one provider at a time (you cannot call this API multiple times for
different providers).

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
    instance:init(params)
end

--[[ Send or request information to/from the game network provider.

**Syntax:**

    GameNetwork.request( command [, params ...] )

**Example:**

    -- For OpenFeint:
    -- setHighScore, leaderboard id, score, display text
    GameNetwork.request("setHighScore", "abc123", 99, "99 sec")

    -- unlockAchievement, achievement id
    GameNetwork.request("unlockAchievement", "1242345322")

**Parameters:**

-   command:

    Command string supported by the provider (case insensitive).

-   params ...:

    Parmeters used in the commands.

**Returns:**

Nothing.

----

**OpenFeint**

Command supported by the OpenFeint provider:

-   getAchievements:

        local achievements = qeeplay.api.GameNetwork.request("getAchievements")
        for achievementId, achievement in pairs(achievements) do
            -- achievement.id (string)
            -- achievement.title (string)
            -- achievement.description (string)
            -- achievement.iconUrl (string)
            -- achievement.gameScore (integer)
            -- achievement.isUnlocked (boolean)
            -- achievement.isSecret (boolean)
        end

-   unlockAchievement: achievement id

        qeeplay.api.GameNetwork.request("unlockAchievement", "1242345322")

-   getLeaderboards:

        local leaderboards = qeeplay.api.GameNetwork.request("getLeaderboards")
        for i, leaderboard = ipairs(leaderboards) do
            -- leaderboard.id (string)
            -- leaderboard.name (string)
            -- leaderboard.currentUserScore (integer)
            -- leaderboard.currentUserScoreDisplayText (string)
            -- leaderboard.descendingScoreOrder (boolean)
        end

-   setHighScore: leaderboard id, score, display text

        qeeplay.api.GameNetwork.request("setHighScore", "abc123", 99, "99 sec")


**GameCenter**

Coming soon.

]]
function request(name, ...)
    if not instance then return end
    local params = {}
    for i = 1, select("#", ...) do
        params[i] = select(i, ...)
    end
    return instance:request(name, params)
end

--[[ Shows (displays) information from game network provider on the screen.

For OpenFeint provider, launches the OpenFeint dashboard in one of the following configurations: leaderboards, challenges, achievements, friends, playing or high score.

**Syntax:**

    qeeplay.api.GameNetwork.show(command [, params] )

**Example:**

    qeeplay.api.GameNetwork("leaderboards")

**Parameters:**

-   command:

    Strings supported by provider.

-   params ...:

    Parameters used by command.

**Returns:**

Nothing.

----

**OpenFeint**

Command supported by the OpenFeint provider:

-   leaderboard: leaderboard id

        qeeplay.api.GameNetwork.show("leaderboard", "abc123")

-   leaderboards:

        qeeplay.api.GameNetwork.show("leaderboards")

-   achievements:

        qeeplay.api.GameNetwork.show("achievements")

-   challenges:

        qeeplay.api.GameNetwork.show("challenges")

-   friends:

        qeeplay.api.GameNetwork.show("friends")

-   playing:

        qeeplay.api.GameNetwork.show("playing")

-   dashboard:

        qeeplay.api.GameNetwork.show("dashboard")


**GameCenter**

Coming soon.

]]
function show(name, ...)
    if not instance then return end
    local params = {}
    for i = 1, select("#", ...) do
        params[i] = select(i, ...)
    end
    instance:show(name, params)
end
