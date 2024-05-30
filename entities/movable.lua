require "entities.entity"
require "sprite"

Movable = {
    SPRITE_SETS = {
        idle = {},
        walk = {},
    },

    WALK_CYCLE_PERIOD = 0.5,
    HAS_FOOTSTEP_SOUNDS = false,

    x = nil,
    y = nil,
    direction = nil,

    footstep_sounds = nil,
    footstep_period = nil,
    t_last_footstep = nil,

    moved_last_tick = nil,

    emote = nil,
}
setup_class(Movable, Entity)

function Movable:__init(state)
    super().__init(self, state)

    self.moved_last_tick = false

    self.footstep_sounds = {
        assets:get_sound("Sound/Footstep1", "wav"),
        assets:get_sound("Sound/Footstep2", "wav"),
        assets:get_sound("Sound/Footstep3", "wav"),
    }
    self.footstep_period = self.WALK_CYCLE_PERIOD / 2
    self.t_last_footstep = t_since(self.footstep_period)
end

function Movable:is_moving()
    return self.moved_last_tick
end

function Movable:sprite()
    if self:is_moving() then
        return sprite.cycling(sprite.directional(self.SPRITE_SETS.walk, self.direction),
                              self.WALK_CYCLE_PERIOD)
    end

    if self.direction ~= nil then
        return sprite.directional(self.SPRITE_SETS.idle, self.direction)
    end

    return nil
end

function Movable:accessible_cells()
    return self.state.level.cells - (self.state.level.solid_cells + self.state.level.solid_door_cells)
end

function Movable:play_footstep()
    if not (self.HAS_FOOTSTEP_SOUNDS and self:is_moving()) then
        return
    end

    local sound = choice(self.footstep_sounds)
    sound:stop()
    sound:play()

    self.t_last_footstep = love.timer.getTime()
end

function Movable:update(dt)
    local old_x, old_y = self.x, self.y
    super().update(self, dt)
    self.moved_last_tick = old_x ~= self.x or old_y ~= self.y

    if t_since(self.t_last_footstep) >= self.footstep_period then
        self:play_footstep()
    end
end

function Movable:draw()
    super().draw(self)

    local cell_size = self.state.level.cell_length_pixels
    if self.emote ~= nil then
        self.emote:draw(self.x, self.y - cell_size * 2.5)
    end
end
