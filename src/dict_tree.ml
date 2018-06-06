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
  | Tree of t list
