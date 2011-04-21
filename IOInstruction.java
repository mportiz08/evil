public class IOInstruction extends Instruction
{
  public Register reg;
  
  public IOInstruction(String name, Register reg)
  {
    super(name);
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(name + " " + reg);
  }
}
