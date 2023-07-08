require "entities.entity"
require "behaviours.goto"

SecurityCamera = {
    SWEEP_SPEED = 0.01,

    x = nil,
    y = nil,
    angle = nil,
    sweep = nil,
    sweep_speed = nil,
}
setup_class(SecurityCamera, Entity)

function SecurityCamera.new(x, y, angle, sweep)
    local obj = magic_new()

    obj.sweep_speed = SecurityCamera.SWEEP_SPEED
    obj.x = x
    obj.y = y
    obj.angle = angle - (sweep or 0) / 2

    if sweep > 0 then
        obj.behaviour = Sweep.new(angle, sweep)
    end

    return obj
end

function SecurityCamera:draw(state)
    super().draw(self, state)

    love.graphics.setColor({0.5, 0, 0.5, 1})
    love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end
