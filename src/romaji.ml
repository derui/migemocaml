(** Romaji module provides functions to convert romaji to other character in japanese.
    But it does not provides function to convert other character to romaji, it is overspec.
*)

type t = Dict_tree.t

(** normalized version  *)
let normalized_xtu = "xtu"
let normalized_xn = "xn"
let converted_n = "n"
let non_xtu = "aiueon"

let is_same_roma_letter_appear string =
  let open String in
  length string >= 2 && get string 0 = get string 1 &&
  not @@ contains non_xtu @@ get string 0

(** convert a character from [string] with [tree] *)
let convert_character string tree =
  match Dict_tree.forward_match ~query:string tree with
  | None | Some ([], _) ->
    (* When not found matched sequence, skip a character that think of multi-byte. *)
    begin match Charset.Utf8.raw_to_character string with
      | None -> failwith "Unknown error: Invalid utf-8 sequence"
      | Some (_, skip) -> (fst @@ Util.take ~size:skip string, skip)
    end
  | Some (word :: _, size) -> (word, size)

(** Convert [string] to other characters with [tree]. This function read [string] as romaji. *)
let convert_roma ~string tree =
  let buf = Buffer.create 0 in
  let xtu_cache = match Dict_tree.forward_match ~query:normalized_xtu tree with
    | None | Some ([], _) -> None
    | Some (word :: _, _) -> Some (word, 1)
  and xn_cache = match Dict_tree.forward_match ~query:normalized_xn tree with
    | None | Some ([], _) -> None
    | Some (word :: _, _) -> Some (word, 1)
  in
  let rec loop string =
    if String.length string = 0 then ()
    else begin
      let char, skip =
        if is_same_roma_letter_appear string then
          match xtu_cache with
          | None -> convert_character string tree
          | Some (char, skip) -> char, skip
        else
          convert_character string tree
      in
      let char, skip =
        if char = converted_n && skip = 1 then
          match xn_cache with
          | None -> (char, skip)
          | Some (word, skip) -> (word, skip)
        else (char, skip)
      in
      let _, rest = Util.take ~size:skip string in
      Buffer.add_string buf char;
      loop rest
    end
  in
  loop string;
  Bytes.to_string @@ Buffer.to_bytes buf
