(** Character conversion functions between raw value and a character *)

type character = int64
type raw = int

(** the signature for converter between unicode and byte sequence. *)
module type Converter = sig
  val character_to_raw : character -> string
  val raw_to_character : string -> (character * int) option
end

module Utf8 : Converter
