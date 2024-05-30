Entity = {
    behaviour = nil,
    state = nil,
}
setup_class(Entity)

function Entity:__init(state)
    super().__init(self)
    self.state = state
end

function Entity:start()
    if self.behaviour then
        self.behaviour:start(self)
    end
end


function Entity:update(dt)
    if self.behaviour ~= nil and self.behaviour:started(self) then
        if self.behaviour:update(dt) then
            self.behaviour = nil
        end
    end
end

function Entity:draw()
    if self.behaviour ~= nil and self.behaviour.entity == self then
        self.behaviour:draw()
    end
end
