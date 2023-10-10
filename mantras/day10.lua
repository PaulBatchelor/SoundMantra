soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day10",
    seq = {
        {"a", 2},
        {"a", 2},
        {"i", 2},
        {"c", 1},

        {"a", 2},
        {"j", 2},
        {"a", 1},

        {"i", 2},
        {"b", 2},
        {"c", 1},

        {"d", 2},
        {"a", 1},
        {"e", 2},
        {"b", 1},
        {"j", 2},
        {"f", 2},
        {"a", 1},

        {"g", 3},
        {"h", 3},
        {"j", 4},
    },

    tempo = {
        {"A", 1},
        {"E", 4},
        {"B", 20},
        {"A", 2},
        {"D", 4},
        {"C", 16},
    },

    tempomul = 1,
}
