
# build all files
OCAML=ocamlbuild 
YACCFLAGS=-use-menhir -yaccflag -v
MYBUILDFOLDER=_build

MYBUILD = ./build
COPYPATH = "../classes"
COPYPATH_EXPR = "../expressions"
COPYPATH_TEST="./testStatements"

PARSING =  types.mly tokens.mly class_methods.mly class_definition.mly types_params_defin.mly modifiers.mly java_file.mly interface_definition.mly parserStart.mly parserStatements.mly parserOperators.mly parserExpressions.mly
all: clean main

$(MYBUILD)/javaParser.cmo: 
	cd $(MYBUILD); menhir $(PARSING)  -v --base javaParser
	cd $(MYBUILD); rm javaParser.mli
	cd $(MYBUILD); ocamlc -c javaParser.ml

$(MYBUILD)/javaLexer.cmo: $(MYBUILD)/javaLexer.mll
	cd $(MYBUILD); ocamllex javaLexer.mll
	cd $(MYBUILD); ocamlc -c javaLexer.ml

$(MYBUILD)/printing.cmo:
	cd $(MYBUILD); ocamlc -c printing.ml

$(MYBUILD)/ast.cmo:
	cd $(MYBUILD); ocamlc -c ast.ml


main: $(MYBUILD) $(MYBUILD)/ast.cmo $(MYBUILD)/printing.cmo $(MYBUILD)/javaParser.cmo $(MYBUILD)/javaLexer.cmo $(MYBUILD)/main.ml 
	cd $(MYBUILD); ocamlc -c main.ml
	cd $(MYBUILD); ocamlc -pp "#load"   ast.cmo  printing.cmo definitions.cmo expressions.cmo javaParser.cmo javaLexer.cmo main.cmo -o main; cp main ../

$(MYBUILD): 
	mkdir -p $(MYBUILD)
	cp $(COPYPATH)/* $(MYBUILD)/
	cp $(COPYPATH_EXPR)/* $(MYBUILD)/
	cp ./main.ml $(MYBUILD)/
	cp ../ast.ml $(MYBUILD)/
	cp ../printing.ml $(MYBUILD)/
	cp ../tokens.mly $(MYBUILD)/
	cp ../javaLexer.mll $(MYBUILD)/


clean:
	rm -rf $(MYBUILD)
	rm -rf main
