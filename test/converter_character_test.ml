open OUnit2

module T = Migemocaml.Dict_tree
module R = Migemocaml.Converter_romaji

let suite =
  "Multibyte-allowed character converter" >:::
  ["should return empty string when empty string given" >:: (fun _ ->
       let open R in
       assert_equal "" @@ convert ~string:"" T.Nil
     );
   "should return string that equal original when tree is Nil" >:: (fun _ ->
       let open R in
       assert_equal "aiueo" @@ convert ~string:"aiueo" T.Nil
     );
   "should return converted string with tree what original mixed multibyte-character" >:: (fun _ ->
       let open R in
       let tree = T.make_tree [("a", ["A"]);
                               ("b", ["B"]);
                               ("c", ["C"])] in
       assert_equal "ABCか" @@ convert ~string:"abcか" tree
     );
   "should convert multibyte-character in tree" >:: (fun _ ->
       let open R in
       let tree = T.make_tree [("か", ["カ"]);
                               ("ん", ["ン"]);] in
       assert_equal "ンcカ" @@ convert ~string:"んcか" tree
     );
  ]
