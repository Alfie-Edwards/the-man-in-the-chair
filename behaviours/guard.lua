require "behaviours.behaviour"
require "behaviours.patrol"
require "behaviours.investigate"

GuardBehaviour = {
    patrol_behaviour = nil,
    investigate_behaviour = nil,
    sub_behaviour = nil,
}
setup_class(GuardBehaviour, Behaviour)

function GuardBehaviour.new(patrol_points)
    local obj = magic_new()

    obj.patrol_behaviour = Patrol.new(patrol_points)

    return obj
end

function GuardBehaviour:start(entity, state)
    super().start(self, entity, state)
    self:patrol()
end

function GuardBehaviour:set_sub_behaviour(behaviour)
    self.sub_behaviour = behaviour
    if self.sub_behaviour then
        self.sub_behaviour:start(self.entity, self.state)
    end
end

function GuardBehaviour:investigate(x, y)
    self:set_sub_behaviour(Investigate.new(x, y, 32, 3, 2))
end

function GuardBehaviour:patrol()
    self:set_sub_behaviour(self.patrol_behaviour)
end

function GuardBehaviour:update(dt)
    super().update(self, dt)
    if self.sub_behaviour then
        self.sub_behaviour:update(dt)
    end
    return false
end

function GuardBehaviour:draw()
    super().draw(self)
    if self.sub_behaviour then
        self.sub_behaviour:draw()
    end
end
