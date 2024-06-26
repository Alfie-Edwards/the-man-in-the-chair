Direction = Enum.new("LEFT", "RIGHT", "UP", "DOWN")
Axis = Enum.new("X", "Y")

function direction_to_angle(direction)
    if direction == Direction.RIGHT then
        return 0
    elseif direction == Direction.UP then
        return math.pi * 1.5
    elseif direction == Direction.LEFT then
    	return math.pi
    else
        return math.pi * 0.5
    end
    error("Invalid direction \""..tostring(direction).."\".")
end

function direction_to_x(direction)
    if direction == Direction.RIGHT then
        return 1
    elseif direction == Direction.UP then
        return 0
    elseif direction == Direction.LEFT then
        return -1
    else
        return 0
    end
    error("Invalid direction \""..tostring(direction).."\".")
end

function direction_to_y(direction)
    if direction == Direction.RIGHT then
        return 0
    elseif direction == Direction.UP then
        return -1
    elseif direction == Direction.LEFT then
        return  0
    else
        return 1
    end
    error("Invalid direction \""..tostring(direction).."\".")
end

function direction_opposite(direction)
    if direction == Direction.RIGHT then
        return Direction.LEFT
    elseif direction == Direction.UP then
        return Direction.DOWN
    elseif direction == Direction.LEFT then
        return Direction.RIGHT
    else
        return Direction.UP
    end
    error("Invalid direction \""..tostring(direction).."\".")
end

function direction_axis(direction)
    if (direction == Direction.RIGHT) or (direction == Direction.LEFT) then
        return Axis.X
    elseif (direction == Direction.UP) or (direction == Direction.DOWN) then
        return Axis.Y
    end
    error("Invalid direction \""..tostring(direction).."\".")
end
