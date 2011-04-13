tree grammar ILOC;

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
   import java.util.LinkedHashMap;
}

generate
   :  ^(PROGRAM types declarations functions)
   ;

types
   :  ^(TYPES type_sub*)
   ;

declarations
   :  ^(DECLS declaration*)
   ;

functions
   :  ^(FUNCS function*)
   ;

type_sub
   :  ^(STRUCT id nested_decl)
   ;

decl
   :  ^(DECL ^(TYPE type) id)
   ;

nested_decl
   :  decl+
   ;
   
declaration
   :  ^(DECLLIST ^(TYPE type) id_list)
   ;
   
id_list
   : id+
   ;

type
   :  INT
   |  BOOL
   |  ^(STRUCT id)
   ;

id
   : ID
   ;

function
   :  ^(FUN id params ^(RETTYPE return_type) localdeclarations statement_list)
   ;

localdeclarations
   :  ^(DECLS localdeclaration*)
   ;

localdeclaration
   :  ^(DECLLIST ^(TYPE type) localid_list)
   ;
   
localid_list
   : id+
   ;

params
   :  ^(PARAMS decl*)
   ;

return_type
   :  type
   |  VOID
   ;

statement_list
   :  ^(STMTS statement*)
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
   |  expression
   ;
   
block
   :  ^(BLOCK statement_list)
   ;
   
assignment
   :  ^(ASSIGN expression lvalue)
   ;
   
print
   :  ^(PRINT expression (ENDL)?)
   ;
   
read
   :  ^(READ lvalue)
   ;
   
conditional
   :  ^(IF expression block (block)?)
   ;
   
loop
   :  ^(WHILE expression block expression)
   ;
 
delete
   :  ^(DELETE expression)
   ;
   
ret
   : ^(RETURN (expression)?)
   ;
   
lvalue
   :  id
   | ^(DOT lvalue id)
   ;
   
expression
   : ^(AND expression expression)
   | ^(OR expression expression)
   | ^(EQ expression expression)
   | ^(LT expression expression)
   | ^(GT expression expression)
   | ^(NE expression expression)
   | ^(LE expression expression)
   | ^(GE expression expression)
   | ^(PLUS expression expression)
   | ^(MINUS expression expression)
   | ^(TIMES expression expression)
   | ^(DIVIDE expression expression)
   | ^(NOT expression)
   | ^(NEG expression)
   | ^(DOT expression id)
   |  id 
   |  INTEGER
   |  TRUE
   |  FALSE
   |  ^(NEW id)
   |  NULL
   |  ^(INVOKE id arguments)
   ;
   
arguments
   :  arg_list
   ;
   
arg_list
   :  ARGS
   |  ^(ARGS expression+)
   ;
