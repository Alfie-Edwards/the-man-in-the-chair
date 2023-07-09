require "behaviours.behaviour"
require "entities.door"

GotoTarget = {
    goto_target = nil,
    target = nil,
}
setup_class(GotoTarget, Behaviour)

function GotoTarget.new()
    local obj = magic_new()

    return obj
end

function GotoTarget:start(entity, state)
    super().start(self, entity, state)

    self:update_door_cells()

    self.unchecked_doors = {}
    for _, door in ipairs(state.entities) do
        if is_type(door, "Door") then
            if self:door_progresses(door) then
                accessible_doors[door] = true
            end
        end
    end
end

function GotoTarget:next_door()
    local closest = nil
    local closest_dist = math.huge
    for door, _ in pairs(self.unchecked_doors) do
        local path_through_door = astar.path(
            Cell.new(state.level:cell(entity.x, entity.y)),
            self:get_door_cell_to_progress(door, self.state),
            entity:accessible_cells(state) - self.door_cells,
            false
        )
        if path_through_door and #path_through_door < closest_dist then
            closest = door
            closest_dist = #path_through_door
        end
    end
    return closest
end

function GotoTarget:update(dt)
    super().update(self, dt)
    if self.target_door == nil then
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
    else if self.goto_target:update(dt) then
        if not self:door_progresses(self.target_door)
            -- If we passed through the door (it no longer progresses) then terminate.
            return true
        end
        self.target_door = nil
        self.goto_target = nil
    end

    return false
end

function GotoTarget:get_door_cell_to_progress(door, state)
    if self.state.escaping then
        return door:cell_before(state)
    else
        return door:cell_after(state)
    end
end

function GotoTarget:door_progresses(door)
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

function GotoTarget:update_door_cells(door)
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

function GotoTarget:draw()
    super().draw(self)
    if self.goto_target then
        self.goto_target:draw()
    end
end

