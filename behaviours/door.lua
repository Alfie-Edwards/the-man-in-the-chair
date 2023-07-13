require "behaviours.behaviour"

DoorBehaviour = {
}
setup_class(DoorBehaviour, Behaviour)

function DoorBehaviour.new()
    local obj = magic_new()

    return obj
end

function DoorBehaviour:update(dt)
    super().update(self, dt)
    for _, c in pairs(self.entity:active_cells()) do
        self.state.level:set_door_cell_solid(c, self.entity)
    end
    if self.entity:any_guard_near(self.state) and not self.entity.is_locked then
        self.entity:open()
    elseif not self.entity.is_locked then
        self.entity:close()
    end
end
