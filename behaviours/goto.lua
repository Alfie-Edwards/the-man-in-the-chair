require "behaviours.behaviour"
require "behaviours.a-star"
Goto = {
    x = nil,
    y = nil,
}
setup_class(Goto, Behaviour)

function Goto.new(x, y)
    local obj = magic_new()

    obj.x = x
    obj.y = y

    return obj
end

function Goto:update(entity, dt, state)
    local path=self:pathfind(entity, state)
    local d = {}
    if not path then
        return true
    elseif #path==1 then
        d = Vector.new(entity.x, entity.y, (path[1].x+0.5)*state.level.cell_length_pixels, (path[1].y+0.5)*state.level.cell_length_pixels)
    else
        d = Vector.new(entity.x, entity.y, (path[2].x+0.5)*state.level.cell_length_pixels, (path[2].y+0.5)*state.level.cell_length_pixels)
    end  
    local sql = d:sq_length()
    if sql <= (entity.speed * entity.speed) and #path==1 then
        entity.x = self.x
        entity.y = self.y
        return true
    else
        local l = sql ^ (1 / 2)
        entity.x = entity.x + d:dx() * entity.speed / l
        entity.y = entity.y + d:dy() * entity.speed / l
        return false
    end
end

function Goto:draw(entity, state)
    local path=self:pathfind(entity,state)
    if path then
        for i , node in ipairs(path) do
            if i~=1 then
                love.graphics.line((node.x+0.5)*state.level.cell_length_pixels,(node.y+0.5)*state.level.cell_length_pixels,(path[i-1].x+0.5)*state.level.cell_length_pixels,(path[i-1].y+0.5)*state.level.cell_length_pixels)
            end
        end
    end
end

function Goto:pathfind(entity,state)
    local valid_node_func = function ( node, neighbor ) 
        local nodeDist = state.level.cell_length_pixels
        -- helper function in the a-star module, returns distance between points
        if astar.distance ( node.x, node.y, neighbor.x, neighbor.y ) <= nodeDist then
            return true
        end
        return false
    end
    local ignore = true
    local path = astar.path (Cell.new(state.level:cell(entity.x,entity.y)), Cell.new(state.level:cell(self.x,self.y)), state.level.cells-state.level.solid_cells, ignore, valid_node_func )
    if path then
        return path
    end
end