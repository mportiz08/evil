public class StoreVariableInstruction extends Instruction
{
  private String vname;
  private Register reg;
  
  public StoreVariableInstruction(String vname, Register reg)
  {
    super("storeai");
    this.vname = vname;
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(this.name + " " + this.reg + ", rarp, " + this.vname);
  }
}