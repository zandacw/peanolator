type p = 
    Z |
    S of p |
    D of p

let dec (x:p) : p = 
    match x with
    | Z -> D Z
    | S i -> i
    | x -> D x

let n (x:int) : p = 
    let rec aux acc = function
        | 0 -> acc
        | x -> 
            if x > 0 
            then aux (S acc) (x - 1)
            else aux (D acc) (x + 1)
    in
    aux Z x

let to_int (n:p) : int =
    let rec aux acc = function
        | Z -> acc
        | S n -> aux (acc + 1) n
        | D n -> aux (acc - 1) n
    in 
    aux 0 n


let repr (n:p) : string =
    let rec aux count p = 
        match p with 
        | Z -> "Z"
        | S p' -> if count >= 10 
            then "..."
            else "S(" ^ aux (count + 1) p' ^ ")"
        | D p' -> if count >= 10
            then "..."
            else "D(" ^ aux (count + 1) p' ^ ")"
    in aux 0 n


let ( + ) (x:p) (y:p) : p = 
    let rec aux acc = function
        | Z -> acc
        | S y -> aux (S acc) y
        | D y -> aux (dec acc) y
    in 
    aux x y

let ( - ) (x:p) (y:p) : p = 
    let rec aux acc = function
        | Z -> acc
        | S y -> aux (dec acc) y
        | D y -> aux (S acc) y
    in
    aux x y

let ( * ) (x:p) (y:p) : p =
    let rec aux acc = function
        | Z -> acc
        | S y -> aux (acc + x) y
        | D y -> aux (acc - x) y
    in
    aux Z y

let ( ^ ) (x:p) (y:p) : p = 
    let rec aux acc = function
        | Z -> acc
        | S y -> aux (acc * x) y
        | D _ -> failwith "negative exponent in ( ^ ) fn"
    in
    aux (S Z) y


let ( <= ) (x:p) (y:p) : bool =
    match x - y with
    | Z | D _ -> true
    | S _ -> false

let ( >= ) = (fun f x y -> f y x) ( <= )

let make_pos (x:p) : p =
    match x with
    | Z | S _ -> x
    | D _ -> (D Z) * x

let ( / ) (x:p) (y:p) : p =
    let sign = match x, y with
        | D _, S _ | S _, D _ -> D Z
        | _ -> S Z 
    in
    let x = make_pos x in
    let y = make_pos y in
    let rec aux acc x =
        if x - (dec y) <= Z
        then acc
        else aux (S acc) (x - y)
    in aux Z x * sign

let ( % ) (x:p) (y:p) : p =
    let rec aux acc n =
        if acc - (dec y) <= Z 
        then acc 
        else aux (acc - y) (dec n) 
    in
    if x >= Z && y >= Z
    then aux x y
    else Z 
