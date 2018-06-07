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
       let expect = Node ({char = 'b'; word_list = ["word"]},
                          Node ({char = 'c'; word_list = ["next_word"]}, Nil, Nil),
                          Nil) in
       let dict = [("b", ["word"]);
                   ("c", ["next_word"])] in
       assert_equal expect @@ T.make_tree dict
     );
   "should have child node when dict contains label that is longer than 1" >:: (fun _ ->
       let open T in
       let expect = Node ({char = 'b'; word_list = ["word"]},
                          Nil,
                          Node ({char = 'c'; word_list = ["next_word"]}, Nil, Nil)
                         ) in
       let dict = [("b", ["word"]);
                   ("bc", ["next_word"])] in
       assert_equal expect @@ T.make_tree dict
     );

  ]
