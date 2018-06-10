open OUnit2

module T = Migemocaml.Dict_tree
module R = Migemocaml.Converter_romaji

let tree = T.make_tree Dicts.romaji_dict

let suite =
  "Romaji converter" >:::
  ["should return empty string when empty string given" >:: (fun _ ->
       let open R in
       assert_equal "" @@ convert ~string:"" tree
     );
   "should return string that equal original when tree is Nil" >:: (fun _ ->
       let open R in
       assert_equal "aiueo" @@ convert ~string:"aiueo" T.Nil
     );
   "should return string that is not normalized when tree is Nil" >:: (fun _ ->
       let open R in
       assert_equal "ntta" @@ convert ~string:"ntta" T.Nil
     );
   "should return converted string when tree contains romaji" >:: (fun _ ->
       let open R in
       assert_equal "あいうえおか" @@ convert ~string:"aiueoka" tree
     );

   "should return normalized 'ん' and 'っ' string when tree contains romaji" >:: (fun _ ->
       let open R in
       assert_equal "あったんか" @@ convert ~string:"attanka" tree
     );
   "should return as-is character that can not convert from tree" >:: (fun _ ->
       let open R in
       assert_equal "あxz" @@ convert ~string:"axz" tree
     );
  ]
