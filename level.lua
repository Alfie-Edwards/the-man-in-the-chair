require "utils.vector"


Level = {
    geom = nil,
    cell_length_pixels = 16,
    cells = nil,
    solid_cells = nil,
    solid_door_cells = nil,

    tile_resources = nil,
    solid_tile_types = nil,

    camera = { x = 0, y = 0 },
    camera_pan_speed = 450,
}
setup_class(Level)

function Level.from_file(filename)

    local f = love.filesystem.lines(filename)

    if not f then
        error("couldn't open file "..filename.."!")
    end

    local geom_img_file = nil
    local tile_resources = {}
    local solid_tile_types = {}

    local stages = { GEOM_IMG = 1, TILE_MAPPING = 2, SOLID_TILES = 3 }
    local stage = stages.GEOM_IMG

    for line in f do
        if line == "" then
            stage = stage + 1
        elseif stage == stages.GEOM_IMG then
            geom_img_file = line
        elseif stage == stages.TILE_MAPPING then
            local name, col_hex = string.match(line, "(.*): (.*)")

            tile_resources[name] = {
                colour_code = hex2rgb(col_hex),
                image = assets:get_image(name),
            }
        elseif stage == stages.SOLID_TILES then
            local found = false
            for tile_type,_ in pairs(tile_resources) do
                if tile_type == line then
                    found = true
                    break
                end
            end
            if not found then
                error("tried to make unknown tile type "..line.." a solid tile type")
            end

            table.insert(solid_tile_types, line)
        else
            error("too many empty lines in file!")
        end
    end

    assert(geom_img_file ~= nil)

    return Level.new(geom_img_file, tile_resources, solid_tile_types)
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

function Level.new(geom_img_file, tile_resources, solid_tile_types)

    -- debug defaults
    if geom_img_file == nil then
        geom_img_file = "big-level-geom"
    end
    if tile_resources == nil then
        tile_resources = {
            floor = {
                colour_code = {1, 1, 1},
                image = assets:get_image("floor"),
            },
            wall = {
                colour_code = {0, 0, 0},
                image = assets:get_image("wall"),
            },
        }
    end
    if solid_tile_types == nil then
        solid_tile_types = { "wall" }
    end

    local obj = magic_new()

    obj.geom = assets:get_image_data(geom_img_file, "png")

    obj.cells = HashSet.new()
    obj.solid_cells = HashSet.new()
    obj.solid_door_cells = HashSet.new()

    obj.tile_resources = tile_resources
    obj.solid_tile_types = solid_tile_types

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

function Level:width_pixels()
    return self:width() * self.cell_length_pixels
end

function Level:height_pixels()
    return self:height() * self.cell_length_pixels
end

function Level:draw()
    love.graphics.push()
    love.graphics.translate(-self.camera.x, -self.camera.y)

    self:draw_tiles()

    love.graphics.pop()
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

function Level:set_door_cell_solid(x, y, is_solid)
    if is_solid then
        self.solid_door_cells:add(Cell.new(x, y))
    else
        self.solid_door_cells:remove(Cell.new(x, y))
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
