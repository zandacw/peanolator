type t = {
    pos : int;
    stream : char list 
}

type error = {
    location : int;
    desc : string
}

type sign = 
    | Plus
    | Minus

type ast =
    Const of int 
    | Add of ast * ast
    | Sub of ast * ast
    | Mul of ast * ast
    | Div of ast * ast
    | Mod of ast * ast
    | Exp of ast * ast

let init (s:string) : t = {
    pos = 0;
    stream = s 
        |> String.to_seq 
        |> List.of_seq 
        |> List.filter (fun c -> c <> ' ')
}

let str_of_chars (cs: char list) : string = 
    cs |> List.to_seq |> String.of_seq

type 'a parser = {
    run: t -> (('a * t), error) result
}

let return (a: 'a) : 'b parser = {
    run = fun input -> Ok(a, input)
}

let ch (c:char) : char parser =  {
    run = fun input -> 
        match input.stream with 
        | [] -> Error { location = input.pos; desc = "eof" }
        | x :: xs ->  if x = c
            then Ok (c,  { pos = input.pos + 1; stream = xs })
            else Error { 
                location = input.pos; 
                desc = Printf.sprintf 
                    "@ %d: got '%c', expected '%c'" 
                    input.pos c x 
            }
}

let alpha : char parser = {
    run = fun input ->
        match input.stream with
        | [] -> Error { location = input.pos; desc = "eof" }
        | x :: xs -> match x with
            | 'a'..'z' | 'A'..'Z' -> 
                Ok (x, { pos = input.pos + 1; stream = xs })
            | _ -> Error {
                location = input.pos;
                desc = Printf.sprintf
                    "@ %d: got '%c', expected 'alpha'"
                    input.pos x 
            }
}

let digit : char parser = {
    run = fun input ->
        match input.stream with
        | [] -> Error { location = input.pos; desc = "eof" }
        | x :: xs -> match x with
            | '0'..'9' -> Ok (x, { pos = input.pos + 1; stream = xs })
            | _ -> Error {
                location = input.pos;
                desc = Printf.sprintf
                    "@ %d: got '%c', expected 'digit'"
                    input.pos x 
            }
}

let ( <|> ) (a: 'a parser) (b: 'b parser) : 'c parser = {
    run = fun input ->
        match a.run input with
        | Ok (c, input) -> Ok (c, input)
        | Error _ -> b.run input
}

let ( *> ) (a: 'a parser) (b: 'b parser) : 'c parser = {
    run = fun input ->
        match a.run input with
        | Error e -> Error e
        | Ok (c, input) -> b.run input
}

let ( <* ) (a: 'a parser) (b: 'b parser) : 'c parser = {
    run = fun input ->
        match a.run input with
        | Error e -> Error e
        | Ok (c, input) -> match b.run input with
            | Error e -> Error e
            | Ok (_, input) -> Ok (c, input)
}

let ( >> ) (x:'a parser) (f:'a -> 'b) : ('b parser) = {
    run = fun input ->
        match x.run(input) with 
        | Error e -> Error e
        | Ok (a, input) -> Ok (f a, input)
}


let ( >>= )  (x:'a parser) (f:'a -> 'b parser) : ('b parser) = {
    run = fun input -> 
        match x.run(input) with
        | Error e -> Error e
        | Ok (a, input) -> (f a).run(input)
}
let ( let* ) = ( >>= )

let ( >>. ) (a:'a parser) (b:'b parser) : ('a * 'b) parser = 
    a >>= fun a_res -> b >> fun b_res -> a_res, b_res
let andthen = ( >>. )

let ( <*> ) (f: ('a->'b) parser) (a:'a parser) : 'b parser = 
    f >>. a >> fun (f,x) -> f x
let apply = ( <*> )

let fail (msg:string) : 'a parser = { 
    run = fun input -> Error {
        location = input.pos; 
        desc = "no match"
    } 
}

