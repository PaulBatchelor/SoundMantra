local tal = {}
function tal.macro(words, name, program)
    table.insert(words, "%" .. name)
    table.insert(words, "{")
    for _,v in pairs(program)
    do
        table.insert(words, v)
    end
    table.insert(words, "}")
end
function tal.label(words, label)
    table.insert(words, "@" .. label)
end
function tal.num(words, val)
    table.insert(words, "#" .. string.format("%02x", val))
end
function tal.val(words, val)
    tal.num(words, val)
    tal.num(words, 0x26)
    table.insert(words, "DEO")
    table.insert(words, "BRK")
end
function tal.halt(words)
    table.insert(words, "BRK")
end
function tal.dur(words, num, den)
    tal.num(words, num)
    tal.num(words, 0x24)
    table.insert(words, "DEO")
    tal.num(words, den)
    tal.num(words, 0x25)
    table.insert(words, "DEO")
end
function tal.behavior(words, id)
    tal.num(words, id)
    tal.num(words, 0x27)
    table.insert(words, "DEO")
end
function tal.jump(words, label)
    table.insert(words, ";" .. label)
    table.insert(words, "JMP2")
end
function tal.membuf(bufname)
    lil(string.format("gmemnew %s", bufname))
end
function tal.start(words)
    table.insert(words, "|0100")
end

-- I keep wanting to call it begin, not start
function tal.begin(words)
    tal.start(words)
end
function tal.compile_words(words, bufname, gvm)
    local program = table.concat(words, " ")
    tal.compile(program, bufname, gvm)
end
function tal.compile(program, bufname, gvm)
    gestvm_compile(bufname, program)
    lil("gmemcpy [grab " .. 
        bufname .. 
        "] " .. 
        gvm)
end
function tal.interpolate(words, state)
    tal.num(words, state)
    tal.num(words, 0x2a)
    table.insert(words, "DEO")
end
return tal
