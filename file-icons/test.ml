type expr =
  | Int of int
  | Add of expr * expr
  | Mul of expr * expr
  | Var of string

let rec eval env = function
  | Int n -> n
  | Add (a, b) -> eval env a + eval env b
  | Mul (a, b) -> eval env a * eval env b
  | Var name ->
    (match List.assoc_opt name env with
     | Some v -> v
     | None -> failwith ("Unbound variable: " ^ name))

let rec to_string = function
  | Int n -> string_of_int n
  | Add (a, b) -> "(" ^ to_string a ^ " + " ^ to_string b ^ ")"
  | Mul (a, b) -> "(" ^ to_string a ^ " * " ^ to_string b ^ ")"
  | Var name -> name

let () =
  let expr = Add (Mul (Int 2, Var "x"), Int 5) in
  let result = eval [("x", 3)] expr in
  Printf.printf "%s = %d\n" (to_string expr) result
