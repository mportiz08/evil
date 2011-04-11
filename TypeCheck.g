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
   import java.util.LinkedHashMap;
}

verify[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(PROGRAM types[structtable] declarations[structtable, vartable] functions[functable, structtable, vartable])
   ;

types[HashMap<String,StructType> structtable]
   :  ^(TYPES {System.out.println("types");} (type_sub[structtable])*)
   ;

declarations[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLS {System.out.println("decls");} (declaration[structtable,vartable])*)
   ;

functions[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(FUNCS {System.out.println("funcs");} (function[functable, structtable, vartable])*)
   ;

type_sub[HashMap<String,StructType> structtable]
   :  ^(STRUCT {System.out.println("struct");} rid=id
        {
          if($structtable.containsKey($rid.rstring)){
               EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring  + " is already declared");
            }
          $structtable.put($rid.rstring, new StructType());
        }
        filledStruct = nested_decl[structtable,new StructType()]{$structtable.put($rid.rstring,$filledStruct.fs);}
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
      )+{$fs = $inf;}
   ;
   
declaration[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLLIST {System.out.println("decllist");} ^(TYPE {System.out.println("type");} 
        dtype=type[structtable]{$dtype.rtype.global = true;}) id_list[structtable,vartable,dtype])
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
   |  ^(STRUCT {System.out.println("struct2");} testid = id
         {
           if(!$structtable.containsKey($testid.rstring)){
              EvilUtil.die("line " + $testid.linenumber + ": struct " + $testid.rstring  + " does not exist");
           }
           $rtype = $structtable.get($testid.rstring);
         })
   ;

id returns [String rstring = null, int linenumber = 0]
   : ^(tnode=ID {System.out.println("id"); $rstring = $tnode.text; $linenumber = $tnode.line;})
   ;

function[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable] returns [String name  = null]
   :  ^(FUN {System.out.println("fun");} rid=id{$name = $rid.rstring;} rparams=params[structtable,vartable]
       ^(RETTYPE {System.out.println("rettype");} rret=return_type[structtable])
       {
         if($functable.containsKey($rid.rstring))
         {
           EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring + " is already defined.");
         }
         FuncType func = new FuncType();
         $functable.put($rid.rstring, func);
         HashMap<String,Type> copy_vartable = new HashMap<String,Type>();
         copy_vartable.putAll(vartable);
         copy_vartable.putAll($rparams.rtype);
       }
       localdeclarations[structtable,copy_vartable] statement_list[functable,structtable,copy_vartable,rret])
   ;

localdeclarations[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLS {System.out.println("decls");} (localdeclaration[structtable,vartable])*)
   ;

localdeclaration[HashMap<String,StructType> structtable, HashMap<String,Type> vartable]
   :  ^(DECLLIST {System.out.println("decllist");} ^(TYPE {System.out.println("type");} 
        dtype=type[structtable]) localid_list[structtable,vartable,dtype])
   ;
   
localid_list[HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type dtype]
   : (rid=id
       {
         if($vartable.containsKey($rid.rstring) && !$vartable.get($rid.rstring).global)
         {
           EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring + " is already defined.");
         }
         if($structtable.containsKey($rid.rstring) && !$structtable.get($rid.rstring).global)
         {
           EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring + " is already defined.");
         }
         $vartable.put($rid.rstring,$dtype);
       }
     )+
   ;

params[HashMap<String,StructType> structtable, HashMap<String,Type> vartable] returns [LinkedHashMap<String, Type> rtype = null]
   :  ^(PARAMS {System.out.println("params"); $rtype = new LinkedHashMap<String, Type>();} (rdecl=decl[structtable]
        {
          if($rtype.containsKey($rdecl.rid))
          {
            EvilUtil.die("line " + $rdecl.linenumber + ": " + $rdecl.rid + " is already defined.");
          }
          if($vartable.containsKey($rdecl.rid) && !$vartable.get($rdecl.rid).global)
          {
            EvilUtil.die("line " + $rdecl.linenumber + ": " + $rdecl.rid + " is already defined.");
          }
          if($structtable.containsKey($rdecl.rid) && !$structtable.get($rdecl.rid).global)
          {
            EvilUtil.die("line " + $rdecl.linenumber + ": " + $rdecl.rid + " is already defined.");
          }
          $rtype.put($rdecl.rid, $rdecl.rtype);
        }
      )*)
   ;

return_type[HashMap<String,StructType> structtable] returns [Type rtype = null]
   :  expected=type[structtable] {$rtype = $expected.rtype;}
   |  VOID {System.out.println("void rtype"); $rtype = new Type();}
   ;

