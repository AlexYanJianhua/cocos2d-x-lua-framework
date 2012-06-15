
module(..., package.seeall)

ERROR_INVALID_FILE_CONTENTS = -1
ERROR_HASH_MISS_MATCH       = -2
ERROR_STATE_FILE_NOT_FOUND  = -3

--[[

提供游戏状态读取和保存

- GameState.init() 初始化
- GameState.load() 读取游戏状态文件，返回一个包含游戏状态数据的数组
- GameState.save() 将指定数组的数据存入游戏状态文件

使用方法：

-- 定义游戏状态默认值
local defaults = {
    lastUnlockedLevel = 0,  -- 最后一个解锁的关卡
    numCoins = 1000,        -- 玩家的金币总数
}

local function stateEventListener(event, state)
    ....
end

qeeplay.api.GameState.init(stateEventListener, "gamestate.bin", secretKey)
local state = qeeplay.api.GameState.load()
qeeplay.api.GameState.save(state)

]]--

-- 加密文件的头
ENCODE_HEAD = "=Q2="

-- 存档文件名
local stateFilename = "state.txt"

-- 事件处理函数
local eventListener = nil

-- 加密的密钥
local secretKey     = nil

local function isEncodedContents_(contents)
    return string.sub(contents, 1, string.len(ENCODE_HEAD)) == ENCODE_HEAD
end

local function encode_(state)
    local s = crypto.encodeBase64(json.encode(state))
    local hash = crypto.md5(s..secretKey)
    local contents = json.encode({h = hash, s = s})
    return ENCODE_HEAD..contents
end

local function decode_(fileContents)
    local contents = string.sub(fileContents, string.len(ENCODE_HEAD) + 1)
    local j = json.decode(contents)

    if type(j) ~= "table" then
        log.error("[qeeplay.api.GameState] ERR, decode_() invalid contents")
        return {errorCode = ERROR_INVALID_FILE_CONTENTS}
    end

    local hash,s = j.h, j.s
    local testHash = crypto.md5(s..secretKey)
    if testHash ~= hash then
        log.error("[qeeplay.api.GameState] ERR, decode_() hash miss match")
        return {errorCode = ERROR_HASH_MISS_MATCH}
    end

    local state = json.decode(crypto.decodeBase64(s))

    if type(state) ~= "table" then
        log.error("[qeeplay.api.GameState] ERR, decode_() invalid state data")
        return {errorCode = ERROR_INVALID_FILE_CONTENTS}
    end

    return {state = state}
end

----

function init(eventListener_, stateFilename_, secretKey_)
    if type(eventListener_) ~= "function" then
        log.error("[qeeplay.api.GameState] ERR, init() invalid eventListener")
        return false
    end

    eventListener = eventListener_

    if type(stateFilename_) == "string" then
        stateFilename = stateFilename_
    end

    if type(secretKey_) == "string" then
        secretKey = secretKey_
    end

    eventListener({
        name = "init",
        filename = getGameStatePath(),
        encode = type(secretKey) == "string"
    })

    return true
end

--[[ Load state data from file, return values ]]
function load()
    local filename = getGameStatePath()

    if not io.exists(filename) then
        log.warning("[qeeplay.api.GameState] load() file \"%s\" not found", filename)
        return eventListener{name = "load", errorCode = ERROR_STATE_FILE_NOT_FOUND}
    end

    local contents = io.readfile(filename)
    log.warning("[qeeplay.api.GameState] load() get values from \"%s\"", filename)

    local state
    local encode = false

    if secretKey and isEncodedContents_(contents) then
        local d = decode_(contents)
        if d.errorCode then
            return eventListener({name = "load", errorCode = d.errorCode})
        end

        state = d.state
        encode = true
    else
        state = json.decode(contents)
        if type(state) ~= "table" then
            log.error("[qeeplay.api.GameState] ERR, load() invalid data")
            return eventListener({name = "load", errorCode = ERROR_INVALID_FILE_CONTENTS})
        end
    end

    return eventListener({name = "load", state = state, encode = encode, time = os.time()})
end

--[[ save values to state file]]
function save(newState)
    state = eventListener({
        name = "save",
        state = newState,
        encode = type(secretKey) == "string"
    })
    if type(state) ~= "table" then
        log.error("[qeeplay.api.GameState] ERR, save() listener return invalid data")
        return false
    end

    local filename = getGameStatePath()
    local ret = false
    if secretKey then
        ret = io.writefile(filename, encode_(state))
    else
        local json = json.encode(state)
        if type(json) == "string" then
            ret = io.writefile(filename, json)
        end
    end

    log.warning("[qeeplay.api.GameState] save() update file \"%s\"", filename)
    return ret
end

-- 确定游戏状态数据文件名
function getGameStatePath()
    return io.pathForFile(stateFilename, device.writeablePath)
end
