require "entities.entity"

Movable = {
}
setup_class(Movable, Entity)

function Movable.new()
    local obj = magic_new()

    return obj
end

function Movable:accessible_cells(state)
    return state.level.cells - (state.level.solid_cells + state.level.solid_door_cells)
end

function Movable:draw(state)
    super().draw(self, state)

    love.graphics.setColor({0.5, 0, 0.5, 1})
    love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end

