import java.util.LinkedHashMap;

public class FuncType extends Type
{
  public LinkedHashMap<String, Type> params;
  public Type returntype; 
  public FuncType()
  {
    params = new LinkedHashMap<String, Type>();
  }
}