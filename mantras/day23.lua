soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day23",
    seq = {
        {"q", 1},
        {"q", 1},
        {"q", 1},
        {"q", 1},

        {"q", 1},
        {"q", 1},
        {"q", 1},
        {"q", 1},

        {"s", 1},
        {"s", 1},
        {"s", 1},
        {"s", 1},

        {"s", 1},
        {"s", 1},
        {"s", 1},
        {"s", 1},
    },

    tempo = {
        -- {"F", 8},
        -- {"G", 8},
        -- {"E", 8},
        -- {"B", 8},

        -- {"A", 8},
        -- {"G", 8},
        -- {"E", 8},
        -- {"B", 8},

        {"B", 8},
        {"A", 1},
        {"E", 3},
        {"A", 4},
        {"D", 4},
        {"C", 4},
    },

    dur = 20,
    tempomul = 4,
}
