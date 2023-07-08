require "entities.movable"
require "behaviours.patrol"
require "behaviours.investigate"
require "direction"

Guard = {
    SPEED = 25,

    x = nil,
    y = nil,
    vision = nil,
    speed = nil,
}
setup_class(Guard, Movable)

function Guard.new(...)
    local obj = magic_new()

    local points = {...}
    assert(#points)
    obj.x = points[1].x
    obj.y = points[1].y
    obj.speed = Guard.SPEED
    -- obj.behaviour = Patrol.new(unpack(points))
    obj.behaviour = Investigate.new(128, 128, 32, 3, 2)
    obj.direction = Direction.DOWN
    obj.vision = HashSet.new()

    return obj
end

function Guard:accessible_cells(state)
    return state.level.cells - state.level.solid_cells
end

function Guard:update(dt, state)
    super().update(self, dt)
    self.vision = raycast(
        state.level,
        self.x,
        self.y,
        direction_to_angle(self.direction),
        SecurityCamera.FOV,
        SecurityCamera.VIEW_DISTANCE * state.level.cell_length_pixels)
end

function Guard:draw(state)
    super().draw(self, state)

    love.graphics.setColor({0, 0.5, 0.2, 1})
    love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end
