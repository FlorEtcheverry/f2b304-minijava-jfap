open Ast
open Printing


type annotation = { aname: string ; aoth: string };; (* TODO *)
type jexception = { ename: string ; eoth: string };; (* TODO *)

type modifier=
	|M_Annot of annotation
	|M_Public
	|M_Protected
	|M_Private
	|M_Abstract
	|M_Static
	|M_Final
	|M_Synchronized
	|M_Native
	|M_Strictfp;;

type variableModifier =
	|VM_Final
	|VM_Annot of annotation;;

type typeParam =
	| TPL_Ident of string
	| TPL_Extend of string * string	


type resultType=
	|RT_Type of allTypes	
	|RT_Void

type declaratorId = 
	|DI_Identifier of string

type body={expr:string};;

type formalParameter = {
	pmodif: variableModifier list; 
	ptype: allTypes; 
	pname: declaratorId;
	pelipsis: bool;
};;

type methodDeclarator= {
	mname: string; 
	mparams: formalParameter list
}

type javaMethod={
	mutable jmmodifiers: modifier list;
	mutable jmtparam: typeParam list; 	
	mutable jmrtype: resultType;
	jmdeclarator: methodDeclarator;
	jmthrows: jexception list;
	jmbody: body;
}


type parentName = string*(typeParam list option)


type parentClass=
	| C_Parent of parentName
	| C_Object


type javaClass={
	mutable cmodifiers: modifier list;
	cidentifier: string;
	ctparam: typeParam list;
	cparent: parentClass;
	cinterfaces: string list; (*TODO*)
	cbody: insideClass list;
}
and insideClass=
	|IC_Method of javaMethod
	|IC_Attribute
	|IC_Class of javaClass
	|IC_Semi
	|IC_Empty


(* return types of each defined parser*)

type abstractSyntaxTree = 
	| JML of javaMethod list
	| STR of string


(* printers *)


let print_annot a=a.aname;;
let print_excep a=a.ename;;

let print_modif modifier= match modifier with
	|M_Annot a -> print_annot a
	|M_Public -> "public"
	|M_Protected -> "protected"
	|M_Private -> "private"
	|M_Abstract -> "abstract"
	|M_Static -> "static"
	|M_Final -> "final"
	|M_Synchronized -> "synchronized"
	|M_Native -> "native"
	|M_Strictfp -> "strictfp";; 

let print_vm var = match var with
	|VM_Final -> "final"
	|VM_Annot a -> print_annot a;;


let print_type_param var = match var with
	| TPL_Ident s -> s
	| TPL_Extend (s1,s2) -> s1^"-ext-"^s2	;;


let print_return_type var = match var with
	|RT_Type t-> string_of_allTypes t	
	|RT_Void -> "void"

let print_declaratorId var = match var with 
	|DI_Identifier s -> s

let print_body var = var.expr;;

let print_formal_parameter var = 
	let el = match var.pelipsis with | true -> "..." | false -> "" in
	(print_list print_vm var.pmodif " ")^" : "^string_of_allTypes var.ptype^el^" : "^(print_declaratorId var.pname)
;;

let print_method_declarator var = var.mname^"\n"^(indent (print_list print_formal_parameter var.mparams "\n"))

let print_java_method var = 
	"\nMethod: "^(print_method_declarator var.jmdeclarator)^
	"\nReturn type: "^(print_return_type var.jmrtype)^
	"\nModifiers: "^(print_list print_modif var.jmmodifiers " ")^
	"\nGenerics: "^(print_list print_type_param var.jmtparam " ")^
	"\nThrows: "^(print_list print_excep var.jmthrows " ")^
	"\nBody: "^print_body var.jmbody;;
