require "behaviours.behaviour"
require "behaviours.find_door"
require "screens.win"

DefaultBehaviour = {
    default_behaviour = nil,
    sub_behaviour = nil,
}
setup_class(DefaultBehaviour, Behaviour)

function DefaultBehaviour.new(default_behaviour_fn)
    local obj = magic_new()

    obj.default_behaviour_fn = default_behaviour_fn

    return obj
end

function DefaultBehaviour:start(entity, state)
    super().start(self, entity, state)
    self.default_behaviour_fn(self)
end

function DefaultBehaviour:set_sub_behaviour(behaviour)
    self.sub_behaviour = behaviour
    if self.sub_behaviour then
        self.sub_behaviour:start(self.entity, self.state)
    end
end

function DefaultBehaviour:doing(behaviour)
    if not type(behaviour) == "string" then
        -- Allow passing raw type.
        behaviour = type_string(behaviour)
    end

    return type_string(self.sub_behaviour) == behaviour
end

function DefaultBehaviour:update(dt)
    super().update(self, dt)

    if self.sub_behaviour then
        if self.sub_behaviour:update(dt) then
            self.default_behaviour_fn(self)
        end
    end
    return false
end

function DefaultBehaviour:draw()
    super().draw(self)
    if self.sub_behaviour then
        self.sub_behaviour:draw()
    end
end