let choice (ps: 'a parser list) : 'a parser = 
    List.fold_left (<|>) (fail "no match in choice") ps

let many (p: 'a parser) : ('a list parser) = {
    run = fun input ->
        let rec aux acc input : 'a list * t =
            match p.run input with
            | Error _ -> List.rev acc, input
            | Ok (r, input) -> aux (r :: acc) input
        in
        Ok(aux [] input)
}

let many1 (p: 'a parser) : ('a list parser) = many p >>= fun r -> {
    run = fun input -> 
        if List.is_empty r 
        then Error {
            location = input.pos;
            desc = "expected alteast one match"
        }
        else Ok(r, input)
}

let opt (p:'a parser) = 
    (p >> fun x -> Some x) <|> 
    return None

let whitespace : (string parser) = 
    many (
        ch ' ' 
        <|> ch '\n' 
        <|> ch '\t' 
        <|> ch '\r'
    ) >> str_of_chars

let const x _ = x

let add_sign sign d = match sign with
    | Some Minus -> d * -1
    | _ -> d

let number : int parser = 
    opt (
        ch '-' 
        >> const Minus <|> (
            ch '+' 
            >> const Plus
        )
    ) 
    >>. (
        many1 digit 
        >> str_of_chars
    )
    >> fun (sign, digits) -> ( 
        int_of_string digits |> add_sign sign 
    )


let parse_const = number >> fun i -> Const i
let fix f =
    let rec p = lazy (f r)
    and r = { run = fun input ->
        (Lazy.force p).run input }
    in
    r

let rec ( ^ ) x y = 
    if y <= 0 then 1
    else x * ( ^ ) x (y - 1) 

let parse_expr = fix @@ fun parse_expr ->
    let term =
        let factor =
            (parse_const >>= return) <|>
            (ch '(' *> parse_expr <* ch ')')
        in
        let unary =
            (ch '+' *> factor) <|>
            (ch '-' *> factor 
                >>= fun right -> return (Mul(Const (-1), right))
            ) in let add = ch '+' in
        let sub = ch '-' in
        let modulus = ch '%' in
        let mul = ch '*' in
        let div = ch '/' in
        let exp = ch '^' in
        let rec aux left =
            (add *> parse_expr >>= fun right -> return (Add(left, right))) <|>
            (sub *> parse_expr >>= fun right -> return (Sub(left, right))) <|>
            (modulus *> factor >>= fun right -> aux (Mod(left, right))) <|>
            (mul *> factor >>= fun right -> aux (Mul(left, right))) <|>
            (div *> factor >>= fun right -> aux (Div(left, right))) <|>
            (exp *> factor >>= fun right -> aux (Exp(left, right))) <|>
            return left
        in
        factor <|> unary >>= aux
    in
    term


let rec evaluate (a:ast) : int =
    match a with 
    | Const i -> i
    | Add (x,y) -> evaluate x + evaluate y
    | Sub (x,y) -> evaluate x - evaluate y
    | Mod (x,y) -> (evaluate x) mod (evaluate y)
    | Mul (x,y) -> evaluate x * evaluate y
    | Div (x,y) -> evaluate x / evaluate y
    | Exp (x,y) -> evaluate x ^ evaluate y


let rec show (a:ast) : string = 
    match a with 
    | Const i -> (string_of_int i)
    | Add (x,y) -> Printf.sprintf "(%s + %s)" (show x) (show y)
    | Sub (x,y) -> Printf.sprintf "(%s - %s)" (show x) (show y)    
    | Mod (x,y) -> Printf.sprintf "(%s %% %s)" (show x) (show y)   
    | Mul (x,y) -> Printf.sprintf "(%s * %s)" (show x) (show y)  
    | Div (x,y) -> Printf.sprintf "(%s / %s)" (show x) (show y)  
    | Exp (x,y) -> Printf.sprintf "(%s ^ %s)" (show x) (show y)  







