(** Dict_tree module provides tree structure for migemo dictionary. *)

type word_list = string list

(** The module for node attribute *)
module Attr :
sig
  type t = { char : char; word_list : word_list; }
  val to_string : t -> string
end
type node = Attr.t

(** Simple tree type *)
type t = Nil | Node of node * t * t

(** Get string of [t] *)
val to_string : t -> string

(** Make the tree directly. *)
val make_tree : (string * string list) list -> t

(** Find first matching node with [query]. *)
val query : query:string -> t -> t option

(** Find first matching node and character length. *)
val forward_match : query:string -> t -> (word_list * int) option

(** Tree traverses depth-proirity *)
val traverse : f:(node -> unit) -> t -> unit

(** Load the file as dictionary *)
val load_dict : string -> t option

(** Load the file as conversion *)
val load_conv : string -> t option
