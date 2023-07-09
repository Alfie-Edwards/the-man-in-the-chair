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

    -- TODO #temp
    obj.t_alarm_toggled = love.timer.getTime()

    return obj
end

function Game:update(dt)
    super().update(self, dt)
    self.state.camera:update(dt, self.state)
    for _, entity in ipairs(self.state.entities) do
        entity:update(dt, self.state)
    end

    -- TODO #temp: toggle alarm with spacebar
    if love.keyboard.isDown("space") and t_since(self.t_alarm_toggled) > 1 then
        self.state.alarm.is_on = not self.state.alarm.is_on
        self.t_alarm_toggled = love.timer.getTime()
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
