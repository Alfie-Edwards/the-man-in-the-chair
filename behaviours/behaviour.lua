Behaviour = {
    entity = nil,
    state = nil,
}
setup_class(Behaviour)

function Behaviour:__init(state)
    super().__init(self)
    assert(is_type(state, "GameState"), "Expected GameState, got "..details_string(state)..".")
    self.state = state
end

function Behaviour:start(entity)
    self.entity = entity
end

function Behaviour:started(entity)
    return self.entity == entity
end

function Behaviour:update(dt)
    return true
end

function Behaviour:draw()
end
