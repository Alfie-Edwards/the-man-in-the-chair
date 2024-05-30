require "ui.layout_element"
require "ui.image"
require "screens.main_menu"

CutsceneSectionType = {
    THROUGH = "through",
    LOOP = "loop",
}

Section = {
    section_type = nil,
    frames_per_second = nil,
    audio = {},  -- { name = { source = audio, when = int, loop = bool? }, ... }
    hold_frames = {},  -- { idx = seconds, ... }
}
setup_class(Section)
function Section:__init(section_type, frames_per_second, audio, hold_frames)
    super().__init(self)

    if hold_frames == nil then
        hold_frames = {}
    end

    self.section_type = section_type
    self.frames_per_second = frames_per_second
    self.audio = audio
    self.hold_frames = hold_frames
end

Cutscene = {
    frames = nil,
    sections = nil,
    bg_music = nil,
    finished_callback = nil,

    image = nil,

    current_section_num = nil,
    t_started_current_section = nil,

    finished = nil,
}
setup_class(Cutscene, LayoutElement)

function Cutscene:__init(frames, sections, bg_music, finished_callback)
    super().__init(self)

    self:set(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    self.frames = frames
    self.sections = sections
    self.bg_music = bg_music
    self.finished_callback = finished_callback

    if self.bg_music ~= nil then
        self.bg_music:setLooping(true)
        self.bg_music:play()
    end

    self:start_section(1)

    self.finished = false

    local image = Image()
    image:set(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    self:_add_visual_child(image)
    self.image = image
end

function Cutscene.from_dir(dirname, sections, bg_music, finished_callback)
    files = love.filesystem.getDirectoryItems("assets/"..dirname)

    if files == nil then
        error("couldn't open dir "..dirname.."!")
    end

    frames = {}

    for _,filename in ipairs(files) do
        local section_num,frame_num = string.match(filename, ".*([0-9]+)-([0-9]+).png")

        if section_num == nil or frame_num == nil then
            print("WARNING: ignoring invalid file "..filename)
        else
            section_num = tonumber(section_num)
            frame_num = tonumber(frame_num)

            if section_num == nil or frame_num == nil then
                error("invalid file "..filename)
            end

            if frames[section_num] == nil then
                frames[section_num] = {}
            end
            frames[section_num][frame_num] = love.graphics.newImage("assets/"..dirname.."/"..filename)
        end
    end

    return Cutscene(frames, sections, bg_music, finished_callback)
end

function Cutscene:section_duration(section_num)
    local section = self.sections[section_num]
    local normal_frame_duration = 1 / section.frames_per_second

    local res = 0
    for i,f in ipairs(self.frames[section_num]) do
        local hf = section.hold_frames[i]
        if hf ~= nil then
            res = res + hf
        else
            res = res + normal_frame_duration
        end
    end

    return res
end

-- returns index, image
function Cutscene:current_frame()
    local t_in_current_section = t_since(self.t_started_current_section)
    local current_section = self.sections[self.current_section_num]
    if current_section.section_type == CutsceneSectionType.LOOP then
        t_in_current_section = t_in_current_section % self:section_duration(self.current_section_num)
    end

    local normal_frame_duration = 1 / current_section.frames_per_second

    local t_stepped = 0

    local iter_i = 1
    local iter_f = 1
    for i,f in ipairs(self.frames[self.current_section_num]) do
        iter_i = i
        iter_f = f

        local frame_duration = normal_frame_duration

        local hf = current_section.hold_frames[i]
        if hf ~= nil then
            frame_duration = hf
        end

        t_stepped = t_stepped + frame_duration

        if t_stepped > t_in_current_section then
            return i,f
        end
    end

    -- return the final frame
    return iter_i, iter_f
end

function Cutscene:draw()
    local idx,img = self:current_frame()

    self.image:set_image(img)
end

function Cutscene:end_section(section_num)
    local section = self.sections[section_num]

    for _,a in pairs(section.audio) do
        a.source:stop()
    end
end

function Cutscene:start_section(section_num)
    local section = self.sections[section_num]

    if section == nil then
        return false
    end

    self.current_section_num = section_num
    self.t_started_current_section = love.timer.getTime()

    for name,a in pairs(section.audio) do
        if a.volume ~= nil then
            a.source:setVolume(a.volume)
        end

        if a.loop == true then
            a.source:setLooping(true)
        end
    end

    return true
end

function Cutscene:play_sounds()
    local section = self.sections[self.current_section_num]

    for name,a in pairs(section.audio) do
        if a.when ~= -1 and
           a.played ~= true and
           t_since(self.t_started_current_section) > a.when then
            a.source:stop()
            a.source:play()
            a.played = true
        end
    end
end

function Cutscene:finish()
    self.finished = true

    if self.bg_music ~= nil then
        self.bg_music:stop()
    end

    if self.finished_callback ~= nil then
        self.finished_callback()
    end
end

function Cutscene:update(dt)
    super().update(self, dt)

    if self.finished then
        return
    end

    self:play_sounds()

    if love.keyboard.isDown("space") and t_since(self.t_started_current_section) > 0.2 then
        self:end_section(self.current_section_num)

        if (not self:start_section(self.current_section_num + 1)) then
            self:finish()
        end
    end
end
