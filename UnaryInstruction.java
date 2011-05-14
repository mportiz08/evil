public class UnaryInstruction extends Instruction
{
  public Register reg;
  public Register sparcRegister;
  public Register sparcRegister2;
  
  public UnaryInstruction(String name, Register reg)
  {
    super(name);
    this.reg = reg;
    sparcRegister = new Register("%o0");
    sparcRegister2 = new Register("%o1");
  }
  
  public String toSparc(){
    if(name.equals("del")){
      return new String("mov " + reg.sparcName + ", " + sparcRegister.sparcName + "\n  call free\n  nop");
    } else if(name.equals("print")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC0), " + sparcRegister.sparcName + "\n  or " + sparcRegister.sparcName + ", %lo(.LCC0), " + sparcRegister.sparcName + "\n  mov " + this.reg.sparcName + ", %o1\n  call printf\n  nop");
    } else if(name.equals("println")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC1), " + sparcRegister.sparcName + "\n  or " + sparcRegister.sparcName + ", %lo(.LCC1), " + sparcRegister.sparcName + "\n  mov " + this.reg.sparcName + ", %o1\n  call printf\n  nop");
    } else if(name.equals("read")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC2), " + sparcRegister.sparcName + "\n  or " + sparcRegister.sparcName + ", %lo(.LCC2), " + sparcRegister.sparcName + "\n  call scanf\n  nop\n  ldsw [%fp-20], %o1");
    }
    return "";
  }
  
  public String toString()
  {
    return new String(name + " " + reg);
  }
}
