module M = Migemocaml

let dict_dir = ref ""

let use_emacs = ref false

let quiet = ref false

let set_signal_handler () = Sys.set_signal Sys.sigint (Sys.Signal_handle (fun _ -> exit 0))

let rec main_loop ~quiet migemo =
  if not quiet then Printf.printf "Input query: " else ();
  let query = read_line () in
  let _start = Unix.gettimeofday () in
  let regexp = M.Migemo.query ~query migemo in
  let _end = Unix.gettimeofday () in
  if not quiet then Printf.printf "Result of migemo: time %f :\n%s\n" (_end -. _start) regexp
  else Printf.printf "%s\n" regexp;
  main_loop ~quiet migemo

let () =
  let specs =
    [
      ("-q", Arg.Set quiet, "quiet output");
      ("-d", Arg.String (fun v -> dict_dir := v), "migemo dictionary directory.");
      ("--emacs", Arg.Set use_emacs, "echo regular expression for Emacs");
    ]
  in
  Arg.parse specs ignore "";

  let spec = if !use_emacs then Some M.Regexp_spec.((module Emacs : S)) else None in
  match M.Migemo.make_from_dir ?spec ~base_dir:!dict_dir () with
  | None        ->
      Logs.err (fun m -> m "Can not load dictionary from: %s\n" !dict_dir);
      exit 1
  | Some migemo ->
      set_signal_handler ();
      main_loop ~quiet:!quiet migemo
