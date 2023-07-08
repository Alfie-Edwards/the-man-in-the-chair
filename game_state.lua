require "level"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        level = Level.new(),
    })

    return obj
end