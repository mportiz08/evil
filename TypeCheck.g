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

verify
   :  ^(PROGRAM types declarations functions)
   ;

types
   :  ^(TYPES type_sub*)
   ;

declarations
   :  ^(DECLS declaration*)  
   ;

functions:
;

type_sub
   :  ^(STRUCT id nested_decl)
   ;

nested_decl
   :  ^(DECL ^(TYPE type) id)
   ;
   
declaration
   :  decl_list*
   ;
   
decl_list
   :  ^(DECLLIST ^(TYPE type) id_list)
   ;
   
id_list
   :
   ;

type
   :  INT
   |  BOOL
   |  ^(STRUCT id)
   ;

id:
;
