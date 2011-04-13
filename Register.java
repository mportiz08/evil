public class Register extends Operand
{
  public int number;
  
  public Register(int number)
  {
    this.number = number;
  }
  
  public String toString()
  {
    return new String("r" + number);
  }
}
