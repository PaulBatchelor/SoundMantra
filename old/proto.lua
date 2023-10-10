core = require("gestlings/core")
function lilt(p)
    lil(table.concat(p, " "))
end

function gesture(sr, gst, name, cnd, extscale)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr()),
        extscale = extscale,
    }
end

function day1()
    lil("bpnew bp 240 320")
    lil("bpset [grab bp] 0 0 0 240 240")

    lil("gfxnew gfx 240 320")
    lil("grab gfx; dup")
    lil("gfxopen soundmantra.h264")
    lil("gfxclrset 1 1.0 1.0 1.0")
    lil("gfxclrset 0 0.0 0.0 0.0")
    lil("drop")

    lil("blkset 49")
    lil("valnew phs")
    lilt{"phasor", 1/7, 0}
    lil("hold zz; regset zz 0")
    lil("grab phs")
    lil("regget 0")
    lil("valset zz zz")
    zz = "zz"
    lil("regget 0")
    lilt{"phsclk", zz, 1}
    lilt{"env", zz, 0.0005, 0.0005, 0.0005}
    lilt{"blsquare", 500}
    lilt{"butbp", zz, 500, 500}
    lilt{"mul", zz, "[dblin -3]"}
    lilt{"mul", zz, zz}
    lil("dup; dup")
    lilt{"bigverb", zz, zz, 0.6, 10000}
    lil("drop")
    lilt {"mul", zz, "[dblin -10]"}
    lilt {"dcblocker", zz}
    lilt {"add", zz, zz}
    lilt{"wavout", zz, "tmp.wav"}
    lil("unhold [regget 0]")

    twopi = 2*math.pi
    phs = 0
    inc = 1/120

    for n=1, 60*35 do
        lil("compute 15")
        lilt {"bpfill", "[bpget [grab bp] 0]", 0}
        lil("bpcirc [bpget [grab bp] 0] 120 120 100 1")
        lil("bpcircf [bpget [grab bp] 0] 120 120 4 1")

        lilt {
            "bprectf",
            "[bpget [grab bp] 0]",
            120 - 8, (120 - 100) - 8,
            16, 16,
            0
        }
        lilt {
            "bprect",
            "[bpget [grab bp] 0]",
            120 - 9, (120 - 100) - 9,
            18, 18,
            1
        }

        xpos = 120 + (120 - 8)*math.sin(twopi * phs)
        ypos = (120 - (120 - 8)*math.cos(twopi * phs))
        phs = valutil.get("phs")

        lilt {
            "bpline",
            "[bpget [grab bp] 0]",
            120, 120,
            xpos, ypos,
            1
        }
        lil("grab gfx; dup")
        lilt{"gfxrectf", 0, 0, 240, 320, 1}
        lilt{"bptr", "[grab bp]", 0, 0, 240, 320, 0, 0, 0}
        lil("grab gfx; dup")
        lil("gfxtransfer; gfxappend")
    end

    lil([[
    grab gfx
    gfxclose
    gfxmp4 soundmantra.h264 tmp.mp4
    ]])

    ffmpeg_args = {
        "export AV_LOG_FORCE_NOCOLOR=1;",
        "ffmpeg",
        "-hide_banner", "-loglevel", "error", "-y",
        "-i", "tmp.mp4",
        "-i", "tmp.wav",
        "-pix_fmt", "yuv420p",
        "-acodec", "aac",
        "-b:a", "320k",
        "soundmantra.mp4"
    }

    os.execute(table.concat(ffmpeg_args, " "))
end

