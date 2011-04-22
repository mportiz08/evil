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
   @init
   {
      HashMap<String, Register> regtable = new HashMap<String, Register>();
   }
   :  ^(PROGRAM types declarations[regtable] functions[regtable])
   ;

types
   :  ^(TYPES type_sub*)
   ;

declarations[HashMap<String, Register> regtable]
   :  ^(DECLS declaration*)
   ;

functions[HashMap<String, Register> regtable]
   :  ^(FUNCS{ArrayList<Block> blist = new ArrayList<Block>();} (rfun=function[regtable] {blist.add($rfun.rblock);})*)
       {
          for(Block b : blist){
            b.printTree();
          }
       }
   ;

type_sub
   :  ^(STRUCT id nested_decl)
   ;

decl[HashMap<String, Register> regtable]
   :  ^(DECL ^(TYPE type) id)
   ;

nested_decl
   :  (decl[new HashMap<String, Register>()])+
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

function[HashMap<String, Register> regtable] returns [Block rblock = new Block()]
   @init
   {
     HashMap<String, Register> regtable_copy = new HashMap<String, Register>(regtable);
   }
   :  ^(FUN rid=ID{$rblock.name=$rid.text;} params[regtable_copy] ^(RETTYPE return_type) localdeclarations[regtable_copy] statement_list[regtable_copy, rblock, new Block()])
   ;

localdeclarations[HashMap<String, Register> regtable_copy]
   :  ^(DECLS (localdeclaration[regtable_copy])*)
   ;

localdeclaration[HashMap<String, Register> regtable]
   :  ^(DECLLIST ^(TYPE type) localid_list[regtable])
   ;
   
localid_list[HashMap<String, Register> regtable]
   : id+
   ;

params[HashMap<String, Register> regtable]
   :  ^(PARAMS (decl[regtable])*)
   ;

return_type
   :  type
   |  VOID
   ;

statement_list[HashMap<String, Register> regtable, Block b, Block exit] returns [Block rblock]
   :  ^(STMTS (finalblock=statement[regtable, b, exit]{b = $finalblock.rblock;})*){rblock = $finalblock.rblock;}
   ;
   
statement[HashMap<String, Register> regtable, Block b, Block exit] returns [Block rblock]
   :  returnblock=block[regtable, b, exit]{$rblock = $returnblock.rblock;}
   |  assignment[regtable, b, exit]{$rblock = b;}
   |  print[regtable, b, exit]{$rblock = b;}
   |  read[regtable, b, exit]{$rblock = b;}
   |  returnblock=conditional[regtable, b, exit]{$rblock = $returnblock.rblock;}
   |  returnblock=loop[regtable, b, exit]{$rblock = $returnblock.rblock;}
   |  delete[regtable, b, exit]{$rblock = b;}
   |  returnblock=ret[regtable, b, exit]{$rblock = $returnblock.rblock;}
   |  expression[regtable, b, exit]{$rblock = b;}
   ;
   
block[HashMap<String, Register> regtable, Block b, Block exit] returns [Block rblock]
   :  ^(BLOCK finalblock=statement_list[regtable, b, exit]{rblock = $finalblock.rblock;})
   ;
   
assignment[HashMap<String, Register> regtable, Block b, Block exit]
   :  ^(ASSIGN expression[regtable, b, exit] lvalue[regtable, b, exit])
   ;
   
print[HashMap<String, Register> regtable, Block b, Block exit]
   :  ^(PRINT expression[regtable, b, exit] (println = ENDL)?)
      {
        if(println == null){
          b.instructions.add(new IOInstruction("print", new Register()));
        }
        else{
          b.instructions.add(new IOInstruction("println", new Register()));
        }
      }
   ;
   
read[HashMap<String, Register> regtable, Block b, Block exit]
   :  ^(READ lvalue[regtable, b, exit])
      {
        b.instructions.add(new IOInstruction("read", new Register()));
      }
   ;
   
conditional[HashMap<String, Register> regtable, Block b, Block exit] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block thenblock = new Block();
      Block elseblock = new Block();
   }
   :  ^(IF expression[regtable, b, exit]{thenblock.name = "L" + c + " (if-then)";} thenLast = block[regtable, thenblock, exit] {elseblock.name = "L" + c + " (if-else)";}(elseLast = block[regtable, elseblock, exit])?)
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
   
loop[HashMap<String, Register> regtable, Block b, Block exit] returns [Block continueblock = new Block()]
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
   :  ^(WHILE expression[regtable, expblock, exit] lastexec=block[regtable, execblock, exit] expression[regtable, new Block(), exit])
       {
         b.successors.add(expblock);
         expblock.successors.add(execblock);
         expblock.successors.add(continueblock);
         $lastexec.rblock.successors.add(expblock);
       }
   ;
 
delete[HashMap<String, Register> regtable, Block b, Block exit]
   :  ^(DELETE expression[regtable, b, exit])
   ;
   
ret[HashMap<String, Register> regtable, Block b, Block exit] returns [Block rblock]
   : ^(RETURN (expression[regtable, b, exit])?){b.successors.add(exit); $rblock = exit;}
   ;
   
lvalue[HashMap<String, Register> regtable, Block b, Block exit]
   :  id
   | ^(DOT lvalue[regtable, b, exit] id)
   ;
   
expression[HashMap<String, Register> regtable, Block b, Block exit]
   : ^(AND expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("and", new Register(), new Register(), new Register()));})
   | ^(OR expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("or", new Register(), new Register(), new Register()));})
   | ^(EQ expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("moveq", new Register(), new Register(), new Register()));})
   | ^(LT expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movlt", new Register(), new Register(), new Register()));})
   | ^(GT expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movgt", new Register(), new Register(), new Register()));})
   | ^(NE expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movne", new Register(), new Register(), new Register()));})
   | ^(LE expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movle", new Register(), new Register(), new Register()));})
   | ^(GE expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movge", new Register(), new Register(), new Register()));})
   | ^(PLUS expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("add", new Register(), new Register(), new Register()));})
   | ^(MINUS expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("sub", new Register(), new Register(), new Register()));})
   | ^(TIMES expression[regtable, b, exit] expression[regtable, b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", new Register(), new Register(), new Register()));})
   | ^(DIVIDE expression[regtable, b, exit] expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("div", new Register(), new Register(), new Register()));})
   | ^(NOT expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("xori", new Register(), new Register(), new Register()));/*xori r1, true, dest*/})
   | ^(NEG expression[regtable, b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", new Register(), new Register(), new Register()));/*multi r1, -1, dest*/})
   | ^(DOT expression[regtable, b, exit] id)
   |  id 
   |  INTEGER
   |  TRUE
   |  FALSE
   |  ^(NEW id)
   |  NULL
   |  ^(INVOKE id arguments[regtable, b, exit])
   ;
   
arguments[HashMap<String, Register> regtable, Block b, Block exit]
   :  arg_list[regtable, b, exit]
   ;
   
arg_list[HashMap<String, Register> regtable, Block b, Block exit]
   :  ARGS
   |  ^(ARGS expression[regtable, b, exit]+)
   ;
