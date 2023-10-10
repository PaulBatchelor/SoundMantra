Sigrunes = {}

S = Sigrunes

function S.rline(n, p)
    n.min = n:param(p.min or 0)
    n.max = n:param(p.max or 1)
    n.rate = n:param(p.rate or 3)
    n:lil("rline zz zz zz")
    n:label("rline")
end
function S.dblin(n, p)
    n.db = n:param(p.db or 0)
    n:lil("dblin zz")
    n:label("dblin")
end
function S.crossfade(n, p)
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 1)
    n.pos  = n:param(p.pos or 0)
    n:lil({"crossfade", "zz", "zz", "zz"})
    n:label("crossfade")
end
function S.butbp(n, p)
    n.input = n:param(0)
    n.freq = n:param(p.freq or 1000)
    n.bw = n:param(p.bw or 1000)
    n:lil({"butbp", "zz", "zz", "zz"})
    n:label("butbp")
end
function S.mtof(n, p)
    n.input = n:param(p.input or 0)
    n:lil({"mtof", "zz"})
    n:label("mtof")
end
function S.peakeq(n, p)
    n.input = n:param(0)
    n.freq = n:param(p.freq or 1000)
    n.bw = n:param(p.bw or 1000)
    n.gain = n:param(p.gain or 1)
    n:lil("peakeq zz zz zz zz")
    n:label("peakeq")
end
function S.noise(n, p)
    n:lil({"noise"})
    n:label("noise")
end
function S.env(n, p)
    n.trig = n:param(0)
    n.atk = n:param(p.atk or 0.001)
    n.dec = n:param(p.dec or 0.01)
    n.rel = n:param(p.rel or 0.1)
    n:lil("env zz zz zz zz")
    n:label("env")
end
function S.metro(n, p)
    n.rate = n:param(p.rate or 1)
    n:lil("metro zz")
    n:label("metro")
end
function S.releaser(n, p)
    n.cab = p.cab

    n.data.gen = function(self)
        return self.cab:unhold(self.data.g.eval)
    end

    n.data.constant = false
    n:label("releaser")
end
function S.setter(n, p)
    n.input = n:param(0)
    local sig = p.sig
    n.cab = sig:new()

    n.data.gen = function(self)
        return self.cab:hold(self.data.g.eval)
    end

    n.data.constant = false
    n:label("setter")
end
function S.getter(n, p)
    n.cab = p.cab
    n.data.gen = function(self)
        return self.cab:getstr()
    end

    n.data.constant = false
    n:label("getter")
end
function S.scale(n, p)
    n.input = n:param(p.input or 0)
    n.min = n:param(p.min or 0)
    n.max = n:param(p.max or 1)
    n:lil({"scale", "zz", "zz", "zz"})
    n:label("scale")
end
function S.wavout(n, p)
    local file = p.file or "test.wav"
    n.input = n:param(p.input or 0)
    n:lil({"wavout", "zz", file})
    n:label("wavout")
end
function S.biscale(n, p)
    n.input = n:param(p.input or 0)
    n.min = n:param(p.min or 0)
    n.max = n:param(p.max or 1)
    n:lil("biscale zz zz zz")
    n:label("biscale")
end
function S.sine(n, p)
    n.freq = n:param(p.freq or 440)
    n.amp = n:param(p.amp or 0.5)
    n:lil({"sine", "zz", "zz"})
    n:label("sine")
end
function S.sub(n, p)
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
    n:lil("sub zz zz")
    n:label("sub")
end
function S.add(n, p)
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
    n:lil({"add", "zz", "zz"})
    n:label("add")
end
function S.mul(n, p)
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
    n:lil({"mul", "zz", "zz"})
    n:label("mul")
end
function S.blsquare(n, p)
    n:lil("blsquare zz")
    n.freq = n:param(p.freq or 440)
    n:label("blsquare")
end
function S.blsaw(n, p)
    n.freq = n:param(p.freq or 440)
    n:lil("blsaw zz")
    n:label("blsaw")
end
function S.butlp(n, p)
    n.input = n:param(0)
    n.cutoff = n:param(p.cutoff or 1000)
    n:lil({"butlp", "zz", "zz"})
    n:label("butlp")
end
function S.buthp(n, p)
    n.input = n:param(0)
    n.cutoff = n:param(p.cutoff or 1000)
    n:lil("buthp zz zz")
    n:label("buthp")
