require "utils.utils"
require "asset_cache"
assets = AssetCache.new()
require "pixelcanvas"
require "ui.view"
require "screens.game"
require "screens.main_menu"
require "screens.cutscene"

function love.load()

    -- setup rendering
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    -- font = assets:get_font("font")
    -- love.graphics.setFont(font)
    love.graphics.setLineJoin("bevel")
    love.graphics.setLineStyle("rough")
    canvas = PixelCanvas.new({ 768, 432 })

    view = View.new()
    local cutscene_music = love.audio.newSource("assets/Sound/MusicIntro.wav", "stream")
    cutscene_music:setVolume(0.75)
    view:set_content(Cutscene.from_dir(
        "Cutscene/CutSceneOne",
        {
            Section.new(CutsceneSectionType.LOOP,    8,
                { eyebrows = {
                    source = love.audio.newSource("assets/Sound/EyebrowsVoice.wav", "stream"),
                    when = 0,
                    loop = true,
                }}),
            Section.new(CutsceneSectionType.THROUGH, 8),
            Section.new(CutsceneSectionType.THROUGH, 8,
                { eyebrows = {
                    source = love.audio.newSource("assets/Sound/EyebrowsVoice.wav", "stream"),
                    when = 1.9,
                    loop = true,
                }}),
            Section.new(CutsceneSectionType.THROUGH, 8,
                { george = {
                    source = love.audio.newSource("assets/Sound/GeorgeVoice.wav", "static"),
                    when = 3.5,
                }}),
        },
        cutscene_music,
        function()
            view:set_content(MainMenu.new())
        end
    ))
end

function love.mousemoved(x, y, dx, dy, istouch)
    local pos = canvas:screen_to_canvas(x, y)
    view:mousemoved(pos.x, pos.y, dx, dy)
end

function love.mousereleased(x, y, button)
    local pos = canvas:screen_to_canvas(x, y)
    view:click(pos.x, pos.y, button)
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
