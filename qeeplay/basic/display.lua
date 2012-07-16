
function ccp(x, y)
    return CCPoint(x, y)
end

function ccsize(width, height)
    return CCSize(width, height)
end

local M = {}

local director = CCDirector:sharedDirector()
M.director = director

local sharedTextureCache = CCTextureCache:sharedTextureCache()
local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()

-- landscape, landscape_right
-- landscape_left
-- portrait
-- upside_down
M.orientationPortrait       = "portrait"
M.orientationUpsideDown     = "upside_down"
M.orientationLandscapeLeft  = "landscape_left"
M.orientationLandscapeRight = "landscape_right"

local orientation_
if DEVICE_ORIENTATION then
    orientation_ = string.lower(DEVICE_ORIENTATION)
    if orientation_ == "landscape"
       or orientation_ == "landscape_right"
       or orientation_ == "landscaperight" then
        orientation_ = M.orientationLandscapeRight
    elseif orientation_ == "landscape_left" or orientation_ == "landscapeleft" then
        orientation_ = M.orientationLandscapeLeft
    elseif orientation_ == "upside_down" or orientation_ == "upsidedown" then
        orientation_ = M.orientationUpsideDown
    else
        orientation_ = M.orientationPortrait
    end
else
    orientation_ = director:getDeviceOrientation()
    if orientation_ == kCCDeviceOrientationLandscapeLeft then
        orientation_ = M.orientationLandscapeLeft
    elseif orientation_ == kCCDeviceOrientationLandscapeRight then
        orientation_ = M.orientationLandscapeRight
    elseif orientation_ == kCCDeviceOrientationPortraitUpsideDown then
        orientation_ = M.orientationUpsideDown
    else
        orientation_ = M.orientationPortrait
    end
end
M.orientation = orientation_

M.sizeInPixels    = director:getWinSizeInPixels()
M.screenWidth     = M.sizeInPixels.width
M.screenHeight    = M.sizeInPixels.height
M.isRetinaDisplay = director:isRetinaDisplay()
M.scaleFactor     = director:getContentScaleFactor()

M.screenType = "iphone"
if M.orientation == M.orientationLandscapeLeft
    or M.orientation == M.orientationLandscapeRight then
    if M.screenWidth == 1024 or M.screenWidth == 2048 then
        M.screenType = "ipad"
    end
else
    if M.screenWidth == 768 or M.screenHeight == 1536 then
        M.screenType = "ipad"
    end
end

M.size              = director:getWinSize()
M.width             = M.size.width
M.height            = M.size.height
M.centerX           = M.width / 2
M.centerY           = M.height / 2
M.left              = 0
M.right             = M.width - 1
M.top               = M.height - 1
M.bottom            = 0
M.sizeInPixels      = director:getWinSizeInPixels()
M.widthInPixels     = M.sizeInPixels.width
M.heightInPixels    = M.sizeInPixels.height
M.centerXInPixels   = M.widthInPixels / 2
M.centerYInPixels   = M.heightInPixels / 2
M.animationInterval = director:getAnimationInterval()

M.c_width  = 480
M.c_height = 320
local ptScale = 1
if M.screenType == "ipad" then
    M.c_height = 340
    ptScale = 2 * 1.066666667
end
M.c_halfwidth  = M.c_width / 2
M.c_halfheight = M.c_height / 2
M.c_left       = -M.c_halfwidth
M.c_right      = M.c_halfwidth
M.c_top        = M.c_halfheight
M.c_bottom     = -M.c_halfheight

function xy(v)
    return v * ptScale
end

M.COLOR_WHITE = ccc3(255, 255, 255)
M.COLOR_BLACK = ccc3(0, 0, 0)

M.CENTER        = 1
M.LEFT_TOP      = 2; M.TOP_LEFT      = 2
M.CENTER_TOP    = 3; M.TOP_CENTER    = 3
M.RIGHT_TOP     = 4; M.TOP_RIGHT     = 4
M.CENTER_LEFT   = 5; M.LEFT_CENTER   = 5
M.CENTER_RIGHT  = 6; M.RIGHT_CENTER  = 6
M.BOTTOM_LEFT   = 7; M.LEFT_BOTTOM   = 7
M.BOTTOM_RIGHT  = 8; M.RIGHT_BOTTOM  = 8
M.BOTTOM_CENTER = 9; M.CENTER_BOTTOM = 9

