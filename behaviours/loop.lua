require "behaviours.behaviour"

Loop = {
    i = nil,
    sub_behaviours = nil,
}
setup_class(Loop, Behaviour)

function Loop.new(...)
    local obj = magic_new()

    obj.i = 1
    obj.sub_behaviours = {...}
    assert(#obj.sub_behaviours > 1)

    return obj
end

function Loop:update(entity, dt, state)
    if self.sub_behaviours[self.i]:update(entity, dt, state) then
        self.i = self.i + 1
        if self.i > #self.sub_behaviours then
            self.i = 1
        end
    end
    return false
end

function Loop:draw(entity, state)
    self.sub_behaviours[self.i]:draw(entity, state)
end
