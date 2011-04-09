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

verify[HashMap<String,StructType> structtable, HashMap<String,Type> vartable] returns [Type rtype = null]
   :  ^(PROGRAM types declarations functions)
   ;

types
   :  ^(TYPES {System.out.println("types");} type_sub*)
   ;

declarations
   :  ^(DECLS {System.out.println("decls");} declaration*)
   ;

functions
   :  ^(FUNCS {System.out.println("funcs");} function*)
   ;

type_sub
   :  ^(STRUCT {System.out.println("struct");} id nested_decl)
   ;

decl
   :  ^(DECL {System.out.println("decl");} ^(TYPE {System.out.println("type");} type) id)
   ;

nested_decl
   :  decl+
   ;
   
declaration
   :  ^(DECLLIST {System.out.println("decllist");} ^(TYPE {System.out.println("type");} type) id_list)
   ;
   
id_list
   : id+
   ;

type
   :  INT {System.out.println("int");}
   |  BOOL {System.out.println("bool");}
   |  ^(STRUCT {System.out.println("struct");} id)
   ;

id
   : ^(ID {System.out.println("id");})
   ;

function returns [String name  = null]
   :  ^(FUN {System.out.println("fun");} id params ^(RETTYPE {System.out.println("rettype");} return_type) declarations statement_list)
   ;
   
params returns [Type rtype = null]
   :  ^(PARAMS {System.out.println("params");} decl*)
   ;

return_type returns [Type rtype = null]
   :  type
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
