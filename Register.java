public class Register extends Operand
{
  public static int counter = 0;
  private int num;
  
  public Register()
  {
    counter++;
    num = counter;
  }
  
  public String toString()
  {
    return new String("r" + num);
  }
}
