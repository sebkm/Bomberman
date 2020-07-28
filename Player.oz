functor
import Data
export start:Start
define Start
in
    proc{Start Id Serv Window} C Binding Move in
        C = {List.nth Data.controls Id}
        Binding = fun{$ E Dir} bind(event:E action:proc{$} {Move Dir} end) end
        Move = proc{$ Dir} {Send Serv move(player:Id direction:Dir)} end
        {List.forAll {List.zip C.2 [left right up down] Binding} Window}
        {Window bind(event:C.1 action:proc{$} {Send Serv bomb(player:Id)} end)}
    end
end