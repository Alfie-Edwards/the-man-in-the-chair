Alarm = {
    is_on = false
}
setup_class(Alarm)

function Alarm.new(mode)
    local obj = magic_new()

    return obj
end

function Alarm:on()
    self.is_on = true
end

function Alarm:off()
    self.is_on = false
end
