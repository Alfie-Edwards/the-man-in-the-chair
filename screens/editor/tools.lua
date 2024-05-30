EditorTool = {
    name = nil,
    editor = nil,
}
setup_class(EditorTool)

function EditorTool:__init(editor)
    self.editor = editor
end

function EditorTool:modify_inputs(x, y)
    return x, y
end

function EditorTool:press(x, y)
end

function EditorTool:release(x, y)
end

function EditorTool:update(x, y, dx, dy)
    return HashSet(Cell(x, y))
end

function EditorTool:reset()
end

DragReleaseTool = {
    drag_origin = nil,
    released_last_update = nil,
}
setup_class(DragReleaseTool, EditorTool)

function DragReleaseTool:modify_inputs(x, y, dx, dy)
    if self.drag_origin and love.keyboard.isDown("lshift", "rshift") then
        -- Snap to axes when shift is held.
        local x_dist = math.abs(x - self.drag_origin.x)
        local y_dist = math.abs(y - self.drag_origin.y)
        if y_dist > x_dist then
            x = self.drag_origin.x
            dx = 0
        else
            y = self.drag_origin.y
            dy = 0
        end
    end
    return x, y, dx, dy
end

function DragReleaseTool:press(x, y)
    self.drag_origin = {x = x, y = y}
end

function DragReleaseTool:update(x, y, dx, dy)
    if not love.mouse.isDown(1) then
        if self.released_last_update then
            self.drag_origin = nil
            released_last_update = false
        else
            self.released_last_update = true
        end
    else
        self.released_last_update = false
    end
    return super().update(self, x, y, dx, dy)
end

function DragReleaseTool:release(x, y)
    self.editor:color_selected_cells()
    self.drag_origin = nil
end

function DragReleaseTool:reset()
    self.drag_origin = nil
    self.released_last_update = nil
end

-------------------------------------------------------------------------------
-- MOUSE
-------------------------------------------------------------------------------

MouseTool = {
    name = "Mouse",
}
setup_class(MouseTool, EditorTool)

-------------------------------------------------------------------------------
-- PENCIL
-------------------------------------------------------------------------------

PencilTool = {
    name = "Pencil",
}
setup_class(PencilTool, DragReleaseTool)

function PencilTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)
    if self.drag_origin ~= nil then
        self.editor.selected_cells = line_super_cover(x - dx, y - dy, x, y)
        self.editor:color_selected_cells()
    end
    return default
end

function PencilTool:release(x, y)
    self.drag_origin = nil
end

-------------------------------------------------------------------------------
-- PICKER
-------------------------------------------------------------------------------

PickerTool = {
    name = "Picker",
}
setup_class(PickerTool, EditorTool)

function PickerTool:press(x, y)
    self.editor.color = col2hex({self.editor.map.level_data:getPixel(x, y)})
    self.editor:prev_tool()
end

-------------------------------------------------------------------------------
-- FILL
-------------------------------------------------------------------------------

FillTool = {
    name = "Fill",
}
setup_class(FillTool, EditorTool)

function FillTool:press(x, y)
    self.editor:color_selected_cells()
end

function FillTool:update(x, y, dx, dy)
    super().update(self, x, y, dx, dy)

    local click_color = {self.editor.map.level_data:getPixel(x, y)}
    local selected_cells = self.editor.selected_cells
    if selected_cells == nil or not selected_cells[Cell(x, y)] then
        selected_cells = floodfill(x, y, self.editor.state.level.cells,
            function(cell)
                return lists_equal({self.editor.map.level_data:getPixel(cell.x, cell.y)}, click_color)
            end
        )
    end
    return selected_cells
end

-------------------------------------------------------------------------------
-- LINE
-------------------------------------------------------------------------------

LineTool = {
    name = "Line",
}
setup_class(LineTool, DragReleaseTool)

function LineTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)

    if self.drag_origin then
        return line_super_cover(self.drag_origin.x, self.drag_origin.y, x, y)
    end
    return default
end

-------------------------------------------------------------------------------
-- RECT
-------------------------------------------------------------------------------

RectTool = {
    name = "Rect",
}
setup_class(RectTool, DragReleaseTool)

