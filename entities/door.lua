require "entities.entity"
require "behaviours.door"
require "sprite"

Door = {
    SPRITES = sprite.make_set("Textures/", {
        up = {
            "DoorBott1",
            "DoorBott2",
            "DoorBott3",
            "DoorBott4",
            "DoorBott5",
            "DoorBott6",
        },
        down = {
            "DoorTop1",
            "DoorTop2",
            "DoorTop3",
            "DoorTop4",
            "DoorTop5",
            "DoorTop6",
        },
        left = {
            "DoorRight1",
            "DoorRight2",
            "DoorRight3",
            "DoorRight4",
            "DoorRight5",
            "DoorRight6",
        },
        right = {
            "DoorLeft1",
            "DoorLeft2",
            "DoorLeft3",
            "DoorLeft4",
            "DoorLeft5",
            "DoorLeft6",
        },
    }),
    ANIM_DURATION_SECONDS = 0.25,

    OPEN_SOUND = assets:get_sound("Sound/SFXDoor", "wav"),

    x = nil,
    y = nil,
    facing = nil,
    state = nil,
    is_open = nil,
    is_locked = nil,
    last_toggled = nil,
}
setup_class(Door, Entity)

function Door:__init(state, x, y, facing, dead_end)
    super().__init(self, state)

    self.x = x
    self.y = y
    self.facing = facing
    self.facing_rev = facing
    if not self.dead_end then
        self.facing_rev = direction_opposite(facing)
    end
    self.is_open = false
    self.is_locked = false
    self.last_toggled = t_since(Door.ANIM_DURATION_SECONDS)
    self.behaviour = DoorBehaviour(state)
end

function Door.from_config(state, config)
    return Door(state, config.position.x, config.position.y, config.direction)
end

function Door:is_transitioning()
    return t_since(self.last_toggled) < Door.ANIM_DURATION_SECONDS
end

function Door:is_solid()
    return (not self.is_open) or self:is_transitioning()
end

function Door:pos_outside()
    local facing = self.facing
    if self.state.escaping then
        facing = self.facing_rev
    end
    if facing == Direction.RIGHT then
        return self.x - 0.5, self.y + 1
    elseif self.facing == Direction.UP then
        return self.x + 1, self.y + 1.5
    elseif self.facing == Direction.LEFT then
        return self.x + 1.5, self.y + 1
    else
        return self.x + 1, self.y - 0.5
    end
end

function Door:pos_inside()
    local facing = self.facing
    if self.state.escaping then
        facing = self.facing_rev
    end
    if self.facing == Direction.RIGHT then
        return self.x + 1.5, self.y + 1
    elseif self.facing == Direction.UP then
        return self.x + 1, self.y - 0.5
    elseif self.facing == Direction.LEFT then
        return self.x - 0.5, self.y + 1
    else
        return self.x + 1, self.y + 1.5
    end
end

function Door:active_cells()
    if self.facing == Direction.UP or
       self.facing == Direction.DOWN then
        return HashSet(
            Cell(self.x, self.y),
            Cell(self.x + 1, self.y)
        )
    else
        return HashSet(
            Cell(self.x, self.y),
            Cell(self.x, self.y + 1)
        )
    end
end

function Door:open()
    if not self.is_open then
        self.is_open = true
        self.last_toggled = love.timer.getTime()
        Door.OPEN_SOUND:play()
    end
end

function Door:close()
    if self.is_open then
        self.is_open = false
        self.last_toggled = love.timer.getTime()
        Door.OPEN_SOUND:play()
    end
end

function Door:toggle()
    if self:is_transitioning() then
        return self.is_open
    end

    if self.is_open then
        self:close()
    else
        self:open()
    end

    return self.is_open
end

function Door:lock()
    self.is_locked = true
end

function Door:unlock()
    self.is_locked = false
    self:close()
end

function Door:lock_open()
    if self:is_transitioning() then
        return self.is_open
    end

    self:lock()
    self:open()

    return self.is_open
end

function Door:lock_closed()
    if self:is_transitioning() then
        return self.is_open
    end

    self:lock()
    self:close()

    return self.is_open
end

function Door:sprite()
    local seq = sprite.directional(Door.SPRITES, self.facing)
    if not self.is_open then
        seq = reverse(seq)
    end
    return sprite.sequence(seq,
                           Door.ANIM_DURATION_SECONDS,
                           t_since(self.last_toggled))
end

function Door:pixel_pos()
    return {
        x = self.x * self.state.level.cell_length_pixels,
        y = self.y * self.state.level.cell_length_pixels
    }
end

function Door:any_guard_near()
    return self.state:any("Guard",
        function(guard)
            return sq_dist(
                    guard.x, guard.y,
                    (self.x + 0.5) * self.state.level.cell_length_pixels,
                    (self.x + 0.5) * self.state.level.cell_length_pixels
                ) < 1.5
        end
    )
end

function Door:draw_cells()
    love.graphics.setColor({0, 0, 1, 0.5})
    for _,c in ipairs(self:active_cells()) do
        love.graphics.rectangle("fill",
            c.x * self.state.level.cell_length_pixels,
            c.y * self.state.level.cell_length_pixels,
            self.state.level.cell_length_pixels,
            self.state.level.cell_length_pixels)
    end
end

function Door:draw()
    super().draw(self)

    local sprite = self:sprite()
    local pos = self:pixel_pos(self.state)

    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.draw(sprite, pos.x, pos.y, 0, 1, 1)
end
