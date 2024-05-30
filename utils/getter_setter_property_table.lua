GetterSetterPropertyTable = {
    -- An object where anything with a getter and/or setter is a property.
    -- Having only a getter will make the property read (errors on write).
}
setup_class(GetterSetterPropertyTable, PropertyTable)

function GetterSetterPropertyTable:__init()
    super().__init(self)
end

function GetterSetterPropertyTable:__get_property_names()
    -- Override __get_property_names to include everything with a getter and/or setter so that unset properties show up in iteration.
    local result = {}
    for name, _ in pairs(self:_get_getters()) do
        result[name] = true
    end
    for name, _ in pairs(self:_get_setters()) do
        result[name] = true
    end
    return result
end

function GetterSetterPropertyTable:__is_property(name)
    -- Override __is_property to count only things with a getter and/or setter.
    return (self:_get_getter(name) ~= nil) or (self:_get_setter(name) ~= nil)
end

function GetterSetterPropertyTable:__set_property(name, value, properties_closure)
    -- Override __get_property error on unknowns.

    if self:_get_setter(name) == nil then
        error("Property \""..name.."\" of "..type_string(self).." is read-only (no setter defined).")
    end
    return PropertyTable.__set_property(self, name, value, properties_closure)
end