end
function S.phasor(n, p)
    n.rate = n:param(p.rate or 0)
    n.iphs = p.iphs or 0
    n:lil(string.format("phasor zz %g", n.iphs))
    n:label("phasor")
end
function S.fmpair(n, p)
    n.tab = n:param(p.tab)
    n.freq = n:param(p.freq or 440)
    n.car = n:param(p.car or 1)
    n.mod = n:param(p.mod or 1)
    n.mi = n:param(p.mi or 1)
    n.fdbk = n:param(p.fdbk or 0)
    n:lil({"fmpair", "zz", "zz", "zz", "zz", "zz", "zz"})
    n:label("fmpair")
end
function S.envar(n, p)
    n.gate = n:param(p.gate or 0)
    n.atk = n:param(p.atk or 0.1)
    n.rel = n:param(p.rel or 0.1)
    n:lil({"envar", "zz", "zz", "zz"})
    n:label("envar")
end
function S.osc(n, p)
    n.tab = n:param(p.tab)
    n.iphs = p.iphs or 0
    n.freq = n:param(p.freq or 440)
    n.amp = n:param(p.amp or 0.5)
    n:lil({"osc", "zz", "zz", "zz", n.iphs})
    n:label("osc")
end
function S.tgate(n, p)
    n.trig = n:param(p.trig or 0)
    n.dur = n:param(p.dur or 0.5)
    n:lil({"tgate", "zz", "zz"})
    n:label("tgate")
end
function S.gtick(n, p)
    n.gate = n:param(p.gate or 0)
    n:lil({"gtick", "zz"})
    n:label("gtick")
end
function S.smoother(n, p)
    n.input = n:param(p.input or 0)
    n.smooth = n:param(p.smooth or 0)
    n:lil({"smoother", "zz", "zz"})
    n:label("smoother")
end
function S.qgliss(n, p)
    n.tab = n:param(p.tab)
    n.input = n:param(p.input or 0)
    n.clock = n:param(p.clock or 0)
    n.gliss = n:param(p.gliss or 0.9)
    n:lil("qgliss zz zz zz zz")
    n:label("qgliss")
end
function S.tract(n, p)
    n.tract = n:param(p.tract)
    n.input = n:param(p.input or 0)
    n.velum = n:param(p.velum or 0)
    n:lil("tract zz zz zz")
    n:label("tract")
end
function S.glottis(n, p)
    n.freq = n:param(p.freq or 0)
    n.aspiration = n:param(p.aspiration or 0.8)
    n:lil("glottis zz zz")
    n:label("glottis")
end
function S.valset (n, p)
    n.val = n:param(p.val or nil)
    n.input = n:param(p.input or 0)
    n:lil({"valset2", "zz", "zz"})
    n:label("valset")
end
function S.rephasor(n, p)
    n.input = n:param(p.input or 0)
    n.ratemul = n:param(p.ratemul or 1)
    n:lil({"rephasor", "zz", "zz"})
    n:label("rephasor ")
end
-- spoof the "node" interface from diagraf
function default_lil_eval(s)
    if type(s) == "table" then
        s = table.concat(s, " ")
    end
    lil(s)
end
dummy = {}
dummy.eval = default_lil_eval

-- this is a hack for the specifically gest node
-- the "glive" parameter for some reason has to be a string
-- it can't work as a callback when it is a parameter node
dummy.sigrune_dummy = true
function dummy:lil(str)
    -- if type(str) == "table" then
    --     str = table.concat(str, " ")
    -- end
    self.eval(str)
end

-- this is a shim for the Node:param() method
-- for some reason, this evals in-place. the current diagraf
-- node method returns something. I think this might be
-- outdated or something? I'll need to revisit.
function dummy:param(v)
    if type(v) == "function" then
        v(self.eval)
    elseif type(v) == "table" and v.lilnode then
		self.eval(v.lilstr)
    else
        self.eval({"param", v})
    end
end

function dummy:label(str)

end
function S.node(n, p)
    p = p or {}
    return function (p)
        n(dummy, p)
    end
end
-- to use a node as a parameter inside of lilnode, call
-- paramnode
function S.paramnode(n, p)
    p = p or {}
    -- Note to self: nested callbacks weren't a great idea
    -- I'm having a hard time keeping all the scope in my head
    return function(p)
        return function (eval)
            -- eval is already in dummy
            n(dummy, p)
        end
    end
end
function S.node_debug(debug)
    if debug then
        dummy.eval = print
    else
        dummy.eval = lil
    end
end
function S.node_eval(eval)
    dummy.eval = eval
end

return Sigrunes
