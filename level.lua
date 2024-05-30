Level = {
    geom = nil,
    cell_length_pixels = 16,
    cells = nil,
    solid_cells = nil,
    solid_door_cells = nil,
    door_cells = nil,

    tile_resources = nil,
    solid_tile_types = nil,
    camera_pan_speed = 450,
}
setup_class(Level)

function Level:__init(map)
    super().__init(self)

    self.geom = map.level_data

    self.cells = HashSet()
    self.solid_cells = HashSet()
    self.solid_door_cells = HashSet()
    self.locked_door_cells = HashSet()

    self.tile_resources = {}
    for col_hex, name in pairs(map.config.tile_mapping) do
        self.tile_resources[name] = {
            colour_code = hex2rgb(col_hex),
            image = assets:get_image(name),
        }
    end

    self.solid_tile_types = map.config.solid_tile_types
    for _, tile_type in ipairs(self.solid_tile_types) do
        if self.tile_resources[tile_type] == nil then
            error("Unknown tile type listed as solid: \""..tile_type.."\".")
        end
    end

    for y=0,self.geom:getHeight() - 1 do
        for x=0,self.geom:getWidth() - 1 do
            self.cells:add(Cell(x, y))

            local tile_type = self:type_from_colour(self:colour_at_pixel(x, y))
            assert(tile_type ~= nil)
            if self:is_solid(tile_type) then
                self.solid_cells:add(Cell(x, y))
            end
        end
    end

    -- geom as an image, to draw for debugging
    self.geom_img = love.graphics.newImage(self.geom)
    self.geom_img:setFilter("nearest")
end

function Level:type_from_colour(r, g, b)
    local colour = {r, g, b}
    for tile_type, tile in pairs(self.tile_resources) do
        if lists_equal(tile.colour_code, colour) then
            return tile_type
        end
    end

    return nil
end

function Level:is_solid(tile_type)
    return value_in(tile_type, self.solid_tile_types)
end

function Level:width_pixels()
    return self:width() * self.cell_length_pixels
end

function Level:height_pixels()
    return self:height() * self.cell_length_pixels
end

function Level:draw()
    self:draw_tiles()
end

function Level:draw_geom(opacity)
    if opacity == nil then
        opacity = 1
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.geom_img, 0, 0, 0,
                       self.cell_length_pixels, self.cell_length_pixels)
end

function Level:colour_at_pixel(x, y)
    local r, g, b = self.geom:getPixel(x, y)

    return math.floor(r * 255),
           math.floor(g * 255),
           math.floor(b * 255)
end

function Level:draw_tiles()
    love.graphics.setColor(1, 1, 1, 1)
    for x=0,self:width() - 1 do
        for y=0,self:height() - 1 do
            local tile_type = self:type_from_colour(self:colour_at_pixel(x, y))
            assert(tile_type ~= nil)

            love.graphics.draw(self.tile_resources[tile_type].image,
                               x * self.cell_length_pixels,
                               y * self.cell_length_pixels,
                               0, 1, 1)
        end
    end
end

function Level:draw_gridlines()
    love.graphics.setColor({1, 0, 0, 1})
    for col=0,self:width() do
        love.graphics.line(col * self.cell_length_pixels, 0,
                           col * self.cell_length_pixels, self:height_pixels())
    end
    for row=0,self:height() do
        love.graphics.line(0, row * self.cell_length_pixels,
                           self:width_pixels(), row * self.cell_length_pixels)
    end
end

function Level:width()
    return self.geom:getWidth()
end

function Level:height()
    return self.geom:getHeight()
end

function Level:cell(x, y)
    if y == nil then
        return math.floor(x / self.cell_length_pixels)
    end
    return math.floor(x / self.cell_length_pixels),
           math.floor(y / self.cell_length_pixels)
end

function Level:position_in_cell(x, y)
    return x % self.cell_length_pixels, y % self.cell_length_pixels
end

function Level:out_of_bounds(x, y)
    return cell_out_of_bounds(self:cell(x, y))
end

function Level:cell_out_of_bounds(x, y)
    return x < 0 or x >= self:width() or
           y < 0 or y >= self:height()
end

function Level:set_door_cell_solid(cell, door)
    if door:is_solid() then
        self.solid_door_cells:add(cell)
    else
        self.solid_door_cells:remove(cell)
    end
    if not door.is_locked then
        self.locked_door_cells:remove(cell)
    else
        self.locked_door_cells:add(cell)
    end
end

function Level:cell_solid(x, y, doors_are_solid)
    if doors_are_solid == nil then
        doors_are_solid = true
    end
    local cell = Cell(x, y)
    if doors_are_solid and self.solid_door_cells[cell] then
        return true
    end
    return self.solid_cells[cell]
end

function Level:solid(pos)
    if self:out_of_bounds(pos.x, pos.y) then
        return true
    end

    local cell_x, cell_y = self:cell(pos.x, pos.y)

    return Level:cell_solid(cell_x, cell_y)
end
