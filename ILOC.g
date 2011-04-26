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
   :  ^(DECLS (declaration[regtable])*)
   ;

functions[HashMap<String, Register> regtable]
   :  ^(FUNCS{ArrayList<Block> blist = new ArrayList<Block>();} (rfun=function[regtable] {blist.add($rfun.rblock);})*)
       {
          for(Block b : blist){
            //b.printTree();
            b.printInstructions();
            System.out.println();
          }
       }
   ;

type_sub
   :  ^(STRUCT id nested_decl)
   ;

decl[HashMap<String, Register> regtable]
   :  ^(DECL ^(TYPE type) rid=id
         { $regtable.put($rid.rstring, new Register($rid.rstring)); }
       )
   ;

nested_decl
   :  (decl[new HashMap<String, Register>()])+
   ;
   
declaration[HashMap<String, Register> regtable]
   :  ^(DECLLIST ^(TYPE type) id_list[regtable])
   ;
   
id_list[HashMap<String, Register> regtable]
   : (rid=id
      {
         Register temp = new Register($rid.rstring);
         temp.global = true;
         $regtable.put($rid.rstring, temp);
      }
   )+
   ;

type
   :  INT
   |  BOOL
   |  ^(STRUCT id)
   ;

id returns [String rstring = null]
   : ^(tnode=ID {$rstring = $tnode.text;})
   ;

function[HashMap<String, Register> regtable] returns [Block rblock = new Block()]
   @init
   {
     HashMap<String, Register> regtable_copy = new HashMap<String, Register>(regtable);
     Block exit = new Block();
   }
   :  ^(FUN rid=ID{$rblock.name=$rid.text;exit.name = "exit-" + $rblock.name;} params[regtable_copy] ^(RETTYPE isVoid=return_type) localdeclarations[regtable_copy] finalblk=statement_list[regtable_copy, rblock, exit]
         { 
           if($finalblk.rblock != null && $isVoid.isVoid)
           {
             $finalblk.rblock.successors.add(exit);
           }
           else if($isVoid.isVoid)
           {
             rblock.successors.add(exit);
           }
         }
       )
   ;

localdeclarations[HashMap<String, Register> regtable_copy]
   :  ^(DECLS (localdeclaration[regtable_copy])*)
   ;

localdeclaration[HashMap<String, Register> regtable]
   :  ^(DECLLIST ^(TYPE type) localid_list[regtable])
   ;
   
localid_list[HashMap<String, Register> regtable]
   : (rid=id
      { $regtable.put($rid.rstring, new Register($rid.rstring)); }
     )+
   ;

params[HashMap<String, Register> regtable]
   :  ^(PARAMS (decl[regtable])*)
   ;

return_type returns [boolean isVoid = false]
   :  type
   |  VOID{isVoid = true;}
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
   :  ^(IF reg=expression[regtable, b, exit]{thenblock.name = "L" + c + " (if-then)";} thenLast = block[regtable, thenblock, exit] {elseblock.name = "L" + c + " (if-else)";}(elseLast = block[regtable, elseblock, exit])?)
       {
          Register condition = new Register();
          b.instructions.add(new LoadInstruction("loadi", "1", condition));
          b.instructions.add(new ComparisonInstruction("comp", condition, $reg.r));
          continueblock.name = "L" + c + " (cont)";
          b.successors.add(thenblock);
          if(elseLast == null){
             b.successors.add(continueblock);
             b.instructions.add(new BranchInstruction("cbreq", thenblock.name, continueblock.name));
          }
          else{
             b.successors.add(elseblock);
             if(!$thenLast.rblock.name.equals("exit")){
               $elseLast.rblock.successors.add(continueblock);
               $elseLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
               b.instructions.add(new BranchInstruction("cbreq", thenblock.name, elseblock.name));
             }
          }
          
          if(!$thenLast.rblock.name.equals("exit")){
            $thenLast.rblock.successors.add(continueblock);
            $thenLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
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
   : ^(RETURN (expression[regtable, b, exit])?){b.successors.add(exit); b.instructions.add(new JumpInstruction(exit.name));$rblock = exit;}
   ;
   
lvalue[HashMap<String, Register> regtable, Block b, Block exit]
   :  id
   | ^(DOT lvalue[regtable, b, exit] id)
   ;
   
expression[HashMap<String, Register> regtable, Block b, Block exit] returns [Register r = new Register()]
   : ^(AND lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("and", $lv.r, $rv.r, r));})
   | ^(OR lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("or", $lv.r, $rv.r, r));})
   | ^(EQ lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("moveq", $lv.r, $rv.r, r));})
   | ^(LT lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movlt", $lv.r, $rv.r, r));})
   | ^(GT lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movgt", $lv.r, $rv.r, r));})
   | ^(NE lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movne", $lv.r, $rv.r, r));})
   | ^(LE lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movle", $lv.r, $rv.r, r));})
   | ^(GE lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("movge", $lv.r, $rv.r, r));})
   | ^(PLUS lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("add", $lv.r, $rv.r, r));})
   | ^(MINUS lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("sub", $lv.r, $rv.r, r));})
   | ^(TIMES lv=expression[regtable, b, exit] rv=expression[regtable, b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", $lv.r, $rv.r, r));})
   | ^(DIVIDE lv=expression[regtable, b, exit] rv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("div", $lv.r, $rv.r, r));})
   | ^(NOT uv=expression[regtable, b, exit] {b.instructions.add(new ArithmeticInstruction("xori", $uv.r, new Register(), r));/*xori r, true, dest*/})
   | ^(NEG uv=expression[regtable, b, exit]  {b.instructions.add(new ArithmeticInstruction("mult", $uv.r, new Register(), r));/*multi r, -1, dest*/})
   | ^(DOT expression[regtable, b, exit] id)
   |  rid=id {r = regtable.get($rid.rstring);}
   |  tnode=INTEGER{b.instructions.add(new LoadInstruction("loadi", $tnode.text, r));}
   |  TRUE{b.instructions.add(new LoadInstruction("loadi", "1", r));}
   |  FALSE{b.instructions.add(new LoadInstruction("loadi", "0", r));}
   |  ^(NEW id){/*?*/}
   |  NULL{/*?*/}
   |  ^(INVOKE id arguments[regtable, b, exit])
   ;
   
arguments[HashMap<String, Register> regtable, Block b, Block exit]
   :  arg_list[regtable, b, exit]
   ;
   
arg_list[HashMap<String, Register> regtable, Block b, Block exit]
   :  ARGS
   |  ^(ARGS expression[regtable, b, exit]+)
   ;