function day2()
    local gest = require("gestlings/gest")
    local sig = require("gestlings/sig")
    local tal = require("gestlings/tal")
    local morpheme = require("gestlings/morpheme")
    local path = require("gestlings/path")
    local sigrunes = require("gestlings/sigrunes")

    lil("bpnew bp 240 320")
    lil("bpset [grab bp] 0 0 0 240 240")

    lil("gfxnew gfx 240 320")
    lil("grab gfx; dup")
    lil("gfxopen soundmantra.h264")
    lil("uf2load plotter fonts/plotter.uf2")
    lil("gfxclrset 1 1.0 1.0 1.0")
    lil("gfxclrset 0 0.0 0.0 0.0")
    lil("drop")

    lil("blkset 49")
    lil("valnew phs")

    local gt = gest.behavior.gate_50
    local stp = gest.behavior.step
    local gm = gest.behavior.gliss_medium
    local m_a = morpheme.template {
        gt = {
            {1, 1, gt},
        },
        pitch = {
            {72, 1, stp},
        },
        revsz = {
            {0x90, 3, stp},
            {0x90, 1, gm},
        }
    }

    local vocab = {
        a = m_a {},
        b = m_a {
            pitch = {
                {72 + 7, 1, stp},
            },
            revsz = {
                {0xFF, 1, gm},
            }
        }
    }

    local seq = {
        {"a", 3},
        {"b", 1},
    }

    local mseq = {}
    mseqdur = 0

    for _,s in pairs(seq) do
        local morph = vocab[s[1]]
        local dur = {1, s[2]}
        table.insert(mseq, {morph, dur})
        mseqdur = mseqdur + s[2]
    end

    gst = gest:new{tal = tal}
    gst:create()
    local words = {}
    tal.begin(words)
    local head = {
        gt = function (words)
            tal.interpolate(words, 0)
        end
    }

    morpheme.articulate(path, tal, words, mseq, head)
    gst:compile(words)
    gst:swapper()

    lilt{"phasor", 1/7, 0}
    local cnd = sig:new()
    cnd:hold()
    lil("grab phs")
    cnd:get()
    lil("valset zz zz")
    zz = "zz"
    -- cnd:get()
    -- lilt{"phsclk", zz, 1}
    local extscale = mseqdur
    gesture(sigrunes, gst, "gt", cnd, extscale)
    lilt {"gtick", zz}
    lilt{"env", zz, 0.0005, 0.0005, 0.0005}
    gesture(sigrunes, gst, "pitch", cnd, extscale)
    lilt{"mtof", zz}
    lilt{"blsquare", zz}
    lilt{"butbp", zz, 500, 500}
    lilt{"mul", zz, "[dblin -3]"}
    lilt{"mul", zz, zz}

    local rev = sig:new()

    rev:zero()
    lil("dup")
    rev:throw(-6)


    rev:get()
    lil("dup")
    gesture(sigrunes, gst, "revsz", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, 0.1, 0.97}
    lil("param 10000")
    lilt{"bigverb", zz, zz, zz, zz}
    lil("drop")
    lilt {"mul", zz, "[dblin -4]"}
    lilt {"dcblocker", zz}
    lilt {"add", zz, zz}
    lilt{"wavout", zz, "tmp.wav"}
    cnd:unhold()
    rev:unhold()

    twopi = 2*math.pi
    phs = 0
    inc = 1/120

    function drawbox(pos, label)
        local xpos = math.sin(twopi * (1 - pos))
        local ypos = math.cos(twopi * (1 - pos))
        local xoff = (120 - 100*xpos)
        local yoff = (120 - 100*ypos)
        lilt {
            "bprectf",
            "[bpget [grab bp] 0]",
            xoff - 8, yoff - 8,
            16, 16,
            0
        }
        lilt {
            "bprect",
            "[bpget [grab bp] 0]",
            xoff - 9, yoff - 9,
            18, 18,
            1
        }
        lilt {
            "uf2txtln",
            "[bpget [grab bp] 0]",
            "[grab plotter]",
            xoff - 8 + 4, yoff - 8 + 4,
            label
        }

    end

    local imseqdur = 1.0 / mseqdur

    for n=1, 60*35 do
        lil("compute 15")
        lilt {"bpfill", "[bpget [grab bp] 0]", 0}
        lil("bpcirc [bpget [grab bp] 0] 120 120 100 1")
        lil("bpcircf [bpget [grab bp] 0] 120 120 4 1")

        local d = 0
        for _,s in pairs(seq) do
            drawbox(d*imseqdur, s[1])
            d = d + s[2]
        end
        xpos = 120 + (120 - 8)*math.sin(twopi * phs)
        ypos = (120 - (120 - 8)*math.cos(twopi * phs))
        phs = valutil.get("phs")

        lilt {
            "bpline",
            "[bpget [grab bp] 0]",
            120, 120,
            xpos, ypos,
            1
        }
        lil("grab gfx; dup")
        lilt{"gfxrectf", 0, 0, 240, 320, 1}
        lilt{"bptr", "[grab bp]", 0, 0, 240, 320, 0, 0, 0}
        lil("grab gfx; dup")
        lil("gfxtransfer; gfxappend")
    end

    lil ([[
    grab gfx
    gfxclose
    gfxmp4 soundmantra.h264 tmp.mp4
    ]])

    ffmpeg_args = {
        "export AV_LOG_FORCE_NOCOLOR=1;",
        "ffmpeg",
        "-hide_banner", "-loglevel", "error", "-y",
        "-i", "tmp.mp4",
        "-i", "tmp.wav",
        "-pix_fmt", "yuv420p",
        "-acodec", "aac",
        "-b:a", "320k",
        "soundmantra.mp4"
    }

    os.execute(table.concat(ffmpeg_args, " "))
end

day2()
