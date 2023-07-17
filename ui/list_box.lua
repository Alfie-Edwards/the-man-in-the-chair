require "ui.simple_element"

ListBox = {
    items = nil,
    wrap = nil,
    flow_direction = nil,
    wrap_direction = nil,
    item_spacing = nil,
    line_spacing = nil,
    line_height = nil,
    item_changed_handler = nil,
    items_changed_handler = nil,
}
setup_class(ListBox, SimpleElement)

function ListBox.new()
    local obj = magic_new()

    obj.item_changed_handler = function(item, property_name, old_value, new_value)
        if property_name == "bb" then
            obj:update_layout()
        end
    end
    obj.items_changed_handler = function(items, i, old_value, new_value)
        if old_value ~= nil then
            old_value.property_changed:unsubscribe(obj.item_changed_handler)
        end
        if new_value ~= nil then
            new_value.property_changed:subscribe(obj.item_changed_handler)
        end
        obj:update_layout()
    end

    obj.cells = {}
    obj.items = Watchable.new()

    return obj
end

function ListBox:set_items(value)
    if not (value == nil or value.property_changed ~= nil) then
        self:_value_error("Value must implement a property_changed event (dst, property_name, old_value, new_value), or be nil.")
    end
    local prev_value = self.items
    if self:_set_property("items", value) then
        if prev_value ~= nil then
            prev_value.property_changed:unsubscribe(self.items_changed_handler)
        end
        if value ~= nil then
            value.property_changed:subscribe(self.items_changed_handler)
        end
        self:update_layout()
    end
end

function ListBox:set_wrap(value)
    if not is_type(value, "boolean", "nil") then
        self:_value_error("Value must be a boolean, or nil.")
    end
    if self:_set_property("wrap", value) then
        self:update_layout()
    end
end

function ListBox:set_item_spacing(value)
    if not is_type(value, "number", "nil") then
        self:_value_error("Value must be a number, or nil.")
    end
    if self:_set_property("item_spacing", value) then
        self:update_layout()
    end
end

function ListBox:set_line_spacing(value)
    if not is_type(value, "number", "nil") then
        self:_value_error("Value must be a number, or nil.")
    end
    if self:_set_property("line_spacing", value) then
        self:update_layout()
    end
end

function ListBox:set_line_height(value)
    if not is_type(value, "number", "nil") then
        self:_value_error("Value must be a number, or nil.")
    end
    if self:_set_property("line_height", value) then
        self:update_layout()
    end
end

function ListBox:set_flow_direction(value)
    if not (value == nil or Direction:is(value)) then
        self:_value_error("Value must be a direction "..tostring(Direction)..", or nil")
    end
    if self.wrap_direction then
        if direction_axis(self.wrap_direction) == direction_axis(value) then
            error("Flow direction ("..value..") and wrap direction ("..self.wrap_direction..") cannot be along the same axis ("..direction_axis(value)..").")
        end
    end
    if self:_set_property("flow_direction", value) then
        self:update_layout()
    end
end

function ListBox:set_wrap_direction(value)
    if not (value == nil or Direction:is(value)) then
        self:_value_error("Value must be a direction "..tostring(Direction)..", or nil")
    end
    if self.flow_direction then
        if direction_axis(self.flow_direction) == direction_axis(value) then
            error("Flow direction ("..self.flow_direction..") and wrap direction ("..value..") cannot be along the same axis ("..direction_axis(value)..").")
        end
    end
    if self:_set_property("wrap_direction", value) then
        self:update_layout()
    end
end

function ListBox:update_layout()
    super().update_layout(self)

    self:clear_children()

    if self.items == nil or self.flow_direction == nil or self.wrap_direction == nil then
        return
    end

    local wrap_size = self.bb:width()
    if direction_axis(self.flow_direction) == Axis.Y then
        wrap_size = self.bb:height()
    end
    local item_spacing = self.item_spacing or 0
    local line_spacing = self.line_spacing or 0

    local line_length = 0
    local auto_line_height = 0
    local wrap_offset = 0

    local i = 1
    while self.items[i] do
        local item = self.items[i]
        i = i + 1

        local length, height
        if direction_axis(self.flow_direction) == Axis.X then
            length = item.bb:width()
            height = item.bb:height()
        else
            length = item.bb:height()
            height = item.bb:width()
        end

        if line_length ~= 0 then
            if self.wrap and (line_length + item_spacing + line_length) > wrap_size then
                -- Wrap to the next line.
                wrap_offset = wrap_offset + (self.line_height or auto_line_height) + line_spacing
                line_length = 0
                auto_line_height = 0
            else
                -- Add item spacing.
                line_length = line_length + item_spacing
            end
        end
        if self.line_height == nil then
            auto_line_height = math.max(auto_line_height, height)
        end
        local x1, y1, x2, y2
        if self.flow_direction == Direction.RIGHT then
            x1 = line_length
            x2 = line_length + length
        elseif self.flow_direction == Direction.DOWN then
            y1 = line_length
            y2 = line_length + length
        elseif self.flow_direction == Direction.LEFT then
            x1 = self.bb:width() - line_length - length
            x2 = self.bb:width() - line_length
        elseif self.flow_direction == Direction.UP then
            y1 = self.bb:height() - line_length - length
            y2 = self.bb:height() - line_length
        end
        if self.wrap_direction == Direction.RIGHT then
            x1 = wrap_offset
            x2 = wrap_offset + height
        elseif self.wrap_direction == Direction.DOWN then
            y1 = wrap_offset
            y2 = wrap_offset + height
        elseif self.wrap_direction == Direction.LEFT then
            x1 = self.bb:width() - wrap_offset - height
            x2 = self.bb:width() - wrap_offset
        elseif self.wrap_direction == Direction.UP then
            y1 = self.bb:height() - wrap_offset - height
            y2 = self.bb:height() - wrap_offset
        end

        line_length = line_length + length

        local cell = Element.new()
        cell.bb = BoundingBox.new(x1, y1, x2, y2)
        cell:add_child(item)
        self:add_child(cell)
    end
end
