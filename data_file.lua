DataFile = {
    sections = {}  -- a map "section name": callback_fn(line: string)
}
setup_class(DataFile)


function DataFile.new(sections)
    local obj = magic_new()

    obj.sections = sections

    return obj
end

function DataFile:load(filename)
    local f = love.filesystem.lines(filename)

    if not f then
        error("couldn't open file "..filename.."!")
    end

    local current_section_callback = nil

    for line in f do
        if line ~= "" then
            local section_name = string.match(line, "^= (.*)$")
            if section_name then
                -- new section
                local found = false
                for s,c in pairs(self.sections) do
                    if s == section_name then
                        current_section_callback = c
                        found = true
                        break
                    end
                end
                if not found then
                    error("tried to start an unknown section "..section_name)
                end
            else
                -- process member of current section
                if current_section_callback ~= nil then
                    current_section_callback(line)
                end
            end
        end
    end
end
