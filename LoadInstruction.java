public class LoadInstruction extends Instruction
{
  public Register reg;
  public String immediate;
  
  public LoadInstruction(String name, String immediate, Register reg)
  {
    super(name);
    this.immediate = immediate;
    this.reg = reg;
  }
  
  public String toSparc()
  {
    return new String("set " + immediate + ", " + reg.sparcName);
  }
  
  public String toString()
  {
    return new String(name + " " + immediate + ", " + reg);
  }
}
