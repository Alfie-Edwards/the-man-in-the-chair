Behaviour = {
    entity = nil,
    state = nil,
}
setup_class(Behaviour)

function Behaviour.new()
    local obj = magic_new()

    return obj
end

function Behaviour:start(entity, state)
    self.entity = entity
    self.state = state
end

function Behaviour:update(dt)
    return true
end

function Behaviour:draw()
end
