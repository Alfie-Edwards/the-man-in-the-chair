require "behaviours.behaviour"
require "behaviours.a-star"
Goto = {
    x = nil,
    y = nil,
    i = nil,
    path = nil,
}
setup_class(Goto, Behaviour)

function Goto.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y

    return obj
end

function Goto:start(entity, state)
    super().start(self, entity, state)
    self.path = self:pathfind()
    self.i = 1
end

function Goto:update(dt)
    if not self.path then
        return true
    end

    local speed = self.entity.speed * dt
    local px = (self.path[self.i].x + 0.5) * self.state.level.cell_length_pixels
    local py = (self.path[self.i].y + 0.5) * self.state.level.cell_length_pixels
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
    end
end

function Goto:pathfind()
    return astar.path(
        Cell.new(self.state.level:cell(self.entity.x, self.entity.y)),
        Cell.new(self.state.level:cell(self.x, self.y)),
        self.entity:accessible_cells(self.state),
        true
    )
end