require "entities.entity"
require "behaviours.security_camera"

SecurityCamera = {
    FOV = math.pi / 2,
    VIEW_DISTANCE = 10,

    SPRITE_SETS = {
        down = sprite.make_set("Sprites/", {
            e = "CameraDown5",
            d = "CameraDown4",
            c = "CameraDown1",
            b = "CameraDown2",
            a = "CameraDown3",
        }),
        right = sprite.make_set("Sprites/", {
            a = "CameraRight5",
            b = "CameraRight4",
            c = "CameraRight1",
            d = "CameraRight2",
            e = "CameraRight3",
        }),
        up = sprite.make_set("Sprites/", {
            a = "CameraUp5",
            b = "CameraUp4",
            c = "CameraUp1",
            d = "CameraUp2",
            e = "CameraUp3",
        }),
        left = sprite.make_set("Sprites/", {
            a = "CameraLeft5",
            b = "CameraLeft4",
            c = "CameraLeft1",
            d = "CameraLeft2",
            e = "CameraLeft3",
        }),
    },

    x = nil,
    y = nil,
    angle = nil,
    sweep = nil,
    sweep_speed = nil,
    direction = nil,
    vision = nil,
    emote = nil,
}
setup_class(SecurityCamera, Entity)

function SecurityCamera.new(x, y, direction)
    local obj = magic_new()

    obj.sweep_speed = SecurityCamera.SWEEP_SPEED
    obj.x = x
    obj.y = y
    obj.angle = direction_to_angle(direction)
    obj.direction = direction
    obj.vision = HashSet.new()
    obj.behaviour = SecurityCameraBehaviour.new(obj.angle)

    return obj
end

function SecurityCamera:update(dt)
    super().update(self, dt)
    self.vision = raycast(
        self.state.level,
        self.x * self.state.level.cell_length_pixels,
        self.y * self.state.level.cell_length_pixels,
        self.angle,
        SecurityCamera.FOV,
        SecurityCamera.VIEW_DISTANCE * self.state.level.cell_length_pixels)
end

function SecurityCamera:get_sprite()
    local set = nil
    local ac = direction_to_angle(self.direction)

    if self.direction == Direction.RIGHT then
        set = SecurityCamera.SPRITE_SETS.right
    elseif self.direction == Direction.UP then
        set = SecurityCamera.SPRITE_SETS.up
    elseif self.direction == Direction.LEFT then
        set = SecurityCamera.SPRITE_SETS.left
    else
        set = SecurityCamera.SPRITE_SETS.down
    end

    local a = normalize_angle(self.angle - ac)
    local sector = a * 8 / math.pi
    if sector <= -3 then
        return set.a
    elseif sector <= -1 then
        return set.b
    elseif sector >= 1 then
        return set.d
    elseif sector >= 3 then
        return set.e
    else
        return set.c
    end
end

function SecurityCamera:centre()
    local x_offset = 0.5
    local y_offset = 0.5
    if self.state.level:cell_solid(self.x, self.y) then
        x_offset = direction_to_x(self.direction) * (10 / 16)
        y_offset = direction_to_y(self.direction) * (10 / 16)
    end
    return (self.x + x_offset) * self.state.level.cell_length_pixels,
           (self.y + y_offset) * self.state.level.cell_length_pixels
end


function SecurityCamera:draw()
    super().draw(self, self.state)

    local cell_size = self.state.level.cell_length_pixels
    for _, cell in pairs(self.vision) do
        love.graphics.setColor({1, 0, 0, 0.2})
        love.graphics.rectangle("fill", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
    end
    local sprite = self:get_sprite()
    love.graphics.setColor({1, 1, 1, 1})
    
    local cx, cy = self:centre()

    if sprite ~= nil then
        love.graphics.draw(sprite,
                           cx - sprite:getWidth() / 2,
                           cy - sprite:getHeight() / 2,
                           0, 1, 1)
    end

    if self.emote ~= nil then
        self.emote:draw(cx, cy - cell_size)
    end
end
