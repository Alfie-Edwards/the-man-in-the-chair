require "ui.simple_element"

Game = {}
setup_class(Game, SimpleElement)

function Game.new(mode)
    local obj = magic_new()

    obj:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    return obj
end

function Game:update(dt)
    super().update(self, dt)
end

function Game:draw()
    super().draw(self)
end
