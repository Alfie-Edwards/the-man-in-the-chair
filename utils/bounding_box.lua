BoundingBox = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
}
setup_class(BoundingBox)

function BoundingBox:__init(x1, y1, x2, y2)
    super().__init(self)
    self.x1 = math.min(x1, x2)
    self.y1 = math.min(y1, y2)
    self.x2 = math.max(x1, x2)
    self.y2 = math.max(y1, y2)
end

function BoundingBox:contains(x, y)
    return (x >= self.x1 and x < self.x2 and y >= self.y1 and y < self.y2)
end

function BoundingBox:width()
    return self.x2 - self.x1
end

function BoundingBox:height()
    return self.y2 - self.y1
end

function BoundingBox:center_x()
    return (self.x2 + self.x1) / 2
end

function BoundingBox:center_y()
    return (self.y2 + self.y1) / 2
end

function BoundingBox:__eq(other)
    if not is_type(other, BoundingBox) then
        return false
    end
    return (other.x1 == self.x1) and
           (other.y1 == self.y1) and
           (other.x2 == self.x2) and
           (other.y2 == self.y2)
end

function BoundingBox:__hash()
    return tostring(self.x1)..","..tostring(self.y1)..","..tostring(self.x2)..","..tostring(self.y2)
end

function BoundingBox:__mul(rhs)
    if type(rhs) == "number" then
        return BoundingBox(self.x1 * rhs, self.y1 * rhs, self.x2 * rhs, self.y2 * rhs)
    elseif is_type(rhs, BoundingBox) then
        if (self.x1 > other.x2) or (other.x1 > self.x2) or
                (self.y1 > other.y2) or (other.y1 > self.y2) then
            return BoundingBox(0, 0, 0, 0)
        end
        return BoundingBox(
            math.max(self.x1, rhs.x1),
            math.max(self.y1, rhs.y1),
            math.min(self.x2, rhs.x2),
            math.min(self.y2, rhs.y2)
        )
    end
    error("Expected rhs to be a BoundingBox or number, got "..details_string(rhs)..".")
end

function draw_bb(bb, color)
    if (color == nil) or (bb == nil) or (color[4] == 0) then
        return
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", bb.x1, bb.y1, bb:width(), bb:height())
end

function draw_bb_outline(bb, color)
    if (color == nil) or (bb == nil) or (color[4] == 0) then
        return
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("line", bb.x1, bb.y1, bb:width(), bb:height())
end
