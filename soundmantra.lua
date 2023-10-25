soundmantra = {}
core = require("gestlings/core")
function lilt(p)
    lil(table.concat(p, " "))
end

function draw_selected_letterbox(st)
    local lxoff = st.lxoff
    local tempo_yoff = st.tempo_yoff
    local letter = st.letter
    lilt {
        "bprectf",
        "[bpget [grab bp] 0]",
        lxoff - 3, ((tempo_yoff) + 16) - 3,
        13, 13,
        0
    }
    lilt {
        "bprect",
        "[bpget [grab bp] 0]",
        lxoff - 3, ((tempo_yoff) + 16) - 3,
        13, 13,
        1
    }

    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab plotter]",
        lxoff, (tempo_yoff) + 16,
        letter
    }
end

function gesture(sr, gst, name, cnd, extscale)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr()),
        extscale = extscale,
    }
end

function gesturizer(sr, gst, cnd, extscale)
    return function(name)
        gesture(sr, gst, name, cnd, extscale)
    end
end

function gscale(mkgst, name, mn, mx)
    local zz = "zz"
    mkgst(name)
    lilt {"mul", zz, 1.0 / 0xFF}
    lilt {"param", mn}
    lilt {"param", mx}
    lilt {"scale", zz, zz, zz}
end

function sawvoice(sigrunes, cnd, gst, extscale, pitch, rate)
    gesture(sigrunes, gst, pitch, cnd, extscale)
    lilt {"mtof", zz}
    lilt {"blsaw", zz}
end

function drawnotch(phs)
        local notch = {}
        local notch_width = 8
        local twopi = 2*math.pi
        local radius = 60
        notch[1] = 120 + (radius - notch_width)*math.sin(twopi * phs)
        notch[2] = 120 - (radius - notch_width)*math.cos(twopi * phs)
        notch[3] = 120 + (radius + notch_width)*math.sin(twopi * phs)
        notch[4] = 120 - (radius + notch_width)*math.cos(twopi * phs)


        lilt {
            "bpline",
            "[bpget [grab bp] 0]",
            notch[1], notch[2],
            notch[3], notch[4],
            1
        }
end

function load_vocal_shapes(sig)
    local zz = "zz"
    local ah = sig:new()
    local oo = sig:new()

    lilt {"tabload", "shapes/julia_ah.raw"}
    ah:hold_data()

    lilt{"tabload", "shapes/julia_oo.raw"}
    oo:hold_data()

    return ah, oo
end

function create_tract(sig)
    local tract = sig:new()
    lilt {"tractnew"}
    tract:hold_data()
    return tract
end

function setup_diphone(sig, ah, oo, mkgst)
    -- TODO: hookup position to gesture
    local pos = 0
    local zz = "zz"
    local diphone = sig:new()
    ah:get()
    oo:get()
    --lilt {"param", pos}
    mkgst("voxshape")
    lilt {"diphone", zz, zz, zz}
    diphone:hold_data()

    return diphone
end

function setup_tractshape(tract, diphone)
    local zz = "zz"
    tract:get()
    diphone:get()
    lilt {"tractshape", zz, zz}
end

function setup_vox(sig, mkgst)
    local ah, oo = load_vocal_shapes(sig)
    local tract = create_tract(sig)
    local diphone = setup_diphone(sig, ah, oo, mkgst)
    ah:unhold()
    oo:unhold()
    setup_tractshape(tract, diphone)
    diphone:unhold()

    return tract
end

function singer(tract, pitch, pads, mkgst)
    local zz = "zz"
    tract:get()

    -- lilt {"param", 60}
    pitch:get()
    gscale(mkgst, "vib_rate", 5, 7.5)
    gscale(mkgst, "vib_amt", 0, 0.5)
    lilt {"sine", zz, zz}
    lilt {"add", zz, zz}
    lilt {"mtof", zz}
    lilt {"param", 0.6}
    lilt {"param", 0.1}
    lilt {"param", 0.001}
    lilt {"glot", zz, zz, zz, zz}
    lilt {"param", 0.0}
    lilt {"tract", zz, zz, zz}
    lilt {"butlp", zz, 8000}
    mkgst("vox")
    lilt {"envar", zz, 0.1, 0.1}
    lilt {"mul", zz, zz}
    lilt {"mul", zz, "[dblin -3]"}
    lilt {"dup"}

    pads:get()
    -- lilt {"peakeq", zz, 500, 500, 0.5}
    lilt {"mul", zz, "[dblin -20]"}

    lilt {"talkbox", zz, zz, 0.9}
    lilt {"dcblocker", zz}
    lilt {"add", zz, zz}

