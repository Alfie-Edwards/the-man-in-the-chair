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

    for _, entity in ipairs(obj.state.entities) do
        if entity.behaviour then
            entity.behaviour:start(entity, obj.state)
        end
    end

    return obj
end

function Game:update(dt)
    super().update(self, dt)
    self.state.camera:update(dt, self.state)
    self.state.alarm.is_on = false
    for _, entity in ipairs(self.state.entities) do
        entity:update(dt, self.state)
    end
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

    love.graphics.pop()
end
