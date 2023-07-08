require "ui.hacking"
require "ui.image_button"
require "ui.simple_element"
require "game_state"

Game = {
    state = nil,
}
setup_class(Game, SimpleElement)

function Game.new(mode)
    local obj = magic_new()

    obj.state = GameState.new()

    obj:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    local hacking_hud = Hacking.new(obj.state)
    obj:add_child(hacking_hud)

    return obj
end

function Game:update(dt)
    super().update(self, dt)
    self.state.camera:update(dt, self.state)
    for _, entity in ipairs(self.state.entities) do
        entity:update(dt, self.state)
    end
    angle = angle + dt
end

function Game:draw()
    super().draw(self)

    local camera = self.state.camera

    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)

    self.state.level:draw()

    for _, entity in ipairs(self.state.entities) do
        entity:draw(self.state)
    end

    local result = raycast(self.state.level, 240, 200, angle, math.pi * 0.5, 1000)
    for _, cell in pairs(result) do
        love.graphics.setColor({1, 0, 0, 0.2})
        local cell_size = self.state.level.cell_length_pixels
        love.graphics.rectangle("fill", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
    end

    love.graphics.pop()
end
angle = 0
