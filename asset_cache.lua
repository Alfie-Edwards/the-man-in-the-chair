AssetCache = {
    assets_root = nil,
    images = nil,
    image_data = nil,
    fonts = nil,
    sounds = nil,
}
setup_class(AssetCache)

function AssetCache:__init(assets_root)
    super().__init(self)

    self.assets_root = assets_root
    self.images = {}
    self.image_data = {}
    self.fonts = {}
    self.sounds = {}
end

function AssetCache:path(name)
    if self.assets_root then
        return self.assets_root.."/"..name
    end
    return name
end

function AssetCache:get_image(name, extension)
    name = name.."."..(extension or "png")
    if self.images[name] == nil then
        self.images[name] = love.graphics.newImage(self:path(name))
    end
    return self.images[name]
end

function AssetCache:get_image_data(name, extension)
    name = name.."."..(extension or "png")
    if self.image_data[name] == nil then
        self.image_data[name] = love.image.newImageData(self:path(name))
    end
    return self.image_data[name]
end

function AssetCache:get_font(name, extension, size)
    name = name.."."..(extension or "ttf")
    size = size or 8
    if self.fonts[name] == nil then
        self.fonts[name] = love.graphics.newFont(self:path(name), size, "none")
        self.fonts[name]:setFilter("nearest", "nearest", size)
    end
    return self.fonts[name]
end

function AssetCache:get_mp3(name, mode)
    return self:get_sound(name, "mp3", mode)
end

function AssetCache:get_sound(name, extension, mode)
    name = name.."."..(extension or "mp3")
    if self.sounds[name] == nil then
        self.sounds[name] = love.audio.newSource(self:path(name), mode or "static")
    end
    return self.sounds[name]
end
