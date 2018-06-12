(** Character conversion functions between raw value and a character *)

type character = int64
type raw = int

module type Converter = sig

  (** Convert a character to 8bit-encoded string *)
  val character_to_raw: character -> string

  (** Convert 8bit-encoded string to a character and read string from original byte sequence. *)
  val raw_to_character: string -> (character * int) option
end

module Utf8 : Converter = struct
  (* helper function to construct UTF-8's non-ascii character. Return [None] if
   * first byte contains range of ascii character. *)
  let raw_to_character_for_noascii string =
    (* this function support only up to 4-byte characters in UTF-8 *)
    let detect_utf8_char_size byte =
      let utf8_char_size = byte land 0xF0 in
      match utf8_char_size with
      | 0xC0 -> 2
      | 0xE0 -> 3
      | 0xF0 -> 4
      | _ -> 1
    in
    let size = detect_utf8_char_size Char.(code @@ String.get string 0) in

    (* concat byte sequence as utf-8 non-ascii character. *)
    let rec combine_string_to_character string size offset ch =
      if offset >= size then Some ch
      else if ((Char.code @@ String.get string offset) land 0xc0) <> 0x80 then None
      else
        let shifted = Int64.shift_left ch 6
        and masked = Int64.of_int @@ ((Char.code @@ String.get string offset) land 0x3f) in
        combine_string_to_character string size (succ offset) Int64.(add shifted masked)
    in
    if size < 2
    then None
    else
      let ch = Int64.of_int @@ ((Char.code @@ String.get string 0) land (0xff lsr size)) in
      match combine_string_to_character string size 1 ch with
      | None -> None
      | Some c -> Some (c, size)

  let raw_to_character string =
    if String.length string = 0 then None
    else
      match raw_to_character_for_noascii string with
      | None -> Some (Int64.of_int @@ Char.code @@ String.get string 0, 1)
      | Some (c, size) -> Some (c, size)

  let character_to_raw ch =
    (* TODO: very rebundand code... *)
    (* RFC-3629 says 5 and 6 string representasion of UTF-8 is obsolete, so this
       algorithm support utf-8 partially now.
    *)
    if Int64.(compare ch 0x80L) = -1 then String.make 1 (Char.chr @@ Int64.to_int ch)
    else if Int64.compare ch 0x800L = -1 then
      let ch0 = Int64.(to_int @@ add 0xc0L @@ shift_right ch 6)
      and ch1 = Int64.(to_int @@ add 0x80L @@ logand ch 0x3fL)
      and bytes = Bytes.create 2 in
      Bytes.set bytes 0 @@ Char.chr ch0;
      Bytes.set bytes 1 @@ Char.chr ch1;
      Bytes.to_string bytes
    else if Int64.compare ch 0x10000L = -1 then
      let ch0 = Int64.(to_int @@ add 0xe0L @@ shift_right ch 12)
      and ch1 = Int64.(to_int @@ add 0x80L @@ logand (shift_right ch 6) 0x3fL)
      and ch2 = Int64.(to_int @@ add 0x80L @@ logand ch 0x3fL)
      and bytes = Bytes.create 3 in
      Bytes.set bytes 0 @@ Char.chr ch0;
      Bytes.set bytes 1 @@ Char.chr ch1;
      Bytes.set bytes 2 @@ Char.chr ch2;
      Bytes.to_string bytes

    else
      let ch0 = Int64.(to_int @@ add 0xf0L @@ shift_right ch 18)
      and ch1 = Int64.(to_int @@ add 0x80L @@ logand (shift_right ch 12) 0x3fL)
      and ch2 = Int64.(to_int @@ add 0x80L @@ logand (shift_right ch 6) 0x3fL)
      and ch3 = Int64.(to_int @@ add 0x80L @@ logand ch 0x3fL)
      and bytes = Bytes.create 4 in
      Bytes.set bytes 0 @@ Char.chr ch0;
      Bytes.set bytes 1 @@ Char.chr ch1;
      Bytes.set bytes 2 @@ Char.chr ch2;
      Bytes.set bytes 3 @@ Char.chr ch3;
      Bytes.to_string bytes

end
