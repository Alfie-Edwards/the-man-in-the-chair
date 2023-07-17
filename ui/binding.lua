BindingMode = Enum.new("ONE_WAY", "TWO_WAY")

Binding = {
    src = nil,
    src_prop = nil,
    dst = nil,
    dst_prop = nil,
    mode = nil,
    src_handler = nil,
    dst_handler = nil,
}
setup_class(Binding)

function Binding.new(src, src_prop, dst, dst_prop, mode, convert_src_to_dst_fn, convert_dst_to_src_fn)
    local obj = magic_new()

    obj.src = src
    obj.src_prop = src_prop
    obj.dst = dst
    obj.dst_prop = dst_prop

    if obj.mode == BindingMode.ONE_WAY or obj.mode == BindingMode.TWO_WAY then
        if obj.src.property_changed == nil then
            error("src must implement a property_changed event (dst, property_name, old_value, new_value) for binding mode "..obj.mode..".")
        end
        obj.src_handler = function(src, property_name, old_value, new_value)
            if src ~= obj.src or property_name ~= obj.property_name then
                return
            end
            if obj.convert_src_to_dst_fn then
                new_value = obj.convert_src_to_dst_fn(new_value)
            end
            obj.dst[obj.dst_prop] = new_value
        end
        obj.src.property_changed:subscribe(obj.src_handler)
    end

    if obj.mode == BindingMode.TWO_WAY then
        if obj.dst.property_changed == nil then
            error("dst must implement a property_changed event (dst, property_name, old_value, new_value) for binding mode "..obj.mode..".")
        end
        obj.dst_handler = function(dst, property_name, old_value, new_value)
            if dst ~= obj.dst or property_name ~= obj.property_name then
                return
            end
            if obj.convert_dst_to_src_fn then
                new_value = obj.convert_dst_to_src_fn(new_value)
            end
            obj.src[obj.src_prop] = new_value
        end
        obj.dst.property_changed:subscribe(obj.dst_handler)
    end

    return obj
end

function Binding:release()
    self.src.property_changed:unsubscribe(self.src_handler)
    self.dst.property_changed:unsubscribe(self.dst_handler)
end

OneWayBinding = {}

setup_class(OneWayBinding, Binding)

function OneWayBinding.new(src, src_prop, dst, dst_prop, convert_fn)
    local obj = magic_new(src, src_prop, dst, dst_prop, BindingMode.ONE_WAY, convert_fn)
    return obj
end

TwoWayBinding = {}

setup_class(TwoWayBinding, Binding)

function TwoWayBinding.new(src, src_prop, dst, dst_prop, convert_src_to_dst_fn, convert_dst_to_src_fn)
    local obj = magic_new(src, src_prop, dst, dst_prop, BindingMode.TWO_WAY, convert_src_to_dst_fn, convert_dst_to_src_fn)
    return obj
end
