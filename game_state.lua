require "level"
require "camera"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        level = Level.new(),
        camera = Camera.new(),
    })

    return obj
end