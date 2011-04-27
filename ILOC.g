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
   import java.util.HashSet;
}

generate[ArrayList<Block> blist, HashMap<String, StructType> structtable]
   @init
   {
      HashMap<String, Register> regtable = new HashMap<String, Register>();
   }
   :  ^(PROGRAM types declarations[regtable] functions[regtable,blist,structtable])
   ;

types
   :  ^(TYPES type_sub*)
   ;

declarations[HashMap<String, Register> regtable]
   :  ^(DECLS (declaration[regtable])*)
   ;

functions[HashMap<String, Register> regtable,ArrayList<Block> blist,HashMap<String, StructType> structtable]
   :  ^(FUNCS (rfun=function[regtable,structtable] {blist.add($rfun.rblock);})*)
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

function[HashMap<String, Register> regtable, HashMap<String, StructType> structtable] returns [Block rblock = new Block()]
   @init
   {
     HashMap<String, Register> regtable_copy = new HashMap<String, Register>(regtable);
     Block exit = new Block();
   }
   :  ^(FUN rid=ID{$rblock.name=$rid.text;exit.name = "exit-" + $rblock.name;} params[regtable_copy] ^(RETTYPE isVoid=return_type) localdeclarations[regtable_copy] finalblk=statement_list[regtable_copy, rblock, exit,structtable]
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

statement_list[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block rblock]
   :  ^(STMTS (finalblock=statement[regtable, b, exit, structtable]{b = $finalblock.rblock;})*){rblock = $finalblock.rblock;}
   ;
   
statement[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block rblock]
   :  returnblock=block[regtable, b, exit, structtable]{$rblock = $returnblock.rblock;}
   |  assignment[regtable, b, exit, structtable]{$rblock = b;}
   |  print[regtable, b, exit, structtable]{$rblock = b;}
   |  read[regtable, b, exit, structtable]{$rblock = b;}
   |  returnblock=conditional[regtable, b, exit, structtable]{$rblock = $returnblock.rblock;}
   |  returnblock=loop[regtable, b, exit, structtable]{$rblock = $returnblock.rblock;}
   |  delete[regtable, b, exit, structtable]{$rblock = b;}
   |  returnblock=ret[regtable, b, exit, structtable]{$rblock = $returnblock.rblock;}
   |  expression[regtable, b, exit, structtable]{$rblock = b;}
   ;
   
block[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block rblock]
   :  ^(BLOCK finalblock=statement_list[regtable, b, exit, structtable]{rblock = $finalblock.rblock;})
   ;
   
assignment[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  ^(ASSIGN rv=expression[regtable, b, exit, structtable] lv=lvalue[regtable, b, exit, structtable])
        {
           if(lv.offset == null){
             b.instructions.add(new MoveInstruction($rv.r, $lv.r));
           }
           else{
             b.instructions.add(new AddressInstruction("storeai", $rv.r, $lv.r, $lv.offset));
           }
        }
   ;
   
print[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  ^(PRINT reg=expression[regtable, b, exit, structtable] (println = ENDL)?)
      {
        if(println == null){
          b.instructions.add(new UnaryInstruction("print", $reg.r));
        }
        else{
          b.instructions.add(new UnaryInstruction("println", $reg.r));
        }
      }
   ;
   
read[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  ^(READ lvalue[regtable, b, exit, structtable])
      {
        b.instructions.add(new UnaryInstruction("read", new Register()));
      }
   ;
   
conditional[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block thenblock = new Block();
      Block elseblock = new Block();
   }
   :  ^(IF reg=expression[regtable, b, exit, structtable]{thenblock.name = "L" + c + "_(if-then)";} thenLast = block[regtable, thenblock, exit, structtable] {elseblock.name = "L" + c + "_(if-else)";}(elseLast = block[regtable, elseblock, exit, structtable])?)
       {
          Register condition = new Register();
          b.instructions.add(new LoadInstruction("loadi", "1", condition));
          b.instructions.add(new ComparisonInstruction("comp", condition, $reg.r));
          continueblock.name = "L" + c + "_(cont)";
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
   
loop[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block expblock = new Block();
      expblock.name = "L" + c + "_(while-exp)";
      Block execblock = new Block();
      execblock.name = "L" + c + "_(while-exec)";
      continueblock.name = "L" + c + "_(while-cont)";
   }
   :  ^(WHILE exp=expression[regtable, expblock, exit, structtable] lastexec=block[regtable, execblock, exit, structtable] expression[regtable, new Block(), exit, structtable])
       {
         Register condition = new Register();
         expblock.instructions.add(new LoadInstruction("loadi", "1", condition));
         expblock.instructions.add(new ComparisonInstruction("comp", condition, $exp.r));
         expblock.instructions.add(new BranchInstruction("cbreq", execblock.name, continueblock.name));
         b.successors.add(expblock);
         expblock.successors.add(execblock);
         expblock.successors.add(continueblock);
         $lastexec.rblock.successors.add(expblock);
         $lastexec.rblock.instructions.add(new JumpInstruction(expblock.name));
       }
   ;
 
delete[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  ^(DELETE reg=expression[regtable, b, exit, structtable]
         {
           b.instructions.add(new UnaryInstruction("del", $reg.r));
         }
       )
   ;
   
ret[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Block rblock]
   : ^(RETURN (expression[regtable, b, exit, structtable])?){b.successors.add(exit); b.instructions.add(new JumpInstruction(exit.name));$rblock = exit;}
   ;
   
lvalue[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Register r, String offset = null]
   :  rid=id{$r = $regtable.get($rid.rstring);}
   | ^(DOT lv=lvalue_h[regtable, b, new Register(), structtable] rid=id)
      {
        $r = $lv.r;
        $offset = "@" + $rid.rstring;
      }
   ;

lvalue_h[HashMap<String, Register> regtable, Block b, Register in, HashMap<String, StructType> structtable] returns [Register r, String offset = null]
   :  rid=id{$r = in; $offset = $rid.rstring;}
   | ^(DOT lv=lvalue_h[regtable, b, in, structtable] rid=id)
      {
        $r = $lv.r;
        $offset = "@" + $rid.rstring;
      }
   ;

expression[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable] returns [Register r = new Register()]
   : ^(AND lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("and", $lv.r, $rv.r, r));})
   | ^(OR lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("or", $lv.r, $rv.r, r));})
   | ^(EQ lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("moveq", "1", r));
        }
      )
   | ^(LT lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movlt", "1", r));
        }
      )
   | ^(GT lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] 
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movgt", "1", r));
        }
      )
   | ^(NE lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movne", "1", r));
        }
      )
   | ^(LE lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] 
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movle", "1", r));
        }
      )
   | ^(GE lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movge", "1", r));
        }
      )
   | ^(PLUS lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("add", $lv.r, $rv.r, r));})
   | ^(MINUS lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("sub", $lv.r, $rv.r, r));})
   | ^(TIMES lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable]  {b.instructions.add(new ArithmeticInstruction("mult", $lv.r, $rv.r, r));})
   | ^(DIVIDE lv=expression[regtable, b, exit, structtable] rv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("div", $lv.r, $rv.r, r));})
   | ^(NOT uv=expression[regtable, b, exit, structtable] {b.instructions.add(new ArithmeticInstruction("xori", $uv.r, new Register(), r));/*xori r, true, dest*/})
   | ^(NEG uv=expression[regtable, b, exit, structtable]  {b.instructions.add(new ArithmeticInstruction("mult", $uv.r, new Register(), r));/*multi r, -1, dest*/})
   | ^(DOT expression[regtable, b, exit, structtable] id)
   |  rid=id {r = regtable.get($rid.rstring);}
   |  tnode=INTEGER{b.instructions.add(new LoadInstruction("loadi", $tnode.text, r));}
   |  TRUE{b.instructions.add(new LoadInstruction("loadi", "1", r));}
   |  FALSE{b.instructions.add(new LoadInstruction("loadi", "0", r));}
   |  ^(NEW rid=id)
       {
         HashSet<String> temp = new HashSet<String>(structtable.get($rid.rstring).types.keySet());
         b.instructions.add(new NewInstruction($rid.rstring, temp, r));
       }
   |  NULL{/*?*/}
   |  ^(INVOKE id arguments[regtable, b, exit, structtable])
   ;
   
arguments[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  arg_list[regtable, b, exit, structtable]
   ;
   
arg_list[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable]
   :  ARGS
   |  ^(ARGS expression[regtable, b, exit, structtable]+)
   ;
