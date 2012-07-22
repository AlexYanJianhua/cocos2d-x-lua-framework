
function cctraceback()
    ccprintf(debug.traceback())
end

function ccprintf(fmt, ...)
    local output = string.format(fmt, ...)
    CCLuaLog(output)
end

function ccvardump(...)
    local count = select("#", ...)
    if count < 1 then return end

    ccprintf("ccvardump:")
    for i = 1, count do
        local v = select(i, ...)
        local t = type(v)
        if t == "string" then
            ccprintf("  %02d: [string] %s", i, v)
        elseif t == "boolean" then
            ccprintf("  %02d: [boolean] %s", i, tostring(v))
        elseif t == "number" then
            ccprintf("  %02d: [number] %0.2f", i, v)
        else
            ccprintf("  %02d: [%s] %s", i, t, tostring(v))
        end
    end
end

function ccassert(expr, message, ...)
    if expr then return expr end
    local output = string.format(message, ...)
    error(output)
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
                local keys = {}
                for k, v in pairs(object) do
                    keys[#keys + 1] = k
                end
                table.sort(keys)
                for i, k in ipairs(keys) do
                    _ccdump(object[k], k, indent2, nest + 1)
                end
                ccprintf(string.format("%s}", indent))
            end
        end
    end
    _ccdump(object, label, "- ", 1)
end
