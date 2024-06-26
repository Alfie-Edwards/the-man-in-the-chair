require "ui.simple_element"
require "ui.image"

TripleButtonState = Enum.new("DEFAULT", "HOVER", "CLICK")

TripleButton = {
    default_image = nil,
    hover_image = nil,
    click_image = nil,

    active_image_elem = nil,
}

setup_class(TripleButton, SimpleElement)

function TripleButton.new()
    local obj = magic_new()

    obj.active_image_elem = Image.new()
    obj:add_child(obj.active_image_elem)

    return obj
end

function TripleButton:set_default_image(value)
    if not is_type(value, "Texture", "nil") then
        self:_value_error("Value must be a love.graphics.Texture, a love.graphics.Image, or nil.")
    end
    if self:_set_property("default_image", value) then
        self:update_layout()
    end
end

function TripleButton:set_hover_image(value)
    if not is_type(value, "Texture", "nil") then
        self:_value_error("Value must be a love.graphics.Texture, a love.graphics.Image, or nil.")
    end
    if self:_set_property("hover_image", value) then
        self:update_layout()
    end
end

function TripleButton:set_click_image(value)
    if not is_type(value, "Texture", "nil") then
        self:_value_error("Value must be a love.graphics.Texture, a love.graphics.Image, or nil.")
    end
    if self:_set_property("click_image", value) then
        self:update_layout()
    end
end

function TripleButton:set_override_state(value)
    if not (value == nil or TripleButtonState:is(value)) then
        self:_value_error("Value must be a one of "..tostring(TripleButtonState)..", or nil")
    end
    if self:_set_property("override_state", value) then
        self:update_layout()
    end
end

function TripleButton:draw()
    super().draw(self)
end

function TripleButton:toggle()
    local temp = self.default_image
    self.default_image = self.click_image
    self.click_image = temp
end

function TripleButton:update(dt)
    local mouse_x, mouse_y = self:get_mouse_pos()

    local active_image = self.default_image
    if self.override_state ~= nil then
        if self.override_state == TripleButtonState.HOVER then
            active_image = self.hover_image
        elseif self.override_state == TripleButtonState.CLICK then
            active_image = self.click_image
        end
    else
        if self:contains(mouse_x, mouse_y) then
            if love.mouse.isDown(1) then
                active_image = self.click_image
            else
                active_image = self.hover_image
            end
        end
    end

    self.active_image_elem:set_properties({
        image = active_image,
        width = self.width,
        height = self.height,
    })
end
