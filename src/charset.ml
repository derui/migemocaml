(** Character conversion functions between raw value and a character *)

type character = int64
type raw = int

module type Converter = sig

  (** Convert a character to 8bit-encoded bytes *)
  val character_to_raw: character -> bytes

  (** Convert 8bit-encoded bytes to a character and read bytes from original byte sequence. *)
  val raw_to_character: bytes -> (character * int) option
end


module Utf8 : Converter = struct
  (* helper function to construct UTF-8's non-ascii character. Return [None] if
   * first byte contains range of ascii character. *)
  let raw_to_character_for_noascii bytes =
    let rec detect_utf8_char_size byte size =
      if byte land 0x80 = 0 then size
      else detect_utf8_char_size (byte lsl 1) (succ size)
    in
    let size = detect_utf8_char_size Char.(code bytes.[0]) 0 in

    (* concat byte sequence as utf-8 non-ascii character. *)
    let rec combine_bytes_to_character bytes size offset ch =
      if offset >= size then Some ch
      else if (Char.code bytes.[offset] land 0xc0) <> 0x80 then None
      else
        let shifted = Int64.shift_left ch 6
        and masked = Int64.of_int @@ (Char.code bytes.[offset] land 0x3f) in
        combine_bytes_to_character bytes size (succ offset) Int64.(add shifted masked)
    in
    if size < 2
    then None
    else
      let ch = Int64.of_int @@ ((Char.code bytes.[0]) land (0xff lsr size)) in
      match combine_bytes_to_character bytes size 1 ch with
      | None -> None
      | Some c -> Some (c, size)

  let raw_to_character bytes =
    if Bytes.length bytes = 0 then None
    else
      match raw_to_character_for_noascii bytes with
      | None -> Some (Int64.of_int @@ Char.code bytes.[0], 1)
      | Some (c, size) -> Some (c, size)

  let character_to_raw ch =
    (* TODO: very rebundand code... *)
    (* RFC-3629 says 5 and 6 bytes representasion of UTF-8 is obsolete, so this
       algorithm support utf-8 partially now.
    *)
    if Int64.(compare ch 0x80L) = -1 then Bytes.make 1 (Char.chr @@ Int64.to_int ch)
    else if Int64.compare ch 0x800L = -1 then
      let ch0 = Int64.(to_int @@ add 0xc0L @@ shift_right ch 6)
      and ch1 = Int64.(to_int @@ add 0x80L @@ logand ch 0x3fL)
      and bytes = Bytes.create 2 in
      Bytes.set bytes 0 @@ Char.chr ch0;
      Bytes.set bytes 1 @@ Char.chr ch1;
      bytes
    else if Int64.compare ch 0x10000L = -1 then
      let ch0 = Int64.(to_int @@ add 0xe0L @@ shift_right ch 12)
      and ch1 = Int64.(to_int @@ add 0x80L @@ logand (shift_right ch 6) 0x3fL)
      and ch2 = Int64.(to_int @@ add 0x80L @@ logand ch 0x3fL)
      and bytes = Bytes.create 3 in
      Bytes.set bytes 0 @@ Char.chr ch0;
      Bytes.set bytes 1 @@ Char.chr ch1;
      Bytes.set bytes 2 @@ Char.chr ch2;
      bytes

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
      bytes

end
