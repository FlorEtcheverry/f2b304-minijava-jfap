open JavaLexer
open JavaParser
open Lexing 

let position lexbuf=
	let pos=lexeme_start_p lexbuf in 
	let error=Lexing.lexeme lexbuf in
	"Unexected: \""^error^"\" in line: "^string_of_int pos.pos_lnum^" char:"^string_of_int(pos.pos_cnum-pos.pos_bol+1);;

let compile file =
		print_string ("File "^file^" is being treated!\n");
		try
		let input_file = open_in file in
		let lexbuf = Lexing.from_channel input_file in
		try
			print_string (javaMethods nexttoken lexbuf);
			print_newline ();
			close_in (input_file);
		with 
				|SyntaxError s -> print_endline (s);
				|JavaParser.Error -> print_endline ("Lexing error  "^(position lexbuf));
		with	Sys_error s -> print_endline ("Can't find file ' " ^ file ^ "'");;
compile Sys.argv.(1);;