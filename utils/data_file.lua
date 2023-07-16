DataFile = {
    TOKEN_TYPES = {
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
    INDENT="   ",
}

function DataFile.save(filename, data)
    local data_string = DataFile.serialize(data)
    love.filesystem.write(filename, data_string)
end

function DataFile.serialize(data)
    return DataFile.serialize_table(data)
end

function DataFile.serialize_table(t, indent_level)
    indent_level = indent_level or 0
    local indent_string = string.rep(DataFile.INDENT, indent_level + 1)
    local result = "{\n"

    for key, value in pairs(t) do
        -- Add indent.
        result = result..indent_string

        -- Add key.
        if type(key) == "table" then
            result = result..DataFile.serialize_table(key, indent_level + 1)
        elseif DataFile.is_primitive(key) then
            result = result..DataFile.serialize_primitive(key)
        else
            error("Unexpected type for key \""..type(key).."\".")
        end

        -- Add : .
        result = result..": "

        -- Add value.
        if type(value) == "table" then
            result = result..DataFile.serialize_table(value, indent_level + 1)
        elseif DataFile.is_primitive(value) then
            result = result..DataFile.serialize_primitive(value)
        else
            error("Unexpected type for value \""..type(key).."\".")
        end

        -- Add , .
        result = result..",\n"
    end

    result = result..string.rep(DataFile.INDENT, indent_level).."}"
    return result
end

function DataFile.is_primitive(p)
    return type(p) == "string" or
           type(p) == "number" or
           type(p) == "boolean"
end

function DataFile.serialize_primitive(p)
    if type(p) == "string" then
        return DataFile.serialize_string(p)
    elseif type(p) == "number" then
        return DataFile.serialize_number(p)
    elseif type(p) == "boolean" then
        return DataFile.serialize_boolean(p)
    end

    error("Unrecognised primitive type \""..type(p).."\".")
end

function DataFile.serialize_string(s)
    assert(type(s) == "string")
    return "\""..s.."\""
end

function DataFile.serialize_number(n)
    assert(type(n) == "number")
    return string.format("%f", n)
end

function DataFile.serialize_boolean(b)
    assert(type(b) == "boolean")
    if b then
        return "true"
    else
        return "false"
    end
end

function DataFile.load(filename)
    local data_string, _ = love.filesystem.read(filename)

    if not data_string then
        error("Couldn't open file \""..filename.."\"!")
    end

    return DataFile.deserialize(data_string)
end

function DataFile.deserialize(data_string)
    -- Parse to beginning of root table.
    local token_type, token, i = DataFile.next_non_whitespace_token(data_string, 1)
    if token_type ~= "table_begin" then
        error("Expected a table at the root, found a "..token_type..":\n"..DataFile.get_source_string(data_string, i))
    end

    -- Parse root table.
    local data, i = DataFile.deserialize_table(data_string, i)

    -- Check only whitespace after root table.
    while i <= #data_string do
        token_type, token, i = DataFile.next_token(data_string, i)
        if token_type ~= "whitespace" then
            error("Found "..token_type.." token after the end of the root table:\n"..DataFile.get_source_string(data_string, i))
        end
    end

    return data
end

function DataFile.next_token(data_string, i)
    for token_type, pattern in pairs(DataFile.TOKEN_TYPES) do
        local _, i_end, token = string.find(data_string, pattern, i)
        if token ~= nil then
            -- For debugging.
            -- print(token_type, "\""..token.."\"")
            return token_type, token, i_end + 1
        end
    end
    error("Failed to deserialize data_string at position "..tostring(i)..":\n"..DataFile.get_source_string(data_string, i))
end

function DataFile.next_non_whitespace_token(data_string, i)
    local token_type, token
    repeat
        token_type, token, i = DataFile.next_token(data_string, i)
    until(i > #data_string or token_type ~= "whitespace")
    return token_type, token, i
end

function DataFile.deserialize_table(data_string, i)
    local result = {}
    local start_i = i - 1
    local token_type, token, key, value

    repeat
        -- Parse key or end.
        if i > #data_string then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(data_string, start_i))
        end
        token_type, token, i = DataFile.next_non_whitespace_token(data_string, i)
        if token_type == "table_end" then
            break
        end
        if token_type == "table_begin" then
            key, i = DataFile.deserialize_table(data_string, i)
        elseif DataFile.token_type_is_primitive(token_type) then
            key = DataFile.deserialize_primitive(token_type, token)
        else
            error("Expected table key or table end '}', got \""..token_type.."\":\n"..DataFile.get_source_string(data_string, i))
        end

        -- Parse separator.
        if i > #data_string then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(data_string, start_i))
        end
        token_type, token, i = DataFile.next_non_whitespace_token(data_string, i)
        if token_type ~= "table_separator" then
            error("Expected table separator ':', got \""..token_type.."\":\n"..DataFile.get_source_string(data_string, i))
        end

        -- Parse value.
        if i > #data_string then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(data_string, start_i))
        end
        token_type, token, i = DataFile.next_non_whitespace_token(data_string, i)
        if token_type == "table_begin" then
            value, i = DataFile.deserialize_table(data_string, i)
        elseif DataFile.token_type_is_primitive(token_type) then
            value = DataFile.deserialize_primitive(token_type, token)
        else
            error("Invalid token for table value \""..token_type.."\":\n"..DataFile.get_source_string(data_string, i))
        end

        -- Parse deliminator or end.
        if i > #data_string then
            error("Table at "..tostring(start_i).." never closed:\n"..DataFile.get_source_string(data_string, start_i))
        end
        token_type, token, i = DataFile.next_non_whitespace_token(data_string, i)
        if token_type ~= "table_deliminator" and token_type ~= "table_end" then
            error("Expected table deliminator ',' or table end '}', got \""..token_type.."\":\n"..DataFile.get_source_string(data_string, i))
        end

        result[key] = value
    until(token_type == "table_end")

    return result, i
end

function DataFile.token_type_is_primitive(token_type)
    return token_type == "boolean1" or token_type == "boolean2" or
           token_type == "string1" or token_type == "string2" or
           token_type == "number"
end

function DataFile.deserialize_primitive(token_type, token)
    if token_type == "boolean1" or token_type == "boolean2" then
        return DataFile.deserialize_boolean(token)
    elseif token_type == "string1" or token_type == "string2" then
        return DataFile.deserialize_string(token)
    elseif token_type == "number" then
        return DataFile.deserialize_number(token)
    end

    error("Unrecognised primitive token type \""..token_type.."\".")
end

function DataFile.deserialize_boolean(token)
    if token == "true" then
        return true
    elseif token == "false" then
        return false
    end
    error("Failed to deserialize boolean \""..token.."\".")
end

function DataFile.deserialize_string(token)
    assert((string.sub(token, 1, 1) == "\"" and string.sub(token, -1, -1) == "\"") or
           (string.sub(token, 1, 1) == "'" and string.sub(token, -1, -1) == "'"),
           "Failed to deserialize string \""..token.."\".")
    return string.sub(token, 2, -2)
end

function DataFile.deserialize_number(token)
    local number = tonumber(token)
    if number == nil then
        error("Failed to deserialize number \""..token.."\".")
    end
    return number
end

function DataFile.get_source_string(data_string, i)
    local i_begin = math.max(1, i - 39)
    local i_end = math.min(#data_string, i + 40)
    return string.sub(data_string, i_begin, i_end).."\n"..string.rep(" ", i - i_begin).."^"
end
