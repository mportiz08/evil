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
   import java.util.ArrayList;
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
   :  ^(FUNCS{ArrayList<Block> blist = new ArrayList<Block>();Integer c = new Integer(0);} (rfun=function[c]{blist.add($rfun.rblock);})*)
       {
          for(Block b : blist){
            System.out.println(b);
          }
       }
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

function[Integer c] returns [Block rblock = new Block()]
   :  ^(FUN rid=ID{$rblock.name=$rid.text;} params ^(RETTYPE return_type) localdeclarations statement_list[rblock, c])
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

statement_list[Block b, Integer c]
   :  ^(STMTS statement[b, c]*)
   ;
   
statement[Block b, Integer c]
   :  block[b, c]
   |  assignment[b, c]
   |  print[b, c]
   |  read[b, c]
   |  conditional[b, c]
   |  loop[b, c]
   |  delete[b, c]
   |  ret[b, c]
   |  expression[b, c]
   ;
   
block[Block b, Integer c]
   :  ^(BLOCK statement_list[b, c])
   ;
   
assignment[Block b, Integer c]
   :  ^(ASSIGN expression[b, c] lvalue[b, c])
   ;
   
print[Block b, Integer c]
   :  ^(PRINT expression[b, c] (ENDL)?)
   ;
   
read[Block b, Integer c]
   :  ^(READ lvalue[b, c])
   ;
   
conditional[Block b, Integer c]
   :  ^(IF expression[b, c] block[b, c] (block[b, c])?)
   ;
   
loop[Block b, Integer c]
   :  ^(WHILE expression[b, c] block[b, c] expression[b, c])
   ;
 
delete[Block b, Integer c]
   :  ^(DELETE expression[b, c])
   ;
   
ret[Block b, Integer c]
   : ^(RETURN (expression[b, c])?)
   ;
   
lvalue[Block b, Integer c]
   :  id
   | ^(DOT lvalue[b, c] id)
   ;
   
expression[Block b, Integer c]
   : ^(AND expression[b, c] expression[b, c])
   | ^(OR expression[b, c] expression[b, c])
   | ^(EQ expression[b, c] expression[b, c])
   | ^(LT expression[b, c] expression[b, c])
   | ^(GT expression[b, c] expression[b, c])
   | ^(NE expression[b, c] expression[b, c])
   | ^(LE expression[b, c] expression[b, c])
   | ^(GE expression[b, c] expression[b, c])
   | ^(PLUS expression[b, c] expression[b, c])
   | ^(MINUS expression[b, c] expression[b, c])
   | ^(TIMES expression[b, c] expression[b, c])
   | ^(DIVIDE expression[b, c] expression[b, c])
   | ^(NOT expression[b, c])
   | ^(NEG expression[b, c])
   | ^(DOT expression[b, c] id)
   |  id 
   |  INTEGER
   |  TRUE
   |  FALSE
   |  ^(NEW id)
   |  NULL
   |  ^(INVOKE id arguments[b, c])
   ;
   
arguments[Block b, Integer c]
   :  arg_list[b, c]
   ;
   
arg_list[Block b, Integer c]
   :  ARGS
   |  ^(ARGS expression[b, c]+)
   ;
