require "behaviours.loop"
require "behaviours.turn"
require "behaviours.wait"
require "behaviours.investigate"

Sweep = {}
setup_class(Sweep, Loop)

function Sweep.new(angle, sweep, wait_time, sweep_speed)
    local obj = magic_new(
        Turn.new(angle - sweep / 2, sweep_speed),
        Wait.new(wait_time),
        Turn.new(angle + sweep / 2, sweep_speed),
        Wait.new(wait_time)
    )

    return obj
end
