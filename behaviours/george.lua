require "behaviours.behaviour"
require "behaviours.default_behaviour"
require "behaviours.find_door"
require "screens.win"

GeorgeBehaviour = {
    find_door_behaviour = nil,
}
setup_class(GeorgeBehaviour, DefaultBehaviour)

function GeorgeBehaviour.new()
    local obj = magic_new(GeorgeBehaviour.find_door)

    obj.find_door_behaviour = FindDoor.new()

    return obj
end

function GeorgeBehaviour:find_door()
    self:set_sub_behaviour(self.find_door_behaviour)
end

function GeorgeBehaviour:update(dt)
    super().update(self, dt)
    if self.entity.x and self.entity.x > 123 * 16 then
        self.state:foreach("Jukebox",
            function(jukebox)
                jukebox:silence()
            end
        )
        view:set_content(WinScreen.new())
    end
    return false
end
