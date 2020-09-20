module T = Migemocaml_private.Dict_tree

let dict_t = Alcotest.testable T.pp T.equal

let suite =
  [
    ( "should return Nil if dict is empty",
      `Quick,
      fun () ->
        let open T in
        Alcotest.(check dict_t) "empty" Nil @@ T.make_tree [] );
    ( "should return single node if label has only one byte",
      `Quick,
      fun () ->
        let open T in
        let expect = Node ({ Attr.char = 'b'; word_list = [ "word" ] }, Nil, Nil) in
        Alcotest.(check dict_t) "tree" expect @@ T.make_tree [ ("b", [ "word" ]) ] );
    ( "should have sibling node when dict contains difference prefix labels",
      `Quick,
      fun () ->
        let open T in
        let expect =
          Node
            ( { Attr.char = 'b'; word_list = [ "word" ] },
              Node ({ Attr.char = 'c'; word_list = [ "next_word" ] }, Nil, Nil),
              Nil )
        in
        let dict = [ ("b", [ "word" ]); ("c", [ "next_word" ]) ] in
        Alcotest.(check dict_t) "tree" expect @@ T.make_tree dict );
    ( "should have child node when dict contains label that is longer than 1",
      `Quick,
      fun () ->
        let open T in
        let expect =
          Node
            ( { Attr.char = 'b'; word_list = [ "word" ] },
              Nil,
              Node ({ Attr.char = 'c'; word_list = [ "next_word" ] }, Nil, Nil) )
        in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        Alcotest.(check dict_t) "tree" expect @@ T.make_tree dict );
    ( "should return None when tree do not have sequence of query",
      `Quick,
      fun () ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        Alcotest.(check @@ option dict_t) "query" None @@ query ~query:"foo" tree );
    ( "should return between node if it is longest matched",
      `Quick,
      fun () ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        let expect =
          Some
            (Node
               ( { Attr.char = 'b'; word_list = [ "word" ] },
                 Nil,
                 Node ({ Attr.char = 'c'; word_list = [ "next_word" ] }, Nil, Nil) ))
        in
        Alcotest.(check @@ option dict_t) "query" expect @@ query ~query:"b" tree );
    ( "should return longest matched content",
      `Quick,
      fun () ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        let expect = Some (Node ({ Attr.char = 'c'; word_list = [ "next_word" ] }, Nil, Nil)) in
        Alcotest.(check @@ option dict_t) "query" expect @@ query ~query:"bc" tree );
    ( "forward_match should return None when query is empty",
      `Quick,
      fun _ ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        Alcotest.(check @@ option @@ pair (list string) int) "query" None @@ forward_match ~query:"" tree );
    ( "forward_match should return None when tree do not have any node",
      `Quick,
      fun _ ->
        let open T in
        Alcotest.(check @@ option @@ pair (list string) int) "query" None @@ forward_match ~query:"foo" Nil );
    ( "should return None when tree do not have forward matched sequence of query",
      `Quick,
      fun _ ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        Alcotest.(check @@ option @@ pair (list string) int) "forward match" None @@ forward_match ~query:"foo" tree );
    ( "should return between node if it is longest matched",
      `Quick,
      fun _ ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        let expect = Some ([ "word" ], 1) in
        Alcotest.(check @@ option @@ pair (list string) int) "forward match" expect @@ forward_match ~query:"ba" tree );
    ( "should return longest matched content",
      `Quick,
      fun _ ->
        let open T in
        let dict = [ ("b", [ "word" ]); ("bc", [ "next_word" ]) ] in
        let tree = make_tree dict in
        let expect = Some ([ "next_word" ], 2) in
        Alcotest.(check @@ option @@ pair (list string) int) "forward match" expect @@ forward_match ~query:"bca" tree
    );
  ]
