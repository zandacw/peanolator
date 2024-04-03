open Parser
open Peano


let rec eval (ast:Parser.ast) : Peano.p =
    let open Parser in
    let open Peano in
    match ast with 
    | Const i -> Peano.n i
    | Add (x,y) -> eval x + eval y
    | Sub (x,y) -> eval x - eval y
    | Mod (x,y) -> (eval x) % (eval y)
    | Mul (x,y) -> eval x * eval y
    | Div (x,y) -> eval x / eval y
    | Exp (x,y) -> eval x ^ eval y

let rec loop () =
    print_string "peano> ";
    let input = read_line () in
    let ast = input |> Parser.init |> Parser.parse_expr.run in
    let _ = match ast with 
        | Ok (ast, _) -> eval ast |> Peano.show |> Printf.printf "= %d\n"
        | Error e -> Printf.printf "Error: %s @ %d" e.desc e.pos;
    in
    loop ()

let () = loop ()
