module Parser = Migemocaml_private.Migemo_dict_parser
module Lexer = Migemocaml_private.Migemo_dict_lexer

let suite =
  let dict_t = Alcotest.(list @@ pair string @@ list string) in
  [
    ( "should return empty list if file is empty",
      `Quick,
      fun () ->
        let dict = Parser.dict Lexer.token (Lexing.from_string "") in
        Alcotest.(check dict_t) "dict" [] dict );
    ( "should return node list that read from content",
      `Quick,
      fun () ->
        let content = {|
わーど	ワード
ふくすう	複数	副数
|} in
        let dict = Parser.dict Lexer.token (Lexing.from_string content) in
        Alcotest.(check dict_t) "dict" [ ("わーど", [ "ワード" ]); ("ふくすう", [ "複数"; "副数" ]) ] dict
    );
    ( "should allow to contain white space in word",
      `Quick,
      fun () ->
        let content = {|
simpleword	simple word
|} in
        let dict = Parser.dict Lexer.token (Lexing.from_string content) in
        Alcotest.(check dict_t) "dict" [ ("simpleword", [ "simple word" ]) ] dict );
  ]
