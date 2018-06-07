open OUnit2

module C = Migemocaml.Charset.Utf8

let suite =
  "UTF-8 Charset converter" >:::
  ["should return None if sequence is empty" >:: (fun _ ->
       assert_equal None @@ C.raw_to_character ""
     );
   "should return ascii code if first bytes sequence is ascii character" >:: (fun _ ->
       assert_equal (Some (Int64.of_int @@ Char.code 'a', 1)) @@ C.raw_to_character "a"
     );
   "should return ascii code if first bytes sequence contains ascii code" >:: (fun _ ->
       assert_equal (Some (110L, 1)) @@ C.raw_to_character @@ String.make 1 @@ Char.chr 110
     );
   "should return multi-byte value if byte sequence has multi-byte sequence" >:: (fun _ ->
       assert_equal (Some (0x30C6L, 3)) @@ C.raw_to_character "テスト"
     );
   "should return single byte if character is ascii" >:: (fun _ ->
       assert_equal "a" @@ C.character_to_raw Int64.(of_int @@ Char.code 'a')
     );
   "should return multi bytes if character is multi-byte character" >:: (fun _ ->
       (* 0x30c6 is unicode of 'テ' *)
       assert_equal "テ" @@ C.character_to_raw 0x30c6L
     );
  ]
