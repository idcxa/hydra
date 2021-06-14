
function Vector()
    local mt = {}
    local function add(a, b)
        local v = new_vector{}
        for l in pairs(a) do v[l] = a[l] + b[l] end
        return v
    end
    local function sub(a, b)
        local v = new_vector{}
        for l in pairs(a) do v[l] = a[l] - b[l] end
        return v
    end
    local function dot(a, b)
        local s = 0
        for l in pairs(a) do s = s + a[l] * b[l] end
        return s
    end
    local function scalar(a, b)
        local v = new_vector{}
        for l in pairs(b) do v[l] = b[l] * a end
        return v
    end
    mt.__mul = dot
    mt.__sub = sub
    mt.__add = add
    mt.__mod = scalar
    function new_vector(t)
        local v = {}
        setmetatable(v, mt)
        for l = 1,3 do v[l] = t[l] end
        return v
    end
    return {new_vector = new_vector}
end

