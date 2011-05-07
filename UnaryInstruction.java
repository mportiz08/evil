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
    } else if(name.equals("print")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC0), " + sparcRegister + "\n  or " + sparcRegister + ", %lo(.LCC0), " + sparcRegister + "\n  mov " + this.reg + ", %o1\n  call printf\n  nop");
    } else if(name.equals("println")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC1), " + sparcRegister + "\n  or " + sparcRegister + ", %lo(.LCC1), " + sparcRegister + "\n  mov " + this.reg + ", %o1\n  call printf\n  nop");
    } else if(name.equals("read")) {
      sparcRegister.name = "%o0";
      return new String("sethi %hi(.LCC2), " + sparcRegister + "\n  or " + sparcRegister + ", %lo(.LCC2), " + sparcRegister + "\n  call scanf\n  nop\n  ldsw [%fp-20], %o1");
    }
    return "";
  }
  
  public String toString()
  {
    return new String(name + " " + reg);
  }
}
