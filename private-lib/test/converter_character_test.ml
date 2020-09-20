module T = Migemocaml_private.Dict_tree
module R = Migemocaml_private.Converter_romaji

let suite =
  [
    ( "should return empty string when empty string given",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "empty" "" @@ convert ~string:"" T.Nil );
    ( "should return string that equal original when tree is Nil",
      `Quick,
      fun () ->
        let open R in
        Alcotest.(check string) "same string" "aiueo" @@ convert ~string:"aiueo" T.Nil );
    ( "should return converted string with tree what original mixed multibyte-character",
      `Quick,
      fun () ->
        let open R in
        let tree = T.make_tree [ ("a", [ "A" ]); ("b", [ "B" ]); ("c", [ "C" ]) ] in
        Alcotest.(check string) "converted" "ABCか" @@ convert ~string:"abcか" tree );
    ( "should convert multibyte-character in tree",
      `Quick,
      fun () ->
        let open R in
        let tree = T.make_tree [ ("か", [ "カ" ]); ("ん", [ "ン" ]) ] in
        Alcotest.(check string) "convert multibyte" "ンcカ" @@ convert ~string:"んcか" tree );
  ]
