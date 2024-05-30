require "behaviours.sequence"
require "behaviours.goto"
require "behaviours.wait"

LookAround = {}
setup_class(LookAround, Sequence)

function LookAround:__init(state, x, y, r, n, t)
    local sub_behaviours = {}
    for i = 1, n do
        local angle = math.pi * 2 * love.math.random()
        local dist = r * math.sqrt(love.math.random())
        sub_behaviours[2 * i - 1] = Goto(
            state,
            x + math.cos(angle) * dist,
            y + math.sin(angle) * dist
        )
        sub_behaviours[2 * i] = Wait(state, t)
    end
    super().__init(self, state, unpack(sub_behaviours))
end
