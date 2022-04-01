%{
  (* This part is inserted into the generated file *)
%}

%token <string> WORD
%token NEWLINE SHARP SEPARATOR EOF
%type <(string * string list) list> dict
%type <(string * string list) option> word_mapping
%start dict

%%

dict:
| words = list(word_mapping); EOF { List.filter (function
                                      | None -> false
                                      | Some _ -> true) words
                                  |> List.map (function
                                         | None -> failwith "Unknown error"
                                         | Some v -> v)
                              }

word:
| WORD {$1}
| SHARP SHARP {"#"}
| SHARP WORD {"#" ^ $2}

wildcard:
| WORD
| SHARP
| SEPARATOR {""}

word_mapping:
| word SEPARATOR word NEWLINE { Some ($1, [$3]) }
| list(SHARP) NEWLINE {None}
| SHARP SEPARATOR list(wildcard) NEWLINE {None}
| word SEPARATOR SHARP NEWLINE {Some ($1, ["#"])}
