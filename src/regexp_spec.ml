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
