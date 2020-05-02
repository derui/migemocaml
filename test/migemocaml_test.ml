let () =
  Alcotest.run "Migemocaml"
    [
      ("UTF-8 Charset converter", Charset_test.suite);
      ("CMigemo dictionary parser", Migemo_dict_parser_test.suite);
      ("CMigemo conversion parser", Migemo_conv_parser_test.suite);
      ("Dict tree", Dict_tree_test.suite);
      ("Romaji converter", Converter_romaji_test.suite);
      ("Multibyte-allowed character converter", Converter_character_test.suite);
      ("Regular expression generator", Regexp_gen_test.suite);
      ("Migemo core module", Migemo_test.suite);
    ]
