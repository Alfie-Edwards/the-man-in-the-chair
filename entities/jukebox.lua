require "alarm"
require "entities.entity"

Jukebox = {
    tracks = nil,
    volume = nil,
}
setup_class(Jukebox, Entity)

function Jukebox:__init(state, volume)
    super().__init(self, state)

    if volume == nil then
        volume = 1
    end

    self.tracks = {
        default = love.audio.newSource("assets/Sound/MusicBG2Normal.WAV", "stream"),
        alarm = love.audio.newSource("assets/Sound/MusicBG2Alarm.WAV", "stream"),
    }
    self.volume = volume

    self:silence()

    for _,audio in pairs(self.tracks) do
        audio:setLooping(true)
        audio:play()
    end

    self:set_track("default")
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

function Jukebox:update(dt)
    if self.state.alarm.is_on then
        self:set_track("alarm")
    else
        self:set_track("default")
    end
end
