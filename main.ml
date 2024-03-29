type p = Z | S of p

let suc (x:p) = S x

let dec (x:p) = 
    match x with
    | Z -> Z
    | S i -> i

let rec num n = 
    if n <= 0 
    then Z 
    else num (n-1) |> suc 

let rec ( + ) (x:p) (y:p) : p = 
    match y with
    | Z -> x
    | S y -> ( + ) (suc x)  y

let rec ( * ) (x:p) (y:p) : p =
    match y with
    | Z -> Z
    | S y -> ( * ) x y |> ( + ) x 

let rec ( - ) (x:p) (y:p) : p = 
    match y with
    | Z -> x
    | S y -> ( - ) (dec x) y

let rec ( / ) (x:p) (y:p) : p =
    if x - (dec y) = Z then Z 
    else suc (( / ) (( - ) x y) y)
