module C = Migemocaml.Charset.Utf8

let suite =
  let char_t = Alcotest.(option @@ pair int64 int) in
  [
    ( "should return None if sequence is empty",
      `Quick,
      fun () -> Alcotest.(check char_t) "empty" None @@ C.raw_to_character "" );
    ( "should return ascii code if first bytes sequence is ascii character",
      `Quick,
      fun () -> Alcotest.(check char_t) "first byte" (Some (Int64.of_int @@ Char.code 'a', 1)) @@ C.raw_to_character "a"
    );
    ( "should return ascii code if first bytes sequence contains ascii code",
      `Quick,
      fun () ->
        Alcotest.(check char_t) "ascii code" (Some (110L, 1)) @@ C.raw_to_character @@ String.make 1 @@ Char.chr 110 );
    ( "should return multi-byte value if byte sequence has multi-byte sequence",
      `Quick,
      fun () -> Alcotest.(check char_t) "multibyte" (Some (0x30C6L, 3)) @@ C.raw_to_character "テスト" );
    ( "should return single byte if character is ascii",
      `Quick,
      fun () -> Alcotest.(check string) "character to raw" "a" @@ C.character_to_raw Int64.(of_int @@ Char.code 'a') );
    ( "should return multi bytes if character is multi-byte character",
      `Quick,
      fun () ->
        (* 0x30c6 is unicode of 'テ' *)
        Alcotest.(check string) "character to raw" "テ" @@ C.character_to_raw 0x30c6L );
  ]
