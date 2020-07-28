functor
export
    rows:Rows
    cols:Cols
    map:Map
    tiles:Tiles
    items:Items
    players:Players
    colors:PlayerColors
    spawns:PlayerSpawns
    controls:PlayersControls
    lives:PlayersLives
    radius:BombRadius
define
    Rows = 11
    Cols = 19
    Map = [
        [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
        [1 4 3 3 3 3 3 3 3 4 3 3 3 3 3 3 3 4 1]
        [1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1]
        [1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1]
        [1 3 1 3 1 2 1 3 1 3 1 3 1 2 1 3 1 3 1]
        [1 4 3 3 2 2 2 3 3 4 3 3 2 2 2 3 3 4 1]
        [1 3 1 3 1 2 1 3 1 3 1 3 1 2 1 3 1 3 1]
        [1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1]
        [1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1]
        [1 4 3 3 3 3 3 3 3 4 3 3 3 3 3 3 3 4 1]
        [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
    ]

    Tiles = [wall empty box chest]
    Items = [box chest fire bomb coin coins]

    Players = 2
    PlayerColors = [green red]
    PlayerSpawns = [pos(x:6 y:6) pos(x:14 y:6)]
    PlayersControls = [
        ["<Return>" "<Left>" "<Right>" "<Up>" "<Down>"]
        ["<space>" "<q>" "<d>" "<z>" "<s>"]
    ]
    PlayersLives = 3

    BombRadius = 3
end