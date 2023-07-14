require "behaviours.behaviour"
require "behaviours.sweep"
require "behaviours.turn_to_target"

SecurityCameraBehaviour = {
    SWEEP_ANGLE = math.pi / 2,
    WAIT_TIME = 5,
    SWEEP_SPEED = 0.5,

    sweep_behaviour = nil,
    watch_behaviour = nil,
    angle = nil,
}
setup_class(SecurityCameraBehaviour, DefaultBehaviour)

function SecurityCameraBehaviour.new(angle)
    local obj = magic_new(SecurityCameraBehaviour.sweep)

    obj.angle = angle
    obj.sweep_behaviour = Sweep.new(
        obj.angle,
        SecurityCameraBehaviour.SWEEP_ANGLE,
        SecurityCameraBehaviour.WAIT_TIME,
        SecurityCameraBehaviour.SWEEP_SPEED
    )

    return obj
end

function SecurityCameraBehaviour:start(entity, state)
    super().start(self, entity, state)

    local george = self.state:first("George")
    if george then
        self.watch_behaviour = TurnToTarget.new(
            george,
            self.angle - SecurityCameraBehaviour.SWEEP_ANGLE / 2,
            self.angle + SecurityCameraBehaviour.SWEEP_ANGLE / 2
        )
    end
end

function SecurityCameraBehaviour:sweep()
    self:set_sub_behaviour(self.sweep_behaviour)
end

function SecurityCameraBehaviour:watch()
    self:set_sub_behaviour(self.watch_behaviour)
end


function SecurityCameraBehaviour:can_see_george()
    if self.entity.vision == nil then
        return
    end

    local george = self.state:first("George")

    if george == nil then
        return
    end

    local george_cell = Cell.new(self.state.level:cell(george.x, george.y))

    return self.entity.vision:contains(george_cell)
end


function SecurityCameraBehaviour:update(dt)
    super().update(self, dt)

    if self:can_see_george() then
        local george = self.state:first("George")

        if not self:doing("TurnToTarget") then
            self:watch()
        end

        self.state.alarm.is_on = true
        local closest_guard = nil
        local closest_guard_dist = math.huge
        self.state:foreach("Guard",
            function(guard)
                local d = sq_dist(guard.x, guard.y, george.x, george.y)
                if d < closest_guard_dist then
                    closest_guard = guard
                    closest_guard_dist = d
                end
            end
        )
        if closest_guard ~= nil and not closest_guard.behaviour:doing("Investigate") then
            closest_guard.behaviour:investigate(george.x, george.y)
        end
    elseif self:doing("TurnToTarget") then
        self:sweep()
    end

    return false
end
