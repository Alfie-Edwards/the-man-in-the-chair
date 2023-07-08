require "ui.element"
require "ui.image"
require "ui.image_button"

Hacking = {
    MAX_POINTS = 3,

    POINT_ICON_INSET_X = 20,
    POINT_ICON_INSET_Y = 20,
    POINT_ICON_SIZE_PX = 32,
    POINT_ICON_SPACING = 10,

    state = nil,

    points = nil,
    door_map = {},
    point_icons = {},
}
setup_class(Hacking, Element)

function Hacking.new(state)
    local obj = magic_new()

    obj.state = state

    obj.points = Hacking.MAX_POINTS

    for _,ntt in ipairs(obj.state.entities) do
        if is_type(ntt, Door) then
            local hack_door_button = ImageButton.new()
            local pos = ntt:pixel_pos(obj.state)

            hack_door_button:set_properties({
                image = assets:get_image("ui/HackGreen"),
                image_data = assets:get_image_data("ui/HackGreen"),
                x_align = "left",
                y_align = "bottom",
                x = pos.x - obj.state.camera.x,
                y = pos.y - obj.state.camera.y,
                click = function()
                    obj:toggle_door(ntt)
                end,
            })
            obj:add_child(hack_door_button)

            obj.door_map[ntt] = hack_door_button
        end
    end

    for i=1,Hacking.MAX_POINTS do
        local point_icon = Image.new()
        local img = assets:get_image("ui/HackGreen")
        point_icon:set_properties({
            image = img,
            image_data = assets:get_image_data("ui/HackGreen"),
            x_align = "left",
            y_align = "top",
            x = Hacking.POINT_ICON_INSET_X + (i - 1) * (Hacking.POINT_ICON_SIZE_PX + Hacking.POINT_ICON_SPACING),
            y = Hacking.POINT_ICON_INSET_Y,
            width = Hacking.POINT_ICON_SIZE_PX,
            height = Hacking.POINT_ICON_SIZE_PX,
        })
        obj:add_child(point_icon)

        table.insert(obj.point_icons, point_icon)
    end

    return obj
end

function Hacking:use_point()
    if self.points == 0 then
        return false
    end

    self.point_icons[self.points]:set_properties({
        image = assets:get_image("ui/HackGrey"),
        image_data = assets:get_image_data("ui/HackGrey"),
    })

    self.points = self.points - 1

    return true
end

function Hacking:restore_point()
    self.points = math.min(self.points + 1, Hacking.MAX_POINTS)

    self.point_icons[self.points]:set_properties({
        image = assets:get_image("ui/HackGreen"),
        image_data = assets:get_image_data("ui/HackGreen"),
    })

end

function Hacking:toggle_door(door)
    if door:is_transitioning() then
        return
    end

    if door.state == DoorState.CLOSED then
        if self:use_point() then
            door:toggle()
        end
    else
        door:toggle()
        self:restore_point()
    end
end

function Hacking:update(dt)
    for door, button in pairs(self.door_map) do
        local pos = door:pixel_pos(self.state)
        button:set_properties({
            x = pos.x - self.state.camera.x,
            y = pos.y - self.state.camera.y,
        })
    end
end
