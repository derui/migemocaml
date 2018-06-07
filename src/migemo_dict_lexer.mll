(** This lexer for lexing C/Migemo dictionary  *)
{
  (* This part is inserted into the head of the generated file. *)
}

rule token = parse
  | ['\n']+ {
      Lexing.new_line lexbuf;token lexbuf
    }
  | [';'] {
      line_comment lexbuf; token lexbuf
    }
  | ['\t'] {
      Migemo_dict_parser.SEPARATOR
    }
  | [^ '\t' ';' '\n']+ { (* This means 'any byte' *)
      Migemo_dict_parser.WORD (Lexing.lexeme lexbuf)
    }
  | eof {
      Migemo_dict_parser.EOF
    }

and line_comment = parse
  | '\n' { Lexing.new_line lexbuf }
  | eof { () }
  | _ { line_comment lexbuf }
