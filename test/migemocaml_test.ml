open OUnit2

let suite = "Migemocaml" >::: [Charset_test.suite]

let () =
  run_test_tt_main suite
