(* Code for doing the execution *)
open Type
open AST
open Exceptions
open MemoryModel

(* find the start point *)
let get_main_method (jprog : jvm) =
	(* search if there is a main method, 
	if yes -> return it
	else raise an exception *)
	let main_method_name = (jprog.public_class ^ "_main_String[]") (* classic java main method *)
	in
	try 
		(* get the method from the jvm table *)
		Hashtbl.find jprog.methods main_method_name
	with
	| _ -> raise (NoMainMethod ("Error: Main method not found in class " ^ jprog.public_class ^ 
								", please define the main method as: public static void main(String[] args)" ^
								"or a JavaFX application class must extend javafx.application.Application "))

let compute_value op val1 val2 =
	match val1,val2 with
	| IntVal(v1),IntVal(v2) -> begin
				match op with
				| Op_add -> IntVal(v1+v2)
				(*| Op_sub  
				| Op_mul  
				| Op_div  
				| Op_mod 
				| Op_cand
				| Op_or   
				| Op_and  
				| Op_xor  
				| Op_eq   
				| Op_ne   
				| Op_gt   
				| Op_lt   
				| Op_ge   
				| Op_le   
				| Op_shl  
				| Op_shr  
				| Op_cor  
				| Op_shrr *)
				end

(* do var++ and var--*)
let rec execute_postfix (jprog : jvm) (e : expression) postop =
	(* see what type *)
	match postop with
	| Incr -> 	begin
				match (execute_expression jprog e) with
				| IntVal(v) -> IntVal(v+1)
				| _ -> raise ArithmeticException
				end
	| Decr -> 	begin
				match (execute_expression jprog e) with
				| IntVal(v) -> IntVal(v-1)
				| _ -> raise ArithmeticException
				end

(* do ++var and --var *)
and execute_prefix (jprog : jvm) preop (e : expression) =
	(* see what type *)
	match preop with
	| Op_incr -> begin 
				match (execute_expression jprog e) with
				| IntVal(v) -> IntVal(v+1)
				| _ -> raise ArithmeticException
				end
	| Op_decr -> begin 
				match (execute_expression jprog e) with
				| IntVal(v) -> IntVal(v-1)
				| _ -> raise ArithmeticException
				end

(* do assignments *)
and execute_assign (jprog : jvm) e1 (op : assign_op) e2 =
	(* see what type *)
	let left = (execute_expression jprog e1)
	in 
	let right = (execute_expression jprog e2)
	in
	let (_, scope) = Stack.top jprog.jvmstack 
	in
	match e1.edesc with
				| Name(n) -> begin
							match op with
							| Assign -> Hashtbl.replace scope.visible n right;
										right
							(*| Ass_add -> Hashtbl.replace scope.visible n (execute_operator left right);
										right
							| Ass_sub 
							| Ass_mul 
							| Ass_div 
							| Ass_mod 
							| Ass_shl 
							| Ass_shr 
							| Ass_shrr
							| Ass_and 
							| Ass_xor 
							| Ass_or  *)
							end
				| _ -> raise (Exception "Bad assignment")

(* variable linking *)
and execute_name (jprog : jvm) (name : string) =
	let (_, scope) = Stack.top jprog.jvmstack 
	in
	try 
		Hashtbl.find scope.visible name
	with
	| Not_found -> raise (Exception "Variable not defined")

(* execute operation *)
and execute_operator (jprog : jvm) e1 (op : infix_op) e2 =
	let left = (execute_expression jprog e1)
	in 
	let right = (execute_expression jprog e2)
	in
	compute_value op left right

(* execute an expression and send back it's value *)
and execute_expression (jprog : jvm) expr =
	(* check the descriptor *)
	match expr.edesc with 
	| Val(v) -> begin
				match v with
				| String(s) -> StrVal(s)
				| Int(i) -> IntVal(int_of_string i)
				| Float(f) -> FltVal(float_of_string f)
				| Boolean(b) -> BoolVal(b) 
				| Null -> NullVal
				end
			  (*| Char of char option
				*)
	| Post(e, poi) -> execute_postfix jprog e poi
	| Pre(pri, e) -> execute_prefix jprog pri e
	| Name(n) -> execute_name jprog n
	| AssignExp(e1, op, e2) -> execute_assign jprog e1 op e2
	| Op(e1, op, e2) -> execute_operator jprog e1 op e2
	(* | New of string option * string list * expression list
	| If(e1, e2, e3) of expression * expression * expression
	| NewArray of Type.t * (expression option) list * expression option
	| Call of expression option * string * expression list
	| Attr of expression * string
	| ArrayInit of expression list
	| Array of expression * (expression option) list
	| Pre of prefix_op * expression
	| CondOp of expression * expression * expression
	| Cast of Type.t * expression
	| Type of Type.t
	| ClassOf of Type.t
	| Instanceof of expression * Type.t
	| VoidClass
 *)

(* execute a variable declaration *)
let execute_vardecl (jprog : jvm) decl = 
	match decl with
	(* type, name, optional initialization *)
	| (Primitive(p), n, eo) -> 
			begin
			let (_, scope) = Stack.top jprog.jvmstack 
			in
			(* matched an  *)
			Hashtbl.add scope.visible n (match eo with 
										| None -> Hashtbl.find jprog.defaults p;
										(* we need type checks here*)
										| Some(e) -> execute_expression jprog e)
			end
	(*
	| Array(typ,size) -> (stringOf typ)^(array_param size)
	| Ref rt -> stringOf_ref rt 
	*)

let execute_statement jprog stmt = 
	match stmt with
	(* treat all the expressions *)
	| Expr(e) -> (* print_endline (AST.string_of_expression e) *)
			begin
			match e.edesc with
			| Call(obj, name, args) -> begin
					match name with
					| "println" -> print_endline (string_of_value (execute_expression jprog (List.hd args))) 
					| _ -> print_endline "Statement not executable yet, try a System.out.println().."
					end
			| _ -> print_endline "Statement not executable yet, try a System.out.println().."
			end
	(* a variable declaration *)
	| VarDecl(vardecls) -> List.iter (execute_vardecl jprog) vardecls

	| _ -> print_endline "Statement not executable yet, try a System.out.println().."


(* add default initializer variables *)
let add_defaults (jprog : jvm) =
	Hashtbl.add jprog.defaults Int (IntVal 0);
	(* Hashtbl.add jprog.defaults Int StrVal(""); 
	*)
	Hashtbl.add jprog.defaults Float (FltVal 0.0);
	Hashtbl.add jprog.defaults Boolean (BoolVal false)

(* Make a structure that contains the whole program, its heap
stack .. *)
let execute_code (jprog : jvm) =
	(* setup the JVM *)
	add_defaults jprog;

	let startpoint = get_main_method jprog 
	in
	(* since we know that by now we have a public class *)
	let currentscope = { 
						visible = (Hashtbl.create 10) 
					   }
	in
	(* add the main mathods scope to the stack *)
	Stack.push (startpoint.mname, currentscope) jprog.jvmstack;
	(* the main method *)
	AST.print_method "" startpoint;
	(* run the program *)
	print_endline "### Running ... ###";
	(* print_scope jprog; *)
	List.iter (execute_statement jprog) startpoint.mbody;
	print_scope jprog
