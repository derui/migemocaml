open OUnit2

module Parser = Migemocaml.Migemo_conv_parser
module Lexer = Migemocaml.Migemo_conv_lexer

let with_in_channel file f =
  let ic = open_in_bin file in
  try
    f ic
  with _ as e ->
    close_in ic;
    raise e

let suite =
  "C/Migemo conversion parser" >:::
  ["should return empty list if file is empty" >:: (fun _ ->
       let dict = Parser.dict Lexer.token (Lexing.from_string "") in
       assert_equal [] dict
     );
   "should be able to read line comment and specialized sharp" >:: (fun _ ->
       let content = {|
# line comment
##	specialized sharp
sharp	#
わーど	ワード
ふくすう	複数	副数
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       assert_equal [("#", ["specialized sharp"]);
                     ("sharp", ["#"]);
                     ("わーど", ["ワード"]);
                     ("ふくすう", ["複数";"副数"])] dict
     );
   "should return node list that read from content" >:: (fun _ ->
       let content = {|
わーど	ワード
ふくすう	複数	副数
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       assert_equal [("わーど", ["ワード"]);("ふくすう", ["複数";"副数"])] dict
     );
   "should allow to contain white space in word" >:: (fun _ ->
       let content = {|
simpleword	simple word
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       assert_equal [("simpleword", ["simple word"]);] dict
     );
  ]
