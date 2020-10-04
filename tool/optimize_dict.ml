(* original written by MURAOKA Taro <koron@tka.att.ne.jp> *)
(* original implementation is https://github.com/koron/cmigemo/tools/optimize-dict.pl *)
module C = CamomileLibraryDefault
module URe = C.Camomile.URe.Make (C.Camomile.UTF8)
module ReIntf = C.Camomile.UReStr

let read_line filename f =
  let in_chan = open_in filename in

  let rec read_line' chan () = input_line chan |> f |> read_line' chan in
  let () = try read_line' in_chan () with End_of_file -> () in
  close_in in_chan

let regexp_comment = ReIntf.regexp "^;" |> URe.compile

let ( >>= ) a f = match a with None -> None | Some v -> f v

let () =
  if Array.length Sys.argv < 2 then exit 1;
  let lines = ref [] and label_hash : (string, string list) Hashtbl.t = Hashtbl.create 10 in

  let file_path = Sys.argv.(1) in
  let store_dict line =
    if URe.string_match regexp_comment line 0 then ()
    else
      match String.split_on_char '\t' line with
      | []           -> ()
      | key :: words ->
          lines := key :: !lines;
          Hashtbl.add label_hash key words
  in

  read_line file_path store_dict;
  let lines =
    List.sort
      (fun a b ->
        let cmp_len = compare (String.length b) (String.length a) in
        if cmp_len = 0 then C.Camomile.UTF8.compare a b else cmp_len)
      !lines
  in
  let uniq_list words =
    let hash : (string, int) Hashtbl.t = Hashtbl.create (List.length words) in
    List.iter (fun v -> Hashtbl.add hash v 1) words;
    Hashtbl.to_seq_keys hash |> List.of_seq
  in

  List.iter
    (fun key ->
      Hashtbl.find_opt label_hash key
      >>= (fun v -> Printf.printf "%s\t%s\n" key (uniq_list v |> String.concat "\t") |> Option.some)
      |> Option.value ~default:())
    lines
