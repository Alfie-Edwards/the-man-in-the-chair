require "level"
require "camera"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        level = Level.from_file("assets/level_data"),
        camera = Camera.new(),
    })

    return obj
end