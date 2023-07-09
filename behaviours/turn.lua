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
    local d = self.angle - self.entity.angle
    d = d + (2 * math.pi)
    d = d % (2 * math.pi)
    if d > math.pi then
        d = d - (math.pi * 2)
    end

    local speed = self.entity.sweep_speed * dt
    if math.abs(d) < speed then
        self.entity.angle = self.angle
        return true
    else
        self.entity.angle = self.entity.angle + (d * speed) / math.abs(d)
        return false
    end
end
