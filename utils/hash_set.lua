HashSet = {
    -- Works with a custom metamethod __hash.
}
setup_class(HashSet)

function HashSet.new()
    local obj = {}

    setup_instance(obj, HashSet)

    return obj
end

function HashSet:contains(key)
    return self[key]
end

function HashSet:add(key)
    self[key] = true
end

function HashSet:remove(key)
    self[key] = false
end

function HashSet:__index(key)
    if key.__hash ~= nil then
        return self[key:__hash()]
    end
    return false
end

function HashSet:__newindex(key, value)
    assert(type(value) == "boolean")
    assert(key.__hash ~= nil)

    -- Temporarily unset metatable to allow direct access.
    local mt = getmetatable(self)
    setmetatable(self, {})
    if value then
        self[key:__hash()] = true
    else
        self[key:__hash()] = nil
    end
    setmetatable(self, mt)
end