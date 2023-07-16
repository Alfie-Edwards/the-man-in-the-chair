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

function Level.new(map)
    local obj = magic_new()

    obj.geom = map.level_data

    obj.cells = HashSet.new()
    obj.solid_cells = HashSet.new()
    obj.solid_door_cells = HashSet.new()
    obj.locked_door_cells = HashSet.new()

    obj.tile_resources = {}
    for col_hex, name in pairs(map.config.tile_mapping) do
        obj.tile_resources[name] = {
            colour_code = hex2rgb(col_hex),
            image = assets:get_image(name),
        }
    end

    obj.solid_tile_types = map.config.solid_tile_types
    for _, tile_type in ipairs(obj.solid_tile_types) do
        if obj.tile_resources[tile_type] == nil then
            error("Unknown tile type listed as solid: \""..tile_type.."\".")
        end
    end

    for y=0,obj.geom:getHeight() - 1 do
        for x=0,obj.geom:getWidth() - 1 do
            obj.cells:add(Cell.new(x, y))

            local tile_type = obj:type_from_colour(obj:colour_at_pixel(x, y))
            assert(tile_type ~= nil)
            if obj:is_solid(tile_type) then
                obj.solid_cells:add(Cell.new(x, y))
            end
        end
    end

    -- geom as an image, to draw for debugging
    obj.geom_img = love.graphics.newImage(obj.geom)
    obj.geom_img:setFilter("nearest")

    return obj
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
    local cell = Cell.new(x, y)
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
    if not is_type(other, Cell) then
        return false
    end
    return self:__hash() == other:__hash()
end

function Cell:__tostring()
    return "Cell("..tostring(self.x)..", "..tostring(self.y)..")"
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

    local start_cell = Cell.new(math.floor(x), math.floor(y))
    local angle_start = angle - fov / 2
    local angle_end = angle - fov / 2
    local arc_length = max_distance * fov
    local rays = math.max(2, math.ceil(arc_length * 2))
    local d_angle = 0
    local inc = max_distance / math.ceil(max_distance)
    for i=1,rays do
        local ray_x = x
        local ray_y = y
        local ray_angle = angle_start + ((i - 1) * fov) / (rays - 1)
        local dx = math.cos(ray_angle)
        local dy = math.sin(ray_angle)
        for distance = 0, max_distance, inc do
            local cell = Cell.new(math.floor(x + dx * distance), math.floor(y + dy * distance))
            if (level:cell_out_of_bounds(cell.x, cell.y) or level:cell_solid(cell.x, cell.y)) then
                if cell ~= start_cell then
                    break
                end
            else
                result:add(cell)
            end
        end
    end


    return result
end
