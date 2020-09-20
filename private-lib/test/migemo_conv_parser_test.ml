module Parser = Migemocaml_private.Migemo_conv_parser
module Lexer = Migemocaml_private.Migemo_conv_lexer

let with_in_channel file f =
  let ic = open_in_bin file in
  try f ic
  with _ as e ->
    close_in ic;
    raise e

let suite =
  let dict_t = Alcotest.(list @@ pair string @@ list string) in
  [
    ( "should return empty list if file is empty",
      `Quick,
      fun () ->
        let dict = Parser.dict Lexer.token (Lexing.from_string "") in
        Alcotest.(check dict_t) "empty" [] dict );
    ( "should ignore all lines if lines are line comment",
      `Quick,
      fun () ->
        let content =
          {|
# vi:set ts=8 sts=8 sw=8 tw=0:
#
# hira2kata.dat - 平仮名→カタカナ変換表
#
# Last Change: 19-Jun-2004.
# Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

# 文字コードの違いもこの変換表で吸収する。
|}
        in
        Alcotest.(check dict_t) "dict" [] @@ Parser.dict Lexer.token (Lexing.from_string content) );
    ( "should be able to read line comment and specialized sharp",
      `Quick,
      fun _ ->
        let content = {|
#
# line comment
##	specializedsharp
sharp	#
わーど	ワード
ふくすう	複数
|} in
        let dict = Parser.dict Lexer.token (Lexing.from_string content) in
        Alcotest.(check dict_t)
          "dict"
          [
            ("#", [ "specializedsharp" ]);
            ("sharp", [ "#" ]);
            ("わーど", [ "ワード" ]);
            ("ふくすう", [ "複数" ]);
          ]
          dict );
    ( "should return node list that read from content",
      `Quick,
      fun () ->
        let content = {|
わーど	ワード
ふくすう	複数
|} in
        let dict = Parser.dict Lexer.token (Lexing.from_string content) in
        Alcotest.(check dict_t) "dict" [ ("わーど", [ "ワード" ]); ("ふくすう", [ "複数" ]) ] dict );
  ]
