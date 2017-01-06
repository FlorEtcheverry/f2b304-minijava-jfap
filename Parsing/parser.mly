%{
	open Printf
	open Lexing

%}
/* brackets */
%token LANG RANG LPAR RPAR LBRAC RBRAC LCURL RCURL /* <> () [] {} */ 

/* delimiters */
%token SEMI COL DOT COMM SQ DQ QM /* ; : . ,  '' "" ? */

/* math binary operators */
%token PLUS MINUS DIV MUL MOD  /* + - / * % */

/* logical bitwiese operators */
%token BAND BOR XOR BNOT /* & | ^ ~ */ 

/* bitwise whifts */
%token LSHIFT RSHIFT LOGSHIFT/* << >> >>> */

/* unary operators */
%token INCREMENT DECREMENT /* ++ -- */

/* logical operators */
%token EQUAL NEQUAL /* == != */
%token GTHAN LTHAN GETHAN LETHAN /* > < >= <= */ 
%token AND OR NOT /* && || ! */


/* assignment operators */
%token ASSIGN /* = */
%token PEQUAL MINUSEQUAL MULEQUAL DIVEQUAL MODEQUAL ANDEQUAL OREQUAL XOREQUAL RSHIFTEQUAL LSHIFTEQUAL LOGSHIFTEQUAL /* += -= *= /= %= &= |= ^= >>= <<= >>>= */

%token ANOT /* @ */

/* special eof */
%token EOF 

/* keywords that are reserved */
%token ABSTRACT
%token ASSERT
%token BOOLEAN
%token BREAK
%token BYTE
%token CASE
%token CATCH
%token CHAR
%token CLASS
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE 
%token ELSE
%token ENUM 
%token EXTENDS
%token FINAL
%token FINALLY
%token FLOAT
%token FOR
%token IF
%token GOTO
%token IMPLEMENTS
%token IMPORT
%token INSTANCEOF
%token INT
%token INTERFACE
%token LONG
%token NATIVE
%token NEW
%token PACKAGE
%token PRIVATE
%token PROTECTED
%token PUBLIC 
%token RETURN
%token SHORT
%token STATIC
%token STRICTFP
%token SUPER
%token SWITCH
%token SYNCHRONIZED
%token THIS
%token THROW
%token THROWS
%token TRANSIENT
%token TRY
%token VOID
%token VOLATILE
%token WHILE

/* identifiers and literals */
%token <string> IDENTIFIER
%token <string> STRLIT
%token <int> INTLIT
%token <float> DOUBLELIT
%token <float> FLOATLIT
%token <char> CHARLIT 
%token <bool> BOOLEANLIT
%token <string> NULLLIT
%token ELIPSIS

/* priorities 
%right ASSIGN
%left OR
%left AND
%left EQUAL NEQUAL
%left GTHAN GETHAN LTHAN LETHAN
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%left DOT
*/
/* starting point */
%start compilationUnit
%type <string> compilationUnit

%%
compilationUnit:
	s=block { s }
	| error { " an error has occured\n" }
;
/* block */
block:
	LCURL lvds=localVariableDeclAndStmts RCURL { "{\n"^lvds^"\n}\n" }
	| LCURL RCURL { "{\n \n}\n" }
;

localVariableDeclAndStmts:
	lvd=localVariableDeclOrStmt { lvd }
	| lvds=localVariableDeclAndStmts lvd=localVariableDeclOrStmt { lvds^lvd }
;

localVariableDeclOrStmt:
	lvd=localVariableDeclStmt { lvd } 
	| stmt=statement { stmt }
;

localVariableDeclStmt:
	ts=types vd=variableDeclarators SEMI { ts^vd^";" }
	| FINAL ts=types vd=variableDeclarators SEMI { "final "^ts^" "^vd^";" }
;

/* statements */
statement:
	es=emptyStmt { es }
	| ls=labelStmt { ls }
	/* | exs=expressionStmt SEMI { exs } */
 	| ss=selectStmt { ss }
	| is=iterStmt { is }
	| js=jumpStmt { js }
	| gs=guardingStmt { gs }
	| b=block { b }

