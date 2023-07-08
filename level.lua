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

function Level:update(dt)
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

    movement:scale_to_length(self.camera_pan_speed * dt)

    self.camera.x = clamp(self.camera.x + movement.x2, 0, self:width_pixels() - canvas:width())
    self.camera.y = clamp(self.camera.y + movement.y2, 0, self:height_pixels() - canvas:height())
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

function Level:cell_size()
    return canvas:width() / self.geom:getWidth()
end

function Level:position_in_cell(x, y)
    local cs = self:cell_size()
    return x % cs, y % cs
end

function Level:out_of_bounds(x, y)
    return x < 0 or x > canvas:width() or
           y < 0 or y > canvas:height()
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
