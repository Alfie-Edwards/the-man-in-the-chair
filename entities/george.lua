require "entities.movable"
require "behaviours.george"
require "direction"

George = {
    SPEED = 60,

    SPRITE_SETS = {
        idle = sprite.make_set("Sprites/", {
            left  = "GeorgeLeft1",
            right = "GeorgeRight1",
            up    = "GeorgeBack1",
            down  = "GeorgeFront1",
        }),
        walk = sprite.make_set("Sprites/", {
            left = {
                "GeorgeLeft1",
                "GeorgeLeft2",
                "GeorgeLeft3",
                "GeorgeLeft4",
            },
            right = {
                "GeorgeRight1",
                "GeorgeRight2",
                "GeorgeRight3",
                "GeorgeRight4",
            },
            up = {
                "GeorgeBack1",
                "GeorgeBack2",
                "GeorgeBack3",
                "GeorgeBack4",
            },
            down = {
                "GeorgeFront1",
                "GeorgeFront2",
                "GeorgeFront3",
                "GeorgeFront4",
            },
        }),
    },
    WALK_CYCLE_PERIOD = 0.75,
    HAS_FOOTSTEP_SOUNDS = true,

    speed = nil,
}
setup_class(George, Movable)

function George.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y
    obj.speed = George.SPEED
    obj.behaviour = GeorgeBehaviour.new()
    obj.direction = Direction.DOWN

    return obj
end

function George.from_config(config)
    return George.new(config.x, config.y)
end

function George:draw()
    super().draw(self)

    love.graphics.setColor({1, 1, 1, 1})
    local sprite = self:sprite()
    if sprite ~= nil then
        love.graphics.draw(sprite,
                           self.x - sprite:getWidth() / 2,
                           self.y - sprite:getHeight(),
                           0, 1, 1)
    end
end
