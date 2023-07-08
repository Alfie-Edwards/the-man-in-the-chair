require "utils.vector"


Level = {
    img = nil,
    geom = nil,
    cell_length_pixels = 16,
    cells = nil,
    solid_cells = nil,

    camera = { x = 0, y = 0 },
    camera_pan_speed = 450,
}
setup_class(Level)

function Level.new()

    local obj = magic_new()

    obj.img = assets:get_image("map3")
    obj.geom = assets:get_image_data("big-level-geom", "bmp")

    obj.cells = HashSet.new()
    obj.solid_cells = HashSet.new()

    for y=0,obj.geom:getHeight() - 1 do
        for x=0,obj.geom:getWidth() - 1 do
            obj.cells:add(Cell.new(x, y))

            if obj.geom:getPixel(x, y) == 0 then
                obj.solid_cells:add(Cell.new(x, y))
            end
        end
    end

    -- geom as an image, to draw for debugging
    obj.geom_img = love.graphics.newImage(obj.geom)
    obj.geom_img:setFilter("nearest")

    return obj
end

function Level:width_pixels()
    return self:width() * self.cell_length_pixels
end

function Level:height_pixels()
    return self:height() * self.cell_length_pixels
end

function Level:draw()
    love.graphics.push()
    love.graphics.translate(-self.camera.x, -self.camera.y)

    self:draw_geom()

    love.graphics.pop()
end

function Level:draw_geom(opacity)
    if opacity == nil then
        opacity = 1
    end

    local scale_x = (self.cell_length_pixels * canvas:width()) / self.img:getWidth()
    local scale_y = (self.cell_length_pixels * canvas:height()) / self.img:getHeight()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.geom_img, 0, 0, 0, scale_x, scale_y)
end

function Level:draw_img()
    local scale_x = canvas:width() / self.img:getWidth()
    local scale_y = canvas:height() / self.img:getHeight()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, 0, 0, 0, scale_x, scale_y)
end

function Level:cell_x(x)
    local scale_x = self.geom:getWidth() / canvas:width()
    return math.floor(x * scale_x)
end

function Level:cell_y(y)
    local scale_y = self.geom:getHeight() / canvas:height()
    return math.floor(y * scale_y)
end

function Level:width()
    return self.geom:getWidth()
end

function Level:height()
    return self.geom:getHeight()
end

function Level:cell(x, y)
    return self:cell_x(x), self:cell_y(y)
end

function Level:position_in_cell(x, y)
    return x % cell_length_pixels, y % cell_length_pixels
end

function Level:out_of_bounds(x, y)
    return cell_out_of_bounds(
        math.floor(x / cell_length_pixels),
        math.floor(y / cell_length_pixels)
    )
end

function Level:cell_out_of_bounds(x, y)
    return x < 0 or x >= self:width() or
           y < 0 or y >= self:height()
end

function Level:cell_solid(x, y)
    return self.solid_cells[Cell.new(x, y)]
end

function Level:solid(pos)
    if self:out_of_bounds(pos.x, pos.y) then
        return true
    end

    local cell_x, cell_y = self:cell(pos.x, pos.y)

    return Level:cell_solid(cell_x, cell_y)
end

Cell = {
    x = nil,
    y = nil,
}
setup_class(Cell)

function Cell.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y

    return obj
end

function Cell:__eq(other)
    if not is_type(rhs, Cell) then
        return false
    end
    return self:__hash() == other:__hash()
end

function Cell:__hash()
    return tostring(self.x)..","..tostring(self.y)
end

function raycast(level, x, y, angle, fov, max_distance)
    local result = HashSet.new()

    -- Adjust from world-space into level-space
    x = x / level.cell_length_pixels
    y = y / level.cell_length_pixels
    max_distance = max_distance / level.cell_length_pixels

    local angle_start = angle - fov / 2
    local angle_end = angle - fov / 2
    local arc_length = max_distance * fov
    local rays = math.max(2, math.ceil(arc_length))
    local d_angle = 0
    local inc = max_distance / math.ceil(max_distance)
    for i=1,rays do
        local ray_x = x
        local ray_y = y
        local ray_angle = angle_start + ((i - 1) * fov) / (rays - 1)
        local dx = math.cos(ray_angle)
        local dy = math.sin(ray_angle)
        for distance = 0, max_distance, inc do
            local cell_x = math.floor(x + dx * distance)
            local cell_y = math.floor(y + dy * distance)
            if level:cell_out_of_bounds(cell_x, cell_y) or level:cell_solid(cell_x, cell_y) then
                break
            end
            result:add(Cell.new(cell_x, cell_y))
        end
    end

    return result
end
