jit.off()
require "utils.utils"
require "asset_cache"
require "map"
assets = AssetCache("assets")
require "pixelcanvas"
require "ui.view"
require "screens.editor"
require "screens.game"
require "screens.main_menu"
require "screens.cutscene"

function love.load()
    -- enable holding backspace for typing.
    love.keyboard.setKeyRepeat(true)

    -- setup rendering
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.graphics.setLineJoin("miter")
    love.graphics.setLineStyle("rough")
    canvas = PixelCanvas({ 768, 432 })

    view = View(canvas:width(), canvas:height())
    -- local cutscene_music = love.audio.newSource("assets/Sound/MusicIntro.wav", "stream")
    -- cutscene_music:setVolume(0.75)
    -- view:set_content(Cutscene.from_dir(
    --     "Cutscene/CutSceneOne",
    --     {
    --         Section(CutsceneSectionType.LOOP,    8,
    --             { eyebrows = {
    --                 source = love.audio.newSource("assets/Sound/EyebrowsVoice.wav", "stream"),
    --                 when = 0,
    --                 loop = true,
    --             }}),
    --         Section(CutsceneSectionType.THROUGH, 8),
    --         Section(CutsceneSectionType.THROUGH, 8,
    --             { eyebrows = {
    --                 source = love.audio.newSource("assets/Sound/EyebrowsVoice.wav", "stream"),
    --                 when = 1.9,
    --                 loop = true,
    --             }}),
    --         Section(CutsceneSectionType.THROUGH, 8,
    --             { george = {
    --                 source = love.audio.newSource("assets/Sound/GeorgeVoice.wav", "static"),
    --                 when = 3.5,
    --             }}),
    --     },
    --     cutscene_music,
    --     function()
    --         view:set_content(MainMenu())
    --     end
    -- ))
    view:set_content(Editor())
end

function love.mousemoved(x, y, dx, dy, istouch)
    local pos = canvas:screen_to_canvas(x, y)
    local disp = canvas:screen_to_canvas(dx, dy)
    view:mousemoved(pos.x, pos.y, disp.x, disp.y)
end

function love.mousepressed(x, y, button)
    local pos = canvas:screen_to_canvas(x, y)
    view:mousepressed(pos.x, pos.y, button)
end

function love.mousereleased(x, y, button)
    local pos = canvas:screen_to_canvas(x, y)
    view:mousereleased(pos.x, pos.y, button)
end

function love.textinput(t)
    view:textinput(t)
end

function love.wheelmoved(x, y)
    view:wheelmoved(-x, -y)
end

function love.keypressed(key, scancode, isrepeat)
   view:keypressed(key)
end

function love.update(dt)
    view:update(dt)
end

function love.draw()
    canvas:set()

    view:draw()

    canvas:draw()
end
