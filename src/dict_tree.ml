(** Word_tree module provides tree structure for migemo dictionary. *)

type word_list = bytes list

(** [node] has a character in the word, and multibyte-word mapped in dictionary *)
type node = {
  char: char;
  word_list: word_list;
}

(** [t] is a type represented character-base tree.
    This tree have nodes and leaf. [Leaf] is the last character of the word and
    have list of words mapped by dict.
    [Node] is as Leaf, but has children if dictionary contains word including [Node]'s character.
*)
type t =
  | Leaf of node
  | Node of node * t list

type tree = t list

(** Search a node that has specified character [ch]. Return option to be found or not *)
let rec find_node ch = function
  | Leaf v as t -> if v.char = ch then Some t else None
  | Node (v, rest) as t ->
    if v.char = ch then Some t
    else List.find_opt (fun node -> find_node ch node <> None) rest

let list_to_tree list =
  let rec construct_tree tree dicts buf words =
    if Bytes.length buf <= 1 then
      match tree with
      | Leaf v -> Leaf {v with word_list = List.append v.word_list words}
      | Node (v, tree) -> Node ({v with word_list = List.append v.word_list words}, tree)
    else begin
      let ch = Bytes.get buf 0 in
      match find_node ch tree with
      | None -> Leaf {char = ch; word_list = words}
      | Some (Leaf _ as v) -> construct_tree v dicts Bytes.(sub buf 1 @@ length buf - 1) words
      | Some (Node _ as v) -> construct_tree v dicts Bytes.(sub buf 1 @@ length buf - 1) words


let parse_dict ic =
  let module P = Migemo_dict_parser in
  let module L = Migemo_dict_lexer in
  let dict = P.dict L.token Lexing.(from_channel ic) in
  list_to_tree dict

let with_open ~f filename =
  let ic = open_in filename in
  let ret = begin
    try
      f ic
    with _ as e ->
      close_in ic;
      raise e
  end in
  close_in ic;
  ret

(** Load tree from file. *)
let load filename =
  if not @@ Sys.file_exists filename then None
  else begin
    let dict = with_open ~parse_dict filename in
    Some dict
  end
