functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    Data
export start:Start
define Start ConfigureCell ConfigureBoard Loop Gifs TS = 50
in
    fun{Start Window} Grid Board Score Stream Players NP in
        Gifs = {Record.make gifs life|player|Data.items}
        for Item in {Record.arity Gifs} do File in
            File = {Append "gif/" {Append {Atom.toString Item} ".gif"}}
            Gifs.Item = {QTk.newImage photo(file:File)}
        end

        NP = Data.players
        Grid = grid(handle:_ height:TS*Data.rows width:TS*Data.cols)
        Score = grid(handle:_ height:2*TS width:NP+1)
        Window = {QTk.build td(Grid Score)}
        {Window show}
        {ConfigureBoard Board Grid.handle}

        for N in 0..1 do {Score.handle rowconfigure(N minsize:TS pad:5)} end
	    for N in 0..NP do {Score.handle columnconfigure(N minsize:TS pad:5)} end

        local
            Life = label(width:TS height:TS image:Gifs.life)
            Coin = label(width:TS height:TS image:Gifs.coin)
        in
            {Score.handle configure(Life row:0 column:0 sticky:wesn)}
            {Score.handle configure(Coin row:1 column:0 sticky:wesn)}
        end

        Players = {Tuple.make players NP}
        for Id in 1..NP do
            Color = {List.nth Data.colors Id}
            Pos = {List.nth Data.spawns Id}
            Img = label(handle:_ width:TS height:TS bg:Color image:Gifs.player)
            Life = label(handle:_ text:"3" borderwidth:5 relief:solid bg:Color)
            Coin = label(handle:_ text:"0" borderwidth:5 relief:solid bg:Color)
        in
            Players.Id = '#'(img:Img.handle life:Life.handle coin:Coin.handle)
            {Grid.handle configure(Img row:Pos.y column:Pos.x)}
            {Score.handle configure(Life row:0 column:Id sticky:wesn)}
            {Score.handle configure(Coin row:1 column:Id sticky:wesn)}
        end

        thread {Loop Stream Grid.handle Board Players} end
        {NewPort Stream}
    end

    fun{ConfigureCell Grid Tile I J}
        fun{ConfigureItem Item} Widget Gif in
            Gif = Gifs.Item
            Widget = label(handle:_ width:TS height:TS bg:c(0 0 204) image:Gif)
            {Grid configure(Widget row:I column:J sticky:wesn)}
            {Grid remove(Widget.handle)}
            Widget.handle
        end
        Wall = td(width:TS height:TS bg:c(0 0 0) borderwidth:5 relief:raised)
        Empty = td(width:TS height:TS bg:c(0 0 204))
    in
        case Tile
        of 1 then
            {Grid configure(Wall row:I column:J sticky:wesn)}
            nil
        [] 2 then R in
            {Grid configure(Empty row:I column:J sticky:wesn)}
            R = {Record.make items Data.items}
            {List.forAll Data.items proc{$ X} {ConfigureItem X R.X} end}
            R
        else Label R in
            {Grid configure(Empty row:I column:J sticky:wesn)}
            Label = {List.nth Data.tiles Tile}
            R = {Record.make items Data.items}
            {List.forAll Data.items proc{$ X} {ConfigureItem X R.X} end}
            {Grid configure(R.Label row:I column:J)}
            R
        end
    end

    proc{ConfigureBoard Board Grid}
        proc{ConfigureRow Row I J}
            case Row
            of nil then skip
            [] Col|Cols then
                Board.I.J = {ConfigureCell Grid Col I J}
                {ConfigureRow Cols I J+1}
            end
        end
        proc{ConfigureRows Rows I}
            case Rows
            of nil then skip
            [] R|Rs then
                Board.I = {Tuple.make col Data.cols}
                {ConfigureRow R I 1}
                {ConfigureRows Rs I+1}
            end
        end
    in
	    for N in 1..Data.rows do {Grid rowconfigure(N minsize:TS)} end
	    for N in 1..Data.cols do {Grid columnconfigure(N minsize:TS)} end
        Board = {Tuple.make row Data.rows}
        {ConfigureRows Data.map 1}
    end

    proc{Loop Stream Grid Board Players}
        case Stream.1
        of movePlayer(Id pos(x:J y:I)) then
            {Grid remove(Players.Id.img)}
            {Grid configure(Players.Id.img row:I column:J)}
        [] update(player:Id field:F value:V) then
            {Players.Id.F set(text:V)}
        [] hidePlayer(Id) then
            {Grid remove(Players.Id.img)}
        [] spawn(Item pos(x:J y:I)) then
            {Grid configure(Board.I.J.Item)}
        [] hide(Item pos(x:J y:I)) then
            {Grid remove(Board.I.J.Item)}
        end
        {Loop Stream.2 Grid Board Players}
    end
end