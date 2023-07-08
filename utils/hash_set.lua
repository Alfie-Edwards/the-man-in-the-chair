HashSet = {
    -- Works with a custom metamethod __hash.
}
setup_class(HashSet)

function HashSet.new()
    local obj = {}

    setup_instance(obj, HashSet)

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

function HashSet:__index(item)
    if item.__hash ~= nil then
        return self[item:__hash()] ~= false
    end
    return false
end

function HashSet:__newindex(item, value)
    assert(item.__hash ~= nil)
    assert(type(value) == "boolean")

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
    local result = HashSet.new()
    for _, item in pairs(self) do
        result:add(item)
    end
    for _, other in pairs(self) do
        result:add(item)
    end
end

function HashSet:__sub(other)
    local result = HashSet.new()
    for _, item in pairs(self) do
        result:add(item)
    end
    for _, other in pairs(self) do
        result:remove(item)
    end
end