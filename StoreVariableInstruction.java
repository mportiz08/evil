import java.util.*;

public class StoreVariableInstruction extends Instruction
{
  private String vname;
  private Register reg;
  private Register sparcRegister;
  
  public StoreVariableInstruction(String vname, Register reg, Register sparcRegister)
  {
    super("storeai");
    this.vname = vname;
    this.reg = reg;
    this.sparcRegister = sparcRegister;
  }
  
  public String toSparc(){
    return new String("mov " + reg.sparcName + ", " + sparcRegister.sparcName);
  }
  
  public String toString()
  {
    return new String(this.name + " " + this.reg + ", rarp, " + this.vname);
  }
}
