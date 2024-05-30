require "ui.layout_element"
require "ui.image"
require "ui.triple_button"
require "ui.containers.grid_box"

WinScreen = {}

setup_class(WinScreen, LayoutElement)

function WinScreen:__init()
    super().__init(self)

    self:set(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    local bg = Image()
    bg:set(
        {
            image = assets:get_image("ui/YouDidntDie"),
            width = canvas:width(),
            height = canvas:height(),
            mousereleased = function()
                view:set_content(MainMenu())
            end
        }
    )
    self:_add_visual_child(bg)

    local grid = GridBox()
    grid:set(
        {
            cols = 3,
            rows = 3,
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    self:_add_visual_child(grid)
end
