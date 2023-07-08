require "utils.vector"

Camera = {
    PAN_SPEED = 250,

    x = nil,
    y = nil,
}
setup_class(Camera)

function Camera.new(canvas, level)
    local obj = magic_new()

    obj.x = 0
    obj.y = 0

    return obj
end

function Camera:update(dt, state)
    local movement = Vector.new(0, 0, 0, 0)

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

    self.x = clamp(self.x + movement.x2, 0, state.level:width_pixels() - canvas:width())
    self.y = clamp(self.y + movement.y2, 0, state.level:height_pixels() - canvas:height())
end
