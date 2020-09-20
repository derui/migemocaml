type t
(** Regexp_gen provides function to construct regular expression from inputted string. *)

val empty : t
(** Get empty engine [t] *)

val to_string : t -> string
(** Convert [t] to representation string *)

val add_word : word:string -> t -> t
(** Add a [word] to regular expression engine [t]. this function immutable. *)

val generate : (module Regexp_spec.S) -> t -> string
(** Generate regular expression from [t] *)
