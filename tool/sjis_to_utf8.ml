module URe = Camomile.URe.Make (Camomile.UTF8)
module ReIntf = Camomile.UReStr

let sjis_jp_enc = Camomile.CharEncoding.of_name "SJIS"

let sjisjp_to_utf8 line =
  let utf8_enc = Camomile.CharEncoding.utf8 in
  Camomile.CharEncoding.(recode_string ~in_enc:sjis_jp_enc ~out_enc:utf8_enc line)

let read_line filename f =
  let in_chan = open_in filename in

  let rec read_line' chan () = input_line chan |> f |> read_line' chan in
  let () = try read_line' in_chan () with End_of_file -> () in
  close_in in_chan

let () =
  if Array.length Sys.argv < 2 then exit 1;

  let file_path = Sys.argv.(1) in

  read_line file_path (fun line -> Printf.printf "%s\n" @@ sjisjp_to_utf8 line)
