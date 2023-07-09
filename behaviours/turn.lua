require "behaviours.behaviour"

Turn = {
    angle = angle,
}
setup_class(Turn, Behaviour)

function Turn.new(angle)
    local obj = magic_new()

    obj.angle = angle

    return obj
end

function Turn:update(dt)
    super().update(self, dt)
    local d = normalize_angle(self.angle - self.entity.angle)

    local speed = self.entity.sweep_speed * dt
    if math.abs(d) < speed then
        self.entity.angle = self.angle
        return true
    else
        self.entity.angle = self.entity.angle + (d * speed) / math.abs(d)
        return false
    end
end
