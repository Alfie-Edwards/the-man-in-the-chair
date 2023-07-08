Entity = {
    behaviour = nil,
}
setup_class(Entity)

function Entity.new(x, y)
    local obj = magic_new()

    return obj
end

function Entity:update(dt, state)
    if self.behaviour ~= nil then
        if self.behaviour:update(self, dt, state) then
            self.behaviour = nil
        end
    end
end

function Entity:draw(state)
    if self.behaviour ~= nil then
        self.behaviour:draw(self, state)
    end
end
