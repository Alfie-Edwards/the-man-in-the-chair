require "behaviours.sequence"
require "behaviours.goto"
require "behaviours.look_around"
require "behaviours.wait"

Investigate = {}
setup_class(Investigate, Sequence)

function Investigate:__init(state, x, y, r, n, t)
    super().__init(self,
        state,
        Goto(state, x, y),
        Wait(state, t),
        LookAround(state, x, y, r, n, t)
    )
end
