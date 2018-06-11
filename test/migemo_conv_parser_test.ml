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
   "should ignore all lines if lines are line comment" >:: (fun _ ->
       let content = {|
# vi:set ts=8 sts=8 sw=8 tw=0:
#
# hira2kata.dat - 平仮名→カタカナ変換表
#
# Last Change: 19-Jun-2004.
# Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

# 文字コードの違いもこの変換表で吸収する。
|}
       in
       assert_equal [] @@ Parser.dict Lexer.token (Lexing.from_string content)
     );
   "should be able to read line comment and specialized sharp" >:: (fun _ ->
       let content = {|
#
# line comment
##	specializedsharp
sharp	#
わーど	ワード
ふくすう	複数
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       let printer = (fun l -> String.concat "|" @@ List.map (fun (h, w) -> Printf.sprintf "%s:%s\n" h (String.concat "," w)) l) in
       assert_equal ~printer [("#", ["specializedsharp"]);
                     ("sharp", ["#"]);
                     ("わーど", ["ワード"]);
                     ("ふくすう", ["複数"])] dict
     );
   "should return node list that read from content" >:: (fun _ ->
       let content = {|
わーど	ワード
ふくすう	複数
|}
       in
       let dict = Parser.dict Lexer.token (Lexing.from_string content) in
       assert_equal [("わーど", ["ワード"]);("ふくすう", ["複数"])] dict
     );
  ]
