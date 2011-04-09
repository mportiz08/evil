import java.util.HashMap;

public class FuncType extends Type
{
  public HashMap<String, Type> params;
  public FuncType()
  {
    params = new HashMap<String, Type>();
  }
}