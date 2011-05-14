public class RetInstruction extends Instruction
{
  public String str;
  public Register reg;
  
  public RetInstruction(Register reg)
  {
    super("storeret");
    this.reg = reg;
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
  
  public String toSparc()
  {
    if(reg == null)
    {
      return new String(str + "  \n  restore");
    }
    else
    {
      return new String("mov " + this.reg.sparcName + ", %i0\n  ret\n  restore");
    }
  }
}
