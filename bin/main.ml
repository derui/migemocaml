module M = Migemocaml

let dict_dir = ref ""

let use_emacs = ref false

let quiet = ref false

let migemo_dict = "migemo-dict"

let hira_to_kata = "hira2kata.dat"

let roma_to_hira = "roma2hira.dat"

let han_to_zen = "han2zen.dat"

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

  let dict_file = Filename.concat !dict_dir migemo_dict in
  let spec = if !use_emacs then Some M.Regexp_spec.((module Emacs : S)) else None in
  match M.Dict_tree.load_dict dict_file with
  | None             ->
      Logs.err (fun m -> m "Dict can not load: %s\n" dict_file);
      exit 1
  | Some migemo_dict ->
      let hira_to_kata =
        Logs.info (fun m -> m "Loading %s\n" hira_to_kata);
        M.Dict_tree.load_conv @@ Filename.concat !dict_dir hira_to_kata
      and romaji_to_hira =
        Logs.info (fun m -> m "Loading %s\n" roma_to_hira);
        M.Dict_tree.load_conv @@ Filename.concat !dict_dir roma_to_hira
      and han_to_zen =
        Logs.info (fun m -> m "Loading %s\n" han_to_zen);
        M.Dict_tree.load_conv @@ Filename.concat !dict_dir han_to_zen
      in
      let migemo = M.Migemo.make ~dict:migemo_dict ?hira_to_kata ?romaji_to_hira ?han_to_zen ?spec () in
      set_signal_handler ();
      main_loop ~quiet:!quiet migemo
