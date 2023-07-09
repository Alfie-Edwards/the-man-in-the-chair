require "behaviours.behaviour"
require "behaviours.patrol"
require "behaviours.goto"
require "entities.george"

GuardBehaviour = {
    patrol_behaviour = nil,

    current_sub_behaviour = nil,

    george = nil,
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
    self.current_sub_behaviour = behaviour
    if self.current_sub_behaviour then
        self.current_sub_behaviour:start(self.entity, self.state)
    end
end

function GuardBehaviour:investigate(x, y)
    print("GuardBehaviour:investigate("..x..", "..y..")")
    self:set_sub_behaviour(Goto.new(x, y))
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

    local george_cell_x, george_cell_y = self.state.level:cell(george.x, george.y)

    for _,cell in pairs(self.entity.vision) do
        if cell.x == george_cell_x and
           cell.y == george_cell_y then
           print('seen')
           return true
        end
    end

    return false
end

function GuardBehaviour:not_pursuing()
    local have_behaviour = self.current_sub_behaviour ~= nil
    if not have_behaviour then
        return true
    end

    local behaviour_type = type_string(self.current_sub_behaviour)
    return behaviour_type ~= "Goto"
end

function GuardBehaviour:update(dt)
    super().update(self, dt)
    if self.current_sub_behaviour then
        if self.current_sub_behaviour:update(dt) then
            self:patrol()
        end
    end

    if self:not_pursuing() and self:can_see_george() then
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
