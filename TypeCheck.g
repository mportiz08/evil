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

verify[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(PROGRAM types[structtable] declarations[structtable, vartable] functions[structtable, vartable])
   ;

types[HashMap<String,StructType> structtable]
   :  ^(TYPES {System.out.println("types");} (type_sub[structtable])*)
   ;

declarations[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLS {System.out.println("decls");} (declaration[structtable,vartable])*)
   ;

functions[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(FUNCS {System.out.println("funcs");} (function[structtable, vartable])*)
   ;

type_sub[HashMap<String,StructType> structtable]
   :  ^(STRUCT {System.out.println("struct");} rid=id 
        filledStruct = nested_decl[structtable,new StructType()]
           {
            if($structtable.containsKey($rid.rstring)){
               EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring  + " is already declared");
            }
            $structtable.put($rid.rstring,$filledStruct.fs);
          }
        )
   ;

decl [HashMap<String,StructType> structtable] returns [Type rtype = null, String rid = null, int linenumber = 0]
   :  ^(DECL {System.out.println("decl");} 
       ^(TYPE {System.out.println("type");} rrtype = type[structtable]{$rtype = $rrtype.rtype;}) 
       rrid = id{$rid = $rrid.rstring; $linenumber = $rrid.linenumber;})
   ;

nested_decl[HashMap<String,StructType> structtable, StructType inf] returns [StructType fs]
   :  (rdecl=decl[structtable]
        {
          if($inf.types.containsKey($rdecl.rid)){
             EvilUtil.die("line " + $rdecl.linenumber + ": " + $rdecl.rid  + " is already declared");
          }
          $inf.types.put($rdecl.rid,$rdecl.rtype);
        }
      )+
   ;
   
declaration[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLLIST {System.out.println("decllist");} ^(TYPE {System.out.println("type");} dtype=type[structtable]) id_list[structtable,vartable,dtype])
   ;
   
id_list[HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type dtype]
   : (rid=id
        {
          if($vartable.containsKey($rid.rstring)){
             EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring  + " is already declared");
          }
          $vartable.put($rid.rstring,$dtype);
        }
      )+
   ;

type[HashMap<String,StructType> structtable] returns [Type rtype = null]
   :  INT {System.out.println("int"); $rtype = new IntType();}
   |  BOOL {System.out.println("bool"); $rtype = new BoolType();}
   |  ^(STRUCT {System.out.println("struct2"); $rtype = new IntType();} testid = id
         {
           if(!$structtable.containsKey($testid.rstring)){
              EvilUtil.die("line " + $testid.linenumber + ": struct " + $testid.rstring  + " does not exist");
           }
         })
   ;

id returns [String rstring = null, int linenumber = 0]
   : ^(tnode=ID {System.out.println("id"); $rstring = $tnode.text; $linenumber = $tnode.line;})
   ;

function[HashMap<String,StructType> structtable, HashMap<String,Type> vartable] returns [String name  = null]
   :  ^(FUN {System.out.println("fun");} id params[structtable] ^(RETTYPE {System.out.println("rettype");} return_type[structtable]) declarations[structtable,vartable] statement_list)
   ;
   
params[HashMap<String,StructType> structtable] returns [Type rtype = null]
   :  ^(PARAMS {System.out.println("params");} (decl[structtable])*)
   ;

return_type[HashMap<String,StructType> structtable] returns [Type rtype = null]
   :  type[structtable]
   |  VOID {System.out.println("void rtype");}
   ;

statement_list returns [Type rtype = null]
   :  ^(STMTS {System.out.println("stmts");} statement*)
   ;
   
statement returns [Type rtype = null]
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
   
block returns [Type rtype = null]
   :  ^(BLOCK {System.out.println("block");} statement_list)
   ;
   
assignment returns [Type rtype = null]
   :  ^(ASSIGN {System.out.println("assign");} expression lvalue)
   ;
   
print returns [Type rtype = null]
   :  ^(tnode=PRINT {System.out.println("print");} uv=expression (ENDL {System.out.println("endl");})?
         {
           if(!$uv.rtype.isInt())
           {
             EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type int.");
           }
         }
       )
   ;
   
read returns [Type rtype = null]
   :  ^(READ {System.out.println("read");} lvalue)
   ;
   
conditional returns [Type rtype = null]
   :  ^(IF {System.out.println("if");} expression block (block)?)
   ;
   
loop returns [Type rtype = null]
   :  ^(WHILE {System.out.println("while");} expression block expression)
   ;
 
delete returns [Type rtype = null]
   :  ^(DELETE {System.out.println("delete");} expression)
   ;
   
ret returns [Type rtype = null]
   : ^(RETURN {System.out.println("ret");} (expression)?)
   ;
   
invocation returns [Type rtype = null]
   :  ^(INVOKE {System.out.println("invoke");} id arguments)
   ;
   
lvalue returns [Type rtype = null]
   :  id
   | ^(DOT {System.out.println("lvalue dot");} lvalue id)
   ;
   
expression returns [Type rtype = null]
   : ^(tnode=AND {System.out.println("random expression");} lv = expression rv = expression
        {
          if(!$lv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type bool.");
          }
          if(!$rv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type bool.");
          }
          $rtype = new BoolType();
        })
   | ^(tnode=OR {System.out.println("random expression");} lv = expression rv = expression
        {
          if(!$lv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type bool.");
          }
          if(!$rv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type bool.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=EQ {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt() || !$lv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type [int, struct].");
          }
          if(!$rv.rtype.isInt() || !$rv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type [int, struct].");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=LT {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=GT {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=NE {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt() || !$lv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type [int, struct].");
          }
          if(!$rv.rtype.isInt() || !$rv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type [int, struct].");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=LE {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=GE {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=PLUS {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(tnode=MINUS {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(tnode=TIMES {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(tnode=DIVIDE {System.out.println("random expression");} lv=expression rv=expression
        {
          if(!$lv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type int.");
          }
          if(!$rv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(tnode=NOT {System.out.println("random expression");} uv=expression
        {
          if(!$uv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type bool.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=NEG {System.out.println("random expression");} uv=expression
        {
          if(!$uv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(DOT {System.out.println("random expression");} expression expression)
   | ^(tnode=INVOKE {System.out.println("random expression");} lv=expression args=arguments
        {
          if(!$lv.rtype.isFunc())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not a function.");
          }
        }
      )
   |  ID {System.out.println("random expression");}
   |  INTEGER {System.out.println("random expression"); $rtype = new IntType(); }
   |  TRUE {System.out.println("random expression"); $rtype = new BoolType();}
   |  FALSE {System.out.println("random expression"); $rtype = new BoolType(); }
   |  ^(NEW {System.out.println("random expression");} id {$rtype = new StructType();})
   |  NULL {System.out.println("random expression"); $rtype = new Type();}
   ;
   
arguments returns [Type rtype = null]
   :  arg_list
   ;
   
arg_list returns [Type rtype = null]
   :  ARGS
   |  ^(ARGS {System.out.println("args");} expression+)
   ;
