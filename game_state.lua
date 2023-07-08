require "level"
require "camera"
require "entities.door"
require "entities.george"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        level = Level.from_file("assets/level_data"),
        camera = Camera.new(),
        entities = {
            George.new(),
            Door.new( 11,   5, Direction.DOWN),
            Door.new( 52,   8, Direction.DOWN),
            Door.new( 90,   8, Direction.DOWN),
            Door.new( 68,  10, Direction.LEFT),
            Door.new(106,  10, Direction.DOWN),
            Door.new( 32,  11, Direction.DOWN),
            Door.new( 24,  13, Direction.LEFT),
            Door.new( 95,  13, Direction.LEFT),
            Door.new(123,  13, Direction.RIGHT),
            Door.new( 40,  16, Direction.UP),
            Door.new(116,  17, Direction.UP),
            Door.new( 52,  19, Direction.UP),
            Door.new( 57,  21, Direction.UP),
            Door.new( 64,  21, Direction.UP),
            Door.new( 19,  22, Direction.UP),
        },
    })

    return obj
end