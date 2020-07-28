functor
import Player Gui Data System OS
define Self GP Loop RecordAdjoinRec
    InitBoard Move OnBoard FreeTile Bomb Fire FindWinner
in
    fun{InitBoard} Board InitRow InitRows in
        proc{InitRow Row I J}
            case Row
            of nil then skip
            [] Col|Cols then
                Board.I.J = {List.nth Data.tiles Col}
                {InitRow Cols I J+1}
            end
        end
        proc{InitRows Rows I}
            case Rows
            of nil then skip
            [] R|Rs then
                Board.I = {Tuple.make row Data.cols}
                {InitRow R I 1}
                {InitRows Rs I+1}
            end
        end
        Board = {Tuple.make board Data.rows}
        {InitRows Data.map 1}
        Board
    end

    fun{Move pos(x:X y:Y) Direction}
        case Direction
        of left then pos(x:X-1 y:Y)
        [] right then pos(x:X+1 y:Y)
        [] up then pos(x:X y:Y-1)
        [] down then pos(x:X y:Y+1)
        end
    end

    fun{OnBoard pos(x:X y:Y)}
        X > 0 andthen X =< Data.cols andthen
        Y > 0 andthen Y =< Data.rows
    end

    fun{FreeTile Pos Tile Players}
        {Not {List.member Tile [wall box chest bomb]}} andthen
        {Not {Record.some Players fun{$ player(pos:P ...)} P == Pos end}}
    end

    proc{Bomb Pos Board Players}
        proc{Fire Pos Direction Range}
            if Range == 0 then skip
            else pos(x:X y:Y) = {Move Pos Direction} in
                if {OnBoard pos(x:X y:Y)} then
                    case Board.Y.X
                    of wall then skip
                    [] box then {Send Self box(pos(x:X y:Y))}
                    [] chest then {Send Self chest(pos(x:X y:Y))}
                    else
                        {Send Self fire(pos(x:X y:Y))}
                        {Fire pos(x:X y:Y) Direction Range-1}
                    end
                end
            end
        end
        Directions = [left right up down]
    in
        {Send Self fire(Pos)}
        {List.forAll Directions proc{$ X} {Fire Pos X Data.radius} end}
    end

    fun{Fire Pos Player}
        if Player.pos == Pos then Spawn in
            if Player.life == 1 then {Send Self dead(player:Player.id)} end
            Spawn = {List.nth Data.spawns Player.id}
            {Send GP movePlayer(Player.id Spawn)}
            {Send GP update(player:Player.id field:life value:Player.life-1)}
            {Record.adjoin Player player(life:Player.life-1 pos:Spawn)}
        else Player end
    end

    fun{FindWinner Players}
        Ids = {Record.arity Players} in
        {List.foldL Ids fun{$ Id1 Id2}
            if Players.Id1.coin >= Players.Id2.coin then Id1 else Id2 end
        end Ids.1}
    end

    proc{RecordAdjoinRec Rec Fields Value ?Res}
        case Fields
        of nil then Res = Value
        [] H|T then Label in
            Label = {Record.label Rec}
            Res = {Record.adjoin Rec Label(H:_)}
            {RecordAdjoinRec Rec.H T Value Res.H}
        end
    end

    proc{Loop Stream Board Players Boxes}
        case Stream.1
        of move(player:Id direction:Dir) then Pos X Y in
            Pos = {Move Players.Id.pos Dir}
            pos(x:X y:Y) = Pos
            if {OnBoard Pos} andthen {FreeTile Pos Board.Y.X Players} then
                Board2 Players2 Nb Player
            in
                case Board.Y.X
                of coin then
                    Nb = Players.Id.coin + 1
                    Board2 = {RecordAdjoinRec Board [Y X] empty}
                    {Send GP hide(coin Pos)}
                [] coins then
                    Nb = Players.Id.coin + 3
                    Board2 = {RecordAdjoinRec Board [Y X] empty}
                    {Send GP hide(coins Pos)}
                else
                    Nb = Players.Id.coin
                    Board2 = Board
                end
                
                Player = {Record.adjoin Players.Id player(coin:Nb pos:Pos)}
                Players2 = {Record.adjoin Players players(Id:Player)}
                {Send GP movePlayer(Id Pos)}
                {Send GP update(player:Id field:coin value:Nb)}
                {Loop Stream.2 Board2 Players2 Boxes}
            else {Loop Stream.2 Board Players Boxes} end

        [] bomb(player:Id) then
            if Players.Id.bomb then
                Pos = Players.Id.pos
                Players2 = {RecordAdjoinRec Players [Id bomb] false}
                Board2 = {RecordAdjoinRec Board [Pos.y Pos.x] bomb}
                Chrono = 500 + {OS.rand} mod 2000
            in
                {Send GP spawn(bomb Pos)}
                thread {Delay Chrono} {Send Self bomb(player:Id Pos)} end
                {Loop Stream.2 Board2 Players2 Boxes}
            else {Loop Stream.2 Board Players Boxes} end

        [] bomb(player:Id Pos) then Players2 Board2 in
            Players2 = {RecordAdjoinRec Players [Id bomb] true}
            Board2 = {RecordAdjoinRec Board [Pos.y Pos.x] empty}
            {Send GP hide(bomb Pos)}
            {Bomb Pos Board2 Players2}
            {Loop Stream.2 Board2 Players2 Boxes}

        [] fire(Pos) then Players2 in
            Players2 = {Record.map Players fun{$ Player} {Fire Pos Player} end}
            {Send GP spawn(fire Pos)}
            thread {Delay 500} {Send GP hide(fire Pos)} end
            {Loop Stream.2 Board Players2 Boxes}

        [] box(Pos = pos(x:X y:Y)) then Board2 in
            Board2 = {RecordAdjoinRec Board [Y X] coin}
            {Send GP hide(box Pos)}
            {Send GP spawn(coin Pos)}
            if Boxes == 1 then
                {Send Self winner(player:{FindWinner Players})}
            end
            {Loop Stream.2 Board2 Players Boxes-1}

        [] chest(Pos = pos(x:X y:Y)) then Board2 in
            Board2 = {RecordAdjoinRec Board [Y X] coins}
            {Send GP hide(chest Pos)}
            {Send GP spawn(coins Pos)}
            {Loop Stream.2 Board2 Players Boxes}

        [] dead(player:Id) then Players2 in
            {Send GP hidePlayer(Id)}
            Players2 = {Record.subtract Players Id} 
            if {Record.width Players2} == 1 then
                {Send Self winner(player:{FindWinner Players2})}
            end
            {Loop Stream.2 Board Players2 Boxes}

        [] winner(player:Id) then
            {System.show 'player'#Id#'won'}

        [] Msg then
            {System.show 'error'#Msg}
            {Loop Stream.2 Board Players Boxes}
        end
    end

    local Stream Window Players CountBoxes in
        GP = {Gui.start Window}
        Players = {Tuple.make players Data.players}
        Self = {NewPort Stream}

        for Id in 1..Data.players do
            Players.Id = player(id:Id coin:0 bomb:true life:Data.lives pos:_)
            Players.Id.pos = {List.nth Data.spawns Id}
            {Player.start Id Self Window}
        end

        CountBoxes = fun{$ Sum Row}
            Sum + {List.length {List.filter Row fun{$ X} X == 3 end}}
        end
        {Loop Stream {InitBoard} Players {List.foldL Data.map CountBoxes 0}}
    end
end