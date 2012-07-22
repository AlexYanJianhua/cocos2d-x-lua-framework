
local M = {}

local display = require("qeeplay.basic.display")

M.DEFAULT_TTF_FONT      = "Arial"
M.DEFAULT_TTF_FONT_SIZE = 16

M.TEXT_ALIGN_LEFT   = CCTextAlignmentLeft
M.TEXT_ALIGN_CENTER = CCTextAlignmentCenter
M.TEXT_ALIGN_RIGHT  = CCTextAlignmentRight

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
    local tag           = params.tag
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
        if tag then item:setTag(tag) end
    end
    return item
end

function M.newBMFontLabel(text, font, x, y, textAlign)
    text = tostring(text)
    local label = CCLabelBMFont:labelWithString(text, font)
    if not label then return end

    display.extendNode(label)
    if type(x) == "number" and type(y) == "number" then
        if textAlign then
            label:textAlign(textAlign, x, y)
        else
            label:setPosition(x, y)
        end
    end
    return label
end

function M.newTTFLabel(params)
    ccassert(type(params) == "table",
             "[qeeplay.basic.ui] newTTFLabel() invalid params")

    local text       = tostring(params.text)
    local font       = params.font or M.DEFAULT_TTF_FONT
    local size       = params.size or M.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or M.TEXT_ALIGN_LEFT
    local x, y       = params.x, params.y
    local dimensions = params.dimensions

    ccassert(type(size) == "number",
             "[qeeplay.basic.ui] newTTFLabel() invalid params.size")

    local label
    if dimensions then
        label = CCLabelTTF:labelWithString(text, dimensions, textAlign, font, size)
    else
        label = CCLabelTTF:labelWithString(text, font, size)
    end
    if label then
        display.extendNode(label)
        label:setColor(color)

        function label:realign(x, y)
            if textAlign == M.TEXT_ALIGN_LEFT then
                label:setPosition(x + label.contentSize.width / 2, y)
            elseif textAlign == M.TEXT_ALIGN_RIGHT then
                label:setPosition(x - label.contentSize.width / 2, y)
            else
                label:setPosition(x, y)
            end
        end

        if x and y then label:realign(x, y) end
    end
    return label
end

function M.newTTFLabelWithShadow(params)
    ccassert(type(params) == "table",
             "[qeeplay.basic.ui] newTTFLabelWithShadow() invalid params")

    local color       = params.color or display.COLOR_WHITE
    local shadowColor = params.shadowColor or display.COLOR_BLACK
    local x, y        = params.x, params.y

    local g = display.newGroup()
    params.color = shadowColor
    params.x, params.y = nil, nil
    g.shadow = M.newTTFLabel(params)
    g.shadow:realign(0.5, -0.5)
    g:addChild(g.shadow)

    params.color = color
    g.label = M.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow:setString(text)
        g.label:setString(text)
    end

    g.contentSize = g.label.contentSize

    if x and y then g:setPosition(x, y) end
    return g
end

return M
