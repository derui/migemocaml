%{
  (* This part is inserted into the generated file *)
%}

%token <string> WORD
%token SEPARATOR EOF
%type <(string * string list) list> dict
%type <string * string list> word_mapping
%start dict

%%

dict:
| word_mapping* EOF { $1 }

word_mapping:
| WORD mapped_word+ { ($1, $2) }

mapped_word:
| SEPARATOR WORD { $2 }
