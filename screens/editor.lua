require "ui.layout_element"
require "ui.triple_button"
require "ui.containers.flow_box"
require "ui.containers.layout_box"
require "ui.containers.layout_frame"
require "ui.containers.dialog"
require "ui.event_sink"
require "ui.containers.scroll_frame"
require "ui.containers.multi_frame"
require "ui.text"
require "ui.text_box"
require "ui.void"
require "ui.binding"
require "ui.data_viewer"
require "screens.editor.tools"
require "screens.editor.save_dialog"
require "screens.editor.load_dialog"
require "screens.editor.entity_dialog"
require "screens.editor.tile_dialog"
require "screens.editor.entity_configs"

Editor = {
    save_dialog = nil,
    load_dialog = nil,
    state = nil,
    map = nil,
    entity_configs = nil,
    entity_config = nil,
    tools = nil,
    tool = nil,
    tool_drag_origin = nil,
    tile = nil,
    selected_cells = nil,
}

setup_class(Editor, LayoutBox)

function Editor:__init()
    super().__init(self)

    self.map = Map("assets/default")
    self._prev_tool = EditorTool.NONE
    self.tool = EditorTool.NONE
    self.tool_drag_origin = false
    self.color = first_pair(self.map.config.tile_mapping)
    self:refresh_state()

    self.tools = {}
    for _, tool_class in ipairs(EDITOR_ALL_TOOLS) do
        self.tools[tool_class.name] = tool_class(self)
    end

    self.entity_configs = {}
    for _, entity_config_class in ipairs(EDITOR_ENTITY_CONFIGS) do
        self.entity_configs[entity_config_class:name()] = entity_config_class(self)
    end
    _, self.entity_config = first_pair(self.entity_configs)

    self.width = canvas:width()
    self.height = canvas:height()

    self.save_dialog = EditorSaveDialog(self)
    self.load_dialog = EditorLoadDialog(self)
    self.entity_dialog = EditorEntityDialog(self)
    self.tile_dialog = EditorTileDialog(self)

    local tool_surface = LayoutElement()
    tool_surface.width = canvas:width()
    tool_surface.height = canvas:height()
    tool_surface.mousemoved = function(element, x, y, dx, dy)
        self:update_tool(self:transform_local_to_level(x, y, dx, dy))
        self:update_entity_config(self:transform_local_to_level(x, y, dx, dy))
    end
    tool_surface.mousepressed = function(element, x, y, button)
        if button == 1 then
            self:tool_press()
        end
    end
    tool_surface.mousereleased = function(element, x, y, button)
        if button == 1 and tool_surface:contains(x, y) then
            self:tool_release()
        end
    end

    local toolbar = LayoutBox()
    toolbar.width = 77
    toolbar.height = canvas:height()
    toolbar.background_color = {0, 0, 0, 0.6}
    toolbar.mousepressed = function() return true end
    toolbar.mousereleased = function() return true end

    local toolbar_items_top = FlowBox()
    toolbar_items_top.x = 6
    toolbar_items_top.y = 4
    toolbar_items_top.width = 67
    toolbar_items_top.max_width = toolbar_items_top.width
    toolbar_items_top.orientation = Orientation.RIGHT_DOWN
    toolbar_items_top.item_margin = 3
    toolbar_items_top.line_margin = 3

    local toolbar_items_bottom = FlowBox()
    toolbar_items_bottom.x = 6
    toolbar_items_bottom.y = canvas:height() - 4
    toolbar_items_bottom.y_align = "bottom"
    toolbar_items_bottom.width = 67
    toolbar_items_bottom.max_width = toolbar_items_bottom.width
    toolbar_items_bottom.orientation = Orientation.RIGHT_UP
    toolbar_items_bottom.item_margin = 3
    toolbar_items_bottom.line_margin = 3

    local spacer = LayoutElement()
    spacer.width = toolbar_items_top.width
    spacer.height = 2
    spacer.background_color = {1, 1, 1, 0.2}

    local picker_swapper = MultiFrame()
    picker_swapper.width = toolbar_items_top.width
    picker_swapper.height = 32
    picker_swapper.current = OneWayBinding(
        self, "tool",
        function(tool)
            if tool == nil then
                return nil
            end
            for _, tool_class in ipairs(EDITOR_ENTITY_TOOLS) do
                if tool_class.name == tool.name then
                    return "entity"
                end
            end
            for _, tool_class in ipairs(EDITOR_LEVEL_TOOLS) do
                if tool_class.name == tool.name then
                    return "tile"
                end
            end
            return nil
        end
    )

    local entity_picker = ImageButton()
    entity_picker.width = 32
    entity_picker.height = entity_picker.width
    entity_picker.x = picker_swapper.width / 2
    entity_picker.x_align = "center"
    entity_picker.background_color = hex2col("#afbfd2")
    entity_picker.border_thickness = 1
    entity_picker.border_color = {0, 0, 0, 0.5}
    entity_picker.image = OneWayBinding(
        self, "entity_config",
        function(entity_config)
            if entity_config == nil then
                return nil
            end
            return entity_config:sprite()
        end
    )
    entity_picker.mousereleased = function()
        self.entity_dialog:open()
    end

    local tile_picker = ImageButton()
    tile_picker.width = 32
    tile_picker.height = tile_picker.width
    tile_picker.x = picker_swapper.width / 2
    tile_picker.x_align = "center"
    tile_picker.background_color = hex2col("#afbfd2")
    tile_picker.border_thickness = 1
    tile_picker.border_color = {0, 0, 0, 0.5}
    tile_picker.image = OneWayBinding(
        self, "color",
        function(color)
            if color == nil then
                return nil
            end
            return assets:get_image(self.map.config.tile_mapping[color])
        end
    )
    tile_picker.mousereleased = function()
        self.tile_dialog:open()
    end

    local add_tool_button = function(tool_class)
        local tool = self.tools[tool_class.name]
        local button = TripleButton()
        button.width = 32
        button.height = 32
        button.default_image = assets:get_image("ui/Editor"..tool.name.."Release")
        button.hover_image = assets:get_image("ui/Editor"..tool.name.."Hover")
        button.click_image = assets:get_image("ui/Editor"..tool.name.."Press")
        button.override_state = OneWayBinding(
            self, "tool",
            function(x)
                if x == tool then
                    return TripleButtonState.CLICK
                end
                return nil
            end)
        button.mousereleased = function()
            self.tool = tool
        end

        toolbar_items_top:append(button)
    end

    for _, tool_class in ipairs(EDITOR_ENTITY_TOOLS) do
        add_tool_button(tool_class)
    end
    toolbar_items_top:append(spacer)

    for _, tool_class in ipairs(EDITOR_LEVEL_TOOLS) do
        add_tool_button(tool_class)
    end
    toolbar_items_top:append(spacer)
    picker_swapper:add("entity", entity_picker)
    picker_swapper:add("tile", tile_picker)
    toolbar_items_top:append(picker_swapper)
    toolbar_items_top:append(spacer)

    local save_button = TripleButton()
    save_button.width = 32
    save_button.height = 32
    save_button.default_image = assets:get_image("ui/EditorSaveRelease")
    save_button.hover_image = assets:get_image("ui/EditorSaveHover")
    save_button.click_image = assets:get_image("ui/EditorSavePress")
    save_button.mousereleased = function()
        self.save_dialog:refresh()
        self.save_dialog:open()
    end

    local load_button = TripleButton()
    load_button.width = 32
    load_button.height = 32
    load_button.default_image = assets:get_image("ui/EditorLoadRelease")
    load_button.hover_image = assets:get_image("ui/EditorLoadHover")
    load_button.click_image = assets:get_image("ui/EditorLoadPress")
    load_button.mousereleased = function()
        self.load_dialog:refresh()
        self.load_dialog:open()
    end

    local entity_data_viewer = DataViewer()
    entity_data_viewer.x = self.bb:width()
    entity_data_viewer.width = 200
    entity_data_viewer.row_height = 8
    entity_data_viewer.background_color = {0, 0, 0, 0.5}
    entity_data_viewer.text_color = {1, 1, 1, 1}
    entity_data_viewer.cell_margin = 4
    entity_data_viewer.x_align = "right"
    entity_data_viewer.font = assets:get_font("font")
    entity_data_viewer.schema = OneWayBinding(
        self, "entity_config",
        function(entity_config)
            return get_if_not_nil(entity_config, "schema")
        end
    )
    entity_data_viewer.data = OneWayBinding(
        self, "entity_config",
        function(entity_config)
            return get_if_not_nil(entity_config, "config")
        end
    )

    toolbar_items_bottom:append(save_button)
    toolbar_items_bottom:append(load_button)
    toolbar_items_bottom:append(spacer)

    toolbar:add(toolbar_items_top)
    toolbar:add(toolbar_items_bottom)

    self:add(tool_surface)
    self:add(toolbar)
    self:add(self.save_dialog)
    self:add(self.load_dialog)
    self:add(self.entity_dialog)
    self:add(self.tile_dialog)
    self:add(entity_data_viewer)
