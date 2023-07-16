Map = {
    _UID_COUNTER = 1,
    DEFAULT_WIDTH = 144,
    DEFAULT_HEIGHT = 27,
    EXT = ".map",
    CONFIG_FIELDS = list_to_set({"tile_mapping", "solid_tile_types", "camera", "security_cameras", "doors", "guards", "george"}),
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

function Map.new(filename)
    local obj = magic_new()

    -- Resolve filename.
    if not filename then
        filename = "assets/empty"
    end
    filename = filename..Map.EXT

    -- Load map.
    obj.data, err = love.filesystem.newFileData(filename)
    if err or obj.data == nil then
        error("Failed to load map \""..filename.."\":\n"..(err or "Unknown error."))
    end

    -- Get uid and update data name to match.
    obj.uid = Map._UID()
    obj.data = love.filesystem.newFileData(obj.data, obj.uid)

    -- Mount map as in-memory archive.
    if not love.filesystem.mount(obj.data, obj.uid) then
        error("Failed to mount data from map file \""..filename.."\" to path \""..obj.uid.."\".")
    end

    -- Load the config and level from the in-memory archive (or create defualts if they are missing).a
    obj.config_file_path = obj.uid.."/"..Map.CONFIG_FILE
    obj.level_file_path = obj.uid.."/"..Map.LEVEL_FILE

    if love.filesystem.getInfo(obj.config_file_path, "file") then
        obj.config = DataFile.load(obj.config_file_path)
    else
        obj.config = {}
    end
    for field, _ in pairs(obj.config) do
        if not Map.CONFIG_FIELDS[field] then
            print("WARNING: Unrecognised config field \""..field.."\" in map \""..filename.."\".")
        end
    end
    for field, _ in pairs(Map.CONFIG_FIELDS) do
        if obj.config[field] == nil then
            obj.config[field] = {}
        end
    end

    if love.filesystem.getInfo(obj.level_file_path, "file") then
        obj.level_data = love.image.newImageData(obj.level_file_path)
    else
        obj.level_data = love.image.newImageData(Map.DEFAULT_WIDTH, Map.DEFAULT_HEIGHT)
    end

    return obj
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

    local save_dir = love.filesystem.getSaveDirectory()
    local files = love.filesystem.getrectoryItems(save_dir)
    for _, path in ipairs(files) do
        if Map.is_map_file(path) then
            table.insert(result, path)
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