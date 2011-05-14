public class CallInstruction extends Instruction
{
  public Register reg;
  public String fxn;
  public Register sparcRegister;
  
  public CallInstruction(String fxn, Register reg)
  {
    super("call");
    this.fxn = fxn;
    this.reg = reg;
    sparcRegister = new Register("%o0");
  }
  
  public String toString()
  {
    return new String(name + " " + fxn + "\n  loadret " + reg);
  }
  
  public String toSparc()
  {
    return new String(name + " " + fxn + "\n  nop\n  " + "mov %o0, " + this.reg.sparcName);
  }
}
