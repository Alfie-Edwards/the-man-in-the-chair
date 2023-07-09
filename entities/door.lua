require "entities.entity"
require "direction"
require "behaviours.door"
require "sprite"

DoorState = { CLOSED = 1, OPEN = 2 }
DoorLockState = { LOCKED = 1, UNLOCKED = 2 }

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
    lock_state = nil,

    last_toggled = nil,
}
setup_class(Door, Entity)

function Door.new(x, y, facing, dead_end)
    local obj = magic_new()

    obj.x = x
    obj.y = y
    obj.facing = facing
    obj.facing_rev = facing
    if not obj.dead_end then
        obj.facing_rev = direction_opposite(facing)
    end
    obj.state = DoorState.CLOSED
    obj.lock_state = DoorLockState.UNLOCKED
    obj.last_toggled = t_since(Door.ANIM_DURATION_SECONDS)
    obj.behaviour = DoorBehaviour.new()

    return obj
end

function Door:is_transitioning()
    return t_since(self.last_toggled) < Door.ANIM_DURATION_SECONDS
end

function Door:is_solid()
    return self.state == DoorState.CLOSED or self:is_transitioning()
end

function Door:cell_before(state)
    local facing = self.facing
    if state.escaping then
        facing = self.facing_rev
    end
    if facing == Direction.RIGHT then
        return Cell.new(self.x - 1, self.y)
    elseif self.facing == Direction.UP then
        return Cell.new(self.x, self.y + 1)
    elseif self.facing == Direction.LEFT then
        return Cell.new(self.x + 1, self.y)
    else
        return Cell.new(self.x, self.y - 1)
    end
end

function Door:cell_after(state)
    local facing = self.facing
    if state.escaping then
        facing = self.facing_rev
    end
    if self.facing == Direction.RIGHT then
        return Cell.new(self.x + 1, self.y)
    elseif self.facing == Direction.UP then
        return Cell.new(self.x, self.y - 1)
    elseif self.facing == Direction.LEFT then
        return Cell.new(self.x - 1, self.y)
    else
        return Cell.new(self.x, self.y + 1)
    end
end

function Door:active_cells()
    if self.facing == Direction.UP or
       self.facing == Direction.DOWN then
        return HashSet.new(
            Cell.new(self.x, self.y),
            Cell.new(self.x + 1, self.y)
        )
    else
        return HashSet.new(
            Cell.new(self.x, self.y),
            Cell.new(self.x, self.y + 1)
        )
    end
end

function Door:open()
    if self.state == DoorState.CLOSED then
        self.state = DoorState.OPEN
        self.last_toggled = love.timer.getTime()
        Door.OPEN_SOUND:play()
    end
end

function Door:close()
    if self.state == DoorState.OPEN then
        self.state = DoorState.CLOSED
        self.last_toggled = love.timer.getTime()
        Door.OPEN_SOUND:play()
    end
end

function Door:toggle()
    if self:is_transitioning() then
        return self.state
    end

    if self.state == DoorState.CLOSED then
        self:open()
    elseif self.state == DoorState.OPEN then
        self:close()
    end

    return self.state
end

function Door:is_locked()
    return self.lock_state == DoorLockState.LOCKED
end

function Door:lock()
    self.lock_state = DoorLockState.LOCKED
end

function Door:unlock()
    self.lock_state = DoorLockState.UNLOCKED
    self:close()
end

function Door:lock_open()
    if self:is_transitioning() then
        return self.state
    end

    self:lock()
    self:open()

    return self.state
end

function Door:lock_closed()
    if self:is_transitioning() then
        return self.state
    end

    self:lock()
    self:close()

    return self.state
end

function Door:sprite()
    local seq = sprite.directional(Door.SPRITES, self.facing)
    if self.state == DoorState.CLOSED then
        seq = reverse(seq)
    end
    return sprite.sequence(seq,
                           Door.ANIM_DURATION_SECONDS,
                           t_since(self.last_toggled))
end

function Door:pixel_pos(state)
    return {
        x = self.x * state.level.cell_length_pixels,
        y = self.y * state.level.cell_length_pixels
    }
end

function Door:any_guard_near(state)
    for _, e in ipairs(state.entities) do
        if type_string(e) == "Guard" and sq_dist(e.x, e.y, (self.x + 0.5) * state.level.cell_length_pixels, (self.x + 0.5) * state.level.cell_length_pixels) < 1.5 then
            return true
        end
    end
end

function Door:draw_cells(state)
    love.graphics.setColor({0, 0, 1, 0.5})
    for _,c in ipairs(self:active_cells()) do
        love.graphics.rectangle("fill",
            c.x * state.level.cell_length_pixels,
            c.y * state.level.cell_length_pixels,
            state.level.cell_length_pixels,
            state.level.cell_length_pixels)
    end
end

function Door:draw(state)
    super().draw(self, state)

    local sprite = self:sprite()
    local pos = self:pixel_pos(state)

    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.draw(sprite, pos.x, pos.y, 0, 1, 1)
end
