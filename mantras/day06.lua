soundmantra = require("soundmantra")

soundmantra.generate {
    name = "day06",
    seq = {
        {"e", 16},
        {"f", 24},
        {"d", 8},
        {"a", 1},
        -- note how this changes over time.
        -- this is a bug, that I believe has to do with
        -- the a weakness in the gesture algorithm
        -- UPDATE: fixed by adding another rephasor
        {"b", 3},
        {"a", 1 + 12 - 2},
    },
    -- nbeats = 18
}
