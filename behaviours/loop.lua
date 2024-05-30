require "behaviours.behaviour"

Loop = {
    i = nil,
    sub_behaviours = nil,
}
setup_class(Loop, Behaviour)

function Loop:__init(state, ...)
    super().__init(self, state)

    self.i = 1
    self.sub_behaviours = {...}
    assert(#self.sub_behaviours > 0, "Must have at least 1 behaviour to loop.")
end

function Loop:start(entity)
    super().start(self, entity)
    self:set_i(1)
end

function Loop:set_i(i)
    self.i = i
    self.sub_behaviours[i]:start(self.entity)
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
    self.sub_behaviours[self.i]:draw()
end
