require "behaviours.behaviour"
require "entities.door"

FindDoor = {
    door_cells = nil,
    checked_doors = nil,
    unreachable_doors = nil,
    all_doors = nil,
    goto_target = nil,
    target_door = nil,
}
setup_class(FindDoor, Behaviour)

DoorQueryResult = {
    UNREACHABLE = {},
    IN_FRONT = {},
    BEHIND = {},
}

function FindDoor.new()
    local obj = magic_new()

    return obj
end

function FindDoor:start(entity, state)
    super().start(self, entity, state)

    self.i = 0
    self.all_doors = {}
    self.checked_doors = {}
    self.unreachable_doors = {}
    self.door_cells = HashSet.new()
    for _, door in ipairs(state.entities) do
        if is_type(door, "Door") then
            self.door_cells = self.door_cells + door:active_cells()
            table.insert(self.all_doors, door)
        end
    end

    self.target_door = self:next_door()
    if self.target_door ~= nil then
        local cell = self:get_door_cell_to_progress(self.target_door, self.state)
        self.goto_target = Goto.new(
            (cell.x + 0.5) * self.state.level.cell_length_pixels,
            (cell.y + 0.5) * self.state.level.cell_length_pixels,
            3
        )
        self.goto_target:start(self.entity, self.state)
    end
end

function FindDoor:next_door()
    if iter_size(self.unreachable_doors) == #self.all_doors then
        return nil
    end
    if iter_size(self.checked_doors) == #self.all_doors then
        self.checked_doors = shallowcopy(self.unreachable_doors)
    end

    local i = love.math.random(#self.all_doors)
    while self.unreachable_doors[self.all_doors[i]] or self.checked_doors[self.all_doors[i]] do
        i = love.math.random(#self.all_doors)
    end

    local door = self.all_doors[i]
    self.checked_doors[door] = true

    local result = self:query(door)
    if result == DoorQueryResult.UNREACHABLE then
        self.unreachable_doors[door] = true
    elseif result == DoorQueryResult.IN_FRONT then 
        return door
    end
    return nil
end

function FindDoor:update(dt)
    super().update(self, dt)
    if iter_size(self.unreachable_doors) == #self.all_doors then
        return true
    end

    if self.target_door and self.goto_target:update(dt) then
        if self:query(self.target_door) == DoorQueryResult.BEHIND then
            -- If we passed through the door then terminate.
            return true
        end
        self.target_door = nil
    end

    if self.target_door == nil then
        self.target_door = self:next_door()
        if self.target_door then
            local cell = self:get_door_cell_to_progress(self.target_door, self.state)
            self.goto_target = Goto.new(
                (cell.x) * self.state.level.cell_length_pixels,
                (cell.y) * self.state.level.cell_length_pixels,
                2
            )
            self.goto_target:start(self.entity, self.state)
        end
    end

    return false
end

function FindDoor:get_door_cell_to_progress(door, state)
    if self.state.escaping then
        return door:cell_before(state)
    else
        return door:cell_after(state)
    end
end

function FindDoor:query(door)
    local e_cell = Cell.new(self.state.level:cell(self.entity.x, self.entity.y))
    local d_cell = Cell.new(door.x, door.y)
    local path_to_door = astar.path(
        e_cell,
        d_cell,
        self.entity:accessible_cells(self.state) - self.door_cells,
        false
    )
    if not path_to_door or #path_to_door < 2 then
        return DoorQueryResult.UNREACHABLE
    end

    local in_front_behind = function(x)
        if x then
            return DoorQueryResult.IN_FRONT
        else
            return DoorQueryResult.BEHIND
        end
    end

    -- Compare direction of last step of path to door with door direction.
    local p_cell = path_to_door[#path_to_door - 1]
    local d = Vector.new(p_cell.x, p_cell.y, d_cell.x, d_cell.y)
    if self.state.escaping then
        if door.facing_rev == Direction.RIGHT then
            return in_front_behind(d:dx() < 0)
        elseif door.facing_rev == Direction.UP then
            return in_front_behind(d:dy() > 0)
        elseif door.facing_rev == Direction.LEFT then
            return in_front_behind(d:dx() > 0)
        else
            return in_front_behind(d:dy() < 0)
        end
    else
        if door.facing == Direction.RIGHT then
            return in_front_behind(d:dx() > 0)
        elseif door.facing == Direction.UP then
            return in_front_behind(d:dy() < 0)
        elseif door.facing == Direction.LEFT then
            return in_front_behind(d:dx() < 0)
        else
            return in_front_behind(d:dy() > 0)
        end
    end
end

function FindDoor:draw()
    super().draw(self)
    if self.goto_target then
        self.goto_target:draw()
    end

    -- if self.target_door then
    --     love.graphics.setColor({0, 0, 1, 1})
    --     love.graphics.rectangle("fill", self.target_door.x * self.state.level.cell_length_pixels + 2, self.target_door.y * self.state.level.cell_length_pixels + 2, 12, 12)
    -- end
end
