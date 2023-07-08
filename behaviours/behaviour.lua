Behaviour = {}
setup_class(Behaviour)

function Behaviour.new()
    local obj = magic_new()

    return obj
end

function Behaviour:update(entity, dt, state)
    return true
end

function Behaviour:draw(entity, state)
end
