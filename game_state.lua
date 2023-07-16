require "alarm"
require "level"
require "entities.camera"
require "entities.door"
require "entities.george"
require "entities.guard"
require "entities.jukebox"
require "entities.security_camera"

GameState = {}
setup_class(GameState, State)

-- function GameState.new()
--     local obj = magic_new({
--         escaping = false,
--         alarm = Alarm.new(),
--         level = Level.from_file("data/level_data"),
--         entities = {
--             Camera.new(),
--             Door.new( 11,   5, Direction.DOWN),
--             Door.new( 19,  22, Direction.UP),
--             Door.new( 24,  13, Direction.RIGHT),
--             Door.new( 32,  11, Direction.DOWN),
--             Door.new( 40,  16, Direction.UP),
--             Door.new( 52,   8, Direction.UP),
--             Door.new( 52,  19, Direction.DOWN),
--             Door.new( 57,  21, Direction.DOWN),
--             Door.new( 64,  21, Direction.UP),
--             Door.new( 68,  10, Direction.RIGHT),
--             Door.new( 90,   8, Direction.DOWN),
--             Door.new( 95,  13, Direction.RIGHT),
--             Door.new(106,  10, Direction.DOWN),
--             Door.new(116,  17, Direction.UP),
--             Door.new(123,  13, Direction.RIGHT),

--             Jukebox.new(0.5),
--             Guard.new(
--             {
--                 { x = 672,  y = 320 },
--                 { x = 592,  y = 224 },
--             }),
--             Guard.new(
--             {
--                 { x = 512,  y = 96 },
--                 { x = 512,  y = 224 },
--             }),
--             Guard.new(
--             {
--                 { x = 912,  y = 352 },
--                 { x = 912,  y = 240 },
--                 { x = 1280, y = 240 },
--                 { x = 912,  y = 240 },
--             }),
--             Guard.new(
--             {
--                 { x = 1456, y = 208 },
--                 { x = 848,  y = 208 },
--                 { x = 832,  y =  64 },
--                 { x = 1440, y =  64 },
--             }),
--             Guard.new(
--             {
--                 { x = 1904, y = 224 },
--                 { x = 1840, y = 336 },
--             }),
--             Guard.new(
--             {
--                 { x = 1872, y = 336 },
--                 { x = 1856, y = 224 },
--                 { x = 1712, y = 224 },
--             }),
--             George.new(),
--         },
--     })

--     for _, entity in ipairs(obj.entities) do
--         entity:init(obj)
--     end

--     return obj
-- end

function GameState.new(map)
    local obj = magic_new({
        escaping = false,
        alarm = Alarm.new(),
        level = Level.new(map),
        entities = {},
    })
    for _, entity in ipairs(obj.entities) do
        entity:init(obj)
    end

    obj:add(Camera.from_config(map.config.camera))
    for _, camera_config in ipairs(map.config.security_cameras) do
        obj:add(SecurityCamera.from_config(camera_config))
    end
    for _, guard_config in ipairs(map.config.guards) do
        obj:add(Guard.from_config(guard_config))
    end
    for _, door_config in ipairs(map.config.doors) do
        obj:add(Door.from_config(door_config))
    end
    obj:add(George.from_config(map.config.george))

    return obj
end

function GameState:add(entity)
    table.insert(self.entities, entity)
    entity:init(self)
end

function GameState:remove(entity)
    table.remove(self.entities, get_key(self.entities, entity))
end

function GameState:first(type)
    for _, e in ipairs(self.entities) do
        if is_type(e, type) then
            return e
        end
    end
    return nil
end

function GameState:foreach(type, f)
    for _, e in ipairs(self.entities) do
        if is_type(e, type) then
            f(e)
        end
    end
end

function GameState:any(type, f)
    for _, e in ipairs(self.entities) do
        if is_type(e, type) and f(e) then
            return true
        end
    end
    return false
end
