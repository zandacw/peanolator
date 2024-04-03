open Parser

let rec eval (ast:Parser.ast) : Peano.p =
    match ast with 
    | Parser.Const i -> Peano.n i
    | Parser.Add (x,y) -> Peano.( + ) (eval x) (eval y)
    | Parser.Sub (x,y) -> Peano.( - ) (eval x) (eval y)
    | Parser.Mod (x,y) -> Peano.( % ) (eval x) (eval y)
    | Parser.Mul (x,y) -> Peano.( * ) (eval x) (eval y)
    | Parser.Div (x,y) -> Peano.( / ) (eval x) (eval y)
    | Parser.Exp (x,y) -> Peano.( ^ ) (eval x) (eval y)

let rec loop () =
    print_string "peano> ";
    let input = read_line () in
    let ast = input |> Parser.init |> Parser.parse_expr.run in
    let _ = match ast with 
        | Ok (ast, _) -> 
            let peano_result = eval ast in
            let bracketed_repr = Parser.show ast in
            Printf.printf "%s\n= %d\n" 
                bracketed_repr 
                (Peano.to_int peano_result)
        | Error e -> Printf.printf 
            "Error: %s @ %d" 
            e.desc 
            e.location;
    in
    loop ()

let () = loop ()
