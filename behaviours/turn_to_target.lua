require "behaviours.behaviour"

TurnToTarget = {
    target = nil,
    min = nil,
    max = nil,
}
setup_class(TurnToTarget, Behaviour)

function TurnToTarget:__init(state, target, min, max)
    super().__init(self, state)

    self.target = target
    self.min = normalize_angle(min)
    self.max = normalize_angle(max)
end

function TurnToTarget:update(dt)
    super().update(self, dt)

    local cx, cy = self.entity:centre()
    local displacement = Vector(cx, cy, self.target.x, self.target.y)
    local target_angle = math.atan2(displacement:dy(), displacement:dx())

    local past_min = normalize_angle(self.min - target_angle)
    local past_max = normalize_angle(target_angle - self.max)
    if past_max > 0 and (past_min < 0 or past_min > past_max) then
        target_angle = self.max
    elseif past_min > 0 and (past_max < 0 or past_max > past_min) then
        target_angle = self.min
    end

    self.entity.angle = target_angle
end
