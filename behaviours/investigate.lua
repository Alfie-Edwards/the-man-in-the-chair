require "behaviours.sequence"
require "behaviours.goto"
require "behaviours.look_around"
require "behaviours.wait"

Investigate = {}
setup_class(Investigate, Sequence)

function Investigate.new(x, y, r, n, t)
    local obj = magic_new(
        Goto.new(x, y),
        Wait.new(t),
        LookAround.new(x, y, r, n, t)
    )

    return obj
end
