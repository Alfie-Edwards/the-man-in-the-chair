require "behaviours.behaviour"

Goto = {
    x = nil,
    y = nil,
    i = nil,
    path = nil,
    lookahead = nil,
}
setup_class(Goto, Behaviour)

function Goto.new(x, y, lookahead)
    local obj = magic_new()

    obj.x = x
    obj.y = y
    obj.lookahead = lookahead or 0

    return obj
end

function Goto:start(entity, state)
    super().start(self, entity, state)
    self.path = self:pathfind()
    self.i = 1
end

function Goto:update(dt)
    super().update(self, dt)
    if not self.path then
        return true
    end

    for lookahead_i = self.i, math.min(self.i + self.lookahead, #self.path) do
        if not self.entity:accessible_cells(self.state):contains(self.path[lookahead_i]) then
            -- If there are solid cells ahead.
            while not self.entity:accessible_cells(self.state):contains(self.path[self.i]) do
                -- Walk back and terminate.
                if self.i == 1 then
                    -- If we find no accessible tiles behind in the path, just terminate.
                    return true
                end
                self.i = self.i - 1
            end

            local path_end = #self.path
            for cull_i = self.i + 1, path_end  do
                -- Cull the end of the path.
                self.path[cull_i] = nil
            end
            self.x = (self.path[self.i].x + 0.5) * self.state.level.cell_length_pixels
            self.y = (self.path[self.i].y + 0.5) * self.state.level.cell_length_pixels
            break
        end
    end

    local speed = self.entity.speed * dt
    local px = (self.path[self.i].x + 0.5) * self.state.level.cell_length_pixels
    local py = (self.path[self.i].y + 0.5) * self.state.level.cell_length_pixels

    if self.i == #self.path then
        px = self.x
        py = self.y
    end

    local d = Vector.new(self.entity.x, self.entity.y, px, py)
    local sql = d:sq_length()

    if sql > 0 then
        if math.abs(d:dx()) > math.abs(d:dy()) then
            if d:dx() < 0 then
                self.entity.direction = Direction.LEFT
            else
                self.entity.direction = Direction.RIGHT
            end
        else
            if d:dy() < 0 then
                self.entity.direction = Direction.UP
            else
                self.entity.direction = Direction.DOWN
            end
        end
    end

    if sql <= (speed * speed) then
        self.entity.x = px
        self.entity.y = py
        if self.i == #self.path then
            return true
        end
        self.i = self.i + 1
    else
        local l = sql ^ (1 / 2)
        self.entity.x = self.entity.x + (d:dx() * speed) / l
        self.entity.y = self.entity.y + (d:dy() * speed) / l
    end

    return false
end

function Goto:draw()
    super().draw(self)

    if self.path then
        love.graphics.line(
            self.entity.x,
            self.entity.y,
            (self.path[self.i].x + 0.5) * self.state.level.cell_length_pixels,
            (self.path[self.i].y + 0.5) * self.state.level.cell_length_pixels
        )
        for i = self.i + 1, #self.path do
            love.graphics.line(
                (self.path[i].x + 0.5) * self.state.level.cell_length_pixels,
                (self.path[i].y + 0.5) * self.state.level.cell_length_pixels,
                (self.path[i - 1].x + 0.5) * self.state.level.cell_length_pixels,
                (self.path[i - 1].y + 0.5) * self.state.level.cell_length_pixels
            )
        end
        love.graphics.setColor({0.2, 0, 0, 1})
        love.graphics.rectangle("fill", self.x - 4, self.y - 4, 8, 8)
    end
end

function Goto:pathfind()
    return astar.path(
        Cell.new(self.state.level:cell(self.entity.x, self.entity.y)),
        Cell.new(self.state.level:cell(self.x, self.y)),
        self.state.level.cells - self.state.level.solid_cells,
        false
    )
end
