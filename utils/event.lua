Event = {
    handlers = nil
}
setup_class(Event)

function Event.new()
    local obj = magic_new()

    obj.handlers = {}

    return obj
end

function Event:subscribe(handler)
    assert(handler ~= nil)
    table.insert(self.handlers, handler)
end

function Event:unsubscribe(handler)
    assert(handler ~= nil)
    remove_value(self.handlers, handler)
end

function Event:unsubscribe_all()
    self.handlers = {}
end

function Event:__call(...)
    for _, handler in ipairs(self.handlers) do
        handler(...)
    end
end