ccwarning("# display.isRetinaDisplay      = "..tostring(M.isRetinaDisplay))
ccwarning("# display.screenType           = "..M.screenType)
ccwarning("# display.screenWidth          = "..M.screenWidth)
ccwarning("# display.screenHeight         = "..M.screenHeight)
ccwarning("# display.scaleFactor          = "..M.scaleFactor)
ccwarning("# display.orientation          = "..M.orientation)
ccwarning("# display.width                = "..M.width)
ccwarning("# display.height               = "..M.height)
ccwarning("# display.centerX              = "..M.centerX)
ccwarning("# display.centerY              = "..M.centerY)
ccwarning("# display.left                 = "..M.left)
ccwarning("# display.right                = "..M.right)
ccwarning("# display.top                  = "..M.top)
ccwarning("# display.bottom               = "..M.bottom)
ccwarning("#")

----------------------------------------
-- scenes
----------------------------------------

local SCENE_TRANSITIONS = {}
SCENE_TRANSITIONS["CROSSFADE"]       = {CCTransitionCrossFade, 2}
SCENE_TRANSITIONS["FADE"]            = {CCTransitionFade, 3, ccc3(0, 0, 0)}
SCENE_TRANSITIONS["FADEBL"]          = {CCTransitionFadeBL, 2}
SCENE_TRANSITIONS["FADEDOWN"]        = {CCTransitionFadeDown, 2}
SCENE_TRANSITIONS["FADETR"]          = {CCTransitionFadeTR, 2}
SCENE_TRANSITIONS["FADEUP"]          = {CCTransitionFadeUp, 2}

SCENE_TRANSITIONS["FLIPANGULAR"]     = {CCTransitionFlipAngular, 3, kOrientationLeftOver}
SCENE_TRANSITIONS["FLIPX"]           = {CCTransitionFlipX, 3, kOrientationLeftOver}
SCENE_TRANSITIONS["FLIPY"]           = {CCTransitionFlipY, 3, kOrientationUpOver}
SCENE_TRANSITIONS["ZOOMFLIPX"]       = {CCTransitionZoomFlipX, 3, kOrientationLeftOver}
SCENE_TRANSITIONS["ZOOMFLIPY"]       = {CCTransitionZoomFlipY, 3, kOrientationUpOver}

SCENE_TRANSITIONS["JUMPZOOM"]        = {CCTransitionJumpZoom, 2}
SCENE_TRANSITIONS["ROTOZOOM"]        = {CCTransitionRotoZoom, 2}

SCENE_TRANSITIONS["MOVEINB"]         = {CCTransitionMoveInB, 2}
SCENE_TRANSITIONS["MOVEINL"]         = {CCTransitionMoveInL, 2}
SCENE_TRANSITIONS["MOVEINR"]         = {CCTransitionMoveInR, 2}
SCENE_TRANSITIONS["MOVEINT"]         = {CCTransitionMoveInT, 2}

SCENE_TRANSITIONS["SLIDEINB"]        = {CCTransitionSlideInB, 2}
SCENE_TRANSITIONS["SLIDEINL"]        = {CCTransitionSlideInL, 2}
SCENE_TRANSITIONS["SLIDEINR"]        = {CCTransitionSlideInR, 2}
SCENE_TRANSITIONS["SLIDEINT"]        = {CCTransitionSlideInT, 2}

SCENE_TRANSITIONS["SHRINKGROW"]      = {CCTransitionShrinkGrow, 2}
SCENE_TRANSITIONS["SPLITCOLS"]       = {CCTransitionSplitCols, 2}
SCENE_TRANSITIONS["SPLITROWS"]       = {CCTransitionSplitRows, 2}
SCENE_TRANSITIONS["TURNOFFTILES"]    = {CCTransitionTurnOffTiles, 2}

SCENE_TRANSITIONS["SCENEORIENTED"]   = {CCTransitionSceneOriented, 3, kOrientationLeftOver}
SCENE_TRANSITIONS["ZOOMFLIPANGULAR"] = {CCTransitionZoomFlipAngular, 2}

