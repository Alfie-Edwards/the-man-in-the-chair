require "ui.simple_element"
require "ui.image"
require "ui.image_button"
require "ui.table"
require "screens.game"

MainMenu = {}

setup_class(MainMenu, SimpleElement)

function MainMenu.new()
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
            image = assets:get_image("ui/menu_background"),
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    obj:add_child(bg)

    local grid = Table.new()
    grid:set_properties(
        {
            cols = 1,
            rows = 2,
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    obj:add_child(grid)

    local button_play = ImageButton.new()
    button_play:set_properties(
        {
            image = assets:get_image("ui/button_play"),
            image_data = assets:get_image_data("ui/button_play"),
            x_align = "center",
            y_align = "center",
            x = grid:cell(1, 1).width / 2,
            y = grid:cell(1, 1).height / 2,
            click = function()
                view:set_content(Game.new())
            end,
        }
    )
    grid:cell(1, 1):add_child(button_play)

    local button_quit = ImageButton.new()
    button_quit:set_properties(
        {
            image = assets:get_image("ui/button_quit"),
            image_data = assets:get_image_data("ui/button_quit"),
            x_align = "center",
            y_align = "center",
            x = grid:cell(1, 2).width / 2,
            y = grid:cell(1, 2).height / 2,
            click = function()
                love.event.quit()
            end,
        }
    )
    grid:cell(1, 2):add_child(button_quit)

    return obj
end
