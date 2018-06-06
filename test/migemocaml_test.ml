open OUnit2

let suite = "Migemocaml" >::: [
    Charset_test.suite;
    Migemo_dict_parser_test.suite;
  ]

let () =
  run_test_tt_main suite
