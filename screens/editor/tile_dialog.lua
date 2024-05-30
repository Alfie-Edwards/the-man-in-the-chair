require "ui.containers.dialog"
require "ui.containers.scroll_frame"
require "ui.containers.flow_box"
require "ui.containers.layout_frame"
require "ui.image_button"

EditorTileDialog = {}
setup_class(EditorTileDialog, Dialog)

function EditorTileDialog:__init(editor)
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

    for color, texture in pairs(editor.map.config.tile_mapping) do
        local button = ImageButton()
        button.width = 32
        button.height = button.width
        button.image = assets:get_image(texture)
        button.mousereleased = function()
            editor.color = color
            self:close()
        end

        local frame = LayoutFrame()
        frame.border_color = {0, 0, 0, 1}
        frame.border_thickness = 1
        frame.width = button.width + 2 * frame.border_thickness
        frame.height = button.height + 2 * frame.border_thickness
        frame.content = button
        frame.content.x = frame.border_thickness
        frame.content.y = frame.border_thickness

        tiles:append(frame)
    end

    tiles.max_width = scroll_frame.width - scroll_frame:h_non_content_space()
    scroll_frame.height = math.min(148, tiles.bb:height() + scroll_frame:v_non_content_space())
    scroll_frame.width = tiles.bb:width() + scroll_frame:h_non_content_space()
    tiles.max_width = tiles.bb:width()

    scroll_frame.content = tiles
    self.content = scroll_frame
end
