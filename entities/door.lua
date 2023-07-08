require "entities.entity"
require "direction"
require "behaviours.door"
require "sprite"

DoorState = { CLOSED = 1, OPEN = 2 }

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
    ANIM_DURATION_SECONDS = 1,

    x = nil,
    y = nil,
    facing = nil,
    state = nil,

    last_toggled = nil,
}
setup_class(Door, Entity)

function Door.new(x, y, facing)
    local obj = magic_new()

    obj.x = x
    obj.y = y
    obj.facing = facing
    obj.state = DoorState.CLOSED
    obj.last_toggled = love.timer.getTime() - Door.ANIM_DURATION_SECONDS
    obj.behaviour = DoorBehaviour.new()

    return obj
end

function Door:is_transitioning()
    return love.timer.getTime() - self.last_toggled < Door.ANIM_DURATION_SECONDS
end

function Door:is_solid()
    return self.state == DoorState.CLOSED or self:is_transitioning()
end

function Door:active_cells()
    if self.facing == Direction.UP or
       self.facing == Direction.DOWN then
        return {
            { x = self.x, y = self.y },
            { x = self.x + 1, y = self.y },
        }
    else
        return {
            { x = self.x, y = self.y },
            { x = self.x, y = self.y + 1 },
        }
    end
end

function Door:toggle()
    if self:is_transitioning() then
        return self.state
    end

    if self.state == DoorState.CLOSED then
        self.state = DoorState.OPEN
    elseif self.state == DoorState.OPEN then
        self.state = DoorState.CLOSED
    end

    self.last_toggled = love.timer.getTime()

    return self.state
end

function Door:sprite()
    local seq = sprite.directional(Door.SPRITES, self.facing)
    if self.state == DoorState.CLOSED then
        seq = reverse(seq)
    end
    return sprite.sequence(seq,
                           Door.ANIM_DURATION_SECONDS,
                           love.timer.getTime() - self.last_toggled)
end

function Door:pixel_pos(state)
    return {
        x = self.x * state.level.cell_length_pixels,
        y = self.y * state.level.cell_length_pixels
    }
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
