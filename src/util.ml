(** Migemocaml internal utility *)

(** Take first string of [size] from [str] *)
let take ?(size = 1) str =
  if String.length str = 0 then ("", "")
  else if String.length str <= size then (str, "")
  else (String.sub str 0 size, String.(sub str size @@ (length str - size)))

let uppercase_alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

let lowercase_alphabets = String.map Char.lowercase_ascii uppercase_alphabets

let is_uppercase ch = String.contains uppercase_alphabets ch

let is_lowercase ch = String.contains lowercase_alphabets ch
