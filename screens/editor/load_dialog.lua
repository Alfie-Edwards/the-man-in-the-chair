require "ui.containers.dialog"
require "ui.containers.flow_box"
require "ui.containers.scroll_frame"
require "ui.triple_button"

EditorLoadDialog = {
    maps = nil,
    maps_scroller = nil,
}
setup_class(EditorLoadDialog, Dialog)

function EditorLoadDialog:__init(editor)
    super().__init(self)

    local margin = 4

    self.tint = {0.1, 0.1, 0.1, 0.6}

    local content = FlowBox()
    content.x = canvas:width() / 2
    content.y = canvas:height() / 2
    content.x_align = "center"
    content.y_align = "center"
    content.orientation = Orientation.DOWN_RIGHT
    content.width = 256
    content.background_color = {0, 0, 0, 0.6}

    self.maps_scroller = ScrollFrame()
    self.maps_scroller.width = content.width
    self.maps_scroller.content_margin = margin
    self.maps_scroller.scrollbar_thickness = 2
    self.maps_scroller.scroll_speed = 2

    self.maps = FlowBox()
    self.maps.item_margin = 2
    self.maps.orientation = Orientation.DOWN_RIGHT

    self.selected_state = FixedPropertyTable({selected = NONE})

    self.maps_scroller.height = math.min(148, self.maps.bb:height() + self.maps_scroller:v_non_content_space())
    self.maps.width = self.maps_scroller.width - self.maps_scroller:h_non_content_space()

    local buttons = FlowBox()
    buttons.orientation = Orientation.LEFT_UP
    buttons.item_margin = margin
    buttons.height = 32
    buttons.width = content.width

    local cancel_button = TripleButton()
    cancel_button.width = 32
    cancel_button.height = 32
    cancel_button.default_image = assets:get_image("ui/EditorCancelRelease")
    cancel_button.hover_image = assets:get_image("ui/EditorCancelHover")
    cancel_button.click_image = assets:get_image("ui/EditorCancelPress")
    cancel_button.mousereleased = function()
        self:close()
    end

    local accept_button = TripleButton()
    accept_button.width = 32
    accept_button.height = 32
    accept_button.default_image = assets:get_image("ui/EditorAcceptRelease")
    accept_button.hover_image = assets:get_image("ui/EditorAcceptHover")
    accept_button.click_image = assets:get_image("ui/EditorAcceptPress")
    accept_button.mousereleased = OneWayBinding(
        self.selected_state, "selected",
        function(selected)
            if selected ~= nil then
                if get_key(buttons.items, accept_button) == nil then
                    buttons:append(accept_button)
                end
                return function()
                    self:close()
                    editor.map = Map(selected)
                end
            else
                local i = index_of(buttons.items, accept_button)
                if i ~= nil then
                    content[i] = nil
                end
                return nil
            end
        end
    )

    self.maps_scroller.content = self.maps

    buttons:append(Void())
    buttons:append(cancel_button)

    content:append(self.maps_scroller)
    content:append(buttons)
    content:append(Void(margin))

    self.content = content
end

function EditorLoadDialog:refresh()
    self.maps:clear()
    for i, map in ipairs(Map.get_available_maps()) do
        local button = LayoutFrame()
        button.width = OneWayBinding(self.maps, "width")
        button.height = 24
        button.background_color = OneWayBinding(
            self.selected_state, "selected",
            function(selected)
                if selected == map then
                    return {0.9, 0.95, 0.95, 1}
                else
                    return hex2col("#afbfd2")
                end
            end
        )
        button.mousereleased = function()
            self.selected_state.selected = map
        end

        local text = Text()
        text.x = button.height / 4
        text.y = button.height / 2
        text.y_align = "center"
        text.text = map
        text.font = assets:get_font("font")
        text.color = hex2col("#3d5064")
        button.content = text

        self.maps.items[i] = button
    end

    self.maps_scroller.height = math.min(148, self.maps.bb:height() + self.maps_scroller:v_non_content_space())
    self.maps.width = self.maps_scroller.width - self.maps_scroller:h_non_content_space()
end
