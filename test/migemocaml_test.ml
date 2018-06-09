open OUnit2

let suite = "Migemocaml" >::: [
    Charset_test.suite;
    Migemo_dict_parser_test.suite;
    Dict_tree_test.suite;
    Romaji_test.suite;
  ]

let () =
  run_test_tt_main suite
