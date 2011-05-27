import java.util.*;

public class StoreVariableInstruction extends Instruction
{
  private String vname;
  private Register reg;
  private Register sparcRegister;
  private Register sparcRegister2;
  
  public StoreVariableInstruction(String vname, Register reg, Register sparcRegister)
  {
    super("storeai");
    this.vname = vname;
    this.reg = reg;
    this.sparcRegister = sparcRegister;
    this.sparcRegister2 = new Register();
  }
  
  public ArrayList<Register> getSources()
  {
    ArrayList<Register> sources = new ArrayList<Register>();
    sources.add(reg);
    sources.add(sparcRegister2);
    return sources;
  }
  
  public ArrayList<Register> getDests()
  {
    ArrayList<Register> sources = new ArrayList<Register>();
    sources.add(sparcRegister);
    sources.add(sparcRegister2);
    return sources;
  }
  
  public String toSparc(){
    if(sparcRegister.global){
      return new String("set " + vname + ", " + sparcRegister2.sparcName + "\n  stsw " + reg.sparcName + ", [" + sparcRegister2.sparcName + "]");
    }
    else{
      return new String("mov " + reg.sparcName + ", " + sparcRegister.sparcName);
    }
  }
  
  public String toString()
  {
    return new String(this.name + " " + this.reg + ", rarp, " + this.vname);
  }
}
