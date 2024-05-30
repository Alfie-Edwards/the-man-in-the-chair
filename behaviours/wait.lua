require "behaviours.behaviour"

Wait = {
    t = nil,
    t0 = nil,
}
setup_class(Wait, Behaviour)

function Wait:__init(state, t)
    super().__init(self, state)

    self.t = t
end

function Wait:start(entity)
    super().start(self, entity)
    self.t0 = love.timer.getTime()
end

function Wait:update(dt)
    super().update(self, dt)
    return (love.timer.getTime() - self.t0) >= self.t
end
