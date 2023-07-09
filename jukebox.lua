require "alarm"
require "entities.entity"

Jukebox = {
    tracks = nil,
    volume = nil,
}
setup_class(Jukebox, Entity)

function Jukebox.new(volume)
    local obj = magic_new()

    if volume == nil then
        volume = 1
    end

    obj.tracks = {
        default = love.audio.newSource("assets/Sound/MusicBG2Normal.WAV", "stream"),
        alarm = love.audio.newSource("assets/Sound/MusicBG2Alarm.WAV", "stream"),
    }
    obj.volume = volume

    obj:silence()

    for _,audio in pairs(obj.tracks) do
        audio:play()
    end

    obj:set_track("default")

    return obj
end

function Jukebox:silence()
    for _,audio in pairs(self.tracks) do
        audio:setVolume(0)
    end
end

function Jukebox:set_track(track)
    self:silence()
    self.tracks[track]:setVolume(self.volume)
end

function Jukebox:update(dt, state)
    if state.alarm.is_on then
        self:set_track("alarm")
    else
        self:set_track("default")
    end
end