end

function soundmantra.generate(p)
    local gest = require("gestlings/gest")
    local sig = require("gestlings/sig")
    local tal = require("gestlings/tal")
    local morpheme = require("gestlings/morpheme")
    local path = require("gestlings/path")
    local sigrunes = require("gestlings/sigrunes")
    local name = p.name
    local seq = p.seq
    local nbeats = p.nbeats or 7
    local tempo = p.tempo
    local tempomul = p.tempomul or 1
    local total_dur = p.dur or 35


    lil("bpnew bp 240 320")
    lil("bpset [grab bp] 0 0 0 240 320")

    lil("gfxnew gfx 240 320")
    lil("grab gfx; dup")
    lil("gfxopen tmp.h264")
    lil("uf2load plotter fonts/plotter.uf2")
    lil("gfxclrset 1 1.0 1.0 1.0")
    lil("gfxclrset 0 0.0 0.0 0.0")
    lil("drop")

    lil("blkset 49")
    lil("valnew phs")
    lil("valnew prime")

    local gt = gest.behavior.gate_50
    local stp = gest.behavior.step
    local exp = gest.behavior.exp_concave_low
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local base = 48

    local m_a = morpheme.template {
        envtype = {
            {0, 1, stp}
        },
        gt = {
            {1, 1, gt},
        },
        pitch = {
            {72, 1, stp},
        },
        revsz = {
            {0x90, 3, stp},
            {0x90, 1, gm},
        },
        vol = {
            {0xFF, 7, stp},
            {0xFF, 1, gm},
        },
        envgt = {
            {0, 1, stp},
        },
        expgt = {
            {0x0, 1, stp},
        },
        cutoff = {
            {0xFF, 3, stp},
            {0xFF, 1, gm}
        },

        pad1nn = {
            {base + 0, 1, gm}
        },
        pad2nn = {
            {base + 7, 1, gm}
        },
        pad3nn = {
            {base + 12 + 2, 1, gm}
        },
        pad4nn = {
            {base + 12 + 5, 1, gm}
        },
        nsgt = {
            {0, 1, stp}
        },
        nsfrq = {
            {0x20, 1, gm}
        },
        nsrev = {
            {0x00, 1, gm}
        },

        vox = {
            {0x00, 1, stp}
        },
        voxshape = {
            {0x00, 1, gm}
        },
        vib_amt = {
            {0x00, 1, gm}
        },
        vib_rate = {
            {0x00, 1, gm}
        }
    }

    m_b = morpheme.template(m_a {
        envtype = {
            {1, 1, stp}
        },
        gt = {
            {0, 1, stp},
        },
        envgt = {
            {1, 1, stp},
        },
        revsz = {
            {0xb0, 3, stp},
            {0xb0, 1, gm},
        },
        pitch = {
            {60, 2, gm},
            {70, 1, gm},
        },
        cutoff = {
            {0x30, 3, stp},
            {0x30, 1, gm}
        },
        vol = {
            {0xE0, 3, exp},
            {0xD0, 1, gm},
        },
    })

    local m_c = morpheme.template (m_a {
        envtype = {
            {0, 1, stp}
        },
        gt = {
            {0, 1, stp},
        },
        pitch = {
            {72 + 7, 1, stp},
        },
        revsz = {
            {0xEA, 1, exp},
            {0x10, 1, gl},
        },
        vol = {
            {0xFF, 7, stp},
            {0xFF, 1, gm},
        },
        envgt = {
            {0, 1, stp},
        },
        expgt = {
            {0x1, 1, stp},
        },
        cutoff = {
            {0xFF, 3, stp},
            {0xFF, 1, gm}
        },

        pad1nn = {
            {base - 4 - 12, 1, gm}
        },
        pad2nn = {
            {base, 1, lin},
        },
        pad3nn = {
            {base + 10, 2, lin},
        },
        pad4nn = {
            {base + 12 + 8, 1, lin},
        },
        nsgt = {
            {1, 1, stp}
        },
    })
    m_d = morpheme.template(m_b {
        pitch = {
            {69, 2, gm},
            {62, 1, gm},
        },
        expgt = {
            {0x01, 1, stp},
        },
        revsz = {
            {0xf0, 3, stp},
            {0xe0, 1, gm},
        },
        pad1nn = {
            {base + -2, 1, gl}
        },
        pad2nn = {
            {base + 5, 1, gm}
        },
        pad3nn = {
            {base + 12, 1, gm}
        },
        pad4nn = {
            {base + 12 + 2, 1, gm}
        }
    })

    m_e = morpheme.template(m_d {
        revsz = {
            {0xe0, 3, gm},
        },
        expgt = {
            {0x01, 0, stp},
            {0x01, 1, stp},
            {0x01, 0, stp},
        },
        pitch = {
            {67, 2, gm},
            {60, 1, gm},
        },
        envtype = {
            {0, 1, stp}
        },
        gt = {
            {0, 1, stp},
        },
        pad1nn = {
            {60, 1, gm}
        },
        pad2nn = {
            {60 - 4, 1, gm},
        },
        pad3nn = {
            {60 - 4 - 5, 1, gm}
        },
        pad4nn = {
            {60 - 12, 1, gm},
        },
        vox = {
            {1, 1, stp}
        },
        voxshape = {
            {1, 2, gm},
            {0, 1, gm}
        },
        vib_amt = {
            {0x00, 1, exp},
            {0xF0, 2, exp}
        },
        vib_rate = {
            {0x80, 1, exp},
            {0x90, 1, exp}
        }
    })

    local vocab = {
        a = m_a {},
        b = m_a {
            pitch = {
                {72 + 7, 1, stp},
            },
            revsz = {
                {0xFF, 1, gm},
            }
        },
        c = m_a {
            gt = {
                {1, 2, gt},
                {1, 2, gt},
                {1, 1, gt},
                {1, 1, gt},
                {1, 1, gt},
                {1, 1, gt},
            },
            pitch = {
                {72 + 7 + 7, 1, stp},
            },
            revsz = {
                {0x10, 3, exp},
                {0xFF, 1, gm},
            },
            vol = {
                {0x80, 3, exp},
                {0xFF, 1, gm},
            },
        },

        d = m_b {},
        e = m_d {},
        f = m_b {
            envgt = {
                {1, 1, stp},
            },
            pitch = {
                {36, 2, gm},
                {36 + 2*12 + 2, 2, gm},
            },
            expgt = {
                {0x01, 1, stp},
            },
            revsz = {
                {0x00, 1, exp},
                {0xff, 1, lin},
                {0xb0, 2, gm},
            },
            pad1nn = {
                {base + 0, 1, gm}
            },
            pad2nn = {
                {base + 7, 1, gm},
                {base + 9, 1, gm}
            },
            pad3nn = {
                {base + 12 + 2, 1, gm}
            },
            pad4nn = {
                {base + 12 + 5, 1, gm},
                {base + 12 + 7, 1, gm},
                {base + 12 + 5, 1, gm},
                {base + 12 + 7, 1, gm},
                {base + 12 + 5, 1, gm},
                {base + 12 + 7, 1, gm},
            }
        },

        g = m_b {
            envgt = {
                {0, 1, stp},
            },
            expgt = {
                {0x01, 1, stp},
            },
            revsz = {
                {0xff, 1, lin},
                {0xb0, 2, gm},
            },
            pad1nn = {
                {base - 12 , 1, gm},
                {base, 1, gm}
            },
            pad2nn = {
                {base + 7, 1, gm},
            },
            pad3nn = {
                {base + 12 + 2, 1, gm}
            },
            pad4nn = {
                {base + 2*12 + 4, 1, gm},
                {base + 2*12 + 5, 1, gm},
                {base + 2*12 + 7, 1, gm},
                {base + 2*12 + 4, 1, gm},
                {base + 2*12 + 5, 1, gm},
                {base + 2*12 + 7, 1, gm},
            }
        },

        h = m_a {
            gt = {
                {1, 1, gt},
                {1, 1, gt},
                {1, 1, gt},
                {1, 3, gt},
                {1, 3, gt},
            },
            expgt = {
                {0x00, 2, stp},
                {0x01, 1, stp},
                {0x00, 2, stp},
            },
            pitch = {
                {72 + 7 + 7 + 2, 1, lin},
                {72 + 7 + 7 - 2, 1, lin},
            },
            revsz = {
                {0xFF, 2, exp},
                {0x80, 1, exp},
            },
            vol = {
                {0xFF, 3, exp},
                {0x80, 1, gm},
            },
            pad1nn = {
                {base - 4 - 12, 1, gm}
            },
            pad2nn = {
                {base + 3, 1, gm},
            },
            pad3nn = {
                {base + 10 , 1, gm}
            },
            pad4nn = {
                {base + 12 + 7, 1, gm},
            }
        },
        i = m_c {},
        j = m_c {
            nsfrq = {
                {0x20, 1, exp},
                {0x80, 4, exp},
            },
            revsz = {
                {0xb0, 1, lin},
            },
        },
        k = m_c {
            expgt = {
                {0x00, 1, stp},
                {0x01, 1, stp},
                {0x00, 1, stp},
            },
            nsfrq = {
                {0x00, 3, exp},
                {0xff, 1, exp},
            },

        },
        l = m_d {
            revsz = {
                {0xe0, 1, gm},
            },
            pitch = {
                {72, 2, gm},
                {64, 1, gm},
            },

            expgt = {
                {0x01, 1, stp},
                {0x00, 1, stp},
            },

            pad1nn = {
                {base, 1, gm}
            },
            pad2nn = {
                {base + 7, 1, gm}
            },
            pad3nn = {
                {base + 12 + 4, 1, gm},
                {base + 12 + 5, 1, gm},
                {base + 12 + 4, 1, gm},
                {base + 12 + 0, 1, gm},
                {base + 12 + 4, 1, gm},
                {base + 12 + 5, 1, gm},
                {base + 12 + 4, 1, gm},
                {base + 12 + 0, 1, gm},

            },
            pad4nn = {
                {base + 12 + 2, 2, gm},
                {base + 12 + 7, 1, gm},
                {base + 12 + 12, 1, gm}
            },

            nsfrq = {
                {0x00, 2, exp},
                {0x10, 1, lin},
            },

            nsgt = {
                {0, 3, exp},
                {1, 1, lin}
            },

            nsrev = {
                {0, 1, exp},
                {0xFF, 1, gm}
            },

        },
        m = m_e {
        },
        n = m_e {
            pitch = {
                {67, 2, gm},
                {68, 1, gm},
            },
            voxshape = {
                {1, 2, gm},
                {0, 1, gm}
            },
            pad1nn = {
                {63, 1, gm}
            },
            pad2nn = {
                {60 - 2 + 12, 1, gm},
            },
            pad3nn = {
                {60 - 2 - 5, 1, gm}
            },
            pad4nn = {
                {60 - 12, 1, gm},
                {60, 1, gm},
            },
        },
        o = m_e {
            pad1nn = {
                {62, 1, gm},
                {60, 2, gm}
            },
            pad2nn = {
                {60 - 4, 1, gm},
            },
            pad3nn = {
                {60 - 4 - 5, 1, gm}
            },
            pad4nn = {
                {60 - 12, 1, gm},
            },
        },
        p = m_e {
            pitch = {
                {70, 1, gm},
                {72, 1, gm},
                {62, 1, gm},
            },
            voxshape = {
                {1, 2, lin},
                {0, 1, gm}
            },
            pad1nn = {
                {63, 1, gm}
            },
            pad2nn = {
                {60 - 2, 1, gm},
                {60 - 2 - 12, 2, gm},
            },
            pad3nn = {
                {60 - 2 - 5, 1, gm}
            },
            pad4nn = {
                {60, 1, gm},
            },
            vib_amt = {
                {0x10, 1, exp},
                {0xF0, 2, gm}
            },
            vib_rate = {
                {0x80, 1, exp},
                {0xA0, 1, gm}
            }
        },
        q = m_a {
            gt = {
                {1, 3, gt},
                {1, 3, gt},
                {1, 2, gt},
                {1, 2, gt},
                {1, 1, gt},
                {1, 1, gt},
            },
            pitch = {
                {72 + 7, 3, exp},
                {72 + 7 + 12, 1, gm},
            },
            revsz = {
                {0x1F, 1, gm},
                {0xFF, 1, gm},
                {0x1F, 1, gm},
            },
            expgt = {
                {0x01, 1, stp},
                {0x00, 1, stp},
            },
            pad1nn = {
                {63 + 2 + 24, 1, gm}
            },
            pad2nn = {
                {60 - 2, 1, gm},
                {60 - 2 - 12, 2, gm},
            },
            pad3nn = {
                {60 - 2 - 5, 1, gm}
            },
            pad4nn = {
                {60, 1, gm},
            },
        },
        r = m_e {
            pitch = {
                {60 - 7, 1, exp},
            },
            pad1nn = {
                {60 + 1, 1, exp}
            },
            pad2nn = {
                {(60 + 12) + 2, 1, exp}
            },
            pad3nn = {
                {(60 - 12) + 3, 1, exp}
            },
            pad4nn = {
                {(60 - 24) + 4, 1, exp},
            },
            vib_amt = {
                {0x00, 1, exp},
                {0xFF, 1, gm}
            },
            vib_rate = {
                {0x00, 2, exp},
                {0xDF, 1, gm}
            },
            voxshape = {
                {1, 1, exp},
                {0, 1, gm}
            },

        },
        s = m_a {
            gt = {
                {1, 1, gt},
                {1, 1, gt},
                {1, 2, gt},
                {1, 2, gt},
                {1, 3, gt},
                {1, 3, gt},
            },
            pitch = {
                {72 + 7 + 12, 3, exp},
                {72 + 7, 1, gm},
            },
            revsz = {
                {0x1F, 1, gm},
                {0xFF, 1, gm},
                {0x1F, 1, gm},
            },
            expgt = {
                {0x01, 1, stp},
                {0x00, 1, stp},
            },
            pad1nn = {
                {63 + 2 + 24 + 3, 1, gm}
            },
            pad2nn = {
                {60 - 2 + 3, 1, gm},
                {60 - 2 - 12 + 3, 2, gm},
            },
            pad3nn = {
                {60 - 2 - 5 + 3, 1, gm}
            },
            pad4nn = {
                {60 + 3, 1, gm},
            },
        },
        t = m_b {
            pitch = {
                {72 + 2, 2, gl},
                {36, 1, exp},
                {48, 1, gl},
            },
            revsz = {
                {0x80, 1, exp},
                {0xff, 1, gm},
            },
            nsgt = {
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
            },
            pad1nn = {
                {63 + 2 + 24 + 3, 1, gm}
            },
            pad2nn = {
                {60 - 2 + 3, 1, gm},
                {60 - 2 - 12 + 3, 2, gm},
            },
            pad3nn = {
                {60 - 2 - 5 + 3, 1, gm}
            },
            pad4nn = {
                {60 + 3, 1, gm},
            },
            vib_amt = {
                {0xFF, 1, gm},
                {0x00, 1, exp},
            },
            vib_rate = {
                {0xDF, 1, gm},
                {0x00, 2, exp},
            },
            voxshape = {
                {0, 1, gm},
                {1, 1, exp},
            },
            vox = {
                {1, 1, stp},
            },
        },
        u = m_c {
            revsz = {
                {0x80, 1, exp},
                {0xff, 1, gm},
            },
            nsgt = {
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
                {1, 1, stp},
                {0, 1, stp},
            },
            pad1nn = {
                {63 + 2 + 24 + 3, 1, gm}
            },
            pad2nn = {
                {60 - 2 + 3, 1, gm},
                {60 - 2 - 12 + 3, 2, gm},
            },
            pad3nn = {
                {60 - 2 - 5 + 3, 1, gm}
            },
            pad4nn = {
                {60 + 3, 1, gm},
            },
        },
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
    local tempovoc = {
        A = {{1, 1}, stp},
        B = {{4, 1}, stp},
        C = {{1, 2}, stp},
        D = {{6, 1}, exp},
        E = {{1, 3}, exp},
        F = {{2, 3}, stp},
        G = {{1, 4}, stp},
    }


    if tempo ~= nil then
        local vtx = path.vertex

        local temponum = {}
        local tempoden = {}

        for _, t in pairs(tempo) do
            local tempoword = tempovoc[t[1]]
            local temposcale = tempoword[1]
            local behavior = tempoword[2]
            local dur = {t[2]*tempomul, 1}
            table.insert(temponum, vtx{temposcale[1], dur, behavior})
            table.insert(tempoden, vtx{temposcale[2], dur, behavior})
        end

        tal.label(words, "temponum")
        path.path(tal, words, temponum)
        tal.jump(words, "temponum")

        tal.label(words, "tempoden")
        path.path(tal, words, tempoden)
        tal.jump(words, "tempoden")
    end

    gst:compile(words)
    gst:swapper()

    zz = "zz"
    rate = 1/7
    bpm = rate*60
    lilt{"phasor", 1/7, 0}
    --lilt{"gestcnd", bpm}
    local cnd_prime = sig:new()
    cnd_prime:hold_cabnew()


    local extscale = mseqdur
    cnd_prime:get()
    local temponumgst = nil
    if tempo ~= nil then
        gesture(sigrunes, gst, "temponum", cnd_prime, 1)
        lil("gestvmlast " .. gst:get())
        temponumgst = pop()
        gesture(sigrunes, gst, "tempoden", cnd_prime, 1)
        lilt{"div", zz, zz}
        lilt{"rephasor", zz, zz}
    else
        lilt{"rephasor", zz, 1.0}
    end
    local cnd0 = sig:new()
    cnd0:hold_cabnew()



    lil("grab phs")
    cnd0:get()
    lil("valset zz zz")

    lil("grab prime")
    cnd_prime:get()
    lil("valset zz zz")

    cnd0:get()
    lilt{"rephasor", zz, extscale}
    local cnd = sig:new()
    cnd:hold_cabnew()
    extscale = 1

    gesture(sigrunes, gst, "gt", cnd, extscale)
    lilt {"gtick", zz}
    -- note that this short envelope will occasionally
    -- not be 100% lined up to the pitch, so it will change
    -- sometimes (especially 'b')
    lilt{"env", zz, 0.0005, 0.0005, 0.0005}
    gesture(sigrunes, gst, "envgt", cnd, extscale)
    lilt{"envar", zz, 0.1, 0.1}
    gesture(sigrunes, gst, "envtype", cnd, extscale)
    lilt{"smoother", zz, 0.001}
    lilt{"crossfade", zz, zz, zz}

    gesture(sigrunes, gst, "expgt", cnd, extscale)
    lilt{"envar", zz, 5.0, 15.0}
    expenv = sig:new()
    expenv:hold()

    gesture(sigrunes, gst, "pitch", cnd, extscale)
    local pitch = sig:new()
    pitch:hold_cabnew()

    pitch:get()
    expenv:get()
    lilt{"scale", zz, 5.0, 7}
    expenv:get()
    lilt{"scale", zz, 0, 0.3}
    lilt{"sine", zz, zz}
    lilt{"add", zz, zz}

    lilt{"mtof", zz}
    lilt{"blsquare", zz}
    -- lilt{"butbp", zz, 500, 500}
    lilt{"butbp", zz, 500, 500}


    gesture(sigrunes, gst, "cutoff", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, 100, 10000}
    lilt {"butlp", zz, zz, zz}

    gesture(sigrunes, gst, "vol", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, -30, -5}
    lilt {"dblin", zz}
    lilt{"mul", zz, zz}
    lilt{"mul", zz, zz}


    local rev = sig:new()
    rev:zero()
    rev:throw(-6)

    local base = 48
    sawvoice(sigrunes, cnd, gst, extscale, "pad1nn", 6)
    sawvoice(sigrunes, cnd, gst, extscale, "pad2nn", 6.2)
    lilt {"add", zz, zz}
    sawvoice(sigrunes, cnd, gst, extscale, "pad3nn", 6.1)
    lilt {"add", zz, zz}
    sawvoice(sigrunes, cnd, gst, extscale, "pad4nn", 6.5)
    lilt {"add", zz, zz}

    local pads = sig:new()

    pads:hold()

    pads:get()

    lilt {"butlp", zz, 500}

    lilt {"mul", zz, 0.1}
    expenv:get()
    lilt {"mul", zz, zz}
    lil("dup")
    lilt{"vardelay", zz, 0.8, 1.1, 2.0}
    lilt{"butlp", zz, 4000}
    lilt{"mul", zz, "[dblin -5]"}
    lilt{"buthp", zz, 300}
    lilt{"add", zz, zz}
    rev:send(0)

    -- bitnoise
    gesture(sigrunes, gst, "nsfrq", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, 500, 1500}
    lilt {"bitnoise", zz, 0}
    lilt {"butlp", zz, 8000}
    lilt {"mul", zz, "[dblin -20]"}
    gesture(sigrunes, gst, "nsgt", cnd, extscale)
    lilt {"mul", zz, zz}
    lilt{"dup", zz, zz}
    lilt{"buthp", zz, 300}

    lilt {"regget", rev.reg}
    gesture(sigrunes, gst, "nsrev", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, -6, 6}
    lilt {"dblin", zz}
    lilt {"mix", zz, zz, zz}
    -- rev:send(-6)
    lilt{"add", zz, zz}

    -- Singer
    local mkgst = gesturizer(sigrunes, gst, cnd, extscale)
    local tract = setup_vox(sig, mkgst)
    singer(tract, pitch, pads, mkgst)
    pads:unhold()
    pitch:unhold()
    rev:throw(-10)
    lilt{"add", zz, zz}

    -- scale dry signal reverb post-fader for distant sound
    expenv:get()
    lilt {"scale", zz, 0, -10}
    lilt {"dblin", zz}
    lilt {"mul", zz, zz}

    rev:get()
    lil("dup")
    gesture(sigrunes, gst, "revsz", cnd, extscale)
    lilt {"mul", zz, 1/0xFF}
    lilt {"scale", zz, 0.1, 0.97}

    expenv:get()
    lilt {"scale", zz, 0.0, 0.25}
    lilt {"add", zz, zz}
    lilt {"limit", zz, 0.0, 0.98}

    lil("param 10000")
    lilt{"bigverb", zz, zz, zz, zz}
    lil("drop")
    lilt {"mul", zz, "[dblin -10]"}
    lilt {"dcblocker", zz}
    lilt {"add", zz, zz}
    lilt {"limit", zz, -0.99, 0.99}
    lilt{"wavout", zz, "tmp.wav"}
    cnd:unhold()
    cnd_prime:unhold()
    rev:unhold()
    expenv:unhold()

    twopi = 2*math.pi

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
    local nframes = 60*total_dur

    local linesz = 240-32
    local totalunits = 0

    if tempo ~= nil then
        for _, t in pairs(tempo) do
            totalunits = totalunits + (1.0/t[2])
        end
    end

    local unit = linesz / totalunits
    local lastramp = 999
    local curpos = 0
    local linepos = 16

    for n=1, nframes do
        if n % 60 == 0 then
            print(string.format("%d\t %02g%%", n, 100*(n / nframes)))
        end
        lil("compute 15")
        lilt {"bpfill", "[bpget [grab bp] 0]", 0}
        lil("bpcirc [bpget [grab bp] 0] 120 120 100 1")
        lil("bpcircf [bpget [grab bp] 0] 120 120 4 1")

        local d = 0
        for _,s in pairs(seq) do
            drawbox(d*imseqdur, s[1])
            d = d + s[2]
        end
        local phs = valutil.get("phs")
        xpos = 120 + (120 - 8)*math.sin(twopi * phs)
        ypos = (120 - (120 - 8)*math.cos(twopi * phs))

        lilt {
            "bpline",
            "[bpget [grab bp] 0]",
            120, 120,
            xpos, ypos,
            1
        }

        -- Prime hand
        local phs = valutil.get("prime")
        primesz = 80
        prime_xpos = 120 + primesz*math.sin(twopi * phs)
        prime_ypos = (120 - primesz*math.cos(twopi * phs))


        if tempo ~= nil then
            lilt {
                "bpline",
                "[bpget [grab bp] 0]",
                120, 120,
                prime_xpos, prime_ypos,
                1
            }

            -- Compass
            lil("bpcirc [bpget [grab bp] 0] 120 120 60 1")
            local phs = 0

            for i=1,12 do
                drawnotch((i - 1) / 8)
            end
        end

        if temponumgst ~= nil then
            local ramp = gestvm_last_conductor(temponumgst)

            if ramp < lastramp then
                if curpos > 0 then
                    linepos = linepos + (1.0/tempo[curpos][2])*unit
                end
                curpos = (curpos + 1)
                if curpos > #tempo then
                    curpos = 1
                    linepos = 16
                end
            end

            lastramp = ramp
            local tempo_yoff = 240 + 8
            lilt {
                "bpline",
                "[bpget [grab bp] 0]",
                16, tempo_yoff,
                240-16, tempo_yoff,
                1
            }

            lilt {
                "bprectf",
                "[bpget [grab bp] 0]",
                --16 + linesz*ramp, (tempo_yoff) - 8,
                (linepos - 1) + ramp*(1.0/tempo[curpos][2])*unit,
                (tempo_yoff) - 8,
                3, 17,
                1
            }

            local lxoff = 16

            -- horizontal center letter on playhead
            lxoff = lxoff - 4

            local sel_lb = nil
            for i, t in pairs(tempo) do
                if i == curpos then
                    lilt {
                        "bprectf",
                        "[bpget [grab bp] 0]",
                        lxoff - 3, ((tempo_yoff) + 16) - 3,
                        13, 13,
                        0
                    }
                    lilt {
                        "bprect",
                        "[bpget [grab bp] 0]",
                        lxoff - 3, ((tempo_yoff) + 16) - 3,
                        13, 13,
                        1
                    }

                    -- store this data, we're going to
                    -- use it to redraw it after
                    sel_lb = {}
                    sel_lb.lxoff = lxoff
                    sel_lb.tempo_yoff = tempo_yoff
                    sel_lb.letter = t[1]
                end

                lilt {
                    "uf2txtln",
                    "[bpget [grab bp] 0]",
                    "[grab plotter]",
                    lxoff, (tempo_yoff) + 16,
                    t[1]
                }

                lxoff = lxoff + (1.0 / t[2])*unit
            end

            -- redraw selected letterbox so it shows up
            -- upfront. Not the most efficient way to
            -- do it, but oh well.
            if sel_lb ~= nil then
                draw_selected_letterbox(sel_lb)
            end

        end

        lil("grab gfx; dup")
        lilt{"gfxrectf", 0, 0, 240, 320, 1}
        lilt{"bptr", "[grab bp]", 0, 0, 240, 320, 0, 0, 0}
        lil("grab gfx; dup")
        lil("gfxtransfer; gfxappend")
    end

    lil("grab gfx")
    lil("gfxclose")
    lilt {"gfxmp4", "tmp.h264", "tmp.mp4"}

    ffmpeg_args = {
        "export AV_LOG_FORCE_NOCOLOR=1;",
        "ffmpeg",
        "-hide_banner", "-loglevel", "error", "-y",
        "-i", "tmp.mp4",
        "-i", "tmp.wav",
        "-pix_fmt", "yuv420p",
        "-acodec", "aac",
        -- "-b:a", "320k",
        "-vbr", 4,
        name .. ".mp4"
    }

    os.execute(table.concat(ffmpeg_args, " "))

end

return soundmantra
