HashMap = {
    -- Works with a custom metamethod __hash.
}
setup_class(HashMap)

function HashMap.new(items)
    local obj = magic_new()

    if items then
        for key, value in pairs(items) do
            obj[key] = value
        end
    end

    return obj
end

function HashMap:contains_key(key)
    return self[key] ~= nil
end

function HashMap:__pairs()
    return function(t, k)
        if k ~= nil then
            k = k:__hash()
        end
        _, entry = next(self, k)
        if entry == nil then
            return nil, nil
        end
        return entry.key, entry.value
    end, self, nils
end

function HashMap:__index(key)
    if key ~= nil and key.__hash ~= nil then
        local entry = self[key:__hash()]
        if entry == nil then
            return nil
        end
        return entry.value
    end
    return nil
end

function HashMap:__newindex(key, value)
    assert(key.__hash ~= nil)

    -- Temporarily unset metatable to allow direct access.
    local mt = getmetatable(self)
    setmetatable(self, {})
    if value ~= nil then
        self[key:__hash()] = {key = key, value = value}
    else
        self[key:__hash()] = nil
    end
    setmetatable(self, mt)
end
