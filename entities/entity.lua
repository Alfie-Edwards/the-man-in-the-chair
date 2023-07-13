Entity = {
    behaviour = nil,
    state = nil,
}
setup_class(Entity)

function Entity.new(x, y)
    local obj = magic_new()

    return obj
end

function Entity:init(state)
    self.state = state
    if self.behaviour then
        self.behaviour:start(self, state)
    end
end


function Entity:update(dt)
    if self.behaviour ~= nil then
        if self.behaviour:update(dt) then
            self.behaviour = nil
        end
    end
end

function Entity:draw()
    if self.behaviour ~= nil then
        self.behaviour:draw()
    end
end