end

function Editor:set_color(value)
    if not MapSchemas.color:match(value) then
        self:_value_error("Value must be a hex code, or nil.")
    end
    self:_set_property("color", value)
end

function Editor:set_entity_config(value)
    if not is_type(value, EditorEntityConfig) then
        self:_value_error("Value must be an EditorEntityConfig, or nil.")
    end
    self:_set_property("entity_config", value)
end

function Editor:set_tool(value)
    if not is_type(value, EditorTool, "nil") then
        self:_value_error("Value must be an EditorTool, or nil.")
    end
    local prev_tool = self.tool
    if self:_set_property("tool", value) then
        self._prev_tool = prev_tool
        if self._prev_tool ~= nil then
            self._prev_tool:reset()
        end
    end
end

function Editor:refresh_level()
    self.state.level = Level(self.map)
end

function Editor:refresh_state()
    if self.state ~= nil then
        local old_camera = self.state:first("Camera")
        self.map.config.camera.position.x = old_camera.x
        self.map.config.camera.position.y = old_camera.y
    end

    self.state = GameState(self.map)
end

function Editor:update(dt)
    self:update_tool()
end

function Editor:update_entity_config(x, y, dx, dy)
    if self.entity_config ~= nil then
        self.entity_config:set_position(x, y)
    end
