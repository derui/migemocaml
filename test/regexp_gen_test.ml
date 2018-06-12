open OUnit2

open Migemocaml.Regexp_gen

let suite =
  "Regular expression generator" >:::
  ["should return empty tree if word is empty" >:: (fun _ ->
       assert_equal "" @@ generate @@ add_word ~word:"" empty
     );
   "add sequence of tree having word if the word not contains" >:: (fun _ ->
       assert_equal "abあ" @@ generate @@ add_word ~word:"abあ" empty
     );
   "add sequence of tree having word if the word is same partially added before " >:: (fun _ ->
       let tree = add_word ~word:"abあ" empty in
       let tree = add_word ~word:"abい" tree in
       assert_equal ~printer:(fun v -> v) "ab[いあ]" @@ generate tree
     );
   "should ignore long sequence if already added partially" >:: (fun _ ->
       let tree = add_word ~word:"abあ" empty in
       assert_equal "abあ" @@ generate @@ add_word ~word:"abあい" tree
     );
   "should delete previous sequence if the word is shorter than added before" >:: (fun _ ->
       let tree = add_word ~word:"abあ" empty in
       assert_equal "ab" @@ generate @@ add_word ~word:"ab" tree
     );
   "should generate empty rule from empty tree" >:: (fun _ ->
       assert_equal "" @@ generate empty
     );
   "should generate rule to match single character if add word having only a character" >:: (fun _ ->
       let tree = add_word ~word:"a" empty in
       assert_equal ~printer:(fun v -> v) "a" @@ generate tree
     );
   "should be able to generate rule to match each words that do not cover character" >:: (fun _ ->
       let tree = add_word ~word:"ab" empty in
       let tree = add_word ~word:"ca" tree in
       assert_equal ~printer:(fun v -> v) "(ca|ab)" @@ generate tree
     );
   "should be able to generate rule to match sibling word do not have child" >:: (fun _ ->
       let tree = add_word ~word:"ab" empty in
       let tree = add_word ~word:"ac" tree in
       assert_equal ~printer:(fun v -> v) "a[cb]" @@ generate tree
     );
   "should be able to generate rule to match nesting words" >:: (fun _ ->
       let tree = add_word ~word:"Es" empty in
       let tree = add_word ~word:"Einstenium" tree in
       assert_equal ~printer:(fun v -> v) "E(s|instenium)" @@ generate tree
     );
   "should be able to generate rule with multi-byte characters" >:: (fun _ ->
       let tree = add_word ~word:"アイ" empty in
       let tree = add_word ~word:"アーイシャ" tree in
       let tree = add_word ~word:"アイーシャ" tree in
       let tree = add_word ~word:"アイコン化" tree in
       let tree = add_word ~word:"アイロン台" tree in
       assert_equal ~printer:(fun v -> v) "ア(イ|ーイシャ)" @@ generate tree
     );
   "should be able to generate nested rule" >:: (fun _ ->
       let tree = add_word ~word:"Iueo" empty in
       let tree = add_word ~word:"いうえお" tree in
       assert_equal ~printer:(fun v -> v) "(いうえお|Iueo)" @@ generate tree
     );
  ]
