require "entities.movable"
require "behaviours.patrol"

Guard = {
    SPEED = 1,

    x = nil,
    y = nil,
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
    obj.behaviour = Patrol.new(unpack(points))

    return obj
end

function Guard:accessible_cells(state)
    return state.level.cells - state.level.solid_cells
end

function Guard:draw(state)
    super().draw(self, state)

    love.graphics.setColor({0, 0.5, 0.2, 1})
    love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end
