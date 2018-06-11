module M = Migemocaml

let dict_dir = ref ""
let migemo_dict = "migemo-dict"
let hira_to_kata = "hira2kata.dat"
let roma_to_hira = "roma2hira.dat"
let han_to_zen = "han2zen.dat"

let set_signal_handler () = Sys.set_signal Sys.sigint (Sys.Signal_handle (fun _ -> exit 0))

let rec main_loop migemo =

  Printf.printf "Input query: ";
  let query = read_line () in
  let _start = Unix.gettimeofday () in
  let regexp = M.Core.query ~query migemo in
  let _end = Unix.gettimeofday () in
  Printf.printf "Result of migemo: time %f :\n%s\n" (_end -. _start) regexp;
  main_loop migemo

let () =
  let specs = [
    ("-d", Arg.String (fun v -> dict_dir := v), "migemo dictionary directory.");
  ] in
  Arg.parse specs ignore "";

  let dict_file = Filename.concat !dict_dir migemo_dict in
  if not @@ Sys.file_exists dict_file then begin
    Printf.printf "Dict file not found: %s\n" dict_file;
    exit 1
  end
  else begin
    match M.Dict_tree.load dict_file with
    | None -> begin Printf.printf "Dict can not load: %s\n" dict_file; exit 1 end
    | Some migemo_dict -> begin
        let hira_to_kata = Printf.printf "Loading %s\n" hira_to_kata; M.Dict_tree.load_conv @@ Filename.concat !dict_dir hira_to_kata
        and romaji_to_hira = Printf.printf "Loading %s\n" roma_to_hira; M.Dict_tree.load_conv @@ Filename.concat !dict_dir roma_to_hira
        and han_to_zen = Printf.printf "Loading %s\n" han_to_zen; M.Dict_tree.load_conv @@ Filename.concat !dict_dir han_to_zen
        in
        let migemo = M.Core.make ~dict:migemo_dict ?hira_to_kata ?romaji_to_hira ?han_to_zen () in
        set_signal_handler ();
        main_loop migemo
      end
  end
