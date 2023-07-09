require "ui.simple_element"
require "ui.image"
-- require "ui.triple_button"
-- require "ui.table"
-- require "screens.game"

LoseScreen = {}

setup_class(LoseScreen, SimpleElement)

function LoseScreen.new()
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
            image = assets:get_image("ui/YouDied"),
            width = canvas:width(),
            height = canvas:height(),
            click = function()
                view:set_content(MainMenu.new())
            end
        }
    )
    obj:add_child(bg)

    -- local grid = Table.new()
    -- grid:set_properties(
    --     {
    --         cols = 3,
    --         rows = 3,
    --         width = canvas:width(),
    --         height = canvas:height(),
    --     }
    -- )
    -- obj:add_child(grid)

    -- local button_play = TripleButton.new()
    -- local button_play_img = assets:get_image("ui/ButtonPlayRelease")
    -- local button_play_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    -- local button_play_width = 100
    -- button_play:set_properties(
    --     {
    --         default_image = button_play_img,
    --         hover_image = assets:get_image("ui/ButtonPlayHover"),
    --         click_image = assets:get_image("ui/ButtonPlayPress"),
    --         x_align = "center",
    --         y_align = "center",
    --         x = grid:cell(1, 3).width / 2,
    --         y = grid:cell(1, 3).height / 2,
    --         width = button_play_width,
    --         height = button_play_width * button_play_aspect,
    --         click = function()
    --             view:set_content(Game.new())
    --         end,
    --     }
    -- )
    -- grid:cell(1, 3):add_child(button_play)

    -- local button_quit = TripleButton.new()
    -- local button_quit_img = assets:get_image("ui/ButtonQuitRelease")
    -- local button_quit_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    -- local button_quit_width = 100
    -- button_quit:set_properties(
    --     {
    --         default_image = button_quit_img,
    --         hover_image = assets:get_image("ui/ButtonQuitHover"),
    --         click_image = assets:get_image("ui/ButtonQuitPress"),
    --         x_align = "center",
    --         y_align = "center",
    --         x = grid:cell(3, 3).width / 2,
    --         y = grid:cell(3, 3).height / 2,
    --         width = button_quit_width,
    --         height = button_quit_width * button_quit_aspect,
    --         click = function()
    --             love.event.quit()
    --         end,
    --     }
    -- )
    -- grid:cell(3, 3):add_child(button_quit)

    return obj
end
