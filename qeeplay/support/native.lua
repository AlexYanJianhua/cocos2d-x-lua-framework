
module("native", package.seeall)

function showActivityIndicator(style)
    if type(style) ~= "number" then
        style = CCActivityIndicatorViewStyleWhiteLarge
    end
    CCNative:showActivityIndicator(style)
end

function hideActivityIndicator()
    CCNative:hideActivityIndicator()
end

local function emptyListener()
end

function showAlert(title, message, cancelButtonTitle, listener, ...)
    CCNative:createAlert(title, message, cancelButtonTitle)
    for i = 1, select("#", ...) do
        local buttonTitle = select(i, ...)
        CCNative:addAlertButton(buttonTitle)
    end
    if type(listener) ~= "function" then listener = emptyListener end
    CCNative:showAlertLua(listener)
end

function cancelAlert()
    CCNative:cancelAlert()
end

function getOpenUDID()
    return CCNative:getOpenUDID()
end
