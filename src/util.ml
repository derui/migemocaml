(** Migemocaml internal utility *)

(** Take first string of [size] from [str] *)
let take ?(size = 1) str =
  let first = Astring.String.take ~min:0 ~max:size str and second = Astring.String.drop ~min:0 ~max:size str in
  (first, second)

let string_to_list str = String.to_seq str |> List.of_seq

let uppercase_alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

let lowercase_alphabets = String.map Char.lowercase_ascii uppercase_alphabets

let is_uppercase ch = String.contains uppercase_alphabets ch

let is_lowercase ch = String.contains lowercase_alphabets ch
