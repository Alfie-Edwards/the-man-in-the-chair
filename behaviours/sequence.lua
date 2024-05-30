require "behaviours.behaviour"

Sequence = {
    i = nil,
    sub_behaviours = nil,
}
setup_class(Sequence, Behaviour)

function Sequence:__init(state, ...)
    super().__init(self, state)

    self.sub_behaviours = {...}
    assert(#self.sub_behaviours > 1)
end

function Sequence:start(entity)
    super().start(self, entity)
    self:set_i(1)
end

function Sequence:set_i(i)
    self.i = i
    self.sub_behaviours[i]:start(self.entity)
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
