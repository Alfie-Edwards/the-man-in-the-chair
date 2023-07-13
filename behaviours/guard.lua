require "behaviours.behaviour"
require "behaviours.patrol"
require "behaviours.goto_target"
require "entities.george"
require "screens.lose"

GuardBehaviour = {
    patrol_behaviour = nil,
    chase_behaviour = nil,
    current_sub_behaviour = nil,
    t_last = nil,
}
setup_class(GuardBehaviour, Behaviour)

function GuardBehaviour.new(patrol_points)
    local obj = magic_new()

    obj.patrol_behaviour = Patrol.new(patrol_points)

    obj.t_last = love.timer.getTime()

    return obj
end

function GuardBehaviour:start(entity, state)
    super().start(self, entity, state)

    local george = self.state:first("George")
    if george then
        self.chase_behaviour = GotoTarget.new(george)
    end

    self:patrol()
end

function GuardBehaviour:set_sub_behaviour(behaviour)
    self.current_sub_behaviour = behaviour
    if self.current_sub_behaviour then
        self.current_sub_behaviour:start(self.entity, self.state)
    end
end

function GuardBehaviour:investigate(x, y)
    if t_since(self.t_last) > 3 then
        self:set_sub_behaviour(Investigate.new(x, y, 3, 3, 2))

        self.t_last = love.timer.getTime()
    end
end

function GuardBehaviour:patrol()
    self:set_sub_behaviour(self.patrol_behaviour)
end

function GuardBehaviour:chase()
    if self.chase_behaviour and self.current_sub_behaviour ~= self.chase_behaviour then
        self:set_sub_behaviour(self.chase_behaviour)
    end
end

function GuardBehaviour:can_see_george()
    if self.entity.vision == nil then
        return false
    end

    local george = self.state:first("George")

    if george == nil then
        return false
    end

    local george_cell = Cell.new(self.state.level:cell(george.x, george.y))

    return self.entity.vision:contains(george_cell)
end

function GuardBehaviour:not_pursuing()
    local have_behaviour = self.current_sub_behaviour ~= nil
    if not have_behaviour then
        return true
    end

    local behaviour_type = type_string(self.current_sub_behaviour)
    return behaviour_type ~= "Goto"
end

function GuardBehaviour:hit_george()
    local george = self.state:first("George")

    if george == nil then
        return false
    end

    local george_cell_x, george_cell_y = self.state.level:cell(george.x, george.y)
    local cell_x, cell_y = self.state.level:cell(self.entity.x, self.entity.y)

    return cell_x == george_cell_x and
           cell_y == george_cell_y
end

function GuardBehaviour:update(dt)
    super().update(self, dt)
    if self.current_sub_behaviour then
        if self.current_sub_behaviour:update(dt) then
            self:patrol()
        end
    end

    if self:hit_george() then
        self.state:foreach("Jukebox", function(e) e:silence() end)
        view:set_content(LoseScreen.new())
    end

    if self:can_see_george() then
        self:chase()
    end

    return false
end

function GuardBehaviour:draw()
    super().draw(self)
    if self.current_sub_behaviour then
        self.current_sub_behaviour:draw()
    end

    if self.entity.vision ~= nil then
        local cell_size = self.state.level.cell_length_pixels
        for _, cell in pairs(self.entity.vision) do
            love.graphics.setColor({1, 0, 0, 0.1})
            love.graphics.rectangle("fill", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
        end
        love.graphics.setColor({0.2, 0, 0, 1})
        love.graphics.rectangle("fill", self.entity.x * cell_size - 4, self.entity.y * cell_size - 4, 8, 8)
    end
end
