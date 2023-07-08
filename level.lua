Level = {
    img = nil,
    geom = nil,
    cells = nil,
    solid_cells = nil,
}
setup_class(Level)

function Level.new()

    local obj = magic_new()

    obj.img = assets:get_image("map3")
    obj.geom = assets:get_image_data("level-geom", "bmp")
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

    return obj
end

function Level:draw(state, inputs, dt)
    Level:draw_img(level)
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

