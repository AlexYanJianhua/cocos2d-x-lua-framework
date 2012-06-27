
local M = {}

local display = require("qeeplay.basic.display")

M.TOUCH_BEGAN     = CCTOUCHBEGAN
M.TOUCH_MOVED     = CCTOUCHMOVED
M.TOUCH_ENDED     = CCTOUCHENDED
M.TOUCH_CANCELLED = CCTOUCHCANCELLED

M.DEFAULT_TTF_FONT      = "Arial"
M.DEFAULT_TTF_FONT_SIZE = 16

function M.newMenu(...)
    local menu
    menu = CCMenu:node()
    display.extendNode(menu)

    local item = select(1, ...)
    local items = {}

    if type(item) ~= "table" then
        for i = 1, select("#", ...) do
            items[i] = select(i, ...)
        end
    else
        items = item
    end

    for k, item in pairs(items) do
        menu:addChild(item)
    end

    menu:setPosition(0, 0)
    return menu
end

function M.newMenuItemImage(params)
    local imageNormal   = params.image
    local imageDown     = params.imageDown
    local imageDisabled = params.imageDisabled
    local listener      = params.listener
    local x             = params.x
    local y             = params.y

    if type(imageNormal) == "string" then
        imageNormal = display.newImage(imageNormal)
    end

    if type(imageDown) == "string" then
        imageDown = display.newImage(imageDown)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newImage(imageDisabled)
    end

    local item = CCMenuItemSprite:itemFromNormalSprite(imageNormal, imageDown, imageDisabled)
    if item then
        display.extendSprite(item)
        if type(listener) == "function" then item:registerScriptTapHandler(listener) end
        if x and y then item:setPosition(x, y) end
    end
    return item
end

function M.newBMFontLabel(text, font, x, y, align)
    text = tostring(text)
    local label = CCLabelBMFont:labelWithString(text, font)
    if label then display.extendNode(label) end
    if type(x) == "number" and type(y) == "number" then
        if align then
            label:align(align, x, y)
        else
            label:setPosition(x, y)
        end
    end
    return label
end

function M.newTTFLabel(params)
    ccassert(type(params) == "table",
             "[framework.support.ui] newTTFLabel() invalid params")

    local text = tostring(params.text)
    local font = params.font or DEFAULT_TTF_FONT
    local size = params.size or DEFAULT_TTF_FONT_SIZE
    local color = params.color or display.COLOR_WHITE
    local align = params.align or display.LEFT_CENTER
    local x, y = params.x, params.y

    ccassert(type(size) == "number",
             "[framework.support.ui] newTTFLabel() invalid params.size")

    local label = CCLabelTTF:labelWithString(text, tostring(font), size)
    if label then
        display.extendNode(label)
        label:setColor(color)
        if x and y then label:setPosition(x, y) end
    end
    return label
end

function M.newTTFLabelWithShadow(params)
    ccassert(type(params) == "table",
             "[framework.support.ui] newTTFLabelWithShadow() invalid params")

    local text = tostring(params.text)
    local font = params.font or DEFAULT_TTF_FONT
    local size = params.size or DEFAULT_TTF_FONT_SIZE
    local color = params.color or display.COLOR_WHITE
    local shadowColor = params.shadowColor or display.COLOR_BLACK
    local align = params.align or display.LEFT_CENTER
    local x, y = params.x, params.y

    ccassert(type(size) == "number",
             "[framework.support.ui] newTTFLabelWithShadow() invalid params.size")

    local g = display.newGroup()
    local shadow = M.newTTFLabel({
        text = text,
        font = font,
        size = size,
        color = shadowColor
    })
    shadow:align(align, 0.5, -0.5)
    g:addChild(shadow)
    g.shadow = shadow

    local label = M.newTTFLabel({
        text = text,
        font = font,
        size = size,
        color = color
    })
    label:align(align, 0, 0)
    g:addChild(label)
    g.label = label

    function g:setString(text)
        g.shadow:setString(text)
        g.label:setString(text)
    end

    g.align_ = g.align
    function g:align(align, x, y)
        g.shadow:align(align, 0.5, -0.5)
        g.label:align(align, 0, 0)
        g:setPosition(x, y)
    end

    g.contentSize = g.label.contentSize

    if x and y then g:align(align, x, y) end
    return g
end

return M
