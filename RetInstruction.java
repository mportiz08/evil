public class RetInstruction extends Instruction
{
  public String str;
  
  public RetInstruction(Register reg)
  {
    super("storeret");
    str = name + " " + reg + "\n  ret";
  }
  
  public RetInstruction()
  {
    super("ret");
    str = name;
  }
  
  public String toString()
  {
    return str;
  }
}
