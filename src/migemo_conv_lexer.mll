(** This lexer for lexing C/Migemo character converter  *)
{
  (* This part is inserted into the head of the generated file. *)
}

rule token = parse
  | '\n' {
      Lexing.new_line lexbuf;Migemo_conv_parser.NEWLINE
    }
  | "#" {
      Migemo_conv_parser.SHARP
    }
  | [' ' '\t']+ {
      Migemo_conv_parser.SEPARATOR
    }
  | [^ ' ' '\t' '#' '\n']+ { (* This means 'any byte' *)
      Migemo_conv_parser.WORD (Lexing.lexeme lexbuf)
    }
  | eof {
      Migemo_conv_parser.EOF
    }

and line_comment = parse
  | '\n' { Lexing.new_line lexbuf }
  | eof { () }
  | _ { line_comment lexbuf }
