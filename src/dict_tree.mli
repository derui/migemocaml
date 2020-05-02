(** Dict_tree module provides tree structure for migemo dictionary. *)

type word_list = string list

(** The module for node attribute *)
module Attr : sig
  type t = {
    char : char;
    word_list : word_list;
  }

  val equal : t -> t -> bool
  (** equality between values *)

  val show : t -> string
  (** get string representation of [t] *)

  val pp : Format.formatter -> t -> unit
  (** [pp fmt t] pritty print to [fmt] *)
end

type node = Attr.t

(** Simple tree type *)
type t =
  | Nil
  | Node of node * t * t

val equal : t -> t -> bool
(** equality between values *)

val show : t -> string
(** Get string of [t] *)

val pp : Format.formatter -> t -> unit
(** [pp fmt t] pritty print to [fmt] *)

val make_tree : (string * string list) list -> t
(** Make the tree directly. *)

val query : query:string -> t -> t option
(** Find first matching node with [query]. *)

val forward_match : query:string -> t -> (word_list * int) option
(** Find first matching node and character length. *)

val traverse : f:(node -> unit) -> t -> unit
(** Tree traverses depth-proirity *)

val load_dict : string -> t option
(** Load the file as dictionary *)

val load_conv : string -> t option
(** Load the file as conversion *)
