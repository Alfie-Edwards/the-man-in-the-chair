require "behaviours.behaviour"
require "entities.door"

GotoTarget = {
    target = nil,
}
setup_class(GotoTarget, Goto)

function GotoTarget:__init(state, target)
    super().__init(self, state, target.x, target.y)
    self.target = target
end

function GotoTarget:start(entity)
    super().start(self, entity)
end

function GotoTarget:refresh_path()
    self.x = self.target.x
    self.y = self.target.y
    super().start(self, self.entity)
end

function GotoTarget:dist_to_target()
    return dist(self.entity.x, self.entity.y, self.target.x, self.target.y)
end

function GotoTarget:dist_to_dest()
    return dist(self.entity.x, self.entity.y, self.x, self.y)
end

function GotoTarget:dist_dest_to_target()
    return dist(self.x, self.y, self.target.x, self.target.y)
end

function GotoTarget:update(dt)
    local dist_to_target = self:dist_to_target()
    if dist_to_target < 0.5 then
        return true
    end

    if dist_to_target < self:dist_dest_to_target() then
        -- Walking to the dest will take us further from the target.
        self:refresh_path()
    end

    if super().update(self, dt) then
        if self:dist_to_dest() < 0.5 then
            self:refresh_path()
        else
            -- Goto terminated without reaching the dest. Must be unpathable.
            return true
        end
    end
    return false
end