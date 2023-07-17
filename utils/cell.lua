Cell = {
    x = nil,
    y = nil,
}
setup_class(Cell)

function Cell.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y

    return obj
end

function Cell:__eq(other)
    if not is_type(other, Cell) then
        return false
    end
    return self:__hash() == other:__hash()
end

function Cell:__tostring()
    return "Cell("..tostring(self.x)..", "..tostring(self.y)..")"
end

function Cell:__hash()
    return tostring(self.x)..","..tostring(self.y)
end

function line_super_cover(x1, y1, x2, y2)
    local result = HashSet.new()
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)

    local x = math.floor(x1)
    local y = math.floor(y1)

    local n = 1
    local x_inc, y_inc
    local error

    if dx == 0 then
        x_inc = 0
        error = math.huge
    elseif x2 > x1 then
        x_inc = 1
        n = n + math.floor(x2) - x
        error = (math.floor(x1) + 1 - x1) * dy
    else
        x_inc = -1
        n = n + x - math.floor(x2)
        error = (x1 - math.floor(x1)) * dy
    end

    if dy == 0 then
        y_inc = 0
        error = error - math.huge
    elseif y2 > y1 then
        y_inc = 1
        n = n + math.floor(y2) - y
        error = error - (math.floor(y1) + 1 - y1) * dx
    else
        y_inc = -1
        n = n + y - math.floor(y2)
        error = error - (y1 - math.floor(y1)) * dx
    end

    while n > 0 do
        result:add(Cell.new(x, y))

        if (error > 0) then
            y = y + y_inc
            error = error - dx
        else
            x = x + x_inc
            error = error + dy
        end
        n = n - 1
    end

    return result
end
