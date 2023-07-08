require "behaviours.behaviour"

Sequence = {
    i = nil,
    sub_behaviours = nil,
}
setup_class(Sequence, Behaviour)

function Sequence.new(...)
    local obj = magic_new()

    obj.i = 1
    obj.sub_behaviours = {...}
    assert(#obj.sub_behaviours > 1)

    return obj
end

function Sequence:update(entity, dt, state)
    if self.sub_behaviours[i]:update(entity, dt, state) then
        self.i = self.i + 1
        if self.i > #self.sub_behaviours then
            return true
        end
    end
    return false
end

function Sequence:draw(entity, state)
    self.sub_behaviours[i]:draw(entity, state)
end
