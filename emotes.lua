require "sprite"

Emote = {
    DURATION = 0.15,

    sprite_set = nil,
    t0 = nil,
}

setup_class(Emote)

function Emote:__init(sprite_set)
    super().__init(self)

    self.sprite_set = sprite_set
    self.t0 = t_now()
end

function Emote:draw(x, y)
    local sprite = sprite.sequence(self.sprite_set, Emote.DURATION, self.t0)
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.draw(sprite,
                       x - sprite:getWidth() / 2,
                       y - sprite:getHeight() / 2,
                       0, 1, 1)
end

ExclaimationEmote = {
    SPRITE = sprite.make_set("Sprites/", {
            "BlipExclaim1",
            "BlipExclaim2",
            "BlipExclaim3",
            "BlipExclaim4",
            "BlipExclaim5",
            "BlipExclaim6",
            "BlipExclaim7",
            "BlipExclaim8",
        }
    )
}

setup_class(ExclaimationEmote, Emote)

function ExclaimationEmote:__init()
    super().__init(self, ExclaimationEmote.SPRITE)
end

QuestionEmote = {
    SPRITE = sprite.make_set("Sprites/", {
            "BlipQuestion1",
            "BlipQuestion2",
            "BlipQuestion3",
            "BlipQuestion4",
            "BlipQuestion5",
            "BlipQuestion6",
            "BlipQuestion7",
            "BlipQuestion8",
        }
    )
}

setup_class(QuestionEmote, Emote)

function QuestionEmote:__init()
    super().__init(self, QuestionEmote.SPRITE)
end
