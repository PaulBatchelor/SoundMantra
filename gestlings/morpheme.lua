local M = {}
function gcd(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

function lcm(m, n)
    return (m ~= 0 and n ~= 0) and
        m * n / gcd(m, n) or 0
end
function M.morpheme(m, r)
    -- Get lengths of each gesture path
    local lengths = {}

    for k, v in pairs(m) do
        lengths[k] = 0
        for _,x in pairs(v) do
            lengths[k] = lengths[k] + x[2]
        end
    end

    -- Find LCM of path lengths

    length_lcm = 0

    for _, v in pairs(lengths) do
        if length_lcm ~= 0 then
            length_lcm = lcm(length_lcm, v)
        else
            length_lcm = v
        end

    end

    out = {}

    -- rescale paths

    for k, v in pairs(m) do
        local s = length_lcm / lengths[k]
        local row = {}
        for i=1,#v do
            row[i] = {v[i][1], v[i][2]*s, v[i][3]}
        end
        out[k] = row
    end

    -- convert to rate multiplier

    for k,v in pairs(out) do
        -- out[k][2] = {length_lcm, out[k][2]}
        for i=1,#v do
            -- apply scaling value r and obtain multipler

            local num = length_lcm * r[1]
            local den = v[i][2] * r[2]

            -- simplify multiplier fractions, if possible

            local div = gcd(num, den)
            if div == 0 then div = 1 end

            num = num / div
            den = den / div

            -- make sure multiplier values are in range

            if (num > 255 or den > 255) then
                error(string.format(
                    "%s[%d]: multiplier (%d, %d) out of range",
                    k, i, num, den))
            end
            v[i][2] = {num, den}
        end
    end


    return out
end
function append_op(path, m, mp)
    for pname, p in pairs(m) do
        if mp[pname] == nil then
            mp[pname] = {}
        end
        for k, v in pairs(p) do
            table.insert(mp[pname], path.vertex(v))
        end
    end
end

function M.append(path, mp, r, m)
    append_op(path, M.morpheme(m, r), mp)
end

function M.appender(path)
    return function(mp, r, m)
        M.append(path, mp, r, m)
    end
end
function M.compile(tal, path, words, mp, head, lookup)
    head = head or {}
    for label, p in pairs(mp) do
        tal.label(words, label)
        if head[label] ~= nil then
            head[label](words)
        end
        lookup = lookup or nil
        path.path(tal, words, p, lookup)
        tal.jump(words, label)
    end
end

function M.compile_noloop(tal, path, words, mp, head, lookup, multilut)
    head = head or {}
    multilut = multilut or {}
    for label, p in pairs(mp) do
        tal.label(words, label)
        if head[label] ~= nil then
            head[label](words)
        end
        local lut = multilut[label] or lookup
        path.path(tal, words, p, lut)
        tal.jump(words, "hold")
    end
end
function M.articulate(path, tal, words, seq, head)
    local mp = {}

    for _,s in pairs(seq) do
        M.append(path, mp, s[2], s[1])
    end


    M.compile(tal, path, words, mp, head)
end
function M.template(m)
    return function(p)
        local o = {}
        for k,v in pairs(m) do
            o[k] = p[k] or v
        end
        return o
    end
end
function M.subset(m, a)
    local o = {}

    for _,v in pairs(a) do
        if m[v] == nil then
            error("Attribute '" .. v .. "' doesn't exist.")
        end
        o[a] = m[a]
    end

    return o
end
function M.merge(A, B)
    local o = {}

    for k,v in pairs(A) do
        o[k] = v
    end

    for k,v in pairs(B) do
        o[k] = v
    end

    return o
end
function M.morpheme_to_data(path, morpheme)
    local morpheme_data = {}

    for k,v in pairs(morpheme) do
        morpheme_data[k] = path.path_to_data(v)
    end

    return morpheme_data
end

function M.save(asset, path, morpheme, filename)
    asset:save(M.morpheme_to_data(path, morpheme), filename)
end

function M.load(asset, path, filename)
    local morpheme_data = asset:load(filename)

    local morpheme = {}

    for k, v in pairs(morpheme_data) do
        morpheme[k] = path.data_to_path(v)
    end
    -- local gpath = {}
    -- for _,v in pairs(path_data) do
    --     table.insert(gpath, Path.vertex(v))
    -- end

    return morpheme
end
return M
