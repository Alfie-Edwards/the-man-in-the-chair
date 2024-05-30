require "ui.layout_element"
require "ui.image"
require "ui.image_button"
require "ui.triple_button"
require "ui.containers.grid_box"
require "screens.game"

MainMenu = {
    bg_music = nil,
}

setup_class(MainMenu, LayoutElement)

function MainMenu:__init()
    super().__init(self)

    self:set(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    self.bg_music = love.audio.newSource("assets/Sound/MusicMenu.wav", "stream")
    self.bg_music:setVolume(0.75)
    self.bg_music:setLooping(true)
    self.bg_music:play()

    local bg = Image()
    bg:set(
        {
            image = assets:get_image("ui/TitleBackground"),
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    self:_add_visual_child(bg)

    local grid = GridBox()
    grid:set(
        {
            cols = 3,
            rows = 1,
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    self:_add_visual_child(grid)

    local button_play = TripleButton()
    local button_play_img = assets:get_image("ui/ButtonPlayRelease")
    local button_play_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    local button_play_width = 200
    button_play:set(
        {
            default_image = button_play_img,
            hover_image = assets:get_image("ui/ButtonPlayHover"),
            click_image = assets:get_image("ui/ButtonPlayPress"),
            x_align = "center",
            y_align = "top",
            x = grid:cell(1, 1).width / 2,
            y = grid:cell(1, 1).height / 2,
            width = button_play_width,
            height = button_play_width * button_play_aspect,
            mousereleased = function()
                -- TODO #cleanup: assumes we're the view content; we don't have
                --                access to `self`
                if view:get_content() ~= nil and
                   view:get_content().bg_music ~= nil then
                    view:get_content().bg_music:stop()
                end

                local cutscene_music = love.audio.newSource("assets/Sound/MusicIntro.wav", "stream")
                cutscene_music:setVolume(0.75)
                view:set_content(Cutscene.from_dir(
                    "Cutscene/CutSceneTwo",
                    {
                        Section(CutsceneSectionType.THROUGH, 8,
                            { agent = {
                                source = love.audio.newSource("assets/Sound/AgentVoice.wav", "stream"),
                                when = 2.8,
                                loop = true,
                            }}),
                        Section(CutsceneSectionType.THROUGH, 8),
                        Section(CutsceneSectionType.THROUGH, 8),
                    },
                    cutscene_music,
                    function()
                        view:set_content(Game())
                    end
                ))
            end,
        }
    )
    grid:cell(1, 1):_add_visual_child(button_play)

    local button_quit = TripleButton()
    local button_quit_img = assets:get_image("ui/ButtonQuitRelease")
    local button_quit_aspect = button_play_img:getHeight() / button_play_img:getWidth()
    local button_quit_width = 200
    button_quit:set(
        {
            default_image = button_quit_img,
            hover_image = assets:get_image("ui/ButtonQuitHover"),
            click_image = assets:get_image("ui/ButtonQuitPress"),
            x_align = "center",
            y_align = "top",
            x = grid:cell(3, 1).width / 2,
            y = grid:cell(3, 1).height / 2,
            width = button_quit_width,
            height = button_quit_width * button_quit_aspect,
            mousereleased = function()
                love.event.quit()
            end,
        }
    )
    grid:cell(3, 1):_add_visual_child(button_quit)
end
