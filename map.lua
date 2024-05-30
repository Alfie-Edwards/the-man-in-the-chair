Map = {
    _UID_COUNTER = 1,
    DEFAULT_WIDTH = 144,
    DEFAULT_HEIGHT = 27,
    EXT = ".map",
    CONFIG_FILE = "config.data",
    LEVEL_FILE = "level.png",

    data = nil,
    uid = nil,
    config_file_path = nil,
    level_file_path = nil,
    config = nil,
    level_data = nil,
}

setup_class(Map)

function Map._UID()
    local uid = "map_"..tostring(Map._UID_COUNTER)
    Map._UID_COUNTER = Map._UID_COUNTER + 1
    return uid
end

function Map:__init(filename)
    super().__init(self)

    -- Resolve filename.
    if not filename then
        filename = "assets/empty"
    end
    filename = filename..Map.EXT

    -- Load map.
    self.data, err = love.filesystem.newFileData(filename)
    if err or self.data == nil then
        error("Failed to load map \""..filename.."\":\n"..(err or "Unknown error."))
    end

    -- Get uid and update data name to match.
    self.uid = Map._UID()
    self.data = love.filesystem.newFileData(self.data, self.uid)

    -- Mount map as in-memory archive.
    if not love.filesystem.mount(self.data, self.uid) then
        error("Failed to mount data from map file \""..filename.."\" to path \""..self.uid.."\".")
    end

    -- Load the config and level from the in-memory archive (or create defaults if they are missing).a
    self.config_file_path = self.uid.."/"..Map.CONFIG_FILE
    self.level_file_path = self.uid.."/"..Map.LEVEL_FILE

    if love.filesystem.getInfo(self.config_file_path, "file") then
        self.config = DataFile.load(self.config_file_path)
    else
        self.config = {}
    end

    MapSchemas.config:complete(x)

    if love.filesystem.getInfo(self.level_file_path, "file") then
        self.level_data = love.image.newImageData(self.level_file_path)
    else
        self.level_data = love.image.newImageData(Map.DEFAULT_WIDTH, Map.DEFAULT_HEIGHT)
    end
end

function Map:save(filename)
    filename = filename..Map.EXT

    -- Write config and level to mounted in-memory archive.
    DataFile.save(self.config_file_path, self.config)
    local level_file_data = self.level_data:encode("png")
    love.filesystem.write(self.level_file_path, level_file_data)

    -- Save in-memory archive to disk.
    love.filesystem.write(filename, self.data)
end

function Map.get_available_maps()
    local result = {}

    local files = love.filesystem.getDirectoryItems("")
    for _, path in ipairs(files) do
        if Map.is_map_file(path) then
            table.insert(result, string.sub(path, 1, -#Map.EXT - 1))
        end
    end
    return result
end

function Map.is_map_file(path)
    if string.sub(path, -(#Map.EXT), -1) ~= Map.EXT then
        return false
    end
    if love.filesystem.getInfo(path, "file") == nil then
        return false
    end

    return true
end

function Map:__gc()
    -- Unmount in-memory archive.
    love.filesystem.unmount(self.uid)
end


MapSchemas = {}

-- Primitives.
MapSchemas.color = PatternSchema("#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", "#000000")
MapSchemas.direction = EnumSchema(Direction)
MapSchemas.position = Schema({x = TypeSchema.NUMBER, y = TypeSchema.NUMBER})
MapSchemas.path = ListSchema(MapSchemas.position)

-- Entities.
MapSchemas.camera = Schema({
    position = MapSchemas.position,
})
MapSchemas.security_camera = Schema({
    position = MapSchemas.position,
    direction = MapSchemas.direction,
})
MapSchemas.door = Schema({
    position = MapSchemas.position,
    direction = MapSchemas.direction,
})
MapSchemas.guard = Schema({
    patrol_points = MapSchemas.path,
})
MapSchemas.george = Schema({
    position = MapSchemas.position,
})

-- Config file.
MapSchemas.config = Schema({
    tile_mapping = MapSchema(PatternSchema.COLOR, TypeSchema.STRING),
    solid_tile_types = ListSchema(TypeSchema.STRING),
    camera = MapSchemas.camera,
    security_cameras = ListSchema(MapSchemas.security_camera),
    doors = ListSchema(MapSchemas.door),
    guards = ListSchema(MapSchemas.guard),
    george = MapSchemas.george,
})
