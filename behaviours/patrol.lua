require "behaviours.loop"
require "behaviours.goto"

Patrol = {}
setup_class(Patrol, Loop)

function Patrol:__init(state, patrol_points)
    local gotos = {}
    for i, point in ipairs(patrol_points) do
        gotos[i] = Goto(state, point.x, point.y)
    end
    super().__init(self, state, unpack(gotos))
end

function Patrol:start(entity)
    super().start(self, entity)
    local closest_i = 0
    local closest_dist = math.huge
    for i, sub_behaviour in ipairs(self.sub_behaviours) do
        local d = dist(sub_behaviour.x, sub_behaviour.y, entity.x, entity.y)
        if d < closest_dist then
            closest_i = i
            closest_dist = d
        end
    end
    if closest_i ~= 0 then
        self:set_i(closest_i)
    end
end
