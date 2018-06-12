(** Migemo module provides core function to query string with migemo algorithm. *)

(** Migemo object. *)
type t = {
  dict: Dict_tree.t;
  romaji_to_hira: Dict_tree.t option;
  hira_to_kata: Dict_tree.t option;
  han_to_zen: Dict_tree.t option;
}

(** Make migemo object *)
let make ?romaji_to_hira ?hira_to_kata ?han_to_zen ~dict () =
  {
    dict;
    romaji_to_hira;
    hira_to_kata;
    han_to_zen;
  }

(** split query to segments. Normally upper case alphabets is splitter of segment.

    example:
      query="abcde" -> ["abcde"]
      query="Abcde" -> ["abcde"]
      query="AbCde" -> ["ab";"cde"]
      query="ABcde" -> ["ab";"cde"]
      query="ABcDe" -> ["ab";"c";"de"]
*)
let split_segments query =
  let is_uppercase_connected buf =
    if String.length buf < 2 then false
    else Util.(is_uppercase @@ String.get buf 0) &&
         Util.(is_uppercase @@ String.get buf 1)
  in
  let detect_splitter buf =
    if is_uppercase_connected buf then Util.is_lowercase
    else Util.is_uppercase
  in
  let rec inner_split_segments buf splitter accum segments =
    if String.length buf = 0 then
      match accum with
      | [] -> List.rev segments
      | _ -> List.rev (String.concat "" (List.rev accum) :: segments)
    else
      let module C = Charset.Utf8 in
      match C.raw_to_character buf with
      | None -> Printf.fprintf stderr "Invalid utf-8 sequence: %s" buf; segments
      | Some (code, skip) ->
        let ch_seq, buf' = Util.take ~size:skip buf in
        if skip = 1 then
          let ch = Int64.to_int code |> Char.chr in
          if splitter ch then
            let segment = String.concat "" @@ List.rev accum in
            inner_split_segments buf' (detect_splitter buf) [ch_seq] (segment :: segments)
          else
            inner_split_segments buf' splitter (ch_seq :: accum) segments
        else
          inner_split_segments buf' splitter (ch_seq :: accum) segments
  in
  inner_split_segments query (detect_splitter query) [] []

(** convert all alphabets in [buf] into uppercase ones. This function thinks of multibyte-character. *)
let to_lowercase_mb buf =
  let rec to_lowercase buf accum =
    if String.length buf = 0 then Buffer.to_bytes accum |> Bytes.to_string
    else
      let module C = Charset.Utf8 in
      match C.raw_to_character buf with
      | None -> Printf.fprintf stderr "Invalid utf-8 sequence: %s" buf; to_lowercase "" accum
      | Some (code, skip) ->
        let ch_seq, buf' = Util.take ~size:skip buf in
        if skip = 1 then
          let ch = Int64.to_int code |> Char.chr |> Char.lowercase_ascii |> Char.escaped in
          Buffer.add_string accum ch;
          to_lowercase buf' accum
        else begin
          Buffer.add_string accum ch_seq;
          to_lowercase buf' accum
        end
  in
  to_lowercase buf (Buffer.create 0)

let add_word_list_to_gen query tree gen =
  let module D = Dict_tree in
  match Dict_tree.query ~query tree with
  | None -> ()
  | Some node -> D.traverse ~f:(fun node ->
        gen := List.fold_left (fun gen word -> Regexp_gen.add_word ~word gen)
            !gen node.D.Attr.word_list
      ) node

let with_dict ~f dict =
  match dict with
  | None -> ()
  | Some dict -> f dict

let query_a_word word t =
  let gen = ref Regexp_gen.empty in
  gen := Regexp_gen.add_word ~word !gen;
  let lower = to_lowercase_mb word in
  let module D = Dict_tree in
  add_word_list_to_gen lower t.dict gen;
  (* Add zenkaku word that is converted original query *)
  begin match t.han_to_zen with
    | None -> ()
    | Some han_to_zen ->
      let converted = Converter_character.convert ~string:lower han_to_zen in
      gen := Regexp_gen.add_word ~word:converted !gen
  end;
  (* Sequence to add words: original -> words what querying with original ->
     hiragana -> words what querying with hiragana ->
     katakana -> words what querying with katakana
  *)
  with_dict t.romaji_to_hira ~f:(fun romaji_to_hira ->
      let hiragana = Converter_romaji.convert ~string:lower romaji_to_hira in
      gen := Regexp_gen.add_word ~word:hiragana !gen;
      add_word_list_to_gen hiragana t.dict gen;

      with_dict t.hira_to_kata ~f:(fun hira_to_kata ->
          let katakana = Converter_romaji.convert ~string:hiragana hira_to_kata in
          gen := Regexp_gen.add_word ~word:katakana !gen;
          add_word_list_to_gen katakana t.dict gen;
        )
    );
  !gen

(** query the [query] to [t], and get regular expression *)
let query ~query t =
  let segments = split_segments query in

  let regexps = List.map (fun word ->
      let gen = query_a_word word t in
      Regexp_gen.generate gen
    ) segments
  in
  String.concat "" regexps
