
---- math

math.round = function(num)
    return math.floor(num + 0.5)
end

math.comma = function(num)
    if type(tonumber(num)) ~= "number" then num = 0 end
    local formatted = tostring(num)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end


---- io

-- checks whether a file exists
io.exists = function(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

-- reads entire file into a string, on failure return nil
io.readfile = function(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

-- write a string to a file
io.writefile = function(path, content)
    local file = io.open(path, "w+")
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

-- returns information [dirname, filename, basename, extname] about a file path
io.pathinfo = function(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

-- gets file size, on failure return false
io.filesize = function(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

-- append filename to path
io.pathForFile = function(filename, path)
    path = string.gsub(path, "[\\\/]+$", "")
    return path .. "/" .. filename
end

---- string

string.split = function(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
    return fields
end


---- table

-- count all elements in an table
table.nums = function(t)
    if type(t) ~= "table" then
        if DEBUG > 0 then traceback() end
        return nil
    end
    local nums = 0
    for k, v in pairs(t) do
        nums = nums + 1
    end
    return nums
end


---- global functions

-- clones object
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- printf
function printf(...)
    print(string.format(select(1, ...)))
end
