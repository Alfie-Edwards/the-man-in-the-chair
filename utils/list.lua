function list(...)
    return {...}
end

function is_list(x)
    return type(x) == "table" and iter_size(x) == #x
end
