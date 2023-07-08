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

function Turn:update(entity, dt, state)

    local d = self.angle - entity.angle
    (() + (math.pi * 2)) % (math.py * 2)
    local speed = entity. * dt
    if d < speed then
        entity.angle = self.angle
        return true
    else
        entity.angle = entity.angle + d
        return false
    end
end

function Turn:draw(entity, state)
end
