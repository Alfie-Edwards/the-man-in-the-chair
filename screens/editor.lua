require "ui.simple_element"
require "ui.triple_button"
require "ui.list_box"

EditorTool = Enum.new("NONE", "PENCIL", "FILL", "LINE", "RECT", "CIRCLE")

Editor = {
    preview_state = nil,
    map = nil,
    tool = nil,
    tool_active = nil,
    tile = nil,
}

setup_class(Editor, SimpleElement)

function Editor.new()
    local obj = magic_new()

    obj.map = Map.new("assets/default")
    obj.camera = Camera.new(0, 0)
    obj.tool = EditorTool.NONE
    obj.tool_active = false
    obj.color = "#D104B2"
    obj:refresh_preview_state()

    obj:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    local tool_surface = SimpleElement.new()
    tool_surface:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
            mousemoved = function(element, x, y, dx, dy)
                obj:do_tool(x, y, dx, dy)
            end,
        }
    )
    obj:add_child(tool_surface)

    local toolbar = SimpleElement.new()
    toolbar:set_properties(
        {
            width = 42,
            height = canvas:height(),
            background_color = {0, 0, 0, 0.6}
        }
    )
    obj:add_child(toolbar)

    local toolbar_items = ListBox.new()
    toolbar_items:set_properties(
        {
            x = 6,
            y = 4,
            width = 32,
            flow_direction = Direction.DOWN,
            wrap_direction = Direction.RIGHT,
            line_height = 32,
            item_spacing = 2,
        }
    )
    toolbar:add_child(toolbar_items)

    local pencil_button = TripleButton.new()
    pencil_button:set_properties(
        {
            width = 32,
            height = 32,
            default_image = assets:get_image("ui/EditorPencilRelease"),
            hover_image = assets:get_image("ui/EditorPencilHover"),
            click_image = assets:get_image("ui/EditorPencilPress"),
            click = function() 
                if obj.tool == EditorTool.PENCIL then
                    obj.tool = EditorTool.NONE
                    pencil_button.override_state = nil
                else
                    obj.tool = EditorTool.PENCIL
                    pencil_button.override_state = TripleButtonState.CLICK
                end
            end,
        }
    )
    toolbar_items.items[1] = pencil_button

    return obj  
end

function Editor:refresh_preview_state()
    self.preview_state = GameState.new(self.map)
    self.camera:init(self.preview_state)
end

function Editor:update(dt)

    if self.tool_active then
        if not love.mouse.isDown(1) then
            self:tool_end(unpack(self.mouse_pos))
        end
    else
        if love.mouse.isDown(1) then
            self:tool_begin(unpack(self.mouse_pos))
        end
    end

    self:refresh_preview_state()
    self.camera:update(dt)
end

function Editor:do_tool(x, y, dx, dy)
    if not (self.tool_active and love.mouse.isDown(1)) then
        return
    end
    local cell_size = self.preview_state.level.cell_length_pixels
    if self.tool == EditorTool.PENCIL then
        local color = hex2rgb(self.color)
        local cells = line_super_cover(
            (x - dx) / cell_size,
            (y - dy) / cell_size,
            x / cell_size,
            y / cell_size
        )
        for cell, _ in pairs(cells) do
            self.map.level_data:setPixel(cell.x, cell.y, color[1] / 255, color[2] / 255, color[3] / 255, 1)
        end
    end
end

function Editor:tool_begin(x, y)
    self.tool_active = true
end

function Editor:tool_end(x, y)
    self.tool_active = false
end

function Editor:get_mouse_cell(x, y)
    x = x or self.mouse_pos[1]
    y = y or self.mouse_pos[2]
    local cell_size = self.preview_state.level.cell_length_pixels
    local world_x, world_y = x + self.camera.x, y + self.camera.y
    return Cell.new(math.floor(world_x / cell_size), math.floor(world_y / cell_size))
end

function Editor:draw_tool()
    local cell_size = self.preview_state.level.cell_length_pixels
    if self.tool == EditorTool.PENCIL then
        local cell = self:get_mouse_cell()
        love.graphics.setLineWidth(2)
        love.graphics.setColor({1, 1, 1, 0.4})
        love.graphics.rectangle("line", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
    end
end

function Editor:draw()
    super().draw(self)


    love.graphics.push()
    self.camera:apply_transform()

    self.preview_state.level:draw()

    for _, entity in ipairs(self.preview_state.entities) do
        entity:draw()
    end

    self:draw_tool()
    love.graphics.pop()
end
