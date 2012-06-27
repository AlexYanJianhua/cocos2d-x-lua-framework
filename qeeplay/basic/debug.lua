
function cctraceback()
    ccprintf(debug.traceback())
end

function ccprintf(fmt, ...)
    local output = string.format(fmt, select(1, ...))
    CCLuaLog(output)
end

function ccassert(expr, message, ...)
    if expr then return expr end
    local output = string.format(message, select(1, ...))
    error(output, 2)
end

-- prints human-readable information about a variable
function ccdump(object, label, nesting, nest)
    if type(nesting) ~= "number" then nesting = 99 end

    local lookup_table = {}
    local function _ccdump(object, label, indent, nest)
        label = label or "<var>"
        if type(object) ~= "table" then
            ccprintf(string.format("%s%s = %s", indent, tostring(label), tostring(object)..""))
        elseif lookup_table[object] then
            ccprintf(string.format("%s%s = *REF*", indent, tostring(label)))
        else
            lookup_table[object] = true
            if nest > nesting then
                ccprintf(string.format("%s%s = *MAX NESTING*", indent, label))
            else
                ccprintf(string.format("%s%s = {", indent, tostring(label)))
                local indent2 = indent.."    "
                for k, v in pairs(object) do
                    _ccdump(v, k, indent2, nest + 1)
                end
                ccprintf(string.format("%s}", indent))
            end
        end
    end
    _ccdump(object, label, "- ", 1)
end
