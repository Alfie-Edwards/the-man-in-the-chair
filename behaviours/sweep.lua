require "behaviours.loop"
require "behaviours.turn"
require "behaviours.wait"
require "behaviours.investigate"

Sweep = {}
setup_class(Sweep, Loop)

function Sweep.new(angle, sweep, wait_time)
    local obj = magic_new(
        Turn.new(angle - sweep / 2),
        Wait.new(wait_time),
        Turn.new(angle + sweep / 2),
        Wait.new(wait_time)
    )

    return obj
end


function Sweep:can_see_george()
    if self.entity.vision == nil then
        return
    end

    local george = self.state:first("George")

    if george == nil then
        return
    end

    local george_cell = Cell.new(self.state.level:cell(george.x, george.y))

    if self.entity.vision:contains(george_cell) then

        self.state.alarm.is_on = true
        local closest_guard = nil
        local closest_guard_dist = math.huge
        for _,ntt in ipairs(self.state.entities) do
            if type_string(ntt) == "Guard" then
                local d = sq_dist(ntt.x, ntt.y, george.x, george.y)
                if d < closest_guard_dist then
                    closest_guard = ntt
                    closest_guard_dist = d
                end
            end
        end
        if closest_guard == nil then
            return
        end
        if type_string(closest_guard.behaviour.current_sub_behaviour) == "Investigate" then
            return
        end
        closest_guard.behaviour:set_sub_behaviour(Investigate.new(george.x, george.y, 3, 3, 2))
    end
end


function Sweep:update(dt)
    super().update(self, dt)
    self:can_see_george()
    return false
end
