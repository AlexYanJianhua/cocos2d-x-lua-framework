
local M = {}

local scheduler = require("qeeplay.basic.scheduler")

local engine    = SimpleAudioEngine:sharedEngine()
local isEnabled = true

function M.disable()
    isEnabled = false
end

function M.enable()
    isEnabled = true
end

function M.preloadMusic(filename)
    if not isEnabled then return end
    engine:preloadBackgroundMusic(filename)
end

function M.playMusic(filename, isLoop)
    if not isEnabled then return end
    if type(isLoop) ~= "boolean" then isLoop = true end
    engine:playBackgroundMusic(filename, isLoop)
end

function M.stopMusic(isReleaseData)
    if not isEnabled then return end
    if type(isReleaseData) ~= "boolean" then isReleaseData = false end
    engine:stopBackgroundMusic(isReleaseData)
end

function M.pauseMusic()
    if not isEnabled then return end
    engine:pauseBackgroundMusic()
end

function M.resumeMusic()
    if not isEnabled then return end
    engine:resumeBackgroundMusic()
end

function M.rewindMusic()
    if not isEnabled then return end
    ending:rewindBackgroundMusic()
end

function M.willPlayMusic()
    if not isEnabled then return false end
    return engine:willPlayBackgroundMusic()
end

function M.isMusicPlaying()
    if not isEnabled then return false end
    return engine:isBackgroundMusicPlaying()
end

function M.getMusicVolume()
    if not isEnabled then return 0 end
    return engine:getBackgroundMusicVolume()
end

function M.setMusicVolume(volume)
    if not isEnabled then return end
    engine:setBackgroundMusicVolume(volume)
end

function M.getEffectsVolume()
    if not isEnabled then return 0 end
    return engine:getEffectsVolume()
end

function M.setEffectsVolume(volume)
    if not isEnabled then return end
    engine:setEffectsVolume(volume)
end

function M.switchMusicOnOff()
    if not isEnabled then return end
    if M.getMusicVolume() <= 0.01 then
        M.setMusicVolume(1)
    else
        M.setMusicVolume(0)
    end
end

function M.switchSoundsOnOff()
    if not isEnabled then return end
    if M.getEffectsVolume() <= 0.01 then
        M.setEffectsVolume(1)
    else
        M.setEffectsVolume(0)
    end
end

function M.playEffect(filename, isLoop)
    if not isEnabled then return end
    if type(isLoop) ~= "boolean" then isLoop = false end
    return engine:playEffect(filename, isLoop)
end

function M.stopEffect(handle)
    if not isEnabled then return end
    engine:stopEffect(handle)
end

function M.preloadEffect(filename)
    if not isEnabled then return end
    engine:preloadEffect(filename)
end

function M.unloadEffect(filename)
    if not isEnabled then return end
    engine:unloadEffect(filename)
end

local handleFadeMusicVolumeTo = nil
function M.fadeMusicVolumeTo(time, volume)
    if not isEnabled then return end
    local currentVolume = M.getMusicVolume()
    if volume == currentVolume then return end

    if handleFadeMusicVolumeTo then
        scheduler.remove(handleFadeMusicVolumeTo)
    end
    local stepVolume = (volume - currentVolume) / time * (1.0 / 60)
    local isIncr     = volume > currentVolume

    local function changeVolumeStep()
        currentVolume = currentVolume + stepVolume
        if (isIncr and currentVolume >= volume) or (not isIncr and currentVolume <= volume) then
            currentVolume = volume
            scheduler.remove(handleFadeMusicVolumeTo)
        end
        M.setMusicVolume(currentVolume)
    end

    handleFadeMusicVolumeTo = scheduler.enterFrame(changeVolumeStep, false)
end

local handleFadeToMusic = nil
function M.fadeToMusic(music, time, volume, isLoop)
    if not isEnabled then return end
    if handleFadeToMusic then scheduler.remove(handleFadeToMusic) end
    time = time / 2
    if type(volume) ~= "number" then volume = 1.0 end
    M.fadeMusicVolumeTo(volume, 0)
    handleFadeToMusic = scheduler.performWithDelay(time + 0.1, function()
        M.playMusic(music, isLoop)
        M.fadeMusicVolumeTo(time, volume)
    end)
end

return M
