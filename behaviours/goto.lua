require "behaviours.behaviour"

Goto = {
    x = nil,
    y = nil,
}
setup_class(Goto, Behaviour)

function Goto.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y

    return obj
end

function Goto:update(entity, dt, state)

    local d = Vector.new(entity.x, entity.y, self.x, self.y)
    local sql = d:sq_length()
    if sql <= (entity.speed * entity.speed) then
        entity.x = self.x
        entity.y = self.y
        return true
    else
        local l = sql ^ (1 / 2)
        entity.x = entity.x + d:dx() * entity.speed / l
        entity.y = entity.y + d:dy() * entity.speed / l
        return false
    end
end

function Goto:draw(entity, state)
end
