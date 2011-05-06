public class UnaryInstruction extends Instruction
{
  public Register reg;
  public Register sparcRegister;
  
  public UnaryInstruction(String name, Register reg)
  {
    super(name);
    this.reg = reg;
    sparcRegister = new Register();
  }
  
  public String toSparc(){
    if(name.equals("del")){
      return new String("mov " + reg + ", " + sparcRegister + "\n  call free\n  nop");
    }
    return "";
  }
  
  public String toString()
  {
    return new String(name + " " + reg);
  }
}
