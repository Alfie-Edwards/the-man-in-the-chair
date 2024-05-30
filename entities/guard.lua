require "entities.movable"
require "behaviours.guard"

Guard = {
    SPEED = 80,

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

function Guard:__init(state, patrol_points)
    super().__init(self, state)

    assert(#patrol_points, "Guard must have at least 1 patrol point.")
    self.x = patrol_points[1].x
    self.y = patrol_points[1].y
    self.speed = Guard.SPEED
    self.behaviour = GuardBehaviour(state, patrol_points)
    self.direction = Direction.DOWN
    self.vision = HashSet()
    self.moved_last = false
end

function Guard.from_config(state, config)
    return Guard(state, config.patrol_points)
end

function Guard:accessible_cells()
    return self.state.level.cells - (self.state.level.solid_cells + self.state.level.locked_door_cells)
end

function Guard:update(dt)
    super().update(self, dt)

    self.vision = raycast(
        self.x / self.state.level.cell_length_pixels,
        self.y / self.state.level.cell_length_pixels,
        direction_to_angle(self.direction),
        SecurityCamera.FOV,
        SecurityCamera.VIEW_DISTANCE,
        self.state.level.cells - self.state.level.solid_cells)
end

function Guard:draw()
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
