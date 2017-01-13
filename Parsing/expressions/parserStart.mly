%{
	open Printf
	open Lexing
	open Expressions
%}
/* starting point */
%start compilationUnit
%type <Expressions.statement> compilationUnit

%%
compilationUnit:
	s=block { s }
	| error { raise (JavaException "ERROR") }
;
/* block */
%public block:
	LCURL lvds=localVariableDeclAndStmts RCURL { ST_block(lvds) }
	| LCURL RCURL { ST_block(List.append [] [ST_empty]) }
;

%public localVariableDeclAndStmts:
	lvd=localVariableDeclOrStmt { []@[lvd] }
	| lvds=localVariableDeclAndStmts lvd=localVariableDeclOrStmt { lvds@[lvd] }
;

localVariableDeclOrStmt:
	lvd=localVariableDeclStmt { lvd } 
	| stmt=statement { stmt }
;

%public localVariableDeclStmt:
	ts=allTypes vd=variableDeclarators SEMI { ST_var_decl(None,ts,vd) }
	| FINAL ts=allTypes vd=variableDeclarators SEMI { ST_var_decl(Some("final "),ts,vd) }
;

/* variable declarators */
variableDeclarators: 
 	vd=variableDeclarator { []@[vd] }
	| vds=variableDeclarators COMM vd=variableDeclarator { vds@[vd] }
;

variableDeclarator:
	dn=declaratorName { EX_Var_decl(dn, None) }
	| dn=declaratorName ASSIGN vi=variableInitializer { EX_Var_decl(dn,Some(vi)) }
;

declaratorName: 
	id=IDENTIFIER { Identifier(id) }
;

variableInitializer:
	ex=expression { []@[ex] }
	| LCURL RCURL { [] }
	| LCURL arri=arrayInitializers RCURL { arri }
;

arrayInitializers:
	vi=variableInitializer { vi }
	| ai=arrayInitializers COMM vi=variableInitializer  { ai@vi }
	| ai=arrayInitializers COMM { ai }
;
/* end variable declarators */

/* allocations */
newAllocationExpression:
	pall=plainNewAllocationExpression { EX_New_alloc(None, pall) }
	| qn=qualifiedName DOT pall=plainNewAllocationExpression { EX_New_alloc(Some(EX_QualifiedName(qn)),pall) }
;

plainNewAllocationExpression:
	arrall=arrayAllocationExpression { arrall }
    	| call=classAllocationExpression { call }
    	| arrall=arrayAllocationExpression LCURL RCURL { arrall }
    	| call=classAllocationExpression LCURL RCURL { call }
    	| arrall=arrayAllocationExpression LCURL arri=arrayInitializers RCURL { EX_Plain_array_alloc(arrall,arri) }
    	(*| call=classAllocationExpression LCURL fdec=fieldDeclarations RCURL { call^"{"^fdec^"}" }*)
;

classAllocationExpression:
	NEW tn=types LPAR args=argumentList RPAR { EX_Class_alloc(tn,Some(args)) }
	| NEW tn=types LPAR RPAR { EX_Class_alloc(tn, None) }
;

argumentList:
	ex=expression { []@[ex] }
	| args=argumentList COMM ex=expression { args@[ex] }
;

arrayAllocationExpression:
	NEW tn=types de=dimExprs d=dims { EX_Array_alloc(tn,Some(de),Some(d)) }
	| NEW tn=types de=dimExprs { EX_Array_alloc(tn,Some(de),None) }
    | NEW tn=types d=dims { EX_Array_alloc(tn,None,Some(d)) }
;

dimExprs:
	de=dimExpr { []@[de] }
	| ds=dimExprs d=dimExpr { ds@[d] }
;

dimExpr:
	LBRAC ex=expression RBRAC { ex }
;
/* end allocations */

%public primaryExpression:
	qn=qualifiedName { P_Qualified(qn) }
	| njs=notJustName { P_NotJustName(njs) }
;

%public notJustName:
	spn=specialName { Identifier(spn) }
	| all=newAllocationExpression { all }
	| cpri=complexPrimary { cpri }
;
/* end types */

complexPrimary:
	LPAR ex=expression RPAR { ex }
	| cprin=complexPrimaryNoParenthesis { cprin }
;

%public complexPrimaryNoParenthesis:
	stlit=STRLIT { Literal(L_Str stlit) }
	| blit=BOOLEANLIT { Literal(L_Boolean blit) }
	| ilit=INTLIT { Literal(L_Int ilit) }
	| clit=CHARLIT { Literal(L_Char clit) }
	| dlit=DOUBLELIT { Literal(L_Double dlit) }
	| flit=FLOATLIT { Literal(L_Float flit) }
	| NULLLIT { Literal(L_Null) }
	| aa=arrayAccess { aa }
	| fa=fieldAccess { fa }
	| mc=methodCall { mc }
;

arrayAccess
	: qn=qualifiedName LBRAC e=expression RBRAC { EX_Array_access(EX_QualifiedName(qn),e) }
	| cp=complexPrimary LBRAC e=expression RBRAC { EX_Array_access(cp,e) }
	;

fieldAccess
	: njn=notJustName DOT id=IDENTIFIER { EX_Field_access(njn, Some(Identifier(id))) }
	| rpe=realPostfixExpression DOT id=IDENTIFIER { EX_Field_access(rpe, Some(Identifier(id))) }
    | qn=qualifiedName DOT THIS { EX_Field_access(EX_QualifiedName(qn), Some(Identifier("this "))) }
    | qn=qualifiedName DOT CLASS { EX_Field_access(EX_QualifiedName(qn), Some(Identifier("class "))) }
    | pt=primitiveType DOT CLASS { EX_Field_access(EX_Primitive(pt, None), Some(Identifier("class "))) }
	;

methodCall
	: ma=methodAccess LPAR al=argumentList RPAR { EX_Method_access(ma,al)}
	| ma=methodAccess LPAR RPAR { EX_Method_access(ma, []) }
	;

methodAccess
	: cpnp=complexPrimaryNoParenthesis { cpnp }
	| sn=specialName { Identifier(sn) }
	| qn=qualifiedName { EX_QualifiedName(qn) }
	;

specialName:
	THIS { "this" }
	| SUPER { "super" }
	/* | NULLLIT { "null" } */
;

%%
let parse_error s = 
	print_endline s;
	flush stdout