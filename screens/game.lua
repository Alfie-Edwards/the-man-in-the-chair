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

    local button_hack = ImageButton.new()
    button_hack:set_properties(
        {
            image = assets:get_image("ui/button_hack"),
            image_data = assets:get_image_data("ui/button_hack"),
            x_align = "left",
            y_align = "bottom",
            x = 20,
            y = obj.height - 20,
            click = function()
                view:set_content(Game.new())
            end,
        }
    )
    obj:add_child(button_hack)

    local button_stop_go = ImageButton.new()
    button_stop_go:set_properties(
        {
            image = assets:get_image("ui/button_stop"),
            image_data = assets:get_image_data("ui/button_stop"),
            x_align = "right",
            y_align = "bottom",
            x = obj.width - 20,
            y = obj.height - 20,
            click = function()
                if button_stop_go.image == assets:get_image("ui/button_stop") then
                    button_stop_go.image = assets:get_image("ui/button_go")
                else
                    button_stop_go.image = assets:get_image("ui/button_stop")
                end
            end,
        }
    )
    obj:add_child(button_stop_go)

    return obj
end

function Game:update(dt)
    super().update(self, dt)
    self.state.level:update(dt)
end

function Game:draw()
    super().draw(self)
    self.state.level:draw()
end
