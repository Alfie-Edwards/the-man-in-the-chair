require "entities.entity"

Movable = {
    direction = nil,
}
setup_class(Movable, Entity)

function Movable.new()
    local obj = magic_new()

    return obj
end

function Movable:accessible_cells(state)
    return state.level.cells - (state.level.solid_cells + state.level.solid_door_cells)
end
