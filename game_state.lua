require "alarm"
require "jukebox"
require "level"
require "camera"
require "entities.door"
require "entities.george"
require "entities.guard"
require "entities.security_camera"

GameState = {}
setup_class(GameState, State)

function GameState.new()
    local obj = magic_new({
        escaping = false,
        alarm = Alarm.new(),
        level = Level.from_file("assets/level_data"),
        camera = Camera.new(),
        entities = {
            Door.new( 11,   5, Direction.DOWN),
            Door.new( 19,  22, Direction.UP),
            Door.new( 24,  13, Direction.RIGHT),
            Door.new( 32,  11, Direction.DOWN),
            Door.new( 40,  16, Direction.UP),
            Door.new( 52,   8, Direction.UP),
            Door.new( 52,  19, Direction.DOWN),
            Door.new( 57,  21, Direction.DOWN),
            Door.new( 64,  21, Direction.UP),
            Door.new( 68,  10, Direction.RIGHT),
            Door.new( 90,   8, Direction.DOWN),
            Door.new( 95,  13, Direction.RIGHT),
            Door.new(106,  10, Direction.DOWN),
            Door.new(116,  17, Direction.UP),
            Door.new(123,  13, Direction.RIGHT),
            SecurityCamera.new(23,  8, Direction.LEFT),
            SecurityCamera.new(46,  12, Direction.DOWN),
            SecurityCamera.new(57,  1, Direction.DOWN),
            SecurityCamera.new(70,  7, Direction.UP),
            SecurityCamera.new(80,  1, Direction.DOWN),
            SecurityCamera.new(94,  7, Direction.UP),
            SecurityCamera.new(103, 1, Direction.DOWN),
            SecurityCamera.new(112, 11, Direction.DOWN),
            Jukebox.new(0.5),
            -- Guard.new(
            --     {
            --         {x = 64, y = 64},
            --         {x = 128, y = 64},
            --         {x = 128, y = 128},
            --         {x = 64, y = 128}
            --     }
            -- ),
            George.new(),
        },
    })

    return obj
end
