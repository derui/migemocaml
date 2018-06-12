open OUnit2

open Migemocaml.Migemo
module D = Migemocaml.Dict_tree

let suite =
  "Migemo core module" >::: [
    "return original query when dict is empty" >:: (fun _ ->
        let t = make ~dict:(D.make_tree []) () in
        assert_equal "aiueo" @@ query ~query:"aiueo" t
      );
    "return converted regexp with dict word" >:: (fun _ ->
        let t = make ~dict:(D.make_tree [("あ", ["亜"; "合"])]) () in
        assert_equal ~printer:(fun id -> id) "[合亜あ]" @@ query ~query:"あ" t
      );
    "return converted regexp with romaji conversion" >:: (fun _ ->
        let t = make ~dict:(D.make_tree [("あ", ["亜"; "合"])])
            ~romaji_to_hira:(D.make_tree Dicts.romaji_dict) () in
        assert_equal ~printer:(fun id -> id) "[合亜あa](いうえお|Iueo)" @@ query ~query:"aIueo" t
      );
  ]
