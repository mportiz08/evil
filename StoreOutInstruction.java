public class StoreOutInstruction extends Instruction
{
  public Register reg;
  public String immediate;
  
  public StoreOutInstruction(String immediate, Register reg)
  {
    super("storeoutargument");
    this.immediate = immediate;
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(name + " " + reg + ", " + immediate);
  }
  
  public String toSparc()
  {
    return new String("mov " + this.reg + ", " + "%o" + immediate);
  }
}
