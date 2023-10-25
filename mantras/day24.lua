soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day24",
    seq = {
        {"r", 6},
        {"q", 6},

        {"r", 6},
        {"s", 6},

        {"r", 12},
        {"d", 6},
        {"l", 6},

        {"r", 18},
        {"t", 18},

        {"r", 30},
        {"s", 15},
        {"c", 5},
        {"m", 10},
    },

    tempo = {
        {"A", 1},
        {"B", 1},
        {"E", 1},
    },

    dur = 35,
    tempomul = 1,
}
