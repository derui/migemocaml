(** Migemocaml internal utility *)

(** Take first string of [size] from [str] *)
let take ?(size=1) str =
  if String.length str = 0 then ("", "")
  else if String.length str <= size then (str, "")
  else (String.sub str 0 size, String.(sub str size @@ length str - size))
