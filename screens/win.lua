require "ui.simple_element"
require "ui.image"
require "ui.triple_button"
require "ui.table"

WinScreen = {}

setup_class(WinScreen, SimpleElement)

function WinScreen.new()
    local obj = magic_new()

    obj:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    local bg = Image.new()
    bg:set_properties(
        {
            image = assets:get_image("ui/YouDidntDie"),
            width = canvas:width(),
            height = canvas:height(),
            click = function()
                view:set_content(MainMenu.new())
            end
        }
    )
    obj:add_child(bg)

    local grid = Table.new()
    grid:set_properties(
        {
            cols = 3,
            rows = 3,
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    obj:add_child(grid)

    return obj
end
