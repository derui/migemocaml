(** Regexp_spec define module interface and some modules to generate regexp from {!Migemo} module.

    If you want to use [Migemocaml] in your application with {!Str} module, you will need {!OCaml_str} module. Create
    new module from {!S} if you want to generate regexp for unsupported format in Migemocaml. *)

(** Spec for regexp that is generated from this module *)
module type S = sig
  val operator_select_in : string

  val operator_select_out : string

  val operator_group_in : string

  val operator_group_out : string

  val operator_or : string
end

(** Default spec to generate *)
module Default : S = struct
  let operator_select_in = "["

  let operator_select_out = "]"

  let operator_group_in = "("

  let operator_group_out = ")"

  let operator_or = "|"
end

(** The spec for Emacs integration *)
module Emacs : S = struct
  let operator_select_in = "["

  let operator_select_out = "]"

  let operator_group_in = "\\("

  let operator_group_out = "\\)"

  let operator_or = "\\|"
end

(** The spec for OCaml's Str integration *)
module OCaml_str : S = struct
  let operator_select_in = "["

  let operator_select_out = "]"

  let operator_group_in = "\\("

  let operator_group_out = "\\)"

  let operator_or = "\\|"
end
