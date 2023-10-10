soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day7",
    seq = {
        {"g", 3},
        {"a", 1},
        {"g", 3},
        {"b", 1},
    },

    tempo = {
        {"A", 1},
        {"B", 4},
        {"A", 1},
        {"B", 2},
        {"C", 1},
    }
}
