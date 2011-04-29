public class Register extends Operand
{
  public static int counter = 0;
  private int num;
  public String name;
  public boolean global;
  
  public Register()
  {
    counter++;
    num = counter;
    name = new Integer(num).toString();
    global = false;
  }
  
  public Register(String name)
  {
    this.name = name;
    global = false;
  }
  
  public String toString()
  {
    return "r" + name;
  }
}
