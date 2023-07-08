require "behaviours.behaviour"

DoorBehaviour = {
}
setup_class(DoorBehaviour, Behaviour)

function DoorBehaviour.new()
    local obj = magic_new()

    return obj
end

function DoorBehaviour:update(entity, dt, state)
    for _,c in ipairs(entity:active_cells()) do
        state.level:set_door_cell_solid(c.x, c.y, entity:is_solid())
    end
end

function DoorBehaviour:draw(entity, state)
end
