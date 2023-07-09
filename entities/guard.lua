require "entities.movable"
require "behaviours.guard"
require "direction"


Guard = {
    SPEED = 25,

    SPRITE_SETS = {
        idle = sprite.make_set("Sprites/", {
            left  = "GuardLeft1",
            right = "GuardRight1",
            up    = "GuardBack1",
            down  = "GuardFront1",
        }),
        walk = sprite.make_set("Sprites/", {
            left = {
                "GuardLeft1",
                "GuardLeft2",
                "GuardLeft3",
                "GuardLeft4",
            },
            right = {
                "GuardRight1",
                "GuardRight2",
                "GuardRight3",
                "GuardRight4",
            },
            up = {
                "GuardBack1",
                "GuardBack2",
                "GuardBack3",
                "GuardBack4",
            },
            down = {
                "GuardFront1",
                "GuardFront2",
                "GuardFront3",
                "GuardFront4",
            },
        }),
    },
    vision = nil,
    speed = nil,

    moved_last = nil,
}
setup_class(Guard, Movable)

function Guard.new(patrol_points)
    local obj = magic_new()

    assert(#patrol_points)
    obj.x = patrol_points[1].x
    obj.y = patrol_points[1].y
    obj.speed = Guard.SPEED
    obj.behaviour = GuardBehaviour.new(patrol_points)
    obj.direction = Direction.DOWN
    obj.vision = HashSet.new()
    obj.moved_last = false

    return obj
end

function Guard:accessible_cells(state)
    return state.level.cells - (state.level.solid_cells + state.level.locked_door_cells)
end

function Guard:update(dt, state)
    super().update(self, dt)

    self.vision = raycast(
        state.level,
        self.x,
        self.y,
        direction_to_angle(self.direction),
        SecurityCamera.FOV,
        SecurityCamera.VIEW_DISTANCE * state.level.cell_length_pixels)
end

function Guard:draw(state)
    super().draw(self, state)

    love.graphics.setColor({1, 1, 1, 1})
    local sprite = self:sprite()
    if sprite ~= nil then
        love.graphics.draw(sprite,
                           self.x - sprite:getWidth() / 2,
                           self.y - sprite:getHeight(),
                           0, 1, 1)
    end
end
