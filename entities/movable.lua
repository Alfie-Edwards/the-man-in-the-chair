require "entities.entity"
require "sprite"

Movable = {
    SPRITE_SETS = {
        idle = {},
        walk = {},
    },

    WALK_CYCLE_PERIOD = 0.5,

    x = nil,
    y = nil,
    direction = nil,

    moved_last = nil,
}
setup_class(Movable, Entity)

function Movable.new()
    local obj = magic_new()

    obj.moved_last = false

    return obj
end

function Movable:is_moving()
    return self.moved_last
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

function Movable:accessible_cells(state)
    return state.level.cells - (state.level.solid_cells + state.level.solid_door_cells)
end

function Movable:update(dt, state)
    local old_x, old_y = self.x, self.y

    super().update(self, dt)

    self.moved_last = old_x ~= self.x or old_y ~= self.y
end
