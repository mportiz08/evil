public class Register extends Operand
{
  public static int counter = 0;
  private int num;
  public String name;
  
  public Register()
  {
    counter++;
    num = counter;
    name = "r" + num;
  }
  
  public Register(String name)
  {
    name = "r" + name;
  }
  
  public String toString()
  {
    return name;
  }
}
