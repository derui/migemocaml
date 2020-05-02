(** Dict_tree module provides tree structure for migemo dictionary. *)

type word_list = string list

(** [node] has a character in the word, and multibyte-word mapped in dictionary *)
module Attr = struct
  type t = {
    char : char;
    word_list : word_list;
  }

  let equal v1 v2 = Char.equal v1.char v2.char && List.for_all2 String.equal v1.word_list v2.word_list

  let show t = Printf.sprintf "[%c;%s]" t.char (String.concat "," t.word_list)

  let pp fmt t = Format.fprintf fmt "%s" @@ show t
end

type node = Attr.t

(** [t] is a type represented character-base tree. This tree have nodes and leaf. [Leaf] is the last character of the
    word and have list of words mapped by dict. [Node] is as Leaf, but has children if dictionary contains word
    including [Node]'s character. *)
type t =
  | Nil
  (* node is data of Node. first t is sibling node, and second t is child node. *)
  | Node of node * t * t

let rec show = function
  | Nil               -> "Nil"
  | Node (node, l, r) -> Printf.sprintf "(%s, %s, %s)" (Attr.show node) (show l) (show r)

let pp fmt t = Format.fprintf fmt "%s" @@ show t

let rec equal v1 v2 =
  match (v1, v2) with
  | Nil, Nil                             -> true
  | Node _, Nil | Nil, Node _            -> false
  | Node (v1, l1, r1), Node (v2, l2, r2) -> Attr.equal v1 v2 && equal l1 l2 && equal r1 r2

(** Make a tree from list of dict *)
let make_tree list =
  let rec construct_tree tree buf words =
    if String.length buf = 0 then tree
    else
      let ch = buf.[0] in
      match tree with
      | Nil                  ->
          let tree = Node ({ Attr.char = ch; word_list = [] }, Nil, Nil) in
          construct_tree tree buf words
      | Node (v, sib, child) ->
          if v.Attr.char = ch then
            if String.length buf = 1 then Node ({ v with Attr.word_list = v.word_list @ words }, sib, child)
            else
              let _, rest = Util.take ~size:1 buf in
              let child = construct_tree child rest words in
              Node (v, sib, child)
          else
            let sib = construct_tree sib buf words in
            Node (v, sib, child)
  in
  List.fold_left (fun tree (buf, words) -> construct_tree tree buf words) Nil list

(** Send [query] to find longest matching content in [tree]. *)
let query ~query tree =
  let rec inner_query query tree =
    if String.length query = 0 then None
    else
      match tree with
      | Nil                       -> None
      | Node (v, sib, child) as t ->
          if query.[0] = v.Attr.char then
            if String.length query = 1 then Some t else inner_query Util.(snd @@ take query) child
          else inner_query query sib
  in
  inner_query query tree

(** Send [query] to find node in [tree] longest forward exact matched [query]. *)
let forward_match ~query tree =
  let rec inner_match query tree length =
    if String.length query = 0 then None
    else
      match tree with
      | Nil                  -> None
      | Node (v, sib, child) ->
          if query.[0] = v.Attr.char then
            match inner_match Util.(snd @@ take query) child (succ length) with
            | None        -> Some (v.Attr.word_list, length)
            | Some _ as v -> v
          else inner_match query sib length
  in
  inner_match query tree 1

(** Traverse tree as depth priority. *)
let traverse ~f tree =
  let rec inner_traverse ~f = function
    | Nil                  -> ()
    | Node (v, sib, child) ->
        inner_traverse ~f child;
        f v;
        inner_traverse ~f sib
  in
  match tree with
  | Nil                -> ()
  | Node (v, _, child) ->
      f v;
      inner_traverse ~f child

let parse_dict ic =
  let module P = Migemo_dict_parser in
  let module L = Migemo_dict_lexer in
  P.dict L.token Lexing.(from_channel ic)

let parse_conv ic =
  let module P = Migemo_conv_parser in
  let module L = Migemo_conv_lexer in
  P.dict L.token Lexing.(from_channel ic)

let with_open ~f filename =
  let ic = open_in filename in
  let ret =
    try f ic
    with _ as e ->
      close_in ic;
      raise e
  in
  close_in ic;
  ret

(** Load tree from file. *)
let load_dict filename =
  if not @@ Sys.file_exists filename then None
  else
    let dict = with_open ~f:parse_dict filename in
    Some (make_tree dict)

(** Load tree from file as conversion file. *)
let load_conv filename =
  if not @@ Sys.file_exists filename then None
  else
    let dict = with_open ~f:parse_conv filename in
    Some (make_tree dict)