SCENE_TRANSITIONS["PAGETURN"]        = {CCTransitionPageTurn, 3, false}
SCENE_TRANSITIONS["RADIALCCW"]       = {CCTransitionRadialCCW, 2}
SCENE_TRANSITIONS["RADIALCW"]        = {CCTransitionRadialCW, 2}

local function newSceneWithTransition(scene, transitionName, time, more)
    local key = string.upper(tostring(transitionName))
    if string.sub(key, 1, 12) == "CCTRANSITION" then
        key = string.sub(key, 13)
    end

    if SCENE_TRANSITIONS[key] then
        local cls, count, default = unpack(SCENE_TRANSITIONS[key])
        transitionTime = transitionTime or 0.2

        if count == 3 then
            scene = cls:transitionWithDuration(time, scene, more or default)
        else
            scene = cls:transitionWithDuration(time, scene)
        end
    end
    return scene
end

function M.newScene(name)
    local scene = CCScene:node()
    scene.name = name or "<none-name>"
    scene.isTouchEnabled = false
    return M.extendScene(scene)
end

function M.extendScene(scene)
    local function sceneEventHandler(eventType)
        if eventType == kCCNodeOnEnter then
            ccwarning("## Scene \"%s:onEnter()\"", scene.name)
            scene.isTouchEnabled = true
            if scene.onEnter then scene:onEnter() end
        else
            ccwarning("## Scene \"%s:onExit()\"", scene.name)
            scene.isTouchEnabled = false
            if scene.onExit then scene:onExit() end
        end
    end

    scene:registerScriptHandler(sceneEventHandler)

    return scene
end

--[[--

replaces the running scene with a new one.

**Usage:**

    M.replaceScene(newScene, [transition mode, transition time, [more parameter] ])

**Example:**

    M.replaceScene(newScene)
    M.replaceScene(newScene, "crossFade", 0.5)
    M.replaceScene(newScene, "fade", 0.5, ccc3(255, 255, 255))

--]]
function M.replaceScene(nextScene, transition_, transitionTime, more)
    local current = director:getRunningScene()
    if current then
        scheduler.unscheduleAll()
        if current.beforeExit then current:beforeExit() end
        nextScene = newSceneWithTransition(nextScene, transition_, transitionTime, more)
        director:replaceScene(nextScene)
    else
        director:runWithScene(nextScene)
    end
end

function M.getRunningScene()
    return director:getRunningScene()
end

function M.pause()
    director:pause()
end

function M.resume()
    director:resume()
end


----------------------------------------
-- nodes
----------------------------------------

local ANCHOR_POINTS = {
    ccp(0.5, 0.5),  -- CENTER
    ccp(0, 1),      -- TOP_LEFT
    ccp(0.5, 1),    -- TOP_CENTER
    ccp(1, 1),      -- TOP_RIGHT
    ccp(0, 0.5),    -- CENTER_LEFT
    ccp(1, 0.5),    -- CENTER_RIGHT
    ccp(0, 0),      -- BOTTOM_LEFT
    ccp(1, 0),      -- BOTTOM_RIGHT
    ccp(0.5, 0),    -- BOTTOM_CENTER
}

function M.align(node, anchorPoint, x, y)
    node:setAnchorPoint(ANCHOR_POINTS[anchorPoint])
    node:setPosition(x, y)
end

function M.newLayer()
    return M.extendLayer(M.extendNode(CCLayer:node()))
end

function M.newGroup()
    return M.extendNode(CCNode:node())
end

function M.newSprite(filename, x, y)
    local sprite
    if string.sub(filename, 1, 1) == "#" then
        sprite = CCSprite:spriteWithSpriteFrameName(string.sub(filename, 2))
    else
        sprite = CCSprite:spriteWithFile(filename)
    end

    if sprite == nil then
        ccerror("[display] ERR, newSprite() not found image: %s", filename)
    end

    local sprite = M.extendSprite(M.extendNode(sprite))
    sprite:setPosition(x, y)
    return sprite
end
M.newImage = M.newSprite

function M.newBackgroundSprite(filename)
    return M.newSprite(filename, M.centerX, M.centerY)
end
M.newBackgroundImage = M.newBackgroundSprite