function RectTool:modify_inputs(x, y, dx, dy)
    if self.drag_origin and love.keyboard.isDown("lshift", "rshift") then
        -- Snap to square when shift is held.
        local x_dist = math.abs(math.floor(x) - math.floor(self.drag_origin.x))
        local y_dist = math.abs(math.floor(y) - math.floor(self.drag_origin.y))
        if y_dist > x_dist then
            x = self.drag_origin.x + (x - self.drag_origin.x) * (y_dist / math.abs(x - self.drag_origin.x))
        else
            y = self.drag_origin.y + (y - self.drag_origin.y) * (x_dist / math.abs(y - self.drag_origin.y))
        end
    end
    return x, y, dx, dy
end

function RectTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)
    if self.drag_origin then
            local x1 = math.floor(math.min(x, self.drag_origin.x))
            local y1 = math.floor(math.min(y, self.drag_origin.y))
            local x2 = math.floor(math.max(x, self.drag_origin.x))
            local y2 = math.floor(math.max(y, self.drag_origin.y))

            return cell_rect(x1, y1, x2, y2) * self.editor.state.level.cells
    end
    return default
end

-------------------------------------------------------------------------------
-- CIRCLE
-------------------------------------------------------------------------------

CircleTool = {
    name = "Circle",
}
setup_class(CircleTool, DragReleaseTool)

function CircleTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)
    if self.drag_origin then
        c_x = math.floor(self.drag_origin.x) + 0.5
        c_y = math.floor(self.drag_origin.y) + 0.5
        c_r = dist(x, y, c_x, c_y)
        return cell_circle(c_x, c_y, c_r) * self.editor.state.level.cells
    end
    return default
end

-------------------------------------------------------------------------------
-- RECT LINE
-------------------------------------------------------------------------------

RectLineTool = {
    name = "RectLine",
}
setup_class(RectLineTool, RectTool)

function RectLineTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)
    if self.drag_origin then
        return (
                line_super_cover(self.drag_origin.x, self.drag_origin.y , x, self.drag_origin.y) +
                line_super_cover(x, self.drag_origin.y , x, y) +
                line_super_cover(x, y, self.drag_origin.x, y) +
                line_super_cover(self.drag_origin.x, y, self.drag_origin.x, self.drag_origin.y)
            ) * self.editor.state.level.cells

    end
    return default
end

-------------------------------------------------------------------------------
-- CIRCLE LINE
-------------------------------------------------------------------------------

CircleLineTool = {
    name = "CircleLine",
}
setup_class(CircleLineTool, DragReleaseTool)

function CircleLineTool:update(x, y, dx, dy)
    local default = super().update(self, x, y, dx, dy)
    if self.drag_origin then
        c_x = math.floor(self.drag_origin.x) + 0.5
        c_y = math.floor(self.drag_origin.y) + 0.5
        c_r = dist(x, y, c_x, c_y)
        c_r_inner = math.max(0, c_r - 1)
        return (cell_circle(c_x, c_y, c_r) - cell_circle(c_x, c_y, c_r_inner)) * self.editor.state.level.cells
    end
    return default
end

-------------------------------------------------------------------------------
-- Entity
-------------------------------------------------------------------------------

EntityTool = {
    name = "Entity",
}
setup_class(EntityTool, EditorTool)

function EntityTool:update(x, y, dx, dy)
    if self.editor.entity_config ~= nil then
        self.editor.entity_config:set_position(math.floor(x), math.floor(y))
    end
    return super().update(self, x, y, dx, dy)
end

function EntityTool:press()
    if self.editor.entity_config ~= nil then
        self.editor.entity_config:add_to_map()
        self.editor.entity_config:add_to_state()
    end
end

-------------------------------------------------------------------------------
-- TOOL REGISTRATION
-------------------------------------------------------------------------------

EDITOR_ENTITY_TOOLS = {
    MouseTool,
    EntityTool,
}

EDITOR_LEVEL_TOOLS = {
    PencilTool,
    PickerTool,
    FillTool,
    LineTool,
    RectTool,
    RectLineTool,
    CircleTool,
    CircleLineTool,
}

EDITOR_ALL_TOOLS = list_concat(EDITOR_ENTITY_TOOLS, EDITOR_LEVEL_TOOLS)
