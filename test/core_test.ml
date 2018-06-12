open OUnit2

open Migemocaml.Core
module D = Migemocaml.Dict_tree

let suite =
  "Migemo core module" >::: [
    "segment splitting" >::: [
      "return empty segment if query is empty" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer [] @@ split_segments ""
        );
      "return a segment if query does not contain uppercase alphabet" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer ["abcde"] @@ split_segments "abcde"
        );
      "return segments splitted by uppercase alphabet" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer ["ab";"Cde"] @@ split_segments "abCde"
        );
      "return segments if query contains some uppercase" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer ["ab";"Cde";"Fgh"] @@ split_segments "abCdeFgh"
        );
      "should use lowercase as spliting point of segment if uppercase continues two times and more" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer ["AB";"cde";"Fgh"] @@ split_segments "ABcdeFgh"
        );
      "should handle through multibyte-character" >:: (fun _ ->
          let printer = String.concat "" in
          assert_equal ~printer ["ABあ";"cde";"Fgh"] @@ split_segments "ABあcdeFgh"
        );
    ];

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
