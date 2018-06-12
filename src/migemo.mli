(** Migemo module provides core function to query string with migemo algorithm. *)

(** Migemo object. *)
type t

(** Make migemo object with dictionary and conversions *)
val make :
  ?romaji_to_hira:Dict_tree.t ->
  ?hira_to_kata:Dict_tree.t ->
  ?han_to_zen:Dict_tree.t ->
  dict:Dict_tree.t -> unit -> t

(** Query the [query] to migemo [t] object and get regular expression. *)
val query : query:string -> t -> string
