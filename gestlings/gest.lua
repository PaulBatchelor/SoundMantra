Gest = {}
Gest.behavior = {
    linear = 0,
    step = 1,
    gliss_medium = 2,
    gliss = 3,
    gate_125 = 4,
    gate_25 = 5,
    gate_50 = 6,
    exp_convex_low = 7,
    exp_convex_high = 8,
    exp_concave_low = 9,
    exp_concave_high = 10,
}
function Gest:new(o)
    o = o or {}
    o.name = o.name or "glive"
    o.bufname = o.bufname or "mem"
    o.tal = o.tal or tal
    assert(o.tal ~= nil, "tal not found")
    setmetatable(o, self)
    self.__index = self
    return o
end
function Gest:create()
    lil("glnew " .. self.name)
    self.tal.membuf(self.bufname)
end
function Gest:compile(words)
    self.tal.compile_words(words,
        self.bufname,
        string.format("[glget [grab %s]]", self.name))
end
function Gest:compile_tal(program)
    self.tal.compile(program,
        self.bufname,
        string.format("[glget [grab %s]]", self.name))
end
function Gest:swapper()
    lil(string.format("glswapper [grab %s]", self.name))
end
function Gest:done()
    lil(string.format("gldone [grab %s]", self.name))
end
function Gest:get()
    return string.format("[glget [grab %s]]", self.name)
end
function Gest:node_old(program, conductor)
    local cnd = conductor or self.conductor
    if cnd == nil then
        error("conductor signal not defined")
    end

    lil(string.format(
        "gestvmnode %s [gmemsym [grab %s] %s] %s",
        self.get(self), self.bufname, program, cnd))
end
function Gest:nodestring(program, conductor)
    local cnd = conductor or self.conductor
    if cnd == nil then
        error("conductor signal not defined")
    end

    local s = string.format(
        "gestvmnode %s [gmemsym [grab %s] %s] %s",
        self.get(self), self.bufname, program, cnd)

    return s
end
function Gest:node()
	local glive = self.get(self)
	local mem = self.bufname
	local glivef =  function(self) return glive end
	local cndstr = self.conductor

    return function(n, p)
        local name = p.name or "gst"
        local program =
            string.format("[gmemsym [grab %s] %s]", mem, name)

        -- TODO: glivef makes this work as a regular node
        -- glive works as only a parameter node. Tests
        -- will break if glivef is used
        -- The quick fix is to just introduce a flag
        local is_param_node = n.sigrune_dummy or false
        if is_param_node then
            n.glive = n:param(glive)
        else
            n.glive = n:param(glivef)
        end

        n.conductor = n:param(p.conductor or cndstr)

        if p.extscale ~= nil then
            n.extscale = n:param(p.extscale)
            n:lil({"gestvmnode", "zz", program, "zz", "zz"})
        else
            n:lil({"gestvmnode", "zz", program, "zz"})
        end

        n:label("gesture: " .. name)
    end
end
function Gest.gest16fun(sr, core)
    return function (gst, name, cnd, mn, mx)
        local pn = sr.paramnode
        local lvl = core.liln

        local node = pn(sr.scale) {
            input = pn(sr.mul) {
                a = pn(gst:node()) {
                    name = name,
                    conductor = lvl(cnd:getstr())
                },
                b = 1.0 / 16.0
            },
            min = mn,
            max = mx
        }

        return node
	end
end
function Gest:gmemsymstr(symbol)
	local mem = self.bufname
    local program = 
        string.format("gmemsym [grab %s] %s", mem, symbol)
    return program
end
return Gest
