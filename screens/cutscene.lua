require "ui.simple_element"
require "ui.image"
require "screens.main_menu"

CutsceneSectionType = {
    THROUGH = "through",
    LOOP = "loop",
}

Section = {
    section_type = nil,
    frames_per_second = nil,
    audio = nil,
    hold_frames = {},  -- { idx = seconds, ... }
}
setup_class(Section)
function Section.new(section_type, frames_per_second, audio, hold_frames)
    local obj = magic_new()

    if hold_frames == nil then
        hold_frames = {}
    end

    obj.section_type = section_type
    obj.frames_per_second = frames_per_second
    obj.audio = audio
    obj.hold_frames = hold_frames

    return obj
end

Cutscene = {
    frames = nil,
    sections = nil,
    finished_callback = nil,

    image = nil,

    current_section_num = nil,
    t_started_current_section = nil,

    finished = nil,
}
setup_class(Cutscene, SimpleElement)

function Cutscene.new(frames, sections, finished_callback)
    local obj = magic_new()

    obj:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )

    obj.frames = frames
    obj.sections = sections
    obj.finished_callback = finished_callback

    obj.current_section_num = 1
    obj.t_started_current_section = love.timer.getTime()

    obj.finished = false

    local image = Image.new()
    image:set_properties(
        {
            width = canvas:width(),
            height = canvas:height(),
        }
    )
    obj:add_child(image)
    obj.image = image

    return obj
end

function Cutscene.from_dir(dirname, sections, finished_callback)
    files = love.filesystem.getDirectoryItems("assets/"..dirname)

    if files == nil then
        error("couldn't open dir "..dirname.."!")
    end

    frames = {}

    for _,filename in ipairs(files) do
        local section_num,frame_num = string.match(filename, ".*([0-9]+)-([0-9]+).png")

        if section_num == nil or frame_num == nil then
            error("invalid file "..filename)
        end

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

    return Cutscene.new(frames, sections, finished_callback)
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

function Cutscene:update(dt)
    super().update(self, dt)

    if self.finished then
        return
    end

    if love.keyboard.isDown("space") and t_since(self.t_started_current_section) > 0.2 then
        if self.sections[self.current_section_num + 1] ~= nil then
            self.current_section_num = self.current_section_num + 1
            self.t_started_current_section = love.timer.getTime()
        elseif self.finished_callback ~= nil then
            self.finished = true
            self.finished_callback()
        end
    end
end
