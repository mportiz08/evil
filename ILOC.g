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
            b.printTree();
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
   :  ^(FUN rid=ID{$rblock.name=$rid.text;} params ^(RETTYPE return_type) localdeclarations statement_list[rblock, new Block(), c])
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

statement_list[Block b, Block exit, Integer c] returns [Block rblock]
   :  ^(STMTS (finalblock=statement[b, exit, c]{b = $finalblock.rblock;})*){rblock = $finalblock.rblock;}
   ;
   
statement[Block b, Block exit, Integer c] returns [Block rblock]
   :  returnblock=block[b, exit, c]{$rblock = $returnblock.rblock;}
   |  assignment[b, exit, c]{$rblock = b;}
   |  print[b, exit, c]{$rblock = b;}
   |  read[b, exit, c]{$rblock = b;}
   |  returnblock=conditional[b, exit, c]{$rblock = $returnblock.rblock;}
   |  returnblock=loop[b, exit, c]{$rblock = $returnblock.rblock;}
   |  delete[b, exit, c]{$rblock = b;}
   |  returnblock=ret[b, exit, c]{$rblock = $returnblock.rblock;}
   |  expression[b, exit, c]{$rblock = b;}
   ;
   
block[Block b, Block exit, Integer c] returns [Block rblock]
   :  ^(BLOCK finalblock=statement_list[b, exit, c]{rblock = $finalblock.rblock;})
   ;
   
assignment[Block b, Block exit, Integer c]
   :  ^(ASSIGN expression[b, exit, c] lvalue[b, exit, c])
   ;
   
print[Block b, Block exit, Integer c]
   :  ^(PRINT expression[b, exit, c] (ENDL)?)
   ;
   
read[Block b, Block exit, Integer c]
   :  ^(READ lvalue[b, exit, c])
   ;
   
conditional[Block b, Block exit, Integer c] returns [Block continueblock = new Block()]
   @init
   {
      Block thenblock = new Block();
      Block elseblock = new Block();
   }
   :  ^(IF expression[b, exit, c]{c++; thenblock.name = "L" + c + " (if-then)";} thenLast = block[thenblock, exit, c] {elseblock.name = "L" + c + " (if-else)";}(elseLast = block[elseblock, exit, c])?)
       {
          b.successors.add(thenblock);
          if(elseLast == null){
             b.successors.add(continueblock);
          }
          else{
             b.successors.add(elseblock);
             if(!$thenLast.rblock.name.equals("exit")){
               $elseLast.rblock.successors.add(continueblock);
             }
          }
          continueblock.name = "L" + c + " (cont)";
          if(!$thenLast.rblock.name.equals("exit")){
            $thenLast.rblock.successors.add(continueblock);
          }
       }
   ;
   
loop[Block b, Block exit, Integer c] returns [Block continueblock = new Block()]
   @init
   {
      Block expblock = new Block();
      expblock.name = "L" + c + " (while-exp)";
      Block execblock = new Block();
      execblock.name = "L" + c + " (while-exec)";
      continueblock.name = "L" + c + " (while-cont)";
   }
   :  ^(WHILE expression[b, exit, c] lastexec=block[b, exit, c] expression[b, exit, c])
       {
         b.successors.add(expblock);
         expblock.successors.add(execblock);
         expblock.successors.add(continueblock);
         $lastexec.rblock.successors.add(expblock);
       }
   ;
 
delete[Block b, Block exit, Integer c]
   :  ^(DELETE expression[b, exit, c])
   ;
   
ret[Block b, Block exit, Integer c] returns [Block rblock]
   : ^(RETURN (expression[b, exit, c])?){b.successors.add(exit); $rblock = exit;}
   ;
   
lvalue[Block b, Block exit, Integer c]
   :  id
   | ^(DOT lvalue[b, exit, c] id)
   ;
   
expression[Block b, Block exit, Integer c]
   : ^(AND expression[b, exit, c] expression[b, exit, c])
   | ^(OR expression[b, exit, c] expression[b, exit, c])
   | ^(EQ expression[b, exit, c] expression[b, exit, c])
   | ^(LT expression[b, exit, c] expression[b, exit, c])
   | ^(GT expression[b, exit, c] expression[b, exit, c])
   | ^(NE expression[b, exit, c] expression[b, exit, c])
   | ^(LE expression[b, exit, c] expression[b, exit, c])
   | ^(GE expression[b, exit, c] expression[b, exit, c])
   | ^(PLUS expression[b, exit, c] expression[b, exit, c])
   | ^(MINUS expression[b, exit, c] expression[b, exit, c])
   | ^(TIMES expression[b, exit, c] expression[b, exit, c])
   | ^(DIVIDE expression[b, exit, c] expression[b, exit, c])
   | ^(NOT expression[b, exit, c])
   | ^(NEG expression[b, exit, c])
   | ^(DOT expression[b, exit, c] id)
   |  id 
   |  INTEGER
   |  TRUE
   |  FALSE
   |  ^(NEW id)
   |  NULL
   |  ^(INVOKE id arguments[b, exit, c])
   ;
   
arguments[Block b, Block exit, Integer c]
   :  arg_list[b, exit, c]
   ;
   
arg_list[Block b, Block exit, Integer c]
   :  ARGS
   |  ^(ARGS expression[b, exit, c]+)
   ;
