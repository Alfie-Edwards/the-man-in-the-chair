require "map"
require "sprite"
require "entities.door"
require "entities.george"
require "entities.guard"
require "entities.security_camera"

EditorEntityConfig = {
    entity_class = nil,
    schema = nil,
    config_list_name = nil,

    editor = nil,
    config = nil,
}
setup_class(EditorEntityConfig)

function EditorEntityConfig:__init(editor, config)
    self.editor = editor
    self.config = nil_coalesce(config, self.schema:complete())
end

function EditorEntityConfig:name()
    return self.entity_class:type()
end

function EditorEntityConfig:sprite_from_config(config)
    error("Must be implemented in subclass.")
end

function EditorEntityConfig:sprite()
    return self:sprite_from_config(self.config)
end

function EditorEntityConfig:set_position(x, y)
    self.config.position.x = x
    self.config.position.y = y
end

function EditorEntityConfig:add_to_map()
    table.insert(self.editor.map.config[self.config_list_name], deep_copy(self.config))
end

function EditorEntityConfig:add_to_state()
    self.editor.state:add(self.entity_class.from_config(self.editor.state, self.config))
end

-------------------------------------------------------------------------------
-- GEORGE
-------------------------------------------------------------------------------

GeorgeEditorConfig = {
    entity_class = George,
    schema = MapSchemas.george,
}
setup_class(GeorgeEditorConfig, EditorEntityConfig)

function GeorgeEditorConfig:set_position(x, y)
    self.config.position.x = x * self.editor.state.level.cell_length_pixels
    self.config.position.y = y * self.editor.state.level.cell_length_pixels
end

function GeorgeEditorConfig:sprite_from_config(config)
    return sprite.directional(George.SPRITE_SETS.idle, config.direction)
end

function GeorgeEditorConfig:add_to_map()
    self.editor.map.config.george = deep_copy(self.config)
end

function GeorgeEditorConfig:add_to_state()
    local george = self.editor.state:first("George")
    if george ~= nil then
        self.editor.state:remove(george)
    end
    self.editor.state:add(self.entity_class.from_config(self.editor.state, self.config))
end

-------------------------------------------------------------------------------
-- GUARD
-------------------------------------------------------------------------------

GuardEditorConfig = {
    entity_class = Guard,
    schema = MapSchemas.guard,
    config_list_name = "guards",
}
setup_class(GuardEditorConfig, EditorEntityConfig)

function GuardEditorConfig:set_position(x, y)
    self.config.patrol_points[1] = {
        x = x * self.editor.state.level.cell_length_pixels,
        y = y * self.editor.state.level.cell_length_pixels
    }
end

function GuardEditorConfig:sprite_from_config(config)
    return sprite.directional(Guard.SPRITE_SETS.idle, config.direction)
end

-------------------------------------------------------------------------------
-- SECURITY CAMERA
-------------------------------------------------------------------------------

SecurityCameraEditorConfig = {
    entity_class = SecurityCamera,
    schema = MapSchemas.security_camera,
    config_list_name = "security_cameras",
}
setup_class(SecurityCameraEditorConfig, EditorEntityConfig)

function SecurityCameraEditorConfig:sprite_from_config(config)
    return sprite.directional(SecurityCamera.SPRITE_SETS, config.direction).c
end

-------------------------------------------------------------------------------
-- DOOR
-------------------------------------------------------------------------------

DoorEditorConfig = {
    entity_class = Door,
    schema = MapSchemas.door,
    config_list_name = "doors",
}
setup_class(DoorEditorConfig, EditorEntityConfig)

function DoorEditorConfig:sprite_from_config(config)
    return sprite.directional(Door.SPRITES, config.direction)[1]
end

-------------------------------------------------------------------------------
-- ENTIRY CONFIG REGISTRATION
-------------------------------------------------------------------------------

EDITOR_ENTITY_CONFIGS = {
    GeorgeEditorConfig,
    GuardEditorConfig,
    SecurityCameraEditorConfig,
    DoorEditorConfig,
}