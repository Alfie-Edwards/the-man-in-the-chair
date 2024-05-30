require "entities.entity"

Camera = {
    PAN_SPEED = 250,

    x = nil,
    y = nil,
}
setup_class(Camera, Entity)

function Camera:__init(state, x, y)
    super().__init(self, state)

    self.x = x
    self.y = y
end

function Camera.from_config(state, config)
    return Camera(state, config.position.x, config.position.y)
end

function Camera:update(dt)
    local movement = Vector(0, 0, 0, 0)

    if love.keyboard.isDown("up", "w") then
        movement.y2 = -1
    end
    if love.keyboard.isDown("down", "s") then
        movement.y2 = 1
    end
    if love.keyboard.isDown("left", "a") then
        movement.x2 = -1
    end
    if love.keyboard.isDown("right", "d") then
        movement.x2 = 1
    end

    if movement:length() == 0 then
        return
    end

    movement:scale_to_length(Camera.PAN_SPEED * dt)

    self.x = math.floor(clamp(self.x + movement.x2, 0, self.state.level:width_pixels() - canvas:width()))
    self.y = math.floor(clamp(self.y + movement.y2, 0, self.state.level:height_pixels() - canvas:height()))
end

function Camera:apply_transform()
    love.graphics.translate(-self.x, -self.y)
end
