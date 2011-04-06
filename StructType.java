import java.util.HashMap;

public class StructType extends Type {
  public HashMap<String, Type> types;
  public StructType(){
   types = new HashMap<String, Type>();
  }
}
