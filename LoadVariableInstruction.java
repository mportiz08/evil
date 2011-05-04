public class LoadVariableInstruction extends Instruction
{
  private String vname;
  private Register reg;
  
  public LoadVariableInstruction(String vname, Register reg)
  {
    super("loadai");
    this.vname = vname;
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(this.name + " rarp, " + this.vname + ", " + this.reg);
  }
}
