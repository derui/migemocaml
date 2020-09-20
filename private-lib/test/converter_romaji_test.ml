module T = Migemocaml_private.Dict_tree
module R = Migemocaml_private.Converter_romaji

let tree = T.make_tree Dicts.romaji_dict

let suite =
  [
    ( "should return empty string when empty string given",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "empty" "" @@ convert ~string:"" tree );
    ( "should return string that equal original when tree is Nil",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "same" "aiueo" @@ convert ~string:"aiueo" T.Nil );
    ( "should return string that is not normalized when tree is Nil",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "with normalized" "ntta" @@ convert ~string:"ntta" T.Nil );
    ( "should return converted string when tree contains romaji",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "multi byte" "あいうえおか" @@ convert ~string:"aiueoka" tree );
    ( "should return normalized 'ん' and 'っ' string when tree contains romaji",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "multi byte" "あったんか" @@ convert ~string:"attanka" tree );
    ( "should return as-is character that can not convert from tree",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "mixed" "あxz" @@ convert ~string:"axz" tree );
  ]
