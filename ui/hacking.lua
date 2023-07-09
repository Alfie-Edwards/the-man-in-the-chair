require "ui.element"
require "ui.image"
require "ui.image_button"

Hacking = {
    MAX_POINTS = 3,

    POINTS_INSET_X = 20,
    POINTS_INSET_Y = 20,

    POINT_ICON_SIZE_SCALE = 2,
    POINT_ICON_SPACING = 2,
    POINT_ICON_INSET_Y = 4,

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

    -- hacking icons over each door
    for _,ntt in ipairs(obj.state.entities) do
        if is_type(ntt, Door) then
            local hack_door_button = ImageButton.new()
            local pos = ntt:pixel_pos(obj.state)

            hack_door_button:set_properties({
                image = assets:get_image("ui/Hack1"),
                image_data = assets:get_image_data("ui/Hack1"),
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

    -- points background banner
    local points_bg = Image.new()
    local points_bg_img = assets:get_image("ui/HackBG")
    local points_bg_width = points_bg_img:getWidth() * Hacking.POINT_ICON_SIZE_SCALE
    local points_bg_aspect = points_bg_img:getHeight() / points_bg_img:getWidth()
    points_bg:set_properties({
        image = points_bg_img,
        image_data = assets:get_image_data("ui/HackBG"),
        x_align = "left",
        y_align = "top",
        x = Hacking.POINTS_INSET_X,
        y = Hacking.POINTS_INSET_Y,
        width = points_bg_width,
        height = points_bg_width * points_bg_aspect,
    })
    obj:add_child(points_bg)

    -- individual point icons
    local point_img = assets:get_image("ui/Hack1")
    local point_img_width = point_img:getWidth() * Hacking.POINT_ICON_SIZE_SCALE
    local point_img_aspect = point_img:getHeight() / point_img:getWidth()
    -- horizontally centre the list of points over the background image
    local total_points_width = point_img_width * Hacking.MAX_POINTS +
                               Hacking.POINT_ICON_SPACING * (Hacking.MAX_POINTS - 1)
    local centring_adjustment = Hacking.POINTS_INSET_X +
                                (points_bg_width / 2) -
                                (total_points_width / 2)

    for i=1,Hacking.MAX_POINTS do
        local point_icon = Image.new()
        point_icon:set_properties({
            image = img,
            image_data = assets:get_image_data("ui/Hack1"),
            x_align = "left",
            y_align = "top",
            x = centring_adjustment + (i - 1) * (point_img_width + Hacking.POINT_ICON_SPACING),
            y = Hacking.POINTS_INSET_Y + Hacking.POINT_ICON_INSET_Y,
            width = point_img_width,
            height = point_img_width * point_img_aspect,
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
        image = assets:get_image("ui/Hack2"),
        image_data = assets:get_image_data("ui/Hack2"),
    })

    self.points = self.points - 1

    return true
end

function Hacking:restore_point()
    self.points = math.min(self.points + 1, Hacking.MAX_POINTS)

    self.point_icons[self.points]:set_properties({
        image = assets:get_image("ui/Hack1"),
        image_data = assets:get_image_data("ui/Hack1"),
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
