public class UnaryInstruction extends Instruction
{
  public Register reg;
  
  public UnaryInstruction(String name, Register reg)
  {
    super(name);
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(name + " " + reg);
  }
}