labelStmt:
	id=IDENTIFIER COL { id^" : " }
	| CASE ce=constantExpression COL { "case "^ce^": " }
	| DEFAULT COL { "default : " }
;
/*
expressionStmt:
	e=expression { e }
;
*/
selectStmt:
	IF LPAR e=expression RPAR s=statement { "if("^e^") "^s }
	| IF LPAR e=expression RPAR s1=statement ELSE s2=statement { "if("^e^") "^s1^"\nelse "^s2 }
	| SWITCH LPAR e=expression RPAR b=block { "switch ("^e^") "^b } 
;

jumpStmt: 
	BREAK id=IDENTIFIER SEMI { "break "^id^"; " }
	| BREAK SEMI { "break;" }
    | CONTINUE id=IDENTIFIER SEMI { "continue "^id^"; "}
	| CONTINUE SEMI { "continue;"}
	| RETURN e=expression SEMI { "return "^e^"; "  }
	/* | RETURN SEMI { "return;"} */
	| THROW e=expression SEMI { "throw "^e^"; " }
;

iterStmt: 
	WHILE LPAR e=expression RPAR s=statement { "while("^e^")"^s }
	| DO s=statement WHILE LPAR e=expression RPAR SEMI { "do "^s^" while ("^e^"); "} 
	/*
	| FOR LPAR fi=forInit fe=forExpr fin=forIncr RPAR s=statement { "for("^fi^fe^fin^")"^s } */
	| FOR LPAR fi=forInit fe=forExpr RPAR s=statement { "for("^fi^fe^")"^s } 
	/* TODO add a foreach */
;

forInit: 
	lvds=localVariableDeclStmt { lvds }
	| SEMI { ";" }
;

forExpr: 
	/* e=expression SEMI { e^";" } */
	SEMI { ";" }
;
/*
forIncr: 
	es=expressionStmts { es }
;
*/
guardingStmt: 
	SYNCHRONIZED LPAR e=expression RPAR s=statement { "synchronized ("^e^") "^s }
	| TRY b=block f=finally { "try "^b^f }
	| TRY b=block c=catches { "try "^b^c }
	| TRY b=block c=catches f=finally { "try "^b^c^f }
;
/* end statements */

/* catch */
catches: 
	c=catch { c } 
	| cs=catches c=catch { cs^c }
;

catch: 
	ch=catchHeader b=block { ch^b }
;

catchHeader: 
	CATCH RPAR ts=types id=IDENTIFIER RPAR { "catch ( "^ts^id^" ) "}
	| CATCH RPAR ts=types LPAR { "catch ( "^ts^" ) " }
;

finally: 
	FINALLY b=block { "finally "^b }
;
/* end catch */

/* variable declarators */
variableDeclarators: 
 	vd=variableDeclarator { vd }
	| vds=variableDeclarators COMM vd=variableDeclarator { vds^" , "^vd }
;

variableDeclarator:
	dn=declaratorName { dn }
	| dn=declaratorName ASSIGN vi=varInitializer { dn^" = "^vi }
;

declaratorName: 
	id=IDENTIFIER { id }
;

varInitializer:
	e=expression { e }
	| RCURL LCURL { "{ }" }
	/* | RCURL ai=arrayInitializers LCURL { "{"^ai^ "}" } */
;
/* end variable declarators */
emptyStmt:
	SEMI { ";" }
;

expression: 
	{ " |some expression| " }
;

constantExpression:
	{ " |some constant expression| " }
;
/* types */
types: 
	pt=primitive { pt }
	/* need classes here */
;

primitive: 
	BOOLEAN { "boolean " }
	| CHAR  { "char " }
	| BYTE { "byte " }
	| SHORT { "short " }
	| INT { "int " }
	| LONG { "long " }
	| FLOAT { "float " }
	| DOUBLE { "double " }
	| VOID { "void " }
	;
%%
let parse_error s = 
	print_endline s;
	flush stdout
