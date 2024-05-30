require "behaviours.loop"
require "behaviours.turn"
require "behaviours.wait"
require "behaviours.investigate"

Sweep = {}
setup_class(Sweep, Loop)

function Sweep:__init(state, angle, sweep, wait_time, sweep_speed)
    super().__init(self,
        state,
        Turn(state, angle - sweep / 2, sweep_speed),
        Wait(state, wait_time),
        Turn(state, angle + sweep / 2, sweep_speed),
        Wait(state, wait_time)
    )
end
