require "behaviours.loop"
require "behaviours.goto"

Patrol = {}
setup_class(Patrol, Loop)

function Patrol.new(...)
    local gotos = {}
    for i, point in ipairs({...}) do
        gotos[i] = Goto.new(point.x, point.y)
    end
    local obj = magic_new(unpack(gotos))

    return obj
end
