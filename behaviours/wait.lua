require "behaviours.behaviour"

Wait = {
    t = nil,
    t0 = nil,
}
setup_class(Wait, Behaviour)

function Wait.new(t)
    local obj = magic_new()

    obj.t = t

    return obj
end

function Wait:start(entity, state)
    super().start(self, entity, state)
    self.t0 = love.timer.getTime()
end

function Wait:update(dt)
    super().update(self, dt)
    return (love.timer.getTime() - self.t0) >= self.t
end
