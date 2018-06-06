open OUnit2

module Parser = Migemocaml.Migemo_dict_parser
module Lexer = Migemocaml.Migemo_dict_lexer

let with_in_channel file f =
  let ic = open_in_bin file in
  try
    f ic
  with _ as e ->
    close_in ic;
    raise e

let suite =
  "C/Migemo dictionary parser" >:::
  ["should return empty list if file is empty" >:: (fun _ ->
       let dict = Parser.dict Lexer.token (Lexing.from_string "") in
       assert_equal [] dict
     );
   "should return empty list if contents only have line comments" >:: (fun _ ->
       let content = {|
;
;normal comment
;日本語コメント
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       assert_equal [] dict
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
  ]