statement_list[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(STMTS {System.out.println("stmts");} statement[functable,structtable,vartable,rret]*)
   ;
   
statement[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  block[functable,structtable,vartable,rret]
   |  assignment[functable,structtable,vartable,rret]
   |  print[functable,structtable,vartable,rret]
   |  read[functable,structtable,vartable,rret]
   |  conditional[functable,structtable,vartable,rret]
   |  loop[functable,structtable,vartable,rret]
   |  delete[functable,structtable,vartable,rret]
   |  ret[functable,structtable,vartable,rret]
   |  invocation[functable,structtable,vartable,rret]
   ;
   
block[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(BLOCK {System.out.println("block");} statement_list[functable,structtable,vartable,rret])
   ;
   
assignment[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(ASSIGN {System.out.println("assign");} expression[functable,structtable,vartable,rret] lvalue[functable,structtable,vartable,rret])
   ;
   
print[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(tnode=PRINT {System.out.println("print");} uv=expression[functable,structtable,vartable,rret] (ENDL {System.out.println("endl");})?
         {
           if(!$uv.rtype.isInt())
           {
             EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type int.");
           }
         }
       )
   ;
   
read[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret] returns [Type rtype = null]
   :  ^(READ {System.out.println("read");} lvalue[functable,structtable,vartable,rret])
   ;
   
conditional[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(IF {System.out.println("if");} expression[functable,structtable,vartable,rret] block[functable,structtable,vartable,rret] 
        (block[functable,structtable,vartable,rret])?)
   ;
   
loop[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(WHILE {System.out.println("while");} expression[functable,structtable,vartable,rret] block[functable,structtable,vartable,rret] 
         expression[functable,structtable,vartable,rret])
   ;
 
delete[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(DELETE {System.out.println("delete");} expression[functable,structtable,vartable,rret])
   ;
   
ret[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   : ^(RETURN {System.out.println("ret");} (expression[functable,structtable,vartable,rret])?)
   ;
   
invocation[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ^(INVOKE {System.out.println("invoke");} id arguments[functable,structtable,vartable,rret])
   ;
   
lvalue [HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  id
   | ^(DOT {System.out.println("lvalue dot");} lvalue[functable,structtable,vartable,rret] id)
   ;
   
expression [HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret] returns [Type rtype = null]
   : ^(tnode=AND {System.out.println("random expression");} lv = expression[functable,structtable,vartable,rret] 
                                                            rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=OR {System.out.println("random expression");} lv = expression[functable,structtable,vartable,rret] 
                                                           rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=EQ {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
        {
          if(!$lv.rtype.isInt() && !$lv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type [int, struct].");
          }
          if(!$rv.rtype.isInt() && !$rv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type [int, struct].");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=LT {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=GT {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=NE {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
        {
          if(!$lv.rtype.isInt() && !$lv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not of type [int, struct].");
          }
          if(!$rv.rtype.isInt() && !$rv.rtype.isStruct())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $rv.text + " is not of type [int, struct].");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=LE {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=GE {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                           rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=PLUS {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                             rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=MINUS {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                              rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=TIMES {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                              rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=DIVIDE {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                               rv = expression[functable,structtable,vartable,rret]
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
   | ^(tnode=NOT {System.out.println("random expression");} uv=expression[functable,structtable,vartable,rret]
        {
          if(!$uv.rtype.isBool())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type bool.");
          }
          $rtype = new BoolType();
        }
      )
   | ^(tnode=NEG {System.out.println("random expression");} uv=expression[functable,structtable,vartable,rret]
        {
          if(!$uv.rtype.isInt())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $uv.text + " is not of type int.");
          }
          $rtype = new IntType();
        }
      )
   | ^(DOT {System.out.println("random expression");} expression[functable,structtable,vartable,rret] 
                                                      expression[functable,structtable,vartable,rret])
   | ^(tnode=INVOKE {System.out.println("random expression");} lv=expression[functable,structtable,vartable,rret]
                                                               args=arguments[functable,structtable,vartable,rret]
        {
          if(!$lv.rtype.isFunc())
          {
            EvilUtil.die("line " + $tnode.line + ": " + $lv.text + " is not a function.");
          }
        }
      )
   |  rid = id 
        {
          System.out.println("random expression");
          if(!$vartable.containsKey($rid.rstring)){
            EvilUtil.die("line " + $rid.linenumber + ": " + $rid.rstring + " does not exist");
          }
          $rtype = $vartable.get($rid.rstring);
        }
   |  INTEGER {System.out.println("random expression"); $rtype = new IntType(); }
   |  TRUE {System.out.println("random expression"); $rtype = new BoolType();}
   |  FALSE {System.out.println("random expression"); $rtype = new BoolType(); }
   |  ^(NEW {System.out.println("random expression");} id {$rtype = new StructType();})
   |  NULL {System.out.println("random expression"); $rtype = new Type();}
   ;
   
arguments[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  arg_list[functable,structtable,vartable,rret]
   ;
   
arg_list[HashMap<String, FuncType> functable, HashMap<String,StructType> structtable, HashMap<String,Type> vartable, Type rret]
   :  ARGS
   |  ^(ARGS {System.out.println("args");} (expression[functable,structtable,vartable,rret])+)
   ;
