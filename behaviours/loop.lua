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

function Loop:start(entity, state)
    super().start(self, entity, state)
    self:set_i(1)
end

function Loop:set_i(i)
    self.i = i
    self.sub_behaviours[i]:start(self.entity, self.state)
end

function Loop:update(dt)
    super().update(self, dt)
    if self.sub_behaviours[self.i]:update(dt) then
        if self.i == #self.sub_behaviours then
            self:set_i(1)
        else
            self:set_i(self.i + 1)
        end
    end
    return false
end

function Loop:draw()
    super().draw(self)
    self.sub_behaviours[self.i]:draw(self.entity, self.state)
end
