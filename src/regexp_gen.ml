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
    Printf.sprintf "(code: %Ld\n%ssib = %s\n%schild = %s)\n"
      code
      (String.make nest ' ')
      (to_string' (succ nest) sib)
      (String.make nest ' ')
      (to_string' (succ nest) child)
  in
  to_string' 0 t

(** Add [word] to engine [t]. This function is immutable. *)
let add_word ~word t =
  let rec construct_tree char_list t =
    (* Drop child pattern that is longer than the [buf]. *)
    match char_list with
    | [] -> Nil
    | code :: rest -> begin
        match t with
        | Nil -> Node (code, Nil, construct_tree rest Nil)
        | Node (code', _, Nil) as t when code' = code -> t
        | Node (code', sib, child) ->
          if code' = code
          then Node (code', sib, construct_tree rest child)
          else Node (code', construct_tree char_list sib, child)
    end
  in
  let module C = Charset.Utf8 in
  let rec buf_to_code_list buf accum =
    match C.raw_to_character buf with
    | None -> List.rev accum
    | Some (code, skip) ->
      let buf' = snd @@ Util.take ~size:skip buf in
      buf_to_code_list buf' (code :: accum)
  in

  construct_tree (buf_to_code_list word []) t

(** Get empty tree *)
let empty = Nil

let has_child = function
  | Nil -> false
  | Node (_, _, Nil) -> false
  | Node (_, _, Node _) -> true

(** Get current layer contains nodes that has child *)
let rec has_children = function
  | Nil -> false
  | Node (_, sib, Nil) -> has_children sib
  | Node (_, _, Node _) -> true

let to_sibling_list t =
  let rec inner_sibling_list accum = function
    | Nil -> List.rev accum
    | Node (_, sib, _) as t -> inner_sibling_list (t :: accum) sib
  in
  inner_sibling_list [] t

(** Generate the regular expression from tree created by words. *)
let generate t =
  (* Generate regexp for sibling node that does not have child. *)
  let generate_sibling_rule list =
    let rules = List.fold_left (fun rules node ->
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
    let rule_for_not_having_child = generate_sibling_rule list in
    (* Child node will nested, and concat [operator_or] each rules *)
    let rules_for_having_child = List.fold_left (fun rules node ->
        if has_child node then
          match node with
          | Nil -> failwith "this branch should unreach"
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
    if List.length list > 1 && has_children t then
      operator_nest_in ^ rule ^ operator_nest_out
    else rule
  in
  inner_generate t
