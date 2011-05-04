public class CallInstruction extends Instruction
{
  public Register reg;
  public String fxn;
  
  public CallInstruction(String fxn, Register reg)
  {
    super("call");
    this.fxn = fxn;
    this.reg = reg;
  }
  
  public String toString()
  {
    return new String(name + " " + fxn + "\n  loadret " + reg);
  }
  
  public String toSparc()
  {
    return new String(name + " " + fxn + "\n  nop");
  }
}
