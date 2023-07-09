require "behaviours.behaviour"

Sequence = {
    i = nil,
    sub_behaviours = nil,
}
setup_class(Sequence, Behaviour)

function Sequence.new(...)
    local obj = magic_new()

    obj.sub_behaviours = {...}
    assert(#obj.sub_behaviours > 1)

    return obj
end

function Sequence:start(entity, state)
    super().start(self, entity, state)
    self:set_i(1)
end

function Sequence:set_i(i)
    self.i = i
    self.sub_behaviours[i]:start(self.entity, self.state)
end

function Sequence:update(dt)
    super().update(self, dt)
    if self.sub_behaviours[self.i]:update(dt) then
        if self.i == #self.sub_behaviours then
            return true
        end
        self:set_i(self.i + 1)
    end
    return false
end

function Sequence:draw()
    super().draw(self)
    self.sub_behaviours[self.i]:draw()
end
