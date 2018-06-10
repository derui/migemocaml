(** Regexp_gen provides function to construct regular expression from
    inputted string.
*)

type code = int64

type t =
  | Nil
  | Node of code * t * t

let operator_select_in = "["
let operator_select_out = "]"
let operator_nest_in = "("
let operator_nest_out = ")"
let operator_or = "|"

(* Get string representation of [t] *)
let to_string t =
  let rec to_string' nest = function
  | Nil -> "()"
  | Node (code, sib, child) ->
    Printf.sprintf "\n%s(code: %Ld, sib = %s, child = %s)"
      (String.make nest ' ')
      code
      (to_string' (succ nest) sib)
      (to_string' (succ nest) child)
  in
  to_string' 0 t

(** Add [word] to engine [t]. This function is immutable. *)
let add_word ~word t =
  let module C = Charset.Utf8 in
  let rec construct_tree buf t =
    (* Drop child pattern that is longer than the [buf]. *)
    if String.length buf = 0 then Nil
    else begin
      match C.raw_to_character buf with
      | None -> t
      | Some (code, skip) -> begin
          let buf' = snd @@ Util.take ~size:skip buf in
          match t with
          | Nil -> Node (code, Nil, construct_tree buf' Nil)
          | Node (code', _, Nil) as t when code' = code -> t
          | Node (code', sib, child) ->
            if code' = code then Node (code', sib, construct_tree buf' child)
            else Node (code', construct_tree buf sib, child)
        end
    end
  in
  construct_tree word t

(** Get empty tree *)
let empty = Nil

(** Get current layer having sibling *)
let has_siblings = function
  | Nil -> false
  | Node (_, Nil, _) -> false
  | Node (_, Node _, _) -> true

let has_child = function
  | Nil -> false
  | Node (_, _, Nil) -> false
  | Node (_, _, Node _) -> true

(** Get current layer contains nodes that has child *)
let rec has_children = function
  | Nil -> false
  | Node (_, sib, Nil) -> has_children sib
  | Node (_, sib, Node _) -> true

let to_sibling_list t =
  let rec inner_sibling_list accum = function
    | Nil -> List.rev accum
    | Node (code, sib, _) as t -> inner_sibling_list (t :: accum) sib
  in
  inner_sibling_list [] t

(** Generate the regular expression from tree created by words. *)
let generate t =
  (* Generate regexp for sibling node that does not have child. *)
  let generate_sibling_rule t =
    let list = to_sibling_list t in
    let rules = List.rev @@ List.fold_left (fun rules node ->
        if not @@ has_child node then
          match node with
          | Nil -> rules
          | Node (code, _, _) -> Charset.Utf8.character_to_raw code :: rules
        else rules
      ) [] list
    in
    if List.length rules > 1 then operator_select_in ^ String.concat "" rules ^ operator_select_out
    else String.concat "" rules
  in

  (* Generate regexp from nodes have child and not child. *)
  let rec inner_generate t =
    let list = to_sibling_list t in
    let rule_for_not_having_child = generate_sibling_rule t in
    (* Child node will nested, and concat [operator_or] each rules *)
    let rules_for_having_child = List.rev @@ List.fold_left (fun rules node ->
        if has_child node then
          match node with
          | Nil -> rules
          | Node (code, _, child) ->
            let rule = Charset.Utf8.character_to_raw code ^ inner_generate child in
            rule :: rules
        else rules
      ) [] list
    in
    let rule_for_having_child = String.concat operator_or rules_for_having_child in
    let rule = match (rule_for_not_having_child, rule_for_having_child) with
      | ("", "") -> ""
      | ("", v) -> v
      | (v, "") -> v
      | (sib_rule, child_rule) -> sib_rule ^ operator_or ^ child_rule
    in
    if List.length list > 1 && has_child t then
      operator_nest_in ^ rule ^ operator_nest_out
    else rule
  in
  inner_generate t
