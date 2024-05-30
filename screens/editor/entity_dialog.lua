require "ui.containers.dialog"
require "ui.containers.scroll_frame"
require "ui.containers.flow_box"
require "ui.containers.layout_frame"
require "ui.image_button"
require "screens.editor.entity_configs"

EditorEntityDialog = {}
setup_class(EditorEntityDialog, Dialog)

function EditorEntityDialog:__init(editor)
    super().__init(self)

    self.block_interaction = true
    self.close_on_background_click = true

    scroll_frame = ScrollFrame()
    scroll_frame.x = canvas:width() / 2
    scroll_frame.y = canvas:height() / 2
    scroll_frame.x_align = "center"
    scroll_frame.y_align = "center"
    scroll_frame.width = 256
    scroll_frame.content_margin = 8
    scroll_frame.scrollbar_thickness = 2
    scroll_frame.scroll_speed = 2
    scroll_frame.background_color = {0, 0, 0, 0.6}

    tiles = FlowBox()
    tiles.item_margin = 4
    tiles.line_margin = 4
    tiles.orientation = Orientation.RIGHT_DOWN

    for _, entity_config_class in ipairs(EDITOR_ENTITY_CONFIGS) do
        local entity_config = editor.entity_configs[entity_config_class:name()]
        local button = ImageButton()
        button.width = 32
        button.height = button.width
        button.image = entity_config:sprite()
	    button.background_color = hex2col("#afbfd2")
	    button.border_thickness = 1
	    button.border_color = {0, 0, 0, 0.5}
        button.mousereleased = function()
            editor.entity_config = entity_config
            self:close()
        end

        tiles:append(button)
    end

    tiles.max_width = scroll_frame.width - scroll_frame:h_non_content_space()
    scroll_frame.height = math.min(148, tiles.bb:height() + scroll_frame:v_non_content_space())
    scroll_frame.width = tiles.bb:width() + scroll_frame:h_non_content_space()
    tiles.max_width = tiles.bb:width()

    scroll_frame.content = tiles
    self.content = scroll_frame
end
