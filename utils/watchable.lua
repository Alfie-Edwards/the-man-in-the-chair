Watchable = {
    _contents = nil,
    property_changed = nil,
}
setup_class(Watchable)

function Watchable.new()
    local obj = magic_new()

    -- Temporarily unset metatable to assign directly.
    local mt = getmetatable(obj)
    setmetatable(obj, nil)
    obj._contents = {}
    obj.property_changed = Event.new() -- (watchable, key, old_value, new_value)
    setmetatable(obj, mt)

    return obj
end

function Watchable:__index(key)
    return self._contents[key]
end

function Watchable:__newindex(key, value)
    if self._contents[key] == value then
        return
    end
    local old_value = self._contents[key]
    self._contents[key] = value
    self:property_changed(key, old_value, value)
end

function Watchable:__pairs()
    return next, self._contents, nil
end
