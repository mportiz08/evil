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

verify returns [String rtype = null]
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

function returns [String name  = null]
   :  ^(FUN {System.out.println("fun");} id params ^(RETTYPE {System.out.println("rettype");} return_type) declarations statement_list)
   ;
   
params returns [String rtype = null]
   :  ^(PARAMS {System.out.println("params");} decl*)
   ;

return_type returns [String rtype = null]
   :  type
   |  VOID {System.out.println("void rtype");}
   ;

statement_list returns [String rtype = null]
   :  ^(STMTS {System.out.println("stmts");} statement*)
   ;
   
statement returns [String rtype = null]
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
   
block returns [String rtype = null]
   :  ^(BLOCK {System.out.println("block");} statement_list)
   ;
   
assignment returns [String rtype = null]
   :  ^(ASSIGN {System.out.println("assign");} expression lvalue)
   ;
   
print returns [String rtype = null]
   :  ^(PRINT {System.out.println("print");} expression (ENDL {System.out.println("endl");})?)
   ;
   
read returns [String rtype = null]
   :  ^(READ {System.out.println("read");} lvalue)
   ;
   
conditional returns [String rtype = null]
   :  ^(IF {System.out.println("if");} expression block (block)?)
   ;
   
loop returns [String rtype = null]
   :  ^(WHILE {System.out.println("while");} expression block expression)
   ;
 
delete returns [String rtype = null]
   :  ^(DELETE {System.out.println("delete");} expression)
   ;
   
ret returns [String rtype = null]
   : ^(RETURN {System.out.println("ret");} (expression)?)
   ;
   
invocation returns [String rtype = null]
   :  ^(INVOKE {System.out.println("invoke");} id arguments)
   ;
   
lvalue returns [String rtype = null]
   :  id
   | ^(DOT {System.out.println("lvalue dot");} lvalue id)
   ;
   
expression returns [String rtype = null]
   : ^(AND {System.out.println("random expression");} expression expression){/*l.equals(r);*/}
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
   
arguments returns [String rtype = null]
   :  arg_list
   ;
   
arg_list returns [String rtype = null]
   :  ARGS
   |  ^(ARGS {System.out.println("args");} expression+)
   ;
