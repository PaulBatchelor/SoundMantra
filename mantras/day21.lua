soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day21",
    seq = {
        {"q", 12},

        {"m", 6},
        {"e", 3},
        {"l", 3},

        {"o", 9},
        {"a", 1},
        {"a", 1},
        {"q", 1},

        {"a", 2},
        {"p", 4},
        {"q", 2},
        {"p", 4},

        {"c", 6},
        {"m", 6},

        {"i", 8},
        {"a", 1},
        {"b", 3},
    },

    tempo = {
        {"D", 1},
        {"E", 4},
        {"F", 3},
        {"G", 2},
    },

    tempomul = 2,

    dur = 40,
}
