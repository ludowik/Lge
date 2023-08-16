Array = class() : extends(table)
Array.add = table.insert
Array.unpack = table.unpack or unpack

table.__className = 'table'

function Array:init(...)
    return ...
end

function Array:__tostring()
    return tostring(#self)
end

function Array:removeIfTrue(f)
    for i,v in ipairs(self, true) do
        if f(v) then
            table.remove(self, i)
        end
    end
end

function Array:forn(n, functionOrValue)
    if type(functionOrValue) == 'function' then
        for i in range(n) do
            self[i] = ffunctionOrValue(i)
        end
    else
        for i in range(n) do
            self[i] = functionOrValue
        end
    end
    return self
end

function Array:foreach(f)
    for i,v in ipairs(self) do
        f(v, i)
    end
    return self
end

function Array:foreachKey(f)
    for k,v in pairs(self) do
        f(v, k)
    end
    return self
end

function Array:max()
    if #self == 0 then return end

    local maxValue = math.mininteger
    for i,v in ipairs(self) do
        maxValue = max(maxValue, v)
    end
    return maxValue
end

local __cloningObjects = {}

function Array:clone()
    if __cloningObjects[self] then return __cloningObjects[self] end
    local t = Array()
    __cloningObjects[self] = t
    Array.foreachKey(self, function(v, k)
        if type(v) == 'table' then
            t[k] = Array.clone(v)
        else
            t[k] = v
        end
    end)
    __cloningObjects[self] = nil
    return t
end

function Array:random()
    return self[random(1, #self)]
end

function Array:tolua()
    return Array.__tolua(self, '')
end

function Array:__tolua(tab)
    local serializeTypes = {
        boolean = tostring,
        number = tostring,
        string = function (s) return '"'..s..'"' end,
        table = function (t) return Array.__tolua(t, tab..'\t') end, 
    }

    local function name(k)
        return type(k) == 'number' and '['..k..']' or k
    end
    
    local code = '{'

    for k,v in pairs(self) do
        if serializeTypes[type(v)] then
            code = code..'\n'                
            code = code..tab..'\t'..name(k)..' = '
            code = code..serializeTypes[type(v)](v)
            code = code..','
        end
    end

    code = code..'\n'..tab..'}'
    return code
end

function Array:unitTest()
    local t = Array()
    t:add('element')
    
    assert(t[1] == 'element')
    assert(#t == 1)

    assert(Array(t) == t)
    assert(Array() ~= t)
end
