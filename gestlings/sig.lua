Sig = {}
function lil_default(s)
    if (type(s) == "table") then
        s = table.concat(s, " ")
    end

    lil(s)
end
function Sig:new(o)
    o = o or {}
    o.reg = -1
    setmetatable(o, self)
    self.__index = self
    return o
end
function Sig:hold(lil_eval)
    -- can be a callback used to simulate holding
    lil_eval = lil_eval or lil_default
    if self.reg >= 0 then
        error("can't hold, already holding")
    end

    -- regnxt actually has to be called to see if it is
    -- working

    local lstr = "param [regnxt 0]"
    -- if lil_eval ~= lil then
    --     lil_eval(lstr)
    -- end

    lil(lstr)


    local reg = pop()

    if reg < 0 then
        error("invalid index")
    end

    -- hold/regset can be simulated without issue
    lil_eval({"hold", "zz"})
    -- lil_eval("hold zz # sig")
    lil_eval({"regset", "zz",reg})

    -- regmrk actually has to be called for it to work
    -- local lstr = string.format("regmrk %d", reg)
    local lstr = {"regmrk", reg}

    if lil_eval ~= lil then
        lil_eval(lstr)
    end

    lil(table.concat(lstr, " "))
    -- lil(string.format("regset zz %d; regmrk %d", reg, reg))

    self.reg = reg
end
function Sig:unhold(lil_eval)
    lil_eval = lil_eval or lil_default
    if self.reg < 0 then
        error("no signal to unhold")
    end

    -- lil_eval(string.format("unhold [regget %d]; regclr %d",
    --    self.reg, self.reg))
    lil_eval({"regget", self.reg})
    lil_eval({"unhold", "zz"})
    lil_eval({"regclr", self.reg})

    self.reg = -1
end
function Sig:get(eval)
    if self.reg < 0 then
        error("no signal")
    end

    if eval == nil then
        eval = lil
    end

    -- eval(string.format("regget %d", self.reg))
    local s = {"regget", self.reg}

    if eval == lil and type(s) ~= "string" then
        s = table.concat(s, " ")
    end

    eval(s)
end
function Sig:getstr()
    if self.reg < 0 then
        error("no signal")
    end

    --return string.format("[regget %d]", self.reg)
    return {"regget", self.reg}
end
function Sig:zero()
    if self.reg >= 0 then
        error("A signal is already being held")
    end
    lil("zero")
    self.hold(self)
end
function Sig:send(gain)
    if self.reg < 0 then
        error("no signal")
    end

    gain = gain or 0

    lil(string.format("mix zz [regget %d] [dblin %g]",
        self.reg, gain))
end
function Sig:throw(gain)
    if self.reg < 0 then
        error("no signal")
    end

    lil("dup")
    self.send(self, gain)
end
return Sig
