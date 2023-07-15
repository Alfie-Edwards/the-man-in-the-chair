DataFile = {
    TOKENS = {
        boolean1 = "^(true)",
        boolean2 = "^(false)",
        string1 = "^(\"[^\"]*\")",
        string2 = "^('[^']*')",
        number = "^([0-9.-]+)",
        table_begin = "^({)",
        table_end = "^(})",
        table_deliminator = "^(,)",
        table_separator = "^(:)",
        whitespace = "^(%s+)"
    },
}

function DataFile.load(filename)
    local contents, _ = love.filesystem.read(filename)

    if not contents then
        error("Couldn't open file \""..filename.."\"!")
    end

    -- Parse to beginning of root table.
    local type, match, i = DataFile.next_non_whitespace_match(contents, 1)
    if type ~= "table_begin" then
        error("Expected a table at the root, found a "..type..":\n"..DataFile.get_source_string(contents, i))
    end

    -- Parse root table.
    local root, i = DataFile.parse_table(contents, i)

    -- Check only whitespace after root table.
    while i <= #contents do
        type, match, i = DataFile.next_match(contents, i)
        if type ~= "whitespace" then
            error("Found "..type.." token after the end of the root table:\n"..DataFile.get_source_string(contents, i))
        end
    end

    return root
end

function DataFile.next_match(contents, i)
    for type, pattern in pairs(DataFile.TOKENS) do
        local _, i_end, match = string.find(contents, pattern, i)
        if match ~= nil then
            -- For debugging.
            -- print(type, "\""..match.."\"")
            return type, match, i_end + 1
        end
    end
    error("Failed to parse contents at position "..tostring(i)..":\n"..DataFile.get_source_string(contents, i))
end

function DataFile.next_non_whitespace_match(contents, i)
    local type, match
    repeat
        type, match, i = DataFile.next_match(contents, i)
    until(i > #contents or type ~= "whitespace")
    return type, match, i
end

function DataFile.parse_table(contents, i)
    local result = {}
    local start_i = i - 1
    local type, match, key, value

    repeat
        -- Parse key
        if i > #contents then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(contents, start_i))
        end
        type, match, i = DataFile.next_non_whitespace_match(contents, i)
        if type == "table_begin" then
            key, i = DataFile.parse_table(contents, i)
        elseif DataFile.is_primitive(type) then
            key = DataFile.parse_primitive(type, match)
        else
            error("Invalid token for table key \""..type.."\":\n"..DataFile.get_source_string(contents, i))
        end

        -- Parse separator
        if i > #contents then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(contents, start_i))
        end
        type, match, i = DataFile.next_non_whitespace_match(contents, i)
        if type ~= "table_separator" then
            error("Expected table separator ':', got \""..type.."\":\n"..DataFile.get_source_string(contents, i))
        end

        -- Parse value
        if i > #contents then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(contents, start_i))
        end
        type, match, i = DataFile.next_non_whitespace_match(contents, i)
        if type == "table_begin" then
            value, i = DataFile.parse_table(contents, i)
        elseif DataFile.is_primitive(type) then
            value = DataFile.parse_primitive(type, match)
        else
            error("Invalid token for table value \""..type.."\":\n"..DataFile.get_source_string(contents, i))
        end

        -- Parse deliminator or end
        if i > #contents then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(contents, start_i))
        end
        type, match, i = DataFile.next_non_whitespace_match(contents, i)
        if type ~= "table_deliminator" and type ~= "table_end" then
            error("Expected table deliminator ',' or table end '}', got \""..type.."\":\n"..DataFile.get_source_string(contents, i))
        end

        result[key] = value
    until(type == "table_end")

    return result, i
end

function DataFile.is_primitive(type)
    return type == "boolean1" or type == "boolean2" or
           type == "string1" or type == "string2" or
           type == "number"
end

function DataFile.parse_primitive(type, match)
    if type == "boolean1" or type == "boolean2" then
        return DataFile.parse_boolean(match)
    elseif type == "string1" or type == "string2" then
        return DataFile.parse_string(match)
    elseif type == "number" then
        return DataFile.parse_number(match)
    end

    error("Unrecognised primitive type \""..type.."\".")
end

function DataFile.parse_boolean(match)
    if match == "true" then
        return true
    elseif match == "false" then
        return false
    end
    error("Failed to parse boolean \""..match.."\".")
end

function DataFile.parse_string(match)
    assert((string.sub(match, 1, 1) == "\"" and string.sub(match, -1, -1) == "\"") or
           (string.sub(match, 1, 1) == "'" and string.sub(match, -1, -1) == "'"),
           "Failed to parse string \""..match.."\".")
    return string.sub(match, 2, -2)
end

function DataFile.parse_number(match)
    local number = tonumber(match)
    if number == nil then
        error("Failed to parse number \""..match.."\".")
    end
    return number
end

function DataFile.get_source_string(contents, i)
    local i_begin = math.max(1, i - 39)
    local i_end = math.min(#contents, i + 40)
    return string.sub(contents, i_begin, i_end).."\n"..string.rep(" ", i - i_begin).."^"
end
