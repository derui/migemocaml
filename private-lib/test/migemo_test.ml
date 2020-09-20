open Migemocaml_private.Migemo
module D = Migemocaml_private.Dict_tree

let suite =
  [
    ( "return original query when dict is empty",
      `Quick,
      fun () ->
        let t = make ~dict:(D.make_tree []) () in
        Alcotest.(check string) "query" "aiueo" @@ query ~query:"aiueo" t );
    ( "return converted regexp with dict word",
      `Quick,
      fun () ->
        let t = make ~dict:(D.make_tree [ ("あ", [ "亜"; "合" ]) ]) () in
        Alcotest.(check string) "query" "[合亜あ]" @@ query ~query:"あ" t );
    ( "return converted regexp with romaji conversion",
      `Quick,
      fun () ->
        let t =
          make ~dict:(D.make_tree [ ("あ", [ "亜"; "合" ]) ]) ~romaji_to_hira:(D.make_tree Dicts.romaji_dict) ()
        in
        Alcotest.(check string) "query" "[合亜あa](いうえお|Iueo)" @@ query ~query:"aIueo" t );
  ]
