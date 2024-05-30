require "ui.layout_element"
require "ui.image"
-- require "ui.triple_button"
-- require "ui.containers.grid_box"
-- require "screens.game"

LoseScreen = {}

setup_class(LoseScreen, LayoutElement)

function LoseScreen:__init()
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
            image = assets:get_image("ui/YouDied"),
            width = canvas:width(),
            height = canvas:height(),
            mousereleased = function()
                view:set_content(MainMenu())
            end
        }
    )
    self:_add_visual_child(bg)

    -- local grid = GridBox()
    -- grid:set(
    --     {
    --         cols = 3,
    --         rows = 3,
    --         width = canvas:width(),
    --         height = canvas:height(),
    --     }
    -- )
    -- self:_add_visual_child(grid)

    -- local button_play = TripleButton()
    -- local button_play_img = assets:get_image("ui/ButtonPlayRelease")
    -- local button_play_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    -- local button_play_width = 100
    -- button_play:set(
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
    --         mousereleased = function()
    --             view:set_content(Game())
    --         end,
    --     }
    -- )
    -- grid:cell(1, 3):_add_visual_child(button_play)

    -- local button_quit = TripleButton()
    -- local button_quit_img = assets:get_image("ui/ButtonQuitRelease")
    -- local button_quit_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    -- local button_quit_width = 100
    -- button_quit:set(
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
    --         mousereleased = function()
    --             love.event.quit()
    --         end,
    --     }
    -- )
    -- grid:cell(3, 3):_add_visual_child(button_quit)
end
