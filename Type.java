public class Type{
  public static boolean isInt(Type t){return t instanceof IntType;}
  public static boolean isBool(Type t) {return t instanceof BoolType;}
  public static boolean isStruct(Type t) {return t instanceof StructType;}
}
