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

generate[ArrayList<FuncBlock> blist, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   @init
   {
      HashMap<String, Register> regtable = new HashMap<String, Register>();
   }
   :  ^(PROGRAM types declarations[regtable] functions[regtable,blist,structtable, vartable])
   ;

types
   :  ^(TYPES type_sub*)
   ;

declarations[HashMap<String, Register> regtable]
   :  ^(DECLS (declaration[regtable])*)
   ;

functions[HashMap<String, Register> regtable,ArrayList<FuncBlock> blist,HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(FUNCS (rfun=function[regtable,structtable, vartable] {blist.add($rfun.rblock);})*)
   ;

type_sub
   :  ^(STRUCT id nested_decl)
   ;

decl[HashMap<String, Register> regtable, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [String rstring = new String()]
   :  ^(DECL ^(TYPE rtype=type[structtable]) rid=id
         { 
           $vartable.put($rid.rstring, $rtype.rtype);
           $regtable.put($rid.rstring, new Register($rid.rstring));
           $rstring = $rid.rstring;
         }
       )
   ;

nested_decl
   :  (decl[new HashMap<String, Register>(), new HashMap<String, StructType>(), new HashMap<String, Type>()])+
   ;
   
declaration[HashMap<String, Register> regtable]
   :  ^(DECLLIST ^(TYPE type[new HashMap<String, StructType>()]) id_list[regtable])
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

type[HashMap<String, StructType> structtable] returns [Type rtype = null]
   :  INT {rtype = new IntType();}
   |  BOOL {rtype = new BoolType();}
   |  ^(STRUCT rid=id) {rtype = structtable.get($rid.rstring);}
   ;

id returns [String rstring = null]
   : ^(tnode=ID {$rstring = $tnode.text;})
   ;

function[HashMap<String, Register> regtable, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [FuncBlock rblock = new FuncBlock()]
   @init
   {
     HashMap<String, Register> regtable_copy = new HashMap<String, Register>(regtable);
     Block exit = new Block();
     HashMap<String, Type> vartablecopy = new HashMap<String, Type>(vartable);
     rblock.exit = exit;
   }
   :  ^(FUN rid=ID{$rblock.name=$rid.text;exit.name = "exit" + $rblock.name;} params[regtable_copy, rblock, structtable, vartablecopy] ^(RETTYPE isVoid=return_type) localdeclarations[regtable_copy, rblock, structtable, vartablecopy] finalblk=statement_list[regtable_copy, rblock, exit,structtable, vartablecopy]
         { 
           if($finalblk.rblock != null && $isVoid.isVoid)
           {
             $finalblk.rblock.instructions.add(new RetInstruction());
             $finalblk.rblock.successors.add(exit);
             exit.predecessors.add($finalblk.rblock);
           }
           else if($isVoid.isVoid)
           {
             rblock.instructions.add(new RetInstruction());
             rblock.successors.add(exit);
             exit.predecessors.add(rblock);
           }
         }
       )
   ;

localdeclarations[HashMap<String, Register> regtable_copy, FuncBlock rblock, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(DECLS (localdeclaration[regtable_copy, rblock, structtable, vartable])*)
   ;

localdeclaration[HashMap<String, Register> regtable, FuncBlock rblock, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(DECLLIST ^(TYPE rtype=type[structtable]) localid_list[regtable, rblock, vartable, $rtype.rtype])
   ;
   
localid_list[HashMap<String, Register> regtable, FuncBlock rblock, HashMap<String, Type> vartable, Type type1]
   : (rid=id
      { 
        $vartable.put($rid.rstring, $type1);
        $regtable.put($rid.rstring, new Register($rid.rstring));
        $rblock.locals.add($rid.rstring);
      }
     )+
   ;

params[HashMap<String, Register> regtable, FuncBlock rblock, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   @init
   {
     ArrayList<Register> reglist = new ArrayList<Register>();
   }
   :  ^(PARAMS (rdecl = decl[regtable, structtable, vartable]
        {
          reglist.add($regtable.get($rdecl.rstring));
          $rblock.locals.add($rdecl.rstring);
        })*)
        {
          for(int i = 0; i < reglist.size(); i++){
             //$reglist.get(i).name = "\%i" + i;
             reglist.get(i).sparcName = "\%i" + i;
             //System.out.println("creating a new input");
           }
        }
   ;

return_type returns [boolean isVoid = false]
   :  type[new HashMap<String, StructType>()]
   |  VOID{isVoid = true;}
   ;

statement_list[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block rblock]
   :  ^(STMTS (finalblock=statement[regtable, b, exit, structtable, vartable]{b = $finalblock.rblock;})*){rblock = $finalblock.rblock;}
   ;
   
statement[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block rblock]
   :  returnblock=block[regtable, b, exit, structtable, vartable]{$rblock = $returnblock.rblock;}
   |  assignment[regtable, b, exit, structtable, vartable]{$rblock = b;}
   |  print[regtable, b, exit, structtable, vartable]{$rblock = b;}
   |  read[regtable, b, exit, structtable, vartable]{$rblock = b;}
   |  returnblock=conditional[regtable, b, exit, structtable, vartable]{$rblock = $returnblock.rblock;}
   |  returnblock=loop[regtable, b, exit, structtable, vartable]{$rblock = $returnblock.rblock;}
   |  delete[regtable, b, exit, structtable, vartable]{$rblock = b;}
   |  returnblock=ret[regtable, b, exit, structtable, vartable]{$rblock = $returnblock.rblock;}
   |  expression[regtable, b, exit, structtable, vartable]{$rblock = b;}
   ;
   
block[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block rblock]
   :  ^(BLOCK finalblock=statement_list[regtable, b, exit, structtable, vartable]{rblock = $finalblock.rblock;})
   ;
   
assignment[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(ASSIGN rv=expression[regtable, b, exit, structtable, vartable] lv=lvalue[regtable, b, exit, structtable, vartable])
        {
           if(lv.offset == null){
             b.instructions.add(new StoreVariableInstruction($lv.r.name, $rv.r, $regtable.get($lv.r.name))); 
             //b.instructions.add(new MoveInstruction($rv.r, $lv.r));
           }
           else{
             b.instructions.add(new AddressInstruction("storeai", $rv.r, $lv.r, $lv.offset, $lv.sparcOffset));
           }
        }
   ;
   
print[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(PRINT reg=expression[regtable, b, exit, structtable, vartable] (println = ENDL)?)
      {
        if(println == null){
          b.instructions.add(new UnaryInstruction("print", $reg.r));
        }
        else{
          b.instructions.add(new UnaryInstruction("println", $reg.r));
        }
      }
   ;
   
read[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(READ reg=lvalue[regtable, b, exit, structtable, vartable])
      {
        Register temp = new Register();
        b.instructions.add(new UnaryInstruction("read", temp));
        if(reg.offset == null){
          if($reg.r.global){
             b.instructions.add(new StoreVariableInstruction($reg.r.name, temp, $reg.r));
          }
          else{
             b.instructions.add(new MoveInstruction(temp, $reg.r));
          }
        }
        else{
          b.instructions.add(new AddressInstruction("storeai", temp, $reg.r, $reg.offset, $reg.sparcOffset));
        }
      }
   ;
   
conditional[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block thenblock = new Block();
      Block elseblock = new Block();
   }
   :  ^(IF reg=expression[regtable, b, exit, structtable, vartable]{thenblock.name = "L" + c + "ifthen";} thenLast = block[regtable, thenblock, exit, structtable, vartable] {elseblock.name = "L" + c + "ifelse";}(elseLast = block[regtable, elseblock, exit, structtable, vartable])?)
       {
          /*Register condition = new Register();
          b.instructions.add(new LoadInstruction("loadi", "1", condition));
          b.instructions.add(new ComparisonInstruction("comp", condition, $reg.r));
          continueblock.name = "L" + c + "cont";
          b.successors.add(thenblock);
          thenblock.predecessors.add(b);
          if(elseLast == null){
             b.successors.add(continueblock);
             continueblock.predecessors.add(b);
             b.instructions.add(new BranchInstruction("cbreq", thenblock.name, continueblock.name));
          }
          else{
             b.successors.add(elseblock);
             elseblock.predecessors.add(b);
             if(!$elseLast.rblock.name.substring(0, 4).equals("exit")){
               $elseLast.rblock.successors.add(continueblock);
               continueblock.predecessors.add($elseLast.rblock);
               $elseLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
               b.instructions.add(new BranchInstruction("cbreq", thenblock.name, elseblock.name));
             }
          }
          
          if(!$thenLast.rblock.name.substring(0, 4).equals("exit")){
            $thenLast.rblock.successors.add(continueblock);
            continueblock.predecessors.add($thenLast.rblock);
            $thenLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
          }*/
          Register condition = new Register();
          b.instructions.add(new LoadInstruction("loadi", "1", condition));
          b.instructions.add(new ComparisonInstruction("comp", condition, $reg.r));
          b.instructions.add(new BranchInstruction("cbreq", thenblock.name, elseblock.name));
          continueblock.name = "L" + c + "cont";
          b.successors.add(thenblock);
          thenblock.predecessors.add(b);
          
          $thenLast.rblock.successors.add(continueblock);
          continueblock.predecessors.add($thenLast.rblock);
          $thenLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
          
          b.successors.add(elseblock);
          elseblock.predecessors.add(b);
          if(elseLast == null){
            elseblock.successors.add(continueblock);
            continueblock.predecessors.add(elseblock);
            elseblock.instructions.add(new JumpInstruction(continueblock.name));
          }
          else{
            $elseLast.rblock.successors.add(continueblock);
            continueblock.predecessors.add($elseLast.rblock);
            $elseLast.rblock.instructions.add(new JumpInstruction(continueblock.name));
          }
       }
   ;
   
loop[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block continueblock = new Block()]
   @init
   {
      Block.counter++;
      int c = Block.counter;
      Block expblock = new Block();
      expblock.name = "L" + c + "whileexp";
      Block execblock = new Block();
      execblock.name = "L" + c + "whileexec";
      continueblock.name = "L" + c + "whilecont";
   }
   :  ^(WHILE exp=expression[regtable, expblock, exit, structtable, vartable] lastexec=block[regtable, execblock, exit, structtable, vartable] expression[regtable, new Block(), exit, structtable, vartable])
       {
         Register condition = new Register();
         expblock.instructions.add(new LoadInstruction("loadi", "1", condition));
         expblock.instructions.add(new ComparisonInstruction("comp", condition, $exp.r));
         expblock.instructions.add(new BranchInstruction("cbreq", execblock.name, continueblock.name));
         b.successors.add(expblock);
         expblock.predecessors.add(b);
         b.instructions.add(new JumpInstruction(expblock.name));
         expblock.successors.add(execblock);
         execblock.predecessors.add(expblock);
         expblock.successors.add(continueblock);
         continueblock.predecessors.add(expblock);
         $lastexec.rblock.successors.add(expblock);
         expblock.predecessors.add($lastexec.rblock);
         $lastexec.rblock.instructions.add(new JumpInstruction(expblock.name));
       }
   ;
 
delete[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  ^(DELETE reg=expression[regtable, b, exit, structtable, vartable]
         {
           b.instructions.add(new UnaryInstruction("del", $reg.r));
         }
       )
   ;
   
ret[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Block rblock]
   : ^(RETURN (reg=expression[regtable, b, exit, structtable, vartable])?)
      {
        b.successors.add(exit);
        exit.predecessors.add(b);
        if(reg==null){
          b.instructions.add(new RetInstruction());
        }
        else{
          b.instructions.add(new RetInstruction($reg.r));
        }
        b.instructions.add(new JumpInstruction(exit.name));
        $rblock = exit;
     }
   ;
   
lvalue[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Register r = new Register(), String offset = null, int sparcOffset = 0]
   :  rid=id{$r = $regtable.get($rid.rstring);}
   | ^(DOT lv=lvalue_h[regtable, b, $r, structtable, vartable, true] rid=id)
      {
        $r = $lv.r;
        $offset = "@" + $rid.rstring;
        if($lv.structfields != null){
          ArrayList<String> temp = new ArrayList<String>($lv.structfields.keySet());
          $sparcOffset = 4 * temp.indexOf($rid.rstring);
        }
      }
   ;

lvalue_h[HashMap<String, Register> regtable, Block b, Register in, HashMap<String, StructType> structtable, HashMap<String, Type> vartable, boolean initial] returns [Register r = new Register(), LinkedHashMap<String, Type> structfields = null]
   :  rid=id
      {
        Register temp = regtable.get($rid.rstring);
        if(temp.global) {
          b.instructions.add(new LoadGlobalInstruction(temp.name, $r));
        } else {
          b.instructions.add(new LoadVariableInstruction(temp.name, $r));
          $r = temp;
        }
        if($vartable.get($rid.rstring).isStruct()){
          $structfields = ((StructType)vartable.get($rid.rstring)).types;
        }
      }
   | ^(DOT lv=lvalue_h[regtable, b, in, structtable, vartable, false] rid=id)
      {   
        int offset = 0;
        if($lv.structfields != null){
          ArrayList<String> temp = new ArrayList<String>($lv.structfields.keySet());
          offset = 4 * temp.indexOf($rid.rstring);
        }
        
        b.instructions.add(new AddressInstruction("loadai", $lv.r, $r, "@" + $rid.rstring, offset));
        
        if($lv.structfields != null && $lv.structfields.get($rid.rstring).isStruct()){
            $structfields = ((StructType)$lv.structfields.get($rid.rstring)).types;
        }
      }
   ;

expression[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable] returns [Register r = new Register(), LinkedHashMap<String, Type> structfields = null]
   : ^(AND lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] {b.instructions.add(new ArithmeticInstruction("and", $lv.r, $rv.r, $r));})
   | ^(OR lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] {b.instructions.add(new ArithmeticInstruction("or", $lv.r, $rv.r, $r));})
   | ^(EQ lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("moveq", "1", $r));
        }
      )
   | ^(LT lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movlt", "1", $r));
        }
      )
   | ^(GT lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] 
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movgt", "1", $r));
        }
      )
   | ^(NE lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movne", "1", $r));
        }
      )
   | ^(LE lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] 
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movle", "1", $r));
        }
      )
   | ^(GE lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable]
        {
          Register lr = new Register();
          Register rr = new Register();
          b.instructions.add(new MoveInstruction($lv.r, lr));
          b.instructions.add(new MoveInstruction($rv.r, rr));
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          b.instructions.add(new ComparisonInstruction("comp", lr, rr));
          b.instructions.add(new MoveConditionInstruction("movge", "1", $r));
        }
      )
   | ^(PLUS lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] {b.instructions.add(new ArithmeticInstruction("add", $lv.r, $rv.r, $r));})
   | ^(MINUS lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] {b.instructions.add(new ArithmeticInstruction("sub", $lv.r, $rv.r, $r));})
   | ^(TIMES lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable]  {b.instructions.add(new ArithmeticInstruction("mult", $lv.r, $rv.r, $r));})
   | ^(DIVIDE lv=expression[regtable, b, exit, structtable, vartable] rv=expression[regtable, b, exit, structtable, vartable] {b.instructions.add(new ArithmeticInstruction("div", $lv.r, $rv.r, $r));})
   | ^(NOT uv=expression[regtable, b, exit, structtable, vartable]
        {
          b.instructions.add(new LoadInstruction("loadi", "1", $r));
          b.instructions.add(new ArithmeticInstruction("xor", $uv.r, $r, $r));
        }
      )
   | ^(NEG uv=expression[regtable, b, exit, structtable, vartable]
        {
          b.instructions.add(new LoadInstruction("loadi", "0", $r));
          //b.instructions.add(new ArithmeticInstruction("mult", $uv.r, new Register(), $r));
          b.instructions.add(new ArithmeticInstruction("sub", $r, $uv.r, $r));
        }
       )
   | ^(DOT reg=expression[regtable, b, exit, structtable, vartable] rid=id
        {
          int offset = 0;
          if($reg.structfields != null){
            ArrayList<String> temp = new ArrayList<String>($reg.structfields.keySet());
            offset = 4 * temp.indexOf($rid.rstring);
          }
          //System.out.println("LV: " + $reg.r + ", R: " + $r.sparcName);
          b.instructions.add(new AddressInstruction("loadai", $reg.r, $r, "@" + $rid.rstring, offset));
          
          if($reg.structfields != null && $reg.structfields.get($rid.rstring).isStruct()){
            $structfields = ((StructType)$reg.structfields.get($rid.rstring)).types;
          }
        }
      )
   |  rid=id
   {
     /*Register temp = regtable.get($rid.rstring);
     if(temp.global) {
       b.instructions.add(new LoadGlobalInstruction(temp.name, $r));
     } else {
       b.instructions.add(new LoadVariableInstruction(temp.name, $r));
     }
     if(vartable.get($rid.rstring).isStruct()){
       $structfields = ((StructType)vartable.get($rid.rstring)).types;
     }*/

     $r = regtable.get($rid.rstring);
     if($r.global) {
       b.instructions.add(new LoadGlobalInstruction($r.name, $r));
     } else {
       b.instructions.add(new LoadVariableInstruction($r.name, $r));
     }
     if(vartable.get($rid.rstring).isStruct()){
       $structfields = ((StructType)vartable.get($rid.rstring)).types;
     }
   }
   |  tnode=INTEGER{b.instructions.add(new LoadInstruction("loadi", $tnode.text, $r));}
   |  TRUE{b.instructions.add(new LoadInstruction("loadi", "1", $r));}
   |  FALSE{b.instructions.add(new LoadInstruction("loadi", "0", $r));}
   |  ^(NEW rid=id)
       {
         HashSet<String> temp = new HashSet<String>(structtable.get($rid.rstring).types.keySet());
         b.instructions.add(new NewInstruction($rid.rstring, temp, $r));
       }
   |  NULL{
        b.instructions.add(new LoadInstruction("loadi", "0", $r));
      }
   |  ^(INVOKE rid=id arguments[regtable, b, exit, structtable,vartable])
      {
        b.instructions.add(new CallInstruction($rid.rstring, $r));
      }
   ;
   
arguments[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   :  arg_list[regtable, b, exit, structtable, vartable]
   ;
   
arg_list[HashMap<String, Register> regtable, Block b, Block exit, HashMap<String, StructType> structtable, HashMap<String, Type> vartable]
   @init
   {
      ArrayList<Register> reglist = new ArrayList<Register>();
   }
   :  ARGS
   |  ^(ARGS (reg = expression[regtable, b, exit, structtable, vartable]{reglist.add($reg.r);})+)
      {
         for(int i = 0; i < reglist.size(); i++){
           b.instructions.add(new StoreOutInstruction(new Integer(i).toString(),reglist.get(i)));
         }
      }
   ;
