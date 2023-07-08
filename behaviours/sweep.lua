require "behaviours.loop"
require "behaviours.turn"

Sweep = {}
setup_class(Sweep, Loop)

function Sweep.new(angle, sweep)
    local obj = magic_new(
        Turn.new(angle - sweep / 2),
        Turn.new(angle + sweep / 2),
    )

    return obj
end
