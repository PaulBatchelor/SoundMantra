local Path = {}
function Path.vertex(v)
    x = {}

    x.val = v[1]
    x.dur = v[2]
    x.bhvr = v[3]

    return x
end
function Path.path(tal, words, path, lookup)
    for _, v in pairs(path)
    do
        assert(v.val ~= nil)
        if v.val ~= nil then
            local pathval = v.val

            if lookup ~= nil and type(pathval) == "string" then
                local pathkey = pathval
                pathval = lookup[pathkey]
                assert(pathval ~= nil, "Could not find value for '" .. pathkey .. "'")
            end

            tal.val(words, pathval)
        end

        if v.dur ~= nil then
            tal.dur(words, v.dur[1], v.dur[2])
        end

        if v.bhvr ~= nil then
            tal.behavior(words, v.bhvr)
        end
    end
end

function Path.save(asset, gpath, filename)
    asset:save(gpath, filename)
end

function Path.load(asset, filename)
    local path_data = asset:load(filename)

    return Path.data_to_path(path_data)
end
function Path.data_to_path(path_data)
    local gpath = {}
    for _,v in pairs(path_data) do
        table.insert(gpath, Path.vertex(v))
    end
    return gpath
end

function Path.path_to_data(path)
    local path_data = {}
    for _,v in pairs(path) do
        table.insert(path_data, {
            v.val,
            v.dur,
            v.bhvr,
        })
    end

    return path_data
end
function Path.AST_to_data(t)
    behaviors = {
        linear = 0,
        step = 1,
        gliss_medium = 2,
        gliss_large = 3,
        gliss_small = 4,
    }

    local ratemul = {1, 1}
    local behavior = behaviors["linear"]
    local gpath = {}

    for _,v in pairs(t) do
        local val = tonumber("0x" .. v.value[1] .. v.value[2])
        if v.behavior ~= nil then
            behavior = behaviors[v.behavior]
        end

        if v.ratemul ~= nil then
            if #v.ratemul == 2 then
                local num, den
                num = v.ratemul[1]
                num = tonumber("0x" .. num[1] .. num[2])
                den = v.ratemul[2]
                den = tonumber("0x" .. den[1] .. den[2])
                ratemul = {num, den}
            elseif #v.ratemul == 1 then
                local num, den
                num = v.ratemul[1]
                num = tonumber("0x" .. num[1] .. num[2])
                ratemul = num
            end
        end
        local vertex = {
            val,
            ratemul,
            behavior
        }
        table.insert(gpath, vertex)
    end
    return gpath
end
local function gcd(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

local function lcm(m, n)
    return (m ~= 0 and n ~= 0) and
        m * n / gcd(m, n) or 0
end

local function fracadd(a, b)
    if a[2] == 0 then return b end
    if b[2] == 0 then return a end
    local s = lcm(a[2], b[2])
    local as = s / a[2]
    local bs = s / b[2]
    return {as*a[1] + bs*b[1], s}
end

local function reduce(a)
    out = a
    local s = gcd(out[1], out[2])

    if (s ~= 0) then
        out[1] = out[1] / s
        out[2] = out[2] / s
    end

    return out
end

function fracmul(a, b)
    local out = {a[1]*b[1], a[2]*b[2]}

    return reduce(out)
end

-- local function morphseq_dur_old(mseq)
--     error("old morseq_dur")
--     local total = {0, 0}
--     for _, m in pairs(mseq) do
--         local r = m[2]
--         total = fracadd(total, r)
--     end
--     -- r is a ratemultiplier against a normalize
--     -- path with dur 1. 2/1 is 2x faster, or dur 1/2.
--     -- inverse to get duration
--     -- this can be multiplied with normalized path
--     -- to stretch/squash it out
--     return {total[2], total[1]}
-- end

local function morphseq_dur(mseq)
    local total = {0, 0}
    for _, m in pairs(mseq) do
        local r = m[2]
        local dur = {r[2], r[1]}
        total = fracadd(total, dur)
    end

    return total
end

-- TODO move this to morpheme

function Path.fracmul(a, b)
    return fracmul(a, b)
end

function Path.morphseq_dur(mseq)
    return morphseq_dur(mseq)
end

local function path_normalizer(p)
    local total = 0

    for _, v in pairs(p) do
        total = total + v[2]
    end

    return {total, 1}
end

local function apply_ratemul(p, r, vertexer)
    path_with_ratemul = {}

    for _,v in pairs(p) do
        local new_rate = reduce({r[1], v[2]*r[2]})
        assert(new_rate[1] <= 0xFF,
            "rate multiplier numerator too high: " .. new_rate[1])
        assert(new_rate[2] <= 0xFF,
            "rate multiplier denominator too high" .. new_rate[2])
        local v_rm = {
            v[1],
            new_rate,
            v[3]
        }
        table.insert(path_with_ratemul, vertexer(v_rm))
    end

    return path_with_ratemul
end
function Path.scale_to_morphseq(gpath, mseq)
    local seqdur = morphseq_dur(mseq)
    local pnorm = path_normalizer(gpath)
    local total_ratemul = fracmul(pnorm, seqdur)
    local gpath_rescaled =
        apply_ratemul(gpath, total_ratemul, Path.vertex)

    return gpath_rescaled
end
return Path
