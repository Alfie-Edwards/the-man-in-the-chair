require "behaviours.loop"
require "behaviours.turn"
require "behaviours.wait"

Sweep = {}
setup_class(Sweep, Loop)

function Sweep.new(angle, sweep, wait_time)
    local obj = magic_new(
        Turn.new(angle - sweep / 2),
        Wait.new(wait_time),
        Turn.new(angle + sweep / 2),
        Wait.new(wait_time)
    )

    return obj
end
