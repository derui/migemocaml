(** Migemo module provides core function to query string with migemo algorithm. *)

type t
(** Migemo object. *)

val make :
  ?romaji_to_hira:Dict_tree.t ->
  ?hira_to_kata:Dict_tree.t ->
  ?han_to_zen:Dict_tree.t ->
  ?spec:(module Regexp_spec.S) ->
  dict:Dict_tree.t ->
  unit ->
  t
(** Make migemo object with dictionary and conversions *)

val make_from_dir : ?spec:(module Regexp_spec.S) -> base_dir:string -> unit -> t option
(** Make migemo object that dictionary and conversions are loaded from [base_dir]directory *)

val query : query:string -> t -> string
(** Query the [query] to migemo [t] object and get regular expression. *)
