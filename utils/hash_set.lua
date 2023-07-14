HashSet = {
    -- Works with a custom metamethod __hash.
}
setup_class(HashSet)

function HashSet.new(...)
    local obj = magic_new()

    for _, item in ipairs({...}) do
        obj:add(item)
    end

    return obj
end

function HashSet:contains(item)
    return self[item]
end

function HashSet:add(item)
    self[item] = true
end

function HashSet:remove(item)
    self[item] = false
end

function HashSet:__pairs()
    return function(t, k)
        if k ~= nil then
            k = k:__hash()
        end
        _, item = next(self, k)
        return item, true
    end, self, nil
end

function HashSet:__index(item)
    if item ~= nil and item.__hash ~= nil then
        return self[item:__hash()] ~= false
    end
    return false
end

function HashSet:__newindex(item, value)
    assert(item.__hash ~= nil)
    assert(value == nil or type(value) == "boolean")

    -- Temporarily unset metatable to allow direct access.
    local mt = getmetatable(self)
    setmetatable(self, {})
    if value then
        self[item:__hash()] = item
    else
        self[item:__hash()] = nil
    end
    setmetatable(self, mt)
end

function HashSet:__add(other)
    assert(is_type(other, HashSet))

    local result = HashSet.new()
    for item, _ in pairs(self) do
        result:add(item)
    end
    for item, _ in pairs(other) do
        result:add(item)
    end
    return result
end

function HashSet:__sub(other)
    assert(is_type(other, HashSet))

    local result = HashSet.new()
    for item, _ in pairs(self) do
        result:add(item)
    end
    for item, _ in pairs(other) do
        result:remove(item)
    end
    return result
end