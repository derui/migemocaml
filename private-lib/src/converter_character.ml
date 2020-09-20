(** Converter_character module provides basement function to convert a character to other character. This module will be
    able to use conversion between romaji and other character, but should use Converter_romaji to get valid result. *)

module Core = struct
  type t = Dict_tree.t

  (** convert a character from [string] with [tree] *)
  let convert_character string tree =
    match Dict_tree.forward_match ~query:string tree with
    | None | Some ([], _)    -> (
        (* When not found matched sequence, skip a character that think of multi-byte. *)
        match Charset.Utf8.raw_to_character string with
        | None           -> failwith "Unknown error: Invalid utf-8 sequence"
        | Some (_, skip) -> (fst @@ Util.take ~size:skip string, skip) )
    | Some (word :: _, size) -> (word, size)

  (** Convert [string] to other characters with [tree]. This function read [string] as romaji. *)
  let convert ~string tree =
    let buf = Buffer.create 0 in
    let rec loop string =
      if String.length string = 0 then ()
      else
        let char, skip = convert_character string tree in
        let _, rest = Util.take ~size:skip string in
        Buffer.add_string buf char;
        loop rest
    in
    loop string;
    Bytes.to_string @@ Buffer.to_bytes buf
end

include Core
