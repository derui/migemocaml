open OUnit2

let suite = "Migemocaml" >::: [
    Charset_test.suite;
    Migemo_dict_parser_test.suite;
    Dict_tree_test.suite;
    Converter_romaji_test.suite;
    Converter_character_test.suite;
    Regexp_gen_test.suite;
    Migemo_test.suite;
    Migemo_conv_parser_test.suite;
  ]

let () =
  run_test_tt_main suite
