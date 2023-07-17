Enum = {
    _values = nil
}

setup_class(Enum)

function Enum.new(...)
    local obj = magic_new()

    -- Temporarily unset metatable to assign _values.
    local mt = getmetatable(obj)
    setmetatable(obj, nil)
    obj._values = set(...)
    setmetatable(obj, mt)

    for _, value in pairs(obj) do
        if not type(value) == "string" then
            error("Invalid type for enum value \""..type(value).."\". Enum values must be strings.")
        end
    end

    return obj
end

function Enum:is(x)
    return self._values[x]
end

function Enum:__index(key)
    if self._values[key] then
        return key
    end

    local name = get_key(_G, self) or "this enum"
    error(tostring(key).." is not a member of "..name..". Valid members are "..tostring(self)..".")
end

function Enum:__newindex(key, value)
    error("Cannot assign to an enum.")
end

function Enum:__pairs()
    return function(t, k)
        print(k)
        k, _ = next(self._values, k)
        return k, k
    end, self, nil
end

function Enum:__tostring()
    local name = get_key(_G, self)
    local result = ""
    if name then
        result = result..name.." "
    end
    result = result.."{ "
    for _, value in pairs(self) do
        result = result..value.." "
    end
    result = result.."}"
end
