open Migemocaml_private.Regexp_gen

let suite =
  let module S = Migemocaml_private.Regexp_spec.Default in
  [
    ( "should return empty tree if word is empty",
      `Quick,
      fun () -> Alcotest.(check string) "regexp" "" @@ generate (module S) @@ add_word ~word:"" empty );
    ( "add sequence of tree having word if the word not contains",
      `Quick,
      fun () -> Alcotest.(check string) "regexp" "abあ" @@ generate (module S) @@ add_word ~word:"abあ" empty );
    ( "add sequence of tree having word if the word is same partially added before ",
      `Quick,
      fun () ->
        let tree = add_word ~word:"abあ" empty in
        let tree = add_word ~word:"abい" tree in
        Alcotest.(check string) "regexp" "ab[いあ]" @@ generate (module S) tree );
    ( "should ignore long sequence if already added partially",
      `Quick,
      fun () ->
        let tree = add_word ~word:"abあ" empty in
        Alcotest.(check string) "regexp" "abあ" @@ generate (module S) @@ add_word ~word:"abあい" tree );
    ( "should delete previous sequence if the word is shorter than added before",
      `Quick,
      fun () ->
        let tree = add_word ~word:"abあ" empty in
        Alcotest.(check string) "regexp" "ab" @@ generate (module S) @@ add_word ~word:"ab" tree );
    ( "should generate empty rule from empty tree",
      `Quick,
      fun () -> Alcotest.(check string) "regexp" "" @@ generate (module S) empty );
    ( "should generate rule to match single character if add word having only a character",
      `Quick,
      fun () ->
        let tree = add_word ~word:"a" empty in
        Alcotest.(check string) "regexp" "a" @@ generate (module S) tree );
    ( "should be able to generate rule to match each words that do not cover character",
      `Quick,
      fun () ->
        let tree = add_word ~word:"ab" empty in
        let tree = add_word ~word:"ca" tree in
        Alcotest.(check string) "regexp" "(ca|ab)" @@ generate (module S) tree );
    ( "should be able to generate rule to match sibling word do not have child",
      `Quick,
      fun () ->
        let tree = add_word ~word:"ab" empty in
        let tree = add_word ~word:"ac" tree in
        Alcotest.(check string) "regexp" "a[cb]" @@ generate (module S) tree );
    ( "should be able to generate rule to match nesting words",
      `Quick,
      fun () ->
        let tree = add_word ~word:"Es" empty in
        let tree = add_word ~word:"Einstenium" tree in
        Alcotest.(check string) "regexp" "E(s|instenium)" @@ generate (module S) tree );
    ( "should be able to generate rule with multi-byte characters",
      `Quick,
      fun () ->
        let tree = add_word ~word:"アイ" empty in
        let tree = add_word ~word:"アーイシャ" tree in
        let tree = add_word ~word:"アイーシャ" tree in
        let tree = add_word ~word:"アイコン化" tree in
        let tree = add_word ~word:"アイロン台" tree in
        Alcotest.(check string) "regexp" "ア(イ|ーイシャ)" @@ generate (module S) tree );
    ( "should be able to generate nested rule",
      `Quick,
      fun () ->
        let tree = add_word ~word:"Iueo" empty in
        let tree = add_word ~word:"いうえお" tree in
        Alcotest.(check string) "regexp" "(いうえお|Iueo)" @@ generate (module S) tree );
    ( "should be escape special characters of regular expression",
      `Quick,
      fun () ->
        let tree = add_word ~word:"++" empty in
        Alcotest.(check string) "regexp" "\\+\\+" @@ generate (module S) tree );
  ]
