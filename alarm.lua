Alarm = {
    is_on = false
}
setup_class(Alarm)

function Alarm:__init(mode)
    super().__init(self)
end

function Alarm:on()
    self.is_on = true
end

function Alarm:off()
    self.is_on = false
end
