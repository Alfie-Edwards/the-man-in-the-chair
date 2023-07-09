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
            Jukebox.new(0.5),
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
            Guard.new(
                {
                    {x = 64, y = 64},
                    {x = 128, y = 64},
                    {x = 128, y = 128},
                    {x = 64, y = 128}
                }
            ),
            SecurityCamera.new(72, 72, math.pi * 1.5, math.pi * 0.5),
        },
    })

    return obj
end
