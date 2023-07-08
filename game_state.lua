require "level"
require "camera"
require "entities.george"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        level = Level.from_file("assets/level_data"),
        camera = Camera.new(),
        entities = {
            George.new(),
        },
    })

    return obj
end