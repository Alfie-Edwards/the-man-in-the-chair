require "behaviours.behaviour"
require "behaviours.find_door"
require "screens.win"

GeorgeBehaviour = {
    find_door_behaviour = nil,
    sub_behaviour = nil,
}
setup_class(GeorgeBehaviour, Behaviour)

function GeorgeBehaviour.new()
    local obj = magic_new()

    obj.find_door_behaviour = FindDoor.new()


    return obj
end

function GeorgeBehaviour:start(entity, state)
    super().start(self, entity, state)
    self:find_door()
end

function GeorgeBehaviour:set_sub_behaviour(behaviour)
    self.sub_behaviour = behaviour
    if self.sub_behaviour then
        self.sub_behaviour:start(self.entity, self.state)
    end
end

function GeorgeBehaviour:find_door()
    self:set_sub_behaviour(self.find_door_behaviour)
end

function GeorgeBehaviour:update(dt)
    super().update(self, dt)
    if self.entity.x and self.entity.x > 123 * 16 then
        for _, e in ipairs(self.state.entities) do
            if type_string(e) == "Jukebox" then
                e:silence()
            end
        end
        view:set_content(WinScreen.new())
    end
    if self.sub_behaviour then
        if self.sub_behaviour:update(dt) then
            self:find_door()
        end
    end
    return false
end

function GeorgeBehaviour:draw()
    super().draw(self)
    if self.sub_behaviour then
        self.sub_behaviour:draw()
    end
end
