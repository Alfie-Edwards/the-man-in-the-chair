require "entities.movable"
require "behaviours.goto"
require "direction"

George = {
    SPEED = 20,
    SPAWN_X = 68,
    SPAWN_Y = 250,

    x = nil,
    y = nil,
    speed = nil,
    direction = nil,
}
setup_class(George, Movable)

function George.new()
    local obj = magic_new()

    obj.x = George.SPAWN_X
    obj.y = George.SPAWN_Y
    obj.speed = George.SPEED
    obj.behaviour = Goto.new(200, 300)
    obj.direction = Direction.DOWN

    return obj
end

function George:draw(state)
    super().draw(self, state)

    love.graphics.setColor({0.5, 0, 0.5, 1})
    love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end
