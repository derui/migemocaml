(* original written by MURAOKA Taro <koron@tka.att.ne.jp> *)
(* original implementation is https://github.com/koron/cmigemo/tools/skk2migemo.pl *)
module C = CamomileLibraryDefault
module URe = C.Camomile.URe.Make (C.Camomile.UTF8)
module ReIntf = C.Camomile.UReStr

let euc_jp_enc = C.Camomile.CharEncoding.of_name "EUC-JP"

let eucjp_to_utf8 line =
  let utf8_enc = C.Camomile.CharEncoding.utf8 in
  C.Camomile.CharEncoding.(recode_string ~in_enc:euc_jp_enc ~out_enc:utf8_enc line)

let read_line filename f =
  let in_chan = open_in filename in

  let rec read_line' chan () = input_line chan |> f |> read_line' chan in
  let () = try read_line' in_chan () with End_of_file -> () in
  close_in in_chan

let regexp_comment = ReIntf.regexp "^;" |> URe.compile

let regexp_split_key_value = ReIntf.regexp "^\\([^ ]+\\) +\\(.*\\)$" |> URe.compile

let regexp_special_key_head = ReIntf.regexp "^[<>?]" |> URe.compile

let regexp_special_key_last = ReIntf.regexp "[<>?]$" |> URe.compile

let regexp_okuri = ReIntf.regexp "[a-z]$" |> URe.compile

let regexp_not_okuri = ReIntf.regexp "^[ -~]+$" |> URe.compile

let regexp_remove_lisp_expression = ReIntf.regexp "^([a-zA-Z].*)$" |> URe.compile

let regexp_number_expansion = ReIntf.regexp "#" |> URe.compile

let regexp_annotation = ReIntf.regexp "^\\([^;]+?\\);.*$" |> URe.compile

let ( >>= ) a f = match a with None -> None | Some v -> f v

let remove_comment line = if URe.string_match regexp_comment line 0 then None else Some line

let extract_groups groups =
  let groups = Array.sub groups 1 (Array.length groups - 1) in
  if Array.length groups = 0 then None else Some groups

let extract_key_value groups =
  let key = groups.(0) and value = groups.(1) in
  match (key, value) with
  | None, _ | _, None    -> None
  | Some key, Some value -> Some (URe.SubText.excerpt key, URe.SubText.excerpt value)

let remove_okuri (key, value) =
  if URe.string_match regexp_okuri key 0 && (not @@ URe.string_match regexp_not_okuri key 0) then
    let key = String.sub key 0 (String.length key - 2) in
    Some (key, value)
  else Some (key, value)

let remove_value_slashes (key, value) =
  let start_index = if value.[0] = '/' then 1 else 0
  and end_index = if value.[String.length value - 1] = '/' then String.length value - 2 else String.length value - 1 in
  let value = String.sub value start_index end_index in
  Some (key, value)

let split_values (key, value) =
  let values = String.split_on_char '/' value in
  Some (key, values)

let remove_lisp_expression pair =
  let values = snd pair in
  let values = List.filter (fun v -> not @@ URe.string_match regexp_remove_lisp_expression v 0) values in
  Some (fst pair, values)

let remove_number_expansion (key, values) =
  let number_expansion_in_key = URe.string_match regexp_number_expansion key 0 in
  let values =
    List.filter (fun v -> (not number_expansion_in_key) || (not @@ URe.string_match regexp_number_expansion v 0)) values
  in
  Some (key, values)

let remove_annotation (key, values) =
  let values =
    List.map
      (fun v ->
        let group = URe.regexp_match regexp_annotation v 0 in
        match group with
        | None        -> v
        | Some groups ->
            let groups = Array.sub groups 1 (Array.length groups - 1) in
            if Array.length groups < 1 then v
            else
              let group = groups.(0) >>= fun v -> URe.SubText.excerpt v |> Option.some in
              Option.value group ~default:v)
      values
  in
  Some (key, values)

let print_dict_line line =
  let line = String.trim line |> eucjp_to_utf8 in

  let key_values =
    remove_comment line >>= fun v ->
    URe.regexp_match regexp_split_key_value v 0
    >>= extract_groups >>= extract_key_value >>= remove_okuri >>= remove_value_slashes >>= split_values
    >>= remove_lisp_expression >>= remove_number_expansion >>= remove_annotation
  in
  match key_values with
  | None               -> ()
  | Some (key, values) ->
      if String.length key > 0 && List.length values >= 0 then Printf.printf "%s\t%s\n" key (String.concat "\t" values)
      else ()

let () =
  if Array.length Sys.argv < 2 then exit 1;

  let file_path = Sys.argv.(1) in

  read_line file_path print_dict_line
