require "alarm"
require "level"
require "entities.camera"
require "entities.door"
require "entities.george"
require "entities.guard"
require "entities.jukebox"
require "entities.security_camera"

GameState = {}
setup_class(GameState, FixedPropertyTable)

-- function GameState:__init()
--     super().__init(self, {
--         escaping = false,
--         alarm = Alarm(),
--         level = Level.from_file("data/level_data"),
--         entities = {
--             Camera(),
--             Door( 11,   5, Direction.DOWN),
--             Door( 19,  22, Direction.UP),
--             Door( 24,  13, Direction.RIGHT),
--             Door( 32,  11, Direction.DOWN),
--             Door( 40,  16, Direction.UP),
--             Door( 52,   8, Direction.UP),
--             Door( 52,  19, Direction.DOWN),
--             Door( 57,  21, Direction.DOWN),
--             Door( 64,  21, Direction.UP),
--             Door( 68,  10, Direction.RIGHT),
--             Door( 90,   8, Direction.DOWN),
--             Door( 95,  13, Direction.RIGHT),
--             Door(106,  10, Direction.DOWN),
--             Door(116,  17, Direction.UP),
--             Door(123,  13, Direction.RIGHT),

--             Jukebox(0.5),
--             Guard(
--             {
--                 { x = 672,  y = 320 },
--                 { x = 592,  y = 224 },
--             }),
--             Guard(
--             {
--                 { x = 512,  y = 96 },
--                 { x = 512,  y = 224 },
--             }),
--             Guard(
--             {
--                 { x = 912,  y = 352 },
--                 { x = 912,  y = 240 },
--                 { x = 1280, y = 240 },
--                 { x = 912,  y = 240 },
--             }),
--             Guard(
--             {
--                 { x = 1456, y = 208 },
--                 { x = 848,  y = 208 },
--                 { x = 832,  y =  64 },
--                 { x = 1440, y =  64 },
--             }),
--             Guard(
--             {
--                 { x = 1904, y = 224 },
--                 { x = 1840, y = 336 },
--             }),
--             Guard(
--             {
--                 { x = 1872, y = 336 },
--                 { x = 1856, y = 224 },
--                 { x = 1712, y = 224 },
--             }),
--             George(),
--         },
--     })

--     for _, entity in ipairs(self.entities) do
--         entity:start(self)
--     end

--
-- end

function GameState:__init(map)
    super().__init(self, {
        escaping = false,
        alarm = Alarm(),
        level = Level(map),
        entities = {},
    })

    self:add(Camera.from_config(self, map.config.camera))
    for _, camera_config in ipairs(map.config.security_cameras) do
        self:add(SecurityCamera.from_config(self, camera_config))
    end
    for _, guard_config in ipairs(map.config.guards) do
        self:add(Guard.from_config(self, guard_config))
    end
    for _, door_config in ipairs(map.config.doors) do
        self:add(Door.from_config(self, door_config))
    end
    self:add(George.from_config(self, map.config.george))
end

function GameState:add(entity)
    table.insert(self.entities, entity)
end

function GameState:remove(entity)
    table.remove(self.entities, get_key(self.entities, entity))
end

function GameState:start_all()
    for entity in ipairs(self.entities) do
        entity:start()
    end
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