end

function Editor:update_tool(x, y, dx, dy)
    if x == nil then
        x, y = self:get_mouse_level_pos()
    end

    if self.tool == nil then
        self.selected_cells = HashSet(Cell(x, y))
        return
    end

    -- Default.
    x, y, dx, dy = self.tool:modify_inputs(x, y, nil_coalesce(dx, 0), nil_coalesce(dy, 0))

    self.selected_cells = self.tool:update(x, y, dx, dy)
end

function Editor:tool_press(x, y)
    if x == nil then
        x, y = self:get_mouse_level_pos()
    end
    if self.tool ~= nil then
        self.tool:press(x, y)
    end
end

function Editor:tool_release(x, y)
    if x == nil then
        x, y = self:get_mouse_level_pos()
    end
    if self.tool ~= nil then
        self.tool:release(x, y)
    end
end

function Editor:prev_tool()
    self.tool = self._prev_tool
end

function Editor:color_selected_cells()
    if not self.selected_cells then
        return
    end

    local color = hex2col(self.color)
    for cell, _ in pairs(self.selected_cells) do
        self.map.level_data:setPixel(cell.x, cell.y, unpack(color))
    end
    self.selected_cells = HashSet()
    self:refresh_level()
end

function Editor:get_mouse_cell(x, y)
    return Cell(self:get_mouse_level_pos())
end

function Editor:get_mouse_level_pos(x, y)
    x = x or self.mouse_pos[1]
    y = y or self.mouse_pos[2]
    return self:transform_local_to_level(x, y)
end

function Editor:transform_local_to_level(x, y, dx, dy)
    local cell_size = self.state.level.cell_length_pixels
    local world_x, world_y = x, y
    if dy == nil then
        return world_x / cell_size, world_y / cell_size
    end
    return world_x / cell_size, world_y / cell_size, dx / cell_size, dy / cell_size
end

function Editor:draw_tool()
    local cell_size = self.state.level.cell_length_pixels
    if self.selected_cells then
        love.graphics.setLineWidth(1)
        for cell, _ in pairs(self.selected_cells) do
            love.graphics.setColor({0.18, 0.2, 0.2, 1})
            love.graphics.setBlendMode("add", "alphamultiply")
            love.graphics.rectangle("fill", cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
            love.graphics.setBlendMode("alpha", "alphamultiply")
        end
    end
end

function Editor:draw()
    super().draw(self)


    local camera = self.state:first("Camera")
    love.graphics.push()

    if camera then
        camera:apply_transform()
    end

    self.state.level:draw()

    for _, entity in ipairs(self.state.entities) do
        entity:draw()
    end

    self:draw_tool()
    love.graphics.pop()
end
