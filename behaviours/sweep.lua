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
        return false
    end

    local george = nil

    for _,ntt in ipairs(self.state.entities) do
        if type_string(ntt) == "George" then
            george = ntt
            return ntt
        end
    end

    if george == nil then
        return false
    end

    local george_cell_x, george_cell_y = self.state.level:cell(george.x, george.y)

    for _, cell in pairs(self.entity.vision) do
        if cell.x == george_cell_x and
           cell.y == george_cell_y then
           
           return true
        end
    end

    return false
end


function Sweep:update(dt)
    super().update(self, dt)

    if self:can_see_george() then
        for _,ntt in ipairs(self.state.entities) do
            if type_string(ntt) == "Guard" then
                ntt.behaviour:set_sub_behaviour(Investigate.new(self.entity.x + self.state.level.cell_length_pixels, self.entity.y + self.state.level.cell_length_pixels, 3, 3, 2))
                return false
            end
        end
    end

    return false
end