function M.addSpriteFramesWithFile(plistFilename, image)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistFilename, image)
end

function M.removeSpriteFramesWithFile(plistFilename, image)
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistFilename)
    CCTextureCache:sharedTextureCache():removeTextureForKey(image);
end

function M.newBatchNode(image, capacity)
    capacity = capacity or 29
    local node
    if type(image) == "string" then
        node = CCSpriteBatchNode:batchNodeWithFile(image, capacity)
    else
        node = CCSpriteBatchNode:batchNodeWithTexture(image, capacity)
    end
    return M.extendNode(node)
end

function M.newSpriteWithFrame(frame, x, y)
    local sprite = CCSprite:spriteWithSpriteFrame(frame)
    if sprite == nil then
        ccerror("[display] ERR, newSpriteWithFrame() not found image: %s", filename)
    end
    local sprite = M.extendSprite(M.extendNode(sprite))
    sprite:setPosition(x, y)
    return sprite
end

--[[--

create multiple frames by pattern

**Usage:**

    M.newFrames(pattern, begin, length)

**Example:**

    -- create array [walk_01.png -> walk_20.png]
    M.newBatchNodeWithDataAndImage("walk.plist", "walk.png")
    local frames = M.newFrames("walk_%02d.png", 1, 20)

]]
function M.newFrames(pattern, begin, length)
    local frames = {}
    for index = begin, begin + length - 1 do
        local frameName = string.format(pattern, index)
        local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
        frames[#frames + 1] = frame
    end
    return frames
end

--[[--

create animation

**Usage:**

    M.newAnimation(frames, time)

**Example:**

    local frames    = M.newFrames("walk_%02d.png", 1, 20)
    local animation = M.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames

]]
function M.newAnimation(frames, time)
    local count = #frames
    local array = CCMutableArray_CCSpriteFrame__:new()
    array:autorelease()
    for i = 1, count do
        array:addObject(frames[i])
    end

    time = time or 1.0 / count
    return CCAnimation:animationWithFrames(array, time)
end

--[[

create animate

**Usage:**

    M.newAnimate(animation, isRestoreOriginalFrame)

**Example:**

    local frames = M.newFrames("walk_%02d.png", 1, 20)
    local sprite = M.newSpriteWithFrame(frames[1])

    local animation = M.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames
    local animate = M.newAnimate(animation)
    sprite:runAnimateRepeatForever(animate)

]]
function M.newAnimate(animation, isRestoreOriginalFrame)
    if type(isRestoreOriginalFrame) ~= "boolean" then isRestoreOriginalFrame = false end
    return CCAnimate:actionWithAnimation(animation, isRestoreOriginalFrame)
end

----------------------------------------
-- binding
----------------------------------------

function M.extendNode(node)
    node.removeFromParentAndCleanup_ = node.removeFromParentAndCleanup
    function node:removeFromParentAndCleanup(isCleanup)
        if type(isCleanup) ~= "boolean" then isCleanup = true end
        self:removeFromParentAndCleanup_(isCleanup)
    end

    node.setPosition_ = node.setPosition
    function node:setPosition(x, y)
        if type(x) == "number" and type(y) == "number" then
            node:setPosition_(x, y)
        end
    end

    function node:removeSelf(isCleanup)
        self:removeFromParentAndCleanup(isCleanup)
    end

    function node:align(anchorPoint, x, y)
        M.align(self, anchorPoint, x, y)
    end

    node.insert = node.addChild

    return node
end

function M.extendLayer(node)
    function node:addTouchEventListener(listener, isMultiTouches, priority, swallowsTouches)
        if type(isMultiTouches) ~= "boolean" then isMultiTouches = false end
        if type(priority) ~= "number" then priority = 0 end
        if type(swallowsTouches) ~= "boolean" then swallowsTouches = false end
        self:registerScriptTouchHandler(listener, isMultiTouches, priority, swallowsTouches)
    end

    function node:removeTouchEventListener()
        self:unregisterScriptTouchHandler()
    end

    return node
end

function M.extendSprite(node)
    function node:runAnimateRepeatForever(animate)
        self:runAction(CCRepeatForever:actionWithAction(animate))
    end

    return node
end

return M
