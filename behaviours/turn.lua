require "behaviours.behaviour"

Turn = {
    angle = angle,
}
setup_class(Turn, Behaviour)

function Turn:__init(state, angle, sweep_speed)
    super().__init(self, state)

    self.angle = angle
    self.sweep_speed = sweep_speed
end

function Turn:update(dt)
    super().update(self, dt)
    local d = normalize_angle(self.angle - self.entity.angle)

    local speed = self.sweep_speed * dt
    if math.abs(d) < speed then
        self.entity.angle = self.angle
        return true
    else
        self.entity.angle = self.entity.angle + (d * speed) / math.abs(d)
        return false
    end
end
