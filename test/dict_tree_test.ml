open OUnit2

module T = Migemocaml.Dict_tree

let suite =
  "Dict tree" >:::
  ["should return Nil if dict is empty" >:: (fun _ ->
       let open T in
       assert_equal Nil @@ T.make_tree []
     );
   "should return single node if label has only one byte" >:: (fun _ ->
       let open T in
       let expect = Node ({char = 'b'; word_list = ["word"]}, Nil, Nil) in
       assert_equal expect @@ T.make_tree [("b", ["word"])]
     );
   "should have sibling node when dict contains difference prefix labels" >:: (fun _ ->
       let open T in
       let expect = Node ({Attr.char = 'b'; word_list = ["word"]},
                          Node ({Attr.char = 'c'; word_list = ["next_word"]}, Nil, Nil),
                          Nil) in
       let dict = [("b", ["word"]);
                   ("c", ["next_word"])] in
       assert_equal expect @@ T.make_tree dict
     );
   "should have child node when dict contains label that is longer than 1" >:: (fun _ ->
       let open T in
       let expect = Node ({Attr.char = 'b'; word_list = ["word"]},
                          Nil,
                          Node ({Attr.char = 'c'; word_list = ["next_word"]}, Nil, Nil)
                         ) in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       assert_equal expect @@ T.make_tree dict
     );
   "should return None when tree do not have sequence of query" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       assert_equal None @@ query ~query:"foo" tree
     );

   "should return between node if it is longest matched" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       let expect = Some (Node ({Attr.char = 'b'; word_list = ["word"]},
                                Nil,
                               Node ({Attr.char = 'c'; word_list = ["next_word"]}, Nil, Nil))) in
       assert_equal expect @@ query ~query:"b" tree
     );

   "should return longest matched content" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       let expect = Some (Node ({Attr.char = 'c'; word_list = ["next_word"]}, Nil, Nil)) in
       assert_equal expect @@ query ~query:"bc" tree
     );

   "forward_match should return None when query is empty" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       assert_equal None @@ forward_match ~query:"" tree
     );
   "forward_match should return None when tree do not have any node" >:: (fun _ ->
       let open T in
       assert_equal None @@ forward_match ~query:"foo" Nil
     );

   "should return None when tree do not have forward matched sequence of query" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       assert_equal None @@ forward_match ~query:"foo" tree
     );
   "should return between node if it is longest matched" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       let expect = Some (["word"], 1) in
       assert_equal expect @@ forward_match ~query:"ba" tree
     );

   "should return longest matched content" >:: (fun _ ->
       let open T in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       let tree = make_tree dict in
       let expect = Some (["next_word"], 2) in
       assert_equal expect @@ forward_match ~query:"bca" tree
     );
  ]
