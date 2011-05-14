public class LoadGlobalInstruction extends Instruction
{
  private String gname;
  private Register reg;
  
  public LoadGlobalInstruction(String gname, Register reg)
  {
    super("loadglobal");
    this.gname = gname;
    this.reg = reg;
  }
  
  public String toSparc(){
    return new String("set " + gname + ", " + reg.sparcName + "\n  ldsw [" + reg.sparcName + "], " + reg.sparcName); 
  }
  
  public String toString()
  {
    return new String(this.name + " " + this.gname + ", " + this.reg);
  }
}
