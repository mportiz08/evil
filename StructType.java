import java.util.*;

public class StructType extends Type {
  public String name;
  public LinkedHashMap<String, Type> types;
  public StructType(){
   types = new LinkedHashMap<String, Type>();
  }
}
