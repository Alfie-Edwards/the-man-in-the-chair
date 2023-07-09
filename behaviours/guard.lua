require "behaviours.behaviour"
require "behaviours.patrol"
require "behaviours.goto"
require "entities.george"
require "screens.lose"

GuardBehaviour = {
    patrol_behaviour = nil,

    current_sub_behaviour = nil,

    george = nil,

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
    self:patrol()
end

function GuardBehaviour:set_sub_behaviour(behaviour)
    self.current_sub_behaviour = behaviour
    if self.current_sub_behaviour then
        self.current_sub_behaviour:start(self.entity, self.state)
    end
end

function GuardBehaviour:investigate(x, y)
    -- if self:not_pursuing() then
    --     self:set_sub_behaviour(Goto.new(x, y))
    --     return
    -- end

    if t_since(self.t_last) > 3 then
        self:set_sub_behaviour(Goto.new(x, y))
        -- self.current_sub_behaviour.x = x
        -- self.current_sub_behaviour.y = y
        -- self.current_sub_behaviour:start(self.entity, self.state)

        self.t_last = love.timer.getTime()
    end
end

function GuardBehaviour:patrol()
    self:set_sub_behaviour(self.patrol_behaviour)
end

function GuardBehaviour:get_george_entity()
    if self.george ~= nil then
        return self.george
    end

    local george = nil

    for _,ntt in ipairs(self.state.entities) do
        if type_string(ntt) == "George" then
            self.george = ntt
            return ntt
        end
    end

    print("WARNING: couldn't find george!")
    return nil
end

function GuardBehaviour:can_see_george()
    if self.entity.vision == nil then
        return false
    end

    local george = self:get_george_entity()

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
    local george = self:get_george_entity()

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
        for _, e in ipairs(self.state.entities) do
            if type_string(e) == "Jukebox" then
                e:silence()
            end
        end
        view:set_content(LoseScreen.new())
    end

    -- if self:not_pursuing() and self:can_see_george() then
    if self:can_see_george() then
        local george = self:get_george_entity()
        self:investigate(george.x, george.y)
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
