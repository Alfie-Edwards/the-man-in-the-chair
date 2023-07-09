Direction = { LEFT = 0, RIGHT = 1, UP = 2, DOWN = 3 }

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
end