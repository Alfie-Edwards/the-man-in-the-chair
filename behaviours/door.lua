require "behaviours.behaviour"

DoorBehaviour = {
}
setup_class(DoorBehaviour, Behaviour)

function DoorBehaviour:__init(state)
    super().__init(self, state)
end

function DoorBehaviour:update(dt)
    super().update(self, dt)
    for cell, _ in pairs(self.entity:active_cells()) do
        self.state.level:set_door_cell_solid(cell, self.entity)
    end
    if self.entity:any_guard_near(self.state) and not self.entity.is_locked then
        self.entity:open()
    elseif not self.entity.is_locked then
        self.entity:close()
    end
end
