require "behaviours.behaviour"
require "entities.door"

FindDoor = {
    door_cells = nil,
    checked_doors = nil,
    accessible_doors = nil,
    goto_target = nil,
    target_door = nil,
}
setup_class(FindDoor, Behaviour)

function FindDoor.new()
    local obj = magic_new()

    return obj
end

function FindDoor:start(entity, state)
    super().start(self, entity, state)

    self:update_door_cells()

    self.accessible_doors = {}
    self.unchecked_doors = {}
    for _, door in ipairs(state.entities) do
        if is_type(door, "Door") then
            if self:door_progresses(door) then
                self.accessible_doors[door] = true
            end
        end
    end


    self.target_door = self:next_door()
    if self.target_door ~= nil then
        self.goto_target = Goto.new(
            self.target_door.x,
            self.target_door.y,
            3 * self.state.level.cell_length_pixels
        )
        self.goto_target:start(self.entity, self.state)
    end
end

function FindDoor:next_door()
    if #self.accessible_doors == 0 then
        return nil
    end

    if #self.checked_doors == #self.accessible_doors then
        self.checked_doors = {}
        if #self.accessible_doors > 1 and self.target_door then
            self.checked_doors[door] = true
        end
    end

    local closest = nil
    local closest_dist = math.huge
    for door, _ in pairs(self.accessible_doors) do
        if not self.checked_doors[door] then
            local path_through_door = astar.path(
                Cell.new(state.level:cell(entity.x, entity.y)),
                self:get_door_cell_to_progress(door),
                entity:accessible_cells(state) - self.door_cells,
                false
            )
            if path_through_door and #path_through_door < closest_dist then
                closest = door
                closest_dist = #path_through_door
            end
        end
    end
    return closest
end

function FindDoor:update(dt)
    super().update(self, dt)

    if self.target_door == nil then
        return true
    end

    if self.goto_target:update(dt) then
        if not self:door_progresses(self.target_door) then
            -- If we passed through the door (it no longer progresses) then terminate.
            return true
        end
        self.checked_doors[door] = true
        self.target_door = self:next_door()
        if self.target_door == nil then
            return true
        end
        self.goto_target = Goto.new(
            self.target_door.x,
            self.target_door.y,
            3 * self.state.level.cell_length_pixels
        )
        self.goto_target:start(self.entity, self.state)
    end

    return false
end

function FindDoor:get_door_cell_to_progress(door)
    if self.state.escaping then
        return door:cell_before()
    else
        return door:cell_after()
    end
end

function FindDoor:door_progresses(door)
    local e_cell = Cell.new(self.state.level:cell(self.entity.x, self.entity.y))
    local d_cell = Cell.new(door.x, door.y)
    local path_to_door = astar.path(
        e_cell,
        d_cell,
        self.entity:accessible_cells(self.state) - self.door_cells + door:active_cells(),
        false
    )
    if not path_to_door or #path_to_door < 2 then
        return false
    end

    -- Compare direction of last step of path to door with door direction.
    local p_cell = path_to_door[#path_to_door - 1]
    local d = Vector.new(p_cell.x, p_cell.y, d_cell.x, d_cell.y)
    if self.state.escaping then
        if door.facing == Direction.RIGHT then
            return d:dx() < 0
        elseif door.facing == Direction.UP then
            return d:dy() > 0
        elseif door.facing == Direction.LEFT then
            return d:dx() > 0
        else
            return d:dy() < 0
        end
    else
        if door.facing == Direction.RIGHT then
            return d:dx() > 0
        elseif door.facing == Direction.UP then
            return d:dy() < 0
        elseif door.facing == Direction.LEFT then
            return d:dx() < 0
        else
            return d:dy() > 0
        end
    end
end

function FindDoor:update_door_cells(door)
    -- Enumerate door cells for pathfinding.
    self.door_cells = HashSet.new()
    for _, door in ipairs(self.state.entities) do
        if is_type(door, "Door") then
            for _, c in ipairs(door:active_cells()) do
                self.door_cells:add(c)
            end
        end
    end
end

function FindDoor:draw()
    super().draw(self)
    if self.goto_target then
        self.goto_target:draw()
    end
end

