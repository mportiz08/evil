public class Register extends Operand
{
  public static int counter = 0;
  private int num;
  public String name;
  public boolean global;
  public String sparcName;
  
  public Register()
  {
    counter++;
    num = counter;
    name = "r" + new Integer(num).toString();
    sparcName = name;
    global = false;
  }
  
  public Register(String name)
  {
    counter++;
    num = counter;
    sparcName = "r" + new Integer(num).toString();
    this.name = name;
    global = false;
  }
  
  public String toString()
  {
    return name;
  }
}
