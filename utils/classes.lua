_classes = {}
_method_owner_cache = {}

function type_string(inst)
    -- Class instances and LOVE objects have their own type function.
    local type = type(inst)
    if ((type == "table" or type == "userdata") and inst.type ~= nil) then
        return inst:type()
    end
    return type
end

function is_basic_type(inst)
    return value_in(
        type_string(inst),
        {
            "nil",
            "boolean",
            "number",
            "string",
            "userdata",
            "function",
            "thread",
            "table"
        }
    )
end

function is_type(inst, ...)
    for _, t in ipairs({...}) do
        if type(t) ~= "string" then
            -- Handle passing in a raw type.
            t = type_string(t)
        end
        assert(type(t) == "string")
        if is_basic_type(inst) then
            if type(inst) == t then
                return true
            end
        else
            -- Class instances and LOVE objects have their own type function which accounts for inheritance.
            if inst:typeOf(t) then
                return true
            end
        end
    end
    return false
end

function setup_class(class, super)
    -- Setup inheritance and the type/typeof methods from LOVE.
    if (class ~= BaseObjectClass and super == nil) then
        super = BaseObjectClass
    end
    local name = get_key(_G, class)
    setmetatable(class,
        {
            __template = super, -- Custom field.
            __index = super,
            __name = name,
        }
    )
    _classes[class] = true
end

function magic_new(...)
    -- Create an instance of the class this method was called from.class
    -- Args are passed to the super class constructor.
    local class = get_calling_class()
    local inst = nil
    local super = super(class)
    if (super == nil) or (super.new == nil) then
        inst = {}
    else
        inst = super.new(...)
    end

    setup_instance(inst, class)
    return inst
end

function setup_instance(inst, class)
    -- Setup the given table as an instance of the given class.
    assert(class ~= nil)
    assert(type(class) == "table")
    setmetatable(inst, generate_inheritance_metatable(class))
end

function super(class)
    -- Get the super class of the given class.
    -- If called from a class method, the class can be inferred.
    if class == nil then
        class = get_calling_class()
    end
    local mt = getmetatable(class)
    if mt == nil then
        return nil
    end
    return mt.__template
end

function get_calling_class()
    -- Must be called from a class method, returns the class.
    local info = debug.getinfo(3, 'f')
    if _method_owner_cache[info.func] ~= nil then
        return _method_owner_cache[info.func]
    end
    for class, _ in next, _classes, nil do
        for _, v in next, class, nil do
            if v == info.func then
                _method_owner_cache[info.func] = class
                return class
            end
        end
    end
    error("Calling method must be owned by a class which has had `setup_class` called.")
end

function generate_inheritance_metatable(class)
    -- Create a metatable from the metatable values defined in the class and super classes.
    local mt = {}

    if class == nil then
        return mt
    end

    -- Custom value.
    mt.__template = class

    -- Special case for __index.
    mt.__index = function(self, name)
        if class[name] == nil and class.__index ~= nil then
            return class.__index(self, name)
        end
        return class[name]
    end

    for key, value in pairs(class) do
        if type(key) == "string" and #key >= 2 and string.sub(key, 1, 2) == "__" and key ~= "__index" then
            mt[key] = value
        end
    end

    return mt
end

-- Override pairs to iterate over our class hierarchy.
function pairs(target)
    local mt = getmetatable(target)
    if mt == nil or (mt.__pairs == nil and mt.__template == nil) then
        return next, target, nil
    end

    if mt.__pairs ~= nil then
        return mt.__pairs(target)
    end

    local seen = {}
    return function(t, k)
        local v = nil

        while target do
            repeat
                -- Find next entry (new key) in target.
                k, v = next(target, k)
            until k == nil or not seen[k]

            if k ~= nil then
                -- If we found a key, return the pair.
                seen[k] = true
                return k, v
            end

            -- If we did not find a key we are done iterating this target, move onto the next.
            local mt = getmetatable(target)
            if mt == nil then
                target = nil
            else
                target = mt.__template
            end
        end

        -- No more targets, stop iteration.
        return nil, nil
    end, target, nil
end

BaseObjectClass = {}

function BaseObjectClass:type()
    local mt = getmetatable(self)
    if mt ~= nil then
        if mt.__name ~= nil then
            -- Return name directly from mt if this is a class.
            return mt.__name
        end

        if mt.__template ~= nil then
            -- Return name from class' metatable.
            mt = getmetatable(mt.__template)
            if mt ~= nil and mt.__name ~= nil then
                return mt.__name
            end
        end
    end

    error("Could not identify type.")
end

function BaseObjectClass:typeOf(type_name)
    while self do
        if self:type() == type_name then
            return true
        end
        local mt = getmetatable(x)
        if mt == nil then
            return false
        end
        self = mt.__template
    end
    return false
end

setup_class(BaseObjectClass)
