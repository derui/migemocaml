(** Regexp_gen provides function to construct regular expression from
    inputted string.
*)
type t

(** Get empty engine [t] *)
val empty : t

(** Convert [t] to representation string *)
val to_string : t -> string

(** Add a [word] to regular expression engine [t]. this function immutable. *)
val add_word : word:string -> t -> t

(** Generate regular expression from [t] *)
val generate : t -> string
