require "entities.entity"
require "behaviours.sweep"

SecurityCamera = {
    SWEEP_SPEED = 0.5,
    FOV = math.pi / 2,
    VIEW_DISTANCE = 10,
    WAIT_TIME = 5,

    x = nil,
    y = nil,
    angle = nil,
    sweep = nil,
    sweep_speed = nil,
    vision = nil,
}
setup_class(SecurityCamera, Entity)

function SecurityCamera.new(x, y, angle, sweep)
    local obj = magic_new()

    obj.sweep_speed = SecurityCamera.SWEEP_SPEED
    obj.x = x
    obj.y = y
    obj.angle = angle - (sweep or 0) / 2
    obj.vision = HashSet.new()

    if sweep > 0 then
        obj.behaviour = Sweep.new(angle, sweep, SecurityCamera.WAIT_TIME)
    end

    return obj
end

function SecurityCamera:update(dt, state)
    super().update(self, dt)
    self.vision = raycast(
        state.level,
        self.x,
        self.y,
        self.angle,
        SecurityCamera.FOV,
        SecurityCamera.VIEW_DISTANCE * state.level.cell_length_pixels)
end

function SecurityCamera:draw(state)
    super().draw(self, state)

    local cell_size = state.level.cell_length_pixels
    for _, cell in pairs(self.vision) do
        love.graphics.setColor({1, 0, 0, 0.2})
        love.graphics.rectangle("fill", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
    end
    love.graphics.setColor({0.2, 0, 0, 1})
    love.graphics.rectangle("fill", self.x - 4, self.y - 4, 8, 8)
end
