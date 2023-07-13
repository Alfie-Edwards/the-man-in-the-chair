require "ui.hacking"
require "ui.image_button"
require "ui.simple_element"
require "game_state"

Game = {
    state = nil,
}
setup_class(Game, SimpleElement)

function Game.new()
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
    self.state.alarm.is_on = false
    for _, entity in ipairs(self.state.entities) do
        entity:update(dt)
    end
end

function Game:draw()
    super().draw(self)

    local camera = self.state:first("Camera")

    love.graphics.push()
    if camera then
        love.graphics.translate(-camera.x, -camera.y)
    end

    self.state.level:draw()

    for _, entity in ipairs(self.state.entities) do
        entity:draw(self.state)
    end

    love.graphics.pop()
end
