tree grammar TypeCheck;

options
{
   tokenVocab=Evil;
   ASTLabelType=CommonTree;
}

@header
{
   import java.util.Map;
   import java.util.HashMap;
   import java.util.Vector;
   import java.util.Iterator;
}

verify
   :  ^(PROGRAM types declarations functions)
   ;

types
   :  ^(TYPES {System.out.println("types");} type_sub*)
   ;

declarations
   :  ^(DECLS {System.out.println("decls");} declaration*)
   ;

functions
   :  ^(FUNCS {System.out.println("funcs");} function*)
   ;

type_sub
   :  ^(STRUCT {System.out.println("struct");} id nested_decl)
   ;

decl
   :  ^(DECL {System.out.println("decl");} ^(TYPE {System.out.println("type");} type) id)
   ;

nested_decl
   :  decl+
   ;
   
declaration
   :  ^(DECLLIST {System.out.println("decllist");} ^(TYPE {System.out.println("type");} type) id_list)
   ;
   
id_list
   : id+
   ;

type
   :  INT {System.out.println("int");}
   |  BOOL {System.out.println("bool");}
   |  ^(STRUCT {System.out.println("struct");} id)
   ;

id
   : ^(ID {System.out.println("id");})
   ;

function
   :  ^(FUN {System.out.println("fun");} id params ^(RETTYPE {System.out.println("rettype");} return_type) declarations statement_list)
   ;
   
params
   :  ^(PARAMS {System.out.println("params");} decl*)
   ;

return_type
   :  type
   |  VOID {System.out.println("void return");}
   ;

statement_list
   :  ^(STMTS {System.out.println("stmts");} statement*)
   ;
   
statement
   :  block
   |  assignment
   |  print
   |  read
   |  conditional
   |  loop
   |  delete
   |  ret
   |  invocation
   ;
   
block
   :  ^(BLOCK {System.out.println("block");} statement_list)
   ;
   
assignment
   :  ^(ASSIGN {System.out.println("assign");} expression lvalue)
   ;
   
print
   :  ^(PRINT {System.out.println("print");} expression (ENDL {System.out.println("endl");})?)
   ;
   
read
   :  ^(READ {System.out.println("read");} lvalue)
   ;
   
conditional
   :  ^(IF {System.out.println("if");} expression block (block)?)
   ;
   
loop
   :  ^(WHILE {System.out.println("while");} expression block expression)
   ;
 
delete
   :  ^(DELETE {System.out.println("delete");} expression)
   ;
   
ret
   : ^(RETURN {System.out.println("ret");} (expression)?)
   ;
   
invocation
   :  ^(INVOKE {System.out.println("invoke");} id arguments)
   ;
   
lvalue
   :  id
   | ^(DOT {System.out.println("lvalue dot");} lvalue id)
   ;
   
expression
   : ^(AND {System.out.println("random expression");} expression expression)
   | ^(OR {System.out.println("random expression");} expression expression)
   | ^(EQ {System.out.println("random expression");} expression expression)
   | ^(LT {System.out.println("random expression");} expression expression)
   | ^(GT {System.out.println("random expression");} expression expression)
   | ^(NE {System.out.println("random expression");} expression expression)
   | ^(LE {System.out.println("random expression");} expression expression)
   | ^(GE {System.out.println("random expression");} expression expression)
   | ^(PLUS {System.out.println("random expression");} expression expression)
   | ^(MINUS {System.out.println("random expression");} expression expression)
   | ^(TIMES {System.out.println("random expression");} expression expression)
   | ^(DIVIDE {System.out.println("random expression");} expression expression)
   | ^(NOT {System.out.println("random expression");} expression)
   | ^(NEG {System.out.println("random expression");} expression)
   | ^(DOT {System.out.println("random expression");} expression expression)
   | ^(INVOKE {System.out.println("random expression");} id arguments)
   |  ID {System.out.println("random expression");}
   |  INTEGER {System.out.println("random expression");}
   |  TRUE {System.out.println("random expression");}
   |  FALSE {System.out.println("random expression");}
   |  ^(NEW {System.out.println("random expression");} id)
   |  NULL {System.out.println("random expression");}
   ;
   
arguments
   :  arg_list
   ;
   
arg_list
   :  ARGS
   |  ^(ARGS {System.out.println("args");} expression+)
   ;
