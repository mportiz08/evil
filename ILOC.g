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
   :  ^(FUNCS{ArrayList<Block> blist = new ArrayList<Block>();} (rfun=function {blist.add($rfun.rblock);})*)
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

function returns [Block rblock = new Block()]
   :  ^(FUN rid=ID{$rblock.name=$rid.text;} params ^(RETTYPE return_type) localdeclarations statement_list[rblock, new Block()])
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

statement_list[Block b, Block exit] returns [Block rblock]
   :  ^(STMTS (finalblock=statement[b, exit]{b = $finalblock.rblock;})*){rblock = $finalblock.rblock;}
   ;
   
statement[Block b, Block exit] returns [Block rblock]
   :  returnblock=block[b, exit]{$rblock = $returnblock.rblock;}
   |  assignment[b, exit]{$rblock = b;}
   |  print[b, exit]{$rblock = b;}
   |  read[b, exit]{$rblock = b;}
   |  returnblock=conditional[b, exit]{$rblock = $returnblock.rblock;}
   |  returnblock=loop[b, exit]{$rblock = $returnblock.rblock;}
   |  delete[b, exit]{$rblock = b;}
   |  returnblock=ret[b, exit]{$rblock = $returnblock.rblock;}
   |  expression[b, exit]{$rblock = b;}
   ;
   
block[Block b, Block exit] returns [Block rblock]
   :  ^(BLOCK finalblock=statement_list[b, exit]{rblock = $finalblock.rblock;})
   ;
   
assignment[Block b, Block exit]
   :  ^(ASSIGN expression[b, exit] lvalue[b, exit])
   ;
   
print[Block b, Block exit]
   :  ^(PRINT expression[b, exit] (println = ENDL)?)
      {
        if(println == null){
          b.instructions.add(new IOInstruction("print", new Register()));
        }
        else{
          b.instructions.add(new IOInstruction("println", new Register()));
        }
      }
   ;
   
read[Block b, Block exit]
   :  ^(READ lvalue[b, exit])
      {
        b.instructions.add(new IOInstruction("read", new Register()));
      }
   ;
   
conditional[Block b, Block exit] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block thenblock = new Block();
      Block elseblock = new Block();
   }
   :  ^(IF expression[b, exit]{thenblock.name = "L" + c + " (if-then)";} thenLast = block[thenblock, exit] {elseblock.name = "L" + c + " (if-else)";}(elseLast = block[elseblock, exit])?)
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
   
loop[Block b, Block exit] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block expblock = new Block();
      expblock.name = "L" + c + " (while-exp)";
      Block execblock = new Block();
      execblock.name = "L" + c + " (while-exec)";
      continueblock.name = "L" + c + " (while-cont)";
   }
   :  ^(WHILE expression[expblock, exit] lastexec=block[execblock, exit] expression[new Block(), exit])
       {
         b.successors.add(expblock);
         expblock.successors.add(execblock);
         expblock.successors.add(continueblock);
         $lastexec.rblock.successors.add(expblock);
       }
   ;
 
delete[Block b, Block exit]
   :  ^(DELETE expression[b, exit])
   ;
   
ret[Block b, Block exit] returns [Block rblock]
   : ^(RETURN (expression[b, exit])?){b.successors.add(exit); $rblock = exit;}
   ;
   
lvalue[Block b, Block exit]
   :  id
   | ^(DOT lvalue[b, exit] id)
   ;
   
expression[Block b, Block exit]
   : ^(AND expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("and", new Register(), new Register(), new Register()));})
   | ^(OR expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("or", new Register(), new Register(), new Register()));})
   | ^(EQ expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("moveq", new Register(), new Register(), new Register()));})
   | ^(LT expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("movlt", new Register(), new Register(), new Register()));})
   | ^(GT expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("movgt", new Register(), new Register(), new Register()));})
   | ^(NE expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("movne", new Register(), new Register(), new Register()));})
   | ^(LE expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("movle", new Register(), new Register(), new Register()));})
   | ^(GE expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("movge", new Register(), new Register(), new Register()));})
   | ^(PLUS expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("add", new Register(), new Register(), new Register()));})
   | ^(MINUS expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("sub", new Register(), new Register(), new Register()));})
   | ^(TIMES expression[b, exit] expression[b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", new Register(), new Register(), new Register()));})
   | ^(DIVIDE expression[b, exit] expression[b, exit] {b.instructions.add(new ArithmeticInstruction("div", new Register(), new Register(), new Register()));})
   | ^(NOT expression[b, exit] {b.instructions.add(new ArithmeticInstruction("xori", new Register(), new Register(), new Register()));/*xori r1, true, dest*/})
   | ^(NEG expression[b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", new Register(), new Register(), new Register()));/*multi r1, -1, dest*/})
   | ^(DOT expression[b, exit] id)
   |  id 
   |  INTEGER
   |  TRUE
   |  FALSE
   |  ^(NEW id)
   |  NULL
   |  ^(INVOKE id arguments[b, exit])
   ;
   
arguments[Block b, Block exit]
   :  arg_list[b, exit]
   ;
   
arg_list[Block b, Block exit]
   :  ARGS
   |  ^(ARGS expression[b, exit]+)
   ;
