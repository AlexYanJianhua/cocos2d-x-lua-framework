
module("audio", package.seeall)

engine = SimpleAudioEngine:sharedEngine()

local isEnabled = true

function disable()
    isEnabled = false
end

function enable()
    isEnabled = true
end

function preloadMusic(filename)
    if not isEnabled then return end
    engine:preloadBackgroundMusic(filename)
end

function playMusic(filename, isLoop)
    if not isEnabled then return end
    engine:playBackgroundMusic(filename, isLoop or true)
end

function stopMusic(isReleaseData)
    if not isEnabled then return end
    isReleaseData = isReleaseData or false
    engine:stopBackgroundMusic(isReleaseData)
end

function pauseMusic()
    if not isEnabled then return end
    engine:pauseBackgroundMusic()
end

function resumeMusic()
    if not isEnabled then return end
    engine:resumeBackgroundMusic()
end

function rewindMusic()
    if not isEnabled then return end
    ending:rewindBackgroundMusic()
end

function willPlayMusic()
    if not isEnabled then return false end
    return engine:willPlayBackgroundMusic()
end

function isMusicPlaying()
    if not isEnabled then return false end
    return engine:isBackgroundMusicPlaying()
end

function getMusicVolume()
    if not isEnabled then return 0 end
    return engine:getBackgroundMusicVolume()
end

function setMusicVolume(volume)
    if not isEnabled then return end
    engine:setBackgroundMusicVolume(volume)
end

function getEffectsVolume()
    if not isEnabled then return 0 end
    return engine:getEffectsVolume()
end

function setEffectsVolume(volume)
    if not isEnabled then return end
    engine:setEffectsVolume(volume)
end

function switchMusicOnOff()
    if not isEnabled then return end
    if getMusicVolume() <= 0.01 then
        setMusicVolume(1)
    else
        setMusicVolume(0)
    end
end

function switchSoundsOnOff()
    if not isEnabled then return end
    if getEffectsVolume() <= 0.01 then
        setEffectsVolume(1)
    else
        setEffectsVolume(0)
    end
end

function playEffect(filename, isLoop)
    if not isEnabled then return end
    return engine:playEffect(filename, isLoop or false)
end

function stopEffect(handle)
    if not isEnabled then return end
    engine:stopEffect(handle)
end

function preloadEffect(filename)
    if not isEnabled then return end
    engine:preloadEffect(filename)
end

function unloadEffect(filename)
    if not isEnabled then return end
    engine:unloadEffect(filename)
end

local handleFadeMusicVolumeTo = nil
function fadeMusicVolumeTo(time, volume)
    if not isEnabled then return end
    local currentVolume = getMusicVolume()
    if volume == currentVolume then return end

    if handleFadeMusicVolumeTo then
        scheduler.remove(handleFadeMusicVolumeTo)
    end
    local stepVolume = (volume - currentVolume) / time * (1.0 / 60)
    local isIncr     = volume > currentVolume

    local function changeVolumeStep()
        currentVolume = currentVolume + stepVolume
        if (isIncr and currentVolume >= volume)
           or (not isIncr and currentVolume <= volume) then
            currentVolume = volume
            scheduler.remove(handleFadeMusicVolumeTo)
        end
        setMusicVolume(currentVolume)
    end

    handleFadeMusicVolumeTo = scheduler.enterFrame(changeVolumeStep, false)
end

local handleFadeToMusic = nil
function fadeToMusic(music, time, volume)
    if not isEnabled then return end
    if handleFadeToMusic then scheduler.remove(handleFadeToMusic) end
    time = time / 2
    if type(volume) ~= "number" then volume = 1.0 end
    fadeMusicVolumeTo(volume, 0)
    handleFadeToMusic = scheduler.performWithDelay(time + 0.1, function()
        playMusic(music)
        fadeMusicVolumeTo(time, volume)
    end)
end
