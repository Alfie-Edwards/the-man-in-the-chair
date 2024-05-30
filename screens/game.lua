require "ui.hacking"
require "ui.image_button"
require "ui.layout_element"
require "game_state"

Game = {
    state = nil,
}
setup_class(Game, LayoutElement)

function Game:__init(map)
    super().__init(self)

    map = map or Map("assets/default")
    self.state = GameState(map)
    self.state:add(Jukebox(0.5))
    self.state:start_all()

    self:set(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    local hacking_hud = Hacking(self.state)
    self:_add_visual_child(hacking_hud)
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
        camera:apply_transform()
    end

    self.state.level:draw()

    for _, entity in ipairs(self.state.entities) do
        entity:draw(self.state)
    end

    love.graphics.pop()
end
